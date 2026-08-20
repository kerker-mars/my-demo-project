package com.servlet;

import com.alibaba.fastjson.JSON;
import com.entity.Employment;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.ResultData;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;


public class ServletEmploymentInfo extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");

        String action = req.getParameter("action") == null ? "" : req.getParameter("action");

        System.out.println("接收到就业信息请求，action: " + action);

        // 检查是否是搜索请求
        if ("getdglist".equals(action)) {
            // 检查是否有搜索参数
            String studentId = req.getParameter("studentId");
            String companyName = req.getParameter("companyName");
            String auditStatus = req.getParameter("auditStatus");

            if ((studentId != null && !studentId.isEmpty()) ||
                    (companyName != null && !companyName.isEmpty()) ||
                    (auditStatus != null && !auditStatus.isEmpty())) {
                // 有搜索参数，执行搜索
                System.out.println("检测到就业信息搜索参数，执行搜索功能");
                Search(req, resp);
            } else {
                // 没有搜索参数，执行普通列表查询
                System.out.println("无就业信息搜索参数，执行普通列表查询");
                getDgList(req, resp);
            }
        } else {
            // 其他action处理
            switch (action) {
                case "add":
                    Add(req, resp);
                    break;
                case "existsStudent":
                    ExistsStudent(req, resp);
                    break;
                case "delete":
                    Delete(req, resp);
                    break;
                case "getone":
                    getOne(req, resp);
                    break;
                case "update":
                    Update(req, resp);
                    break;
                case "search":
                    Search(req, resp);
                    break;
                default:
                    // 默认返回空数据
                    try {
                        resp.getWriter().write("{\"total\":0,\"rows\":[]}");
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    break;
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

    private void getDgList(HttpServletRequest req, HttpServletResponse resp) {
        try {
            int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
            int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));
            PrintWriter out = resp.getWriter();
            HashMap<String, Object> map = new HashMap<>();

            String sqlcount = "select count(*) from employment";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlcount).toString());
            map.put("total", total);

            String sqllist = "SELECT * FROM employment ORDER BY employmentId ASC LIMIT "
                    + (pageIndex - 1) * pageSize + ", " + pageSize;
            List<Employment> list = DBUtils.QueryBeanList(sqllist, Employment.class);

            map.put("rows", list);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void Add(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            PrintWriter out = resp.getWriter();

            // 获取所有参数
            int studentId = Integer.parseInt(req.getParameter("studentId"));
            int employmentType = Integer.parseInt(req.getParameter("employmentType"));
            String companyName = req.getParameter("companyName");
            String jobPosition = req.getParameter("jobPosition");
            Integer companyNature = req.getParameter("companyNature") == null || req.getParameter("companyNature").isEmpty()
                    ? null : Integer.parseInt(req.getParameter("companyNature"));
            String workCity = req.getParameter("workCity");
            String employmentTime = req.getParameter("employmentTime");
            String contactPhone = req.getParameter("contactPhone");
            String auditStatus = req.getParameter("auditStatus");
            String auditOpinion = req.getParameter("auditOpinion");
            Integer auditorId = req.getParameter("auditorId") == null || req.getParameter("auditorId").isEmpty()
                    ? null : Integer.parseInt(req.getParameter("auditorId"));
            String auditTime = req.getParameter("auditTime");

            String sql = "INSERT INTO employment (studentId, employmentType, companyName, jobPosition, " +
                    "companyNature, workCity, employmentTime, contactPhone, auditStatus, " +
                    "auditOpinion, auditorId, auditTime) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            if (DBUtils.Update(sql, studentId, employmentType, companyName, jobPosition,
                    companyNature, workCity, employmentTime, contactPhone, auditStatus,
                    auditOpinion, auditorId, auditTime) > 0) {
                out.write(JSON.toJSONString(new ResultData(String.valueOf(resp.getStatus()), "保存成功")));
            } else {
                out.write(JSON.toJSONString(new ResultData("501", "保存失败")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write(JSON.toJSONString(new ResultData("501", "数据有误，无法保存")));
        }
    }

    private void ExistsStudent(HttpServletRequest req, HttpServletResponse resp) {
        try {
            PrintWriter out = resp.getWriter();
            String studentId = req.getParameter("studentId");

            System.out.println("验证学生ID是否存在: " + studentId);

            if (studentId == null || studentId.trim().isEmpty()) {
                out.write("false");
                return;
            }

            // 首先检查学生是否存在
            String sqlCheckStudent = "SELECT COUNT(*) FROM student WHERE studentId = ?";
            Object studentCountObj = DBUtils.QueryScalar(sqlCheckStudent, Integer.parseInt(studentId.trim()));
            int studentCount = studentCountObj != null ? Integer.parseInt(studentCountObj.toString()) : 0;

            System.out.println("学生存在检查结果: " + studentCount);

            if (studentCount == 0) {
                out.write("false"); // 学生不存在
                return;
            }

            // 然后检查是否已存在就业信息
            String sql = "SELECT COUNT(*) FROM employment WHERE studentId = ?";
            Object employmentCountObj = DBUtils.QueryScalar(sql, Integer.parseInt(studentId.trim()));
            int employmentCount = employmentCountObj != null ? Integer.parseInt(employmentCountObj.toString()) : 0;

            System.out.println("就业信息存在检查结果: " + employmentCount);

            if (employmentCount >= 1) {
                out.write("false"); // 已存在就业信息
            } else {
                out.write("true"); // 可以添加
            }
        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.getWriter().write("false");
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }

    private void Delete(HttpServletRequest req, HttpServletResponse resp) {
        try {
            PrintWriter out = resp.getWriter();
            String employmentId = req.getParameter("employmentId");
            String sql = "delete from employment where employmentId=?";

            if (DBUtils.Update(sql, employmentId) > 0) {
                out.write(JSON.toJSONString(new ResultData("200", "删除成功")));
            } else {
                out.write(JSON.toJSONString(new ResultData("500", "删除失败")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void getOne(HttpServletRequest req, HttpServletResponse resp) {
        try {
            PrintWriter out = resp.getWriter();
            String employmentId = req.getParameter("employmentId");
            String sql = "select * from employment where employmentId=?";
            Employment employment = DBUtils.QueryBean(sql, Employment.class, employmentId);

            ResultData rd = new ResultData();
            if (employment != null) {
                rd.setCode(String.valueOf(resp.getStatus()));
                rd.setMsg("获取成功");
                rd.setData(employment);
                out.write(JSON.toJSONString(rd));
            } else {
                rd.setCode("501");
                rd.setMsg("获取失败");
                rd.setData(employment);
                out.write(JSON.toJSONString(rd));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void Update(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            PrintWriter out = resp.getWriter();

            // 获取所有参数
            int employmentId = Integer.parseInt(req.getParameter("employmentId"));
            int studentId = Integer.parseInt(req.getParameter("studentId"));
            int employmentType = Integer.parseInt(req.getParameter("employmentType"));
            String companyName = req.getParameter("companyName");
            String jobPosition = req.getParameter("jobPosition");
            Integer companyNature = req.getParameter("companyNature") == null || req.getParameter("companyNature").isEmpty()
                    ? null : Integer.parseInt(req.getParameter("companyNature"));
            String workCity = req.getParameter("workCity");
            String employmentTime = req.getParameter("employmentTime");
            String contactPhone = req.getParameter("contactPhone");
            String auditStatus = req.getParameter("auditStatus");
            String auditOpinion = req.getParameter("auditOpinion");
            Integer auditorId = req.getParameter("auditorId") == null || req.getParameter("auditorId").isEmpty()
                    ? null : Integer.parseInt(req.getParameter("auditorId"));
            String auditTime = req.getParameter("auditTime");

            String sql = "UPDATE employment SET studentId=?, employmentType=?, companyName=?, " +
                    "jobPosition=?, companyNature=?, workCity=?, employmentTime=?, " +
                    "contactPhone=?, auditStatus=?, auditOpinion=?, auditorId=?, auditTime=? " +
                    "WHERE employmentId=?";

            if (DBUtils.Update(sql, studentId, employmentType, companyName, jobPosition,
                    companyNature, workCity, employmentTime, contactPhone, auditStatus,
                    auditOpinion, auditorId, auditTime, employmentId) > 0) {
                out.write(JSON.toJSONString(new ResultData(String.valueOf(resp.getStatus()), "更新成功")));
            } else {
                out.write(JSON.toJSONString(new ResultData("501", "更新失败")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write(JSON.toJSONString(new ResultData("501", "数据有误，无法更新")));
        }
    }

    private void Search(HttpServletRequest req, HttpServletResponse resp) {
        try {
            int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
            int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));

            // 获取搜索条件
            String studentId = req.getParameter("studentId");
            String companyName = req.getParameter("companyName");
            String auditStatus = req.getParameter("auditStatus");

            System.out.println("接收到就业信息搜索参数: studentId=" + studentId +
                    ", companyName=" + companyName +
                    ", auditStatus=" + auditStatus);

            PrintWriter out = resp.getWriter();
            HashMap<String, Object> map = new HashMap<>();

            // 构建动态查询条件
            StringBuilder whereClause = new StringBuilder(" WHERE 1=1");
            List<Object> params = new ArrayList<>();

            if (studentId != null && !studentId.trim().isEmpty()) {
                whereClause.append(" AND studentId = ?");
                params.add(Integer.parseInt(studentId.trim()));
            }
            if (companyName != null && !companyName.trim().isEmpty()) {
                whereClause.append(" AND companyName LIKE ?");
                params.add("%" + companyName.trim() + "%");
            }
            if (auditStatus != null && !auditStatus.trim().isEmpty()) {
                whereClause.append(" AND auditStatus = ?");
                params.add(auditStatus.trim());
            }

            // 获取总记录数
            String sqlCount = "SELECT COUNT(*) FROM employment" + whereClause;

            System.out.println("就业信息计数SQL: " + sqlCount);
            System.out.println("就业信息计数参数: " + params);

            Object countResult = DBUtils.QueryScalar(sqlCount, params.toArray());
            int total = countResult != null ? Integer.parseInt(countResult.toString()) : 0;
            map.put("total", total);

            // 获取分页数据
            String sqlList = "SELECT * FROM employment" + whereClause +
                    " ORDER BY employmentId ASC LIMIT ?, ?";

            // 添加分页参数
            List<Object> allParams = new ArrayList<>(params);
            allParams.add((pageIndex - 1) * pageSize);
            allParams.add(pageSize);

            System.out.println("就业信息查询SQL: " + sqlList);
            System.out.println("就业信息查询参数: " + allParams);

            List<Employment> list = DBUtils.QueryBeanList(sqlList, Employment.class, allParams.toArray());
            map.put("rows", list);

            System.out.println("就业信息查询结果: " + list.size() + " 条记录");

            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.getWriter().write("{\"total\":0,\"rows\":[],\"error\":\"" + e.getMessage() + "\"}");
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }
}