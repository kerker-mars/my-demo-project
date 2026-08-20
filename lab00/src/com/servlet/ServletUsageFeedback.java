package com.servlet;

import com.alibaba.fastjson.JSON;
import com.entity.SysUser;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.DruidUtils;
import com.jsj.isdt.utils.ResultData;
import org.apache.commons.dbutils.handlers.MapListHandler;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 教师：对已提交的领用单填写/修改「使用反馈」
 * 依赖表：usage_feedback（见项目根目录 扩展_usage_feedback表.sql）
 */
public class ServletUsageFeedback extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "listMine":
                listMine(req, resp);
                break;
            case "myOrderOptions":
                myOrderOptions(req, resp);
                break;
            case "save":
                save(req, resp);
                break;
            case "update":
                update(req, resp);
                break;
            case "listAll":
                listAll(req, resp);
                break;
            case "reply":
                reply(req, resp);
                break;
            case "countUnread":
                countUnread(req, resp);
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
        if (session == null) return null;
        Object u = session.getAttribute("loginUser");
        return (u instanceof SysUser) ? (SysUser) u : null;
    }

    private boolean isTeacherRole(SysUser user) {
        try {
            if (user == null || user.getRole_id() == null) return false;
            Object rn = DBUtils.QueryScalar("SELECT role_name FROM sys_role WHERE id=?", user.getRole_id());
            if (rn == null) return false;
            return rn.toString().contains("教师");
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 我的反馈列表（分页 + 筛选）
     */
    private void listMine(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || !isTeacherRole(user)) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }
        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize  = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        String category       = req.getParameter("category");
        String feedbackStatus = req.getParameter("feedback_status");
        String keyword        = req.getParameter("keyword"); // 领用单号
        String dateFrom       = req.getParameter("date_from");
        String dateTo         = req.getParameter("date_to");

        StringBuilder where = new StringBuilder("WHERE f.user_id=?");
        List<Object> params = new ArrayList<>();
        params.add(user.getId());
        if (category != null && !category.trim().isEmpty()) {
            where.append(" AND f.category=?"); params.add(category.trim());
        }
        if (feedbackStatus != null && !feedbackStatus.trim().isEmpty()) {
            where.append(" AND f.feedback_status=?"); params.add(Integer.parseInt(feedbackStatus.trim()));
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            try { int kid = Integer.parseInt(keyword.trim()); where.append(" AND f.outbound_order_id=?"); params.add(kid); }
            catch (Exception ignored) {}
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            where.append(" AND DATE(f.create_time)>=?"); params.add(dateFrom.trim());
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            where.append(" AND DATE(f.create_time)<=?"); params.add(dateTo.trim());
        }

        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            String sqlCount = "SELECT COUNT(*) FROM usage_feedback f " + where;
            Object totalObj = DBUtils.runner().query(conn, sqlCount,
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), params.toArray());
            int total = totalObj == null ? 0 : Integer.parseInt(totalObj.toString());
            Map<String, Object> map = new HashMap<>();
            map.put("total", total);

            String sqlList = "SELECT f.id, f.outbound_order_id, f.content, f.category, " +
                    "       f.feedback_status, f.admin_reply, f.create_time, f.update_time, " +
                    "       o.status AS order_status, o.purpose, o.course_name, o.class_name, l.lab_name " +
                    "FROM usage_feedback f " +
                    "JOIN outbound_order o ON f.outbound_order_id=o.id " +
                    "LEFT JOIN lab l ON o.lab_id=l.id " +
                    where + " ORDER BY f.id DESC LIMIT ?, ?";
            List<Object> listParams = new ArrayList<>(params);
            listParams.add((pageIndex - 1) * pageSize);
            listParams.add(pageSize);
            List<Map<String, Object>> rows = DBUtils.runner().query(conn, sqlList,
                    new MapListHandler(), listParams.toArray());
            map.put("rows", rows == null ? new ArrayList<>() : rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            if (conn != null) try { DruidUtils.close(null, null, conn); } catch (Exception ignored) {}
        }
    }

    /**
     * 下拉：本人领用单（优先已出库单据）
     */
    private void myOrderOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || !isTeacherRole(user)) { out.write("[]"); return; }
        Connection conn = null;
        try {
            // 已出库(status=3)排在前面
            String sql = "SELECT o.id AS id, " +
                    "CONCAT('单号', o.id, ' | ', IFNULL(o.purpose,''), ' | ', " +
                    "CASE o.status WHEN 3 THEN '已出库' WHEN 0 THEN '待审核' WHEN 1 THEN '待出库' WHEN 2 THEN '已驳回' ELSE '其他' END) AS text, " +
                    "o.status AS order_status " +
                    "FROM outbound_order o WHERE o.apply_user_id=? " +
                    "ORDER BY CASE o.status WHEN 3 THEN 0 ELSE 1 END, o.id DESC LIMIT 200";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(conn, sql, new MapListHandler(), user.getId());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            if (conn != null) try { DruidUtils.close(null, null, conn); } catch (Exception ignored) {}
        }
    }

    /**
     * 保存反馈（新增）
     */
    private void save(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null || !isTeacherRole(user)) {
            rd.setCode("403"); rd.setMsg("仅教师可提交使用反馈");
            out.write(JSON.toJSONString(rd)); return;
        }
        String oidStr    = req.getParameter("outbound_order_id");
        String content   = req.getParameter("content");
        String category  = req.getParameter("category");
        if (oidStr == null || content == null || content.trim().isEmpty()) {
            rd.setCode("400"); rd.setMsg("请选择领用单并填写反馈内容");
            out.write(JSON.toJSONString(rd)); return;
        }
        if (content.length() > 500) {
            rd.setCode("400"); rd.setMsg("反馈内容不超过500字");
            out.write(JSON.toJSONString(rd)); return;
        }
        if (category == null || category.trim().isEmpty()) category = "其他";
        try {
            int oid = Integer.parseInt(oidStr);
            Object cnt = DBUtils.QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE id=? AND apply_user_id=?", oid, user.getId());
            if (cnt == null || Integer.parseInt(cnt.toString()) == 0) {
                rd.setCode("403"); rd.setMsg("只能对本人申请的领用单提交反馈");
                out.write(JSON.toJSONString(rd)); return;
            }
            String upsert = "INSERT INTO usage_feedback (outbound_order_id, user_id, content, category, feedback_status) VALUES (?,?,?,?,0) " +
                    "ON DUPLICATE KEY UPDATE content=VALUES(content), category=VALUES(category), feedback_status=0, update_time=NOW()";
            DBUtils.Update(upsert, oid, user.getId(), content.trim(), category.trim());
            rd.setCode("200"); rd.setMsg("反馈提交成功");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500"); rd.setMsg("保存失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    /**
     * 编辑已有反馈（通过 feedback.id 更新）
     */
    private void update(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null || !isTeacherRole(user)) {
            rd.setCode("403"); rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd)); return;
        }
        String idStr    = req.getParameter("id");
        String content  = req.getParameter("content");
        String category = req.getParameter("category");
        if (idStr == null || content == null || content.trim().isEmpty()) {
            rd.setCode("400"); rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd)); return;
        }
        if (content.length() > 500) {
            rd.setCode("400"); rd.setMsg("反馈内容不超过500字");
            out.write(JSON.toJSONString(rd)); return;
        }
        if (category == null || category.trim().isEmpty()) category = "其他";
        try {
            int r = DBUtils.Update(
                    "UPDATE usage_feedback SET content=?, category=?, feedback_status=0, update_time=NOW() WHERE id=? AND user_id=?",
                    content.trim(), category.trim(), Integer.parseInt(idStr), user.getId());
            if (r > 0) { rd.setCode("200"); rd.setMsg("反馈已更新"); }
            else { rd.setCode("404"); rd.setMsg("记录不存在或无权限修改"); }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500"); rd.setMsg("更新失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    /** 管理员：未处理反馈数 */
    private void countUnread(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        try {
            Object cnt = DBUtils.QueryScalar("SELECT COUNT(*) FROM usage_feedback WHERE feedback_status=0");
            Map<String, Object> r = new HashMap<>();
            r.put("count", cnt == null ? 0 : Integer.parseInt(cnt.toString()));
            out.write(JSON.toJSONString(r));
        } catch (Exception e) { out.write("{\"count\":0}"); }
    }

    /** 管理员：反馈列表（分页+筛选） */
    private void listAll(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) { out.write("{\"total\":0,\"rows\":[]}"); return; }
        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize  = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        String category = req.getParameter("category");
        String feedbackStatus = req.getParameter("feedback_status");
        String keyword  = req.getParameter("keyword");
        String dateFrom = req.getParameter("date_from");
        String dateTo   = req.getParameter("date_to");

        StringBuilder where = new StringBuilder("WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (category != null && !category.trim().isEmpty()) { where.append(" AND f.category=?"); params.add(category.trim()); }
        if (feedbackStatus != null && !feedbackStatus.trim().isEmpty()) { where.append(" AND f.feedback_status=?"); params.add(Integer.parseInt(feedbackStatus.trim())); }
        if (keyword != null && !keyword.trim().isEmpty()) {
            try { int kid = Integer.parseInt(keyword.trim()); where.append(" AND f.outbound_order_id=?"); params.add(kid); } catch (Exception ignored) {}
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) { where.append(" AND DATE(f.create_time)>=?"); params.add(dateFrom.trim()); }
        if (dateTo   != null && !dateTo.trim().isEmpty())   { where.append(" AND DATE(f.create_time)<=?"); params.add(dateTo.trim()); }

        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            String sqlCount = "SELECT COUNT(*) FROM usage_feedback f " + where;
            Object totalObj = DBUtils.runner().query(conn, sqlCount, new org.apache.commons.dbutils.handlers.ScalarHandler<>(), params.toArray());
            int total = totalObj == null ? 0 : Integer.parseInt(totalObj.toString());
            Map<String, Object> map = new HashMap<>();
            map.put("total", total);
            String sqlList = "SELECT f.id, f.outbound_order_id, f.content, f.category, " +
                    "f.feedback_status, f.admin_reply, f.create_time, f.update_time, " +
                    "u.real_name AS teacher_name, o.course_name, o.class_name, o.purpose, l.lab_name, " +
                    "GROUP_CONCAT(DISTINCT c.name ORDER BY c.id SEPARATOR '、') AS consumable_names " +
                    "FROM usage_feedback f " +
                    "JOIN outbound_order o ON f.outbound_order_id=o.id " +
                    "JOIN sys_user u ON f.user_id=u.id " +
                    "LEFT JOIN lab l ON o.lab_id=l.id " +
                    "LEFT JOIN outbound_item oi ON oi.outbound_id=o.id " +
                    "LEFT JOIN consumable c ON oi.consumable_id=c.id " +
                    where + " GROUP BY f.id ORDER BY f.feedback_status ASC, f.id DESC LIMIT ?, ?";
            List<Object> listParams = new ArrayList<>(params);
            listParams.add((pageIndex - 1) * pageSize);
            listParams.add(pageSize);
            List<Map<String, Object>> rows = DBUtils.runner().query(conn, sqlList, new MapListHandler(), listParams.toArray());
            map.put("rows", rows == null ? new ArrayList<>() : rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            if (conn != null) try { DruidUtils.close(null, null, conn); } catch (Exception ignored) {}
        }
    }

    /** 管理员：回复/标记反馈 */
    private void reply(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null) { rd.setCode("401"); rd.setMsg("未登录"); out.write(JSON.toJSONString(rd)); return; }
        String idStr  = req.getParameter("id");
        String replyContent = req.getParameter("reply");
        String status = req.getParameter("status");
        if (idStr == null) { rd.setCode("400"); rd.setMsg("参数错误"); out.write(JSON.toJSONString(rd)); return; }
        int newStatus = (status != null && "1".equals(status)) ? 1 : 2;
        try {
            if (replyContent != null && !replyContent.trim().isEmpty()) {
                DBUtils.Update("UPDATE usage_feedback SET admin_reply=?, feedback_status=?, update_time=NOW() WHERE id=?",
                        replyContent.trim(), newStatus, Integer.parseInt(idStr));
            } else {
                DBUtils.Update("UPDATE usage_feedback SET feedback_status=?, update_time=NOW() WHERE id=?",
                        newStatus, Integer.parseInt(idStr));
            }
            rd.setCode("200"); rd.setMsg(newStatus == 2 ? "已标记为已处理" : "已标记为已查看");
        } catch (Exception e) {
            e.printStackTrace(); rd.setCode("500"); rd.setMsg("操作失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }
}
