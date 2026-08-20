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
 * 归还登记与审核（return_record + stock.total_quantity 反向回补）
 *
 * 业务对齐：
 * - 教师提交：针对 outbound_item（should_return=1）的归还数量/反馈，生成 return_record(status=0)
 * - 实验室管理员审核：status=0 -> 1（通过）或 2（驳回）
 * - 通过时回补库存：stock.total_quantity += return_quantity
 */
public class ServletReturn extends HttpServlet {

    /**
     * Servlet 初始化时幂等添加所需字段，避免手动执行 SQL 遗漏
     */
    @Override
    public void init() {
        try {
            // return_record 加 reject_reason 字段（字段不存在时才加）
            Object colRejectReason = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?",
                    "return_record", "reject_reason");
            if (colRejectReason == null || Integer.parseInt(colRejectReason.toString()) == 0) {
                DBUtils.Update("ALTER TABLE return_record ADD COLUMN reject_reason VARCHAR(200) NULL");
            }

            // outbound_item 加 returned_quantity 字段（字段不存在时才加）
            Object colReturnedQty = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?",
                    "outbound_item", "returned_quantity");
            if (colReturnedQty == null || Integer.parseInt(colReturnedQty.toString()) == 0) {
                DBUtils.Update("ALTER TABLE outbound_item ADD COLUMN returned_quantity INT NOT NULL DEFAULT 0");
            }

            // outbound_order 加 second_audit_user_id 字段（字段不存在时才加）
            Object colSecondAuditUserId = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?",
                    "outbound_order", "second_audit_user_id");
            if (colSecondAuditUserId == null || Integer.parseInt(colSecondAuditUserId.toString()) == 0) {
                DBUtils.Update("ALTER TABLE outbound_order ADD COLUMN second_audit_user_id INT NULL");
            }

            // outbound_order 加 second_audit_time 字段（字段不存在时才加）
            Object colSecondAuditTime = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?",
                    "outbound_order", "second_audit_time"
            );
            if (colSecondAuditTime == null || Integer.parseInt(colSecondAuditTime.toString()) == 0) {
                DBUtils.Update("ALTER TABLE outbound_order ADD COLUMN second_audit_time DATETIME NULL");
            }
            // outbound_order 加 borrow_time 字段（字段不存在时才加）
            Object colBorrowTime = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?",
                    "outbound_order", "borrow_time"
            );
            if (colBorrowTime == null || Integer.parseInt(colBorrowTime.toString()) == 0) {
                DBUtils.Update("ALTER TABLE outbound_order ADD COLUMN borrow_time DATETIME NULL");
            }
        } catch (Exception e) {
            // 初始化失败不影响 Servlet 正常启动，仅打印日志
            System.err.println("[ServletReturn.init] 自动初始化表结构失败：" + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");

        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "listReturnableItems":
                listReturnableItems(req, resp);
                break;
            case "listMyReturns":
                listMyReturns(req, resp);
                break;
            case "listPending":
                listPending(req, resp);
                break;
            case "create":
                createReturn(req, resp);
                break;
            case "audit":
                auditReturn(req, resp);
                break;
            case "listAll":
                listAll(req, resp);
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

    /**
     * 教师：可归还列表
     * 条件：领用单已出库（status=3）、申请人为当前用户、该明细尚无“待审核/已通过”的归还记录。
     * 说明：不再强制 i.should_return=1——教师领用申请里“需归还”常默认为否，会导致列表长期为空无法测试；
     *      列表中仍展示 should_return 字段供业务识别。
     */
    private void listReturnableItems(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
            // 返回所有已出库明细：
            // - need_return=1（需归还）：剩余可归还量 > 0 的才展示（支持部分归还）
            // - need_return=0（无需归还）：全部展示，供教师查看，但前端禁止操作
            String baseWhere =
                    "FROM outbound_item i " +
                    "JOIN outbound_order o ON i.outbound_id=o.id " +
                    "JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE o.apply_user_id=? AND o.status=3 " +
                    "AND (" +
                    "  i.should_return = 0 " +   // 无需归还：全部展示
                    "  OR (" +
                    "    i.should_return = 1 " +  // 需归还：剩余量 > 0 才展示
                    "    AND (i.quantity " +
                    "         - COALESCE((SELECT SUM(r3.return_quantity) FROM return_record r3 " +
                    "                     WHERE r3.outbound_item_id=i.id AND r3.status=1),0) " +
                    "         - COALESCE((SELECT SUM(r4.return_quantity) FROM return_record r4 " +
                    "                     WHERE r4.outbound_item_id=i.id AND r4.status=0),0)" +
                    "    ) > 0" +
                    "  )" +
                    ")";

            String sqlCount = "SELECT COUNT(*) " + baseWhere;
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount, user.getId()).toString());
            map.put("total", total);

            String sqlList = "SELECT i.id AS outbound_item_id, " +
                    "       c.name AS consumable_name, c.unit, " +
                    "       i.quantity AS original_quantity, " +
                    "       i.should_return AS need_return, " +
                    "       o.id AS outbound_id, o.course_name, o.class_name, o.purpose, " +
                    "       o.status AS outbound_status, " +
                    "       COALESCE(o.borrow_time, o.audit_time, o.second_audit_time) AS borrow_time, " +
                    "       COALESCE((SELECT SUM(r3.return_quantity) FROM return_record r3 " +
                    "                 WHERE r3.outbound_item_id=i.id AND r3.status=1),0) AS already_returned, " +
                    "       (i.quantity " +
                    "        - COALESCE((SELECT SUM(r3.return_quantity) FROM return_record r3 " +
                    "                    WHERE r3.outbound_item_id=i.id AND r3.status=1),0) " +
                    "        - COALESCE((SELECT SUM(r4.return_quantity) FROM return_record r4 " +
                    "                    WHERE r4.outbound_item_id=i.id AND r4.status=0),0)" +
                    "       ) AS remaining_qty " +
                    baseWhere +
                    " ORDER BY i.id DESC LIMIT ?, ?";

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
     * 教师：我的归还记录
     */
    private void listMyReturns(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
            String sqlCount = "SELECT COUNT(*) FROM return_record WHERE return_user_id=?";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount, user.getId()).toString());
            map.put("total", total);

            String sqlList = "SELECT rr.id, rr.status, rr.return_quantity, rr.feedback, " +
                    "       rr.apply_time, rr.check_time, " +
                    "       c.name AS consumable_name, c.unit, " +
                    "       o.course_name, o.class_name, o.purpose " +
                    "FROM return_record rr " +
                    "JOIN outbound_item i ON rr.outbound_item_id=i.id " +
                    "JOIN outbound_order o ON i.outbound_id=o.id " +
                    "JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE rr.return_user_id=? " +
                    "ORDER BY rr.id DESC LIMIT ?, ?";

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
     * 实验室管理员：待审核归还
     */
    private void listPending(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }

        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));

        Map<String, Object> map = new HashMap<>();
        Connection conn = null;
        try {
            String sqlCount = "SELECT COUNT(*) " +
                    "FROM return_record rr " +
                    "JOIN outbound_item i ON rr.outbound_item_id=i.id " +
                    "JOIN outbound_order o ON i.outbound_id=o.id " +
                    "WHERE o.lab_id=? AND rr.status=0";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount, user.getLab_id()).toString());
            map.put("total", total);

            String sqlList = "SELECT rr.id, rr.return_quantity, rr.feedback, rr.apply_time, rr.status, " +
                    "       u.real_name AS return_user_name, " +
                    "       c.name AS consumable_name, c.unit, " +
                    "       o.course_name, o.class_name " +
                    "FROM return_record rr " +
                    "JOIN outbound_item i ON rr.outbound_item_id=i.id " +
                    "JOIN outbound_order o ON i.outbound_id=o.id " +
                    "JOIN consumable c ON i.consumable_id=c.id " +
                    "JOIN sys_user u ON rr.return_user_id=u.id " +
                    "WHERE o.lab_id=? AND rr.status=0 " +
                    "ORDER BY rr.id DESC LIMIT ?, ?";

            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn,
                    sqlList,
                    new MapListHandler(),
                    user.getLab_id(),
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
     * 教师提交归还
     * 参数：
     * - outbound_item_id
     * - return_quantity
     * - feedback
     */
    private void createReturn(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null) {
            rd.setCode("401");
            rd.setMsg("未登录");
            out.write(JSON.toJSONString(rd));
            return;
        }

        String outboundItemIdStr = req.getParameter("outbound_item_id");
        String qtyStr = req.getParameter("return_quantity");
        String feedback = req.getParameter("feedback");

        try {
            if (outboundItemIdStr == null || outboundItemIdStr.trim().isEmpty()) {
                rd.setCode("400");
                rd.setMsg("参数错误：outbound_item_id");
                out.write(JSON.toJSONString(rd));
                return;
            }
            int outboundItemId = Integer.parseInt(outboundItemIdStr);

            int qty = Integer.parseInt(qtyStr == null ? "0" : qtyStr.trim());
            if (qty <= 0) {
                rd.setCode("400");
                rd.setMsg("归还数量必须大于0");
                out.write(JSON.toJSONString(rd));
                return;
            }

            if (feedback == null) feedback = "";

            // 校验：该明细必须属于当前教师、且领用单已出库(status=3)（与列表条件一致）
            Connection conn = null;
            Map<?, ?> base;
            try {
                conn = DruidUtils.getConnection();
                base = (Map<?, ?>) DBUtils.runner().query(
                        conn,
                    "SELECT i.quantity AS original_qty, i.consumable_id, o.lab_id " +
                            "FROM outbound_item i " +
                            "JOIN outbound_order o ON i.outbound_id=o.id " +
                            "WHERE i.id=? AND o.apply_user_id=? AND o.status=3",
                    new MapHandler(),
                    outboundItemId, user.getId()
                );
            } finally {
                closeQuietly(conn);
            }
            if (base == null) {
                rd.setCode("403");
                rd.setMsg("该领用明细不可归还（不属于你或不满足归还条件）");
                out.write(JSON.toJSONString(rd));
                return;
            }

            int originalQty = Integer.parseInt(base.get("original_qty").toString());
            if (qty > originalQty) {
                rd.setCode("400");
                rd.setMsg("归还数量不能超过领用数量 " + originalQty);
                out.write(JSON.toJSONString(rd));
                return;
            }

            // 校验：已通过归还量 + 待审核归还量 + 本次归还量 不能超过原始领用量
            Object approvedObj = DBUtils.QueryScalar(
                    "SELECT COALESCE(SUM(return_quantity),0) FROM return_record WHERE outbound_item_id=? AND status=1",
                    outboundItemId
            );
            Object pendingObj = DBUtils.QueryScalar(
                    "SELECT COALESCE(SUM(return_quantity),0) FROM return_record WHERE outbound_item_id=? AND status=0",
                    outboundItemId
            );
            int approvedQty = approvedObj == null ? 0 : Integer.parseInt(approvedObj.toString());
            int pendingQty  = pendingObj  == null ? 0 : Integer.parseInt(pendingObj.toString());
            int usedQty = approvedQty + pendingQty;
            if (usedQty + qty > originalQty) {
                int canReturn = originalQty - usedQty;
                if (canReturn <= 0) {
                    rd.setCode("409");
                    rd.setMsg("该耗材已全部归还或归还申请处理中，无可归还数量");
                } else {
                    rd.setCode("400");
                    rd.setMsg("归还数量超出剩余可归还量（最多可归还 " + canReturn + "）");
                }
                out.write(JSON.toJSONString(rd));
                return;
            }

            int r = DBUtils.Update(
                    "INSERT INTO return_record(outbound_item_id, return_user_id, return_quantity, feedback, status) VALUES(?,?,?,?,0)",
                    outboundItemId, user.getId(), qty, feedback
            );
            if (r > 0) {
                rd.setCode("200");
                rd.setMsg("提交归还成功，等待审核");
            } else {
                rd.setCode("501");
                rd.setMsg("提交归还失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("提交归还失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    /**
     * 实验室管理员：全量归还记录（多维过滤分页）
     */
    private void listAll(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }

        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize  = req.getParameter("rows") == null ? 15 : Integer.parseInt(req.getParameter("rows"));
        String statusParam         = req.getParameter("status");
        String consumableNameParam = req.getParameter("consumable_name");
        String returnUserParam     = req.getParameter("return_user");
        String courseNameParam     = req.getParameter("course_name");
        String classNameParam      = req.getParameter("class_name");

        StringBuilder where = new StringBuilder(
            "FROM return_record rr " +
            "JOIN outbound_item i ON rr.outbound_item_id=i.id " +
            "JOIN outbound_order o ON i.outbound_id=o.id " +
            "JOIN consumable c ON i.consumable_id=c.id " +
            "JOIN sys_user u ON rr.return_user_id=u.id " +
            "LEFT JOIN sys_user cu ON rr.check_user_id=cu.id " +
            "WHERE o.lab_id=?"
        );
        List<Object> params = new ArrayList<>();
        params.add(user.getLab_id());

        if (statusParam != null && !statusParam.trim().isEmpty()) {
            where.append(" AND rr.status=?");
            params.add(Integer.parseInt(statusParam.trim()));
        }
        if (consumableNameParam != null && !consumableNameParam.trim().isEmpty()) {
            where.append(" AND c.name LIKE ?");
            params.add("%" + consumableNameParam.trim() + "%");
        }
        if (returnUserParam != null && !returnUserParam.trim().isEmpty()) {
            where.append(" AND u.real_name LIKE ?");
            params.add("%" + returnUserParam.trim() + "%");
        }
        if (courseNameParam != null && !courseNameParam.trim().isEmpty()) {
            where.append(" AND o.course_name LIKE ?");
            params.add("%" + courseNameParam.trim() + "%");
        }
        if (classNameParam != null && !classNameParam.trim().isEmpty()) {
            where.append(" AND o.class_name LIKE ?");
            params.add("%" + classNameParam.trim() + "%");
        }

        Map<String, Object> map = new HashMap<>();
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();

            String sqlCount = "SELECT COUNT(*) " + where;
            Object totalObj = DBUtils.runner().query(conn, sqlCount,
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), params.toArray());
            int total = totalObj == null ? 0 : Integer.parseInt(totalObj.toString());
            map.put("total", total);

            String sqlList = "SELECT rr.id, rr.return_quantity, rr.feedback, rr.apply_time, rr.status, " +
                    "       rr.check_time, rr.reject_reason, " +
                    "       u.real_name AS return_user_name, " +
                    "       cu.real_name AS check_user_name, " +
                    "       c.name AS consumable_name, c.unit, c.is_dangerous, " +
                    "       o.course_name, o.class_name, o.id AS outbound_order_id, " +
                    "       o.audit_time AS borrow_time " +
                    where + " ORDER BY CASE rr.status WHEN 0 THEN 1 WHEN 2 THEN 2 ELSE 3 END, rr.id DESC LIMIT ?, ?";

            List<Object> listParams = new ArrayList<>(params);
            listParams.add((pageIndex - 1) * pageSize);
            listParams.add(pageSize);

            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sqlList,
                    new org.apache.commons.dbutils.handlers.MapListHandler(),
                    listParams.toArray());
            map.put("rows", rows == null ? new ArrayList<>() : rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    }

    /**
     * 审核归还：status=0 -> 1/2
     * 参数：
     * - id：return_record.id
     * - pass：1通过，0驳回
     */
    private void auditReturn(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null) {
            rd.setCode("401");
            rd.setMsg("未登录或未绑定实验室");
            out.write(JSON.toJSONString(rd));
            return;
        }

        String idStr = req.getParameter("id");
        String passStr = req.getParameter("pass");
        String rejectReason = req.getParameter("reject_reason");
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
                        "SELECT rr.return_quantity, i.consumable_id, o.lab_id, i.quantity AS original_qty, i.id AS outbound_item_id " +
                                "FROM return_record rr " +
                                "JOIN outbound_item i ON rr.outbound_item_id=i.id " +
                                "JOIN outbound_order o ON i.outbound_id=o.id " +
                                "WHERE rr.id=? AND rr.status=0",
                        new MapHandler(),
                        id
                );
                if (base == null) {
                    throw new RuntimeException("该归还记录不存在或已被处理");
                }

                int labId = Integer.parseInt(base.get("lab_id").toString());
                if (labId != user.getLab_id()) {
                    throw new RuntimeException("无权限审核该归还记录");
                }

                int consumableId = Integer.parseInt(base.get("consumable_id").toString());
                int qty = Integer.parseInt(base.get("return_quantity").toString());

                if (pass == 1) {
                    int originalQty = Integer.parseInt(base.get("original_qty").toString());
                    int outboundItemId = Integer.parseInt(base.get("outbound_item_id").toString());
                    if (qty <= 0) {
                        throw new RuntimeException("归还数量必须大于0");
                    }
                    if (qty > originalQty) {
                        throw new RuntimeException("归还数量不能超过原领用数量，请核对");
                    }

                    int updated = DBUtils.Update(
                            conn,
                            "UPDATE return_record SET status=1, check_user_id=?, check_time=NOW() WHERE id=? AND status=0",
                            user.getId(), id
                    );
                    if (updated <= 0) throw new RuntimeException("审核失败：状态变更冲突");

                    // 回补库存（若库存行不存在则插入）
                    Object stockObj = DBUtils.runner().query(
                            conn,
                            "SELECT id,total_quantity FROM stock WHERE lab_id=? AND consumable_id=?",
                            new MapHandler(),
                            labId, consumableId
                    );
                    if (stockObj == null) {
                        DBUtils.Update(
                                conn,
                                "INSERT INTO stock(lab_id, consumable_id, total_quantity, safe_quantity, warning_quantity) VALUES(?,?,?,0,0)",
                                labId, consumableId, qty
                        );
                    } else {
                        Map<?, ?> m = (Map<?, ?>) stockObj;
                        int cur = Integer.parseInt(m.get("total_quantity").toString());
                        DBUtils.Update(
                                conn,
                                "UPDATE stock SET total_quantity=? WHERE id=?",
                                cur + qty, m.get("id")
                        );
                    }

                    // 更新已归还数量
                    DBUtils.Update(conn, "UPDATE outbound_item SET returned_quantity=returned_quantity+? WHERE id=?",
                            qty, outboundItemId);
                } else {
                    if (rejectReason == null || rejectReason.trim().isEmpty()) {
                        rd.setCode("400");
                        rd.setMsg("请填写驳回理由");
                        out.write(JSON.toJSONString(rd));
                        return;
                    }
                    int updated = DBUtils.Update(
                            conn,
                            "UPDATE return_record SET status=2, check_user_id=?, check_time=NOW(), reject_reason=? WHERE id=? AND status=0",
                            user.getId(), rejectReason.trim(), id
                    );
                    if (updated <= 0) throw new RuntimeException("驳回失败：状态变更冲突");
                }

                conn.commit();
                rd.setCode("200");
                rd.setMsg(pass == 1 ? "归还审核通过，库存已回补" : "归还审核驳回");
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

