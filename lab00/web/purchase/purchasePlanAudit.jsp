<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>采购计划审核</title>
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

            /* 工具栏 */
            .toolbar-wrap {
                background: #f0f4fa;
                border-bottom: 1px solid #dce6f5;
                padding: 6px 10px;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            /* 标签切换样式 */
            .tab-group {
                display: flex;
                align-items: flex-end;
                margin-right: 12px;
            }

            .tab-item {
                padding: 8px 20px;
                background: #e3eaf5;
                border: 1px solid #dce6f5;
                border-bottom: none;
                cursor: pointer;
                font-size: 13px;
                color: #546e7a;
                border-radius: 6px 6px 0 0;
                margin-right: 4px;
            }

            .tab-item:hover {
                background: #cfdcec;
            }

            .tab-item.active {
                background: #fff;
                color: #1565c0;
                border-color: #cfdcec;
                font-weight: bold;
                box-shadow: 0 -2px 4px rgba(0, 0, 0, 0.05);
            }

            /* 状态徽章 */
            .badge {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 12px;
                font-weight: bold;
                color: #fff;
            }

            .badge-pending {
                background: #f57c00;
            }

            .badge-pass {
                background: #43a047;
            }

            .badge-reject {
                background: #e53935;
            }

            /* 金额高亮 */
            .amount-cell {
                color: #1565c0;
                font-weight: bold;
            }

            /* 明细面板 */
            .detail-panel {
                height: 100%;
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

            .detail-info {
                background: #f8fafc;
                border-bottom: 1px solid #e3eaf5;
                padding: 8px 14px;
                font-size: 12px;
                color: #546e7a;
                flex-shrink: 0;
            }

            .detail-info span {
                margin-right: 20px;
            }

            .detail-info strong {
                color: #1565c0;
            }

            .detail-grid {
                flex: 1;
                overflow: hidden;
            }

            .detail-footer {
                background: #f0f4fa;
                border-top: 1px solid #dce6f5;
                padding: 6px 14px;
                font-size: 13px;
                color: #37474f;
                flex-shrink: 0;
            }

            /* 审核弹窗 */
            .audit-header {
                padding: 10px 14px;
                border-radius: 6px;
                margin-bottom: 14px;
                font-size: 13px;
                font-weight: bold;
            }

            .audit-pass {
                background: #e8f5e9;
                color: #2e7d32;
                border: 1px solid #a5d6a7;
            }

            .audit-reject {
                background: #ffebee;
                color: #c62828;
                border: 1px solid #ef9a9a;
            }

            .audit-info {
                font-size: 12px;
                color: #546e7a;
                margin-bottom: 10px;
            }

            .audit-info span {
                margin-right: 16px;
            }

            /* 空状态 */
            .empty-tip {
                text-align: center;
                padding: 40px 0;
                color: #b0bec5;
                font-size: 13px;
            }
        </style>
        <script>
            $(function () {
                var currentPlan = null;
                var viewMode = 'pending'; // pending=待审核, audited=已审核

                /* ===== 主列表 ===== */
                $('#dgPlan').datagrid({
                    url: '${pageContext.request.contextPath}/ServletPurchasePlan?action=listPending',
                    toolbar: '#tbPlan',
                    pagination: true,
                    fit: true,
                    singleSelect: true,
                    rownumbers: true,
                    striped: true,
                    pageSize: 10,
                    pageList: [10, 20, 50],
                    columns: [[
                        {
                            field: 'id', title: '计划编号', width: 75, align: 'center',
                            formatter: function (v) { return '<strong style="color:#1565c0;">P' + String(v).padStart(4, '0') + '</strong>'; }
                        },
                        { field: 'lab_name', title: '实验室', width: 180 },
                        { field: 'apply_user_name', title: '申请人', width: 100 },
                        {
                            field: 'total_amount', title: '预算总额(元)', width: 110, align: 'right',
                            formatter: function (v) { return v ? '<span class="amount-cell">¥ ' + parseFloat(v).toFixed(2) + '</span>' : '<span style="color:#90a4ae;">—</span>'; }
                        },
                        {
                            field: 'create_time', title: '提交时间', width: 150,
                            formatter: function (v) {
                                if (!v) return '—';
                                var s = String(v).replace('T', ' ').substring(0, 16);
                                return s;
                            }
                        },
                        {
                            field: 'audit_time', title: '审核时间', width: 150,
                            formatter: function (v, row) {
                                if (viewMode === 'pending') return '—';
                                if (!v) return '—';
                                return String(v).replace('T', ' ').substring(0, 16);
                            }
                        },
                        {
                            field: 'status', title: '状态', width: 80, align: 'center',
                            formatter: function (v) {
                                var map = { 0: '草稿', 1: '待审核', 2: '已通过', 3: '已退回' };
                                var cls = { 0: '', 1: 'badge-pending', 2: 'badge-pass', 3: 'badge-reject' };
                                return '<span class="badge ' + (cls[v] || '') + '">' + (map[v] || v) + '</span>';
                            }
                        }
                    ]],
                    onSelect: function (idx, row) {
                        currentPlan = row;
                        loadItems(row.id, row);
                    },
                    onLoadSuccess: function () {
                        currentPlan = null;
                        $('#dgItem').datagrid('loadData', { total: 0, rows: [] });
                        $('#detailInfo').html('<span>← 点击左侧列表选择采购计划查看明细</span>');
                        $('#detailFooter').text('');
                    }
                });

                /* ===== 明细列表 ===== */
                $('#dgItem').datagrid({
                    fit: true,
                    singleSelect: true,
                    rownumbers: true,
                    striped: true,
                    emptyMsg: '请先选择左侧采购计划',
                    columns: [[
                        { field: 'consumable_name', title: '耗材名称', width: 180 },
                        { field: 'unit', title: '单位', width: 55, align: 'center' },
                        { field: 'plan_quantity', title: '计划数量', width: 75, align: 'center' },
                        {
                            field: 'plan_price', title: '计划单价(元)', width: 100, align: 'right',
                            formatter: function (v) { return v ? '¥ ' + parseFloat(v).toFixed(2) : '—'; }
                        },
                        {
                            field: '_subtotal', title: '小计(元)', width: 100, align: 'right',
                            formatter: function (v, row) {
                                var qty = parseFloat(row.plan_quantity || 0);
                                var price = parseFloat(row.plan_price || 0);
                                var sub = qty * price;
                                return sub > 0 ? '<span style="color:#1565c0;">¥ ' + sub.toFixed(2) + '</span>' : '—';
                            }
                        },
                        {
                            field: 'remark', title: '备注', width: 120,
                            formatter: function (v) { return v || '—'; }
                        }
                    ]]
                });

                function loadItems(planId, plan) {
                    $.getJSON('${pageContext.request.contextPath}/ServletPurchasePlan?action=getItems',
                        { plan_id: planId }, function (data) {
                            $('#dgItem').datagrid('loadData', data);
                            // 计算合计
                            var total = 0;
                            $.each(data, function (i, row) {
                                total += parseFloat(row.plan_quantity || 0) * parseFloat(row.plan_price || 0);
                            });
                            var infoHtml = '<span>实验室：<strong>' + (plan.lab_name || '—') + '</strong></span>'
                                + '<span>申请人：<strong>' + (plan.apply_user_name || '—') + '</strong></span>'
                                + '<span>共 <strong>' + data.length + '</strong> 种耗材</span>';
                            $('#detailInfo').html(infoHtml);
                            $('#detailFooter').html('合计预算：<strong style="color:#1565c0;font-size:14px;">¥ ' + total.toFixed(2) + '</strong>');
                        });
                }

                /* ===== 审核操作 ===== */
                function openAuditDlg(pass) {
                    if (!currentPlan) { $.messager.alert('提示', '请先选择一条采购计划', 'warning'); return; }
                    $('#auditResult').val(pass);
                    var isPass = (pass == '1');
                    $('#auditHeader').attr('class', 'audit-header ' + (isPass ? 'audit-pass' : 'audit-reject'));
                    $('#auditHeader').text(isPass ? '✔ 审核通过' : '✘ 退回申请');
                    $('#auditPlanInfo').html(
                        '<span>计划编号：<strong>P' + String(currentPlan.id).padStart(4, '0') + '</strong></span>'
                        + '<span>实验室：<strong>' + (currentPlan.lab_name || '—') + '</strong></span>'
                        + '<span>预算：<strong>¥ ' + parseFloat(currentPlan.total_amount || 0).toFixed(2) + '</strong></span>'
                    );
                    $('#comment').textbox('setValue', '');
                    $('#dlgAudit').dialog('open');
                }

                $('#btnPass').click(function () { openAuditDlg('1'); });
                $('#btnReject').click(function () { openAuditDlg('0'); });

                $('#btnSaveAudit').click(function () {
                    if (!currentPlan) return;
                    var pass = $('#auditResult').val();
                    var comment = $('#comment').textbox('getValue').trim();
                    if (pass == '0' && !comment) {
                        $.messager.alert('提示', '退回时请填写审核意见', 'warning');
                        return;
                    }
                    $.messager.progress();
                    $.post('${pageContext.request.contextPath}/ServletPurchasePlan?action=audit',
                        { id: currentPlan.id, pass: pass, comment: comment }, function (ret) {
                            $.messager.progress('close');
                            var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                            if (r.code == '200') {
                                $.messager.show({ title: '提示', msg: r.msg, timeout: 1800, showType: 'slide' });
                                $('#dlgAudit').dialog('close');
                                currentPlan = null;
                                $('#dgPlan').datagrid('reload');
                                $('#dgItem').datagrid('loadData', { total: 0, rows: [] });
                                $('#detailInfo').html('<span>← 点击左侧列表选择采购计划查看明细</span>');
                                $('#detailFooter').text('');
                            } else {
                                $.messager.alert('提示', r.msg, 'warning');
                            }
                        });
                });

                /* ===== 切换视图模式 ===== */
                function switchViewMode(mode) {
                    viewMode = mode;
                    if (mode === 'pending') {
                        $('#dgPlan').datagrid('options').url = '${pageContext.request.contextPath}/ServletPurchasePlan?action=listPending';
                        $('#dgPlan').datagrid('reload');
                        $('#btnPass').show();
                        $('#btnReject').show();
                        $('#tabPending').addClass('active');
                        $('#tabAudited').removeClass('active');
                    } else {
                        $('#dgPlan').datagrid('options').url = '${pageContext.request.contextPath}/ServletPurchasePlan?action=listAudited';
                        $('#dgPlan').datagrid('reload');
                        $('#btnPass').hide();
                        $('#btnReject').hide();
                        $('#tabPending').removeClass('active');
                        $('#tabAudited').addClass('active');
                    }
                }
                $('#tabPending').click(function () { switchViewMode('pending'); });
                $('#tabAudited').click(function () { switchViewMode('audited'); });

                /* ===== 刷新 ===== */
                $('#btnRefresh').click(function () { $('#dgPlan').datagrid('reload'); });
            });
        </script>
    </head>

    <body style="font-family:'微软雅黑',sans-serif;height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">✅</span>
            采购计划审核
            <span class="sub">系统管理员审核实验室的采购计划</span>
        </div>

        <div style="height:calc(100% - 44px);display:flex;flex-direction:column;">
            <!-- 工具栏 -->
            <div class="toolbar-wrap" id="tbPlan" style="flex-shrink:0;">
                <div class="tab-group">
                    <div id="tabPending" class="tab-item active">待审核</div>
                    <div id="tabAudited" class="tab-item">已审核</div>
                </div>
                <span style="border-left:1px solid #dce6f5;height:22px;margin:0 10px;"></span>
                <a id="btnPass" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-ok'">审核通过</a>
                <a id="btnReject" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-cancel'">退回申请</a>
                <span style="border-left:1px solid #ccc;height:18px;margin:0 4px;"></span>
                <a id="btnRefresh" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-reload',plain:true">刷新</a>
                <span style="font-size:12px;color:#90a4ae;margin-left:8px;">
                    提示：选中左侧计划后可在右侧查看明细
                </span>
            </div>

            <div style="flex:1;display:flex;overflow:hidden;">
                <!-- 主列表（左） -->
                <div style="flex:1;overflow:hidden;">
                    <table id="dgPlan"></table>
                </div>

                <!-- 明细面板（右） -->
                <div style="width:480px;border-left:1px solid #dce6f5;display:flex;flex-direction:column;">
                    <div class="detail-panel" style="flex:1;">
                        <div class="detail-header">📋 采购计划明细</div>
                        <div class="detail-info" id="detailInfo">
                            <span>← 点击左侧列表选择采购计划查看明细</span>
                        </div>
                        <div class="detail-grid" style="flex:1;">
                            <table id="dgItem" style="width:100%;height:100%;"></table>
                        </div>
                        <div class="detail-footer" id="detailFooter"></div>
                    </div>
                </div>
            </div>

            <!-- ===== 审核弹窗 ===== -->
            <div id="dlgAudit" class="easyui-dialog" style="width:460px;padding:16px 20px;"
                data-options="closed:true,modal:true,title:'审核确认',buttons:'#dlgAuditBtns'">
                <input type="hidden" id="auditResult">
                <div id="auditHeader" class="audit-header audit-pass">✔ 审核通过</div>
                <div class="audit-info" id="auditPlanInfo"></div>
                <div style="margin-bottom:6px;">
                    <label style="font-size:13px;color:#546e7a;font-weight:600;display:block;margin-bottom:6px;">
                        审核意见
                        <span style="font-weight:normal;color:#90a4ae;">（退回时必填，通过时选填）</span>
                    </label>
                    <input id="comment" class="easyui-textbox" style="width:100%;height:90px"
                        data-options="multiline:true,prompt:'请输入审核意见...'">
                </div>
            </div>
            <div id="dlgAuditBtns">
                <a id="btnSaveAudit" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-ok'">确认提交</a>
                <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'"
                    onclick="$('#dlgAudit').dialog('close')">取消</a>
            </div>

    </body>

    </html>