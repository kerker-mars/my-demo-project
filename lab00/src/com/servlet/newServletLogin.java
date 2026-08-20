package com.servlet;

import com.alibaba.fastjson.JSON;
import com.dao.SysUserDao;
import com.entity.SysUser;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.ResultData;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

public class newServletLogin extends HttpServlet {
    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=utf-8");
        resp.setCharacterEncoding("utf-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "login":
                login(req, resp);
                break;
            case "logout":
                logout(req, resp);
                break;
            default:
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

    private void login(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=utf-8");
        PrintWriter out = resp.getWriter();
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        System.out.println(username + "       " + password);

        ResultData rd = new ResultData();
        try {
            // 直接查询用户，不限制状态，然后再检查状态
            SysUser user = (SysUser) DBUtils.QueryBean("SELECT * FROM sys_user WHERE username = ? AND password = ?", SysUser.class, username, password);

            if (user != null) {
                if (user.getStatus() != 1) {
                    rd.setCode("4042");
                    rd.setMsg("账号已停用");
                } else {
                    // 若未绑定实验室，则自动绑定一个默认实验室（用于演示领用/出库流程）
                    if (user.getLab_id() == null) {
                        Integer labId = (Integer) DBUtils.QueryScalar("SELECT id FROM lab ORDER BY id ASC LIMIT 1");
                        if (labId != null) {
                            DBUtils.Update("UPDATE sys_user SET lab_id=? WHERE id=?", labId, user.getId());
                            user.setLab_id(labId);
                        }
                    }

                    HttpSession session = req.getSession();
                    session.setAttribute("loginUser", user);
                    session.setAttribute("username", user.getUsername());
                    session.setAttribute("userId", user.getId());
                    session.setAttribute("roleId", user.getRole_id());
                    try {
                        Object roleNameObj = DBUtils.QueryScalar("SELECT role_name FROM sys_role WHERE id=?", user.getRole_id());
                        session.setAttribute("roleName", roleNameObj == null ? "" : roleNameObj.toString());
                    } catch (Exception ignored) {
                        session.setAttribute("roleName", "");
                    }

                    rd.setCode("200");
                    rd.setMsg("登录成功");
                }
            } else {
                rd.setCode("4041");
                rd.setMsg("用户名或密码有误");
            }
        } catch (Exception e) {
            e.printStackTrace();
            rd.setCode("500");
            rd.setMsg("服务器异常：" + e.getMessage());
        } finally {
            out.write(JSON.toJSONString(rd));
            out.flush();
        }
    }

    private void logout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.removeAttribute("username");
            session.invalidate();
        }
        resp.sendRedirect("login.jsp");
    }
}
