package com.servlet;

import com.alibaba.fastjson.JSON;
import com.entity.SysUser;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.DruidUtils;
import com.jsj.isdt.utils.ResultData;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 报废登记与审核（scrap_record + stock.total_quantity 扣减）
 *
 * 业务对齐：
 * - 实验室管理员/业务人：申请报废（status=0）
 * - 系统管理员：审核（status=1通过 / 2驳回）
 * - 通过时扣减库存：stock.total_quantity -= quantity
 */
public class ServletScrap extends HttpServlet {

    @Override
    public void init() {
        try {
            // scrap_record 幂等添加 audit_comment 字段（驳回原因）
            Object col = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='scrap_record' AND COLUMN_NAME='audit_comment'");
            if (col == null || Integer.parseInt(col.toString()) == 0) {
                DBUtils.Update("ALTER TABLE scrap_record ADD COLUMN audit_comment VARCHAR(200) NULL COMMENT '审核意见/驳回原因'");
            }
        } catch (Exception e) {
            System.err.println("[ServletScrap.init] 自动初始化表结构失败：" + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");

        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "stockOptions":
                stockOptions(req, resp);
                break;
            case "listMy":
                listMy(req, resp);
                break;
            case "create":
                createScrap(req, resp);
                break;
            case "listPending":
                listPending(req, resp);
                break;
            case "listAll":
                listAll(req, resp);
                break;
            case "audit":
                audit(req, resp);
                break;
            default:
                resp.getWriter().write("{\"total\":0,\"rows\":[]}");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doGet(req, resp);
    }

    private SysUser getLoginUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object u = session.getAttribute("loginUser");
        return (u instanceof SysUser) ? (SysUser) u : null;
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                DruidUtils.close(null, null, conn);
            } catch (Exception ignored) {
            }
        }
    }

    private boolean isSystemAdmin(SysUser user) {
        try {
            if (user == null || user.getRole_id() == null) return false;
            Object roleNameObj = DBUtils.QueryScalar("SELECT role_name FROM sys_role WHERE id=?", user.getRole_id());
            if (roleNameObj == null) return false;
            String roleName = roleNameObj.toString();
            return roleName.contains("系统") && roleName.contains("管理员");
        } catch (Exception ignored) {
            return false;
        }
    }

    /**
     * 下拉：当前实验室可报废耗材（来自 stock 行）
     */
    private void stockOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            String sql = "SELECT s.consumable_id AS id, " +
                    "       c.name AS name, c.unit, " +
                    "       c.is_dangerous, s.total_quantity AS stock_qty " +
                    "FROM stock s " +
                    "JOIN consumable c ON s.consumable_id=c.id " +
                    "WHERE s.lab_id=? AND s.total_quantity>0 " +
                    "ORDER BY s.consumable_id DESC";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> raw = DBUtils.runner().query(
                    conn,
                    sql,
                    new MapListHandler(),
                    user.getLab_id()
            );
            // 规范字段：id/stock_qty 为数字，text 为下拉显示文案（避免 combobox+label 时选中不刷新、BigDecimal 类型不匹配）
            List<Map<String, Object>> list = new ArrayList<>();
            for (Map<String, Object> m : raw) {
                Map<String, Object> row = new HashMap<>();
                Object idObj = m.get("id");
                int id = idObj instanceof Number ? ((Number) idObj).intValue() : Integer.parseInt(String.valueOf(idObj));
                String name = m.get("name") == null ? "" : m.get("name").toString();
                String unit = m.get("unit") == null ? "" : m.get("unit").toString();
                Object sqObj = m.get("stock_qty");
                int sq = sqObj instanceof Number ? ((Number) sqObj).intValue() : Integer.parseInt(String.valueOf(sqObj));
                row.put("id", id);
                row.put("name", name);
                row.put("unit", unit);
                row.put("stock_qty", sq);
                row.put("text", name);  // 下拉只显示耗材名称，单位/库存通过 onSelect 回调展示
                if (m.get("is_dangerous") != null) {
                    row.put("is_dangerous", m.get("is_dangerous"));
                }
                list.add(row);
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
     * 实验室内：我的报废申请记录
     */
    private void listMy(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
            String sqlCount = "SELECT COUNT(*) FROM scrap_record WHERE apply_user_id=?";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount, user.getId()).toString());
            map.put("total", total);

            String sqlList = "SELECT sr.id, sr.status, sr.quantity, sr.reason, sr.apply_time, sr.audit_time, " +
                    "       sr.audit_comment, " +
                    "       c.name AS consumable_name, c.unit, l.lab_name " +
                    "FROM scrap_record sr " +
                    "JOIN consumable c ON sr.consumable_id=c.id " +
                    "JOIN lab l ON sr.lab_id=l.id " +
                    "WHERE sr.apply_user_id=? " +
                    "ORDER BY sr.id DESC LIMIT ?, ?";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn,
                    sqlList,
                    new MapListHandler(),
                    user.getId(),
                    (pageIndex - 1) * pageSize,
                    pageSize
            );
            map.put("rows", rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * 申请报废
     * 参数：consumable_id, quantity, reason
     */
    private void createScrap(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null) {
            rd.setCode("401");
            rd.setMsg("未登录或未绑定实验室");
            out.write(JSON.toJSONString(rd));
            return;
        }

        try {
            String consumableIdStr = req.getParameter("consumable_id");
            String qtyStr = req.getParameter("quantity");
            String reason = req.getParameter("reason");

            if (consumableIdStr == null || consumableIdStr.trim().isEmpty()) {
                rd.setCode("400");
                rd.setMsg("参数错误：consumable_id");
                out.write(JSON.toJSONString(rd));
                return;
            }
            int consumableId = Integer.parseInt(consumableIdStr);

            int qty = Integer.parseInt(qtyStr == null ? "0" : qtyStr.trim());
            if (qty <= 0) {
                rd.setCode("400");
                rd.setMsg("报废数量必须大于0");
                out.write(JSON.toJSONString(rd));
                return;
            }
            if (reason == null || reason.trim().isEmpty()) {
                rd.setCode("400");
                rd.setMsg("报废原因不能为空");
                out.write(JSON.toJSONString(rd));
                return;
            }

            // 校验库存充足
            Object stockObj = DBUtils.QueryScalar(
                    "SELECT total_quantity FROM stock WHERE lab_id=? AND consumable_id=?",
                    user.getLab_id(), consumableId
            );
            int curQty = stockObj == null ? 0 : Integer.parseInt(stockObj.toString());
            if (curQty < qty) {
                rd.setCode("400");
                rd.setMsg("库存不足：当前库存 " + curQty + "，申请报废 " + qty);
                out.write(JSON.toJSONString(rd));
                return;
            }

            int r = DBUtils.Update(
                    "INSERT INTO scrap_record(lab_id, consumable_id, quantity, reason, apply_user_id, status) VALUES(?,?,?,?,?,0)",
                    user.getLab_id(), consumableId, qty, reason, user.getId()
            );
            if (r > 0) {
                rd.setCode("200");
                rd.setMsg("报废申请提交成功，等待审核");
            } else {
                rd.setCode("501");
                rd.setMsg("报废申请提交失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("报废申请失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    /**
     * 系统管理员：待审核报废
     */
    private void listPending(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
            String sqlCount = "SELECT COUNT(*) FROM scrap_record WHERE status=0";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount).toString());
            map.put("total", total);

            String sqlList = "SELECT sr.id, sr.lab_id, l.lab_name, sr.consumable_id, " +
                    "       sr.quantity, sr.reason, sr.apply_time, sr.status, " +
                    "       u.real_name AS apply_user_name, " +
                    "       c.name AS consumable_name, c.unit, c.is_dangerous " +
                    "FROM scrap_record sr " +
                    "JOIN lab l ON sr.lab_id=l.id " +
                    "JOIN sys_user u ON sr.apply_user_id=u.id " +
                    "JOIN consumable c ON sr.consumable_id=c.id " +
                    "WHERE sr.status=0 " +
                    "ORDER BY sr.id DESC LIMIT ?, ?";

            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sqlList, new MapListHandler(),
                    (pageIndex - 1) * pageSize, pageSize);
            map.put("rows", rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * 系统管理员：全部历史报废记录（含已通过/已驳回）
     */
    private void listAll(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
            String sqlCount = "SELECT COUNT(*) FROM scrap_record WHERE status IN (1,2)";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount).toString());
            map.put("total", total);

            String sqlList = "SELECT sr.id, sr.lab_id, l.lab_name, sr.consumable_id, " +
                    "       sr.quantity, sr.reason, sr.apply_time, sr.audit_time, sr.status, sr.audit_comment, " +
                    "       u.real_name AS apply_user_name, " +
                    "       au.real_name AS audit_user_name, " +
                    "       c.name AS consumable_name, c.unit, c.is_dangerous " +
                    "FROM scrap_record sr " +
                    "JOIN lab l ON sr.lab_id=l.id " +
                    "JOIN sys_user u ON sr.apply_user_id=u.id " +
                    "LEFT JOIN sys_user au ON sr.audit_user_id=au.id " +
                    "JOIN consumable c ON sr.consumable_id=c.id " +
                    "WHERE sr.status IN (1,2) " +
                    "ORDER BY sr.id DESC LIMIT ?, ?";

            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sqlList, new MapListHandler(),
                    (pageIndex - 1) * pageSize, pageSize);
            map.put("rows", rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * 审核报废
     * 参数：id, pass(1通过/0驳回)
     */
    private void audit(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null) {
            rd.setCode("401");
            rd.setMsg("未登录");
            out.write(JSON.toJSONString(rd));
            return;
        }

        String idStr = req.getParameter("id");
        String passStr = req.getParameter("pass");
        try {
            if (idStr == null || passStr == null) {
                rd.setCode("400");
                rd.setMsg("参数错误");
                out.write(JSON.toJSONString(rd));
                return;
            }
            int id = Integer.parseInt(idStr);
            int pass = "1".equals(passStr) ? 1 : 0;

            Connection conn = null;
            try {
                conn = DruidUtils.getConnection();
                conn.setAutoCommit(false);

                Map<?, ?> base = (Map<?, ?>) DBUtils.runner().query(
                        conn,
                        "SELECT sr.lab_id, sr.consumable_id, sr.quantity " +
                                "FROM scrap_record sr " +
                                "WHERE sr.id=? AND sr.status=0",
                        new MapHandler(),
                        id
                );
                if (base == null) {
                    throw new RuntimeException("该报废记录不存在或已被处理");
                }

                int labId = Integer.parseInt(base.get("lab_id").toString());
                int consumableId = Integer.parseInt(base.get("consumable_id").toString());
                int qty = Integer.parseInt(base.get("quantity").toString());

                if (pass == 1) {
                    // 二次校验库存（防并发）
                    Object stockObj = DBUtils.runner().query(
                            conn,
                            "SELECT total_quantity FROM stock WHERE lab_id=? AND consumable_id=?",
                            new MapHandler(),
                            labId, consumableId
                    );
                    int curQty = 0;
                    if (stockObj != null) {
                        Map<?, ?> m = (Map<?, ?>) stockObj;
                        Object tq = m.get("total_quantity");
                        if (tq != null) curQty = Integer.parseInt(tq.toString());
                    }
                    if (curQty < qty) {
                        throw new RuntimeException("库存不足，无法审核通过（当前库存 " + curQty + "，需要扣减 " + qty + "）");
                    }

                    int updated = DBUtils.Update(
                            conn,
                            "UPDATE scrap_record SET status=1, audit_user_id=?, audit_time=NOW() WHERE id=? AND status=0",
                            user.getId(), id
                    );
                    if (updated <= 0) throw new RuntimeException("审核失败：状态变更冲突");

                    DBUtils.Update(
                            conn,
                            "UPDATE stock SET total_quantity=total_quantity-? WHERE lab_id=? AND consumable_id=?",
                            qty, labId, consumableId
                    );
                } else {
                    String auditComment = req.getParameter("comment");
                    int updated = DBUtils.Update(
                            conn,
                            "UPDATE scrap_record SET status=2, audit_user_id=?, audit_time=NOW(), audit_comment=? WHERE id=? AND status=0",
                            user.getId(), auditComment, id
                    );
                    if (updated <= 0) throw new RuntimeException("驳回失败：状态变更冲突");
                }

                conn.commit();
                rd.setCode("200");
                rd.setMsg(pass == 1 ? "报废审核通过，库存已扣减" : "报废审核驳回");
            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException ignored) {
                    }
                }
                throw e;
            } finally {
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
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("操作失败：" + e.getMessage());
        }

        out.write(JSON.toJSONString(rd));
    }
}

