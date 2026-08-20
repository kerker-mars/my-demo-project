package com.servlet;

import com.alibaba.fastjson.JSON;
import com.entity.Consumable;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.ResultData;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 耗材信息维护（consumable）
 */
public class ServletConsumable extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");

        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        // 获取耗材列表
        if ("getdglist".equals(action)) {
            // datagrid load() 会带查询参数，统一走列表接口
            getDgList(req, resp);
            return;
        }
        switch (action) {
            case "add":
                add(req, resp);
                break;
            case "update":
                update(req, resp);
                break;
            case "delete":
                delete(req, resp);
                break;
            case "getone":
                getOne(req, resp);
                break;
            case "exists":
                exists(req, resp);
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

    private void getDgList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        HashMap<String, Object> map = new HashMap<>();

        int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
        int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));

        String name = req.getParameter("name");
        String category = req.getParameter("category");
        String isDangerous = req.getParameter("is_dangerous");
        String returnable = req.getParameter("returnable");

        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (name != null && !name.trim().isEmpty()) {
            where.append(" AND name LIKE ? ");
            params.add("%" + name.trim() + "%");
        }
        if (category != null && !category.trim().isEmpty()) {
            where.append(" AND category LIKE ? ");
            params.add("%" + category.trim() + "%");
        }
        if (isDangerous != null && !isDangerous.trim().isEmpty()) {
            where.append(" AND is_dangerous = ? ");
            params.add(Integer.parseInt(isDangerous.trim()));
        }
        if (returnable != null && !returnable.trim().isEmpty()) {
            where.append(" AND returnable = ? ");
            params.add(Integer.parseInt(returnable.trim()));
        }

        try {
            String sqlCount = "SELECT COUNT(*) FROM consumable " + where;
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount, params.toArray(new Object[0])).toString());
            map.put("total", total);

            String sqlList = "SELECT * FROM consumable " + where + " ORDER BY id DESC LIMIT ?, ?";
            List<Object> allParams = new ArrayList<>(params);
            allParams.add((pageIndex - 1) * pageSize);
            allParams.add(pageSize);
            List<Consumable> list = DBUtils.QueryBeanList(sqlList, Consumable.class, allParams.toArray(new Object[0]));
            map.put("rows", list);

            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    // 添加耗材
    private void add(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        try {
            String name = req.getParameter("name");
            String category = req.getParameter("category");
            String spec = req.getParameter("spec");
            String unit = req.getParameter("unit");
            int isDangerous = Integer.parseInt(req.getParameter("is_dangerous"));
            String storageRequire = req.getParameter("storage_require");
            String validity = req.getParameter("validity_period");
            Integer validityPeriod = (validity == null || validity.trim().isEmpty()) ? null
                    : Integer.parseInt(validity.trim());
            String remark = req.getParameter("remark");

            String sql = "INSERT INTO consumable(name, category, spec, unit, is_dangerous, storage_require, validity_period, remark, returnable) "
                    +
                    "VALUES(?,?,?,?,?,?,?,?,?)";
            String returnableStr = req.getParameter("returnable");
            int returnable = (returnableStr == null || returnableStr.trim().isEmpty()) ? 0
                    : Integer.parseInt(returnableStr.trim());
            int r = DBUtils.Update(sql, name, category, spec, unit, isDangerous, storageRequire, validityPeriod, remark,
                    returnable);
            if (r > 0)
                out.write(JSON.toJSONString(new ResultData("200", "添加成功")));
            else
                out.write(JSON.toJSONString(new ResultData("501", "添加失败")));
        } catch (Exception e) {
            e.printStackTrace();
            out.write(JSON.toJSONString(new ResultData("500", "服务器异常：" + e.getMessage())));
        }
    }
    // 更新耗材
    private void update(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            String name = req.getParameter("name");
            String category = req.getParameter("category");
            String spec = req.getParameter("spec");
            String unit = req.getParameter("unit");
            int isDangerous = Integer.parseInt(req.getParameter("is_dangerous"));
            String storageRequire = req.getParameter("storage_require");
            String validity = req.getParameter("validity_period");
            Integer validityPeriod = (validity == null || validity.trim().isEmpty()) ? null
                    : Integer.parseInt(validity.trim());
            String remark = req.getParameter("remark");
            String returnableStr = req.getParameter("returnable");
            int returnable = (returnableStr == null || returnableStr.trim().isEmpty()) ? 0
                    : Integer.parseInt(returnableStr.trim());

            String sql = "UPDATE consumable SET name=?, category=?, spec=?, unit=?, is_dangerous=?, storage_require=?, validity_period=?, remark=?, returnable=? WHERE id=?";
            int r = DBUtils.Update(sql, name, category, spec, unit, isDangerous, storageRequire, validityPeriod, remark,
                    returnable, id);
            if (r > 0)
                out.write(JSON.toJSONString(new ResultData("200", "更新成功")));
            else
                out.write(JSON.toJSONString(new ResultData("501", "更新失败")));
        } catch (Exception e) {
            e.printStackTrace();
            out.write(JSON.toJSONString(new ResultData("500", "服务器异常：" + e.getMessage())));
        }
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        try {
            String id = req.getParameter("id");
            String sql = "DELETE FROM consumable WHERE id=?";
            int r = DBUtils.Update(sql, id);
            if (r > 0)
                out.write(JSON.toJSONString(new ResultData("200", "删除成功")));
            else
                out.write(JSON.toJSONString(new ResultData("500", "删除失败")));
        } catch (Exception e) {
            e.printStackTrace();
            out.write(JSON.toJSONString(new ResultData("500", "服务器异常：" + e.getMessage())));
        }
    }

    private void getOne(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        try {
            String id = req.getParameter("id");
            Consumable c = DBUtils.QueryBean("SELECT * FROM consumable WHERE id=?", Consumable.class, id);
            ResultData rd = new ResultData();
            if (c != null) {
                rd.setCode("200");
                rd.setMsg("获取成功");
                rd.setData(c);
            } else {
                rd.setCode("404");
                rd.setMsg("记录不存在");
            }
            out.write(JSON.toJSONString(rd));
        } catch (Exception e) {
            e.printStackTrace();
            out.write(JSON.toJSONString(new ResultData("500", "服务器异常：" + e.getMessage())));
        }
    }

    private void exists(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        try {
            String name = req.getParameter("name");
            String id = req.getParameter("id");

            String sql = "SELECT COUNT(*) FROM consumable WHERE name = ? ";
            List<Object> params = new ArrayList<>();
            params.add(name);
            if (id != null && !id.trim().isEmpty()) {
                sql += " AND id <> ? ";
                params.add(Integer.parseInt(id));
            }
            int count = Integer.parseInt(DBUtils.QueryScalar(sql, params.toArray(new Object[0])).toString());
            // easyui remote: true 表示可用，false 表示已存在
            out.write(count > 0 ? "false" : "true");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("true");
        }
    }
}
