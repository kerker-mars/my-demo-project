<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="com.alibaba.fastjson.JSON" %>
        <html>

        <head>
            <title>计算机实验教学中心耗材管理系统</title>
            <link rel="stylesheet" type="text/css" href="static/plugins/jquery-easyui-1.9.14/themes/default/easyui.css">
            <link rel="stylesheet" type="text/css" href="static/plugins/jquery-easyui-1.9.14/themes/icon.css">
            <script src="static/plugins/jquery-easyui-1.9.14/jquery.min.js"></script>
            <script src="static/plugins/jquery-easyui-1.9.14/jquery.easyui.min.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.2/dist/echarts.min.js"></script>
            <link rel="shortcut icon" href="static/login/newPhotos/logo.jpg" type="image/x-icon">
            <style>
                * {
                    box-sizing: border-box;
                }

                body {
                    font-family: "微软雅黑", sans-serif;
                }

                h1 {
                    margin-left: 20px;
                    margin-top: 28px;
                    float: left;
                    font-size: 36px;
                    background: -webkit-linear-gradient(135deg, #1565c0 40%, #42a5f5 70%, #1976d2 100%);
                    -webkit-text-fill-color: transparent;
                    -webkit-background-clip: text;
                }

                /* ===== 首页主体 ===== */
                .home-wrap {
                    display: flex;
                    height: 100%;
                    overflow: hidden;
                }

                .home-main {
                    flex: 1;
                    overflow-y: auto;
                    padding: 14px 16px;
                    background: #f0f4fa;
                }

                /* ===== 可折叠侧边栏 ===== */
                .guide-sidebar {
                    width: 0;
                    overflow: hidden;
                    transition: width 0.3s ease;
                    background: #fff;
                    border-left: 1px solid #e3eaf5;
                    flex-shrink: 0;
                }

                .guide-sidebar.open {
                    width: 260px;
                }

                .guide-toggle {
                    position: fixed;
                    right: 0;
                    top: 50%;
                    transform: translateY(-50%);
                    background: #1976d2;
                    color: #fff;
                    border: none;
                    border-radius: 6px 0 0 6px;
                    padding: 10px 6px;
                    cursor: pointer;
                    font-size: 12px;
                    writing-mode: vertical-rl;
                    letter-spacing: 2px;
                    z-index: 100;
                    transition: right 0.3s;
                }

                .guide-sidebar.open~.guide-toggle {
                    right: 260px;
                }

                .guide-title {
                    font-size: 14px;
                    font-weight: bold;
                    color: #1565c0;
                    border-bottom: 2px solid #e3eaf5;
                    padding-bottom: 8px;
                    margin-bottom: 12px;
                }

                .guide-section {
                    margin-bottom: 14px;
                }

                .guide-section h4 {
                    font-size: 13px;
                    color: #37474f;
                    margin-bottom: 6px;
                }

                .guide-section ul {
                    padding-left: 16px;
                    margin: 0;
                }

                .guide-section li {
                    font-size: 12px;
                    color: #546e7a;
                    line-height: 1.8;
                }

                .guide-section .danger-tip {
                    background: #fff3e0;
                    border-radius: 4px;
                    padding: 6px 8px;
                    font-size: 12px;
                    color: #e65100;
                    margin-top: 6px;
                }

                /* ===== 公告栏 ===== */
                .notice-bar {
                    background: #fff;
                    border-radius: 8px;
                    box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                    margin-bottom: 12px;
                    overflow: hidden;
                }

                .notice-bar-head {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 10px 14px;
                    cursor: pointer;
                    border-bottom: 1px solid #e8eef7;
                }

                .notice-bar-head:hover {
                    background: #f5f9ff;
                }

                .notice-bar-title {
                    font-size: 13px;
                    font-weight: bold;
                    color: #1565c0;
                }

                .notice-bar-body {
                    padding: 10px 14px;
                    display: none;
                }

                .notice-bar-body.open {
                    display: block;
                }

                .notice-item {
                    padding: 7px 0;
                    border-bottom: 1px solid #f0f4fa;
                    font-size: 13px;
                }

                .notice-item:last-child {
                    border-bottom: none;
                }

                .notice-item .n-title {
                    color: #263238;
                    font-weight: 500;
                }

                .notice-item .n-meta {
                    font-size: 11px;
                    color: #90a4ae;
                    margin-top: 2px;
                }

                .notice-publish-btn {
                    font-size: 12px;
                    background: #e3f2fd;
                    color: #1976d2;
                    border: 1px solid #90caf9;
                    border-radius: 4px;
                    padding: 2px 10px;
                    cursor: pointer;
                }

                /* ===== KPI 卡 ===== */
                .kpi-row {
                    display: flex;
                    gap: 10px;
                    margin-bottom: 12px;
                }

                .kpi-card {
                    flex: 1;
                    background: #fff;
                    border-radius: 8px;
                    padding: 12px 14px;
                    box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                    border-top: 3px solid #1976d2;
                    position: relative;
                    overflow: hidden;
                }

                .kpi-card.warn {
                    border-top-color: #f57c00;
                }

                .kpi-card.ok {
                    border-top-color: #43a047;
                }

                .kpi-card.info {
                    border-top-color: #8e24aa;
                }

                .kpi-label {
                    font-size: 12px;
                    color: #78909c;
                    margin-bottom: 4px;
                }

                .kpi-value {
                    font-size: 26px;
                    font-weight: bold;
                    color: #1565c0;
                    line-height: 1;
                }

                .kpi-card.warn .kpi-value {
                    color: #f57c00;
                }

                .kpi-card.ok .kpi-value {
                    color: #43a047;
                }

                .kpi-card.info .kpi-value {
                    color: #8e24aa;
                }

                .kpi-unit {
                    font-size: 11px;
                    color: #90a4ae;
                    margin-top: 3px;
                }

                .kpi-icon {
                    position: absolute;
                    right: 12px;
                    top: 12px;
                    font-size: 26px;
                    opacity: 0.12;
                }

                /* ===== 健康度评分 ===== */
                .health-card {
                    background: #fff;
                    border-radius: 8px;
                    box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                    padding: 14px 16px;
                    margin-bottom: 12px;
                    display: flex;
                    align-items: center;
                    gap: 20px;
                }

                .health-score-wrap {
                    flex-shrink: 0;
                    text-align: center;
                }

                .health-score {
                    font-size: 48px;
                    font-weight: bold;
                    line-height: 1;
                }

                .health-score.s-good {
                    color: #43a047;
                }

                .health-score.s-mid {
                    color: #f57c00;
                }

                .health-score.s-bad {
                    color: #e53935;
                }

                .health-label {
                    font-size: 12px;
                    color: #90a4ae;
                    margin-top: 4px;
                }

                .health-detail {
                    flex: 1;
                }

                .health-detail-title {
                    font-size: 13px;
                    font-weight: bold;
                    color: #1565c0;
                    margin-bottom: 8px;
                }

                .deduct-item {
                    font-size: 12px;
                    color: #e53935;
                    padding: 3px 0;
                    border-bottom: 1px dashed #ffcdd2;
                }

                .deduct-item:last-child {
                    border-bottom: none;
                }

                .health-ok {
                    font-size: 12px;
                    color: #43a047;
                }

                /* ===== 超时预警 ===== */
                .overdue-card {
                    background: #fff;
                    border-radius: 8px;
                    box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                    margin-bottom: 12px;
                    overflow: hidden;
                }

                .overdue-head {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 10px 14px;
                    background: #ffebee;
                }

                .overdue-head-title {
                    font-size: 13px;
                    font-weight: bold;
                    color: #c62828;
                }

                .overdue-body {
                    padding: 0 14px;
                }

                .overdue-item {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 8px 0;
                    border-bottom: 1px solid #f5f5f5;
                    font-size: 13px;
                }

                .overdue-item:last-child {
                    border-bottom: none;
                }

                .overdue-tag {
                    background: #e53935;
                    color: #fff;
                    border-radius: 4px;
                    padding: 1px 7px;
                    font-size: 11px;
                    font-weight: bold;
                    margin-left: 6px;
                }

                .overdue-link {
                    color: #1976d2;
                    text-decoration: none;
                    font-size: 12px;
                }

                .overdue-link:hover {
                    text-decoration: underline;
                }

                /* ===== 耗材结构饼图 ===== */
                .chart-card {
                    background: #fff;
                    border-radius: 8px;
                    box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                    overflow: hidden;
                    margin-bottom: 12px;
                }

                .chart-head {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 10px 14px;
                    border-bottom: 1px solid #e8eef7;
                }

                .chart-head-title {
                    font-size: 13px;
                    font-weight: bold;
                    color: #1565c0;
                }

                /* ===== 弹窗（发布公告） ===== */
                .modal-mask {
                    display: none;
                    position: fixed;
                    inset: 0;
                    background: rgba(0, 0, 0, 0.4);
                    z-index: 9000;
                    align-items: center;
                    justify-content: center;
                }

                .modal-mask.show {
                    display: flex;
                }

                .modal-box {
                    background: #fff;
                    border-radius: 10px;
                    width: 520px;
                    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
                    overflow: hidden;
                }

                .modal-head {
                    background: linear-gradient(90deg, #1565c0, #1976d2);
                    color: #fff;
                    padding: 12px 18px;
                    font-size: 14px;
                    font-weight: bold;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }

                .modal-close {
                    background: none;
                    border: none;
                    color: #fff;
                    font-size: 18px;
                    cursor: pointer;
                }

                .modal-body {
                    padding: 18px;
                }

                .modal-foot {
                    padding: 10px 18px;
                    border-top: 1px solid #e8eef7;
                    text-align: right;
                }

                .modal-input {
                    width: 100%;
                    border: 1px solid #cfd8dc;
                    border-radius: 5px;
                    padding: 7px 10px;
                    font-size: 13px;
                    font-family: "微软雅黑";
                    margin-bottom: 10px;
                    outline: none;
                }

                .modal-input:focus {
                    border-color: #1976d2;
                }

                .modal-textarea {
                    width: 100%;
                    height: 120px;
                    resize: vertical;
                }

                .modal-btn {
                    background: #1976d2;
                    color: #fff;
                    border: none;
                    border-radius: 5px;
                    padding: 7px 20px;
                    font-size: 13px;
                    cursor: pointer;
                    font-family: "微软雅黑";
                }

                .modal-btn:hover {
                    background: #1565c0;
                }

                .modal-btn-cancel {
                    background: #eceff1;
                    color: #546e7a;
                    margin-right: 8px;
                }

                /* ===== 刷新提示（居中） ===== */
                .refresh-toast {
                    display: none;
                    position: fixed;
                    top: 50%;
                    left: 50%;
                    transform: translate(-50%, -50%);
                    background: rgba(21, 101, 192, 0.92);
                    color: #fff;
                    border-radius: 8px;
                    padding: 14px 28px;
                    font-size: 14px;
                    z-index: 9999;
                }

                /* ===== 预警卡片 ===== */
                .warning-card {
                    background: #fff;
                    border-radius: 8px;
                    box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                    margin-bottom: 12px;
                    overflow: hidden;
                }

                .warning-card.replenish {
                    border-left: 4px solid #f57c00;
                }

                .warning-card.danger {
                    border-left: 4px solid #e53935;
                }

                .warning-head {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 10px 14px;
                }

                .warning-card.replenish .warning-head {
                    background: #fff3e0;
                }

                .warning-card.danger .warning-head {
                    background: #ffebee;
                }

                .warning-head-title {
                    font-size: 13px;
                    font-weight: bold;
                }

                .warning-card.replenish .warning-head-title {
                    color: #e65100;
                }

                .warning-card.danger .warning-head-title {
                    color: #c62828;
                }

                .warning-body {
                    padding: 0 14px;
                }

                .warning-item {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 8px 0;
                    border-bottom: 1px solid #f5f5f5;
                    font-size: 13px;
                }

                .warning-item:last-child {
                    border-bottom: none;
                }

                .warning-item .item-name {
                    color: #37474f;
                    font-weight: 500;
                }

                .warning-item .item-lab {
                    font-size: 11px;
                    color: #90a4ae;
                    margin-left: 6px;
                }

                .warning-item .item-value {
                    font-size: 12px;
                }

                .warning-item .shortage {
                    color: #f57c00;
                    font-weight: bold;
                }

                .warning-item .over {
                    color: #e53935;
                    font-weight: bold;
                }

                .warning-empty {
                    padding: 12px 0;
                    color: #43a047;
                    font-size: 13px;
                    text-align: center;
                }

                /* ===== 实时库存台账 ===== */
                .stock-card {
                    background: #fff;
                    border-radius: 8px;
                    padding: 14px 16px;
                    margin-bottom: 12px;
                    box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                }

                .stock-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 12px;
                }

                .stock-title {
                    font-size: 14px;
                    font-weight: bold;
                    color: #1565c0;
                }

                .stock-datagrid {
                    width: 100%;
                    height: 400px;
                }

                /* ===== 溯源追踪弹窗 ===== */
                .trace-modal-content {
                    padding: 20px;
                }

                .trace-header {
                    font-size: 15px;
                    font-weight: bold;
                    color: #1565c0;
                    margin-bottom: 16px;
                    padding-bottom: 12px;
                    border-bottom: 1px solid #e3eaf5;
                }

                .trace-timeline {
                    max-height: 500px;
                    overflow-y: auto;
                }

                .trace-item {
                    display: flex;
                    margin-bottom: 20px;
                    position: relative;
                }

                .trace-item:last-child {
                    margin-bottom: 0;
                }

                .trace-icon {
                    width: 48px;
                    height: 48px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 20px;
                    flex-shrink: 0;
                    z-index: 1;
                }

                .trace-icon.purchase {
                    background: #e3f2fd;
                    color: #1976d2;
                }

                .trace-icon.inbound {
                    background: #e8f5e9;
                    color: #43a047;
                }

                .trace-icon.outbound {
                    background: #fff3e0;
                    color: #f57c00;
                }

                .trace-icon.return {
                    background: #f3e5f5;
                    color: #8e24aa;
                }

                .trace-icon.scrap {
                    background: #ffebee;
                    color: #e53935;
                }

                .trace-content {
                    margin-left: 16px;
                    padding: 12px 16px;
                    background: #f8fafc;
                    border-radius: 8px;
                    flex: 1;
                }

                .trace-title {
                    font-size: 14px;
                    font-weight: bold;
                    color: #37474f;
                    margin-bottom: 4px;
                }

                .trace-meta {
                    font-size: 12px;
                    color: #90a4ae;
                    margin-bottom: 6px;
                }

                .trace-desc {
                    font-size: 13px;
                    color: #546e7a;
                }

                .trace-item::before {
                    content: '';
                    position: absolute;
                    left: 24px;
                    top: 50px;
                    bottom: -20px;
                    width: 2px;
                    background: #e3eaf5;
                }

                .trace-item:last-child::before {
                    display: none;
                }

                /* ===== 非管理员工作台 ===== */
                .workbench-card {
                    background: #fff;
                    border-radius: 8px;
                    padding: 16px;
                    margin-bottom: 12px;
                    box-shadow: 0 1px 6px rgba(21, 101, 192, 0.08);
                }
            </style>
        </head>
        <% if(session.getAttribute("username")==null) response.sendRedirect("login.jsp"); String
            roleName=(String)session.getAttribute("roleName"); if(roleName==null){ com.entity.SysUser
            lu=(com.entity.SysUser)session.getAttribute("loginUser"); if(lu!=null && lu.getRole_id()!=null){ try{ Object
            rn=com.jsj.isdt.utils.DBUtils.QueryScalar("SELECT role_name FROM sys_role WHERE id=?",lu.getRole_id());
            roleName=rn==null?"":rn.toString(); session.setAttribute("roleName",roleName); }catch(Exception e){
            roleName="" ; } }else{ roleName="" ; } } boolean isSysAdmin=roleName!=null && roleName.contains("系统管理员");
            boolean isLabAdmin=roleName!=null && roleName.contains("实验室管理员"); boolean isTeacher=roleName!=null &&
            roleName.contains("教师"); Integer loginUserId=(Integer)session.getAttribute("userId"); %>

            <body class="easyui-layout">

                <!-- ===== 全局视觉优化样式 ===== -->
                <style>
                    /* ---- 侧边栏深色科技蓝 ---- */
                    .nav-sidebar {
                        background: #0d1b2e;
                        height: 100%;
                        display: flex;
                        flex-direction: column;
                    }

                    .nav-logo {
                        padding: 14px 16px 10px;
                        border-bottom: 1px solid rgba(255, 255, 255, .08);
                    }

                    .nav-logo .logo-text {
                        font-size: 13px;
                        font-weight: bold;
                        color: #90caf9;
                        letter-spacing: .5px;
                    }

                    .nav-logo .logo-sub {
                        font-size: 11px;
                        color: rgba(255, 255, 255, .35);
                        margin-top: 2px;
                    }

                    .nav-section {
                        padding: 10px 10px 4px;
                        font-size: 10px;
                        color: rgba(255, 255, 255, .3);
                        letter-spacing: 1px;
                        text-transform: uppercase;
                    }

                    .nav-item {
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        padding: 9px 14px;
                        margin: 1px 6px;
                        border-radius: 6px;
                        font-size: 13px;
                        color: rgba(255, 255, 255, .75);
                        cursor: pointer;
                        transition: background .15s, color .15s;
                        text-decoration: none;
                        white-space: nowrap;
                    }

                    .nav-item:hover {
                        background: rgba(255, 255, 255, .08);
                        color: #fff;
                    }

                    .nav-item.active {
                        background: #1565c0;
                        color: #fff;
                        font-weight: 600;
                    }

                    .nav-item .nav-icon {
                        font-size: 15px;
                        width: 18px;
                        text-align: center;
                        flex-shrink: 0;
                    }

                    /* ---- 顶部 header ---- */
                    .top-header {
                        height: 56px;
                        background: linear-gradient(90deg, #0d47a1, #1565c0);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 0 20px;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, .18);
                    }

                    .top-header .sys-title {
                        font-size: 18px;
                        font-weight: bold;
                        color: #fff;
                        letter-spacing: .5px;
                    }

                    .top-header .user-info {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        font-size: 13px;
                        color: #e3f2fd;
                    }

                    .top-header .user-badge {
                        background: rgba(255, 255, 255, .15);
                        border-radius: 20px;
                        padding: 3px 12px;
                        font-size: 12px;
                        color: #fff;
                    }

                    /* ---- 面包屑 ---- */
                    .breadcrumb-bar {
                        height: 36px;
                        background: #fff;
                        border-bottom: 1px solid #e8eef7;
                        display: flex;
                        align-items: center;
                        padding: 0 16px;
                        gap: 6px;
                        font-size: 12px;
                        color: #78909c;
                    }

                    .breadcrumb-bar .bc-sep {
                        color: #cfd8dc;
                    }

                    .breadcrumb-bar .bc-cur {
                        color: #1565c0;
                        font-weight: 600;
                    }

                    /* ---- EasyUI tabs 美化 ---- */
                    .tabs-container .tabs-header {
                        background: #f8fafc !important;
                        border-bottom: 2px solid #e3eaf5 !important;
                    }

                    .tabs-container .tabs-header .tabs-wrap li a {
                        font-size: 13px !important;
                        padding: 6px 14px !important;
                        color: #546e7a !important;
                        border-radius: 4px 4px 0 0 !important;
                    }

                    .tabs-container .tabs-header .tabs-wrap li.tabs-selected a {
                        background: #fff !important;
                        color: #1565c0 !important;
                        font-weight: 600 !important;
                        border-top: 2px solid #1565c0 !important;
                    }

                    /* ---- datagrid 美化 ---- */
                    .datagrid-header {
                        background: #f0f4fa !important;
                    }

                    .datagrid-header td {
                        color: #546e7a !important;
                        font-weight: 600 !important;
                        font-size: 12px !important;
                    }

                    .datagrid-row-odd td {
                        background: #fafbfd !important;
                    }

                    .datagrid-row:hover td {
                        background: #e8f0fe !important;
                    }

                    .datagrid-pager {
                        background: #f8fafc !important;
                        border-top: 1px solid #e3eaf5 !important;
                    }

                    /* ---- 底部状态栏 ---- */
                    .status-bar {
                        background: #f0f4fa;
                        border-top: 1px solid #dce6f5;
                        height: 30px;
                        line-height: 30px;
                        text-align: center;
                        font-size: 11px;
                        color: #90a4ae;
                    }

                    /* ---- 中心内容区 - 防止页脚遮挡 ---- */
                    #centerPanel {
                        box-sizing: border-box;
                    }
                </style>

                <!-- 顶部 -->
                <div data-options="region:'north',border:false" style="height:56px;">
                    <div class="top-header">
                        <span class="sys-title">🔬 计算机实验教学中心耗材管理系统</span>
                        <div class="user-info">
                            <span class="user-badge">👤 <%=session.getAttribute("username")%></span>
                            <a href="newServletLogin?action=logout" class="easyui-linkbutton"
                                data-options="iconCls:'icon-back',plain:true"
                                style="color:#e3f2fd;font-size:12px;">退出登录</a>
                        </div>
                    </div>
                </div>

                <!-- 左侧导航 -->
                <div data-options="region:'west',split:true" style="width:200px;">
                    <div class="nav-sidebar">
                        <div class="nav-logo">
                            <div class="logo-text">功能导航</div>
                            <div class="logo-sub">
                                <% if(isSysAdmin){ %>系统管理员<% }else if(isLabAdmin){ %>实验室管理员<% }else{ %>教师<% } %>
                            </div>
                        </div>
                        <div style="flex:1;overflow-y:auto;padding:6px 0;">
                            <% if(isSysAdmin){ %>
                                <a href="#" class="nav-item" data-url="admin/userManage.jsp"><span
                                        class="nav-icon">👥</span>用户管理</a>
                                <a href="#" class="nav-item" data-url="admin/roleManage.jsp"><span
                                        class="nav-icon">🔑</span>角色权限配置</a>
                                <a href="#" class="nav-item" data-url="consumable/consumableList.jsp"><span
                                        class="nav-icon">🧪</span>耗材信息维护</a>
                                <a href="#" class="nav-item" data-url="purchase/purchasePlanAudit.jsp"><span
                                        class="nav-icon">📋</span>采购计划审核</a>
                                <a href="#" class="nav-item" data-url="scrap/scrapAudit.jsp"><span
                                        class="nav-icon">🗑️</span>报废审核与扣减</a>
                                <a href="#" class="nav-item" data-url="report/consumableReport.jsp"><span
                                        class="nav-icon">📊</span>数据统计分析</a>
                                <% }else if(isLabAdmin){ %>
                                    <a href="#" class="nav-item" data-url="purchase/purchasePlanList.jsp"><span
                                            class="nav-icon">📝</span>采购计划填报</a>
                                    <a href="#" class="nav-item" data-url="inbound/inboundList.jsp"><span
                                            class="nav-icon">📥</span>入库登记</a>
                                    <a href="#" class="nav-item" data-url="outbound/outboundDirect.jsp"><span
                                            class="nav-icon">📤</span>出库登记</a>
                                    <a href="#" class="nav-item" data-url="outbound/outboundAudit.jsp"><span
                                            class="nav-icon">✅</span>领用申请审核</a>
                                    <a href="#" class="nav-item" data-url="return/returnAudit.jsp"><span
                                            class="nav-icon">↩️</span>归还登记审核</a>
                                    <a href="#" class="nav-item" data-url="scrap/scrapApply.jsp"><span
                                            class="nav-icon">🗑️</span>报废登记</a>
                                    <a href="#" class="nav-item" data-url="inventory/inventoryCheck.jsp"><span
                                            class="nav-icon">📦</span>库存盘点</a>
                                    <a href="#" class="nav-item" data-url="admin/feedbackManage.jsp"><span
                                            class="nav-icon">💬</span>反馈管理</a>
                                    <% }else if(isTeacher){ %>
                                        <a href="#" class="nav-item" data-url="teacher/outboundManage.jsp"><span
                                                class="nav-icon">📋</span>领用申请管理</a>
                                        <a href="#" class="nav-item" data-url="return/returnApply.jsp"><span
                                                class="nav-icon">↩️</span>归还登记</a>
                                        <a href="#" class="nav-item" data-url="teacher/usageFeedback.jsp"><span
                                                class="nav-icon">💬</span>使用反馈</a>
                                        <% }else{ %>
                                            <p style="padding:10px;color:rgba(255,255,255,.4);font-size:12px;">
                                                角色未识别，请联系管理员。</p>
                                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- 底部 -->
                <div data-options="region:'south',border:false" style="height:30px;">
                    <div class="status-bar">计算机实验教学中心实验室管理办公室 &nbsp;|&nbsp; 耗材管理系统 v2.0</div>
                </div>

                <!-- 中心内容 -->
                <div id="centerPanel" data-options="region:'center',border:false">
                    <!-- 面包屑 -->
                    <div class="breadcrumb-bar" id="breadcrumbBar">
                        <span style="cursor:pointer;" onclick="showHomePage()">🏠 首页</span>
                        <span class="bc-sep" id="bcSep" style="display:none;">›</span>
                        <span class="bc-cur" id="bcCur"></span>
                    </div>
                    <!-- 首页内容区 -->
                    <div id="homePanel" style="height:calc(100% - 36px);overflow:hidden;">
                        <div style="overflow:hidden;height:100%;">

                            <% if(isSysAdmin){ %>
                                <!-- ===== 系统管理员首页 JS（必须在 HTML 之前定义，避免 onclick 找不到函数） ===== -->
                                <script>
                                    var ctx = '<%=request.getContextPath()%>';
                                    var homePieChart = null;
                                    var purchaseScrapChart = null;

                                    /* ===== 静态公告数据（按日期倒序） ===== */
                                    var STATIC_NOTICES = [
                                        {
                                            title: '关于启用耗材管理系统新版本的通知', date: '2026-04-01', publisher: '信息化管理办公室',
                                            content: '耗材管理系统已完成升级，新版本新增库存健康度评分、审批超时预警、数据统计分析等功能。如使用过程中遇到问题，请联系实验室管理办公室或通过系统反馈功能提交。'
                                        },
                                        {
                                            title: '2026年度实验室耗材库存盘点工作安排', date: '2026-03-25', publisher: '实验室管理中心',
                                            content: '定于2026年4月10日至4月12日开展年度库存盘点工作。各实验室管理员须在系统中完成盘点登记，盘点须由两人共同完成并签字确认，盘点结果将作为下一年度采购预算依据。'
                                        },
                                        {
                                            title: '关于规范耗材领用审批流程的通知', date: '2026-03-18', publisher: '计算机实验教学中心',
                                            content: '为进一步规范耗材管理，自2026年4月1日起，所有耗材领用申请须提前24小时提交，危险化学品领用须完成双人审批后方可出库。请各教师知悉并配合执行。'
                                        },
                                        {
                                            title: '危险化学品安全管理专项检查通知', date: '2026-03-10', publisher: '安全管理办公室',
                                            content: '根据学校安全工作部署，将于2026年3月20日至3月25日开展危险化学品专项安全检查。请各实验室确保危化品台账完整、双人双锁落实到位，系统中出入库记录与实物一致。'
                                        },
                                        {
                                            title: '关于2026年春季学期实验耗材申购计划填报的通知', date: '2026-03-01', publisher: '实验室管理中心',
                                            content: '各实验室管理员：请于2026年3月15日前完成春季学期耗材申购计划填报，逾期将影响采购审批进度。填报时请注意危险化学品须单独列明存储要求，并严格执行"五双管理"制度。'
                                        }
                                    ];

                                    /* ===== 公告展开/收起 ===== */
                                    function toggleNotice() {
                                        var body = document.getElementById('noticeBody');
                                        var icon = document.getElementById('noticeToggleIcon');
                                        if (body.classList.contains('open')) {
                                            body.classList.remove('open');
                                            icon.textContent = '▼ 展开';
                                        } else {
                                            body.classList.add('open');
                                            icon.textContent = '▲ 收起';
                                        }
                                    }

                                    /* ===== 公告详情 ===== */
                                    function showNoticeDetail(i) {
                                        var n = STATIC_NOTICES[i];
                                        document.getElementById('noticeDetailTitle').textContent = n.title;
                                        document.getElementById('noticeDetailMeta').textContent = '发布人：' + n.publisher + '　时间：' + n.date;
                                        document.getElementById('noticeDetailContent').textContent = n.content;
                                        document.getElementById('noticeDetailModal').classList.add('show');
                                    }
                                    function closeNoticeDetail() {
                                        document.getElementById('noticeDetailModal').classList.remove('show');
                                    }

                                    /* ===== 健康度详情弹窗 ===== */
                                    function openHealthDetail() {
                                        $.getJSON(ctx + '/ReportServlet?action=healthScore', function (d) {
                                            var s = d.score || 0;
                                            var color = s >= 90 ? '#43a047' : s >= 70 ? '#f57c00' : '#e53935';
                                            document.getElementById('hdScore').textContent = s;
                                            document.getElementById('hdScore').style.color = color;
                                            var deducts = d.deductions || [];
                                            var total = d.total || 0;
                                            if (deducts.length === 0) {
                                                document.getElementById('hdDeductList').innerHTML = '<div style="color:#43a047;padding:10px 0;">✔ 无扣分项，库存状态良好</div>';
                                            } else {
                                                var html = '<div style="margin-bottom:10px;"><strong>扣分明细：</strong></div>';
                                                deducts.forEach(function (t) {
                                                    html += '<div style="padding:6px 0;border-bottom:1px dashed #e0e0e0;">'
                                                        + '<span style="color:#e53935;margin-right:8px;">▼</span>' + t + '</div>';
                                                });
                                                html += '<div style="margin-top:10px;font-size:12px;color:#90a4ae;">总耗材种类：' + total + ' 种</div>';
                                                document.getElementById('hdDeductList').innerHTML = html;
                                            }
                                            document.getElementById('healthDetailModal').classList.add('show');
                                        }).fail(function () {
                                            document.getElementById('hdScore').textContent = '—';
                                            document.getElementById('hdDeductList').innerHTML = '<div style="color:#e53935;padding:10px 0;">数据加载失败</div>';
                                            document.getElementById('healthDetailModal').classList.add('show');
                                        });
                                    }

                                    /* ===== 前往审核（单页覆盖模式） ===== */
                                    function gotoAuditTab() {
                                        openFuncPage('数据统计分析', 'report/consumableReport.jsp');
                                        $('a.nav-item[data-url="report/consumableReport.jsp"]').addClass('active').siblings().removeClass('active');
                                        // 等 iframe 加载完后调用其内部 showStatusList(0)
                                        setTimeout(function () {
                                            try {
                                                var iframe = document.getElementById('funcFrame');
                                                if (iframe && iframe.contentWindow && iframe.contentWindow.showStatusList) {
                                                    iframe.contentWindow.showStatusList(0);
                                                }
                                            } catch (e) { }
                                        }, 1200);
                                    }

                                    /* ===== 使用指南侧边栏 ===== */
                                    function toggleGuide() {
                                        var sb = document.getElementById('guideSidebar');
                                        sb.classList.toggle('open');
                                    }

                                    /* ===== 导出饼图 PNG ===== */
                                    function exportHomePie() {
                                        if (!homePieChart) { alert('图表尚未加载，请稍后再试'); return; }
                                        var url = homePieChart.getDataURL({ type: 'png', pixelRatio: 2, backgroundColor: '#fff' });
                                        var a = document.createElement('a');
                                        a.href = url; a.download = '全学院耗材资产价值分布.png'; a.click();
                                    }

                                    /* ===== 导出采购报废趋势 PNG ===== */
                                    function exportPurchaseScrap() {
                                        if (!purchaseScrapChart) { alert('图表尚未加载，请稍后再试'); return; }
                                        var url = purchaseScrapChart.getDataURL({ type: 'png', pixelRatio: 2, backgroundColor: '#fff' });
                                        var a = document.createElement('a');
                                        a.href = url; a.download = '近一年各月采购金额vs报废损耗金额.png'; a.click();
                                    }

                                    /* ===== 刷新饼图 ===== */
                                    function refreshHomePie() {
                                        loadHomePie();
                                        showToast('✔ 数据已刷新');
                                    }

                                    /* ===== 打开功能页（单页覆盖模式） ===== */
                                    function openTab(title, url) {
                                        openFuncPage(title, url);
                                        $('a.nav-item[data-url]').each(function () {
                                            if ($(this).text().trim() === title) { $('a.nav-item').removeClass('active'); $(this).addClass('active'); }
                                        });
                                    }

                                    /* ===== 居中刷新提示 ===== */
                                    function showToast(msg) {
                                        var t = document.getElementById('refreshToast');
                                        t.textContent = msg || '✔ 数据已刷新';
                                        t.style.display = 'block';
                                        setTimeout(function () { t.style.display = 'none'; }, 1800);
                                    }

                                    /* ===== 数据加载函数（DOM 就绪后调用） ===== */
                                    function loadKpi() {
                                        $.getJSON(ctx + '/ReportServlet?action=coreIndicators', function (d) {
                                            $('#kpiPlan').text(d.pendingPurchasePlans || 0);
                                            $('#kpiWarn').text(d.warningStockItems || 0);
                                            $('#kpiRate').text((d.dangerComplianceRate || 100) + '%');
                                            $('#kpiToday').text(d.todayOutboundRequests || 0);
                                        }).fail(function () { $('#kpiPlan,#kpiWarn,#kpiRate,#kpiToday').text('—'); });
                                    }

                                    function loadHomePie() {
                                        $.getJSON(ctx + '/ReportServlet?action=stockCategory', function (data) {
                                            if (!data || !data.inner || data.inner.length === 0) {
                                                homePieChart.setOption({ title: { text: '暂无库存数据', left: 'center', top: 'middle', textStyle: { color: '#b0bec5', fontSize: 14 } } });
                                                return;
                                            }

                                            var innerData = data.inner;
                                            var outerData = data.outer;

                                            var colors = ['#1976d2', '#43a047', '#8e24aa', '#f57c00', '#00838f', '#6d4c41'];
                                            var dangerColors = ['#e53935', '#f57c00', '#c62828'];
                                            outerData.forEach(function (item, i) {
                                                item.itemStyle = { color: item.name.indexOf('危险') >= 0 ? dangerColors[i % 3] : colors[i % 6] };
                                            });

                                            homePieChart.setOption({
                                                tooltip: {
                                                    trigger: 'item',
                                                    formatter: function (p) {
                                                        return p.name + '<br/>价值：<b>¥' + p.value + '</b><br/>占比：' + p.percent + '%';
                                                    }
                                                },
                                                legend: {
                                                    type: 'scroll',
                                                    bottom: 'auto',
                                                    top: '78%',
                                                    left: 'center',
                                                    textStyle: { fontSize: 11 },
                                                    pageTextStyle: { fontSize: 11 },
                                                    pageIconSize: 10
                                                },
                                                series: [
                                                    // 内环：资产总值
                                                    {
                                                        name: '内环',
                                                        type: 'pie',
                                                        radius: ['0%', '30%'],
                                                        center: ['50%', '38%'],
                                                        label: {
                                                            show: true,
                                                            position: 'center',
                                                            formatter: function (params) {
                                                                if (params.percent === 100) {
                                                                    return '{a|总资产}\n{value|¥' + params.value + '}';
                                                                }
                                                                return '';
                                                            },
                                                            rich: {
                                                                a: {
                                                                    fontSize: 12,
                                                                    color: '#607d8b',
                                                                    lineHeight: 20
                                                                },
                                                                value: {
                                                                    fontSize: 16,
                                                                    fontWeight: 'bold',
                                                                    color: '#1976d2'
                                                                }
                                                            }
                                                        },
                                                        data: innerData,
                                                        itemStyle: {
                                                            color: '#e3f2fd'
                                                        }
                                                    },
                                                    // 外环：各类别价值
                                                    {
                                                        name: '外环',
                                                        type: 'pie',
                                                        radius: ['40%', '55%'],
                                                        center: ['50%', '38%'],
                                                        avoidLabelOverlap: true,
                                                        label: { show: true, formatter: '{b}\n¥{c}', fontSize: 11 },
                                                        emphasis: { itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.3)' } },
                                                        data: outerData
                                                    }
                                                ]
                                            });
                                        });
                                    }

                                    function loadPurchaseScrap() {
                                        $.getJSON(ctx + '/ReportServlet?action=purchaseScrapTrend', function (data) {
                                            if (!data || !data.months || data.months.length === 0) {
                                                purchaseScrapChart.setOption({ title: { text: '暂无数据', left: 'center', top: 'middle', textStyle: { color: '#b0bec5', fontSize: 14 } } });
                                                return;
                                            }

                                            purchaseScrapChart.setOption({
                                                tooltip: {
                                                    trigger: 'axis',
                                                    axisPointer: { type: 'cross' },
                                                    formatter: function (params) {
                                                        var result = params[0].name + '<br/>';
                                                        params.forEach(function (param) {
                                                            var value = param.value !== undefined ? '¥' + param.value : '';
                                                            result += param.seriesName + ': <b>' + value + '</b><br/>';
                                                        });
                                                        return result;
                                                    }
                                                },
                                                legend: {
                                                    data: ['采购金额', '报废损耗金额'],
                                                    top: 5,
                                                    textStyle: { fontSize: 11 }
                                                },
                                                xAxis: {
                                                    type: 'category',
                                                    data: data.months,
                                                    axisLabel: { fontSize: 10 }
                                                },
                                                yAxis: [
                                                    {
                                                        type: 'value',
                                                        name: '采购金额',
                                                        axisLabel: {
                                                            formatter: '¥{value}',
                                                            fontSize: 10
                                                        }
                                                    },
                                                    {
                                                        type: 'value',
                                                        name: '报废金额',
                                                        axisLabel: {
                                                            formatter: '¥{value}',
                                                            fontSize: 10
                                                        }
                                                    }
                                                ],
                                                series: [
                                                    {
                                                        name: '采购金额',
                                                        type: 'bar',
                                                        data: data.purchaseAmount,
                                                        itemStyle: { color: '#1976d2' }
                                                    },
                                                    {
                                                        name: '报废损耗金额',
                                                        type: 'line',
                                                        yAxisIndex: 1,
                                                        data: data.scrapAmount,
                                                        smooth: true,
                                                        itemStyle: { color: '#e53935' },
                                                        lineStyle: { width: 2 }
                                                    }
                                                ],
                                                grid: {
                                                    left: '8%',
                                                    right: '8%',
                                                    top: '18%',
                                                    bottom: '10%'
                                                }
                                            });
                                        }).fail(function () {
                                            purchaseScrapChart.setOption({ title: { text: '数据加载失败', left: 'center', top: 'middle', textStyle: { color: '#b0bec5', fontSize: 14 } } });
                                        });
                                    }

                                    function refreshPurchaseScrap() {
                                        loadPurchaseScrap();
                                        showToast('✔ 数据已刷新');
                                    }

                                    function loadHealth() {
                                        $.getJSON(ctx + '/ReportServlet?action=healthScore', function (d) {
                                            var s = d.score || 0;
                                            var cls = s >= 90 ? 's-good' : s >= 70 ? 's-mid' : 's-bad';
                                            $('#healthScore').text(s).attr('class', 'health-score ' + cls);
                                            var deducts = d.deductions || [];
                                            if (deducts.length === 0) {
                                                $('#healthDeductions').html('<span class="health-ok">✔ 无扣分项，库存状态良好</span>');
                                            } else {
                                                var html = '';
                                                deducts.forEach(function (t) { html += '<div class="deduct-item">▼ ' + t + '</div>'; });
                                                $('#healthDeductions').html(html);
                                            }
                                        }).fail(function () {
                                            $('#healthScore').text('—').attr('class', 'health-score s-mid');
                                            $('#healthDeductions').html('<span style="color:#90a4ae;font-size:12px;">数据加载失败</span>');
                                        });
                                    }

                                    function loadOverdue() {
                                        $.getJSON(ctx + '/ReportServlet?action=overdueApprovals', function (data) {
                                            if (!data || data.length === 0) {
                                                $('#overdueBody').html('<div style="padding:12px 0;color:#43a047;font-size:13px;text-align:center;">✔ 暂无超时未审核申请</div>');
                                                return;
                                            }
                                            var html = '';
                                            data.forEach(function (r) {
                                                var h = parseInt(r.hours_ago || 0);
                                                var days = Math.floor(h / 24);
                                                var tag = days >= 1 ? '超时 ' + days + ' 天' : '超时 ' + h + ' 小时';
                                                var danger = r.has_danger ? ' <span style="color:#e53935;font-size:11px;">⚠危化品</span>' : '';
                                                html += '<div class="overdue-item">'
                                                    + '<span>申请人：<b>' + (r.apply_user_name || '—') + '</b>' + danger + '</span>'
                                                    + '<span><span class="overdue-tag">' + tag + '</span>'
                                                    + ' <a class="overdue-link" href="javascript:void(0)" onclick="openTab(\'领用申请审核\',\'outbound/outboundAudit.jsp\')">去审核</a></span>'
                                                    + '</div>';
                                            });
                                            $('#overdueBody').html(html);
                                        }).fail(function () {
                                            $('#overdueBody').html('<div style="padding:12px 0;color:#90a4ae;font-size:13px;text-align:center;">数据加载失败</div>');
                                        });
                                    }

                                    function renderStaticNotices() {
                                        var html = '';
                                        STATIC_NOTICES.forEach(function (n, i) {
                                            html += '<div class="notice-item">'
                                                + '<div style="display:flex;align-items:center;justify-content:space-between;">'
                                                + '<div class="n-title">' + n.title + '</div>'
                                                + '<a href="javascript:void(0)" onclick="showNoticeDetail(' + i + ')" style="font-size:11px;color:#1976d2;white-space:nowrap;margin-left:10px;">查看详情</a>'
                                                + '</div>'
                                                + '<div class="n-meta">发布人：' + n.publisher + '&nbsp;&nbsp;时间：' + n.date + '</div>'
                                                + '</div>';
                                        });
                                        $('#noticeList').html(html);
                                    }

                                    /* ===== 实时库存台账 ===== */
                                    function formatCurrentQty(val, row) {
                                        if (!val) return '0';
                                        var isDanger = row.is_dangerous === 1;
                                        var color = isDanger ? '#e53935' : '#1565c0';
                                        return '<span style="font-weight:bold;color:' + color + ';font-size:15px;">' + val + '</span>';
                                    }

                                    function formatAction(val, row) {
                                        return '<a href="javascript:void(0)" onclick="openTrace(' + row.consumable_id + ',\'' + (row.consumable_name || '').replace(/'/g, "\\'") + '\')" style="color:#1976d2;font-size:12px;">🔍 溯源追踪</a>';
                                    }

                                    function formatConsumableName(val, row) {
                                        if (row.is_dangerous === 1) {
                                            return '<span style="color:#e53935;font-weight:bold;">⚠ ' + val + '</span>';
                                        }
                                        return val;
                                    }

                                    function formatSpec(val, row) {
                                        if (row.unit) {
                                            return (val || '') + ' / ' + row.unit;
                                        }
                                        return val || '';
                                    }

                                    function loadLiveStock() {
                                        var url = ctx + '/ReportServlet?action=listLiveStock';
                                        $('#liveStockDatagrid').datagrid({
                                            url: url,
                                            loadFilter: function (data) {
                                                return { total: data.length, rows: data };
                                            },
                                            rowStyler: function (index, row) {
                                                if (row.is_dangerous === 1) {
                                                    return 'background:#ffebee;';
                                                }
                                                return '';
                                            }
                                        });
                                    }

                                    /* ===== 溯源追踪 ===== */
                                    function openTrace(consumableId, consumableName) {
                                        $('#traceConsumableName').text(consumableName);
                                        $('#traceTimeline').html('<div style="padding:40px 20px;text-align:center;color:#90a4ae;">加载中...</div>');
                                        $('#traceModal').dialog('open');

                                        $.getJSON(ctx + '/ReportServlet?action=getTraceability&consumable_id=' + consumableId, function (data) {
                                            if (!data || data.length === 0) {
                                                $('#traceTimeline').html('<div style="padding:40px 20px;text-align:center;color:#90a4ae;">暂无溯源数据</div>');
                                                return;
                                            }
                                            var html = '';
                                            data.forEach(function (item) {
                                                var icon, title;
                                                switch (item.type) {
                                                    case 'purchase':
                                                        icon = '📋';
                                                        title = '采购计划';
                                                        break;
                                                    case 'inbound':
                                                        icon = '📥';
                                                        title = '入库登记';
                                                        break;
                                                    case 'outbound':
                                                        icon = '📤';
                                                        title = '领用出库';
                                                        break;
                                                    case 'return':
                                                        icon = '↩️';
                                                        title = '归还登记';
                                                        break;
                                                    case 'scrap':
                                                        icon = '🗑️';
                                                        title = '报废登记';
                                                        break;
                                                    default:
                                                        icon = '📝';
                                                        title = '操作记录';
                                                }
                                                var time = item.time ? String(item.time).replace('T', ' ') : '';
                                                html += '<div class="trace-item">'
                                                    + '<div class="trace-icon ' + item.type + '">' + icon + '</div>'
                                                    + '<div class="trace-content">'
                                                    + '<div class="trace-title">' + title + '</div>'
                                                    + '<div class="trace-meta">'
                                                    + (item.operator ? '操作人：' + item.operator : '')
                                                    + (item.qty ? '　数量：' + item.qty : '')
                                                    + (time ? '　时间：' + time : '')
                                                    + '</div>'
                                                    + '<div class="trace-desc">' + item.description + '</div>'
                                                    + '</div>'
                                                    + '</div>';
                                            });
                                            $('#traceTimeline').html(html);
                                        }).fail(function () {
                                            $('#traceTimeline').html('<div style="padding:40px 20px;text-align:center;color:#e53935;">数据加载失败</div>');
                                        });
                                    }

                                    function closeTrace() {
                                        $('#traceModal').dialog('close');
                                    }

                                    /* ===== 补货预警 ===== */
                                    function loadReplenishWarning() {
                                        $.getJSON(ctx + '/ReportServlet?action=replenishmentWarning', function (data) {
                                            if (!data || data.length === 0) {
                                                $('#replenishBody').html('<div class="warning-empty">✔ 暂无需要补货的耗材</div>');
                                                return;
                                            }
                                            var html = '';
                                            data.forEach(function (r) {
                                                html += '<div class="warning-item">'
                                                    + '<span><span class="item-name">' + (r.consumable_name || '—') + '</span>'
                                                    + '<span class="item-lab">' + (r.lab_name || '—') + '</span></span>'
                                                    + '<span class="item-value"><span>当前：' + (r.current_qty || 0) + '</span>'
                                                    + '<span style="margin:0 6px;">/</span>'
                                                    + '<span>安全：' + (r.min_safe_stock || 0) + '</span>'
                                                    + '<span style="margin-left:8px;" class="shortage">缺' + (r.shortage_qty || 0) + '</span></span>'
                                                    + '</div>';
                                            });
                                            $('#replenishBody').html(html);
                                        }).fail(function () {
                                            $('#replenishBody').html('<div style="padding:12px 0;color:#90a4ae;font-size:13px;text-align:center;">数据加载失败</div>');
                                        });
                                    }

                                    /* ===== 危化品合规预警 ===== */
                                    function loadDangerWarning() {
                                        $.getJSON(ctx + '/ReportServlet?action=dangerComplianceWarning', function (data) {
                                            window.dangerWarningCache = data;
                                            if (!data || data.length === 0) {
                                                $('#dangerBody').html('<div class="warning-empty">✔ 暂无危化品超库存限制</div>');
                                                return;
                                            }
                                            var html = '';
                                            data.forEach(function (r) {
                                                html += '<div class="warning-item">'
                                                    + '<span><span class="item-name">' + (r.consumable_name || '—') + '</span>'
                                                    + '<span class="item-lab">' + (r.lab_name || '—') + '</span></span>'
                                                    + '<span class="item-value"><span>当前：' + (r.current_qty || 0) + '</span>'
                                                    + '<span style="margin:0 6px;">/</span>'
                                                    + '<span>上限：' + (r.max_limit_stock || 0) + '</span>'
                                                    + '<span style="margin-left:8px;" class="over">超' + (r.over_qty || 0) + '</span></span>'
                                                    + '</div>';
                                            });
                                            $('#dangerBody').html(html);
                                        }).fail(function () {
                                            $('#dangerBody').html('<div style="padding:12px 0;color:#90a4ae;font-size:13px;text-align:center;">数据加载失败</div>');
                                        });
                                    }

                                    /* ===== 打开危化品合规预警详情弹窗 ===== */
                                    function openDangerWarningDetail() {
                                        var data = window.dangerWarningCache || [];
                                        var html = '';
                                        if (!data || data.length === 0) {
                                            html = '<div style="padding:40px 20px;text-align:center;color:#43a047;">✔ 暂无危化品超库存限制</div>';
                                        } else {
                                            html = '<table style="width:100%;border-collapse:collapse;">'
                                                + '<thead>'
                                                + '<tr style="background:#f0f4fa;">'
                                                + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:left;font-size:13px;color:#37474f;">耗材名称</th>'
                                                + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:left;font-size:13px;color:#37474f;">所属实验室</th>'
                                                + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">当前库存</th>'
                                                + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">最高合规库存</th>'
                                                + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">超量数量</th>'
                                                + '</tr>'
                                                + '</thead>'
                                                + '<tbody>';
                                            data.forEach(function (r) {
                                                html += '<tr>'
                                                    + '<td style="padding:10px;border:1px solid #e3eaf5;font-size:13px;color:#37474f;">' + (r.consumable_name || '—') + '</td>'
                                                    + '<td style="padding:10px;border:1px solid #e3eaf5;font-size:13px;color:#37474f;">' + (r.lab_name || '—') + '</td>'
                                                    + '<td style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">' + (r.current_qty || 0) + '</td>'
                                                    + '<td style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">' + (r.max_limit_stock || 0) + '</td>'
                                                    + '<td style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#e53935;font-weight:bold;">' + (r.over_qty || 0) + '</td>'
                                                    + '</tr>';
                                            });
                                            html += '</tbody></table>';
                                        }
                                        document.getElementById('dangerWarningDetailContent').innerHTML = html;
                                        document.getElementById('dangerWarningDetailModal').classList.add('show');
                                    }

                                    /* ===== 关闭危化品合规预警详情弹窗 ===== */
                                    function closeDangerWarningDetail() {
                                        document.getElementById('dangerWarningDetailModal').classList.remove('show');
                                    }

                                    /* ===== DOM 就绪后初始化 ===== */
                                    $(function () {
                                        var pieEl = document.getElementById('homePieChart');
                                        if (pieEl && typeof echarts !== 'undefined') {
                                            homePieChart = echarts.init(pieEl);
                                            loadHomePie();
                                        }

                                        var psEl = document.getElementById('purchaseScrapChart');
                                        if (psEl && typeof echarts !== 'undefined') {
                                            purchaseScrapChart = echarts.init(psEl);
                                            loadPurchaseScrap();
                                        }

                                        loadKpi();
                                        loadHealth();
                                        loadOverdue();
                                        loadReplenishWarning();
                                        loadDangerWarning();
                                        loadLiveStock();
                                        renderStaticNotices();
                                        window.addEventListener('resize', function () {
                                            if (homePieChart) homePieChart.resize();
                                            if (purchaseScrapChart) purchaseScrapChart.resize();
                                        });
                                    });

                                    window.homeRefresh = function () {
                                        loadKpi(); loadHealth(); loadOverdue(); loadHomePie();
                                        loadReplenishWarning(); loadDangerWarning();
                                        if (typeof loadPurchaseScrap !== 'undefined') {
                                            loadPurchaseScrap();
                                        }
                                        showToast('✔ 数据已刷新');
                                    };
                                </script>

                                <!-- ===== 系统管理员首页 HTML ===== -->
                                <div class="home-wrap" id="homeWrap">
                                    <!-- 主内容区 -->
                                    <div class="home-main" id="homeMain">

                                        <!-- 公告栏 -->
                                        <div class="notice-bar">
                                            <div class="notice-bar-head" onclick="toggleNotice()">
                                                <span class="notice-bar-title">📢 系统公告</span>
                                                <span style="display:flex;align-items:center;gap:8px;">
                                                    <span id="noticeToggleIcon" style="color:#90a4ae;font-size:12px;">▼
                                                        展开</span>
                                                </span>
                                            </div>
                                            <div class="notice-bar-body" id="noticeBody">
                                                <div id="noticeList"><span
                                                        style="color:#b0bec5;font-size:13px;">加载中...</span></div>
                                            </div>
                                        </div>

                                        <!-- 公告详情弹窗 -->
                                        <div class="modal-mask" id="noticeDetailModal">
                                            <div class="modal-box">
                                                <div class="modal-head">
                                                    <span id="noticeDetailTitle">公告详情</span>
                                                    <button class="modal-close" onclick="closeNoticeDetail()">✕</button>
                                                </div>
                                                <div class="modal-body">
                                                    <div id="noticeDetailMeta"
                                                        style="font-size:12px;color:#90a4ae;margin-bottom:12px;"></div>
                                                    <div id="noticeDetailContent"
                                                        style="font-size:13px;color:#37474f;line-height:1.8;white-space:pre-wrap;">
                                                    </div>
                                                </div>
                                                <div class="modal-foot">
                                                    <button class="modal-btn" onclick="closeNoticeDetail()">关闭</button>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- KPI 指标 -->
                                        <div class="kpi-row">
                                            <div class="kpi-card">
                                                <div class="kpi-icon">📋</div>
                                                <div class="kpi-label">待审核采购计划</div>
                                                <div class="kpi-value" id="kpiPlan">—</div>
                                                <div class="kpi-unit">条</div>
                                            </div>
                                            <div class="kpi-card warn">
                                                <div class="kpi-icon">⚠</div>
                                                <div class="kpi-label">库存预警耗材</div>
                                                <div class="kpi-value" id="kpiWarn">—</div>
                                                <div class="kpi-unit">种（库存 ≤ 预警值）</div>
                                            </div>
                                            <div class="kpi-card ok">
                                                <div class="kpi-icon">✔</div>
                                                <div class="kpi-label">危化品审批合规率</div>
                                                <div class="kpi-value" id="kpiRate">—</div>
                                                <div class="kpi-unit">已审核 / 全部危化品领用</div>
                                            </div>
                                            <div class="kpi-card info">
                                                <div class="kpi-icon">🗑️</div>
                                                <div class="kpi-label">待审核报废申请</div>
                                                <div class="kpi-value" id="kpiToday">—</div>
                                                <div class="kpi-unit">条</div>
                                            </div>
                                        </div>

                                        <!-- 补货预警 + 危化品合规预警 并排 -->
                                        <div style="display:flex;gap:12px;margin-bottom:12px;">
                                            <!-- 补货预警 -->
                                            <div class="warning-card replenish" style="flex:1;">
                                                <div class="warning-head">
                                                    <span class="warning-head-title">🟠 补货预警（常规耗材库存低于安全值）</span>
                                                    <a href="javascript:void(0)"
                                                        onclick="openTab('采购计划审核','purchase/purchasePlanAudit.jsp')"
                                                        style="font-size:12px;color:#e65100;">去审核采购计划 →</a>
                                                </div>
                                                <div class="warning-body" id="replenishBody">
                                                    <div
                                                        style="padding:12px 0;color:#b0bec5;font-size:13px;text-align:center;">
                                                        加载中...</div>
                                                </div>
                                            </div>
                                            <!-- 危化品合规预警 -->
                                            <div class="warning-card danger" style="flex:1;">
                                                <div class="warning-head">
                                                    <span class="warning-head-title">🔴 危化品合规预警（库存超过最高合规库存）</span>
                                                    <a href="javascript:void(0)" onclick="openDangerWarningDetail()"
                                                        style="font-size:12px;color:#c62828;">查看更多 →</a>
                                                </div>
                                                <div class="warning-body" id="dangerBody">
                                                    <div
                                                        style="padding:12px 0;color:#b0bec5;font-size:13px;text-align:center;">
                                                        加载中...</div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- 库存健康度 + 超时预警 并排 -->
                                        <div style="display:flex;gap:12px;margin-bottom:12px;">
                                            <!-- 库存健康度（点击扣分明细弹窗） -->
                                            <div class="health-card" style="flex:1;">
                                                <div class="health-score-wrap">
                                                    <div class="health-score" id="healthScore">—</div>
                                                    <div class="health-label">库存健康度</div>
                                                    <div style="font-size:11px;color:#90a4ae;margin-top:2px;">满分 100 分
                                                    </div>
                                                </div>
                                                <div class="health-detail">
                                                    <div class="health-detail-title"
                                                        style="display:flex;align-items:center;justify-content:space-between;">
                                                        扣分明细
                                                        <a href="javascript:void(0)" onclick="openHealthDetail()"
                                                            style="font-size:11px;color:#1976d2;font-weight:normal;">查看详情
                                                            →</a>
                                                    </div>
                                                    <div id="healthDeductions"><span
                                                            style="color:#b0bec5;font-size:12px;">加载中...</span></div>
                                                </div>
                                            </div>
                                            <!-- 超时预警 -->
                                            <div class="overdue-card" style="flex:1.4;">
                                                <div class="overdue-head">
                                                    <span class="overdue-head-title">🔴 审批超时预警（超过24小时未审核）</span>
                                                    <a href="javascript:void(0)" onclick="gotoAuditTab()"
                                                        style="font-size:12px;color:#c62828;">前往审核 →</a>
                                                </div>
                                                <div class="overdue-body" id="overdueBody">
                                                    <div
                                                        style="padding:12px 0;color:#b0bec5;font-size:13px;text-align:center;">
                                                        加载中...</div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- 健康度扣分详情弹窗 -->
                                        <div class="modal-mask" id="healthDetailModal">
                                            <div class="modal-box">
                                                <div class="modal-head">
                                                    <span>库存健康度详情</span>
                                                    <button class="modal-close"
                                                        onclick="document.getElementById('healthDetailModal').classList.remove('show')">✕</button>
                                                </div>
                                                <div class="modal-body">
                                                    <div
                                                        style="display:flex;align-items:center;gap:20px;margin-bottom:16px;padding-bottom:14px;border-bottom:1px solid #e8eef7;">
                                                        <div style="text-align:center;">
                                                            <div id="hdScore"
                                                                style="font-size:48px;font-weight:bold;color:#43a047;line-height:1;">
                                                                —</div>
                                                            <div style="font-size:12px;color:#90a4ae;margin-top:4px;">
                                                                综合评分 /
                                                                100</div>
                                                        </div>
                                                        <div
                                                            style="flex:1;font-size:13px;color:#546e7a;line-height:1.8;">
                                                            评分基于：缺货率（最多扣30分）、库存预警率（最多扣20分）、过期批次率（最多扣30分）。
                                                        </div>
                                                    </div>
                                                    <div id="hdDeductList" style="font-size:13px;"></div>
                                                    <div
                                                        style="margin-top:14px;padding:10px;background:#f0f4fa;border-radius:6px;font-size:12px;color:#546e7a;">
                                                        <strong>评分等级：</strong>
                                                        90-100 优秀 &nbsp;|&nbsp; 70-89 良好 &nbsp;|&nbsp; 60-69 一般
                                                        &nbsp;|&nbsp; &lt;60 较差
                                                    </div>
                                                </div>
                                                <div class="modal-foot">
                                                    <button class="modal-btn"
                                                        onclick="document.getElementById('healthDetailModal').classList.remove('show')">关闭</button>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- 全学院耗材资产价值分布（嵌套环形图） + 近一年采购 vs 报废趋势 -->
                                        <div style="display:flex;gap:12px;">
                                            <!-- 嵌套环形图：全学院耗材资产价值分布 -->
                                            <div class="chart-card" style="flex:1;">
                                                <div class="chart-head">
                                                    <span class="chart-head-title">全学院耗材资产价值分布
                                                        <span style="font-size:11px;color:#90a4ae;margin-left:6px;">按类别
                                                            + 危险等级，按入库单价计算</span>
                                                    </span>
                                                    <div style="display:flex;gap:8px;">
                                                        <button onclick="exportHomePie()"
                                                            style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">导出PNG</button>
                                                        <button onclick="refreshHomePie()"
                                                            style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">刷新</button>
                                                    </div>
                                                </div>
                                                <div style="padding:6px 10px 10px;">
                                                    <div id="homePieChart" style="height:260px;"></div>
                                                </div>
                                            </div>

                                            <!-- 双轴折线+柱状图：近一年各月采购金额 vs 报废损耗金额 -->
                                            <div class="chart-card" style="flex:1;">
                                                <div class="chart-head">
                                                    <span class="chart-head-title">近一年各月采购金额 vs 报废损耗金额
                                                        <span
                                                            style="font-size:11px;color:#90a4ae;margin-left:6px;">采购金额（柱状图），报废金额（折线图）</span>
                                                    </span>
                                                    <div style="display:flex;gap:8px;">
                                                        <button onclick="exportPurchaseScrap()"
                                                            style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">导出PNG</button>
                                                        <button onclick="refreshPurchaseScrap()"
                                                            style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">刷新</button>
                                                    </div>
                                                </div>
                                                <div style="padding:6px 10px 10px;">
                                                    <div id="purchaseScrapChart" style="height:260px;"></div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- 实时库存台账 -->
                                        <div class="stock-card">
                                            <div class="stock-header">
                                                <span class="stock-title">📦 实时库存台账（当前库存 > 0）</span>
                                                <button onclick="loadLiveStock()"
                                                    style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">刷新数据</button>
                                            </div>
                                            <table id="liveStockDatagrid" class="easyui-datagrid"
                                                style="width:100%;height:380px;" singleSelect="true" pagination="false"
                                                rownumbers="true">
                                                <thead>
                                                    <tr>
                                                        <th field="consumable_name" width="180"
                                                            formatter="formatConsumableName">耗材名称</th>
                                                        <th field="category" width="100">类别</th>
                                                        <th field="spec" width="120" formatter="formatSpec">规格/单位</th>
                                                        <th field="current_qty" width="120"
                                                            formatter="formatCurrentQty">当前库存</th>
                                                        <th field="min_safe_stock" width="100">最低安全库存</th>
                                                        <th field="max_limit_stock" width="100">最高合规库存</th>
                                                        <th field="lab_name" width="150">所属实验室</th>
                                                        <th field="action" width="100" align="center"
                                                            formatter="formatAction">操作</th>
                                                    </tr>
                                                </thead>
                                            </table>
                                        </div>

                                    </div><!-- /home-main -->

                                    <!-- 可折叠侧边栏（默认收起） -->
                                    <div class="guide-sidebar" id="guideSidebar">
                                        <div class="guide-inner">
                                            <div class="guide-title">📖 系统使用指南</div>
                                            <div class="guide-section">
                                                <h4>分角色功能说明</h4>
                                                <ul>
                                                    <li><strong>系统管理员</strong>：用户管理、角色权限配置、耗材信息维护、采购计划审核、报废审核与扣减、数据统计分析。
                                                    </li>
                                                    <li><strong>实验室管理员</strong>：采购计划填报、入库登记、出库登记、领用申请审核、归还登记审核、报废登记、库存盘点、反馈管理。
                                                    </li>
                                                    <li><strong>教师</strong>：领用申请管理、归还登记、使用反馈。</li>
                                                </ul>
                                            </div>
                                            <div class="guide-section">
                                                <h4>库存健康度说明</h4>
                                                <ul>
                                                    <li>90-100：优秀，库存充足</li>
                                                    <li>70-89：良好，关注预警项</li>
                                                    <li>60-69：一般，需及时补货</li>
                                                    <li>&lt;60：较差，存在缺货/过期风险</li>
                                                </ul>
                                            </div>
                                            <div class="guide-section">
                                                <h4>危险化学品注意事项</h4>
                                                <div class="danger-tip">
                                                    ⚠ 危化品领用需经过<strong>双人审批</strong>，出库前必须完成二审。库存盘点、出入库记录全部留痕，便于追溯与责任落实。
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div><!-- /home-wrap -->

                                <!-- 侧边栏切换按钮 -->
                                <button class="guide-toggle" id="guideToggleBtn" onclick="toggleGuide()">使用指南</button>

                                <!-- 刷新提示（居中） -->
                                <div class="refresh-toast" id="refreshToast">✔ 数据已刷新</div>

                                <!-- 危化品合规预警详情弹窗 -->
                                <div class="modal-mask" id="dangerWarningDetailModal">
                                    <div class="modal-box" style="width:800px;">
                                        <div class="modal-head">
                                            <span>危化品合规预警详情</span>
                                            <button class="modal-close" onclick="closeDangerWarningDetail()">✕</button>
                                        </div>
                                        <div class="modal-body">
                                            <div id="dangerWarningDetailContent"></div>
                                        </div>
                                        <div class="modal-foot">
                                            <button class="modal-btn" onclick="closeDangerWarningDetail()">关闭</button>
                                        </div>
                                    </div>
                                </div>

                                <!-- 溯源追踪弹窗 -->
                                <div id="traceModal" class="easyui-dialog" title="🔍 溯源追踪"
                                    style="width:700px;height:550px;padding:10px;" closed="true" modal="true">
                                    <div class="trace-modal-content">
                                        <div class="trace-header" id="traceConsumableName"
                                            style="font-size:16px;font-weight:bold;color:#1565c0;margin-bottom:15px;padding-bottom:10px;border-bottom:1px solid #e3eaf5;">
                                            耗材名称</div>
                                        <div id="traceTimeline" class="trace-timeline"
                                            style="max-height:420px;overflow-y:auto;"></div>
                                    </div>
                                </div>

                                <% }else if(isLabAdmin){ %>
                                    <!-- ===== 实验室管理员首页 JS ===== -->
                                    <script>
                                        var ctx = '<%=request.getContextPath()%>';
                                        var labPieChart = null;
                                        var highFrequencyChart = null;
                                        var dangerStockChart = null;
                                        var labId = <%=session.getAttribute("loginUser") != null ? ((com.entity.SysUser)session.getAttribute("loginUser")).getLab_id() : "null" %>;

                                        /* ===== 静态公告数据（与系统管理员一致，按日期倒序） ===== */
                                        var STATIC_NOTICES = [
                                            {
                                                title: '关于启用耗材管理系统新版本的通知', date: '2026-04-01', publisher: '信息化管理办公室',
                                                content: '耗材管理系统已完成升级，新版本新增库存健康度评分、审批超时预警、数据统计分析等功能。如使用过程中遇到问题，请联系实验室管理办公室或通过系统反馈功能提交。'
                                            },
                                            {
                                                title: '2026年度实验室耗材库存盘点工作安排', date: '2026-03-25', publisher: '实验室管理中心',
                                                content: '定于2026年4月10日至4月12日开展年度库存盘点工作。各实验室管理员须在系统中完成盘点登记，盘点须由两人共同完成并签字确认，盘点结果将作为下一年度采购预算依据。'
                                            },
                                            {
                                                title: '关于规范耗材领用审批流程的通知', date: '2026-03-18', publisher: '计算机实验教学中心',
                                                content: '为进一步规范耗材管理，自2026年4月1日起，所有耗材领用申请须提前24小时提交，危险化学品领用须完成双人审批后方可出库。请各教师知悉并配合执行。'
                                            },
                                            {
                                                title: '危险化学品安全管理专项检查通知', date: '2026-03-10', publisher: '安全管理办公室',
                                                content: '根据学校安全工作部署，将于2026年3月20日至3月25日开展危险化学品专项安全检查。请各实验室确保危化品台账完整、双人双锁落实到位，系统中出入库记录与实物一致。'
                                            },
                                            {
                                                title: '关于2026年春季学期实验耗材申购计划填报的通知', date: '2026-03-01', publisher: '实验室管理中心',
                                                content: '各实验室管理员：请于2026年3月15日前完成春季学期耗材申购计划填报，逾期将影响采购审批进度。填报时请注意危险化学品须单独列明存储要求，并严格执行"五双管理"制度。'
                                            }
                                        ];

                                        /* ===== 加载公告（与系统管理员一致的渲染方式） ===== */
                                        function loadNotices() {
                                            var html = '';
                                            STATIC_NOTICES.forEach(function (n, i) {
                                                html += '<div class="notice-item">'
                                                    + '<div style="display:flex;align-items:center;justify-content:space-between;">'
                                                    + '<div class="n-title">' + n.title + '</div>'
                                                    + '<a href="javascript:void(0)" onclick="showNoticeDetail(' + i + ')" style="font-size:11px;color:#1976d2;white-space:nowrap;margin-left:10px;">查看详情</a>'
                                                    + '</div>'
                                                    + '<div class="n-meta">发布人：' + n.publisher + '&nbsp;&nbsp;时间：' + n.date + '</div>'
                                                    + '</div>';
                                            });
                                            document.getElementById('noticeList').innerHTML = html || '<div style="color:#b0bec5;font-size:13px;">暂无公告</div>';
                                        }

                                        /* ===== 公告详情 ===== */
                                        function showNoticeDetail(i) {
                                            var n = STATIC_NOTICES[i];
                                            document.getElementById('noticeDetailTitle').textContent = n.title;
                                            document.getElementById('noticeDetailMeta').textContent = '发布人：' + n.publisher + '　时间：' + n.date;
                                            document.getElementById('noticeDetailContent').textContent = n.content;
                                            document.getElementById('noticeDetailModal').classList.add('show');
                                        }
                                        function closeNoticeDetail() {
                                            document.getElementById('noticeDetailModal').classList.remove('show');
                                        }

                                        /* ===== 数据加载函数 ===== */
                                        function loadLabKpi() {
                                            if (!labId) return;
                                            $.getJSON(ctx + '/ReportServlet?action=labDashboard&lab_id=' + labId, function (d) {
                                                $('#labKpiKinds').text(d.stockKinds || 0);
                                                $('#labKpiWarn').text(d.warnCount || 0);
                                                $('#labKpiPendingOutbound').text(d.pendingOutbound || 0);
                                                $('#labKpiPendingReturn').text(d.pendingReturn || 0);
                                                $('#labKpiInbound').text(d.monthInbound || 0);
                                                $('#labKpiOutbound').text(d.monthOutbound || 0);
                                            }).fail(function () {
                                                $('#labKpiKinds,#labKpiWarn,#labKpiPendingOutbound,#labKpiPendingReturn,#labKpiInbound,#labKpiOutbound').text('—');
                                            });
                                            // 未处理反馈数
                                            $.getJSON(ctx + '/ServletUsageFeedback?action=countUnread', function (d) {
                                                var cnt = d.count || 0;
                                                $('#labKpiFeedback').text(cnt);
                                                var badge = document.getElementById('labFeedbackBadge');
                                                if (badge) {
                                                    badge.textContent = cnt > 0 ? cnt : '';
                                                    badge.style.display = cnt > 0 ? 'inline-block' : 'none';
                                                }
                                            });
                                        }

                                        /* ===== 近30天高频流动耗材榜（漏斗图） ===== */
                                        function loadHighFrequency() {
                                            if (!labId) return;
                                            $.getJSON(ctx + '/ReportServlet?action=highFrequencyConsumables&lab_id=' + labId, function (data) {
                                                if (!highFrequencyChart) {
                                                    var el = document.getElementById('highFrequencyChart');
                                                    if (el && typeof echarts !== 'undefined') {
                                                        highFrequencyChart = echarts.init(el);
                                                    }
                                                }
                                                if (!highFrequencyChart) return;

                                                var chartData = [];
                                                var colors = ['#1976d2', '#43a047', '#8e24aa', '#f57c00', '#00838f'];
                                                var dangerColors = ['#e53935', '#d32f2f', '#b71c1c'];

                                                data.forEach(function (item, i) {
                                                    var name = item.consumable_name || '未知';
                                                    var value = item.order_count || 0;
                                                    var isDangerous = item.is_dangerous || 0;
                                                    chartData.push({
                                                        name: name,
                                                        value: value,
                                                        itemStyle: {
                                                            color: isDangerous === 1 ? dangerColors[i % 3] : colors[i % 5]
                                                        }
                                                    });
                                                });

                                                highFrequencyChart.setOption({
                                                    tooltip: {
                                                        trigger: 'item',
                                                        formatter: function (p) {
                                                            var item = data[p.dataIndex];
                                                            var danger = item && item.is_dangerous === 1 ? '<br/>⚠ 危化品' : '';
                                                            return p.name + '<br/>领用次数：<b>' + p.value + '</b> 次' + danger;
                                                        }
                                                    },
                                                    series: [{
                                                        type: 'funnel',
                                                        left: '10%',
                                                        width: '80%',
                                                        top: '8%',
                                                        height: '84%',
                                                        min: 0,
                                                        max: chartData.length > 0 ? chartData[0].value : 10,
                                                        minSize: '0%',
                                                        maxSize: '100%',
                                                        sort: 'descending',
                                                        gap: 3,
                                                        label: {
                                                            show: true,
                                                            position: 'inside',
                                                            formatter: '{b}\n{c}次',
                                                            fontSize: 11,
                                                            color: '#fff'
                                                        },
                                                        emphasis: {
                                                            label: {
                                                                fontSize: 14
                                                            }
                                                        },
                                                        data: chartData
                                                    }]
                                                });
                                            });
                                        }

                                        /* ===== 危化品库存监控（双层雷达图） ===== */
                                        function loadDangerStockMonitor() {
                                            if (!labId) return;
                                            $.getJSON(ctx + '/ReportServlet?action=dangerStockMonitor&lab_id=' + labId, function (data) {
                                                if (!dangerStockChart) {
                                                    var el = document.getElementById('dangerStockChart');
                                                    if (el && typeof echarts !== 'undefined') {
                                                        dangerStockChart = echarts.init(el);
                                                    }
                                                }
                                                if (!dangerStockChart) return;

                                                var names = data.names || [];
                                                var current = data.current || [];
                                                var limit = data.limit || [];

                                                // 计算雷达图的最大值（取limit的最大值或当前的最大值，加一点余量）
                                                var maxVal = 10;
                                                for (var i = 0; i < limit.length; i++) {
                                                    if (limit[i] > maxVal) maxVal = limit[i];
                                                }
                                                for (var i = 0; i < current.length; i++) {
                                                    if (current[i] > maxVal) maxVal = current[i];
                                                }
                                                maxVal = Math.ceil(maxVal * 1.2);

                                                // 构建 indicator
                                                var indicator = [];
                                                for (var i = 0; i < names.length; i++) {
                                                    indicator.push({
                                                        name: names[i],
                                                        max: maxVal
                                                    });
                                                }

                                                dangerStockChart.setOption({
                                                    tooltip: {
                                                        trigger: 'axis',
                                                        formatter: function (params) {
                                                            if (params && params.length > 0) {
                                                                var result = '';

                                                                // 遍历有库存的危化品，显示它们的数据
                                                                for (var j = 0; j < names.length; j++) {
                                                                    var name = names[j] || '';
                                                                    var c = current[j] || 0;
                                                                    var l = limit[j] || 0;
                                                                    var over = l > 0 && c > l ? ' ⚠ 超量' : '';
                                                                    result += '<strong>' + name + '</strong><br/>';
                                                                    result += '当前库存：' + c + '<br/>';
                                                                    result += '最高合规库存：' + l + over + '<br/><br/>';
                                                                }

                                                                return result;
                                                            }
                                                            return '';
                                                        }
                                                    },
                                                    legend: {
                                                        data: ['当前库存', '最高合规库存'],
                                                        bottom: '0%',
                                                        top: 'auto',
                                                        textStyle: { fontSize: 12 },
                                                        itemWidth: 14,
                                                        itemHeight: 14,
                                                        // 明确指定图例颜色
                                                        color: ['#e53935', '#9e9e9e']
                                                    },
                                                    // 全局颜色设置
                                                    color: ['#9e9e9e', '#e53935'],
                                                    radar: {
                                                        indicator: indicator,
                                                        shape: 'polygon',
                                                        splitNumber: 4,
                                                        radius: '60%',
                                                        center: ['50%', '42%'],
                                                        axisName: {
                                                            fontSize: 11,
                                                            color: '#607d8b',
                                                            padding: [4, 0]
                                                        },
                                                        splitLine: {
                                                            lineStyle: {
                                                                color: '#e3eaf5'
                                                            }
                                                        },
                                                        splitArea: {
                                                            show: true,
                                                            areaStyle: {
                                                                color: ['#f6f9fc', '#f0f4fa']
                                                            }
                                                        }
                                                    },
                                                    series: [
                                                        {
                                                            name: '最最高合规库存',
                                                            type: 'radar',
                                                            data: [{
                                                                value: limit,
                                                                name: '最高合规库存',
                                                                areaStyle: {
                                                                    color: 'rgba(158, 158, 158, 0.1)'
                                                                },
                                                                lineStyle: {
                                                                    color: '#9e9e9e',
                                                                    type: 'dashed',
                                                                    width: 1.5
                                                                },
                                                                itemStyle: {
                                                                    color: '#9e9e9e'
                                                                }
                                                            }]
                                                        },
                                                        {
                                                            name: '当前库存',
                                                            type: 'radar',
                                                            data: [{
                                                                value: current,
                                                                name: '当前库存',
                                                                areaStyle: {
                                                                    color: 'rgba(229, 57, 53, 0.35)'
                                                                },
                                                                lineStyle: {
                                                                    color: '#e53935',
                                                                    width: 2
                                                                },
                                                                itemStyle: {
                                                                    color: '#e53935'
                                                                }
                                                            }]
                                                        }
                                                    ]
                                                });
                                            });
                                        }

                                        /* ===== 实验室管理员刷新提示 ===== */
                                        function showLabToast(msg) {
                                            var t = document.getElementById('labRefreshToast');
                                            if (t) {
                                                t.textContent = msg || '✔ 数据已刷新';
                                                t.style.display = 'block';
                                                setTimeout(function () { t.style.display = 'none'; }, 1800);
                                            }
                                        }

                                        /* ===== 导出高频流动漏斗图 PNG ===== */
                                        function exportHighFrequency() {
                                            if (!highFrequencyChart) { alert('图表尚未加载，请稍后再试'); return; }
                                            var url = highFrequencyChart.getDataURL({ type: 'png', pixelRatio: 2, backgroundColor: '#fff' });
                                            var a = document.createElement('a');
                                            a.href = url; a.download = '近30天高频流动耗材榜.png'; a.click();
                                        }

                                        /* ===== 导出危化品库存监控 PNG ===== */
                                        function exportDangerStock() {
                                            if (!dangerStockChart) { alert('图表尚未加载，请稍后再试'); return; }
                                            var url = dangerStockChart.getDataURL({ type: 'png', pixelRatio: 2, backgroundColor: '#fff' });
                                            var a = document.createElement('a');
                                            a.href = url; a.download = '危化品库存监控.png'; a.click();
                                        }

                                        /* ===== 刷新高频流动漏斗图 ===== */
                                        function refreshHighFrequency() {
                                            loadHighFrequency();
                                            showLabToast('✔ 数据已刷新');
                                        }

                                        /* ===== 刷新危化品库存监控 ===== */
                                        function refreshDangerStock() {
                                            loadDangerStockMonitor();
                                            showLabToast('✔ 数据已刷新');
                                        }

                                        /* ===== 打开功能页（单页覆盖模式） ===== */
                                        function openLabTab(title, url) {
                                            openFuncPage(title, url);
                                            $('a.nav-item[data-url]').each(function () {
                                                if ($(this).text().trim() === title) { $('a.nav-item').removeClass('active'); $(this).addClass('active'); }
                                            });
                                        }

                                        /* ===== 居中刷新提示 ===== */
                                        function showLabToast(msg) {
                                            var t = document.getElementById('labRefreshToast');
                                            if (t) {
                                                t.textContent = msg || '✔ 数据已刷新';
                                                t.style.display = 'block';
                                                setTimeout(function () { t.style.display = 'none'; }, 1800);
                                            }
                                        }

                                        /* ===== 补货预警 ===== */
                                        function loadLabReplenishWarning() {
                                            if (!labId) return;
                                            $.getJSON(ctx + '/ReportServlet?action=replenishmentWarning&lab_id=' + labId, function (data) {
                                                if (!data || data.length === 0) {
                                                    $('#labReplenishBody').html('<div class="warning-empty">✔ 暂无需要补货的耗材</div>');
                                                    return;
                                                }
                                                var html = '';
                                                data.forEach(function (r) {
                                                    html += '<div class="warning-item">'
                                                        + '<span><span class="item-name">' + (r.consumable_name || '—') + '</span></span>'
                                                        + '<span class="item-value"><span>当前：' + (r.current_qty || 0) + '</span>'
                                                        + '<span style="margin:0 6px;">/</span>'
                                                        + '<span>安全：' + (r.min_safe_stock || 0) + '</span>'
                                                        + '<span style="margin-left:8px;" class="shortage">缺' + (r.shortage_qty || 0) + '</span></span>'
                                                        + '</div>';
                                                });
                                                $('#labReplenishBody').html(html);
                                            }).fail(function () {
                                                $('#labReplenishBody').html('<div style="padding:12px 0;color:#90a4ae;font-size:13px;text-align:center;">数据加载失败</div>');
                                            });
                                        }

                                        /* ===== 危化品合规预警 ===== */
                                        function loadLabDangerWarning() {
                                            if (!labId) return;
                                            $.getJSON(ctx + '/ReportServlet?action=dangerComplianceWarning&lab_id=' + labId, function (data) {
                                                window.labDangerWarningCache = data;
                                                if (!data || data.length === 0) {
                                                    $('#labDangerBody').html('<div class="warning-empty">✔ 暂无危化品超库存限制</div>');
                                                    return;
                                                }
                                                var html = '';
                                                data.forEach(function (r) {
                                                    html += '<div class="warning-item">'
                                                        + '<span><span class="item-name">' + (r.consumable_name || '—') + '</span></span>'
                                                        + '<span class="item-value"><span>当前：' + (r.current_qty || 0) + '</span>'
                                                        + '<span style="margin:0 6px;">/</span>'
                                                        + '<span>上限：' + (r.max_limit_stock || 0) + '</span>'
                                                        + '<span style="margin-left:8px;" class="over">超' + (r.over_qty || 0) + '</span></span>'
                                                        + '</div>';
                                                });
                                                $('#labDangerBody').html(html);
                                            }).fail(function () {
                                                $('#labDangerBody').html('<div style="padding:12px 0;color:#90a4ae;font-size:13px;text-align:center;">数据加载失败</div>');
                                            });
                                        }

                                        /* ===== 打开危化品合规预警详情弹窗 ===== */
                                        function openLabDangerWarningDetail() {
                                            var data = window.labDangerWarningCache || [];
                                            var html = '';
                                            if (!data || data.length === 0) {
                                                html = '<div style="padding:40px 20px;text-align:center;color:#43a047;">✔ 暂无危化品超库存限制</div>';
                                            } else {
                                                html = '<table style="width:100%;border-collapse:collapse;">'
                                                    + '<thead>'
                                                    + '<tr style="background:#f0f4fa;">'
                                                    + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:left;font-size:13px;color:#37474f;">耗材名称</th>'
                                                    + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">当前库存</th>'
                                                    + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">最高合规库存</th>'
                                                    + '<th style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">超量数量</th>'
                                                    + '</tr>'
                                                    + '</thead>'
                                                    + '<tbody>';
                                                data.forEach(function (r) {
                                                    html += '<tr>'
                                                        + '<td style="padding:10px;border:1px solid #e3eaf5;font-size:13px;color:#37474f;">' + (r.consumable_name || '—') + '</td>'
                                                        + '<td style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">' + (r.current_qty || 0) + '</td>'
                                                        + '<td style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#37474f;">' + (r.max_limit_stock || 0) + '</td>'
                                                        + '<td style="padding:10px;border:1px solid #e3eaf5;text-align:right;font-size:13px;color:#e53935;font-weight:bold;">' + (r.over_qty || 0) + '</td>'
                                                        + '</tr>';
                                                });
                                                html += '</tbody></table>';
                                            }
                                            document.getElementById('labDangerWarningDetailContent').innerHTML = html;
                                            document.getElementById('labDangerWarningDetailModal').classList.add('show');
                                        }

                                        /* ===== 关闭危化品合规预警详情弹窗 ===== */
                                        function closeLabDangerWarningDetail() {
                                            document.getElementById('labDangerWarningDetailModal').classList.remove('show');
                                        }

                                        /* ===== 导出饼图 PNG ===== */
                                        function exportLabPie() {
                                            if (!labPieChart) { alert('图表尚未加载，请稍后再试'); return; }
                                            var url = labPieChart.getDataURL({ type: 'png', pixelRatio: 2, backgroundColor: '#fff' });
                                            var a = document.createElement('a');
                                            a.href = url; a.download = '实验室库存Top5.png'; a.click();
                                        }

                                        // 公告折叠
                                        window.toggleNotice = function () {
                                            var body = document.getElementById('noticeBody');
                                            var icon = document.getElementById('noticeToggleIcon');
                                            if (body.classList.contains('open')) {
                                                body.classList.remove('open');
                                                icon.textContent = '▼ 展开';
                                            } else {
                                                body.classList.add('open');
                                                icon.textContent = '▲ 收起';
                                            }
                                        };

                                        // 侧边栏折叠
                                        window.toggleGuide = function () {
                                            var sb = document.getElementById('guideSidebar');
                                            sb.classList.toggle('open');
                                        };

                                        /* ===== DOM 就绪后初始化 ===== */
                                        $(function () {
                                            loadLabKpi();
                                            loadNotices();
                                            loadLabReplenishWarning();
                                            loadLabDangerWarning();
                                            loadLiveStock();
                                            loadHighFrequency();
                                            loadDangerStockMonitor();
                                            window.addEventListener('resize', function () {
                                                if (highFrequencyChart) highFrequencyChart.resize();
                                                if (dangerStockChart) dangerStockChart.resize();
                                            });
                                        });

                                        window.labRefresh = function () {
                                            loadLabKpi();
                                            loadLabReplenishWarning();
                                            loadLabDangerWarning();
                                            loadLiveStock();
                                            loadHighFrequency();
                                            loadDangerStockMonitor();
                                            showLabToast('✔ 数据已刷新');
                                        };

                                        /* ===== 实时库存台账 ===== */
                                        function formatCurrentQty(val, row) {
                                            if (!val) return '0';
                                            var isDanger = row.is_dangerous === 1;
                                            var color = isDanger ? '#e53935' : '#1565c0';
                                            return '<span style="font-weight:bold;color:' + color + ';font-size:15px;">' + val + '</span>';
                                        }

                                        function formatAction(val, row) {
                                            return '<a href="javascript:void(0)" onclick="openTrace(' + row.consumable_id + ',\'' + (row.consumable_name || '').replace(/'/g, "\\'") + '\')" style="color:#1976d2;font-size:12px;">🔍 溯源追踪</a>';
                                        }

                                        function formatConsumableName(val, row) {
                                            if (row.is_dangerous === 1) {
                                                return '<span style="color:#e53935;font-weight:bold;">⚠ ' + val + '</span>';
                                            }
                                            return val;
                                        }

                                        function formatSpec(val, row) {
                                            if (row.unit) {
                                                return (val || '') + ' / ' + row.unit;
                                            }
                                            return val || '';
                                        }

                                        function loadLiveStock() {
                                            var url = ctx + '/ReportServlet?action=listLiveStock&lab_id=' + labId;
                                            $('#liveStockDatagrid').datagrid({
                                                url: url,
                                                loadFilter: function (data) {
                                                    return { total: data.length, rows: data };
                                                },
                                                rowStyler: function (index, row) {
                                                    if (row.is_dangerous === 1) {
                                                        return 'background:#ffebee;';
                                                    }
                                                    return '';
                                                }
                                            });
                                        }

                                        /* ===== 溯源追踪 ===== */
                                        function openTrace(consumableId, consumableName) {
                                            $('#traceConsumableName').text(consumableName);
                                            $('#traceTimeline').html('<div style="padding:40px 20px;text-align:center;color:#90a4ae;">加载中...</div>');
                                            $('#traceModal').dialog('open');

                                            $.getJSON(ctx + '/ReportServlet?action=getTraceability&consumable_id=' + consumableId, function (data) {
                                                if (!data || data.length === 0) {
                                                    $('#traceTimeline').html('<div style="padding:40px 20px;text-align:center;color:#90a4ae;">暂无溯源数据</div>');
                                                    return;
                                                }
                                                var html = '';
                                                data.forEach(function (item) {
                                                    var icon, title;
                                                    switch (item.type) {
                                                        case 'purchase':
                                                            icon = '📋';
                                                            title = '采购计划';
                                                            break;
                                                        case 'inbound':
                                                            icon = '📥';
                                                            title = '入库登记';
                                                            break;
                                                        case 'outbound':
                                                            icon = '📤';
                                                            title = '领用出库';
                                                            break;
                                                        case 'return':
                                                            icon = '↩️';
                                                            title = '归还登记';
                                                            break;
                                                        case 'scrap':
                                                            icon = '🗑️';
                                                            title = '报废登记';
                                                            break;
                                                        default:
                                                            icon = '📝';
                                                            title = '操作记录';
                                                    }
                                                    var time = item.time ? String(item.time).replace('T', ' ') : '';
                                                    html += '<div class="trace-item">'
                                                        + '<div class="trace-icon ' + item.type + '">' + icon + '</div>'
                                                        + '<div class="trace-content">'
                                                        + '<div class="trace-title">' + title + '</div>'
                                                        + '<div class="trace-meta">'
                                                        + (item.operator ? '操作人：' + item.operator : '')
                                                        + (item.qty ? '　数量：' + item.qty : '')
                                                        + (time ? '　时间：' + time : '')
                                                        + '</div>'
                                                        + '<div class="trace-desc">' + item.description + '</div>'
                                                        + '</div>'
                                                        + '</div>';
                                                });
                                                $('#traceTimeline').html(html);
                                            }).fail(function () {
                                                $('#traceTimeline').html('<div style="padding:40px 20px;text-align:center;color:#e53935;">数据加载失败</div>');
                                            });
                                        }

                                        function closeTrace() {
                                            $('#traceModal').dialog('close');
                                        }
                                    </script>

                                    <!-- ===== 实验室管理员首页 HTML ===== -->
                                    <div class="home-wrap" id="homeWrap">
                                        <!-- 主内容区 -->
                                        <div class="home-main" id="homeMain">

                                            <!-- 公告栏 -->
                                            <div class="notice-bar">
                                                <div class="notice-bar-head" onclick="toggleNotice()">
                                                    <span class="notice-bar-title">📢 系统公告</span>
                                                    <span style="display:flex;align-items:center;gap:8px;">
                                                        <span id="noticeToggleIcon"
                                                            style="color:#90a4ae;font-size:12px;">▼
                                                            展开</span>
                                                    </span>
                                                </div>
                                                <div class="notice-bar-body" id="noticeBody">
                                                    <div id="noticeList"><span
                                                            style="color:#b0bec5;font-size:13px;">加载中...</span></div>
                                                </div>
                                            </div>

                                            <!-- 实验室信息 -->
                                            <div class="workbench-card">
                                                <div
                                                    style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;">
                                                    <h3 style="color:#1565c0;margin:0;">实验室管理工作台</h3>
                                                    <button onclick="labRefresh()"
                                                        style="font-size:12px;background:#e3f2fd;color:#1976d2;border:1px solid #90caf9;border-radius:4px;padding:4px 12px;cursor:pointer;">🔄
                                                        刷新数据</button>
                                                </div>
                                                <p style="color:#546e7a;margin-bottom:8px;">
                                                    请使用左侧菜单完成采购计划填报、入库/出库、领用审核、归还审核、报废管理及库存盘点等业务。</p>
                                            </div>

                                            <!-- KPI 指标 - 第一行 -->
                                            <div class="kpi-row">
                                                <div class="kpi-card">
                                                    <div class="kpi-icon">📦</div>
                                                    <div class="kpi-label">当前库存种类</div>
                                                    <div class="kpi-value" id="labKpiKinds">—</div>
                                                    <div class="kpi-unit">种（库存 > 0）</div>
                                                </div>
                                                <div class="kpi-card warn">
                                                    <div class="kpi-icon">⚠</div>
                                                    <div class="kpi-label">库存预警数</div>
                                                    <div class="kpi-value" id="labKpiWarn">—</div>
                                                    <div class="kpi-unit">种（库存 ≤ 预警值）</div>
                                                </div>
                                                <div class="kpi-card">
                                                    <div class="kpi-icon">📤</div>
                                                    <div class="kpi-label">待审核领用</div>
                                                    <div class="kpi-value" id="labKpiPendingOutbound">—</div>
                                                    <div class="kpi-unit">条</div>
                                                </div>
                                                <div class="kpi-card info">
                                                    <div class="kpi-icon">📥</div>
                                                    <div class="kpi-label">待审核归还</div>
                                                    <div class="kpi-value" id="labKpiPendingReturn">—</div>
                                                    <div class="kpi-unit">条</div>
                                                </div>
                                            </div>

                                            <!-- KPI 指标 - 第二行 -->
                                            <div class="kpi-row">
                                                <div class="kpi-card ok">
                                                    <div class="kpi-icon">📥</div>
                                                    <div class="kpi-label">本月入库总量</div>
                                                    <div class="kpi-value" id="labKpiInbound">—</div>
                                                    <div class="kpi-unit">件</div>
                                                </div>
                                                <div class="kpi-card">
                                                    <div class="kpi-icon">📤</div>
                                                    <div class="kpi-label">本月出库总量</div>
                                                    <div class="kpi-value" id="labKpiOutbound">—</div>
                                                    <div class="kpi-unit">件</div>
                                                </div>
                                                <div class="kpi-card" style="flex:2;">
                                                    <div class="kpi-icon">⚡</div>
                                                    <div class="kpi-label">快速操作</div>
                                                    <div style="display:flex;gap:8px;margin-top:8px;">
                                                        <button
                                                            onclick="openLabTab('采购计划填报','purchase/purchasePlanList.jsp')"
                                                            style="font-size:11px;background:#e3f2fd;color:#1976d2;border:1px solid #90caf9;border-radius:4px;padding:4px 10px;cursor:pointer;">采购计划</button>
                                                        <button onclick="openLabTab('入库登记','inbound/inboundList.jsp')"
                                                            style="font-size:11px;background:#e8f5e8;color:#43a047;border:1px solid #a5d6a7;border-radius:4px;padding:4px 10px;cursor:pointer;">入库登记</button>
                                                        <button
                                                            onclick="openLabTab('出库登记','outbound/outboundDirect.jsp')"
                                                            style="font-size:11px;background:#fff3e0;color:#f57c00;border:1px solid #ffcc80;border-radius:4px;padding:4px 10px;cursor:pointer;">出库登记</button>
                                                        <button
                                                            onclick="openLabTab('领用申请审核','outbound/outboundAudit.jsp')"
                                                            style="font-size:11px;background:#f3e5f5;color:#8e24aa;border:1px solid #ce93d8;border-radius:4px;padding:4px 10px;cursor:pointer;">领用审核</button>
                                                        <button onclick="openLabTab('反馈管理','admin/feedbackManage.jsp')"
                                                            style="font-size:11px;background:#fce4ec;color:#c62828;border:1px solid #ef9a9a;border-radius:4px;padding:4px 10px;cursor:pointer;position:relative;">
                                                            反馈管理
                                                            <span id="labFeedbackBadge"
                                                                style="display:none;position:absolute;top:-6px;right:-6px;background:#e53935;color:#fff;border-radius:50%;width:16px;height:16px;font-size:10px;line-height:16px;text-align:center;font-weight:bold;"></span>
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- 补货预警 + 危化品合规预警 并排 -->
                                            <div style="display:flex;gap:12px;margin-bottom:12px;">
                                                <!-- 补货预警 -->
                                                <div class="warning-card replenish" style="flex:1;">
                                                    <div class="warning-head">
                                                        <span class="warning-head-title">🟠 补货预警（常规耗材库存低于安全值）</span>
                                                        <a href="javascript:void(0)"
                                                            onclick="openLabTab('采购计划填报','purchase/purchasePlanList.jsp')"
                                                            style="font-size:12px;color:#e65100;">去采购 →</a>
                                                    </div>
                                                    <div class="warning-body" id="labReplenishBody">
                                                        <div
                                                            style="padding:12px 0;color:#b0bec5;font-size:13px;text-align:center;">
                                                            加载中...</div>
                                                    </div>
                                                </div>
                                                <!-- 危化品合规预警 -->
                                                <div class="warning-card danger" style="flex:1;">
                                                    <div class="warning-head">
                                                        <span class="warning-head-title">🔴 危化品合规预警（库存超过最高合规库存）</span>
                                                        <a href="javascript:void(0)"
                                                            onclick="openLabDangerWarningDetail()"
                                                            style="font-size:12px;color:#c62828;">查看更多 →</a>
                                                    </div>
                                                    <div class="warning-body" id="labDangerBody">
                                                        <div
                                                            style="padding:12px 0;color:#b0bec5;font-size:13px;text-align:center;">
                                                            加载中...</div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- 未处理反馈待办卡片 -->
                                            <div class="kpi-row">
                                                <div class="kpi-card" style="border-top-color:#e53935;cursor:pointer;"
                                                    onclick="openLabTab('反馈管理','admin/feedbackManage.jsp')">
                                                    <div class="kpi-icon">💬</div>
                                                    <div class="kpi-label">未处理反馈</div>
                                                    <div class="kpi-value" id="labKpiFeedback" style="color:#e53935;">—
                                                    </div>
                                                    <div class="kpi-unit">条（点击处理）</div>
                                                </div>
                                            </div>

                                            <!-- 图表区域：高频流动漏斗图 + 危化品雷达图 -->
                                            <div style="display:flex;gap:12px;margin-bottom:12px;">
                                                <!-- 高频流动漏斗图 -->
                                                <div class="chart-card" style="flex:1;">
                                                    <div class="chart-head">
                                                        <span class="chart-head-title">近30天高频流动耗材榜
                                                            <span
                                                                style="font-size:11px;color:#90a4ae;margin-left:6px;">按领用频次排序，前5名</span>
                                                        </span>
                                                        <div style="display:flex;gap:8px;">
                                                            <button onclick="exportHighFrequency()"
                                                                style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">导出PNG</button>
                                                            <button onclick="refreshHighFrequency()"
                                                                style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">刷新</button>
                                                        </div>
                                                    </div>
                                                    <div style="padding:6px 10px 10px;">
                                                        <div id="highFrequencyChart" style="height:260px;"></div>
                                                    </div>
                                                </div>

                                                <!-- 危化品库存监控雷达图 -->
                                                <div class="chart-card" style="flex:1;">
                                                    <div class="chart-head">
                                                        <span class="chart-head-title">危化品库存监控
                                                            <span
                                                                style="font-size:11px;color:#90a4ae;margin-left:6px;">当前库存
                                                                vs 最高合规库存</span>
                                                        </span>
                                                        <div style="display:flex;gap:8px;">
                                                            <button onclick="exportDangerStock()"
                                                                style="font-size:11px;color:#e53935;background:#ffebee;border:1px solid #ef9a9a;border-radius:4px;padding:2px 8px;cursor:pointer;">导出PNG</button>
                                                            <button onclick="refreshDangerStock()"
                                                                style="font-size:11px;color:#e53935;background:#ffebee;border:1px solid #ef9a9a;border-radius:4px;padding:2px 8px;cursor:pointer;">刷新</button>
                                                        </div>
                                                    </div>
                                                    <div style="padding:6px 10px 10px;">
                                                        <div id="dangerStockChart" style="height:260px;"></div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- 实时库存台账 -->
                                            <div class="stock-card">
                                                <div class="stock-header">
                                                    <span class="stock-title">📦 实时库存台账（当前库存 > 0）</span>
                                                    <button onclick="loadLiveStock()"
                                                        style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">刷新数据</button>
                                                </div>
                                                <table id="liveStockDatagrid" class="easyui-datagrid"
                                                    style="width:100%;height:380px;" singleSelect="true"
                                                    pagination="false" rownumbers="true">
                                                    <thead>
                                                        <tr>
                                                            <th field="consumable_name" width="180"
                                                                formatter="formatConsumableName">耗材名称</th>
                                                            <th field="category" width="100">类别</th>
                                                            <th field="spec" width="120" formatter="formatSpec">规格/单位
                                                            </th>
                                                            <th field="current_qty" width="120"
                                                                formatter="formatCurrentQty">当前库存</th>
                                                            <th field="min_safe_stock" width="100">最低安全库存</th>
                                                            <th field="max_limit_stock" width="100">最高合规库存</th>
                                                            <th field="action" width="100" align="center"
                                                                formatter="formatAction">操作</th>
                                                        </tr>
                                                    </thead>
                                                </table>
                                            </div>

                                        </div><!-- /home-main -->

                                        <!-- 可折叠侧边栏（默认收起） -->
                                        <div class="guide-sidebar" id="guideSidebar">
                                            <div class="guide-inner">
                                                <div class="guide-title">📖 实验室管理员指南</div>
                                                <div class="guide-section">
                                                    <h4>日常工作流程</h4>
                                                    <ol>
                                                        <li>采购计划填报</li>
                                                        <li>入库登记</li>
                                                        <li>出库登记</li>
                                                        <li>领用申请审核</li>
                                                        <li>归还登记审核</li>
                                                        <li>报废登记</li>
                                                        <li>库存盘点</li>
                                                        <li>反馈管理</li>
                                                    </ol>
                                                </div>
                                                <div class="guide-section">
                                                    <h4>库存管理建议</h4>
                                                    <ul>
                                                        <li>定期检查库存预警项</li>
                                                        <li>及时处理过期耗材</li>
                                                        <li>保持库存记录与实物一致</li>
                                                        <li>优化采购计划，避免积压</li>
                                                    </ul>
                                                </div>
                                                <div class="guide-section">
                                                    <h4>危险化学品管理</h4>
                                                    <div class="danger-tip">
                                                        ⚠ 危化品领用需经过<strong>双人审批</strong>，出库前必须完成二审。请确保危化品存储符合安全要求。
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- 公告详情弹窗 -->
                                        <div class="modal-mask" id="noticeDetailModal">
                                            <div class="modal-box">
                                                <div class="modal-head">
                                                    <span id="noticeDetailTitle">公告详情</span>
                                                    <button class="modal-close" onclick="closeNoticeDetail()">✕</button>
                                                </div>
                                                <div class="modal-body">
                                                    <div id="noticeDetailMeta"
                                                        style="font-size:12px;color:#90a4ae;margin-bottom:12px;"></div>
                                                    <div id="noticeDetailContent"
                                                        style="font-size:13px;color:#37474f;line-height:1.8;white-space:pre-wrap;">
                                                    </div>
                                                </div>
                                                <div class="modal-foot">
                                                    <button class="modal-btn" onclick="closeNoticeDetail()">关闭</button>
                                                </div>
                                            </div>
                                        </div>

                                    </div><!-- /home-wrap -->

                                    <!-- 侧边栏切换按钮 -->
                                    <button class="guide-toggle" id="guideToggleBtn"
                                        onclick="toggleGuide()">使用指南</button>

                                    <!-- 刷新提示（居中） -->
                                    <div class="refresh-toast" id="labRefreshToast">✔ 数据已刷新</div>

                                    <!-- 危化品合规预警详情弹窗 -->
                                    <div class="modal-mask" id="labDangerWarningDetailModal">
                                        <div class="modal-box" style="width:700px;">
                                            <div class="modal-head">
                                                <span>危化品合规预警详情</span>
                                                <button class="modal-close"
                                                    onclick="closeLabDangerWarningDetail()">✕</button>
                                            </div>
                                            <div class="modal-body">
                                                <div id="labDangerWarningDetailContent"></div>
                                            </div>
                                            <div class="modal-foot">
                                                <button class="modal-btn"
                                                    onclick="closeLabDangerWarningDetail()">关闭</button>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 溯源追踪弹窗 -->
                                    <div id="traceModal" class="easyui-dialog" title="🔍 溯源追踪"
                                        style="width:700px;height:550px;padding:10px;" closed="true" modal="true">
                                        <div class="trace-modal-content">
                                            <div class="trace-header" id="traceConsumableName"
                                                style="font-size:16px;font-weight:bold;color:#1565c0;margin-bottom:15px;padding-bottom:10px;border-bottom:1px solid #e3eaf5;">
                                                耗材名称</div>
                                            <div id="traceTimeline" class="trace-timeline"
                                                style="max-height:420px;overflow-y:auto;"></div>
                                        </div>
                                    </div>

                                    <% }else if(isTeacher){ %>
                                        <!-- ===== 教师首页 JS ===== -->
                                        <script>
                                            var ctx = '<%=request.getContextPath()%>';
                                            var teacherUserId = <%=loginUserId != null ? loginUserId : "null" %>;
                                            var teacherTopChart = null;

                                            /* ===== 静态公告数据（与系统管理员一致，按日期倒序） ===== */
                                            var STATIC_NOTICES = [
                                                {
                                                    title: '关于启用耗材管理系统新版本的通知', date: '2026-04-01', publisher: '信息化管理办公室',
                                                    content: '耗材管理系统已完成升级，新版本新增库存健康度评分、审批超时预警、数据统计分析等功能。如使用过程中遇到问题，请联系实验室管理办公室或通过系统反馈功能提交。'
                                                },
                                                {
                                                    title: '2026年度实验室耗材库存盘点工作安排', date: '2026-03-25', publisher: '实验室管理中心',
                                                    content: '定于2026年4月10日至4月12日开展年度库存盘点工作。各实验室管理员须在系统中完成盘点登记，盘点须由两人共同完成并签字确认，盘点结果将作为下一年度采购预算依据。'
                                                },
                                                {
                                                    title: '关于规范耗材领用审批流程的通知', date: '2026-03-18', publisher: '计算机实验教学中心',
                                                    content: '为进一步规范耗材管理，自2026年4月1日起，所有耗材领用申请须提前24小时提交，危险化学品领用须完成双人审批后方可出库。请各教师知悉并配合执行。'
                                                },
                                                {
                                                    title: '危险化学品安全管理专项检查通知', date: '2026-03-10', publisher: '安全管理办公室',
                                                    content: '根据学校安全工作部署，将于2026年3月20日至3月25日开展危险化学品专项安全检查。请各实验室确保危化品台账完整、双人双锁落实到位，系统中出入库记录与实物一致。'
                                                },
                                                {
                                                    title: '关于2026年春季学期实验耗材申购计划填报的通知', date: '2026-03-01', publisher: '实验室管理中心',
                                                    content: '各实验室管理员：请于2026年3月15日前完成春季学期耗材申购计划填报，逾期将影响采购审批进度。填报时请注意危险化学品须单独列明存储要求，并严格执行"五双管理"制度。'
                                                }
                                            ];

                                            function toggleNotice() {
                                                var body = document.getElementById('noticeBody');
                                                var icon = document.getElementById('noticeToggleIcon');
                                                if (body.classList.contains('open')) { body.classList.remove('open'); icon.textContent = '▼ 展开'; }
                                                else { body.classList.add('open'); icon.textContent = '▲ 收起'; }
                                            }
                                            function showNoticeDetail(i) {
                                                var n = STATIC_NOTICES[i];
                                                document.getElementById('noticeDetailTitle').textContent = n.title;
                                                document.getElementById('noticeDetailMeta').textContent = '发布人：' + n.publisher + '　时间：' + n.date;
                                                document.getElementById('noticeDetailContent').textContent = n.content;
                                                document.getElementById('noticeDetailModal').classList.add('show');
                                            }
                                            function closeNoticeDetail() { document.getElementById('noticeDetailModal').classList.remove('show'); }

                                            function renderStaticNotices() {
                                                var html = '';
                                                STATIC_NOTICES.forEach(function (n, i) {
                                                    html += '<div class="notice-item">'
                                                        + '<div style="display:flex;align-items:center;justify-content:space-between;">'
                                                        + '<div class="n-title">' + n.title + '</div>'
                                                        + '<a href="javascript:void(0)" onclick="showNoticeDetail(' + i + ')" style="font-size:11px;color:#1976d2;white-space:nowrap;margin-left:10px;">查看详情</a>'
                                                        + '</div>'
                                                        + '<div class="n-meta">发布人：' + n.publisher + '&nbsp;&nbsp;时间：' + n.date + '</div>'
                                                        + '</div>';
                                                });
                                                document.getElementById('noticeList').innerHTML = html || '<div style="color:#b0bec5;font-size:13px;">暂无公告</div>';
                                            }

                                            function loadTeacherDashboard() {
                                                if (!teacherUserId) return;
                                                $.getJSON(ctx + '/ReportServlet?action=teacherDashboard&user_id=' + teacherUserId, function (d) {
                                                    document.getElementById('tKpiTotal').textContent = d.myTotal || 0;
                                                    document.getElementById('tKpiPending').textContent = d.myPending || 0;
                                                    document.getElementById('tKpiDone').textContent = d.myDone || 0;
                                                    document.getElementById('tKpiRejected').textContent = d.myRejected || 0;
                                                    document.getElementById('tKpiReturn').textContent = d.myReturnTotal || 0;
                                                    document.getElementById('tKpiReturnPending').textContent = d.myReturnPending || 0;
                                                    document.getElementById('tKpiFeedback').textContent = d.myFeedbackTotal || 0;

                                                    // 待审核徽章
                                                    var pendingBadge = document.getElementById('tPendingBadge');
                                                    if (d.myPending > 0) {
                                                        pendingBadge.textContent = d.myPending + ' 条待审核';
                                                        pendingBadge.style.display = 'inline-block';
                                                    } else {
                                                        pendingBadge.style.display = 'none';
                                                    }

                                                    // 最近领用记录
                                                    var orders = d.recentOrders || [];
                                                    var html = '';
                                                    if (orders.length === 0) {
                                                        html = '<div style="padding:14px 0;color:#b0bec5;font-size:13px;text-align:center;">暂无领用记录</div>';
                                                    } else {
                                                        orders.forEach(function (o) {
                                                            var statusMap = {
                                                                '-1': '<span style="color:#78909c;font-weight:bold;">草稿</span>',
                                                                0: '<span style="color:#FF9800;font-weight:bold;">待审核</span>',
                                                                1: '<span style="color:#2196F3;font-weight:bold;">初审通过</span>',
                                                                2: '<span style="color:#e53935;font-weight:bold;">已驳回</span>',
                                                                3: '<span style="color:#43a047;font-weight:bold;">已出库</span>',
                                                                4: '<span style="color:#7b1fa2;font-weight:bold;">二审通过</span>'
                                                            };
                                                            var st = statusMap[o.status] || o.status;
                                                            var ct = o.create_time ? String(o.create_time).substring(0, 16) : '—';
                                                            html += '<div class="overdue-item">'
                                                                + '<span><b style="color:#1565c0;">' + o.id + '</b>&nbsp;&nbsp;'
                                                                + (o.purpose || '—') + '&nbsp;&nbsp;<span style="color:#90a4ae;font-size:11px;">' + (o.lab_name || '') + '</span></span>'
                                                                + '<span>' + st + '&nbsp;&nbsp;<span style="color:#b0bec5;font-size:11px;">' + ct + '</span></span>'
                                                                + '</div>';
                                                        });
                                                    }
                                                    document.getElementById('tRecentOrders').innerHTML = html;

                                                    // 我的常用耗材 Top 5 横向柱状图
                                                    var topData = d.myTopConsumables || [];
                                                    if (teacherTopChart && topData.length > 0) {
                                                        var names = topData.map(function (item) { return item.name; });
                                                        var quantities = topData.map(function (item) {
                                                            var q = item.quantity;
                                                            return q ? Number(q) : 0;
                                                        });
                                                        teacherTopChart.setOption({
                                                            tooltip: {
                                                                trigger: 'axis',
                                                                axisPointer: { type: 'shadow' }
                                                            },
                                                            grid: {
                                                                left: '3%',
                                                                right: '4%',
                                                                bottom: '3%',
                                                                top: '3%',
                                                                containLabel: true
                                                            },
                                                            xAxis: {
                                                                type: 'value',
                                                                axisLabel: { fontSize: 11 }
                                                            },
                                                            yAxis: {
                                                                type: 'category',
                                                                data: names.reverse(),
                                                                axisLabel: { fontSize: 11 }
                                                            },
                                                            series: [{
                                                                type: 'bar',
                                                                data: quantities.reverse(),
                                                                itemStyle: {
                                                                    color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
                                                                        { offset: 0, color: '#1976d2' },
                                                                        { offset: 1, color: '#42a5f5' }
                                                                    ])
                                                                },
                                                                label: {
                                                                    show: true,
                                                                    position: 'right',
                                                                    fontSize: 11
                                                                }
                                                            }]
                                                        });
                                                    } else if (teacherTopChart) {
                                                        teacherTopChart.setOption({
                                                            title: {
                                                                text: '暂无领用记录',
                                                                left: 'center',
                                                                top: 'middle',
                                                                textStyle: { color: '#b0bec5', fontSize: 13 }
                                                            }
                                                        });
                                                    }
                                                }).fail(function () {
                                                    ['tKpiTotal', 'tKpiPending', 'tKpiDone', 'tKpiRejected', 'tKpiReturn', 'tKpiReturnPending', 'tKpiFeedback'].forEach(function (id) { document.getElementById(id).textContent = '—'; });
                                                });
                                            }

                                            function openTeacherTab(title, url) {
                                                openFuncPage(title, url);
                                                $('a.nav-item[data-url]').each(function () {
                                                    if ($(this).text().trim() === title) { $('a.nav-item').removeClass('active'); $(this).addClass('active'); }
                                                });
                                            }

                                            function showTeacherToast(msg) {
                                                var t = document.getElementById('teacherRefreshToast');
                                                t.textContent = msg || '✔ 数据已刷新';
                                                t.style.display = 'block';
                                                setTimeout(function () { t.style.display = 'none'; }, 1800);
                                            }

                                            /* ===== 导出教师常用耗材 PNG ===== */
                                            function exportTeacherTop() {
                                                if (!teacherTopChart) { alert('图表尚未加载，请稍后再试'); return; }
                                                var url = teacherTopChart.getDataURL({ type: 'png', pixelRatio: 2, backgroundColor: '#fff' });
                                                var a = document.createElement('a');
                                                a.href = url; a.download = '我的常用耗材Top5.png'; a.click();
                                            }

                                            /* ===== 刷新教师图表 ===== */
                                            function refreshTeacherTop() {
                                                loadTeacherDashboard();
                                                showTeacherToast('✔ 数据已刷新');
                                            }

                                            function toggleTeacherGuide() {
                                                document.getElementById('teacherGuideSidebar').classList.toggle('open');
                                            }

                                            $(function () {
                                                var el = document.getElementById('teacherTopChart');
                                                if (el && typeof echarts !== 'undefined') {
                                                    teacherTopChart = echarts.init(el);
                                                }
                                                loadTeacherDashboard();
                                                renderStaticNotices();
                                                window.addEventListener('resize', function () { if (teacherTopChart) teacherTopChart.resize(); });
                                            });

                                            window.teacherRefresh = function () {
                                                loadTeacherDashboard();
                                                showTeacherToast('✔ 数据已刷新');
                                            };
                                        </script>

                                        <!-- ===== 教师首页 HTML ===== -->
                                        <div class="home-wrap" id="teacherHomeWrap">
                                            <div class="home-main" id="teacherHomeMain">

                                                <!-- 公告栏 -->
                                                <div class="notice-bar">
                                                    <div class="notice-bar-head" onclick="toggleNotice()">
                                                        <span class="notice-bar-title">📢 系统公告</span>
                                                        <span id="noticeToggleIcon"
                                                            style="color:#90a4ae;font-size:12px;">▼ 展开</span>
                                                    </div>
                                                    <div class="notice-bar-body" id="noticeBody">
                                                        <div id="noticeList"><span
                                                                style="color:#b0bec5;font-size:13px;">加载中...</span>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- 公告详情弹窗 -->
                                                <div class="modal-mask" id="noticeDetailModal">
                                                    <div class="modal-box">
                                                        <div class="modal-head">
                                                            <span id="noticeDetailTitle">公告详情</span>
                                                            <button class="modal-close"
                                                                onclick="closeNoticeDetail()">✕</button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div id="noticeDetailMeta"
                                                                style="font-size:12px;color:#90a4ae;margin-bottom:12px;">
                                                            </div>
                                                            <div id="noticeDetailContent"
                                                                style="font-size:13px;color:#37474f;line-height:1.8;white-space:pre-wrap;">
                                                            </div>
                                                        </div>
                                                        <div class="modal-foot">
                                                            <button class="modal-btn"
                                                                onclick="closeNoticeDetail()">关闭</button>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- KPI 第一行：领用申请统计 -->
                                                <div
                                                    style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;">
                                                    <span style="font-size:13px;font-weight:bold;color:#1565c0;">📋
                                                        数据总览</span>
                                                    <span id="tPendingBadge"
                                                        style="display:none;background:#e53935;color:#fff;border-radius:10px;padding:2px 10px;font-size:11px;font-weight:bold;"></span>
                                                </div>
                                                <div class="kpi-row">
                                                    <div class="kpi-card"
                                                        onclick="openTeacherTab('领用申请管理','teacher/outboundManage.jsp')"
                                                        style="cursor:pointer;">
                                                        <div class="kpi-icon">📋</div>
                                                        <div class="kpi-label">领用申请总数</div>
                                                        <div class="kpi-value" id="tKpiTotal">—</div>
                                                        <div class="kpi-unit">条</div>
                                                    </div>
                                                    <div class="kpi-card warn"
                                                        onclick="openTeacherTab('领用申请管理','teacher/outboundManage.jsp')"
                                                        style="cursor:pointer;">
                                                        <div class="kpi-icon">⏳</div>
                                                        <div class="kpi-label">待审核领用申请</div>
                                                        <div class="kpi-value" id="tKpiPending">—</div>
                                                        <div class="kpi-unit">条</div>
                                                    </div>
                                                    <div class="kpi-card ok"
                                                        onclick="openTeacherTab('领用申请管理','teacher/outboundManage.jsp')"
                                                        style="cursor:pointer;">
                                                        <div class="kpi-icon">✅</div>
                                                        <div class="kpi-label">已出库</div>
                                                        <div class="kpi-value" id="tKpiDone">—</div>
                                                        <div class="kpi-unit">条</div>
                                                    </div>
                                                    <div class="kpi-card" style="border-top-color:#e53935;"
                                                        onclick="openTeacherTab('领用申请管理','teacher/outboundManage.jsp')"
                                                        style="cursor:pointer;">
                                                        <div class="kpi-icon">❌</div>
                                                        <div class="kpi-label">已驳回领用申请</div>
                                                        <div class="kpi-value" id="tKpiRejected" style="color:#e53935;">
                                                            —</div>
                                                        <div class="kpi-unit">条</div>
                                                    </div>
                                                </div>

                                                <!-- KPI 第二行：归还 + 反馈 + 快捷操作 -->
                                                <div class="kpi-row">
                                                    <div class="kpi-card info"
                                                        onclick="openTeacherTab('归还登记','return/returnApply.jsp')"
                                                        style="cursor:pointer;">
                                                        <div class="kpi-icon">↩️</div>
                                                        <div class="kpi-label">归还记录总数</div>
                                                        <div class="kpi-value" id="tKpiReturn">—</div>
                                                        <div class="kpi-unit">条</div>
                                                    </div>
                                                    <div class="kpi-card warn"
                                                        onclick="openTeacherTab('归还登记','return/returnApply.jsp')"
                                                        style="cursor:pointer;">
                                                        <div class="kpi-icon">⏳</div>
                                                        <div class="kpi-label">待审核归还</div>
                                                        <div class="kpi-value" id="tKpiReturnPending">—</div>
                                                        <div class="kpi-unit">条</div>
                                                    </div>
                                                    <div class="kpi-card ok"
                                                        onclick="openTeacherTab('使用反馈','teacher/usageFeedback.jsp')"
                                                        style="cursor:pointer;">
                                                        <div class="kpi-icon">💬</div>
                                                        <div class="kpi-label">已提交反馈</div>
                                                        <div class="kpi-value" id="tKpiFeedback">—</div>
                                                        <div class="kpi-unit">条</div>
                                                    </div>
                                                    <div class="kpi-card" style="border-top-color:#1976d2;flex:1.2;">
                                                        <div class="kpi-icon">⚡</div>
                                                        <div class="kpi-label">快速操作</div>
                                                        <div
                                                            style="display:flex;gap:6px;margin-top:8px;flex-wrap:wrap;">
                                                            <button
                                                                onclick="openTeacherTab('领用申请管理','teacher/outboundManage.jsp')"
                                                                style="font-size:11px;background:#e3f2fd;color:#1976d2;border:1px solid #90caf9;border-radius:4px;padding:4px 10px;cursor:pointer;">📋
                                                                领用申请</button>
                                                            <button
                                                                onclick="openTeacherTab('归还登记','return/returnApply.jsp')"
                                                                style="font-size:11px;background:#e8f5e8;color:#43a047;border:1px solid #a5d6a7;border-radius:4px;padding:4px 10px;cursor:pointer;">↩️
                                                                归还登记</button>
                                                            <button
                                                                onclick="openTeacherTab('使用反馈','teacher/usageFeedback.jsp')"
                                                                style="font-size:11px;background:#f3e5f5;color:#8e24aa;border:1px solid #ce93d8;border-radius:4px;padding:4px 10px;cursor:pointer;">💬
                                                                使用反馈</button>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- 最近领用记录 + 常用耗材图表 并排 -->
                                                <div style="display:flex;gap:12px;margin-bottom:12px;">
                                                    <!-- 最近领用记录 -->
                                                    <div class="overdue-card" style="flex:1.3;">
                                                        <div class="overdue-head" style="background:#e3f2fd;">
                                                            <span class="overdue-head-title" style="color:#1565c0;">📄
                                                                最近领用记录（最新5条）</span>
                                                            <a href="javascript:void(0)"
                                                                onclick="openTeacherTab('领用申请管理','teacher/outboundManage.jsp')"
                                                                style="font-size:12px;color:#1565c0;">查看全部 →</a>
                                                        </div>
                                                        <div class="overdue-body" id="tRecentOrders">
                                                            <div
                                                                style="padding:12px 0;color:#b0bec5;font-size:13px;text-align:center;">
                                                                加载中...</div>
                                                        </div>
                                                    </div>
                                                    <!-- 我的常用耗材 Top 5 -->
                                                    <div class="chart-card" style="flex:1;margin-bottom:0;">
                                                        <div class="chart-head">
                                                            <span class="chart-head-title">我的常用耗材 Top 5
                                                                <span
                                                                    style="font-size:11px;color:#90a4ae;margin-left:4px;">按累计领用数量统计</span>
                                                            </span>
                                                            <div style="display:flex;gap:8px;">
                                                                <button onclick="exportTeacherTop()"
                                                                    style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">导出PNG</button>
                                                                <button onclick="refreshTeacherTop()"
                                                                    style="font-size:11px;color:#1976d2;background:#e3f2fd;border:1px solid #90caf9;border-radius:4px;padding:2px 8px;cursor:pointer;">刷新</button>
                                                            </div>
                                                        </div>
                                                        <div style="padding:6px 10px 10px;">
                                                            <div id="teacherTopChart" style="height:220px;"></div>
                                                        </div>
                                                    </div>
                                                </div>

                                            </div><!-- /home-main -->

                                            <!-- 可折叠侧边栏 -->
                                            <div class="guide-sidebar" id="teacherGuideSidebar">
                                                <div style="padding:14px 16px;overflow-y:auto;height:100%;">
                                                    <div class="guide-title">📖 教师使用指南</div>
                                                    <div class="guide-section">
                                                        <h4>领用申请流程</h4>
                                                        <ul>
                                                            <li>1. 点击「领用申请管理」</li>
                                                            <li>2. 填写课程、班级、用途</li>
                                                            <li>3. 添加所需耗材明细</li>
                                                            <li>4. 提交后等待管理员审核</li>
                                                            <li>5. 审核通过后凭单领取</li>
                                                        </ul>
                                                    </div>
                                                    <div class="guide-section">
                                                        <h4>归还登记流程</h4>
                                                        <ul>
                                                            <li>1. 点击「归还登记」</li>
                                                            <li>2. 在可归还列表中选择明细</li>
                                                            <li>3. 填写归还数量和使用反馈</li>
                                                            <li>4. 提交后等待管理员确认</li>
                                                        </ul>
                                                    </div>
                                                    <div class="guide-section">
                                                        <h4>使用反馈</h4>
                                                        <ul>
                                                            <li>可对已领用耗材提交质量反馈</li>
                                                            <li>同一领用单仅保留最新一条</li>
                                                            <li>反馈内容不超过500字</li>
                                                        </ul>
                                                    </div>
                                                    <div class="guide-section">
                                                        <h4>危险化学品注意事项</h4>
                                                        <div class="danger-tip">
                                                            ⚠ 危化品领用需经过<strong>双人审批</strong>，请提前申请并配合管理员完成二审流程。
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div><!-- /home-wrap -->

                                        <!-- 侧边栏切换按钮 -->
                                        <button class="guide-toggle" id="teacherGuideToggleBtn"
                                            onclick="toggleTeacherGuide()">使用指南</button>

                                        <!-- 刷新提示 -->
                                        <div class="refresh-toast" id="teacherRefreshToast">✔ 数据已刷新</div>
                                        <% }else{ %>
                                            <div style="padding:16px;">
                                                <p style="color:#c62828;">当前账号角色未识别，请联系管理员配置角色。</p>
                                            </div>
                                            <% } %>
                        </div><!-- /首页内容 -->
                    </div><!-- /homePanel -->
                    <!-- 功能页 iframe 覆盖区 -->
                    <div id="funcPanel" style="display:none;height:calc(100% - 36px);overflow:hidden;">
                        <iframe id="funcFrame" src="" frameborder="0" scrolling="auto"
                            style="width:100%;height:100%;border:none;"></iframe>
                    </div>
                </div><!-- /center -->

                <script>
                    /* ===== 单页覆盖模式 ===== */
                    function showHomePage() {
                        $('#funcPanel').hide();
                        $('#homePanel').show();
                        $('#funcFrame').attr('src', '');
                        $('#bcSep').hide();
                        $('#bcCur').text('');
                        $('a.nav-item').removeClass('active');
                    }

                    function openFuncPage(title, url) {
                        $('#homePanel').hide();
                        $('#funcFrame').attr('src', url);
                        $('#funcPanel').show();
                        $('#bcSep').show();
                        $('#bcCur').text(title);
                    }

                    $(function () {
                        // 新导航菜单点击（.nav-item）
                        $('a.nav-item[data-url]').click(function (e) {
                            e.preventDefault();
                            var title = $(this).text().trim();
                            var url = $(this).data('url');
                            $('a.nav-item').removeClass('active');
                            $(this).addClass('active');
                            openFuncPage(title, url);
                        });

                        // 全局 tooltip：鼠标悬浮单元格显示完整内容
                        var $tip = $('<div id="cellTooltip" style="position:fixed;background:rgba(30,40,60,.92);color:#fff;font-size:12px;padding:5px 10px;border-radius:5px;max-width:360px;word-break:break-all;pointer-events:none;z-index:99999;display:none;line-height:1.6;box-shadow:0 2px 8px rgba(0,0,0,.25);"></div>').appendTo('body');
                        $(document).on('mouseover', 'td', function (e) {
                            var text = $(this).text().trim();
                            if (!text || text === '—') return;
                            $tip.text(text).show();
                        }).on('mousemove', 'td', function (e) {
                            $tip.css({ left: e.clientX + 14, top: e.clientY + 14 });
                        }).on('mouseout', 'td', function () {
                            $tip.hide();
                        });

                        // 全局右键复制单元格内容
                        $(document).on('contextmenu', 'td', function (e) {
                            var text = $(this).text().trim();
                            if (!text || text === '—') return;
                            e.preventDefault();
                            if (navigator.clipboard && navigator.clipboard.writeText) {
                                navigator.clipboard.writeText(text).then(function () {
                                    showCopyToast('已复制：' + (text.length > 20 ? text.substring(0, 20) + '…' : text));
                                });
                            } else {
                                var ta = document.createElement('textarea');
                                ta.value = text; document.body.appendChild(ta);
                                ta.select(); document.execCommand('copy'); document.body.removeChild(ta);
                                showCopyToast('已复制：' + (text.length > 20 ? text.substring(0, 20) + '…' : text));
                            }
                        });
                    });

                    function showCopyToast(msg) {
                        var t = document.getElementById('copyToast');
                        if (!t) {
                            t = document.createElement('div');
                            t.id = 'copyToast';
                            t.style.cssText = 'position:fixed;bottom:28px;left:50%;transform:translateX(-50%);background:rgba(21,101,192,.92);color:#fff;border-radius:6px;padding:8px 22px;font-size:13px;z-index:99999;pointer-events:none;transition:opacity .3s;';
                            document.body.appendChild(t);
                        }
                        t.textContent = msg;
                        t.style.opacity = '1';
                        clearTimeout(t._timer);
                        t._timer = setTimeout(function () { t.style.opacity = '0'; }, 1800);
                    }
                </script>
            </body>

        </html>