package com.servlet;

import com.alibaba.fastjson.JSON;
import com.entity.InboundItem;
import com.entity.InboundOrder;
import com.entity.SysUser;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.DruidUtils;
import com.jsj.isdt.utils.ResultData;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.apache.commons.dbutils.handlers.MapHandler;
import org.apache.commons.dbutils.handlers.MapListHandler;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

public class ServletInbound extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "list":
                listInbound(req, resp);
                break;
            case "save":
                saveInbound(req, resp);
                break;
            case "getItems":
                getItems(req, resp);
                break;
            case "planOptions":
                planOptions(req, resp);
                break;
            case "planOptionsAvailable":
                planOptionsAvailable(req, resp);
                break;
            case "planConsumableOptions":
                planConsumableOptions(req, resp);
                break;
            case "planRemaining":
                planRemaining(req, resp);
                break;
            case "genBatchNo":
                genBatchNo(req, resp);
                break;
            default:
                resp.getWriter().write("{\"total\":0,\"rows\":[]}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doGet(req, resp);
    }

    private SysUser getLoginUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null)
            return null;
        Object u = session.getAttribute("loginUser");
        return (u instanceof SysUser) ? (SysUser) u : null;
    }

    // 入库单列表（含入库状态：已完成/部分入库）
    private void listInbound(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }
        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        Map<String, Object> map = new HashMap<>();
        Connection conn = null;
        try {
            String sqlCount = "SELECT COUNT(*) FROM inbound_order WHERE lab_id=?";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount, user.getLab_id()).toString());
            map.put("total", total);

            // 联查采购计划：若有关联计划，判断是否已完全入库
            String sqlList = "SELECT o.*, l.lab_name, u.real_name AS inbound_user_name, " +
                    "  CASE WHEN o.plan_id IS NULL THEN '已完成' " +
                    "       WHEN (SELECT COUNT(*) FROM purchase_plan_item pi " +
                    "             LEFT JOIN inbound_item ii ON ii.inbound_id=o.id AND ii.consumable_id=pi.consumable_id "
                    +
                    "             WHERE pi.plan_id=o.plan_id AND (ii.id IS NULL OR ii.quantity < pi.plan_quantity)) > 0 "
                    +
                    "       THEN '部分入库' ELSE '已完成' END AS inbound_status, " +
                    "  (SELECT GROUP_CONCAT(CONCAT('计划',id,' - ',DATE_FORMAT(create_time,'%Y-%m-%d')) SEPARATOR '; ') "
                    +
                    "   FROM purchase_plan p WHERE p.id = o.plan_id) AS plan_info " +
                    "FROM inbound_order o " +
                    "LEFT JOIN lab l ON o.lab_id=l.id " +
                    "LEFT JOIN sys_user u ON o.inbound_user_id=u.id " +
                    "WHERE o.lab_id=? ORDER BY o.id DESC LIMIT ?,?";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> list = DBUtils.runner().query(
                    conn, sqlList, new MapListHandler(),
                    user.getLab_id(), (pageIndex - 1) * pageSize, pageSize);
            map.put("rows", list == null ? new ArrayList<>() : list);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * 保存入库单 + 明细 + 更新库存
     * 参数：
     * - plan_id（可空）
     * - supplier
     * - itemsJson: [{consumable_id, quantity, unit_price, batch_no, product_date,
     * expire_date}]
     */
    private void saveInbound(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null) {
            rd.setCode("401");
            rd.setMsg("未登录或未绑定实验室");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String planIdStr = req.getParameter("plan_id");
        String supplier = req.getParameter("supplier");
        String itemsJson = req.getParameter("itemsJson");

        if (itemsJson == null || itemsJson.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请添加入库明细");
            out.write(JSON.toJSONString(rd));
            return;
        }

        List<InboundItem> items;
        try {
            items = JSON.parseArray(itemsJson, InboundItem.class);
        } catch (Exception e) {
            rd.setCode("400");
            rd.setMsg("明细数据格式错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        if (items == null || items.isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请添加入库明细");
            out.write(JSON.toJSONString(rd));
            return;
        }

        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);

            Integer planId = null;
            if (planIdStr != null && !planIdStr.trim().isEmpty()) {
                planId = Integer.parseInt(planIdStr);
            }

            // 如果选择了采购计划：必须为“已通过”，且属于当前实验室
            if (planId != null) {
                Object cntObj = DBUtils.runner().query(
                        conn,
                        "SELECT COUNT(*) FROM purchase_plan WHERE id=? AND lab_id=? AND status=2",
                        new org.apache.commons.dbutils.handlers.ScalarHandler<>(),
                        planId, user.getLab_id());
                int cnt = cntObj == null ? 0 : Integer.parseInt(cntObj.toString());
                if (cnt <= 0) {
                    throw new RuntimeException("当前采购计划不可用（需为已通过状态）");
                }
            }
            // 1. 插入入库主表
            String sqlOrder = "INSERT INTO inbound_order(plan_id, lab_id, inbound_user_id, supplier, status) " +
                    "VALUES(?,?,?,?,1)";
            int inboundId = DBUtils.UpdateAndGetKey(conn, sqlOrder, planId, user.getLab_id(), user.getId(), supplier);
            // 2. 插入入库明细
            String sqlItem = "INSERT INTO inbound_item(inbound_id, consumable_id, batch_no, quantity, unit_price, product_date, expire_date) "
                    +
                    "VALUES(?,?,?,?,?,?,?)";
            for (InboundItem it : items) {
                if (it.getConsumable_id() == null) {
                    throw new IllegalArgumentException("明细缺少耗材ID");
                }
                if (it.getQuantity() == null || it.getQuantity() <= 0) {
                    throw new IllegalArgumentException("入库数量必须大于0（耗材ID=" + it.getConsumable_id() + "）");
                }

                // 校验入库数量不能超过采购计划剩余可入库数量
                Integer maxQty = null;
                java.math.BigDecimal planUnitPrice = null;
                if (planId != null) {
                    Map<?, ?> planItem = (Map<?, ?>) DBUtils.runner().query(
                            conn,
                            "SELECT plan_quantity, plan_price FROM purchase_plan_item WHERE plan_id=? AND consumable_id=?",
                            new MapHandler(),
                            planId, it.getConsumable_id());
                    if (planItem == null) {
                        // 捕获异常，返回友好提示
                        throw new RuntimeException("该耗材不属于当前采购计划，请重新选择");
                    }
                    Object maxQtyObj = planItem.get("plan_quantity");
                    int planQty = maxQtyObj == null ? 0 : Integer.parseInt(maxQtyObj.toString());
                    planUnitPrice = (java.math.BigDecimal) planItem.get("plan_price");

                    // 计算已入库数量（本次入库单之前）
                    Object alreadyObj = DBUtils.runner().query(conn,
                            "SELECT COALESCE(SUM(ii.quantity),0) FROM inbound_item ii " +
                                    "JOIN inbound_order io ON ii.inbound_id=io.id " +
                                    "WHERE io.plan_id=? AND ii.consumable_id=?",
                            new org.apache.commons.dbutils.handlers.ScalarHandler<>(),
                            planId, it.getConsumable_id());
                    int alreadyQty = alreadyObj == null ? 0 : Integer.parseInt(alreadyObj.toString());
                    maxQty = planQty - alreadyQty;
                    if (maxQty < 0)
                        maxQty = 0;

                    if (it.getQuantity() > maxQty) {
                        throw new RuntimeException("入库数量不能超过采购计划剩余可入库量，请修改");
                    }
                }

                // 单价必填；若前端未填且有计划单价，则使用计划单价
                if (it.getUnit_price() == null) {
                    if (planUnitPrice != null) {
                        it.setUnit_price(planUnitPrice);
                    } else {
                        throw new IllegalArgumentException("单价不能为空（耗材ID=" + it.getConsumable_id() + "）");
                    }
                }

                DBUtils.Update(conn, sqlItem, inboundId, it.getConsumable_id(), it.getBatch_no(),
                        it.getQuantity(), it.getUnit_price(), it.getProduct_date(), it.getExpire_date());

                // 更新/插入库存
                Object stockObj = DBUtils.runner().query(conn,
                        "SELECT id, total_quantity FROM stock WHERE lab_id=? AND consumable_id=?",
                        new MapHandler(),
                        user.getLab_id(), it.getConsumable_id());
                if (stockObj == null) {
                    DBUtils.Update(conn,
                            "INSERT INTO stock(lab_id, consumable_id, total_quantity, safe_quantity, warning_quantity) "
                                    +
                                    "VALUES(?,?,?,0,0)",
                            user.getLab_id(), it.getConsumable_id(), it.getQuantity());
                } else {
                    Map<?, ?> m = (Map<?, ?>) stockObj;
                    int cur = Integer.parseInt(m.get("total_quantity").toString());
                    int newQty = cur + it.getQuantity();
                    DBUtils.Update(conn,
                            "UPDATE stock SET total_quantity=? WHERE id=?",
                            newQty, m.get("id"));
                }
            }

            // 若有采购计划且状态为已通过，可以在这里根据业务需要做标记（例如“已完成入库”）
            if (planId != null) {
                // 示例：不强制改变原状态，只做备注；可按需要扩展
            }

            conn.commit();
            rd.setCode("200");
            rd.setMsg("入库登记成功，库存已更新");
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            String msg = e.getMessage();
            // 业务校验：直接提示给用户
            if (e instanceof IllegalArgumentException || e instanceof RuntimeException) {
                rd.setCode("400");
                rd.setMsg(msg);
            } else {
                // 连接池类技术异常：替换为业务易懂的提示
                if (msg != null
                        && (msg.contains("wait millis") || msg.contains("maxActive") || msg.contains("creating 0"))) {
                    rd.setCode("500");
                    rd.setMsg("服务器繁忙：数据库连接池已满，请稍后再试");
                } else {
                    rd.setCode("500");
                    rd.setMsg("入库失败：请检查数据后重试");
                }
            }
        } finally {
            closeQuietly(conn);
            out.write(JSON.toJSONString(rd));
        }
    }

    private void getItems(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String inboundId = req.getParameter("inbound_id");
        if (inboundId == null || inboundId.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            String sql = "SELECT i.*, c.name AS consumable_name, c.unit " +
                    "FROM inbound_item i " +
                    "LEFT JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE i.inbound_id=? ORDER BY i.id";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> list = DBUtils.runner().query(
                    conn, sql, new MapListHandler(), Integer.parseInt(inboundId));
            out.write(JSON.toJSONString(list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeQuietly(conn);
        }
    }

    // 下拉：已审核通过的采购计划（status=2）
    private void planOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            String sql = "SELECT id, create_time FROM purchase_plan p WHERE status=2 AND lab_id=?";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> list = DBUtils.runner().query(conn, sql, new MapListHandler(), user.getLab_id());
            List<Map<String, Object>> result = new ArrayList<>();
            for (Map<String, Object> p : list) {
                int id = Integer.parseInt(p.get("id").toString());
                String createTime = "";
                Object createTimeObj = p.get("create_time");
                if (createTimeObj instanceof java.time.LocalDateTime) {
                    java.time.LocalDateTime ldt = (java.time.LocalDateTime) createTimeObj;
                    java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter
                            .ofPattern("yyyy-MM-dd");
                    createTime = ldt.format(formatter);
                } else if (createTimeObj instanceof java.util.Date) {
                    createTime = new java.text.SimpleDateFormat("yyyy-MM-dd").format((java.util.Date) createTimeObj);
                }

                // 计算计划状态
                String status = calculatePlanStatus(id);

                Map<String, Object> item = new HashMap<>();
                item.put("id", id);
                item.put("text", "计划" + id + " - " + createTime + status);
                item.put("status", status);
                result.add(item);
            }
            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeQuietly(conn);
        }
    }

    // 计算采购计划状态
    private String calculatePlanStatus(int planId) throws Exception {
        // 获取计划中的耗材总数
        String sqlItemCount = "SELECT COUNT(*) FROM purchase_plan_item WHERE plan_id=?";
        int itemCount = Integer.parseInt(DBUtils.QueryScalar(sqlItemCount, planId).toString());

        if (itemCount == 0) {
            return "（待入库）";
        }

        // 获取已完全入库的耗材数量
        String sqlCompletedCount = "SELECT COUNT(*) FROM purchase_plan_item pi " +
                "WHERE pi.plan_id=? AND EXISTS (" +
                "    SELECT 1 FROM inbound_item ii " +
                "    JOIN inbound_order io ON ii.inbound_id=io.id " +
                "    WHERE io.plan_id=pi.plan_id AND ii.consumable_id=pi.consumable_id " +
                "    GROUP BY ii.consumable_id " +
                "    HAVING SUM(ii.quantity) >= pi.plan_quantity " +
                ")";
        int completedCount = Integer.parseInt(DBUtils.QueryScalar(sqlCompletedCount, planId).toString());

        if (completedCount == 0) {
            return "（待入库）";
        } else if (completedCount < itemCount) {
            return "（部分入库）";
        } else {
            return "（已完成入库）";
        }
    }

    /**
     * 下拉：某采购计划对应的可入库耗材（只返回计划明细中的耗材）
     * 返回字段结构与 ServletOutbound?action=consumableOptions
     * 一致：[{id,text,name,unit,is_dangerous},...]
     */
    private void planConsumableOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("[]");
            return;
        }
        String planIdStr = req.getParameter("plan_id");
        if (planIdStr == null || planIdStr.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            int planId = Integer.parseInt(planIdStr);
            String sql = "SELECT c.id, c.name, c.unit, c.is_dangerous, " +
                    "       SUM(i.plan_quantity) AS plan_quantity, " +
                    "       MAX(i.plan_price) AS plan_price " +
                    "FROM purchase_plan_item i " +
                    "LEFT JOIN consumable c ON i.consumable_id = c.id " +
                    "LEFT JOIN purchase_plan p ON i.plan_id = p.id " +
                    "WHERE i.plan_id = ? AND p.lab_id = ? " +
                    "GROUP BY c.id, c.name, c.unit, c.is_dangerous " +
                    "ORDER BY c.id DESC";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> raw = DBUtils.runner().query(conn, sql, new MapListHandler(), planId, user.getLab_id());

            List<Map<String, Object>> list = new ArrayList<>();
            for (Map<String, Object> r : raw) {
                Map<String, Object> m = new HashMap<>();
                Object id = r.get("id");
                Object name = r.get("name");
                Object unit = r.get("unit");
                Object danger = r.get("is_dangerous");
                Object planQuantity = r.get("plan_quantity");
                Object planPrice = r.get("plan_price");
                m.put("id", id);
                String text = (name == null ? "" : name.toString()) + "（" + (unit == null ? "" : unit.toString()) + "）"
                        +
                        (danger != null && Integer.parseInt(danger.toString()) == 1 ? "【危】" : "");
                m.put("text", text);
                m.put("name", name);
                m.put("unit", unit);
                m.put("is_dangerous", danger);
                m.put("plan_quantity", planQuantity);
                m.put("plan_price", planPrice);
                list.add(m);
            }
            out.write(JSON.toJSONString(list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * 仅展示「已通过且未完全入库」的采购计划
     * 完全入库：所有明细的已入库量 >= 计划量
     */
    private void planOptionsAvailable(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            String sql = "SELECT p.id, CONCAT('计划',p.id,' - ',DATE_FORMAT(p.create_time,'%Y-%m-%d')) AS text " +
                    "FROM purchase_plan p " +
                    "WHERE p.status=2 AND p.lab_id=? " +
                    "AND EXISTS (" +
                    "  SELECT 1 FROM purchase_plan_item pi " +
                    "  WHERE pi.plan_id=p.id " +
                    "  AND pi.plan_quantity > COALESCE((" +
                    "    SELECT SUM(ii.quantity) FROM inbound_item ii " +
                    "    JOIN inbound_order io ON ii.inbound_id=io.id " +
                    "    WHERE io.plan_id=p.id AND ii.consumable_id=pi.consumable_id" +
                    "  ),0)" +
                    ") ORDER BY p.id DESC";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> list = DBUtils.runner().query(conn, sql, new MapListHandler(), user.getLab_id());
            out.write(JSON.toJSONString(list == null ? new ArrayList<>() : list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * 查询某采购计划各耗材剩余可入库数量
     * 返回：[{consumable_id, consumable_name, unit, plan_quantity, already_qty,
     * remaining_qty, plan_price, is_dangerous}]
     */
    private void planRemaining(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("[]");
            return;
        }
        String planIdStr = req.getParameter("plan_id");
        if (planIdStr == null || planIdStr.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            int planId = Integer.parseInt(planIdStr);
            String sql = "SELECT pi.consumable_id, c.name AS consumable_name, c.unit, c.is_dangerous, " +
                    "  pi.plan_quantity, pi.plan_price, " +
                    "  COALESCE((SELECT SUM(ii.quantity) FROM inbound_item ii " +
                    "    JOIN inbound_order io ON ii.inbound_id=io.id " +
                    "    WHERE io.plan_id=? AND ii.consumable_id=pi.consumable_id),0) AS already_qty, " +
                    "  (pi.plan_quantity - COALESCE((SELECT SUM(ii.quantity) FROM inbound_item ii " +
                    "    JOIN inbound_order io ON ii.inbound_id=io.id " +
                    "    WHERE io.plan_id=? AND ii.consumable_id=pi.consumable_id),0)) AS remaining_qty " +
                    "FROM purchase_plan_item pi " +
                    "JOIN consumable c ON pi.consumable_id=c.id " +
                    "WHERE pi.plan_id=? " +
                    "HAVING remaining_qty > 0 " +
                    "ORDER BY pi.consumable_id";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> list = DBUtils.runner().query(conn, sql, new MapListHandler(), planId, planId, planId);
            out.write(JSON.toJSONString(list == null ? new ArrayList<>() : list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * 生成批次号：RK + 入库单ID + YYYYMMDD + 两位序号
     * 若 inbound_id 为空（新建时），用临时序号
     */
    private void genBatchNo(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=utf-8");
        PrintWriter out = resp.getWriter();
        String inboundIdStr = req.getParameter("inbound_id");
        String seqStr = req.getParameter("seq");
        int seq = seqStr == null ? 1 : Integer.parseInt(seqStr);
        String date = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
        String idPart = (inboundIdStr == null || inboundIdStr.trim().isEmpty()) ? "NEW" : inboundIdStr;
        String batchNo = "RK" + idPart + date + String.format("%02d", seq);
        if (batchNo.length() > 20)
            batchNo = batchNo.substring(0, 20);
        Map<String, Object> result = new HashMap<>();
        result.put("batch_no", batchNo);
        out.write(JSON.toJSONString(result));
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException ignored) {
            }
            try {
                conn.close();
            } catch (SQLException ignored) {
            }
        }
    }
}