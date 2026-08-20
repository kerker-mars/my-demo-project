package com.servlet;

import com.alibaba.fastjson.JSON;
import com.jsj.isdt.utils.DBUtils;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

public class ReportServlet extends HttpServlet {
    // 报表统计
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=utf-8");
        req.setCharacterEncoding("utf-8");
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        switch (action) {
            case "stockCategory":
                stockCategory(req, resp);
                break;
            case "outboundTrend":
                outboundTrend(req, resp);
                break;
            case "stockDanger":
                stockDanger(req, resp);
                break;
            case "outboundDangerTrend":
                outboundDangerTrend(req, resp);
                break;
            case "coreIndicators":
                coreIndicators(req, resp);
                break;
            case "dangerTodo":
                dangerTodo(req, resp);
                break;
            case "stockSummary":
                stockSummary(req, resp);
                break;
            case "healthScore":
                healthScore(req, resp);
                break;
            case "overdueApprovals":
                overdueApprovals(req, resp);
                break;
            case "outboundStatusDist":
                outboundStatusDist(req, resp);
                break;
            case "outboundList":
                outboundList(req, resp);
                break;
            case "consumptionRank":
                consumptionRank(req, resp);
                break;
            case "labDashboard":
                labDashboard(req, resp);
                break;
            case "noticeList":
                noticeList(req, resp);
                break;
            case "noticeSave":
                noticeSave(req, resp);
                break;
            case "teacherDashboard":
                teacherDashboard(req, resp);
                break;
            case "replenishmentWarning":
                replenishmentWarning(req, resp);
                break;
            case "dangerComplianceWarning":
                dangerComplianceWarning(req, resp);
                break;
            case "listLiveStock":
                listLiveStock(req, resp);
                break;
            case "getTraceability":
                getTraceability(req, resp);
                break;
            case "purchaseScrapTrend":
                purchaseScrapTrend(req, resp);
                break;
            case "highFrequencyConsumables":
                highFrequencyConsumables(req, resp);
                break;
            case "dangerStockMonitor":
                dangerStockMonitor(req, resp);
                break;
            default:
                resp.getWriter().write("[]");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doGet(req, resp);
    }

    /**
     * 库存结构统计：按类别+是否危险品汇总当前库存价值（按入库单价计算）
     * 返回：嵌套环形图数据 {inner: [{name:'资产总值', value: xxx}], outer: [{name:'试剂(危险)',
     * value: xxx}, ...]}
     */
    private void stockCategory(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String sql = "SELECT c.category, c.is_dangerous, " +
                "       SUM(s.total_quantity * COALESCE(i.unit_price, 0)) AS total_value " +
                "FROM stock s " +
                "LEFT JOIN consumable c ON s.consumable_id = c.id " +
                "LEFT JOIN (" +
                "    SELECT consumable_id, MAX(unit_price) AS unit_price " +
                "    FROM inbound_item " +
                "    GROUP BY consumable_id" +
                ") i ON s.consumable_id = i.consumable_id " +
                "GROUP BY c.category, c.is_dangerous " +
                "ORDER BY total_value DESC";
        try {
            List<Map<String, Object>> outerList = new ArrayList<>();
            double totalValue = 0.0;

            // 查询库存类别价值
            List<Map<String, Object>> rows = DBUtils.QueryMapList(sql);

            for (Map<String, Object> r : rows) {
                String category = (String) r.get("category");
                if (category == null)
                    continue;

                Integer isDangerous = (Integer) r.get("is_dangerous");
                String label = category + (isDangerous != null && isDangerous == 1 ? "(危险)" : "(普通)");

                Object valueObj = r.get("total_value");
                double value = valueObj != null ? ((Number) valueObj).doubleValue() : 0.0;

                totalValue += value;

                Map<String, Object> m = new HashMap<>();
                m.put("name", label);
                m.put("value", Math.round(value * 100.0) / 100.0);
                outerList.add(m);
            }

            // 构建嵌套环形图数据结构
            Map<String, Object> result = new HashMap<>();

            // 内环：资产总值
            List<Map<String, Object>> innerList = new ArrayList<>();
            Map<String, Object> totalMap = new HashMap<>();
            totalMap.put("name", "耗材资产总值");
            totalMap.put("value", Math.round(totalValue * 100.0) / 100.0);
            innerList.add(totalMap);

            result.put("inner", innerList);
            result.put("outer", outerList);

            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("inner", new ArrayList<>());
            errorResult.put("outer", new ArrayList<>());
            out.write(JSON.toJSONString(errorResult));
        }
    }

    /**
     * 近 6 个月出库趋势：按月份汇总出库总量
     * 返回：{months:['2025-01',...], values:[100,80,...]}
     */
    private void outboundTrend(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String sql = "SELECT DATE_FORMAT(o.create_time, '%Y-%m') AS ym, " +
                "       SUM(i.quantity) AS qty " +
                "FROM outbound_order o " +
                "LEFT JOIN outbound_item i ON o.id = i.outbound_id " +
                "WHERE o.status = 3 " +
                "  AND o.create_time >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                "GROUP BY ym " +
                "ORDER BY ym";
        try {
            List<String> months = new ArrayList<>();
            List<Integer> values = new ArrayList<>();
            List<OutboundTrendRow> rows = DBUtils.QueryBeanList(sql, OutboundTrendRow.class);
            for (OutboundTrendRow r : rows) {
                months.add(r.getYm());
                values.add(r.getQty() == null ? 0 : r.getQty());
            }
            Map<String, Object> result = new HashMap<>();
            result.put("months", months);
            result.put("values", values);
            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"months\":[],\"values\":[]}");
        }
    }

    /**
     * 危险品库存占比：只统计 is_dangerous = 1 的耗材
     * 返回：[{name:'试剂(危险)', value: 50}, ...]
     */
    private void stockDanger(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String sql = "SELECT c.category, SUM(s.total_quantity) AS qty " +
                "FROM stock s " +
                "LEFT JOIN consumable c ON s.consumable_id = c.id " +
                "WHERE c.is_dangerous = 1 " +
                "GROUP BY c.category " +
                "ORDER BY c.category";
        try {
            List<Map<String, Object>> list = new ArrayList<>();
            List<StockRow> rows = DBUtils.QueryBeanList(sql, StockRow.class);
            for (StockRow r : rows) {
                if (r.getCategory() == null)
                    continue;
                String label = r.getCategory() + "(危险)";
                Map<String, Object> m = new HashMap<>();
                m.put("name", label);
                m.put("value", r.getQty() == null ? 0 : r.getQty());
                list.add(m);
            }
            out.write(JSON.toJSONString(list));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        }
    }

    /**
     * 近 N 个月危险品出库趋势（支持 months 参数，默认6）
     */
    private void outboundDangerTrend(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String monthsStr = req.getParameter("months");
        int months = 6;
        try {
            if (monthsStr != null)
                months = Integer.parseInt(monthsStr);
        } catch (Exception ignored) {
        }
        String sql = "SELECT DATE_FORMAT(o.create_time, '%Y-%m') AS ym, " +
                "       SUM(i.quantity) AS qty " +
                "FROM outbound_order o " +
                "LEFT JOIN outbound_item i ON o.id = i.outbound_id " +
                "LEFT JOIN consumable c ON i.consumable_id = c.id " +
                "WHERE o.status = 3 " +
                "  AND c.is_dangerous = 1 " +
                "  AND o.create_time >= DATE_SUB(CURDATE(), INTERVAL " + months + " MONTH) " +
                "GROUP BY ym " +
                "ORDER BY ym";
        try {
            List<String> monthList = new ArrayList<>();
            List<Integer> values = new ArrayList<>();
            List<OutboundTrendRow> rows = DBUtils.QueryBeanList(sql, OutboundTrendRow.class);
            for (OutboundTrendRow r : rows) {
                monthList.add(r.getYm());
                values.add(r.getQty() == null ? 0 : r.getQty());
            }
            Map<String, Object> result = new HashMap<>();
            result.put("months", monthList);
            result.put("values", values);
            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"months\":[],\"values\":[]}");
        }
    }

    /**
     * 库存汇总：返回各耗材当前库存（用于柱状图），直接从 stock JOIN consumable 取
     * 返回：{names:['无水乙醇',...], values:[365,...], isDangerous:[1,...]}
     */
    private void stockSummary(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String sql = "SELECT c.name, c.is_dangerous, s.total_quantity AS qty " +
                "FROM stock s " +
                "JOIN consumable c ON s.consumable_id = c.id " +
                "WHERE s.total_quantity > 0 " +
                "ORDER BY s.total_quantity DESC LIMIT 20";
        try {
            List<String> names = new ArrayList<>();
            List<Integer> values = new ArrayList<>();
            List<Integer> dangerous = new ArrayList<>();
            List<StockRow2> rows = DBUtils.QueryBeanList(sql, StockRow2.class);
            for (StockRow2 r : rows) {
                names.add(r.getName());
                values.add(r.getQty() == null ? 0 : r.getQty());
                dangerous.add(r.getIs_dangerous() == null ? 0 : r.getIs_dangerous());
            }
            Map<String, Object> result = new HashMap<>();
            result.put("names", names);
            result.put("values", values);
            result.put("isDangerous", dangerous);
            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"names\":[],\"values\":[],\"isDangerous\":[]}");
        }
    }

    // 内部 DTO 类（只在本 Servlet 用）
    public static class StockRow {
        private String category;
        private Integer is_dangerous;
        private Integer qty;

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public Integer getIs_dangerous() {
            return is_dangerous;
        }

        public void setIs_dangerous(Integer is_dangerous) {
            this.is_dangerous = is_dangerous;
        }

        public Integer getQty() {
            return qty;
        }

        public void setQty(Integer qty) {
            this.qty = qty;
        }
    }

    public static class OutboundTrendRow {
        private String ym;
        private Integer qty;

        public String getYm() {
            return ym;
        }

        public void setYm(String ym) {
            this.ym = ym;
        }

        public Integer getQty() {
            return qty;
        }

        public void setQty(Integer qty) {
            this.qty = qty;
        }
    }

    public static class StockRow2 {
        private String name;
        private Integer is_dangerous;
        private Integer qty;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public Integer getIs_dangerous() {
            return is_dangerous;
        }

        public void setIs_dangerous(Integer is_dangerous) {
            this.is_dangerous = is_dangerous;
        }

        public Integer getQty() {
            return qty;
        }

        public void setQty(Integer qty) {
            this.qty = qty;
        }
    }

    /**
     * 库存健康度评分（0-100）
     * = 100 - 缺货扣分 - 预警扣分 - 过期扣分
     * 缺货率：stock.total_quantity=0 的耗材占比，每1%扣0.5分，最多扣30分
     * 预警率：total_quantity<=warning_quantity 的占比，每1%扣0.3分，最多扣20分
     * 过期覆盖：validity_period不为null的耗材中，inbound_item.expire_date<NOW()的占比，每1%扣0.5分，最多扣30分
     */
    private void healthScore(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();
        try {
            // 总耗材种数（有库存记录的）
            Object totalObj = DBUtils.QueryScalar("SELECT COUNT(*) FROM stock");
            int total = totalObj == null ? 0 : Integer.parseInt(totalObj.toString());

            int score = 100;
            List<String> deductions = new ArrayList<>();

            if (total > 0) {
                // 缺货扣分
                Object outObj = DBUtils.QueryScalar("SELECT COUNT(*) FROM stock WHERE total_quantity = 0");
                int outCount = outObj == null ? 0 : Integer.parseInt(outObj.toString());
                double outRate = (double) outCount / total * 100;
                int outDeduct = (int) Math.min(outRate * 0.5, 30);
                if (outDeduct > 0) {
                    score -= outDeduct;
                    deductions.add("缺货耗材 " + outCount + " 种，扣 " + outDeduct + " 分");
                }

                // 预警扣分
                Object warnObj = DBUtils.QueryScalar(
                        "SELECT COUNT(*) FROM stock WHERE total_quantity > 0 AND total_quantity <= warning_quantity AND warning_quantity > 0");
                int warnCount = warnObj == null ? 0 : Integer.parseInt(warnObj.toString());
                double warnRate = (double) warnCount / total * 100;
                int warnDeduct = (int) Math.min(warnRate * 0.3, 20);
                if (warnDeduct > 0) {
                    score -= warnDeduct;
                    deductions.add("库存预警耗材 " + warnCount + " 种，扣 " + warnDeduct + " 分");
                }

                // 过期扣分（基于入库批次的过期日期）
                Object expireObj = DBUtils.QueryScalar(
                        "SELECT COUNT(DISTINCT i.consumable_id) FROM inbound_item i " +
                                "WHERE i.expire_date IS NOT NULL AND i.expire_date < CURDATE()");
                int expireCount = expireObj == null ? 0 : Integer.parseInt(expireObj.toString());
                double expireRate = (double) expireCount / total * 100;
                int expireDeduct = (int) Math.min(expireRate * 0.5, 30);
                if (expireDeduct > 0) {
                    score -= expireDeduct;
                    deductions.add("存在过期批次耗材 " + expireCount + " 种，扣 " + expireDeduct + " 分");
                }
            }

            result.put("score", Math.max(score, 0));
            result.put("deductions", deductions);
            result.put("total", total);
            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"score\":0,\"deductions\":[],\"total\":0}");
        }
    }

    /**
     * 审批超时预警：超过24小时未审核的领用申请
     * 返回：[{id, apply_user_name, create_time, hoursAgo, daysAgo, hasDanger}, ...]
     */
    private void overdueApprovals(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String sql = "SELECT o.id, u.real_name AS apply_user_name, o.create_time, " +
                "  TIMESTAMPDIFF(HOUR, o.create_time, NOW()) AS hours_ago, " +
                "  EXISTS(SELECT 1 FROM outbound_item i JOIN consumable c ON i.consumable_id=c.id " +
                "         WHERE i.outbound_id=o.id AND c.is_dangerous=1) AS has_danger " +
                "FROM outbound_order o " +
                "JOIN sys_user u ON o.apply_user_id=u.id " +
                "WHERE o.status=0 AND o.create_time < DATE_SUB(NOW(), INTERVAL 24 HOUR) " +
                "ORDER BY o.create_time ASC LIMIT 10";
        com.jsj.isdt.utils.DruidUtils druid = null;
        java.sql.Connection conn = null;
        try {
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 领用审核状态分布
     * 返回：{pending:N, pass:N, reject:N, done:N}
     * status: 0=待审核 1=初审通过 2=驳回 3=已出库
     */
    private void outboundStatusDist(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();
        try {
            Object p = DBUtils.QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE status=0");
            Object a = DBUtils.QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE status=1");
            Object r = DBUtils.QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE status=2");
            Object d = DBUtils.QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE status=3");
            result.put("pending", p == null ? 0 : Integer.parseInt(p.toString()));
            result.put("approved", a == null ? 0 : Integer.parseInt(a.toString()));
            result.put("rejected", r == null ? 0 : Integer.parseInt(r.toString()));
            result.put("done", d == null ? 0 : Integer.parseInt(d.toString()));
            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"pending\":0,\"approved\":0,\"rejected\":0,\"done\":0}");
        }
    }

    /**
     * 实验室工作台数据（实验室管理员首页）
     * 需要 session 中的 lab_id，通过 request 参数传入
     */
    private void labDashboard(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String labIdStr = req.getParameter("lab_id");
        if (labIdStr == null || labIdStr.trim().isEmpty()) {
            out.write("{}");
            return;
        }
        int labId;
        try {
            labId = Integer.parseInt(labIdStr);
        } catch (Exception e) {
            out.write("{}");
            return;
        }
        Map<String, Object> result = new HashMap<>();
        java.sql.Connection conn = null;
        try {
            // 当前库存总种类
            Object stockKinds = DBUtils.QueryScalar("SELECT COUNT(*) FROM stock WHERE lab_id=? AND total_quantity>0",
                    labId);
            result.put("stockKinds", stockKinds == null ? 0 : Integer.parseInt(stockKinds.toString()));

            // 库存预警数
            Object warnCount = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM stock WHERE lab_id=? AND total_quantity<=warning_quantity AND warning_quantity>0",
                    labId);
            result.put("warnCount", warnCount == null ? 0 : Integer.parseInt(warnCount.toString()));

            // 待审核领用申请数
            Object pendingOutbound = DBUtils
                    .QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE lab_id=? AND status=0", labId);
            result.put("pendingOutbound", pendingOutbound == null ? 0 : Integer.parseInt(pendingOutbound.toString()));

            // 待审核归还数
            Object pendingReturn = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM return_record rr JOIN outbound_item i ON rr.outbound_item_id=i.id " +
                            "JOIN outbound_order o ON i.outbound_id=o.id WHERE o.lab_id=? AND rr.status=0",
                    labId);
            result.put("pendingReturn", pendingReturn == null ? 0 : Integer.parseInt(pendingReturn.toString()));

            // 本月入库总量
            Object inboundQty = DBUtils.QueryScalar(
                    "SELECT COALESCE(SUM(i.quantity),0) FROM inbound_order o JOIN inbound_item i ON o.id=i.inbound_id "
                            +
                            "WHERE o.lab_id=? AND DATE_FORMAT(o.inbound_time,'%Y-%m')=DATE_FORMAT(NOW(),'%Y-%m')",
                    labId);
            result.put("monthInbound", inboundQty == null ? 0 : Integer.parseInt(inboundQty.toString()));

            // 本月出库总量
            Object outboundQty = DBUtils.QueryScalar(
                    "SELECT COALESCE(SUM(i.quantity),0) FROM outbound_order o JOIN outbound_item i ON o.id=i.outbound_id "
                            +
                            "WHERE o.lab_id=? AND o.status=3 AND DATE_FORMAT(o.create_time,'%Y-%m')=DATE_FORMAT(NOW(),'%Y-%m')",
                    labId);
            result.put("monthOutbound", outboundQty == null ? 0 : Integer.parseInt(outboundQty.toString()));

            // 库存 Top5（用于图表）
            String stockSql = "SELECT c.name, s.total_quantity AS qty, c.is_dangerous " +
                    "FROM stock s JOIN consumable c ON s.consumable_id=c.id " +
                    "WHERE s.lab_id=? AND s.total_quantity>0 ORDER BY s.total_quantity DESC LIMIT 5";
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> stockTop5 = DBUtils.runner().query(
                    conn, stockSql, new org.apache.commons.dbutils.handlers.MapListHandler(), labId);
            result.put("stockTop5", stockTop5 == null ? new ArrayList<>() : stockTop5);

            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{}");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 近 N 个月耗材消耗排行（按出库数量降序，默认1个月，Top 10）
     * 数据来源：outbound_order(status=3) JOIN outbound_item JOIN consumable
     * 返回：[{name:'无水乙醇', qty:120, is_dangerous:1}, ...]
     */
    private void consumptionRank(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String monthsStr = req.getParameter("months");
        int months = 1;
        try {
            if (monthsStr != null)
                months = Integer.parseInt(monthsStr);
        } catch (Exception ignored) {
        }
        String sql = "SELECT c.name, c.is_dangerous, SUM(i.quantity) AS qty " +
                "FROM outbound_order o " +
                "JOIN outbound_item i ON o.id = i.outbound_id " +
                "JOIN consumable c ON i.consumable_id = c.id " +
                "WHERE o.status = 3 " +
                "  AND o.create_time >= DATE_SUB(CURDATE(), INTERVAL " + months + " MONTH) " +
                "GROUP BY c.id, c.name, c.is_dangerous " +
                "ORDER BY qty DESC LIMIT 10";
        java.sql.Connection conn = null;
        try {
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler());
            out.write(JSON.toJSONString(rows == null ? new java.util.ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 按状态查询领用申请列表（用于状态卡片点击弹窗）
     */
    private void outboundList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String statusStr = req.getParameter("status");
        String pageStr = req.getParameter("page");
        String rowsStr = req.getParameter("rows");
        int status = 0;
        int page = 1, rows = 20;
        try {
            if (statusStr != null)
                status = Integer.parseInt(statusStr);
        } catch (Exception ignored) {
        }
        try {
            if (pageStr != null)
                page = Integer.parseInt(pageStr);
        } catch (Exception ignored) {
        }
        try {
            if (rowsStr != null)
                rows = Integer.parseInt(rowsStr);
        } catch (Exception ignored) {
        }
        Map<String, Object> result = new HashMap<>();
        java.sql.Connection conn = null;
        try {
            Object total = DBUtils.QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE status=?", status);
            result.put("total", total == null ? 0 : Integer.parseInt(total.toString()));
            String sql = "SELECT o.id, u.real_name AS apply_user_name, o.course_name, o.class_name, " +
                    "o.purpose, o.create_time, o.status " +
                    "FROM outbound_order o LEFT JOIN sys_user u ON o.apply_user_id=u.id " +
                    "WHERE o.status=? ORDER BY o.id DESC LIMIT ?,?";
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> list = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler(),
                    status, (page - 1) * rows, rows);
            result.put("rows", list == null ? new ArrayList<>() : list);
            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"total\":0,\"rows\":[]}");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 公告列表（已发布，最新5条）
     */
    private void noticeList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        java.sql.Connection conn = null;
        try {
            String sql = "SELECT n.notice_id, n.title, n.content, n.publish_time, n.status, " +
                    "u.real_name AS publisher_name " +
                    "FROM sys_notice n LEFT JOIN sys_user u ON n.publisher_id=u.id " +
                    "WHERE n.status='已发布' ORDER BY n.publish_time DESC LIMIT 5";
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            // 表不存在时返回空列表，不报错
            out.write("[]");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 发布公告（INSERT INTO sys_notice）
     */
    private void noticeSave(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=utf-8");
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();
        try {
            String title = req.getParameter("title");
            String content = req.getParameter("content");
            String pubId = req.getParameter("publisher_id");
            if (title == null || title.trim().isEmpty()) {
                result.put("code", "400");
                result.put("msg", "标题不能为空");
                out.write(JSON.toJSONString(result));
                return;
            }
            // 确保表存在
            try {
                DBUtils.Update("CREATE TABLE IF NOT EXISTS sys_notice (" +
                        "notice_id INT PRIMARY KEY AUTO_INCREMENT," +
                        "title VARCHAR(200) NOT NULL," +
                        "content TEXT," +
                        "publisher_id INT," +
                        "publish_time DATETIME DEFAULT CURRENT_TIMESTAMP," +
                        "status VARCHAR(20) DEFAULT '已发布'" +
                        ") COMMENT '系统公告'");
            } catch (Exception ignored) {
            }
            DBUtils.Update("INSERT INTO sys_notice(title,content,publisher_id,status) VALUES(?,?,?,'已发布')",
                    title.trim(), content, pubId == null ? null : Integer.parseInt(pubId));
            result.put("code", "200");
            result.put("msg", "发布成功");
        } catch (Exception e) {
            e.printStackTrace();
            result.put("code", "500");
            result.put("msg", e.getMessage());
        }
        out.write(JSON.toJSONString(result));
    }

    /**
     * 核心指标：待审核采购计划数、库存预警耗材数、危化品合规率、今日领用申请数
     */
    private void coreIndicators(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();
        try {
            // 待审核采购计划数
            Object pendingPlanObj = DBUtils.QueryScalar("SELECT COUNT(*) FROM purchase_plan WHERE status = 1");
            result.put("pendingPurchasePlans",
                    pendingPlanObj == null ? 0 : Integer.parseInt(pendingPlanObj.toString()));

            // 库存预警耗材数
            Object warningStockObj = DBUtils
                    .QueryScalar("SELECT COUNT(*) FROM stock WHERE total_quantity <= warning_quantity");
            result.put("warningStockItems", warningStockObj == null ? 0 : Integer.parseInt(warningStockObj.toString()));

            // 危化品合规率（已审核的危化品领用单占比）
            // 使用 COUNT(DISTINCT o.id) 确保每张领用单只计算一次
            Object totalDangerOutboundObj = DBUtils.QueryScalar(
                    "SELECT COUNT(DISTINCT o.id) FROM outbound_order o " +
                            "JOIN outbound_item i ON o.id = i.outbound_id " +
                            "JOIN consumable c ON i.consumable_id = c.id " +
                            "WHERE c.is_dangerous = 1");
            Object auditedDangerOutboundObj = DBUtils.QueryScalar(
                    "SELECT COUNT(DISTINCT o.id) FROM outbound_order o " +
                            "JOIN outbound_item i ON o.id = i.outbound_id " +
                            "JOIN consumable c ON i.consumable_id = c.id " +
                            "WHERE c.is_dangerous = 1 AND o.status >= 1");
            int totalDanger = totalDangerOutboundObj == null ? 0 : Integer.parseInt(totalDangerOutboundObj.toString());
            int auditedDanger = auditedDangerOutboundObj == null ? 0
                    : Integer.parseInt(auditedDangerOutboundObj.toString());
            double complianceRate = totalDanger > 0 ? (double) auditedDanger / totalDanger * 100 : 100;
            result.put("dangerComplianceRate", Math.round(complianceRate));

            // 待审核报废申请数
            Object pendingScrapObj = DBUtils
                    .QueryScalar("SELECT COUNT(*) FROM scrap_record WHERE status = 0");
            result.put("todayOutboundRequests",
                    pendingScrapObj == null ? 0 : Integer.parseInt(pendingScrapObj.toString()));

            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{}");
        }
    }

    /**
     * 教师工作台数据（教师首页）
     * 需要 request 参数 user_id
     * 返回：
     * myTotal - 本人领用申请总数
     * myPending - 待审核数
     * myDone - 已出库数
     * myRejected - 已驳回数
     * myReturnTotal - 归还记录总数
     * myReturnPending- 待审核归还数
     * myFeedbackTotal- 使用反馈总数
     * recentOrders - 最近5条领用申请 [{id,purpose,status,create_time}]
     * myTopConsumables - 我的常用耗材Top 5 [{name, quantity}]
     */
    private void teacherDashboard(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String userIdStr = req.getParameter("user_id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            out.write("{}");
            return;
        }
        int userId;
        try {
            userId = Integer.parseInt(userIdStr);
        } catch (Exception e) {
            out.write("{}");
            return;
        }
        Map<String, Object> result = new HashMap<>();
        java.sql.Connection conn1 = null;
        java.sql.Connection conn2 = null;
        java.sql.Connection conn3 = null;
        try {
            Object total = DBUtils.QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE apply_user_id=?", userId);
            Object pending = DBUtils
                    .QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE apply_user_id=? AND status=0", userId);
            Object done = DBUtils.QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE apply_user_id=? AND status=3",
                    userId);
            Object rejected = DBUtils
                    .QueryScalar("SELECT COUNT(*) FROM outbound_order WHERE apply_user_id=? AND status=2", userId);
            result.put("myTotal", total == null ? 0 : Integer.parseInt(total.toString()));
            result.put("myPending", pending == null ? 0 : Integer.parseInt(pending.toString()));
            result.put("myDone", done == null ? 0 : Integer.parseInt(done.toString()));
            result.put("myRejected", rejected == null ? 0 : Integer.parseInt(rejected.toString()));

            Object retTotal = DBUtils.QueryScalar("SELECT COUNT(*) FROM return_record WHERE return_user_id=?", userId);
            Object retPending = DBUtils
                    .QueryScalar("SELECT COUNT(*) FROM return_record WHERE return_user_id=? AND status=0", userId);
            result.put("myReturnTotal", retTotal == null ? 0 : Integer.parseInt(retTotal.toString()));
            result.put("myReturnPending", retPending == null ? 0 : Integer.parseInt(retPending.toString()));

            Object fbTotal = DBUtils.QueryScalar("SELECT COUNT(*) FROM usage_feedback WHERE user_id=?", userId);
            result.put("myFeedbackTotal", fbTotal == null ? 0 : Integer.parseInt(fbTotal.toString()));

            // 最近5条领用申请
            String recentSql = "SELECT o.id, o.purpose, o.status, o.create_time, l.lab_name " +
                    "FROM outbound_order o LEFT JOIN lab l ON o.lab_id=l.id " +
                    "WHERE o.apply_user_id=? ORDER BY o.id DESC LIMIT 5";
            conn1 = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> recentOrders = DBUtils.runner().query(
                    conn1, recentSql, new org.apache.commons.dbutils.handlers.MapListHandler(), userId);
            result.put("recentOrders", recentOrders == null ? new ArrayList<>() : recentOrders);

            // 我的常用耗材 Top 5（按累计领用数量统计）
            String topSql = "SELECT c.name, SUM(i.quantity) AS quantity " +
                    "FROM outbound_item i " +
                    "JOIN outbound_order o ON i.outbound_id = o.id " +
                    "JOIN consumable c ON i.consumable_id = c.id " +
                    "WHERE o.apply_user_id = ? AND o.status = 3 " +
                    "GROUP BY c.id, c.name " +
                    "ORDER BY quantity DESC LIMIT 5";
            conn2 = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> topConsumables = DBUtils.runner().query(
                    conn2, topSql, new org.apache.commons.dbutils.handlers.MapListHandler(), userId);
            result.put("myTopConsumables", topConsumables == null ? new ArrayList<>() : topConsumables);

            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{}");
        } finally {
            if (conn1 != null)
                try {
                    conn1.close();
                } catch (Exception ignored) {
                }
            if (conn2 != null)
                try {
                    conn2.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 危化品待办事项：
     * - 待二审的危险品领用单：status=1（初审通过）且 second_audit_user_id IS NULL
     * - 超期未归还危化品数
     */
    private void dangerTodo(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();
        try {
            // 待二审的危险品领用单（初审通过但未完成二审）
            Object pendingDangerObj = DBUtils.QueryScalar(
                    "SELECT COUNT(DISTINCT o.id) FROM outbound_order o " +
                            "JOIN outbound_item i ON o.id = i.outbound_id " +
                            "JOIN consumable c ON i.consumable_id = c.id " +
                            "WHERE c.is_dangerous = 1 AND o.status = 1 AND o.second_audit_user_id IS NULL");
            result.put("pendingDangerApprovals",
                    pendingDangerObj == null ? 0 : Integer.parseInt(pendingDangerObj.toString()));

            // 超期未归还危化品数（简化计算：已出库但未归还的危险品）
            Object overdueDangerObj = DBUtils.QueryScalar(
                    "SELECT COUNT(*) FROM outbound_item i JOIN outbound_order o ON i.outbound_id = o.id JOIN consumable c ON i.consumable_id = c.id LEFT JOIN return_record r ON r.outbound_item_id = i.id WHERE c.is_dangerous = 1 AND o.status = 3 AND r.id IS NULL AND i.should_return = 1");
            result.put("overdueDangerItems",
                    overdueDangerObj == null ? 0 : Integer.parseInt(overdueDangerObj.toString()));

            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{}");
        }
    }

    /**
     * 【补货预警】查询：常规耗材，当前库存 < 最低安全库存
     * 参数可选：lab_id（实验室管理员需要）
     * 返回：[{id, consumable_name, lab_id, lab_name, current_qty, min_safe_stock,
     * shortage_qty}, ...]
     */
    private void replenishmentWarning(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String labIdStr = req.getParameter("lab_id");
        Integer labId = null;
        try {
            if (labIdStr != null && !labIdStr.trim().isEmpty()) {
                labId = Integer.parseInt(labIdStr);
            }
        } catch (Exception ignored) {
        }

        String sql;
        List<Object> params = new ArrayList<>();
        if (labId != null) {
            sql = "SELECT s.id, c.name AS consumable_name, l.id AS lab_id, l.lab_name, " +
                    "       s.total_quantity AS current_qty, c.min_safe_stock, " +
                    "       (c.min_safe_stock - s.total_quantity) AS shortage_qty " +
                    "FROM stock s " +
                    "JOIN consumable c ON s.consumable_id = c.id " +
                    "JOIN lab l ON s.lab_id = l.id " +
                    "WHERE c.is_dangerous = 0 " +
                    "  AND s.total_quantity < c.min_safe_stock " +
                    "  AND s.lab_id = ? " +
                    "ORDER BY shortage_qty DESC";
            params.add(labId);
        } else {
            sql = "SELECT s.id, c.name AS consumable_name, l.id AS lab_id, l.lab_name, " +
                    "       s.total_quantity AS current_qty, c.min_safe_stock, " +
                    "       (c.min_safe_stock - s.total_quantity) AS shortage_qty " +
                    "FROM stock s " +
                    "JOIN consumable c ON s.consumable_id = c.id " +
                    "JOIN lab l ON s.lab_id = l.id " +
                    "WHERE c.is_dangerous = 0 " +
                    "  AND s.total_quantity < c.min_safe_stock " +
                    "ORDER BY shortage_qty DESC";
        }

        java.sql.Connection conn = null;
        try {
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler(), params.toArray());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 【危化品合规预警】查询：危化品，当前库存 >= 最高合规库存
     * 参数可选：lab_id（实验室管理员需要）
     * 返回：[{id, consumable_name, lab_id, lab_name, current_qty, max_limit_stock,
     * over_qty}, ...]
     */
    private void dangerComplianceWarning(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String labIdStr = req.getParameter("lab_id");
        Integer labId = null;
        try {
            if (labIdStr != null && !labIdStr.trim().isEmpty()) {
                labId = Integer.parseInt(labIdStr);
            }
        } catch (Exception ignored) {
        }

        String sql;
        List<Object> params = new ArrayList<>();
        if (labId != null) {
            sql = "SELECT s.id, c.name AS consumable_name, l.id AS lab_id, l.lab_name, " +
                    "       s.total_quantity AS current_qty, c.max_limit_stock, " +
                    "       (s.total_quantity - c.max_limit_stock) AS over_qty " +
                    "FROM stock s " +
                    "JOIN consumable c ON s.consumable_id = c.id " +
                    "JOIN lab l ON s.lab_id = l.id " +
                    "WHERE c.is_dangerous = 1 " +
                    "  AND s.total_quantity >= c.max_limit_stock " +
                    "  AND s.lab_id = ? " +
                    "ORDER BY over_qty DESC";
            params.add(labId);
        } else {
            sql = "SELECT s.id, c.name AS consumable_name, l.id AS lab_id, l.lab_name, " +
                    "       s.total_quantity AS current_qty, c.max_limit_stock, " +
                    "       (s.total_quantity - c.max_limit_stock) AS over_qty " +
                    "FROM stock s " +
                    "JOIN consumable c ON s.consumable_id = c.id " +
                    "JOIN lab l ON s.lab_id = l.id " +
                    "WHERE c.is_dangerous = 1 " +
                    "  AND s.total_quantity >= c.max_limit_stock " +
                    "ORDER BY over_qty DESC";
        }

        java.sql.Connection conn = null;
        try {
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler(), params.toArray());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 【实时库存台账】查询：当前库存>0的耗材
     * 参数可选：lab_id（实验室管理员需要）
     * 返回：[{id, consumable_id, consumable_name, category, spec, unit, is_dangerous,
     * current_qty, min_safe_stock, max_limit_stock, lab_name}, ...]
     */
    private void listLiveStock(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String labIdStr = req.getParameter("lab_id");
        Integer labId = null;
        try {
            if (labIdStr != null && !labIdStr.trim().isEmpty()) {
                labId = Integer.parseInt(labIdStr);
            }
        } catch (Exception ignored) {
        }

        String sql;
        List<Object> params = new ArrayList<>();
        if (labId != null) {
            sql = "SELECT s.id, c.id AS consumable_id, c.name AS consumable_name, c.category, " +
                    "       c.spec, c.unit, c.is_dangerous, s.total_quantity AS current_qty, " +
                    "       c.min_safe_stock, c.max_limit_stock, l.lab_name " +
                    "FROM stock s " +
                    "JOIN consumable c ON s.consumable_id = c.id " +
                    "JOIN lab l ON s.lab_id = l.id " +
                    "WHERE s.total_quantity > 0 " +
                    "  AND s.lab_id = ? " +
                    "ORDER BY c.is_dangerous DESC, s.total_quantity DESC";
            params.add(labId);
        } else {
            sql = "SELECT s.id, c.id AS consumable_id, c.name AS consumable_name, c.category, " +
                    "       c.spec, c.unit, c.is_dangerous, s.total_quantity AS current_qty, " +
                    "       c.min_safe_stock, c.max_limit_stock, l.lab_name " +
                    "FROM stock s " +
                    "JOIN consumable c ON s.consumable_id = c.id " +
                    "JOIN lab l ON s.lab_id = l.id " +
                    "WHERE s.total_quantity > 0 " +
                    "ORDER BY c.is_dangerous DESC, s.total_quantity DESC";
        }

        java.sql.Connection conn = null;
        try {
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> rows = DBUtils.runner().query(
                    conn, sql, new org.apache.commons.dbutils.handlers.MapListHandler(), params.toArray());
            out.write(JSON.toJSONString(rows == null ? new ArrayList<>() : rows));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 【溯源追踪】查询：获取指定耗材的全生命周期时间线
     * 参数：consumable_id（必填）
     * 返回：[{type, time, operator, description, qty, order_id}, ...]
     * type: purchase(采购计划) | inbound(入库) | outbound(出库) | return(归还) | scrap(报废)
     */
    private void getTraceability(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String consumableIdStr = req.getParameter("consumable_id");
        if (consumableIdStr == null || consumableIdStr.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        int consumableId;
        try {
            consumableId = Integer.parseInt(consumableIdStr);
        } catch (Exception e) {
            out.write("[]");
            return;
        }

        java.sql.Connection conn = null;
        try {
            conn = com.jsj.isdt.utils.DruidUtils.getConnection();
            List<Map<String, Object>> timeline = new ArrayList<>();

            // 1. 查询采购计划
            String purchaseSql = "SELECT p.id AS order_id, p.create_time AS time, u.real_name AS operator, " +
                    "       p.status, i.plan_quantity AS qty " +
                    "FROM purchase_plan_item i " +
                    "JOIN purchase_plan p ON i.plan_id = p.id " +
                    "LEFT JOIN sys_user u ON p.apply_user_id = u.id " +
                    "WHERE i.consumable_id = ? " +
                    "ORDER BY p.create_time DESC";
            List<Map<String, Object>> purchaseRows = DBUtils.runner().query(
                    conn, purchaseSql, new org.apache.commons.dbutils.handlers.MapListHandler(), consumableId);
            if (purchaseRows != null) {
                for (Map<String, Object> r : purchaseRows) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("type", "purchase");
                    item.put("time", r.get("time"));
                    item.put("operator", r.get("operator"));
                    String status = "";
                    Object statusObj = r.get("status");
                    if (statusObj != null) {
                        int s = Integer.parseInt(statusObj.toString());
                        if (s == 0)
                            status = "草稿";
                        else if (s == 1)
                            status = "待审核";
                        else if (s == 2)
                            status = "已通过";
                        else if (s == 3)
                            status = "已驳回";
                    }
                    item.put("description", "采购计划单 #" + r.get("order_id") + "，计划数量 " + r.get("qty") + "，状态：" + status);
                    item.put("qty", r.get("qty"));
                    item.put("order_id", r.get("order_id"));
                    timeline.add(item);
                }
            }

            // 2. 查询入库记录
            String inboundSql = "SELECT i.id, o.inbound_time AS time, u.real_name AS operator, " +
                    "       i.quantity AS qty, i.batch_no, o.id AS order_id " +
                    "FROM inbound_item i " +
                    "JOIN inbound_order o ON i.inbound_id = o.id " +
                    "LEFT JOIN sys_user u ON o.inbound_user_id = u.id " +
                    "WHERE i.consumable_id = ? " +
                    "ORDER BY o.inbound_time DESC";
            List<Map<String, Object>> inboundRows = DBUtils.runner().query(
                    conn, inboundSql, new org.apache.commons.dbutils.handlers.MapListHandler(), consumableId);
            if (inboundRows != null) {
                for (Map<String, Object> r : inboundRows) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("type", "inbound");
                    item.put("time", r.get("time"));
                    item.put("operator", r.get("operator"));
                    String batch = r.get("batch_no") != null ? r.get("batch_no").toString() : "无批次";
                    item.put("description", "入库单 #" + r.get("order_id") + "，批次：" + batch + "，入库数量 " + r.get("qty"));
                    item.put("qty", r.get("qty"));
                    item.put("order_id", r.get("order_id"));
                    timeline.add(item);
                }
            }

            // 3. 查询出库记录
            String outboundSql = "SELECT i.id, o.create_time AS time, u.real_name AS operator, " +
                    "       i.quantity AS qty, o.id AS order_id, o.status, o.purpose " +
                    "FROM outbound_item i " +
                    "JOIN outbound_order o ON i.outbound_id = o.id " +
                    "LEFT JOIN sys_user u ON o.apply_user_id = u.id " +
                    "WHERE i.consumable_id = ? " +
                    "ORDER BY o.create_time DESC";
            List<Map<String, Object>> outboundRows = DBUtils.runner().query(
                    conn, outboundSql, new org.apache.commons.dbutils.handlers.MapListHandler(), consumableId);
            if (outboundRows != null) {
                for (Map<String, Object> r : outboundRows) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("type", "outbound");
                    item.put("time", r.get("time"));
                    item.put("operator", r.get("operator"));
                    String status = "";
                    Object statusObj = r.get("status");
                    if (statusObj != null) {
                        int s = Integer.parseInt(statusObj.toString());
                        if (s == 0)
                            status = "待审核";
                        else if (s == 1)
                            status = "已通过";
                        else if (s == 2)
                            status = "已驳回";
                        else if (s == 3)
                            status = "已出库";
                    }
                    String purpose = r.get("purpose") != null ? r.get("purpose").toString() : "无";
                    item.put("description",
                            "领用单 #" + r.get("order_id") + "，用途：" + purpose + "，领用数量 " + r.get("qty") + "，状态：" + status);
                    item.put("qty", r.get("qty"));
                    item.put("order_id", r.get("order_id"));
                    timeline.add(item);
                }
            }

            // 4. 查询归还记录
            String returnSql = "SELECT r.id, r.apply_time AS time, u.real_name AS operator, " +
                    "       r.return_quantity AS qty, r.id AS order_id, r.status " +
                    "FROM return_record r " +
                    "JOIN outbound_item oi ON r.outbound_item_id = oi.id " +
                    "LEFT JOIN sys_user u ON r.return_user_id = u.id " +
                    "WHERE oi.consumable_id = ? " +
                    "ORDER BY r.apply_time DESC";
            List<Map<String, Object>> returnRows = DBUtils.runner().query(
                    conn, returnSql, new org.apache.commons.dbutils.handlers.MapListHandler(), consumableId);
            if (returnRows != null) {
                for (Map<String, Object> r : returnRows) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("type", "return");
                    item.put("time", r.get("time"));
                    item.put("operator", r.get("operator"));
                    String status = "";
                    Object statusObj = r.get("status");
                    if (statusObj != null) {
                        int s = Integer.parseInt(statusObj.toString());
                        if (s == 0)
                            status = "待审核";
                        else if (s == 1)
                            status = "已通过";
                        else if (s == 2)
                            status = "已驳回";
                    }
                    item.put("description", "归还单 #" + r.get("order_id") + "，归还数量 " + r.get("qty") + "，状态：" + status);
                    item.put("qty", r.get("qty"));
                    item.put("order_id", r.get("order_id"));
                    timeline.add(item);
                }
            }

            // 5. 查询报废记录
            String scrapSql = "SELECT s.id, s.apply_time AS time, u.real_name AS operator, " +
                    "       s.quantity AS qty, s.id AS order_id, s.status, s.reason " +
                    "FROM scrap_record s " +
                    "LEFT JOIN sys_user u ON s.apply_user_id = u.id " +
                    "WHERE s.consumable_id = ? " +
                    "ORDER BY s.apply_time DESC";
            List<Map<String, Object>> scrapRows = DBUtils.runner().query(
                    conn, scrapSql, new org.apache.commons.dbutils.handlers.MapListHandler(), consumableId);
            if (scrapRows != null) {
                for (Map<String, Object> r : scrapRows) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("type", "scrap");
                    item.put("time", r.get("time"));
                    item.put("operator", r.get("operator"));
                    String status = "";
                    Object statusObj = r.get("status");
                    if (statusObj != null) {
                        int s = Integer.parseInt(statusObj.toString());
                        if (s == 0)
                            status = "待审核";
                        else if (s == 1)
                            status = "已通过";
                        else if (s == 2)
                            status = "已驳回";
                    }
                    String reason = r.get("reason") != null ? r.get("reason").toString() : "无";
                    item.put("description",
                            "报废单 #" + r.get("order_id") + "，原因：" + reason + "，报废数量 " + r.get("qty") + "，状态：" + status);
                    item.put("qty", r.get("qty"));
                    item.put("order_id", r.get("order_id"));
                    timeline.add(item);
                }
            }

            // 按时间排序（最新的在前）
            timeline.sort((a, b) -> {
                String timeA = a.get("time") != null ? a.get("time").toString() : "";
                String timeB = b.get("time") != null ? b.get("time").toString() : "";
                return timeB.compareTo(timeA);
            });

            out.write(JSON.toJSONString(timeline));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            if (conn != null)
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
        }
    }

    /**
     * 近一年各月采购金额 vs 报废损耗金额趋势
     * 返回：{months: ['2025-01', ...], purchaseAmount: [1000.0, ...], scrapAmount:
     * [50.0, ...]}
     */
    private void purchaseScrapTrend(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        try {
            // 获取近12个月的数据
            String[] months = new String[12];
            double[] purchaseAmount = new double[12];
            double[] scrapAmount = new double[12];

            // 生成月份列表（从2026年1月开始）
            String[] targetMonths = new String[] { "2026-01", "2026-02", "2026-03", "2026-04", "2026-05",
                    "2026-06", "2026-07", "2026-08", "2026-09", "2026-10",
                    "2026-11", "2026-12" };
            System.arraycopy(targetMonths, 0, months, 0, 12);

            // 查询采购金额（按入库单统计）
            String purchaseSql = "SELECT DATE_FORMAT(i.inbound_time, '%Y-%m') AS ym, " +
                    "       SUM(ii.quantity * COALESCE(ii.unit_price, 0)) AS total_amount " +
                    "FROM inbound_order i " +
                    "LEFT JOIN inbound_item ii ON i.id = ii.inbound_id " +
                    "WHERE i.inbound_time >= '2026-01-01' " +
                    "GROUP BY ym ORDER BY ym";

            List<Map<String, Object>> purchaseRows = DBUtils.QueryMapList(purchaseSql);

            // 将采购数据填充到数组中
            for (Map<String, Object> r : purchaseRows) {
                String ym = (String) r.get("ym");
                Object amountObj = r.get("total_amount");
                double amount = amountObj != null ? ((Number) amountObj).doubleValue() : 0.0;
                for (int i = 0; i < months.length; i++) {
                    if (months[i].equals(ym)) {
                        purchaseAmount[i] = amount;
                        break;
                    }
                }
            }

            // 查询报废金额（报废时使用该耗材的入库单价估算）
            String scrapSql = "SELECT DATE_FORMAT(s.apply_time, '%Y-%m') AS ym, " +
                    "       SUM(s.quantity * COALESCE(ii.unit_price, 0)) AS total_amount " +
                    "FROM scrap_record s " +
                    "LEFT JOIN (" +
                    "    SELECT consumable_id, MAX(unit_price) AS unit_price " +
                    "    FROM inbound_item " +
                    "    GROUP BY consumable_id" +
                    ") ii ON s.consumable_id = ii.consumable_id " +
                    "WHERE s.apply_time >= '2026-01-01' " +
                    "GROUP BY ym ORDER BY ym";

            List<Map<String, Object>> scrapRows = DBUtils.QueryMapList(scrapSql);

            // 将报废数据填充到数组中
            for (Map<String, Object> r : scrapRows) {
                String ym = (String) r.get("ym");
                Object amountObj = r.get("total_amount");
                double amount = amountObj != null ? ((Number) amountObj).doubleValue() : 0.0;
                for (int i = 0; i < months.length; i++) {
                    if (months[i].equals(ym)) {
                        scrapAmount[i] = amount;
                        break;
                    }
                }
            }

            // 构建返回数据
            Map<String, Object> result = new HashMap<>();
            List<String> monthList = new ArrayList<>(java.util.Arrays.asList(months));
            List<Double> purchaseList = new ArrayList<>();
            List<Double> scrapList = new ArrayList<>();

            for (int i = 0; i < 12; i++) {
                purchaseList.add(Math.round(purchaseAmount[i] * 100.0) / 100.0);
                scrapList.add(Math.round(scrapAmount[i] * 100.0) / 100.0);
            }

            result.put("months", monthList);
            result.put("purchaseAmount", purchaseList);
            result.put("scrapAmount", scrapList);

            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("months", new ArrayList<>());
            errorResult.put("purchaseAmount", new ArrayList<>());
            errorResult.put("scrapAmount", new ArrayList<>());
            out.write(JSON.toJSONString(errorResult));
        }
    }

    /**
     * 近30天高频流动耗材榜（按领用频次前5）
     */
    private void highFrequencyConsumables(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String labIdStr = req.getParameter("lab_id");
        if (labIdStr == null || labIdStr.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        int labId;
        try {
            labId = Integer.parseInt(labIdStr);
        } catch (Exception e) {
            out.write("[]");
            return;
        }

        String sql = "SELECT c.id AS consumable_id, c.name AS consumable_name, c.is_dangerous, " +
                "COUNT(DISTINCT o.id) AS order_count " +
                "FROM outbound_order o " +
                "JOIN outbound_item i ON o.id = i.outbound_id " +
                "JOIN consumable c ON i.consumable_id = c.id " +
                "WHERE o.lab_id = ? " +
                "AND o.create_time >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
                "GROUP BY c.id, c.name, c.is_dangerous " +
                "ORDER BY order_count DESC " +
                "LIMIT 5";

        try {
            List<Map<String, Object>> data = DBUtils.QueryMapList(sql, labId);
            out.write(JSON.toJSONString(data));
        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        }
    }

    /**
     * 危化品库存监控数据（用于雷达图）
     */
    private void dangerStockMonitor(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String labIdStr = req.getParameter("lab_id");
        if (labIdStr == null || labIdStr.trim().isEmpty()) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("names", new ArrayList<>());
            empty.put("current", new ArrayList<>());
            empty.put("limit", new ArrayList<>());
            out.write(JSON.toJSONString(empty));
            return;
        }
        int labId;
        try {
            labId = Integer.parseInt(labIdStr);
        } catch (Exception e) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("names", new ArrayList<>());
            empty.put("current", new ArrayList<>());
            empty.put("limit", new ArrayList<>());
            out.write(JSON.toJSONString(empty));
            return;
        }

        String sql = "SELECT c.name AS consumable_name, " +
                "COALESCE(s.total_quantity, 0) AS current_qty, " +
                "COALESCE(c.max_limit_stock, 0) AS max_limit_stock " +
                "FROM consumable c " +
                "LEFT JOIN stock s ON c.id = s.consumable_id AND s.lab_id = ? " +
                "WHERE c.is_dangerous = 1 " +
                "ORDER BY s.total_quantity DESC";

        try {
            List<Map<String, Object>> data = DBUtils.QueryMapList(sql, labId);

            List<String> names = new ArrayList<>();
            List<Double> current = new ArrayList<>();
            List<Double> limit = new ArrayList<>();

            for (Map<String, Object> r : data) {
                String name = (String) r.get("consumable_name");
                if (name != null) {
                    Object cObj = r.get("current_qty");
                    double c = cObj != null ? ((Number) cObj).doubleValue() : 0.0;

                    // 只保留有库存的危化品
                    if (c > 0) {
                        names.add(name);

                        Object lObj = r.get("max_limit_stock");
                        double l = lObj != null ? ((Number) lObj).doubleValue() : 0.0;

                        current.add(c);
                        limit.add(l);
                    }
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("names", names);
            result.put("current", current);
            result.put("limit", limit);

            out.write(JSON.toJSONString(result));
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> empty = new HashMap<>();
            empty.put("names", new ArrayList<>());
            empty.put("current", new ArrayList<>());
            empty.put("limit", new ArrayList<>());
            out.write(JSON.toJSONString(empty));
        }
    }
}