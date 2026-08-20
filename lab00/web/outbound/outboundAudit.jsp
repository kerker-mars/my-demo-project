<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>领用申请审核</title>
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/default/easyui.css">
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/icon.css">
        <script src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.min.js"></script>
        <script
            src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.easyui.min.js"></script>
        <script
            src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/locale/easyui-lang-zh_CN.js"></script>
        <style>
            html,
            body {
                height: 100%;
                margin: 0;
                font-family: "微软雅黑", sans-serif;
                overflow: hidden;
            }

            .page-header {
                background: linear-gradient(90deg, #1565c0, #1976d2);
                color: #fff;
                padding: 10px 18px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 15px;
                font-weight: bold;
                flex-shrink: 0;
            }

            .page-header .sub {
                font-size: 12px;
                font-weight: normal;
                opacity: .8;
            }

            .filter-bar {
                background: #f8fafc;
                border-bottom: 1px solid #dce6f5;
                padding: 6px 10px;
                display: flex;
                align-items: center;
                gap: 8px;
                flex-wrap: wrap;
            }

            .action-bar {
                background: #fff;
                border-bottom: 1px solid #e8eef7;
                padding: 5px 10px;
                display: flex;
                align-items: center;
                gap: 6px;
                flex-wrap: wrap;
            }

            /* 操作按钮 */
            .btn-pass {
                background: #43a047 !important;
                color: #fff !important;
                border: none !important;
                border-radius: 4px !important;
                font-weight: bold;
            }

            .btn-reject {
                background: #e53935 !important;
                color: #fff !important;
                border: none !important;
                border-radius: 4px !important;
                font-weight: bold;
            }

            .btn-out {
                background: #1976d2 !important;
                color: #fff !important;
                border: none !important;
                border-radius: 4px !important;
                font-weight: bold;
            }

            .btn-danger {
                background: #f57c00 !important;
                color: #fff !important;
                border: none !important;
                border-radius: 4px !important;
                font-weight: bold;
            }

            /* 行内操作按钮 */
            .op-btn {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 3px;
                font-size: 11px;
                font-weight: bold;
                cursor: pointer;
                border: none;
                line-height: 18px;
            }

            .op-pass {
                background: #43a047;
                color: #fff;
            }

            .op-reject {
                background: #e53935;
                color: #fff;
            }

            .op-out {
                background: #1976d2;
                color: #fff;
            }

            .op-danger {
                background: #f57c00;
                color: #fff;
            }

            .op-gray {
                background: #bdbdbd;
                color: #fff;
                cursor: not-allowed;
            }

            .op-label {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 3px;
                font-size: 11px;
                font-weight: bold;
                background: #eeeeee;
                color: #757575;
            }

            /* 状态徽章 - 浅色背景+深色文字 */
            .s0 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #fff3e0;
                color: #e65100;
            }

            .s1 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #e8f5e9;
                color: #2e7d32;
            }

            .s2 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #ffebee;
                color: #c62828;
            }

            .s3 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #e3f2fd;
                color: #1565c0;
            }

            .s4 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #f3e5f5;
                color: #6a1b9a;
            }

            .danger-badge {
                display: inline-block;
                padding: 1px 6px;
                border-radius: 8px;
                font-size: 11px;
                font-weight: bold;
                background: #ffebee;
                color: #c62828;
            }

            /* 双板块 */
            .section-wrap {
                height: 100%;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }

            .section-block {
                display: flex;
                flex-direction: column;
                flex: 1;
                min-height: 0;
                overflow: hidden;
            }

            .section-title-danger {
                background: #fff8e1;
                border-left: 4px solid #f57c00;
                border-bottom: 1px solid #ffe082;
                padding: 5px 12px;
                font-size: 13px;
                font-weight: bold;
                color: #e65100;
                flex-shrink: 0;
            }

            .section-title-normal {
                background: #e3f2fd;
                border-left: 4px solid #1976d2;
                border-bottom: 1px solid #bbdefb;
                padding: 5px 12px;
                font-size: 13px;
                font-weight: bold;
                color: #0d47a1;
                flex-shrink: 0;
            }

            .section-divider {
                height: 6px;
                background: #eceff1;
                flex-shrink: 0;
            }

            /* 明细面板 */
            .detail-panel {
                padding: 0;
                height: 100%;
                box-sizing: border-box;
                display: flex;
                flex-direction: column;
            }

            .detail-header {
                background: linear-gradient(90deg, #1565c0, #1976d2);
                color: #fff;
                padding: 8px 14px;
                font-size: 13px;
                font-weight: bold;
                flex-shrink: 0;
            }

            .info-grid {
                display: flex;
                flex-wrap: wrap;
                gap: 0;
                background: #f8fafc;
                border-bottom: 1px solid #e3eaf5;
                padding: 8px 12px;
                flex-shrink: 0;
            }

            .info-item {
                width: 50%;
                display: flex;
                gap: 6px;
                padding: 3px 0;
                font-size: 12px;
            }

            .info-item .lbl {
                color: #78909c;
                min-width: 52px;
                flex-shrink: 0;
            }

            .info-item .val {
                color: #263238;
                flex: 1;
            }

            .info-item.full {
                width: 100%;
            }

            /* 驳回原因弹窗样式 */
            .reject-form {
                padding: 15px 20px;
            }

            .reject-form textarea {
                width: 100%;
                height: 100px;
                padding: 8px;
                border: 1px solid #cfd8dc;
                border-radius: 4px;
                font-family: "微软雅黑";
                font-size: 13px;
                resize: none;
                box-sizing: border-box;
            }

            .reject-form textarea:focus {
                border-color: #1976d2;
                outline: none;
            }

            /* 驳回弹窗按钮样式 */
            .l-btn.btn-reject {
                background: #e53935 !important;
                color: #fff !important;
                border-color: #e53935 !important;
            }
        </style>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">📋</span>
            领用申请审核
            <span class="sub">审核教师提交的耗材领用申请，并执行出库操作</span>
        </div>

        <div class="easyui-layout" data-options="fit:true" style="height:calc(100vh - 44px);">

            <!-- 筛选栏 + 操作栏 -->
            <div data-options="region:'north',border:false" style="height:auto;">
                <div class="filter-bar">
                    <span style="font-size:12px;color:#546e7a;font-weight:600;">筛选：</span>
                    <input id="filterStatus" style="width:120px;">
                    <input id="filterOrderId" class="easyui-textbox" style="width:110px;" data-options="prompt:'单号'">
                    <input id="filterApplicant" class="easyui-textbox" style="width:110px;"
                        data-options="prompt:'申请人姓名'">
                    <a id="btnSearch" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-search'">查询</a>
                    <a id="btnReset" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-undo',plain:true">重置</a>
                </div>
                <div class="action-bar">
                    <a href="javascript:doAudit1ByBar(1)" class="easyui-linkbutton btn-pass"
                        data-options="iconCls:'icon-ok'">初审通过</a>
                    <a href="javascript:doAudit1ByBar(0)" class="easyui-linkbutton btn-reject"
                        data-options="iconCls:'icon-cancel'">驳回</a>
                    <span style="color:#ddd;margin:0 4px;">|</span>
                    <a href="javascript:doAudit2ByBar()" class="easyui-linkbutton btn-danger"
                        data-options="iconCls:'icon-tip'">危化品二审通过</a>
                    <span style="color:#ddd;margin:0 4px;">|</span>
                    <a href="javascript:doOutboundByBar()" class="easyui-linkbutton btn-out"
                        data-options="iconCls:'icon-save'">执行出库</a>
                    <span style="font-size:11px;color:#90a4ae;margin-left:8px;">
                        仅对已审核的领用申请执行出库，自动扣减库存
                    </span>
                </div>
            </div>

            <!-- 双板块列表 -->
            <div data-options="region:'center',border:true">
                <div class="section-wrap">
                    <div class="section-block" style="flex:0 0 50%;">
                        <div class="section-title-danger">⚠️ 含危化品领用申请</div>
                        <div style="flex:1;overflow:hidden;">
                            <table id="dgDanger" style="width:100%;height:100%;"></table>
                        </div>
                    </div>
                    <div class="section-divider"></div>
                    <div class="section-block" style="flex:0 0 calc(50% - 6px);">
                        <div class="section-title-normal">📦 普通耗材领用申请</div>
                        <div style="flex:1;overflow:hidden;">
                            <table id="dgNormal" style="width:100%;height:100%;"></table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 右侧明细面板 -->
            <div data-options="region:'east',split:true" style="width:440px;">
                <div class="detail-panel">
                    <div class="detail-header" id="detailTitle">领用明细（请点击左侧列表选择）</div>
                    <div class="info-grid" id="infoGrid"></div>
                    <div style="flex:1;overflow:hidden;">
                        <table id="dgItems" style="width:100%;height:100%;"></table>
                    </div>
                </div>
            </div>

        </div>

        <script>
            var ctx = '${pageContext.request.contextPath}';
            var _selRow = null;   // 当前选中行
            var _selFrom = null;  // 'danger' or 'normal'

            /* ===== 列定义（两个 datagrid 共用） ===== */
            function buildColumns() {
                return [[
                    {
                        field: 'id', title: '单号', width: 70, align: 'center',
                        formatter: function (v) { return '<b style="color:#1565c0;cursor:pointer;">' + v + '</b>'; }
                    },
                    { field: 'apply_user_name', title: '申请人', width: 80 },
                    {
                        field: 'course_name', title: '课程', width: 130,
                        formatter: function (v) { return v || '—'; }
                    },
                    {
                        field: 'class_name', title: '班级', width: 110,
                        formatter: function (v) { return v || '—'; }
                    },
                    {
                        field: 'purpose', title: '用途说明', minWidth: 140,
                        formatter: function (v) {
                            if (!v) return '—';
                            var safe = v.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
                            return '<span title="' + safe + '">' + (v.length > 16 ? v.substring(0, 16) + '…' : v) + '</span>';
                        }
                    },
                    {
                        field: 'create_time', title: '申请时间', width: 140,
                        formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                    },
                    {
                        field: 'status', title: '状态', width: 90, align: 'center',
                        formatter: function (v) { return fmtStatusBadge(v); }
                    },
                    {
                        field: '_op', title: '操作', width: 180, align: 'center',
                        formatter: function (v, row) { return buildOpHtml(row); }
                    }
                ]];
            }

            function fmtStatusBadge(v) {
                if (v == 0) return '<span class="s0">待初审</span>';
                if (v == 1) return '<span class="s1">初审通过</span>';
                if (v == 2) return '<span class="s2">已驳回</span>';
                if (v == 3) return '<span class="s3">已出库</span>';
                if (v == 4) return '<span class="s4">二审通过</span>';
                return v;
            }

            function buildOpHtml(row) {
                var id = row.id;
                var s = parseInt(row.status);
                var hd = parseInt(row.has_dangerous);
                if (s === 0) {
                    return '<button class="op-btn op-pass" onclick="doAudit1(' + id + ',1)">初审通过</button> '
                        + '<button class="op-btn op-reject" onclick="showRejectDialog(' + id + ',1)">驳回</button>';
                }
                if (s === 1 && hd === 0) {
                    return '<button class="op-btn op-out" onclick="doOutbound(' + id + ')">执行出库</button>';
                }
                if (s === 1 && hd === 1) {
                    return '<button class="op-btn op-danger" onclick="doAudit2(' + id + ')">危化品二审通过</button> '
                        + '<button class="op-btn op-gray" disabled title="需先完成二审">执行出库</button>';
                }
                if (s === 4) {
                    return '<button class="op-btn op-out" onclick="doOutbound(' + id + ')">执行出库</button>';
                }
                if (s === 2) return '<span class="op-label">已驳回</span>';
                if (s === 3) return '<span class="op-label">已出库</span>';
                return '—';
            }

            /* ===== 初始化 ===== */
            $(function () {
                $('#filterStatus').combobox({
                    data: [
                        { id: '', text: '全部' },
                        { id: '0', text: '待初审' },
                        { id: '1', text: '初审通过' },
                        { id: '2', text: '已驳回' },
                        { id: '4', text: '二审通过' },
                        { id: '3', text: '已出库' }
                    ],
                    valueField: 'id', textField: 'text', editable: false, panelHeight: 'auto', value: '',
                    onChange: function () { doSearch(); }
                });

                $('#btnSearch').click(function () { doSearch(); });
                $('#btnReset').click(function () {
                    $('#filterStatus').combobox('setValue', '');
                    $('#filterOrderId').textbox('setValue', '');
                    $('#filterApplicant').textbox('setValue', '');
                    doSearch();
                });
                $('#filterOrderId').textbox({ onKeyDown: function (e) { if (e.keyCode == 13) doSearch(); } });
                $('#filterApplicant').textbox({ onKeyDown: function (e) { if (e.keyCode == 13) doSearch(); } });

                /* 危化品 datagrid */
                $('#dgDanger').datagrid({
                    fit: true, pagination: true, pageSize: 15, pageList: [15, 30, 50], singleSelect: true, rownumbers: true, striped: true,
                    emptyMsg: '暂无含危化品的领用申请',
                    columns: buildColumns(),
                    onSelect: function (idx, row) { _selRow = row; _selFrom = 'danger'; loadItems(row.id, row); },
                    onLoadSuccess: function () {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* 普通 datagrid */
                $('#dgNormal').datagrid({
                    fit: true, pagination: true, pageSize: 15, pageList: [15, 30, 50], singleSelect: true, rownumbers: true, striped: true,
                    emptyMsg: '暂无普通耗材领用申请',
                    columns: buildColumns(),
                    onSelect: function (idx, row) { _selRow = row; _selFrom = 'normal'; loadItems(row.id, row); },
                    onLoadSuccess: function () {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* 明细 datagrid */
                $('#dgItems').datagrid({
                    fit: true, singleSelect: true, rownumbers: true, striped: true,
                    emptyMsg: '请先选择左侧领用单',
                    columns: [[
                        { field: 'consumable_name', title: '耗材名称', minWidth: 140 },
                        { field: 'unit', title: '单位', width: 50, align: 'center' },
                        {
                            field: 'is_dangerous', title: '危化品', width: 65, align: 'center',
                            formatter: function (v) { return v == 1 ? '<span class="danger-badge">⚠ 危</span>' : '否'; }
                        },
                        { field: 'quantity', title: '数量', width: 60, align: 'center' },
                        {
                            field: 'should_return', title: '需归还', width: 65, align: 'center',
                            formatter: function (v) { return v == 1 ? '<span style="color:#1976d2;font-weight:bold;">是</span>' : '否'; }
                        },
                        {
                            field: 'remark', title: '备注', minWidth: 100,
                            formatter: function (v) { return v || '—'; }
                        }
                    ]]
                });

                /* 首次加载 */
                loadAll({});
            });

            /* ===== 搜索 ===== */
            function doSearch() {
                var status = $('#filterStatus').combobox('getValue');
                var orderId = ($('#filterOrderId').textbox('getValue') || '').replace(/#/g, '').trim();
                var applicant = ($('#filterApplicant').textbox('getValue') || '').trim();
                var params = {};
                if (status) params.status = status;
                if (orderId) params.order_id = orderId;
                if (applicant) params.applicant = applicant;
                loadAll(params);
            }

            /* ===== 加载全部数据并分发 ===== */
            function loadAll(params) {
                var p = $.extend({ page: 1, rows: 500 }, params);
                $.getJSON(ctx + '/ServletOutbound?action=listPending', p, function (data) {
                    var rows = [];
                    if (data && data.rows) rows = data.rows;
                    else if ($.isArray(data)) rows = data;

                    var danger = [], normal = [];
                    $.each(rows, function (i, row) {
                        if (parseInt(row.has_dangerous) === 1) danger.push(row);
                        else normal.push(row);
                    });
                    $('#dgDanger').datagrid('loadData', danger);
                    $('#dgNormal').datagrid('loadData', normal);
                    _selRow = null;
                    clearDetail();
                }).fail(function () {
                    $.messager.alert('错误', '加载数据失败，请刷新重试', 'error');
                });
            }

            /* ===== 明细 ===== */
            function loadItems(outboundId, row) {
                $.getJSON(ctx + '/ServletOutbound?action=getItems', { outbound_id: outboundId }, function (list) {
                    $('#dgItems').datagrid('loadData', list || []);
                    renderInfo(row);
                });
            }

            function renderInfo(row) {
                var hd = parseInt(row.has_dangerous);
                var dangerHtml = hd === 1 ? ' <span class="danger-badge">⚠ 含危化品</span>' : '';
                var rejectReasonHtml = '';
                if (row.status == 2 && row.reject_reason) {
                    rejectReasonHtml = '<div class="info-item full" style="background:#ffebee;border-top:1px solid #ffcdd2;"><span class="lbl" style="color:#c62828;">驳回原因：</span><span class="val" style="color:#c62828;">' + row.reject_reason + '</span></div>';
                }
                $('#detailTitle').html('领用单 <b style="color:#fff;">#' + row.id + '</b>' + dangerHtml + ' 明细');
                $('#infoGrid').html(
                    '<div class="info-item"><span class="lbl">申请人：</span><span class="val">' + (row.apply_user_name || '—') + '</span></div>' +
                    '<div class="info-item"><span class="lbl">状态：</span><span class="val">' + fmtStatusBadge(row.status) + '</span></div>' +
                    '<div class="info-item"><span class="lbl">课程：</span><span class="val">' + (row.course_name || '—') + '</span></div>' +
                    '<div class="info-item"><span class="lbl">班级：</span><span class="val">' + (row.class_name || '—') + '</span></div>' +
                    '<div class="info-item full"><span class="lbl">用途：</span><span class="val">' + (row.purpose || '—') + '</span></div>' +
                    rejectReasonHtml
                );
            }

            function clearDetail() {
                $('#dgItems').datagrid('loadData', []);
                $('#detailTitle').text('领用明细（请点击左侧列表选择）');
                $('#infoGrid').html('');
            }

            /* ===== 驳回弹窗 ===== */
            function showRejectDialog(id, isAudit1) {
                var dialog = $('<div class="reject-form"></div>').dialog({
                    title: '驳回申请',
                    width: 450,
                    height: 260,
                    modal: true,
                    buttons: [{
                        text: '取消',
                        handler: function () { dialog.dialog('destroy'); }
                    }, {
                        text: '确认驳回',
                        cls: 'btn-reject',
                        handler: function () {
                            var reason = dialog.find('textarea').val();
                            if (!reason || !reason.trim()) {
                                $.messager.alert('提示', '请填写驳回原因', 'warning');
                                return;
                            }
                            dialog.dialog('destroy');
                            if (isAudit1) {
                                doAudit1WithReason(id, reason.trim());
                            } else {
                                doAudit2WithReason(id, reason.trim());
                            }
                        }
                    }],
                    onOpen: function () {
                        $(this).html('<div style="margin-bottom:10px;font-size:13px;color:#37474f;"><span style="color:#e53935;">*</span> 请填写驳回原因：</div><textarea id="rejectReasonTextarea" placeholder="请输入驳回原因..." style="width:100%;height:100px;padding:8px;border:1px solid #cfd8dc;border-radius:4px;font-family:微软雅黑;font-size:13px;resize:none;box-sizing:border-box;"></textarea>');
                    }
                });
            }

            /* ===== 操作函数（行内按钮调用） ===== */
            function doAudit1(id, pass) {
                var msg = pass ? '确认初审通过该领用申请？' : '确认驳回该领用申请？';
                $.messager.confirm('确认操作', msg, function (r) {
                    if (!r) return;
                    $.messager.progress();
                    $.post(ctx + '/ServletOutbound?action=audit1', { id: id, pass: pass }, function (ret) {
                        $.messager.progress('close');
                        var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                        if (res.code == '200') {
                            $.messager.show({ title: '✔ 操作成功', msg: res.msg, timeout: 2000, showType: 'slide' });
                            doSearch();
                        } else { $.messager.alert('提示', res.msg, 'warning'); }
                    });
                });
            }

            function doAudit1WithReason(id, reason) {
                $.messager.progress();
                $.post(ctx + '/ServletOutbound?action=audit1', { id: id, pass: 0, reject_reason: reason }, function (ret) {
                    $.messager.progress('close');
                    var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                    if (res.code == '200') {
                        $.messager.show({ title: '✔ 已驳回', msg: res.msg, timeout: 2000, showType: 'slide' });
                        doSearch();
                    } else { $.messager.alert('提示', res.msg, 'warning'); }
                });
            }

            function doAudit2(id) {
                $.messager.confirm('危化品二审', '确认危化品领用二审通过？（五双管理复核）', function (r) {
                    if (!r) return;
                    $.messager.progress();
                    $.post(ctx + '/ServletOutbound?action=audit2', { id: id, pass: 1 }, function (ret) {
                        $.messager.progress('close');
                        var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                        if (res.code == '200') {
                            $.messager.show({ title: '✔ 二审通过', msg: res.msg, timeout: 2000, showType: 'slide' });
                            doSearch();
                        } else { $.messager.alert('提示', res.msg, 'warning'); }
                    });
                });
            }

            function doAudit2WithReason(id, reason) {
                $.messager.progress();
                $.post(ctx + '/ServletOutbound?action=audit2', { id: id, pass: 0, reject_reason: reason }, function (ret) {
                    $.messager.progress('close');
                    var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                    if (res.code == '200') {
                        $.messager.show({ title: '✔ 已驳回', msg: res.msg, timeout: 2000, showType: 'slide' });
                        doSearch();
                    } else { $.messager.alert('提示', res.msg, 'warning'); }
                });
            }

            function doOutbound(id) {
                $.messager.confirm('确认出库', '确认执行出库并扣减库存？此操作不可撤销。', function (r) {
                    if (!r) return;
                    $.messager.progress({ title: '处理中', msg: '正在出库...' });
                    $.post(ctx + '/ServletOutbound?action=doOutbound', { id: id }, function (ret) {
                        $.messager.progress('close');
                        var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                        if (res.code == '200') {
                            $.messager.alert('✔ 出库成功', res.msg, 'info');
                            doSearch();
                        } else { $.messager.alert('提示', res.msg, 'warning'); }
                    });
                });
            }

            /* ===== 顶部操作栏按钮（需先选中行） ===== */
            function getSelRow(requiredStatus, statusLabel) {
                if (!_selRow) { $.messager.alert('提示', '请先在列表中选择一条领用单', 'warning'); return null; }
                if (requiredStatus !== undefined && _selRow.status != requiredStatus) {
                    $.messager.alert('提示', '当前单据状态为「' + fmtStatusText(_selRow.status) + '」，不支持此操作', 'warning');
                    return null;
                }
                return _selRow;
            }

            function fmtStatusText(v) {
                return { 0: '待初审', 1: '初审通过', 2: '已驳回', 3: '已出库', 4: '二审通过' }[v] || v;
            }

            function doAudit1ByBar(pass) {
                var row = getSelRow(0);
                if (!row) return;
                if (pass === 0) {
                    showRejectDialog(row.id, 1);
                } else {
                    doAudit1(row.id, pass);
                }
            }

            function doAudit2ByBar() {
                var row = getSelRow(1);
                if (!row) return;
                doAudit2(row.id);
            }

            function doOutboundByBar() {
                if (!_selRow) { $.messager.alert('提示', '请先在列表中选择一条领用单', 'warning'); return; }
                var s = parseInt(_selRow.status);
                var hd = parseInt(_selRow.has_dangerous);
                var ok = (s === 1 && hd === 0) || (s === 4);
                if (!ok) {
                    $.messager.alert('提示', '当前单据状态为「' + fmtStatusText(_selRow.status) + '」，不满足出库条件', 'warning');
                    return;
                }
                doOutbound(_selRow.id);
            }
        </script>
    </body>

    </html>