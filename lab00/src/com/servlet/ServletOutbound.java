package com.servlet;

import com.alibaba.fastjson.JSON;
import com.entity.OutboundItem;
import com.entity.OutboundOrder;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 领用申请→审核→出库（outbound_order/outbound_item/stock）
 */
public class ServletOutbound extends HttpServlet {

    /**
     * Servlet 初始化时自动建表/加字段，避免手动执行 SQL 遗漏
     */
    @Override
    public void init() {
        try {
            // 建 teacher_course 表
            DBUtils.Update("CREATE TABLE IF NOT EXISTS teacher_course (" +
                    "id INT PRIMARY KEY AUTO_INCREMENT," +
                    "teacher_id INT NOT NULL," +
                    "course_name VARCHAR(100) NOT NULL," +
                    "course_code VARCHAR(50) NULL" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师所授课程表'");

            // 建 teacher_class 表
            DBUtils.Update("CREATE TABLE IF NOT EXISTS teacher_class (" +
                    "id INT PRIMARY KEY AUTO_INCREMENT," +
                    "teacher_id INT NOT NULL," +
                    "class_name VARCHAR(100) NOT NULL," +
                    "class_code VARCHAR(50) NULL" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师所授班级表'");

            // consumable 加 returnable 字段（字段不存在时才加）
            Object colExists = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                            "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='consumable' AND COLUMN_NAME='returnable'");
            if (colExists == null || Integer.parseInt(colExists.toString()) == 0) {
                DBUtils.Update("ALTER TABLE consumable ADD COLUMN returnable TINYINT NOT NULL DEFAULT 0 " +
                        "COMMENT '是否可归还：0消耗品 1可归还'");
                // 初始化归还属性
                DBUtils.Update(
                        "UPDATE consumable SET returnable=1 WHERE category='器皿' OR name IN ('烧杯','量筒','锥形瓶','试管','烧瓶')");
            }

            // 自动为 teacher 账号插入示例课程/班级（若表为空）
            Object teacherCourseCount = DBUtils.QueryScalar("SELECT COUNT(*) FROM teacher_course");
            if (teacherCourseCount == null || Integer.parseInt(teacherCourseCount.toString()) == 0) {
                // 找所有教师角色用户
                Connection initConn = null;
                try {
                    initConn = DruidUtils.getConnection();
                    List<java.util.Map<String, Object>> teachers = DBUtils.runner().query(
                            initConn,
                            "SELECT u.id FROM sys_user u JOIN sys_role r ON u.role_id=r.id WHERE r.role_name='教师' AND u.status=1",
                            new org.apache.commons.dbutils.handlers.MapListHandler());
                    if (teachers != null) {
                        for (java.util.Map<String, Object> t : teachers) {
                            int tid = Integer.parseInt(t.get("id").toString());
                            String[] courses = { "大学物理实验", "有机化学实验", "无机化学实验", "计算机组成原理实验", "数字电路实验" };
                            String[] codes = { "PHY101", "CHE201", "CHE101", "CS301", "EE201" };
                            for (int i = 0; i < courses.length; i++) {
                                DBUtils.Update(
                                        "INSERT IGNORE INTO teacher_course(teacher_id,course_name,course_code) VALUES(?,?,?)",
                                        tid, courses[i], codes[i]);
                            }
                            String[] classes = { "计算机科学2201班", "计算机科学2202班", "软件工程2201班", "软件工程2202班", "网络工程2201班",
                                    "电子信息2201班" };
                            String[] clsCodes = { "CS2201", "CS2202", "SE2201", "SE2202", "NE2201", "EI2201" };
                            for (int i = 0; i < classes.length; i++) {
                                DBUtils.Update(
                                        "INSERT IGNORE INTO teacher_class(teacher_id,class_name,class_code) VALUES(?,?,?)",
                                        tid, classes[i], clsCodes[i]);
                            }
                        }
                    }
                } finally {
                    if (initConn != null)
                        try {
                            initConn.close();
                        } catch (Exception ignored) {
                        }
                }
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
                    "outbound_order", "second_audit_time");
            if (colSecondAuditTime == null || Integer.parseInt(colSecondAuditTime.toString()) == 0) {
                DBUtils.Update("ALTER TABLE outbound_order ADD COLUMN second_audit_time DATETIME NULL");
            }
        } catch (Exception e) {
            // 初始化失败不影响 Servlet 正常启动，仅打印日志
            System.err.println("[ServletOutbound.init] 自动初始化表结构失败：" + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");

        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "consumableOptions":
                consumableOptions(req, resp);
                break;
            case "consumableOptionsWithStock":
                consumableOptionsWithStock(req, resp);
                break;
            case "courseOptions":
                courseOptions(req, resp);
                break;
            case "classOptions":
                classOptions(req, resp);
                break;
            case "create":
                createApply(req, resp);
                break;
            case "saveDraft":
                saveDraft(req, resp);
                break;
            case "cancel":
                cancelApply(req, resp);
                break;
            case "listMine":
                listMine(req, resp);
                break;
            case "listPending":
                listPending(req, resp);
                break;
            case "listOutboundRecords":
                listOutboundRecords(req, resp);
                break;
            case "getItems":
                getItems(req, resp);
                break;
            case "getMyItems":
                getMyItems(req, resp);
                break;
            case "audit1":
                audit1(req, resp);
                break;
            case "audit2":
                audit2(req, resp);
                break;
            case "doOutbound":
                doOutbound(req, resp);
                break;
            case "directOutbound":
                directOutbound(req, resp);
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
        if (session == null)
            return null;
        Object u = session.getAttribute("loginUser");
        return (u instanceof SysUser) ? (SysUser) u : null;
    }

    /**
     * 下拉选择耗材（含当前库存数量 + returnable 属性）
     * 返回：[{id, text, name, unit, is_dangerous, returnable, stock_qty}, ...]
     * 优化：有库存的排在前面，有库存显示绿色，无库存显示红色
     */
    private void consumableOptionsWithStock(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            String sql = "SELECT c.id, c.name, c.unit, c.is_dangerous, c.returnable, " +
                    "COALESCE(s.total_quantity, 0) AS stock_qty " +
                    "FROM consumable c " +
                    "LEFT JOIN stock s ON s.consumable_id=c.id AND s.lab_id=? " +
                    "ORDER BY (COALESCE(s.total_quantity, 0) > 0) DESC, c.id DESC";
            conn = DruidUtils.getConnection();
            List<java.util.Map<String, Object>> raw = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler(), user.getLab_id());
            List<java.util.Map<String, Object>> list = new ArrayList<>();
            for (java.util.Map<String, Object> r : raw) {
                java.util.Map<String, Object> m = new HashMap<>();
                Object id = r.get("id");
                String name = r.get("name") == null ? "" : r.get("name").toString();
                String unit = r.get("unit") == null ? "" : r.get("unit").toString();
                Object danger = r.get("is_dangerous");
                Object returnable = r.get("returnable");
                Object stockQty = r.get("stock_qty");
                int sq = stockQty == null ? 0 : Integer.parseInt(stockQty.toString());
                m.put("id", id);
                m.put("name", name);
                m.put("unit", unit);
                m.put("is_dangerous", danger);
                m.put("returnable", returnable);
                m.put("stock_qty", sq);
                String dangerTag = (danger != null && Integer.parseInt(danger.toString()) == 1) ? "【危】" : "";
                String stockStatus = sq > 0 ? "✓" : "✗";
                m.put("text", name + "（" + unit + "）" + dangerTag + " 库存:" + sq + (sq > 0 ? "" : " (无库存)"));
                m.put("has_stock", sq > 0);
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

    /** 教师课程下拉 */
    private void courseOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            String sql = "SELECT id, course_name AS text, course_name AS value FROM teacher_course WHERE teacher_id=? ORDER BY id";
            conn = DruidUtils.getConnection();
            List<java.util.Map<String, Object>> list = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler(), user.getId());
            out.write(JSON.toJSONString(list == null ? new ArrayList<>() : list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeQuietly(conn);
        }
    }

    /** 教师班级下拉 */
    private void classOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            String sql = "SELECT id, class_name AS text, class_name AS value FROM teacher_class WHERE teacher_id=? ORDER BY id";
            conn = DruidUtils.getConnection();
            List<java.util.Map<String, Object>> list = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler(), user.getId());
            out.write(JSON.toJSONString(list == null ? new ArrayList<>() : list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * 保存草稿（status=-1）：插入或更新 outbound_order，不插入明细
     * 参数：id(可空), course_name, class_name, purpose, itemsJson
     */
    private void saveDraft(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();
        SysUser user = getLoginUser(req);
        if (user == null) {
            rd.setCode("401");
            rd.setMsg("未登录");
            out.write(JSON.toJSONString(rd));
            return;
        }
        if (user.getLab_id() == null) {
            rd.setCode("400");
            rd.setMsg("未绑定实验室");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String idStr = req.getParameter("id");
        String courseName = req.getParameter("course_name");
        String className = req.getParameter("class_name");
        String purpose = req.getParameter("purpose");
        String itemsJson = req.getParameter("itemsJson");
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);
            int orderId;
            if (idStr == null || idStr.trim().isEmpty()) {
                // 新建草稿
                String sqlIns = "INSERT INTO outbound_order(lab_id,apply_user_id,course_name,class_name,purpose,status) VALUES(?,?,?,?,?,-1)";
                orderId = DBUtils.UpdateAndGetKey(conn, sqlIns, user.getLab_id(), user.getId(), courseName, className,
                        purpose);
            } else {
                orderId = Integer.parseInt(idStr);
                // 只允许更新草稿
                Object st = DBUtils.runner().query(conn,
                        "SELECT status FROM outbound_order WHERE id=? AND apply_user_id=?",
                        new org.apache.commons.dbutils.handlers.ScalarHandler<>(), orderId, user.getId());
                if (st == null)
                    throw new RuntimeException("草稿不存在");
                int status = Integer.parseInt(st.toString());
                if (status != -1)
                    throw new RuntimeException("只能编辑草稿状态的申请");
                DBUtils.Update(conn, "UPDATE outbound_order SET course_name=?,class_name=?,purpose=? WHERE id=?",
                        courseName, className, purpose, orderId);
                DBUtils.Update(conn, "DELETE FROM outbound_item WHERE outbound_id=?", orderId);
            }
            // 保存明细
            if (itemsJson != null && !itemsJson.trim().isEmpty()) {
                List<OutboundItem> items = JSON.parseArray(itemsJson, OutboundItem.class);
                if (items != null) {
                    for (OutboundItem it : items) {
                        int shouldReturn = it.getShould_return() == null ? 0 : it.getShould_return();
                        DBUtils.Update(conn,
                                "INSERT INTO outbound_item(outbound_id,consumable_id,quantity,should_return,remark) VALUES(?,?,?,?,?)",
                                orderId, it.getConsumable_id(), it.getQuantity(), shouldReturn, it.getRemark());
                    }
                }
            }
            conn.commit();
            rd.setCode("200");
            rd.setMsg("草稿已保存");
            java.util.Map<String, Object> data = new HashMap<>();
            data.put("id", orderId);
            rd.setData(data);
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null)
                try {
                    conn.rollback();
                } catch (Exception ignored) {
                }
            rd.setCode("500");
            rd.setMsg("保存草稿失败：" + e.getMessage());
        } finally {
            if (conn != null)
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {
                }
            out.write(JSON.toJSONString(rd));
        }
    }

    /**
     * 撤销申请（待审核 status=0 → 撤销 status=-1 草稿，可重新编辑）
     */
    private void cancelApply(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
        if (idStr == null || idStr.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            int r = DBUtils.Update("UPDATE outbound_order SET status=-1 WHERE id=? AND apply_user_id=? AND status=0",
                    Integer.parseInt(idStr), user.getId());
            if (r > 0) {
                rd.setCode("200");
                rd.setMsg("已撤销，可重新编辑后提交");
            } else {
                rd.setCode("409");
                rd.setMsg("只能撤销「待审核」状态的申请");
            }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("撤销失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    /**
     * 下拉选择耗材（combobox）
     */
    private void consumableOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        try {
            // 只给 id/name/unit/is_dangerous
            String sql = "SELECT id, name, unit, is_dangerous FROM consumable ORDER BY id DESC";
            List<HashMap<String, Object>> list = new ArrayList<>();
            // 复用 QueryBeanList 映射到 HashMap 不方便，这里直接用 JSON 结构：用 QueryBeanList 到 Consumable
            // 也行
            List<com.entity.Consumable> cs = DBUtils.QueryBeanList(sql, com.entity.Consumable.class);
            for (com.entity.Consumable c : cs) {
                HashMap<String, Object> m = new HashMap<>();
                m.put("id", c.getId());
                m.put("text", c.getName() + "（" + c.getUnit() + "）"
                        + (c.getIs_dangerous() != null && c.getIs_dangerous() == 1 ? "【危】" : ""));
                m.put("name", c.getName());
                m.put("unit", c.getUnit());
                m.put("is_dangerous", c.getIs_dangerous());
                list.add(m);
            }
            out.write(JSON.toJSONString(list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        }
    }

    /**
     * 教师提交领用申请：插入 outbound_order + outbound_item（事务）
     *
     * 前端传参：
     * - course_name, class_name, purpose
     * - itemsJson: [{consumable_id, quantity, should_return, remark}]
     */
    private void createApply(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();

        SysUser user = getLoginUser(req);
        if (user == null) {
            rd.setCode("401");
            rd.setMsg("未登录");
            out.write(JSON.toJSONString(rd));
            return;
        }
        if (user.getLab_id() == null) {
            rd.setCode("400");
            rd.setMsg("当前账号未绑定实验室（sys_user.lab_id 为空），无法提交领用申请");
            out.write(JSON.toJSONString(rd));
            return;
        }

        String courseName = req.getParameter("course_name");
        String className = req.getParameter("class_name");
        String purpose = req.getParameter("purpose");
        String itemsJson = req.getParameter("itemsJson");
        String draftIdStr = req.getParameter("draft_id"); // 从草稿提交时传入

        if (itemsJson == null || itemsJson.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请添加领用明细");
            out.write(JSON.toJSONString(rd));
            return;
        }

        List<OutboundItem> items;
        try {
            items = JSON.parseArray(itemsJson, OutboundItem.class);
        } catch (Exception e) {
            rd.setCode("400");
            rd.setMsg("明细数据格式错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        if (items == null || items.isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请添加领用明细");
            out.write(JSON.toJSONString(rd));
            return;
        }

        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);

            int orderId;
            if (draftIdStr != null && !draftIdStr.trim().isEmpty()) {
                // 从草稿提交：更新状态为0，更新基本信息，清空旧明细
                orderId = Integer.parseInt(draftIdStr);
                Object st = DBUtils.runner().query(conn,
                        "SELECT status FROM outbound_order WHERE id=? AND apply_user_id=?",
                        new org.apache.commons.dbutils.handlers.ScalarHandler<>(), orderId, user.getId());
                if (st == null)
                    throw new RuntimeException("草稿不存在");
                if (Integer.parseInt(st.toString()) != -1)
                    throw new RuntimeException("只能提交草稿状态的申请");
                DBUtils.Update(conn,
                        "UPDATE outbound_order SET course_name=?,class_name=?,purpose=?,status=0 WHERE id=?",
                        courseName, className, purpose, orderId);
                DBUtils.Update(conn, "DELETE FROM outbound_item WHERE outbound_id=?", orderId);
            } else {
                String sqlOrder = "INSERT INTO outbound_order(lab_id, apply_user_id, course_name, class_name, purpose, status) "
                        +
                        "VALUES(?,?,?,?,?,0)";
                orderId = DBUtils.UpdateAndGetKey(conn, sqlOrder, user.getLab_id(), user.getId(), courseName, className,
                        purpose);
            }

            String sqlItem = "INSERT INTO outbound_item(outbound_id, consumable_id, quantity, should_return, remark) VALUES(?,?,?,?,?)";
            for (OutboundItem it : items) {
                if (it.getConsumable_id() == null || it.getQuantity() == null || it.getQuantity() <= 0) {
                    throw new RuntimeException("明细数量必须大于0");
                }
                int shouldReturn = (it.getShould_return() == null) ? 0 : it.getShould_return();
                DBUtils.Update(conn, sqlItem, orderId, it.getConsumable_id(), it.getQuantity(), shouldReturn,
                        it.getRemark());
            }

            conn.commit();
            rd.setCode("200");
            rd.setMsg("提交成功，等待审核");
            java.util.Map<String, Object> data = new HashMap<>();
            data.put("id", orderId);
            rd.setData(data);
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            rd.setCode("500");
            rd.setMsg("提交失败：" + e.getMessage());
        } finally {
            closeQuietly(conn);
            out.write(JSON.toJSONString(rd));
        }
    }

    private void listMine(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }

        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        String statusFilter = req.getParameter("status_filter"); // 可为空
        String keyword = req.getParameter("keyword"); // 申请单号搜索
        String dateFrom = req.getParameter("date_from");
        String dateTo = req.getParameter("date_to");

        StringBuilder where = new StringBuilder("WHERE o.apply_user_id=?");
        List<Object> params = new ArrayList<>();
        params.add(user.getId());

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            where.append(" AND o.status=?");
            params.add(Integer.parseInt(statusFilter));
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            try {
                int kid = Integer.parseInt(keyword.trim());
                where.append(" AND o.id=?");
                params.add(kid);
            } catch (Exception ignored) {
            }
        }
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            where.append(" AND DATE(o.create_time)>=?");
            params.add(dateFrom.trim());
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            where.append(" AND DATE(o.create_time)<=?");
            params.add(dateTo.trim());
        }

        HashMap<String, Object> map = new HashMap<>();
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            String sqlCount = "SELECT COUNT(*) FROM outbound_order o " + where;
            Object totalObj = DBUtils.runner().query(conn, sqlCount,
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), params.toArray());
            int total = totalObj == null ? 0 : Integer.parseInt(totalObj.toString());
            map.put("total", total);

            String sqlList = "SELECT o.*, u.real_name AS apply_user_name, l.lab_name AS lab_name, " +
                    "au.real_name AS audit_user_name, " +
                    "(SELECT COUNT(*) > 0 FROM outbound_item i2 " +
                    "JOIN consumable c2 ON i2.consumable_id=c2.id " +
                    "WHERE i2.outbound_id=o.id AND c2.is_dangerous=1) AS has_dangerous " +
                    "FROM outbound_order o LEFT JOIN sys_user u ON o.apply_user_id=u.id " +
                    "LEFT JOIN lab l ON o.lab_id=l.id " +
                    "LEFT JOIN sys_user au ON o.audit_user_id=au.id " +
                    where + " ORDER BY o.id DESC LIMIT ?, ?";
            List<Object> listParams = new ArrayList<>(params);
            listParams.add((pageIndex - 1) * pageSize);
            listParams.add(pageSize);
            List<java.util.Map<String, Object>> list = DBUtils.runner().query(
                    conn, sqlList,
                    new org.apache.commons.dbutils.handlers.MapListHandler(), listParams.toArray());
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
     * 实验室管理员查看本实验室待审核/待出库
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
        String statusParam = req.getParameter("status"); // 可空，空则不限
        String orderIdParam = req.getParameter("order_id"); // 可空，单号精确匹配（已去除#）
        String applicantParam = req.getParameter("applicant"); // 可空，申请人模糊匹配

        // 动态构建 WHERE 条件
        StringBuilder where = new StringBuilder("WHERE o.lab_id=?");
        List<Object> params = new ArrayList<>();
        params.add(user.getLab_id());

        if (statusParam != null && !statusParam.trim().isEmpty()) {
            where.append(" AND o.status=?");
            params.add(Integer.parseInt(statusParam.trim()));
        } else {
            // 无 status 参数时默认排除草稿(-1)和已出库(3)
            where.append(" AND o.status IN (0,1,2,4)");
        }

        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int oid = Integer.parseInt(orderIdParam.trim());
                where.append(" AND o.id=?");
                params.add(oid);
            } catch (NumberFormatException ignored) {
            }
        }

        if (applicantParam != null && !applicantParam.trim().isEmpty()) {
            where.append(" AND u.real_name LIKE ?");
            params.add("%" + applicantParam.trim() + "%");
        }

        HashMap<String, Object> map = new HashMap<>();
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();

            // COUNT
            String sqlCount = "SELECT COUNT(*) FROM outbound_order o " +
                    "LEFT JOIN sys_user u ON o.apply_user_id=u.id " + where;
            Object totalObj = DBUtils.runner().query(conn, sqlCount,
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), params.toArray());
            int total = totalObj == null ? 0 : Integer.parseInt(totalObj.toString());
            map.put("total", total);

            // LIST：新增 has_dangerous 子查询字段
            String sqlList = "SELECT o.*, u.real_name AS apply_user_name, " +
                    "  (SELECT COUNT(*) > 0 FROM outbound_item i2 " +
                    "   JOIN consumable c2 ON i2.consumable_id=c2.id " +
                    "   WHERE i2.outbound_id=o.id AND c2.is_dangerous=1) AS has_dangerous " +
                    "FROM outbound_order o " +
                    "LEFT JOIN sys_user u ON o.apply_user_id=u.id " +
                    where + " ORDER BY o.id DESC LIMIT ?, ?";

            List<Object> listParams = new ArrayList<>(params);
            listParams.add((pageIndex - 1) * pageSize);
            listParams.add(pageSize);

            List<java.util.Map<String, Object>> list = DBUtils.runner().query(
                    conn, sqlList,
                    new org.apache.commons.dbutils.handlers.MapListHandler(),
                    listParams.toArray());
            map.put("rows", list == null ? new ArrayList<>() : list);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 查询某单的明细
     */
    private void getItems(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String outboundId = req.getParameter("outbound_id");
        if (outboundId == null || outboundId.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        try {
            String sql = "SELECT i.*, c.name AS consumable_name, c.unit, c.is_dangerous " +
                    "FROM outbound_item i LEFT JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE i.outbound_id=? ORDER BY i.id";
            List<OutboundItem> list = DBUtils.QueryBeanList(sql, OutboundItem.class, Integer.parseInt(outboundId));
            out.write(JSON.toJSONString(list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        }
    }

    /**
     * 教师查看本人领用单明细（校验 outbound_order.apply_user_id）
     */
    private void getMyItems(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null) {
            out.write("[]");
            return;
        }
        String outboundId = req.getParameter("outbound_id");
        if (outboundId == null || outboundId.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        try {
            int oid = Integer.parseInt(outboundId);
            Object cnt = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM outbound_order WHERE id=? AND apply_user_id=?",
                    oid, user.getId());
            int n = cnt == null ? 0 : Integer.parseInt(cnt.toString());
            if (n <= 0) {
                out.write("[]");
                return;
            }
            String sql = "SELECT i.*, c.name AS consumable_name, c.unit, c.is_dangerous " +
                    "FROM outbound_item i LEFT JOIN consumable c ON i.consumable_id=c.id " +
                    "WHERE i.outbound_id=? ORDER BY i.id";
            List<OutboundItem> list = DBUtils.QueryBeanList(sql, OutboundItem.class, oid);
            out.write(JSON.toJSONString(list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        }
    }

    /**
     * 初审：0->1（通过）或 0->2（驳回）
     */
    private void audit1(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();

        SysUser user = getLoginUser(req);
        if (user == null) {
            rd.setCode("401");
            rd.setMsg("未登录");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String id = req.getParameter("id");
        String pass = req.getParameter("pass");
        String rejectReason = req.getParameter("reject_reason");
        if (id == null || pass == null) {
            rd.setCode("400");
            rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        int newStatus = "1".equals(pass) ? 1 : 2;

        if (newStatus == 2 && (rejectReason == null || rejectReason.trim().isEmpty())) {
            rd.setCode("400");
            rd.setMsg("驳回时必须填写驳回原因");
            out.write(JSON.toJSONString(rd));
            return;
        }

        try {
            String sql;
            if (newStatus == 2) {
                sql = "UPDATE outbound_order SET status=?, audit_user_id=?, audit_time=NOW(), reject_reason=? WHERE id=? AND status=0";
                int r = DBUtils.Update(sql, newStatus, user.getId(), rejectReason, Integer.parseInt(id));
                if (r > 0) {
                    rd.setCode("200");
                    rd.setMsg("已驳回");
                } else {
                    rd.setCode("409");
                    rd.setMsg("状态已变更，请刷新后重试");
                }
            } else {
                sql = "UPDATE outbound_order SET status=?, audit_user_id=?, audit_time=NOW() WHERE id=? AND status=0";
                int r = DBUtils.Update(sql, newStatus, user.getId(), Integer.parseInt(id));
                if (r > 0) {
                    rd.setCode("200");
                    rd.setMsg("初审通过");
                } else {
                    rd.setCode("409");
                    rd.setMsg("状态已变更，请刷新后重试");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("操作失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    /**
     * 二审：1->2（通过）或 1->2（驳回保持2也行，这里用2表示驳回/未通过，简化）
     * 为了演示五双复核：只允许对明细包含危险品的单做二审；非危险品单可跳过二审直接出库（状态1）。
     */
    private void audit2(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();

        SysUser user = getLoginUser(req);
        if (user == null) {
            rd.setCode("401");
            rd.setMsg("未登录");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String id = req.getParameter("id");
        String pass = req.getParameter("pass");
        String rejectReason = req.getParameter("reject_reason");
        if (id == null || pass == null) {
            rd.setCode("400");
            rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd));
            return;
        }

        if (!"1".equals(pass) && (rejectReason == null || rejectReason.trim().isEmpty())) {
            rd.setCode("400");
            rd.setMsg("驳回时必须填写驳回原因");
            out.write(JSON.toJSONString(rd));
            return;
        }

        // pass=1 通过，pass=0 驳回（简化为状态2）
        try {
            boolean hasDanger = hasDangerousItem(Integer.parseInt(id));
            if (!hasDanger) {
                rd.setCode("400");
                rd.setMsg("该领用单不包含危险品，无需二审");
                out.write(JSON.toJSONString(rd));
                return;
            }
            if (!"1".equals(pass)) {
                String sqlReject = "UPDATE outbound_order SET status=2, second_audit_user_id=?, second_audit_time=NOW(), reject_reason=? WHERE id=? AND status=1";
                int r = DBUtils.Update(sqlReject, user.getId(), rejectReason, Integer.parseInt(id));
                if (r > 0) {
                    rd.setCode("200");
                    rd.setMsg("二审未通过（已驳回）");
                } else {
                    rd.setCode("409");
                    rd.setMsg("状态已变更，请刷新后重试");
                }
                out.write(JSON.toJSONString(rd));
                return;
            }

            // 二审通过：status 更新为 4（二审通过），记录 second_audit_user_id 和 second_audit_time
            String sql = "UPDATE outbound_order SET status=4, second_audit_user_id=?, second_audit_time=NOW() WHERE id=? AND status=1";
            int r = DBUtils.Update(sql, user.getId(), Integer.parseInt(id));
            if (r > 0) {
                rd.setCode("200");
                rd.setMsg("危险品二审通过");
            } else {
                rd.setCode("409");
                rd.setMsg("状态已变更，请刷新后重试");
            }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("操作失败：" + e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    /**
     * 出库：扣减库存 stock.total_quantity，订单状态变更为 3
     * - 非危险品：status=1 即可出库
     * - 危险品：必须 second_audit_user_id 不为空才允许出库
     */
    private void doOutbound(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();

        SysUser user = getLoginUser(req);
        if (user == null) {
            rd.setCode("401");
            rd.setMsg("未登录");
            out.write(JSON.toJSONString(rd));
            return;
        }

        String id = req.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("参数错误");
            out.write(JSON.toJSONString(rd));
            return;
        }

        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);

            // 查单据
            OutboundOrder order = DBUtils.QueryBean(conn, "SELECT * FROM outbound_order WHERE id=?",
                    OutboundOrder.class, Integer.parseInt(id));
            if (order == null)
                throw new RuntimeException("单据不存在");

            boolean hasDanger = hasDangerousItem(conn, order.getId());
            int currentStatus = order.getStatus() == null ? -99 : order.getStatus();

            if (hasDanger) {
                // 危化品申请：必须 status=4（二审通过）才可出库
                if (currentStatus != 4) {
                    rd.setCode("409");
                    rd.setMsg("审核未完成，不可出库（危险品领用需完成二审）");
                    out.write(JSON.toJSONString(rd));
                    return;
                }
            } else {
                // 普通申请：status=1（初审通过）即可出库
                if (currentStatus != 1) {
                    rd.setCode("409");
                    rd.setMsg("审核未完成，不可出库");
                    out.write(JSON.toJSONString(rd));
                    return;
                }
            }

            // 查明细
            String sqlItems = "SELECT * FROM outbound_item WHERE outbound_id=?";
            List<OutboundItem> items = DBUtils.runner().query(conn, sqlItems, new BeanListHandler<>(OutboundItem.class),
                    order.getId());

            // 校验库存
            for (OutboundItem it : items) {
                Integer cid = it.getConsumable_id();
                Integer qty = it.getQuantity();
                Object qObj = DBUtils.runner().query(conn,
                        "SELECT total_quantity FROM stock WHERE lab_id=? AND consumable_id=?",
                        new org.apache.commons.dbutils.handlers.ScalarHandler<>(),
                        order.getLab_id(), cid);
                int stockQty = (qObj == null) ? 0 : Integer.parseInt(qObj.toString());
                if (stockQty < qty) {
                    throw new RuntimeException("库存不足（耗材ID=" + cid + "，库存=" + stockQty + "，申请=" + qty + "）");
                }
            }

            // 扣减库存（事务内）
            for (OutboundItem it : items) {
                DBUtils.Update(conn,
                        "UPDATE stock SET total_quantity=total_quantity-? WHERE lab_id=? AND consumable_id=?",
                        it.getQuantity(), order.getLab_id(), it.getConsumable_id());
            }

            // 更新单据状态
            DBUtils.Update(conn, "UPDATE outbound_order SET status=3 WHERE id=? AND status IN (1,4)", order.getId());

            conn.commit();
            rd.setCode("200");
            rd.setMsg("出库成功，库存已扣减");
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            rd.setCode("500");
            rd.setMsg("出库失败：" + e.getMessage());
        } finally {
            closeQuietly(conn);
            out.write(JSON.toJSONString(rd));
        }
    }

    /**
     * 实验室管理员直接出库登记（不走教师申请流程）
     * 前端传参：itemsJson=[{consumable_id, quantity, purpose}], purpose(汇总)
     * - 生成一条 outbound_order（status=3 已出库）
     * - 批量生成 outbound_item
     * - 批量扣减库存 stock.total_quantity
     */
    private void directOutbound(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        ResultData rd = new ResultData();

        SysUser user = getLoginUser(req);
        if (user == null) {
            rd.setCode("401");
            rd.setMsg("未登录");
            out.write(JSON.toJSONString(rd));
            return;
        }
        if (user.getLab_id() == null) {
            rd.setCode("400");
            rd.setMsg("当前账号未绑定实验室，无法进行出库登记");
            out.write(JSON.toJSONString(rd));
            return;
        }

        String itemsJson = req.getParameter("itemsJson");
        String purpose = req.getParameter("purpose");

        if (itemsJson == null || itemsJson.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请添加出库明细");
            out.write(JSON.toJSONString(rd));
            return;
        }

        List<java.util.Map> items;
        try {
            items = JSON.parseArray(itemsJson, java.util.Map.class);
        } catch (Exception e) {
            rd.setCode("400");
            rd.setMsg("明细数据格式错误");
            out.write(JSON.toJSONString(rd));
            return;
        }
        if (items == null || items.isEmpty()) {
            rd.setCode("400");
            rd.setMsg("请添加出库明细");
            out.write(JSON.toJSONString(rd));
            return;
        }

        // 前置校验：每行 consumable_id 和 quantity 必须合法
        for (int i = 0; i < items.size(); i++) {
            java.util.Map item = items.get(i);
            Object cid = item.get("consumable_id");
            Object qty = item.get("quantity");
            if (cid == null || cid.toString().trim().isEmpty()
                    || qty == null || qty.toString().trim().isEmpty()
                    || Integer.parseInt(qty.toString()) <= 0) {
                rd.setCode("400");
                rd.setMsg("第" + (i + 1) + "行耗材或数量不合法");
                out.write(JSON.toJSONString(rd));
                return;
            }
        }

        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            conn.setAutoCommit(false);

            // 新建一条已出库单据（status=3），申请人和审核人都记为当前实验室管理员
            String sqlOrder = "INSERT INTO outbound_order(lab_id, apply_user_id, course_name, class_name, purpose, status, "
                    +
                    "audit_user_id, audit_time) VALUES(?,?,?,?,?,3,?,NOW())";
            int orderId = DBUtils.UpdateAndGetKey(conn, sqlOrder,
                    user.getLab_id(), user.getId(),
                    null, null, purpose, user.getId());

            String sqlItem = "INSERT INTO outbound_item(outbound_id, consumable_id, quantity, should_return, remark) " +
                    "VALUES(?,?,?,?,?)";

            for (java.util.Map item : items) {
                int consumableId = Integer.parseInt(item.get("consumable_id").toString());
                int qty = Integer.parseInt(item.get("quantity").toString());
                String rowPurpose = item.get("purpose") != null ? item.get("purpose").toString() : "";

                // 校验单行库存
                Object qObj = DBUtils.runner().query(conn,
                        "SELECT total_quantity FROM stock WHERE lab_id=? AND consumable_id=?",
                        new org.apache.commons.dbutils.handlers.ScalarHandler<>(),
                        user.getLab_id(), consumableId);
                int stockQty = (qObj == null) ? 0 : Integer.parseInt(qObj.toString());
                if (stockQty < qty) {
                    // 取耗材名称用于提示
                    Object nameObj = DBUtils.runner().query(conn,
                            "SELECT name FROM consumable WHERE id=?",
                            new org.apache.commons.dbutils.handlers.ScalarHandler<>(), consumableId);
                    String cName = nameObj == null ? "id=" + consumableId : nameObj.toString();
                    throw new RuntimeException("「" + cName + "」库存不足（当前=" + stockQty + "，出库=" + qty + "）");
                }

                // 插入明细
                DBUtils.Update(conn, sqlItem, orderId, consumableId, qty, 0,
                        rowPurpose.isEmpty() ? "直接出库登记" : rowPurpose);

                // 扣减库存
                DBUtils.Update(conn,
                        "UPDATE stock SET total_quantity=total_quantity-? WHERE lab_id=? AND consumable_id=?",
                        qty, user.getLab_id(), consumableId);
            }

            conn.commit();
            rd.setCode("200");
            rd.setMsg("出库登记成功，共 " + items.size() + " 种耗材库存已扣减");
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            rd.setCode("500");
            rd.setMsg("出库登记失败：" + e.getMessage());
        } finally {
            closeQuietly(conn);
            out.write(JSON.toJSONString(rd));
        }
    }

    private boolean hasDangerousItem(int outboundId) throws Exception {
        String sql = "SELECT COUNT(*) FROM outbound_item i LEFT JOIN consumable c ON i.consumable_id=c.id " +
                "WHERE i.outbound_id=? AND c.is_dangerous=1";
        int cnt = Integer.parseInt(DBUtils.QueryScalar(sql, outboundId).toString());
        return cnt > 0;
    }

    private boolean hasDangerousItem(Connection conn, int outboundId) throws Exception {
        String sql = "SELECT COUNT(*) FROM outbound_item i LEFT JOIN consumable c ON i.consumable_id=c.id " +
                "WHERE i.outbound_id=? AND c.is_dangerous=1";
        Object obj = DBUtils.runner().query(conn, sql, new org.apache.commons.dbutils.handlers.ScalarHandler<>(),
                outboundId);
        int cnt = (obj == null) ? 0 : Integer.parseInt(obj.toString());
        return cnt > 0;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    /**
     * 查询出库记录（实验室管理员查看历史）
     */
    private void listOutboundRecords(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        SysUser user = getLoginUser(req);
        if (user == null || user.getLab_id() == null) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }

        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
        String orderIdParam = req.getParameter("order_id");
        String dateFrom = req.getParameter("date_from");
        String dateTo = req.getParameter("date_to");

        StringBuilder where = new StringBuilder("WHERE o.lab_id=? AND o.status=3");
        List<Object> params = new ArrayList<>();
        params.add(user.getLab_id());

        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int oid = Integer.parseInt(orderIdParam.trim());
                where.append(" AND o.id=?");
                params.add(oid);
            } catch (NumberFormatException ignored) {
            }
        }

        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            where.append(" AND DATE(o.create_time)>=?");
            params.add(dateFrom.trim());
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            where.append(" AND DATE(o.create_time)<=?");
            params.add(dateTo.trim());
        }

        HashMap<String, Object> map = new HashMap<>();
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();

            String sqlCount = "SELECT COUNT(*) FROM outbound_order o " + where;
            Object totalObj = DBUtils.runner().query(conn, sqlCount,
                    new org.apache.commons.dbutils.handlers.ScalarHandler<>(), params.toArray());
            int total = totalObj == null ? 0 : Integer.parseInt(totalObj.toString());
            map.put("total", total);

            String sqlList = "SELECT o.*, u.real_name AS apply_user_name, " +
                    "au.real_name AS audit_user_name, " +
                    "(SELECT COUNT(*) FROM outbound_item i2 WHERE i2.outbound_id=o.id) AS item_count " +
                    "FROM outbound_order o " +
                    "LEFT JOIN sys_user u ON o.apply_user_id=u.id " +
                    "LEFT JOIN sys_user au ON o.audit_user_id=au.id " +
                    where + " ORDER BY o.id DESC LIMIT ?, ?";

            List<Object> listParams = new ArrayList<>(params);
            listParams.add((pageIndex - 1) * pageSize);
            listParams.add(pageSize);

            List<java.util.Map<String, Object>> list = DBUtils.runner().query(
                    conn, sqlList,
                    new org.apache.commons.dbutils.handlers.MapListHandler(),
                    listParams.toArray());
            map.put("rows", list == null ? new ArrayList<>() : list);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            closeQuietly(conn);
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
