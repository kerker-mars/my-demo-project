<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>报废审核与扣减</title>
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

            .action-bar {
                background: #fff;
                border-bottom: 1px solid #e8eef7;
                padding: 7px 12px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

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

            /* 板块标题 */
            .section-title-pending {
                background: #fff8e1;
                border-left: 4px solid #f57c00;
                border-bottom: 1px solid #ffe082;
                padding: 5px 12px;
                font-size: 13px;
                font-weight: bold;
                color: #e65100;
                flex-shrink: 0;
            }

            .section-title-history {
                background: #e8f5e9;
                border-left: 4px solid #43a047;
                border-bottom: 1px solid #c8e6c9;
                padding: 5px 12px;
                font-size: 13px;
                font-weight: bold;
                color: #2e7d32;
                flex-shrink: 0;
            }

            .section-divider {
                height: 6px;
                background: #eceff1;
                flex-shrink: 0;
            }

            /* 状态徽章 */
            .s0 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #FF9800;
                color: #fff;
            }

            .s1 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #43a047;
                color: #fff;
            }

            .s2 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            .danger-badge {
                display: inline-block;
                padding: 1px 7px;
                border-radius: 8px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            /* 详情面板 */
            .detail-panel {
                padding: 14px 16px;
                height: 100%;
                box-sizing: border-box;
                overflow-y: auto;
            }

            .detail-title {
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
                margin-bottom: 10px;
                padding-bottom: 6px;
                border-bottom: 2px solid #e3eaf5;
            }

            .info-card {
                background: #f8fafc;
                border-radius: 6px;
                padding: 12px 14px;
                margin-bottom: 12px;
            }

            .info-row {
                display: flex;
                gap: 6px;
                margin-bottom: 7px;
                font-size: 13px;
            }

            .info-row .lbl {
                color: #78909c;
                min-width: 70px;
                flex-shrink: 0;
            }

            .info-row .val {
                color: #263238;
                flex: 1;
                word-break: break-all;
            }

            .reason-box {
                background: #fff8e1;
                border: 1px solid #ffe082;
                border-radius: 6px;
                padding: 10px 12px;
                font-size: 13px;
                color: #5d4037;
                white-space: pre-wrap;
                min-height: 40px;
                margin-bottom: 10px;
            }

            .reject-box {
                background: #ffebee;
                border: 1px solid #ef9a9a;
                border-radius: 6px;
                padding: 10px 12px;
                font-size: 13px;
                color: #c62828;
                white-space: pre-wrap;
                min-height: 40px;
                margin-bottom: 10px;
            }

            .warn-box {
                background: #ffebee;
                border: 1px solid #ef9a9a;
                border-radius: 6px;
                padding: 10px 12px;
                font-size: 12px;
                color: #c62828;
                margin-bottom: 10px;
            }

            .no-select {
                color: #b0bec5;
                font-size: 13px;
                text-align: center;
                padding: 40px 0;
            }

            /* 驳回弹窗 textarea */
            #rejectReasonInput {
                width: 100%;
                height: 90px;
                box-sizing: border-box;
                border: 1px solid #ccc;
                border-radius: 4px;
                padding: 8px;
                font-family: "微软雅黑", sans-serif;
                font-size: 13px;
                resize: vertical;
            }

            #rejectReasonInput:focus {
                outline: none;
                border-color: #e53935;
            }
        </style>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">⚖️</span>
            报废审核与扣减
            <span class="sub">审核报废申请，通过后自动扣减库存；驳回时须填写理由</span>
        </div>

        <div class="easyui-layout" data-options="fit:true" style="height:calc(100vh - 44px);">

            <!-- 操作栏 -->
            <div data-options="region:'north',border:false" style="height:auto;">
                <div class="action-bar">
                    <a href="javascript:doPass()" class="easyui-linkbutton btn-pass"
                        data-options="iconCls:'icon-ok'">审核通过（扣减库存）</a>
                    <a href="javascript:openRejectDlg()" class="easyui-linkbutton btn-reject"
                        data-options="iconCls:'icon-cancel'">驳回（填写理由）</a>
                    <span style="font-size:11px;color:#90a4ae;margin-left:8px;">
                        ⚠ 审核通过后库存立即扣减，请仔细核对后操作
                    </span>
                </div>
            </div>

            <!-- 中间：上下双板块 -->
            <div data-options="region:'center',border:true">
                <div style="height:100%;display:flex;flex-direction:column;overflow:hidden;">
                    <!-- 上：待审核 -->
                    <div style="flex:0 0 50%;display:flex;flex-direction:column;overflow:hidden;">
                        <div class="section-title-pending">🕐 待审核报废申请</div>
                        <div style="flex:1;overflow:hidden;">
                            <table id="dgPending" style="width:100%;height:100%;"></table>
                        </div>
                    </div>
                    <div class="section-divider"></div>
                    <!-- 下：历史记录 -->
                    <div style="flex:0 0 calc(50% - 6px);display:flex;flex-direction:column;overflow:hidden;">
                        <div class="section-title-history">📋 历史审核记录（已通过 / 已驳回）</div>
                        <div style="flex:1;overflow:hidden;">
                            <table id="dgHistory" style="width:100%;height:100%;"></table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 右侧：详情卡片 -->
            <div data-options="region:'east',split:true" style="width:340px;">
                <div class="detail-panel" id="detailPanel">
                    <div class="no-select">请点击左侧列表查看报废详情</div>
                </div>
            </div>

        </div>

        <!-- 驳回弹窗 -->
        <div id="dlgReject" class="easyui-dialog" style="width:420px;padding:16px 20px;"
            data-options="title:'填写驳回理由',modal:true,closed:true,buttons:'#dlgRejectBtns'">
            <p style="margin:0 0 8px;font-size:13px;color:#546e7a;">请说明驳回原因，该信息将同步给申请人。</p>
            <textarea id="rejectReasonInput" placeholder="请填写驳回理由（必填）"></textarea>
        </div>
        <div id="dlgRejectBtns">
            <a href="javascript:confirmReject()" class="easyui-linkbutton btn-reject"
                data-options="iconCls:'icon-cancel'">确认驳回</a>
            <a href="javascript:$('#dlgReject').dialog('close')" class="easyui-linkbutton"
                data-options="plain:true">取消</a>
        </div>

        <script>
            var ctx = '${pageContext.request.contextPath}';
            var _selRow = null;   // 当前选中行（只允许从待审核板块选）

            /* ===== 列定义 ===== */
            var pendingCols = [[
                {
                    field: 'id', title: '报废ID', width: 70, align: 'center',
                    formatter: function (v) { return '<b style="color:#1565c0;">#' + v + '</b>'; }
                },
                { field: 'lab_name', title: '实验室', width: 110 },
                { field: 'apply_user_name', title: '申请人', width: 80 },
                {
                    field: 'consumable_name', title: '耗材名称', minWidth: 140,
                    formatter: function (v, r) {
                        var tag = r.is_dangerous == 1 ? ' <span class="danger-badge">⚠危</span>' : '';
                        return (v || '—') + tag;
                    }
                },
                { field: 'unit', title: '单位', width: 50, align: 'center' },
                {
                    field: 'quantity', title: '报废数量', width: 75, align: 'center',
                    formatter: function (v) { return '<b style="color:#e53935;">' + v + '</b>'; }
                },
                {
                    field: 'apply_time', title: '申请时间', width: 135,
                    formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                },
                {
                    field: 'reason', title: '报废原因', minWidth: 140, formatter: function (v) {
                        if (!v) return '—';
                        var safe = v.replace(/"/g, '&quot;').replace(/</g, '&lt;');
                        return '<span title="' + safe + '">' + (v.length > 18 ? v.substring(0, 18) + '…' : v) + '</span>';
                    }
                }
            ]];

            var historyCols = [[
                {
                    field: 'id', title: '报废ID', width: 70, align: 'center',
                    formatter: function (v) { return '<b style="color:#1565c0;">#' + v + '</b>'; }
                },
                { field: 'lab_name', title: '实验室', width: 110 },
                { field: 'apply_user_name', title: '申请人', width: 80 },
                {
                    field: 'consumable_name', title: '耗材名称', minWidth: 130,
                    formatter: function (v, r) {
                        var tag = r.is_dangerous == 1 ? ' <span class="danger-badge">⚠危</span>' : '';
                        return (v || '—') + tag;
                    }
                },
                { field: 'unit', title: '单位', width: 50, align: 'center' },
                {
                    field: 'quantity', title: '报废数量', width: 75, align: 'center',
                    formatter: function (v) { return '<b style="color:#e53935;">' + v + '</b>'; }
                },
                {
                    field: 'status', title: '状态', width: 80, align: 'center',
                    formatter: function (v) {
                        if (v == 1) return '<span class="s1">已通过</span>';
                        if (v == 2) return '<span class="s2">已驳回</span>';
                        return v;
                    }
                },
                {
                    field: 'audit_user_name', title: '审核人', width: 80,
                    formatter: function (v) { return v || '—'; }
                },
                {
                    field: 'audit_time', title: '审核时间', width: 135,
                    formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                },
                {
                    field: 'audit_comment', title: '驳回理由', minWidth: 130, formatter: function (v, r) {
                        if (r.status != 2 || !v) return '—';
                        var safe = v.replace(/"/g, '&quot;').replace(/</g, '&lt;');
                        return '<span style="color:#e53935;" title="' + safe + '">' + (v.length > 16 ? v.substring(0, 16) + '…' : v) + '</span>';
                    }
                }
            ]];

            $(function () {
                /* 待审核列表 */
                $('#dgPending').datagrid({
                    url: ctx + '/ServletScrap?action=listPending',
                    fit: true, pagination: true, singleSelect: true, rownumbers: true, striped: true,
                    pageSize: 10, pageList: [10, 20, 50],
                    columns: pendingCols,
                    onSelect: function (idx, row) {
                        _selRow = row;
                        renderDetail(row, false);
                        // 取消历史列表选中
                        $('#dgHistory').datagrid('clearSelections');
                    },
                    onLoadSuccess: function () {
                        _selRow = null;
                        $('#detailPanel').html('<div class="no-select">请点击左侧列表查看报废详情</div>');
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* 历史记录列表（只读，点击查看详情） */
                $('#dgHistory').datagrid({
                    url: ctx + '/ServletScrap?action=listAll',
                    fit: true, pagination: true, singleSelect: true, rownumbers: true, striped: true,
                    pageSize: 10, pageList: [10, 20, 50],
                    columns: historyCols,
                    onSelect: function (idx, row) {
                        // 历史记录只展示详情，不允许审核操作
                        _selRow = null;
                        renderDetail(row, true);
                        // 取消待审核列表选中
                        $('#dgPending').datagrid('clearSelections');
                    },
                    onLoadSuccess: function () {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });
            });

            /* ===== 渲染详情卡片 ===== */
            function renderDetail(row, isHistory) {
                var dangerHtml = row.is_dangerous == 1
                    ? '<div class="warn-box">⚠ 该耗材为危险化学品，报废须按危化品处置规范执行，审核前请确认已双人在场记录。</div>'
                    : '';

                var statusHtml = '';
                if (!isHistory) {
                    statusHtml = '<span class="s0">待审核</span>';
                } else if (row.status == 1) {
                    statusHtml = '<span class="s1">已通过</span>';
                } else if (row.status == 2) {
                    statusHtml = '<span class="s2">已驳回</span>';
                }

                var auditSection = '';
                if (isHistory) {
                    auditSection =
                        '<div class="info-row"><span class="lbl">审核人：</span><span class="val">' + (row.audit_user_name || '—') + '</span></div>' +
                        '<div class="info-row"><span class="lbl">审核时间：</span><span class="val">' + (row.audit_time ? String(row.audit_time).substring(0, 16).replace('T', ' ') : '—') + '</span></div>';
                }

                var rejectSection = '';
                if (isHistory && row.status == 2 && row.audit_comment) {
                    rejectSection =
                        '<div style="font-size:12px;font-weight:bold;color:#c62828;margin-bottom:6px;">驳回理由：</div>' +
                        '<div class="reject-box">' + row.audit_comment.replace(/</g, '&lt;') + '</div>';
                }

                var actionTip = '';
                if (!isHistory) {
                    actionTip =
                        '<div style="margin-top:12px;padding:10px;background:#e8f5e9;border-radius:6px;font-size:12px;color:#2e7d32;">' +
                        '✔ 审核通过后，将自动扣减库存 <b>-' + row.quantity + '</b> ' + (row.unit || '') + '</div>';
                }

                $('#detailPanel').html(
                    '<div class="detail-title">报废申请 <b style="color:#1565c0;">#' + row.id + '</b>' +
                    (isHistory ? ' <span style="font-size:11px;color:#90a4ae;">（历史记录）</span>' : '') + '</div>' +
                    dangerHtml +
                    '<div class="info-card">' +
                    '<div class="info-row"><span class="lbl">实验室：</span><span class="val">' + (row.lab_name || '—') + '</span></div>' +
                    '<div class="info-row"><span class="lbl">申请人：</span><span class="val">' + (row.apply_user_name || '—') + '</span></div>' +
                    '<div class="info-row"><span class="lbl">耗材：</span><span class="val"><b>' + (row.consumable_name || '—') + '</b>（' + (row.unit || '') + '）</span></div>' +
                    '<div class="info-row"><span class="lbl">报废数量：</span><span class="val"><b style="color:#e53935;font-size:15px;">' + row.quantity + '</b> ' + (row.unit || '') + '</span></div>' +
                    '<div class="info-row"><span class="lbl">申请时间：</span><span class="val">' + (row.apply_time ? String(row.apply_time).substring(0, 16).replace('T', ' ') : '—') + '</span></div>' +
                    '<div class="info-row"><span class="lbl">状态：</span><span class="val">' + statusHtml + '</span></div>' +
                    auditSection +
                    '</div>' +
                    '<div style="font-size:12px;font-weight:bold;color:#546e7a;margin-bottom:6px;">报废原因：</div>' +
                    '<div class="reason-box">' + (row.reason || '—').replace(/</g, '&lt;') + '</div>' +
                    rejectSection +
                    actionTip
                );
            }

            /* ===== 审核通过（二次确认） ===== */
            function doPass() {
                if (!_selRow) { $.messager.alert('提示', '请先在「待审核」列表中选择一条记录', 'warning'); return; }
                var row = _selRow;
                // 第一次确认
                $.messager.confirm('确认审核通过',
                    '确认通过报废申请 <b>#' + row.id + '</b>？<br>' +
                    '通过后将立即扣减库存 <b style="color:#e53935;">-' + row.quantity + ' ' + (row.unit || '') + '</b>，此操作不可撤销。',
                    function (r1) {
                        if (!r1) return;
                        // 第二次确认（防误操作）
                        $.messager.confirm('⚠ 再次确认',
                            '请再次确认：库存将扣减 <b style="color:#e53935;">' + row.quantity + ' ' + (row.unit || '') + '</b>，确定执行？',
                            function (r2) {
                                if (!r2) return;
                                $.messager.progress();
                                $.post(ctx + '/ServletScrap?action=audit', { id: row.id, pass: 1 }, function (ret) {
                                    $.messager.progress('close');
                                    var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                                    if (res.code == '200') {
                                        $.messager.show({ title: '✔ 审核通过', msg: res.msg, timeout: 2000, showType: 'slide' });
                                        $('#dgPending').datagrid('reload');
                                        $('#dgHistory').datagrid('reload');
                                        _selRow = null;
                                        $('#detailPanel').html('<div class="no-select">请点击左侧列表查看报废详情</div>');
                                    } else { $.messager.alert('提示', res.msg, 'warning'); }
                                });
                            }
                        );
                    }
                );
            }

            /* ===== 打开驳回弹窗 ===== */
            function openRejectDlg() {
                if (!_selRow) { $.messager.alert('提示', '请先在「待审核」列表中选择一条记录', 'warning'); return; }
                $('#rejectReasonInput').val('');
                $('#dlgReject').dialog('open');
            }

            /* ===== 确认驳回 ===== */
            function confirmReject() {
                var reason = $('#rejectReasonInput').val().trim();
                if (!reason) { $.messager.alert('提示', '请填写驳回理由', 'warning'); return; }
                var row = _selRow;
                $.messager.progress();
                $.post(ctx + '/ServletScrap?action=audit', { id: row.id, pass: 0, comment: reason }, function (ret) {
                    $.messager.progress('close');
                    var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                    if (res.code == '200') {
                        $('#dlgReject').dialog('close');
                        $.messager.show({ title: '已驳回', msg: res.msg, timeout: 2000, showType: 'slide' });
                        $('#dgPending').datagrid('reload');
                        $('#dgHistory').datagrid('reload');
                        _selRow = null;
                        $('#detailPanel').html('<div class="no-select">请点击左侧列表查看报废详情</div>');
                    } else { $.messager.alert('提示', res.msg, 'warning'); }
                });
            }
        </script>
    </body>

    </html>