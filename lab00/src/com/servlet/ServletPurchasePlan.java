package com.servlet;

import com.alibaba.fastjson.JSON;
import com.entity.PurchasePlan;
import com.entity.PurchasePlanItem;
import com.entity.SysUser;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.DruidUtils;
import com.jsj.isdt.utils.ResultData;
import org.apache.commons.dbutils.handlers.BeanListHandler;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

public class ServletPurchasePlan extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "listMine":
                listMine(req, resp);
                break;
            case "save":
                savePlan(req, resp);
                break;
            case "getItems":
                getItems(req, resp);
                break;
            case "submit":
                submitPlan(req, resp);
                break;
            case "delete":
                deletePlan(req, resp);
                break;
            case "listPending":
                listPending(req, resp);
                break;
            case "audit":
                auditPlan(req, resp);
                break;
            case "listAudited":
                listAudited(req, resp);
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

    // 实验室管理员：查看本人填报的采购计划
    private void listMine(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }
        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        Map<String, Object> map = new HashMap<>();
        try {
            String sqlCount = "SELECT COUNT(*) FROM purchase_plan WHERE apply_user_id=?";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount, user.getId()).toString());
            map.put("total", total);

            String sqlList = "SELECT p.*, l.lab_name, u.real_name AS apply_user_name, au.real_name AS audit_user_name "
                    +
                    "FROM purchase_plan p " +
                    "LEFT JOIN lab l ON p.lab_id=l.id " +
                    "LEFT JOIN sys_user u ON p.apply_user_id=u.id " +
                    "LEFT JOIN sys_user au ON p.audit_user_id=au.id " +
                    "WHERE p.apply_user_id=? ORDER BY p.id DESC LIMIT ?,?";
            List<PurchasePlan> list = DBUtils.QueryBeanList(sqlList, PurchasePlan.class,
                    user.getId(), (pageIndex - 1) * pageSize, pageSize);
            map.put("rows", list);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    /**
     * 保存采购计划（新增/修改）+ 明细，使用 JSON 明细数组
     * 参数：
     * - id（可空，空=新增）
     * - itemsJson: [{consumable_id, plan_quantity, plan_price, remark}, ...]
     * - total_amount（选填，可前端计算好）
     */
    private void savePlan(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
        String itemsJson = req.getParameter("itemsJson");
        String totalAmountStr = req.getParameter("total_amount");

        if (itemsJson == null || itemsJson.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请添加采购明细");
            out.write(JSON.toJSONString(rd));
            return;
        }

        List<PurchasePlanItem> items;
        try {
            items = JSON.parseArray(itemsJson, PurchasePlanItem.class);
        } catch (Exception e) {
            rd.setCode("400");
            rd.setMsg("明细数据格式错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        if (items == null || items.isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请添加采购明细");
            out.write(JSON.toJSONString(rd));
            return;
        }

        java.math.BigDecimal totalAmount = null;
        if (totalAmountStr != null && !totalAmountStr.trim().isEmpty()) {
            totalAmount = new java.math.BigDecimal(totalAmountStr.trim());
        }

        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);

            Integer planId;
            if (idStr == null || idStr.trim().isEmpty()) {
                String sqlPlan = "INSERT INTO purchase_plan(lab_id, apply_user_id, total_amount, status) " +
                        "VALUES(?,?,?,0)";
                planId = DBUtils.UpdateAndGetKey(conn, sqlPlan, user.getLab_id(), user.getId(), totalAmount);
            } else {
                planId = Integer.parseInt(idStr);
                String sqlPlan = "UPDATE purchase_plan SET total_amount=? WHERE id=? AND status=0";
                DBUtils.Update(conn, sqlPlan, totalAmount, planId);
                DBUtils.Update(conn, "DELETE FROM purchase_plan_item WHERE plan_id=?", planId);
            }

            String sqlItem = "INSERT INTO purchase_plan_item(plan_id, consumable_id, plan_quantity, plan_price, remark) "
                    +
                    "VALUES(?,?,?,?,?)";
            for (PurchasePlanItem it : items) {
                if (it.getConsumable_id() == null || it.getPlan_quantity() == null || it.getPlan_quantity() <= 0) {
                    throw new RuntimeException("明细数量必须大于0");
                }
                if (it.getPlan_price() == null || it.getPlan_price().compareTo(java.math.BigDecimal.ZERO) < 0) {
                    throw new RuntimeException("计划单价为必填项，且不能为负数");
                }
                DBUtils.Update(conn, sqlItem, planId, it.getConsumable_id(), it.getPlan_quantity(),
                        it.getPlan_price(), it.getRemark());
            }

            conn.commit();
            rd.setCode("200");
            rd.setMsg("保存成功（当前状态为草稿）");
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            rd.setCode("500");
            rd.setMsg("保存失败：" + e.getMessage());
        } finally {
            closeQuietly(conn);
            out.write(JSON.toJSONString(rd));
        }
    }

    private void getItems(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String planId = req.getParameter("plan_id");
        if (planId == null || planId.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        try {
            String sql = "SELECT i.*, c.name AS consumable_name, c.unit " +
                    "FROM purchase_plan_item i " +
                    "LEFT JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE i.plan_id=? ORDER BY i.id";
            List<PurchasePlanItem> list = DBUtils.QueryBeanList(sql, PurchasePlanItem.class, Integer.parseInt(planId));
            out.write(JSON.toJSONString(list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        }
    }

    private void submitPlan(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            int r = DBUtils.Update("UPDATE purchase_plan SET status=1 WHERE id=? AND status=0",
                    Integer.parseInt(idStr));
            if (r > 0) {
                rd.setCode("200");
                rd.setMsg("已提交审核");
            } else {
                rd.setCode("409");
                rd.setMsg("当前状态不可提交，或记录不存在");
            }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("提交失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    private void deletePlan(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        Connection conn = null;
        try {
            int planId = Integer.parseInt(idStr);
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);
            // 先校验状态
            Object statusObj = DBUtils.runner().query(conn,
                    "SELECT status FROM purchase_plan WHERE id=?",
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), planId);
            if (statusObj == null) {
                rd.setCode("404");
                rd.setMsg("记录不存在");
                out.write(JSON.toJSONString(rd));
                return;
            }
            int status = Integer.parseInt(statusObj.toString());
            if (status != 0) {
                rd.setCode("409");
                rd.setMsg("仅允许删除草稿状态的采购计划");
                out.write(JSON.toJSONString(rd));
                return;
            }
            // 先删子表，再删主表（避免外键约束报错）
            DBUtils.Update(conn, "DELETE FROM purchase_plan_item WHERE plan_id=?", planId);
            DBUtils.Update(conn, "DELETE FROM purchase_plan WHERE id=?", planId);
            conn.commit();
            rd.setCode("200");
            rd.setMsg("删除成功");
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ignored) {
                }
            }
            rd.setCode("500");
            rd.setMsg("删除失败：" + e.getMessage());
        } finally {
            closeQuietly(conn);
            out.write(JSON.toJSONString(rd));
        }
    }

    // 系统管理员：查看待审核采购计划
    private void listPending(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        Map<String, Object> map = new HashMap<>();
        try {
            String sqlCount = "SELECT COUNT(*) FROM purchase_plan WHERE status=1";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount).toString());
            map.put("total", total);

            String sqlList = "SELECT p.*, l.lab_name, u.real_name AS apply_user_name, au.real_name AS audit_user_name "
                    +
                    "FROM purchase_plan p " +
                    "LEFT JOIN lab l ON p.lab_id=l.id " +
                    "LEFT JOIN sys_user u ON p.apply_user_id=u.id " +
                    "LEFT JOIN sys_user au ON p.audit_user_id=au.id " +
                    "WHERE p.status=1 ORDER BY p.id DESC LIMIT ?,?";
            List<PurchasePlan> list = DBUtils.QueryBeanList(sqlList, PurchasePlan.class,
                    (pageIndex - 1) * pageSize, pageSize);
            map.put("rows", list);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    // 系统管理员：审核采购计划（通过/退回）
    private void auditPlan(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
        String pass = req.getParameter("pass");
        String comment = req.getParameter("comment");
        if (idStr == null || pass == null) {
            rd.setCode("400");
            rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        int newStatus = "1".equals(pass) ? 2 : 3; // 2=已通过 3=已退回
        try {
            String sql = "UPDATE purchase_plan SET status=?, audit_user_id=?, audit_time=NOW(), audit_comment=? " +
                    "WHERE id=? AND status=1";
            int r = DBUtils.Update(sql, newStatus, user.getId(), comment, Integer.parseInt(idStr));
            if (r > 0) {
                rd.setCode("200");
                rd.setMsg(newStatus == 2 ? "审核通过" : "已退回");
            } else {
                rd.setCode("409");
                rd.setMsg("状态已变更，请刷新后重试");
            }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("审核失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    // 系统管理员：查看已审核采购计划（自己审核过的）
    private void listAudited(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }
        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        Map<String, Object> map = new HashMap<>();
        try {
            String sqlCount = "SELECT COUNT(*) FROM purchase_plan WHERE audit_user_id=?";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount, user.getId()).toString());
            map.put("total", total);

            String sqlList = "SELECT p.*, l.lab_name, u.real_name AS apply_user_name, au.real_name AS audit_user_name "
                    +
                    "FROM purchase_plan p " +
                    "LEFT JOIN lab l ON p.lab_id=l.id " +
                    "LEFT JOIN sys_user u ON p.apply_user_id=u.id " +
                    "LEFT JOIN sys_user au ON p.audit_user_id=au.id " +
                    "WHERE p.audit_user_id=? ORDER BY p.audit_time DESC LIMIT ?,?";
            List<PurchasePlan> list = DBUtils.QueryBeanList(sqlList, PurchasePlan.class,
                    user.getId(), (pageIndex - 1) * pageSize, pageSize);
            map.put("rows", list);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        }
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