package com.servlet;

import com.alibaba.fastjson.JSON;
import com.entity.SysUser;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.DruidUtils;
import com.jsj.isdt.utils.ResultData;
import org.apache.commons.dbutils.QueryRunner;
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
 * 实验室库存盘点（inventory_check / inventory_check_item + 回写 stock）
 */
public class ServletInventory extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "list":
                list(req, resp);
                break;
            case "labUserOptions":
                labUserOptions(req, resp);
                break;
            case "create":
                create(req, resp);
                break;
            case "listItems":
                listItems(req, resp);
                break;
            case "updateItem":
                updateItem(req, resp);
                break;
            case "complete":
                complete(req, resp);
                break;
            case "completeSummary":
                completeSummary(req, resp);
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

    private boolean isLabAdmin(SysUser user) {
        try {
            if (user == null || user.getRole_id() == null)
                return false;
            Object rn = DBUtils.QueryScalar("SELECT role_name FROM sys_role WHERE id=?", user.getRole_id());
            return rn != null && rn.toString().contains("实验室管理员");
        } catch (Exception e) {
            return false;
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null || !isLabAdmin(user)) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }
        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        Connection conn = null;
        try {
            int total = Integer.parseInt(
                    DBUtils.QueryScalar("SELECT COUNT(*) FROM inventory_check WHERE lab_id=?", user.getLab_id())
                            .toString());
            Map<String, Object> map = new HashMap<>();
            map.put("total", total);
            String sql = "SELECT ic.*, " +
                    "u1.real_name AS checker1_name, u2.real_name AS checker2_name " +
                    "FROM inventory_check ic " +
                    "LEFT JOIN sys_user u1 ON ic.checker1_id=u1.id " +
                    "LEFT JOIN sys_user u2 ON ic.checker2_id=u2.id " +
                    "WHERE ic.lab_id=? ORDER BY ic.status ASC, ic.id DESC LIMIT ?, ?";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(conn, sql, new MapListHandler(),
                    user.getLab_id(), (pageIndex - 1) * pageSize, pageSize);
            map.put("rows", rows == null ? new ArrayList<>() : rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            closeConn(conn);
        }
    }

    /** 本实验室用户（第二盘点人下拉，自动排除当前用户） */
    private void labUserOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null || !isLabAdmin(user)) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            // 排除当前用户自己
            String sql = "SELECT id, CONCAT(real_name, ' (', username, ')') AS text FROM sys_user " +
                    "WHERE lab_id=? AND status=1 AND id != ? ORDER BY id";
            List<Map<String, Object>> rows = DBUtils.runner().query(conn, sql, new MapListHandler(),
                    user.getLab_id(), user.getId());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeConn(conn);
        }
    }

    private void create(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null || !isLabAdmin(user)) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String period = req.getParameter("period");
        String scope = req.getParameter("scope"); // "all"/"dangerous"/"normal"
        if (period == null || period.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请填写盘点周期");
            out.write(JSON.toJSONString(rd));
            return;
        }
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);
            QueryRunner run = DBUtils.runner();
            String insH = "INSERT INTO inventory_check (lab_id, period, scope, checker1_id, checker2_id, status) VALUES (?,?,?,?,NULL,0)";
            run.update(conn, insH, user.getLab_id(), period.trim(), scope, user.getId());
            Object lid = run.query(conn, "SELECT LAST_INSERT_ID()",
                    new org.apache.commons.dbutils.handlers.ScalarHandler());
            int invId = Integer.parseInt(lid.toString());

            // 根据盘点范围筛选耗材
            String scopeFilter = "";
            if ("dangerous".equals(scope)) {
                scopeFilter = " AND c.is_dangerous=1";
            } else if ("normal".equals(scope)) {
                scopeFilter = " AND c.is_dangerous=0";
            }
            String insI = "INSERT INTO inventory_check_item (inventory_id, consumable_id, system_quantity, real_quantity, diff_quantity) "
                    +
                    "SELECT ?, s.consumable_id, s.total_quantity, s.total_quantity, 0 " +
                    "FROM stock s JOIN consumable c ON s.consumable_id=c.id " +
                    "WHERE s.lab_id=? AND s.total_quantity>=0" + scopeFilter;
            run.update(conn, insI, invId, user.getLab_id());
            conn.commit();
            rd.setCode("200");
            rd.setMsg("盘点单已生成，请录入实盘数量后完成盘点");
        } catch (Exception e) {
            e.printStackTrace();
            rollback(conn);
            rd.setCode("500");
            rd.setMsg("创建失败： " + e.getMessage());
        } finally {
            closeConn(conn);
        }
        out.write(JSON.toJSONString(rd));
    }

    private void listItems(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null || !isLabAdmin(user)) {
            out.write("[]");
            return;
        }
        String iid = req.getParameter("inventory_id");
        String keyword = req.getParameter("keyword"); // 耗材名称筛选
        if (iid == null) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            Object cnt = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM inventory_check WHERE id=? AND lab_id=?",
                    Integer.parseInt(iid), user.getLab_id());
            if (cnt == null || Integer.parseInt(cnt.toString()) == 0) {
                out.write("[]");
                return;
            }
            conn = DruidUtils.getConnection();
            String sql = "SELECT i.*, c.name AS consumable_name, c.unit, c.is_dangerous " +
                    "FROM inventory_check_item i " +
                    "JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE i.inventory_id=?" +
                    (keyword != null && !keyword.trim().isEmpty() ? " AND c.name LIKE ?" : "") +
                    " ORDER BY i.id";
            List<Map<String, Object>> rows;
            if (keyword != null && !keyword.trim().isEmpty()) {
                rows = DBUtils.runner().query(conn, sql, new MapListHandler(),
                        Integer.parseInt(iid), "%" + keyword.trim() + "%");
            } else {
                rows = DBUtils.runner().query(conn, sql, new MapListHandler(), Integer.parseInt(iid));
            }
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeConn(conn);
        }
    }

    private void updateItem(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null || !isLabAdmin(user)) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String itemId = req.getParameter("id");
        String realQty = req.getParameter("real_quantity");
        if (itemId == null || realQty == null) {
            rd.setCode("400");
            rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            String verify = "SELECT ic.status FROM inventory_check_item ii " +
                    "JOIN inventory_check ic ON ii.inventory_id=ic.id " +
                    "WHERE ii.id=? AND ic.lab_id=?";
            Object st = DBUtils.runner().query(conn, verify, new org.apache.commons.dbutils.handlers.ScalarHandler(),
                    Integer.parseInt(itemId), user.getLab_id());
            if (st == null) {
                rd.setCode("404");
                rd.setMsg("记录不存在");
                out.write(JSON.toJSONString(rd));
                return;
            }
            if (Integer.parseInt(st.toString()) != 0) {
                rd.setCode("400");
                rd.setMsg("该盘点单已完成，不可修改");
                out.write(JSON.toJSONString(rd));
                return;
            }
            int rq = Integer.parseInt(realQty);
            if (rq < 0)
                rq = 0;
            String remark = req.getParameter("remark");
            String up = "UPDATE inventory_check_item SET real_quantity=?, diff_quantity=(? - system_quantity), remark=? WHERE id=?";
            DBUtils.runner().update(conn, up, rq, rq, remark, Integer.parseInt(itemId));
            rd.setCode("200");
            rd.setMsg("已保存");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        } finally {
            closeConn(conn);
        }
        out.write(JSON.toJSONString(rd));
    }

    private void complete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null || !isLabAdmin(user)) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String iid = req.getParameter("inventory_id");
        if (iid == null) {
            rd.setCode("400");
            rd.setMsg("缺少盘点单ID");
            out.write(JSON.toJSONString(rd));
            return;
        }
        int invId = Integer.parseInt(iid);
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);
            QueryRunner run = DBUtils.runner();
            Object st = run.query(conn,
                    "SELECT status FROM inventory_check WHERE id=? AND lab_id=?",
                    new org.apache.commons.dbutils.handlers.ScalarHandler(), invId, user.getLab_id());
            if (st == null) {
                rd.setCode("404");
                rd.setMsg("盘点单不存在");
                out.write(JSON.toJSONString(rd));
                return;
            }
            if (Integer.parseInt(st.toString()) != 0) {
                rd.setCode("400");
                rd.setMsg("该单已完成");
                out.write(JSON.toJSONString(rd));
                return;
            }
            String upStock = "UPDATE stock s " +
                    "INNER JOIN inventory_check_item i ON s.consumable_id=i.consumable_id " +
                    "INNER JOIN inventory_check inv ON i.inventory_id=inv.id AND inv.lab_id=s.lab_id " +
                    "SET s.total_quantity=i.real_quantity " +
                    "WHERE i.inventory_id=? AND inv.lab_id=? AND inv.status=0";
            run.update(conn, upStock, invId, user.getLab_id());
            run.update(conn,
                    "UPDATE inventory_check SET status=1, check_time=NOW() WHERE id=? AND lab_id=?",
                    invId, user.getLab_id());
            conn.commit();

            // 返回差异汇总
            Object diffCount = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM inventory_check_item WHERE inventory_id=? AND diff_quantity!=0", invId);
            Object totalDiff = DBUtils.QueryScalar(
                    "SELECT COALESCE(SUM(ABS(diff_quantity)),0) FROM inventory_check_item WHERE inventory_id=?", invId);
            rd.setCode("200");
            rd.setMsg("盘点完成，库存已按实盘数量更新。差异耗材 " +
                    (diffCount == null ? 0 : diffCount) + " 种，累计调整 " +
                    (totalDiff == null ? 0 : totalDiff) + " 件");
        } catch (Exception e) {
            e.printStackTrace();
            rollback(conn);
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        } finally {
            closeConn(conn);
        }
        out.write(JSON.toJSONString(rd));
    }

    /**
     * 完成盘点前预览差异汇总（不执行回写）
     */
    private void completeSummary(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null || !isLabAdmin(user)) {
            out.write("{}");
            return;
        }
        String iid = req.getParameter("inventory_id");
        if (iid == null) {
            out.write("{}");
            return;
        }
        int invId = Integer.parseInt(iid);
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            // 差异明细
            String sqlDiff = "SELECT c.name AS consumable_name, c.unit, c.is_dangerous, " +
                    "i.system_quantity, i.real_quantity, i.diff_quantity, i.remark " +
                    "FROM inventory_check_item i " +
                    "JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE i.inventory_id=? AND i.diff_quantity!=0 ORDER BY i.diff_quantity";
            List<Map<String, Object>> diffItems = DBUtils.runner().query(conn, sqlDiff, new MapListHandler(), invId);

            // 所有耗材明细（用于导出）
            String sqlAll = "SELECT c.name AS consumable_name, c.unit, c.is_dangerous, " +
                    "i.system_quantity, i.real_quantity, i.diff_quantity, i.remark " +
                    "FROM inventory_check_item i " +
                    "JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE i.inventory_id=? ORDER BY i.id";
            List<Map<String, Object>> allItems = DBUtils.runner().query(conn, sqlAll, new MapListHandler(), invId);

            // 汇总数字
            Object totalItems = DBUtils.runner().query(conn,
                    "SELECT COUNT(*) FROM inventory_check_item WHERE inventory_id=?",
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), invId);
            Object diffCount = DBUtils.runner().query(conn,
                    "SELECT COUNT(*) FROM inventory_check_item WHERE inventory_id=? AND diff_quantity!=0",
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), invId);
            Object posSum = DBUtils.runner().query(conn,
                    "SELECT COALESCE(SUM(diff_quantity),0) FROM inventory_check_item WHERE inventory_id=? AND diff_quantity>0",
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), invId);
            Object negSum = DBUtils.runner().query(conn,
                    "SELECT COALESCE(SUM(diff_quantity),0) FROM inventory_check_item WHERE inventory_id=? AND diff_quantity<0",
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), invId);

            // 盘点单基本信息
            Map<?, ?> invInfo = (Map<?, ?>) DBUtils.runner().query(conn,
                    "SELECT ic.period, ic.scope, u1.real_name AS checker1_name, u2.real_name AS checker2_name, ic.check_time, ic.create_time "
                            +
                            "FROM inventory_check ic " +
                            "LEFT JOIN sys_user u1 ON ic.checker1_id=u1.id " +
                            "LEFT JOIN sys_user u2 ON ic.checker2_id=u2.id " +
                            "WHERE ic.id=?",
                    new org.apache.commons.dbutils.handlers.MapHandler(), invId);

            Map<String, Object> result = new HashMap<>();
            result.put("totalItems", totalItems == null ? 0 : Integer.parseInt(totalItems.toString()));
            result.put("diffCount", diffCount == null ? 0 : Integer.parseInt(diffCount.toString()));
            result.put("posSum", posSum == null ? 0 : Integer.parseInt(posSum.toString()));
            result.put("negSum", negSum == null ? 0 : Integer.parseInt(negSum.toString()));
            result.put("diffItems", diffItems == null ? new ArrayList<>() : diffItems);
            result.put("allItems", allItems == null ? new ArrayList<>() : allItems);
            result.put("invInfo", invInfo);
            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{}");
        } finally {
            closeConn(conn);
        }
    }

    private void rollback(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
        }
    }

    private void closeConn(Connection conn) {
        if (conn != null) {
            try {
                DruidUtils.close(null, null, conn);
            } catch (Exception ignored) {
            }
        }
    }
}
