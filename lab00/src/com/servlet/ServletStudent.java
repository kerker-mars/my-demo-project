package com.servlet;

import com.entity.Class; // 导入已有的Class实体类
import com.alibaba.fastjson.JSON;
import com.entity.Student;
import com.jsj.isdt.utils.DBUtils;
import com.jsj.isdt.utils.ResultData;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ServletStudent extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=utf-8");
        req.setCharacterEncoding("utf-8");

        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        System.out.println("接收到请求，action: " + action);
        // 检查是否是搜索请求（datagrid的load方法会传递参数）
        if ("getdglist".equals(action)) {
            // 检查是否有搜索参数
            String studentName = req.getParameter("studentName");
            String studentNumber = req.getParameter("studentNumber");
            String className = req.getParameter("className");

            if ((studentName != null && !studentName.isEmpty()) ||
                    (studentNumber != null && !studentNumber.isEmpty()) ||
                    (className != null && !className.isEmpty())) {
                // 有搜索参数，执行搜索
                System.out.println("检测到搜索参数，执行搜索功能");
                searchStudent(req, resp);
            } else {
                // 没有搜索参数，执行普通列表查询
                System.out.println("无搜索参数，执行普通列表查询");
                getDgList(req, resp);
            }
        } else {
            // 其他action处理
            switch (action) {
                case "add":
                    addStudent(req, resp);
                    break;
                case "exists":
                    existsStudent(req, resp);
                    break;
                case "delete":
                    deleteStudent(req, resp);
                    break;
                case "getone":
                    getOneStudent(req, resp);
                    break;
                case "update":
                    updateStudent(req, resp);
                    break;
                case "search":
                    searchStudent(req, resp);
                    break;
                case "getClasses":
                    getClassList(req, resp);
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

            // 获取总记录数
            String sqlCount = "SELECT COUNT(*) FROM student";
            int total = Integer.parseInt(DBUtils.QueryScalar(sqlCount).toString());
            map.put("total", total);

            // 修改SQL查询：联表查询班级名称
            String sqlList = "SELECT s.*, c.className FROM student s " +
                    "LEFT JOIN class c ON s.classId = c.classId " +
                    "ORDER BY s.studentId ASC LIMIT " +
                    (pageIndex - 1) * pageSize + ", " + pageSize;

            List<Student> list = DBUtils.QueryBeanList(sqlList, Student.class);
            map.put("rows", list);
            out.write(JSON.toJSONString(map));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void addStudent(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            PrintWriter out = resp.getWriter();

            String studentNumber = req.getParameter("studentNumber");
            String studentName = req.getParameter("studentName");
            String gender = req.getParameter("gender");
            String phone = req.getParameter("phone");
            String email = req.getParameter("email");
            int classId = Integer.parseInt(req.getParameter("classId"));

            String sql = "INSERT INTO student (studentNumber, studentName, gender, phone, email, classId) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";

            if (DBUtils.Update(sql, studentNumber, studentName, gender, phone, email, classId) > 0) {
                out.write(JSON.toJSONString(new ResultData("200", "添加成功")));
            } else {
                out.write(JSON.toJSONString(new ResultData("501", "添加失败")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write(JSON.toJSONString(new ResultData("501", "数据有误，无法添加")));
        }
    }

    private void existsStudent(HttpServletRequest req, HttpServletResponse resp) {
        try {
            PrintWriter out = resp.getWriter();
            String studentNumber = req.getParameter("studentNumber");
            String sql = "SELECT COUNT(*) FROM student WHERE studentNumber = ?";

            int count = Integer.parseInt(DBUtils.QueryScalar(sql, studentNumber).toString());
            if (count == 1) {
                out.write("false");
            } else {
                out.write("true");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void deleteStudent(HttpServletRequest req, HttpServletResponse resp) {
        try {
            PrintWriter out = resp.getWriter();
            String studentId = req.getParameter("studentId");
            String sql = "DELETE FROM student WHERE studentId = ?";

            if (DBUtils.Update(sql, studentId) > 0) {
                out.write(JSON.toJSONString(new ResultData("200", "删除成功")));
            } else {
                out.write(JSON.toJSONString(new ResultData("500", "删除失败")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void getOneStudent(HttpServletRequest req, HttpServletResponse resp) {
        try {
            PrintWriter out = resp.getWriter();
            String studentId = req.getParameter("studentId");

            // 修改SQL查询：联表查询班级名称
            String sql = "SELECT s.*, c.className FROM student s " +
                    "LEFT JOIN class c ON s.classId = c.classId " +
                    "WHERE s.studentId = ?";

            Student student = DBUtils.QueryBean(sql, Student.class, studentId);
            ResultData rd = new ResultData();

            if (student != null) {
                rd.setCode("200");
                rd.setMsg("获取成功");
                rd.setData(student);
                out.write(JSON.toJSONString(rd));
            } else {
                rd.setCode("501");
                rd.setMsg("获取失败");
                out.write(JSON.toJSONString(rd));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void updateStudent(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            PrintWriter out = resp.getWriter();

            int studentId = Integer.parseInt(req.getParameter("studentId"));
            String studentNumber = req.getParameter("studentNumber");
            String studentName = req.getParameter("studentName");
            String gender = req.getParameter("gender");
            String phone = req.getParameter("phone");
            String email = req.getParameter("email");
            int classId = Integer.parseInt(req.getParameter("classId"));

            String sql = "UPDATE student SET studentNumber = ?, studentName = ?, gender = ?, " +
                    "phone = ?, email = ?, classId = ? WHERE studentId = ?";

            if (DBUtils.Update(sql, studentNumber, studentName, gender, phone, email, classId, studentId) > 0) {
                out.write(JSON.toJSONString(new ResultData("200", "更新成功")));
            } else {
                out.write(JSON.toJSONString(new ResultData("501", "更新失败")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write(JSON.toJSONString(new ResultData("501", "数据有误，无法更新")));
        }
    }

    private void searchStudent(HttpServletRequest req, HttpServletResponse resp) {
        try {
            int pageIndex = req.getParameter("page") == null ? 1 : Integer.parseInt(req.getParameter("page"));
            int pageSize = req.getParameter("rows") == null ? 10 : Integer.parseInt(req.getParameter("rows"));

            // 获取搜索条件
            String studentName = req.getParameter("studentName");
            String studentNumber = req.getParameter("studentNumber");
            String className = req.getParameter("className");

            System.out.println("接收到搜索参数: studentName=" + studentName +
                    ", studentNumber=" + studentNumber +
                    ", className=" + className);

            PrintWriter out = resp.getWriter();
            HashMap<String, Object> map = new HashMap<>();

            // 构建动态查询条件
            StringBuilder whereClause = new StringBuilder(" WHERE 1=1");
            List<Object> params = new ArrayList<>();

            if (studentName != null && !studentName.trim().isEmpty()) {
                whereClause.append(" AND s.studentName LIKE ?");
                params.add("%" + studentName.trim() + "%");
            }
            if (studentNumber != null && !studentNumber.trim().isEmpty()) {
                whereClause.append(" AND s.studentNumber LIKE ?");
                params.add("%" + studentNumber.trim() + "%");
            }
            if (className != null && !className.trim().isEmpty()) {
                whereClause.append(" AND c.className LIKE ?");
                params.add("%" + className.trim() + "%");
            }

            // 获取总记录数
            String sqlCount = "SELECT COUNT(*) FROM student s " +
                    "LEFT JOIN class c ON s.classId = c.classId" + whereClause;

            System.out.println("计数SQL: " + sqlCount);
            System.out.println("计数参数: " + params);

            Object countResult = DBUtils.QueryScalar(sqlCount, params.toArray());
            int total = countResult != null ? Integer.parseInt(countResult.toString()) : 0;
            map.put("total", total);

            // 获取分页数据
            String sqlList = "SELECT s.*, c.className FROM student s " +
                    "LEFT JOIN class c ON s.classId = c.classId" + whereClause +
                    " ORDER BY s.studentId ASC LIMIT ?, ?";

            // 添加分页参数
            List<Object> allParams = new ArrayList<>(params);
            allParams.add((pageIndex - 1) * pageSize);
            allParams.add(pageSize);

            System.out.println("查询SQL: " + sqlList);
            System.out.println("查询参数: " + allParams);

            List<Student> list = DBUtils.QueryBeanList(sqlList, Student.class, allParams.toArray());
            map.put("rows", list);

            System.out.println("查询结果: " + list.size() + " 条记录");

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

    private void getClassList(HttpServletRequest req, HttpServletResponse resp) {
        try {
            PrintWriter out = resp.getWriter();
            String sql = "SELECT classId, className FROM class ORDER BY classId";

            // 使用现有的Class实体类和QueryBeanList方法
            List<Class> classList = DBUtils.QueryBeanList(sql, Class.class);
            out.write(JSON.toJSONString(classList));
        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.getWriter().write("[]");
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }
}