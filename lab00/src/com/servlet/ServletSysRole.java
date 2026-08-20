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
 * 系统管理员：角色维护（sys_role）——「角色权限配置」基础版（角色名称与说明）
 */
public class ServletSysRole extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "list":
                list(req, resp);
                break;
            case "listAll":
                listAll(req, resp);
                break;
            case "save":
                save(req, resp);
                break;
            case "update":
                update(req, resp);
                break;
            case "delete":
                delete(req, resp);
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

    private boolean isSystemAdmin(SysUser user) {
        try {
            if (user == null || user.getRole_id() == null) return false;
            Object roleNameObj = DBUtils.QueryScalar("SELECT role_name FROM sys_role WHERE id=?", user.getRole_id());
            if (roleNameObj == null) return false;
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
        Connection conn = null;
        try {
            int total = Integer.parseInt(DBUtils.QueryScalar("SELECT COUNT(*) FROM sys_role").toString());
            Map<String, Object> map = new HashMap<>();
            map.put("total", total);
            String sql = "SELECT r.id, r.role_name, r.description, " +
                    "(SELECT COUNT(*) FROM sys_user u WHERE u.role_id=r.id) AS user_count " +
                    "FROM sys_role r ORDER BY r.id ASC LIMIT ?, ?";
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(conn, sql, new MapListHandler(),
                    (pageIndex - 1) * pageSize, pageSize);
            map.put("rows", rows == null ? new ArrayList<>() : rows);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            if (conn != null) {
                try {
                    DruidUtils.close(null, null, conn);
                } catch (Exception ignored) {
                }
            }
        }
    }

    /** 下拉用：全部角色 */
    private void listAll(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        if (!isSystemAdmin(getLoginUser(req))) {
            out.write("[]");
            return;
        }
        Connection conn = null;
        try {
            conn = DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(conn,
                    "SELECT id, role_name AS text, role_name, description FROM sys_role ORDER BY id",
                    new MapListHandler());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            if (conn != null) {
                try {
                    DruidUtils.close(null, null, conn);
                } catch (Exception ignored) {
                }
            }
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
        String name = req.getParameter("role_name");
        String desc = req.getParameter("description");
        if (name == null || name.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("角色名称不能为空");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            Object c = DBUtils.QueryScalar("SELECT COUNT(*) FROM sys_role WHERE role_name=?", name.trim());
            if (c != null && Integer.parseInt(c.toString()) > 0) {
                rd.setCode("400");
                rd.setMsg("角色名称已存在");
                out.write(JSON.toJSONString(rd));
                return;
            }
            DBUtils.Update("INSERT INTO sys_role (role_name, description) VALUES (?,?)", name.trim(), desc);
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
        String name = req.getParameter("role_name");
        String desc = req.getParameter("description");
        if (id == null || name == null || name.trim().isEmpty()) {
            rd.setCode("400");
            rd.setMsg("参数不完整");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            Object c = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM sys_role WHERE role_name=? AND id<>?",
                    name.trim(), Integer.parseInt(id));
            if (c != null && Integer.parseInt(c.toString()) > 0) {
                rd.setCode("400");
                rd.setMsg("角色名称与其他记录重复");
                out.write(JSON.toJSONString(rd));
                return;
            }
            DBUtils.Update("UPDATE sys_role SET role_name=?, description=? WHERE id=?",
                    name.trim(), desc, Integer.parseInt(id));
            rd.setCode("200");
            rd.setMsg("保存成功");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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
        if (id == null) {
            rd.setCode("400");
            rd.setMsg("缺少id");
            out.write(JSON.toJSONString(rd));
            return;
        }
        try {
            Object c = DBUtils.QueryScalar("SELECT COUNT(*) FROM sys_user WHERE role_id=?", Integer.parseInt(id));
            if (c != null && Integer.parseInt(c.toString()) > 0) {
                rd.setCode("400");
                rd.setMsg("该角色下仍有用户，无法删除");
                out.write(JSON.toJSONString(rd));
                return;
            }
            DBUtils.Update("DELETE FROM sys_role WHERE id=?", Integer.parseInt(id));
            rd.setCode("200");
            rd.setMsg("已删除");
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg(e.getMessage());
        }
        out.write(JSON.toJSONString(rd));
    }
}
