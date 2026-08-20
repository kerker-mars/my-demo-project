<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>归还登记</title>
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
            }

            .page-header .sub {
                font-size: 12px;
                font-weight: normal;
                opacity: .8;
            }

            .panel-title-bar {
                background: #f0f4fa;
                border-bottom: 2px solid #1976d2;
                padding: 7px 12px;
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .tb-wrap {
                background: #f8fafc;
                border-bottom: 1px solid #dce6f5;
                padding: 5px 8px;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .badge-pending {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #FF9800;
                color: #fff;
            }

            .badge-pass {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #43a047;
                color: #fff;
            }

            .badge-reject {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            .badge-need {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #1976d2;
                color: #fff;
            }

            .badge-noneed {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #90a4ae;
                color: #fff;
            }

            .btn-primary {
                background: linear-gradient(90deg, #1565c0, #1976d2) !important;
                color: #fff !important;
                border: none !important;
                border-radius: 5px !important;
                font-weight: bold;
            }

            .dlg-row {
                margin-bottom: 14px;
            }

            .dlg-row label {
                display: block;
                font-size: 12px;
                color: #546e7a;
                font-weight: 600;
                margin-bottom: 5px;
            }

            .info-card {
                background: #e3f2fd;
                border-left: 3px solid #1976d2;
                border-radius: 4px;
                padding: 8px 12px;
                font-size: 12px;
                color: #1565c0;
                margin-bottom: 14px;
            }

            .info-card b {
                color: #1565c0;
            }

            .empty-tip {
                text-align: center;
                padding: 40px 20px;
                color: #b0bec5;
                font-size: 13px;
                line-height: 2;
            }

            /* 数量输入框错误状态 */
            .qty-error input {
                border-color: #e53935 !important;
                box-shadow: 0 0 0 2px rgba(229, 57, 53, .15) !important;
            }

            /* 倒计时样式 */
            .countdown-green {
                color: #43a047;
                font-weight: 500;
            }

            .countdown-orange {
                color: #ff9800;
                font-weight: 600;
            }

            .countdown-red {
                color: #e53935;
                font-weight: bold;
            }
        </style>
        <script>
            var ctx = '${pageContext.request.contextPath}';
            var selectedItem = null;

            /* ===== 计算归还倒计时 ===== */
            function calcCountdown(borrowTime) {
                if (!borrowTime) return { text: '—', class: 'countdown-green' };
                var borrow = new Date(borrowTime);
                var now = new Date();
                var diffMs = now - borrow;
                var diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
                var remaining = 10 - diffDays;

                if (remaining > 0) {
                    return { text: '还剩 ' + remaining + ' 天', class: 'countdown-green' };
                } else if (remaining === 0) {
                    return { text: '今日到期', class: 'countdown-orange' };
                } else {
                    return { text: '已逾期 ' + Math.abs(remaining) + ' 天', class: 'countdown-red' };
                }
            }

            $(function () {

                /* ===== 加载所有明细并分区渲染 ===== */
                function loadReturnItems() {
                    $.getJSON(ctx + '/ServletReturn?action=listReturnableItems&page=1&rows=500', function (data) {
                        var rows = data.rows || [];
                        var needRows = [], noNeedRows = [];
                        rows.forEach(function (r) {
                            if (parseInt(r.need_return) === 1) needRows.push(r);
                            else noNeedRows.push(r);
                        });
                        renderNeedTable(needRows);
                        renderNoNeedTable(noNeedRows);
                    });
                }

                loadReturnItems();
                /* ===== 渲染"需归还"表格 ===== */
                function renderNeedTable(rows) {
                    var cols = buildColumns(true);
                    if ($('#dgNeedReturn').data('datagrid')) {
                        $('#dgNeedReturn').datagrid('loadData', rows);
                    } else {
                        $('#dgNeedReturn').datagrid({
                            fit: true, singleSelect: true, rownumbers: true, striped: true,
                            emptyMsg: '<div style="text-align:center;padding:16px;color:#b0bec5;font-size:12px;">暂无需要归还的耗材</div>',
                            columns: [cols],
                            data: rows,
                            onSelect: function (idx, row) { selectedItem = row; }
                        });
                    }
                }

                /* ===== 渲染"无需归还"表格 ===== */
                function renderNoNeedTable(rows) {
                    var cols = buildColumns(false);
                    if ($('#dgNoNeedReturn').data('datagrid')) {
                        $('#dgNoNeedReturn').datagrid('loadData', rows);
                    } else {
                        $('#dgNoNeedReturn').datagrid({
                            fit: true, singleSelect: false, rownumbers: true, striped: true,
                            emptyMsg: '<div style="text-align:center;padding:16px;color:#b0bec5;font-size:12px;">暂无无需归还的耗材</div>',
                            columns: [cols],
                            data: rows,
                            onClickRow: function () { return false; } // 禁止选中
                        });
                    }
                }

                /* ===== 列定义 ===== */
                function buildColumns(canReturn) {
                    var cols = [
                        { field: 'outbound_item_id', hidden: true },
                        {
                            field: 'consumable_name', title: '耗材名称', width: 150,
                            formatter: function (v) { return '<span style="font-weight:500;">' + (v || '') + '</span>'; }
                        },
                        { field: 'unit', title: '单位', width: 50, align: 'center' },
                        {
                            field: 'original_quantity', title: '已领用', width: 65, align: 'center',
                            formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                        }
                    ];

                    // 仅需归还的耗材添加以下列
                    if (canReturn) {
                        cols.push({
                            field: 'already_returned', title: '已归还', width: 65, align: 'center',
                            formatter: function (v) {
                                var n = parseInt(v || 0);
                                return '<span style="color:' + (n > 0 ? '#43a047' : '#90a4ae') + ';">' + n + '</span>';
                            }
                        });
                        cols.push({
                            field: 'remaining_qty', title: '剩余可归还', width: 80, align: 'center',
                            formatter: function (v) {
                                var n = parseInt(v || 0);
                                var c = n <= 0 ? '#e53935' : n <= 2 ? '#f57c00' : '#1565c0';
                                return '<b style="color:' + c + ';">' + n + '</b>';
                            }
                        });
                    }

                    cols.push({
                        field: 'need_return', title: '是否需归还', width: 80, align: 'center',
                        formatter: function (v) {
                            return (v == 1 || v === '1')
                                ? '<span class="badge-need">是</span>'
                                : '<span class="badge-noneed">否</span>';
                        }
                    });

                    // 仅需归还的耗材添加归还倒计时
                    if (canReturn) {
                        cols.push({
                            field: 'countdown', title: '归还倒计时', width: 100, align: 'center',
                            formatter: function (v, r) {
                                var countdown = calcCountdown(r.borrow_time);
                                return '<span class="' + countdown.class + '">' + countdown.text + '</span>';
                            }
                        });
                    }

                    cols.push({ field: 'course_name', title: '课程', width: 110, formatter: function (v) { return v || '—'; } });
                    cols.push({ field: 'class_name', title: '班级', width: 100, formatter: function (v) { return v || '—'; } });
                    cols.push({ field: 'purpose', title: '用途', minWidth: 120, formatter: function (v) { return v || '—'; } });

                    // 删除操作列
                    return cols;
                }

                /* ===== 工具栏「提交归还」按钮 ===== */
                $('#btnSubmitReturn').click(function () {
                    if (!selectedItem) { $.messager.alert('提示', '请先在上方列表选中一条需归还的明细', 'warning'); return; }
                    if (parseInt(selectedItem.need_return) !== 1) { $.messager.alert('提示', '该耗材无需归还', 'warning'); return; }
                    openReturnDlgByItem(selectedItem);
                });

                /* ===== 我的归还记录 ===== */
                $('#dgMyReturns').datagrid({
                    url: ctx + '/ServletReturn?action=listMyReturns',
                    pagination: true, fit: true, singleSelect: true, rownumbers: true,
                    pageSize: 10, pageList: [10, 20, 50],
                    columns: [[
                        { field: 'id', title: '记录ID', width: 70, align: 'center' },
                        { field: 'consumable_name', title: '耗材名称', width: 160 },
                        { field: 'unit', title: '单位', width: 55, align: 'center' },
                        {
                            field: 'return_quantity', title: '归还数量', width: 80, align: 'center',
                            formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                        },
                        {
                            field: 'status', title: '审核状态', width: 90, align: 'center',
                            formatter: function (v, row) {
                                if (v == 0) return '<span class="badge-pending">待审核</span>';
                                if (v == 1) return '<span class="badge-pass">已通过</span>';
                                if (v == 2) {
                                    var reason = row.reject_reason || '未说明原因';
                                    return '<span class="badge-reject" title="' + reason.replace(/"/g, '&quot;') + '">已驳回</span>';
                                }
                                return v;
                            }
                        },
                        { field: 'course_name', title: '课程', width: 120, formatter: function (v) { return v || '—'; } },
                        {
                            field: 'feedback', title: '使用反馈', width: 180, formatter: function (v) {
                                if (!v) return '—';
                                var s = v.length > 30 ? v.substring(0, 30) + '...' : v;
                                return '<span title="' + v.replace(/"/g, '&quot;') + '">' + s + '</span>';
                            }
                        },
                        { field: 'apply_time', title: '提交时间', width: 140, formatter: function (v) { if (!v) return '—'; return String(v).replace('T', ' '); } },
                        { field: 'check_time', title: '审核时间', width: 140, formatter: function (v) { if (!v) return '—'; return String(v).replace('T', ' '); } },
                        {
                            field: '_op', title: '操作', width: 80, align: 'center',
                            formatter: function (v, row) {
                                if (row.status == 0) {
                                    return '<a href="javascript:void(0)" onclick="cancelReturn(' + row.id + ')" style="color:#e53935;font-size:12px;">撤回</a>';
                                }
                                return '<span style="color:#b0bec5;font-size:12px;">—</span>';
                            }
                        }
                    ]],
                    onLoadSuccess: function () {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* ===== 归还数量实时校验 ===== */
                $('#return_quantity').numberbox({
                    required: true, min: 1, precision: 0,
                    prompt: '请输入归还数量',
                    onChange: function (v) { validateQty(v); }
                });

                /* ===== 确认提交归还 ===== */
                $(document).on('click', '#btnConfirmReturn', function () {
                    if (!selectedItem) return;
                    var qty = parseInt($('#return_quantity').numberbox('getValue') || 0);
                    if (!validateQty(qty)) return;
                    var name = selectedItem.consumable_name || '';
                    $.messager.confirm('确认归还',
                        '确认归还 <b>【' + name + '】' + qty + ' ' + (selectedItem.unit || '') + '</b>？<br>'
                        + '<span style="font-size:12px;color:#546e7a;">提交后将等待管理员审核，审核通过后自动回补实验室库存。</span>',
                        function (r) {
                            if (!r) return;
                            doSubmitReturn(qty);
                        }
                    );
                });
            });

            /* ===== 通过行数据打开弹窗（操作列按钮调用） ===== */
            function openReturnDlgByRow(rowJson) {
                var row = typeof rowJson === 'string' ? JSON.parse(rowJson) : rowJson;
                openReturnDlgByItem(row);
            }

            /* ===== 通过 item 对象打开弹窗 ===== */
            function openReturnDlgByItem(row) {
                if (!row) return;
                selectedItem = row;
                var maxQty = parseInt(row.remaining_qty || row.original_quantity || 1);
                $('#dlgItemInfo').html(
                    '<b>' + (row.consumable_name || '') + '</b>'
                    + '&nbsp;&nbsp;单位：' + (row.unit || '')
                    + '&nbsp;&nbsp;已领用：<b style="color:#1565c0;">' + (row.original_quantity || 0) + '</b>'
                    + '&nbsp;&nbsp;剩余可归还：<b style="color:' + (maxQty > 0 ? '#1565c0' : '#e53935') + ';">' + maxQty + '</b>'
                    + '&nbsp;&nbsp;课程：' + (row.course_name || '—')
                );
                $('#return_quantity').numberbox('options').max = maxQty;
                $('#return_quantity').numberbox('setValue', maxQty);
                $('#qtyError').hide();
                $('#feedback').textbox('setValue', '');
                $('#dlgReturn').dialog('open');
            }

            /* ===== 数量校验 ===== */
            function validateQty(v) {
                if (!selectedItem) return true;
                var maxQty = parseInt(selectedItem.remaining_qty || selectedItem.original_quantity || 1);
                var qty = parseInt(v || 0);
                var errEl = $('#qtyError');
                if (!v || v === '' || qty <= 0) {
                    errEl.text('请填写归还数量').show();
                    $('#qtyWrap').addClass('qty-error');
                    return false;
                }
                if (qty > maxQty) {
                    errEl.text('归还数量不能超过剩余可归还数量（' + maxQty + '）').show();
                    $('#qtyWrap').addClass('qty-error');
                    return false;
                }
                errEl.hide();
                $('#qtyWrap').removeClass('qty-error');
                return true;
            }

            /* ===== doSubmitReturn ===== */
            function doSubmitReturn(qty) {
                $.messager.progress({ title: '处理中', msg: '正在提交归还...' });
                $.ajax({
                    type: 'POST',
                    url: ctx + '/ServletReturn?action=create',
                    data: {
                        outbound_item_id: selectedItem.outbound_item_id,
                        return_quantity: qty,
                        feedback: $('#feedback').textbox('getValue')
                    },
                    success: function (ret) {
                        $.messager.progress('close');
                        var r = (typeof ret === 'string') ? JSON.parse(ret) : ret;
                        if (r.code == '200') {
                            $('#dlgReturn').dialog('close');
                            selectedItem = null;
                            // 重新拉取数据并刷新两个区域（用 loadData，不 destroy）
                            reloadReturnItems();
                            $('#dgMyReturns').datagrid('reload');
                            $('#dlgSuccess').dialog('open');
                        } else {
                            $('#qtyError').text(r.msg || '提交失败，请检查后重试').show();
                        }
                    },
                    error: function () {
                        $.messager.progress('close');
                        $('#qtyError').text('网络异常，请稍后重试').show();
                    }
                });
            }

            /* ===== 刷新两个分区表格 ===== */
            function reloadReturnItems() {
                $.getJSON(ctx + '/ServletReturn?action=listReturnableItems&page=1&rows=500', function (data) {
                    var rows = data.rows || [];
                    var needRows = [], noNeedRows = [];
                    rows.forEach(function (r) {
                        if (parseInt(r.need_return) === 1) needRows.push(r);
                        else noNeedRows.push(r);
                    });
                    if ($('#dgNeedReturn').data('datagrid')) {
                        $('#dgNeedReturn').datagrid('loadData', needRows);
                    }
                    if ($('#dgNoNeedReturn').data('datagrid')) {
                        $('#dgNoNeedReturn').datagrid('loadData', noNeedRows);
                    }
                });
            }

            /* ===== 列定义（独立函数，供重建时调用） ===== */
            function buildNeedCols() {
                return [
                    { field: 'outbound_item_id', hidden: true },
                    { field: 'consumable_name', title: '耗材名称', width: 150, formatter: function (v) { return '<span style="font-weight:500;">' + (v || '') + '</span>'; } },
                    { field: 'unit', title: '单位', width: 50, align: 'center' },
                    { field: 'original_quantity', title: '已领用', width: 65, align: 'center', formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; } },
                    { field: 'already_returned', title: '已归还', width: 65, align: 'center', formatter: function (v) { var n = parseInt(v || 0); return '<span style="color:' + (n > 0 ? '#43a047' : '#90a4ae') + ';">' + n + '</span>'; } },
                    { field: 'remaining_qty', title: '剩余可归还', width: 80, align: 'center', formatter: function (v) { var n = parseInt(v || 0); var c = n <= 0 ? '#e53935' : n <= 2 ? '#f57c00' : '#1565c0'; return '<b style="color:' + c + ';">' + n + '</b>'; } },
                    { field: 'need_return', title: '是否需归还', width: 80, align: 'center', formatter: function (v) { return (v == 1 || v === '1') ? '<span class="badge-need">是</span>' : '<span class="badge-noneed">否</span>'; } },
                    { field: 'countdown', title: '归还倒计时', width: 100, align: 'center', formatter: function (v, r) { var countdown = calcCountdown(r.borrow_time); return '<span class="' + countdown.class + '">' + countdown.text + '</span>'; } },
                    { field: 'course_name', title: '课程', width: 110, formatter: function (v) { return v || '—'; } },
                    { field: 'class_name', title: '班级', width: 100, formatter: function (v) { return v || '—'; } },
                    { field: 'purpose', title: '用途', minWidth: 120, formatter: function (v) { return v || '—'; } }
                ];
            }
            function buildNoNeedCols() {
                return [
                    { field: 'outbound_item_id', hidden: true },
                    { field: 'consumable_name', title: '耗材名称', width: 150, formatter: function (v) { return '<span style="font-weight:500;">' + (v || '') + '</span>'; } },
                    { field: 'unit', title: '单位', width: 50, align: 'center' },
                    { field: 'original_quantity', title: '已领用', width: 65, align: 'center', formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; } },
                    { field: 'need_return', title: '是否需归还', width: 80, align: 'center', formatter: function (v) { return (v == 1 || v === '1') ? '<span class="badge-need">是</span>' : '<span class="badge-noneed">否</span>'; } },
                    { field: 'course_name', title: '课程', width: 110, formatter: function (v) { return v || '—'; } },
                    { field: 'class_name', title: '班级', width: 100, formatter: function (v) { return v || '—'; } },
                    { field: 'purpose', title: '用途', minWidth: 120, formatter: function (v) { return v || '—'; } }
                ];
            }

            /* openReturnDlgByRow 支持 encodeURIComponent 编码的参数 */
            function openReturnDlgByRow(rowStr) {
                var row;
                try { row = JSON.parse(decodeURIComponent(rowStr)); } catch (e) { return; }
                openReturnDlgByItem(row);
            }

            /* ===== 撤回归还申请 ===== */
            function cancelReturn(returnId) {
                $.messager.confirm('确认撤回', '确认撤回该归还申请？撤回后可重新提交。', function (r) {
                    if (!r) return;
                    $.post(ctx + '/ServletReturn?action=cancel', { id: returnId }, function (ret) {
                        var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
                        if (res.code == '200') {
                            $.messager.show({ title: '成功', msg: res.msg, timeout: 2500, showType: 'slide' });
                            $('#dgMyReturns').datagrid('reload');
                            reloadReturnItems();
                        } else {
                            $.messager.alert('失败', res.msg, 'warning');
                        }
                    }).fail(function () {
                        $.messager.alert('错误', '网络异常', 'error');
                    });
                });
            }
        </script>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <!-- 顶部标题 -->
        <div class="page-header">
            <span style="font-size:20px;">↩️</span>
            归还登记
            <span class="sub">选择已出库的领用明细，填写归还数量后提交，等待管理员审核</span>
        </div>

        <!-- 主体布局 -->
        <div class="easyui-layout" data-options="fit:true" style="height:calc(100vh - 44px);">

            <!-- 左：可归还明细（上下分区） -->
            <div data-options="region:'west',split:true,border:true" style="width:65%;">
                <div style="height:100%;display:flex;flex-direction:column;overflow:hidden;">

                    <!-- 工具栏 -->
                    <div class="tb-wrap" style="flex-shrink:0;">
                        <a id="btnSubmitReturn" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                            data-options="iconCls:'icon-save'">提交归还</a>
                        <span style="color:#90a4ae;font-size:12px;margin-left:6px;">在上方列表选中需归还的耗材后点击</span>
                    </div>

                    <!-- 上：需归还 -->
                    <div style="flex:1;min-height:0;display:flex;flex-direction:column;overflow:hidden;">
                        <div class="panel-title-bar"
                            style="flex-shrink:0;background:#e8f5e9;border-bottom-color:#43a047;color:#2e7d32;">
                            ✅ 需要归还的耗材
                            <span
                                style="font-size:11px;font-weight:normal;color:#66bb6a;margin-left:6px;">选中耗材后点击上方「提交归还」按钮</span>
                        </div>
                        <div style="flex:1;overflow:hidden;">
                            <table id="dgNeedReturn" style="width:100%;height:100%;"></table>
                        </div>
                    </div>

                    <!-- 分隔线 -->
                    <div style="height:6px;background:#eceff1;flex-shrink:0;"></div>

                    <!-- 下：无需归还 -->
                    <div style="flex:1;min-height:0;display:flex;flex-direction:column;overflow:hidden;">
                        <div class="panel-title-bar"
                            style="flex-shrink:0;background:#f5f5f5;border-bottom-color:#bdbdbd;color:#757575;">
                            📦 无需归还的耗材
                            <span
                                style="font-size:11px;font-weight:normal;color:#bdbdbd;margin-left:6px;">消耗品，无需归还操作</span>
                        </div>
                        <div style="flex:1;overflow:hidden;opacity:0.7;">
                            <table id="dgNoNeedReturn" style="width:100%;height:100%;"></table>
                        </div>
                    </div>

                </div>
            </div>

            <!-- 右：我的归还记录 -->
            <div data-options="region:'center',border:true">
                <div class="easyui-layout" data-options="fit:true">
                    <div data-options="region:'north',border:false" style="height:auto;">
                        <div class="panel-title-bar" id="myReturnTitle">📋 我的归还记录</div>
                    </div>
                    <div data-options="region:'center',border:false">
                        <table id="dgMyReturns"></table>
                    </div>
                </div>
            </div>
        </div>

        <!-- ===== 归还弹窗 ===== -->
        <div id="dlgReturn" class="easyui-dialog" title="提交归还申请" style="width:500px;padding:18px 22px;"
            data-options="closed:true,modal:true,buttons:'#dlgReturnBtns'">

            <div class="info-card" id="dlgItemInfo"></div>

            <div class="dlg-row" id="qtyWrap">
                <label>归还数量 <span style="color:#e53935;">*</span></label>
                <input id="return_quantity" style="width:100%;">
                <div id="qtyError"
                    style="display:none;margin-top:4px;font-size:12px;color:#e53935;padding:4px 8px;background:#ffebee;border-radius:4px;">
                </div>
            </div>
            <div class="dlg-row">
                <label>使用反馈（可选）</label>
                <input id="feedback" class="easyui-textbox" style="width:100%;height:90px"
                    data-options="multiline:true,prompt:'可描述使用情况、破损情况、质量问题等'">
            </div>
        </div>
        <div id="dlgReturnBtns">
            <a id="btnConfirmReturn" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                data-options="iconCls:'icon-ok'">确认提交</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back'"
                onclick="$('#dlgReturn').dialog('close')">取消</a>
        </div>

        <!-- ===== 提交成功弹窗 ===== -->
        <div id="dlgSuccess" class="easyui-dialog" title="归还提交成功" style="width:380px;padding:20px 24px;"
            data-options="closed:true,modal:true,buttons:'#dlgSuccessBtns'">
            <div style="text-align:center;">
                <div style="font-size:38px;margin-bottom:10px;">✅</div>
                <div style="font-size:15px;font-weight:bold;color:#43a047;margin-bottom:8px;">归还申请提交成功！</div>
                <div style="font-size:13px;color:#546e7a;">等待实验室管理员审核</div>
                <div style="font-size:12px;color:#90a4ae;margin-top:6px;">审核通过后库存将自动回补</div>
            </div>
        </div>
        <div id="dlgSuccessBtns">
            <a href="javascript:void(0)" class="easyui-linkbutton btn-primary" data-options="iconCls:'icon-search'"
                onclick="$('#dlgSuccess').dialog('close');$('#dgMyReturns').datagrid('reload');document.getElementById('myReturnTitle').scrollIntoView({behavior:'smooth'});">
                查看我的归还记录
            </a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-ok',plain:true"
                onclick="$('#dlgSuccess').dialog('close');">关闭</a>
        </div>

    </body>

    </html>