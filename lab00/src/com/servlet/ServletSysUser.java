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
 * 系统管理员：用户管理（sys_user）
 */
public class ServletSysUser extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "list":
                list(req, resp);
                break;
            case "save":
                save(req, resp);
                break;
            case "update":
                update(req, resp);
                break;
            case "updateStatus":
                updateStatus(req, resp);
                break;
            case "disable":
                disable(req, resp);
                break;
            case "batchEnable":
                batchEnable(req, resp);
                break;
            case "batchDisable":
                batchDisable(req, resp);
                break;
            case "export":
                export(req, resp);
                break;
            case "labOptions":
                labOptions(req, resp);
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

    private boolean isSystemAdmin(SysUser user) {
        try {
            if (user == null || user.getRole_id() == null)
                return false;
            Object roleNameObj = DBUtils.QueryScalar("SELECT role_name FROM sys_role WHERE id=?", user.getRole_id());
            if (roleNameObj == null)
                return false;
            String roleName = roleNameObj.toString();
            return roleName.contains("系统管理员");
        } catch (Exception ignored) {
            return false;
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        if (!isSystemAdmin(getLoginUser(req))) {
            out.write("{\"total\":0,\"rows\":[]}");
            return;
        }
        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));

        String realName = req.getParameter("real_name");
        String roleId = req.getParameter("role_id");
        String status = req.getParameter("status");

        StringBuilder whereSql = new StringBuilder(" WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (realName != null && !realName.trim().isEmpty()) {
            whereSql.append(" AND u.real_name LIKE ?");
            params.add("%" + realName.trim() + "%");
        }
        if (roleId != null && !roleId.trim().isEmpty()) {
            whereSql.append(" AND u.role_id = ?");
            params.add(Integer.parseInt(roleId));
        }
        if (status != null && !status.trim().isEmpty()) {
            whereSql.append(" AND u.status = ?");
            params.add(Integer.parseInt(status));
        }

        Connection conn = null;
        try {
            String countSql = "SELECT COUNT(*) FROM sys_user u" + whereSql.toString();
            int total = Integer.parseInt(DBUtils.QueryScalar(countSql, params.toArray()).toString());
            Map<String, Object> map = new HashMap<>();
            map.put("total", total);

            String sql = "SELECT u.id, u.username, u.real_name, u.role_id, u.lab_id, u.phone, u.email, u.status, u.create_time, "
                    +
                    "r.role_name, l.lab_name "
                    +
                    "FROM sys_user u "
                    +
                    "LEFT JOIN sys_role r ON u.role_id=r.id "
                    +
                    "LEFT JOIN lab l ON u.lab_id=l.id "
                    +
                    whereSql.toString()
                    +
                    " ORDER BY u.id ASC LIMIT ?, ?";
            params.add((pageIndex - 1) * pageSize);
            params.add(pageSize);

            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(conn, sql, new MapListHandler(), params.toArray());
            map.put("rows", rows == null ? new ArrayList<>() : rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            closeConn(conn);
        }
    }

    private void save(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        if (!isSystemAdmin(getLoginUser(req))) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String realName = req.getParameter("real_name");
        String roleId = req.getParameter("role_id");
        String labId = req.getParameter("lab_id");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()
                || realName == null || realName.trim().isEmpty() || roleId == null) {
            rd.setCode("400");
            rd.setMsg("账号、密码、姓名、角色为必填");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            Object exists = DBUtils.QueryScalar("SELECT COUNT(*) FROM sys_user WHERE username=?", username.trim());
            if (exists != null && Integer.parseInt(exists.toString()) > 0) {
                rd.setCode("400");
                rd.setMsg("登录账号已存在");
                out.write(JSON.toJSONString(rd));
                return;
            }
            Integer lab = (labId == null || labId.trim().isEmpty()) ? null : Integer.parseInt(labId);
            String sql = "INSERT INTO sys_user (username, password, real_name, role_id, lab_id, phone, email, status) VALUES (?,?,?,?,?,?,?,1)";
            DBUtils.Update(sql, username.trim(), password, realName.trim(), Integer.parseInt(roleId),
                    lab, phone, email);
            rd.setCode("200");
            rd.setMsg("新增成功");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    private void update(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        if (!isSystemAdmin(getLoginUser(req))) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String id = req.getParameter("id");
        String password = req.getParameter("password");
        String realName = req.getParameter("real_name");
        String roleId = req.getParameter("role_id");
        String labId = req.getParameter("lab_id");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String status = req.getParameter("status");
        if (id == null || realName == null || realName.trim().isEmpty() || roleId == null) {
            rd.setCode("400");
            rd.setMsg("参数不完整");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            Integer userId = Integer.parseInt(id);

            String currentUsername = (String) DBUtils.QueryScalar("SELECT username FROM sys_user WHERE id=?", userId);
            if (currentUsername != null && currentUsername.equals("admin")) {
                if (roleId != null && !roleId.isEmpty()) {
                    Integer newRoleId = Integer.parseInt(roleId);
                    String newRoleName = (String) DBUtils.QueryScalar("SELECT role_name FROM sys_role WHERE id=?",
                            newRoleId);
                    if (newRoleName != null && !newRoleName.contains("系统管理员")) {
                        rd.setCode("400");
                        rd.setMsg("不能修改系统管理员账号的角色");
                        out.write(JSON.toJSONString(rd));
                        return;
                    }
                }
            }

            Integer lab = (labId == null || labId.trim().isEmpty()) ? null : Integer.parseInt(labId);
            if (password != null && !password.trim().isEmpty()) {
                String sql = "UPDATE sys_user SET password=?, real_name=?, role_id=?, lab_id=?, phone=?, email=?, status=? WHERE id=?";
                DBUtils.Update(sql, password, realName.trim(), Integer.parseInt(roleId), lab, phone, email,
                        Integer.parseInt(status == null ? "1" : status), userId);
            } else {
                String sql = "UPDATE sys_user SET real_name=?, role_id=?, lab_id=?, phone=?, email=?, status=? WHERE id=?";
                DBUtils.Update(sql, realName.trim(), Integer.parseInt(roleId), lab, phone, email,
                        Integer.parseInt(status == null ? "1" : status), userId);
            }
            rd.setCode("200");
            rd.setMsg("保存成功");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    private void updateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser me = getLoginUser(req);
        if (!isSystemAdmin(me)) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String id = req.getParameter("id");
        String status = req.getParameter("status");
        if (id == null || status == null) {
            rd.setCode("400");
            rd.setMsg("缺少参数");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            Integer userId = Integer.parseInt(id);

            String currentUsername = (String) DBUtils.QueryScalar("SELECT username FROM sys_user WHERE id=?", userId);
            if (currentUsername != null && currentUsername.equals("admin")) {
                rd.setCode("400");
                rd.setMsg("不能停用系统管理员账号");
                out.write(JSON.toJSONString(rd));
                return;
            }

            if (me.getId() != null && me.getId().toString().equals(id)) {
                rd.setCode("400");
                rd.setMsg("不能修改当前登录账号的状态");
                out.write(JSON.toJSONString(rd));
                return;
            }
            DBUtils.Update("UPDATE sys_user SET status=? WHERE id=?", Integer.parseInt(status), userId);
            rd.setCode("200");
            rd.setMsg(Integer.parseInt(status) == 1 ? "已启用" : "已停用");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    private void labOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        if (!isSystemAdmin(getLoginUser(req))) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(conn,
                    "SELECT id, lab_name AS text FROM lab ORDER BY id",
                    new MapListHandler());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            closeConn(conn);
        }
    }

    private void disable(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser me = getLoginUser(req);
        if (!isSystemAdmin(me)) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String id = req.getParameter("id");
        if (id == null) {
            rd.setCode("400");
            rd.setMsg("缺少id");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            if (me.getId() != null && me.getId().toString().equals(id)) {
                rd.setCode("400");
                rd.setMsg("不能停用当前登录账号");
                out.write(JSON.toJSONString(rd));
                return;
            }
            DBUtils.Update("UPDATE sys_user SET status=0 WHERE id=?", Integer.parseInt(id));
            rd.setCode("200");
            rd.setMsg("已停用");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    private void batchEnable(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser me = getLoginUser(req);
        if (!isSystemAdmin(me)) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String ids = req.getParameter("ids");
        if (ids == null || ids.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("缺少ids参数");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            String[] idArray = ids.split(",");
            for (String id : idArray) {
                DBUtils.Update("UPDATE sys_user SET status=1 WHERE id=?", Integer.parseInt(id));
            }
            rd.setCode("200");
            rd.setMsg("批量启用成功");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    private void batchDisable(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        resp.setContentType("application/json;charset=utf-8");
        ResultData rd = new ResultData();
        SysUser me = getLoginUser(req);
        if (!isSystemAdmin(me)) {
            rd.setCode("403");
            rd.setMsg("无权限");
            out.write(JSON.toJSONString(rd));
            return;
        }
        String ids = req.getParameter("ids");
        if (ids == null || ids.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("缺少ids参数");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            String[] idArray = ids.split(",");
            for (String id : idArray) {
                if (me.getId() != null && me.getId().toString().equals(id)) {
                    rd.setCode("400");
                    rd.setMsg("不能停用当前登录账号");
                    out.write(JSON.toJSONString(rd));
                    return;
                }
                String currentUsername = (String) DBUtils.QueryScalar("SELECT username FROM sys_user WHERE id=?", Integer.parseInt(id));
                if (currentUsername != null && currentUsername.equals("admin")) {
                    rd.setCode("400");
                    rd.setMsg("不能停用系统管理员账号");
                    out.write(JSON.toJSONString(rd));
                    return;
                }
                DBUtils.Update("UPDATE sys_user SET status=0 WHERE id=?", Integer.parseInt(id));
            }
            rd.setCode("200");
            rd.setMsg("批量停用成功");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    private void export(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        SysUser me = getLoginUser(req);
        if (!isSystemAdmin(me)) {
            resp.getWriter().write("无权限");
            return;
        }
        String ids = req.getParameter("ids");
        if (ids == null || ids.trim().isEmpty()) {
            resp.getWriter().write("缺少ids参数");
            return;
        }
        try {
            // 设置响应头，告诉浏览器这是一个CSV文件
            resp.setContentType("text/csv;charset=utf-8");
            resp.setHeader("Content-Disposition", "attachment;filename=users.csv");

            PrintWriter out = resp.getWriter();
            // 写入CSV表头
            out.println("ID,账号,姓名,角色,实验室,电话,邮箱,状态,创建时间");

            // 查询用户信息
            Connection conn = DruidUtils.getConnection();
            String[] idArray = ids.split(",");
            for (String id : idArray) {
                String sql = "SELECT u.id, u.username, u.real_name, r.role_name, l.lab_name, u.phone, u.email, CASE u.status WHEN 1 THEN '启用' ELSE '停用' END as status, u.create_time FROM sys_user u LEFT JOIN sys_role r ON u.role_id=r.id LEFT JOIN lab l ON u.lab_id=l.id WHERE u.id=?";
                List<Map<String, Object>> rows = DBUtils.runner().query(conn, sql, new MapListHandler(),
                        Integer.parseInt(id));
                if (rows != null && !rows.isEmpty()) {
                    Map<String, Object> row = rows.get(0);
                    out.println(row.get("id") + "," +
                            row.get("username") + "," +
                            row.get("real_name") + "," +
                            row.get("role_name") + "," +
                            (row.get("lab_name") == null ? "" : row.get("lab_name")) + "," +
                            (row.get("phone") == null ? "" : row.get("phone")) + "," +
                            (row.get("email") == null ? "" : row.get("email")) + "," +
                            row.get("status") + "," +
                            row.get("create_time"));
                }
            }
            closeConn(conn);
            out.flush();
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("导出失败：" + e.getMessage());
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
