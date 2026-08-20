<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>采购计划填报</title>
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

            /* 状态徽章 */
            .badge {
                display: inline-block;
                padding: 2px 10px;
                border-radius: 10px;
                font-size: 12px;
                font-weight: bold;
                color: #fff;
            }

            .badge-draft {
                background: #90a4ae;
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

            /* 工具栏 */
            .tb-wrap {
                background: #f0f4fa;
                border-bottom: 1px solid #dce6f5;
                padding: 6px 10px;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            /* 弹窗表单 */
            .item-form-row {
                display: flex;
                gap: 12px;
                margin-bottom: 10px;
            }

            .item-form-col {
                flex: 1;
            }

            .item-form-col label {
                display: block;
                font-size: 12px;
                color: #546e7a;
                font-weight: 600;
                margin-bottom: 4px;
            }

            .f-err {
                color: #e53935;
                font-size: 11px;
                min-height: 13px;
                display: block;
            }

            /* 明细工具栏 */
            .item-tb {
                background: #f8fafc;
                border-bottom: 1px solid #e8eef7;
                padding: 5px 8px;
                display: flex;
                gap: 6px;
            }

            /* 金额合计 */
            .total-bar {
                background: #e3f2fd;
                border-top: 1px solid #90caf9;
                padding: 6px 14px;
                font-size: 13px;
                color: #1565c0;
                font-weight: bold;
                text-align: right;
            }
        </style>
        <script>
            $(function () {
                var ctx = '${pageContext.request.contextPath}';

                /* ===== 主列表 ===== */
                $('#dgPlan').datagrid({
                    url: ctx + '/ServletPurchasePlan?action=listMine',
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
                            formatter: function (v) { return '<b style="color:#1565c0;">P' + String(v).padStart(4, '0') + '</b>'; }
                        },
                        { field: 'lab_name', title: '实验室', width: 180, formatter: function (v) { return v || '—'; } },
                        { field: 'apply_user_name', title: '申请人', width: 90 },
                        {
                            field: 'total_amount', title: '预算总额(元)', width: 110, align: 'right',
                            formatter: function (v) { return v ? '¥ ' + parseFloat(v).toFixed(2) : '—'; }
                        },
                        {
                            field: 'status', title: '状态', width: 90, align: 'center',
                            formatter: function (v) {
                                if (v == 0) return '<span class="badge badge-draft">草稿</span>';
                                if (v == 1) return '<span class="badge badge-pending">待审核</span>';
                                if (v == 2) return '<span class="badge badge-pass">已通过</span>';
                                if (v == 3) return '<span class="badge badge-reject">已退回</span>';
                                return v;
                            }
                        },
                        {
                            field: 'create_time', title: '创建时间', width: 150,
                            formatter: function (v) {
                                if (!v) return '—';
                                return String(v).substring(0, 16).replace('T', ' ');
                            }
                        },
                        {
                            field: 'audit_user_name', title: '审核人', width: 90,
                            formatter: function (v, row) {
                                if (row.status == 0 || row.status == 1) return '—';
                                return v || '—';
                            }
                        },
                        {
                            field: 'audit_time', title: '审核时间', width: 150,
                            formatter: function (v, row) {
                                if (row.status == 0 || row.status == 1) return '—';
                                if (!v) return '—';
                                return String(v).substring(0, 16).replace('T', ' ');
                            }
                        },
                        {
                            field: 'audit_comment', title: '审核意见', width: 160,
                            formatter: function (v) { return v || '—'; }
                        }
                    ]],
                    onSelect: function (idx, row) { loadItems(row.id); },
                    onLoadSuccess: function () {
                        $('#dgItem').datagrid('loadData', { total: 0, rows: [] });
                        $('#detailTitle').text('采购计划明细（请点击左侧列表选择）');
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* ===== 明细列表 ===== */
                $('#dgItem').datagrid({
                    fit: true, singleSelect: true, rownumbers: true, striped: true,
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
                            field: '_sub', title: '小计(元)', width: 100, align: 'right',
                            formatter: function (v, row) {
                                var s = parseFloat(row.plan_quantity || 0) * parseFloat(row.plan_price || 0);
                                return s > 0 ? '<span style="color:#1565c0;">¥ ' + s.toFixed(2) + '</span>' : '—';
                            }
                        },
                        { field: 'remark', title: '备注', width: 140, formatter: function (v) { return v || '—'; } }
                    ]]
                });

                function loadItems(planId) {
                    $.getJSON(ctx + '/ServletPurchasePlan?action=getItems', { plan_id: planId }, function (data) {
                        $('#dgItem').datagrid('loadData', data);
                        var total = 0;
                        $.each(data, function (i, r) { total += parseFloat(r.plan_quantity || 0) * parseFloat(r.plan_price || 0); });
                        $('#detailTitle').text('采购计划明细（共 ' + data.length + ' 种耗材，合计 ¥' + total.toFixed(2) + '）');
                    });
                }

                /* ===== 工具栏按钮 ===== */
                $('#btnAdd').click(function () { openDlg(null); });

                $('#btnEdit').click(function () {
                    var row = $('#dgPlan').datagrid('getSelected');
                    if (!row) { $.messager.alert('提示', '请选择采购计划', 'warning'); return; }
                    if (row.status != 0) { $.messager.alert('提示', '仅草稿状态可编辑', 'warning'); return; }
                    openDlg(row.id);
                });

                $('#btnDelete').click(function () {
                    var row = $('#dgPlan').datagrid('getSelected');
                    if (!row) { $.messager.alert('提示', '请选择采购计划', 'warning'); return; }
                    if (row.status != 0) { $.messager.alert('提示', '仅草稿状态可删除', 'warning'); return; }
                    $.messager.confirm('确认删除', '确定删除该草稿采购计划？删除后不可恢复。', function (y) {
                        if (!y) return;
                        $.get(ctx + '/ServletPurchasePlan?action=delete', { id: row.id }, function (ret) {
                            var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                            if (r.code == '200') {
                                $.messager.show({ title: '提示', msg: '删除成功', timeout: 1500, showType: 'slide' });
                                $('#dgPlan').datagrid('reload');
                                $('#dgItem').datagrid('loadData', { total: 0, rows: [] });
                            } else {
                                $.messager.alert('提示', r.msg, 'warning');
                            }
                        });
                    });
                });

                $('#btnSubmit').click(function () {
                    var row = $('#dgPlan').datagrid('getSelected');
                    if (!row) { $.messager.alert('提示', '请选择采购计划', 'warning'); return; }
                    if (row.status != 0) { $.messager.alert('提示', '仅草稿状态可提交审核', 'warning'); return; }
                    $.messager.confirm('确认提交', '提交后将进入管理员审核流程，是否继续？', function (y) {
                        if (!y) return;
                        $.post(ctx + '/ServletPurchasePlan?action=submit', { id: row.id }, function (ret) {
                            var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                            if (r.code == '200') { $.messager.alert('提示', r.msg, 'info'); $('#dgPlan').datagrid('reload'); }
                            else $.messager.alert('提示', r.msg, 'warning');
                        });
                    });
                });

                /* ===== 新增/编辑弹窗 ===== */
                var currentPlanId = '';
                var itemRows = [];   // 内存中的明细行

                // 耗材数据缓存
                var consumableCache = [];

                function loadConsumableOptions(cb) {
                    if (consumableCache.length > 0) { if (cb) cb(); return; }
                    $.getJSON(ctx + '/ServletOutbound?action=consumableOptions', function (data) {
                        consumableCache = data || [];
                        // 填充 select
                        var opts = '<option value="">-- 请选择耗材 --</option>';
                        consumableCache.forEach(function (c) {
                            opts += '<option value="' + c.id + '" data-unit="' + (c.unit || '') + '" data-name="' + (c.name || '') + '">' + c.text + '</option>';
                        });
                        $('#selConsumable').html(opts);
                        if (cb) cb();
                    });
                }

                function openDlg(planId) {
                    currentPlanId = planId || '';
                    itemRows = [];
                    $('#dlg').dialog('setTitle', '采购计划明细录入');
                    $('#dlg').dialog('open');
                    loadConsumableOptions(function () {
                        if (planId) {
                            $.getJSON(ctx + '/ServletPurchasePlan?action=getItems', { plan_id: planId }, function (data) {
                                itemRows = data || [];
                                renderItemTable();
                            });
                        } else {
                            renderItemTable();
                        }
                    });
                    clearItemForm();
                }

                function renderItemTable() {
                    var html = '';
                    var total = 0;
                    itemRows.forEach(function (r, i) {
                        var sub = parseFloat(r.plan_quantity || 0) * parseFloat(r.plan_price || 0);
                        total += sub;
                        html += '<tr>'
                            + '<td style="padding:5px 8px;">' + (r.consumable_name || '—') + '</td>'
                            + '<td style="padding:5px 8px;text-align:center;">' + (r.unit || '—') + '</td>'
                            + '<td style="padding:5px 8px;text-align:center;">' + (r.plan_quantity || 0) + '</td>'
                            + '<td style="padding:5px 8px;text-align:right;">¥ ' + parseFloat(r.plan_price || 0).toFixed(2) + '</td>'
                            + '<td style="padding:5px 8px;text-align:right;color:#1565c0;">¥ ' + sub.toFixed(2) + '</td>'
                            + '<td style="padding:5px 8px;">' + (r.remark || '') + '</td>'
                            + '<td style="padding:5px 8px;text-align:center;">'
                            + '<a href="javascript:void(0)" onclick="removeItemRow(' + i + ')" style="color:#e53935;font-size:12px;">删除</a>'
                            + '</td>'
                            + '</tr>';
                    });
                    if (!html) html = '<tr><td colspan="7" style="text-align:center;padding:20px;color:#b0bec5;">暂无明细，请添加耗材</td></tr>';
                    $('#itemTbody').html(html);
                    $('#itemTotal').text('合计：¥ ' + total.toFixed(2));
                }

                window.removeItemRow = function (i) {
                    itemRows.splice(i, 1);
                    renderItemTable();
                };

                // 耗材选择自动回填单位和单价
                $('#selConsumable').on('change', function () {
                    var id = $(this).val();
                    if (!id) { $('#txtUnit').val(''); $('#numPrice').val(''); return; }
                    var found = null;
                    consumableCache.forEach(function (c) { if (String(c.id) === String(id)) found = c; });
                    if (found) {
                        $('#txtUnit').val(found.unit || '');
                        // 单价不强制回填（耗材表无单价字段），留空让用户填
                    }
                });

                $('#btnAddItem').click(function () {
                    var id = $('#selConsumable').val();
                    if (!id) { $.messager.alert('提示', '请选择耗材', 'warning'); return; }
                    var qty = parseInt($('#numQty').val() || 0);
                    var priceStr = $('#numPrice').val();
                    var price = parseFloat(priceStr || -1);
                    if (qty <= 0) { $.messager.alert('提示', '计划数量必须大于0', 'warning'); return; }
                    if (priceStr === '' || priceStr === null || priceStr === undefined || isNaN(price)) {
                        $.messager.alert('提示', '计划单价为必填项，请填写', 'warning');
                        return;
                    }
                    if (price < 0) { $.messager.alert('提示', '计划单价不能为负数', 'warning'); return; }
                    var found = null;
                    consumableCache.forEach(function (c) { if (String(c.id) === String(id)) found = c; });
                    itemRows.push({
                        consumable_id: parseInt(id),
                        consumable_name: found ? found.name : id,
                        unit: found ? found.unit : '',
                        plan_quantity: qty,
                        plan_price: price,
                        remark: $('#txtRemark').val()
                    });
                    renderItemTable();
                    clearItemForm();
                });

                function clearItemForm() {
                    $('#selConsumable').val('');
                    $('#txtUnit').val('');
                    $('#numQty').val('');
                    $('#numPrice').val('');
                    $('#txtRemark').val('');
                }

                $('#btnSaveDraft').click(function () {
                    if (itemRows.length === 0) { $.messager.alert('提示', '请添加至少一条采购明细', 'warning'); return; }
                    var total = 0;
                    itemRows.forEach(function (r) { total += parseFloat(r.plan_quantity || 0) * parseFloat(r.plan_price || 0); });
                    $.messager.progress();
                    $.ajax({
                        type: 'POST',
                        url: ctx + '/ServletPurchasePlan?action=save',
                        data: { id: currentPlanId, total_amount: total, itemsJson: JSON.stringify(itemRows) },
                        success: function (ret) {
                            $.messager.progress('close');
                            var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                            if (r.code == '200') {
                                $.messager.show({ title: '提示', msg: r.msg, timeout: 1500, showType: 'slide' });
                                $('#dlg').dialog('close');
                                $('#dgPlan').datagrid('reload');
                            } else {
                                $.messager.alert('提示', r.msg, 'warning');
                            }
                        },
                        error: function () { $.messager.progress('close'); $.messager.alert('错误', '保存失败', 'error'); }
                    });
                });
            });
        </script>
    </head>

    <body style="font-family:'微软雅黑',sans-serif;height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">📋</span>
            采购计划填报
            <span class="sub">实验室管理员可在此创建、编辑采购计划并提交审核</span>
        </div>

        <div style="height:calc(100% - 44px);display:flex;flex-direction:column;">
            <!-- 工具栏 -->
            <div class="tb-wrap" id="tbPlan" style="flex-shrink:0;">
                <a id="btnAdd" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-add'">新增计划</a>
                <a id="btnEdit" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-edit'">编辑草稿</a>
                <a id="btnDelete" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-remove'">删除草稿</a>
                <a id="btnSubmit" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-ok'">提交审核</a>
            </div>

            <div style="flex:1;display:flex;overflow:hidden;">
                <!-- 主列表（左） -->
                <div style="flex:1;overflow:hidden;">
                    <table id="dgPlan"></table>
                </div>

                <!-- 明细面板（右） -->
                <div style="width:460px;border-left:1px solid #dce6f5;display:flex;flex-direction:column;">
                    <div style="height:100%;display:flex;flex-direction:column;">
                        <div style="background:linear-gradient(90deg,#1565c0,#1976d2);color:#fff;padding:8px 14px;font-size:13px;font-weight:bold;flex-shrink:0;"
                            id="detailTitle">
                            采购计划明细（请点击左侧列表选择）
                        </div>
                        <div style="flex:1;overflow:hidden;">
                            <table id="dgItem" style="width:100%;height:100%;"></table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ===== 新增/编辑弹窗 ===== -->
            <div id="dlg" class="easyui-dialog" style="width:700px;padding:0;"
                data-options="closed:true,modal:true,title:'采购计划明细录入',buttons:'#dlgBtns'">

                <!-- 添加明细区 -->
                <div style="padding:14px 16px;background:#f8fafc;border-bottom:1px solid #e8eef7;">
                    <div
                        style="font-size:13px;font-weight:bold;color:#1565c0;margin-bottom:10px;border-left:3px solid #1976d2;padding-left:8px;">
                        添加耗材明细</div>
                    <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;">
                        <div style="flex:2;min-width:160px;">
                            <label
                                style="font-size:12px;color:#546e7a;font-weight:600;display:block;margin-bottom:4px;">耗材
                                <span style="color:#e53935;">*</span></label>
                            <select id="selConsumable"
                                style="width:100%;height:28px;border:1px solid #cfd8dc;border-radius:4px;font-size:13px;padding:0 6px;font-family:'微软雅黑';">
                                <option value="">-- 请选择耗材 --</option>
                            </select>
                        </div>
                        <div style="flex:0.8;min-width:70px;">
                            <label
                                style="font-size:12px;color:#546e7a;font-weight:600;display:block;margin-bottom:4px;">单位</label>
                            <input id="txtUnit" type="text" readonly
                                style="width:100%;height:28px;border:1px solid #cfd8dc;border-radius:4px;font-size:13px;padding:0 6px;background:#f0f4fa;color:#78909c;">
                        </div>
                        <div style="flex:0.8;min-width:70px;">
                            <label
                                style="font-size:12px;color:#546e7a;font-weight:600;display:block;margin-bottom:4px;">数量
                                <span style="color:#e53935;">*</span></label>
                            <input id="numQty" type="number" min="1"
                                style="width:100%;height:28px;border:1px solid #cfd8dc;border-radius:4px;font-size:13px;padding:0 6px;"
                                placeholder="必填">
                        </div>
                        <div style="flex:0.8;min-width:80px;">
                            <label
                                style="font-size:12px;color:#546e7a;font-weight:600;display:block;margin-bottom:4px;">单价(元)
                                <span style="color:#e53935;">*</span></label>
                            <input id="numPrice" type="number" min="0" step="0.01"
                                style="width:100%;height:28px;border:1px solid #cfd8dc;border-radius:4px;font-size:13px;padding:0 6px;"
                                placeholder="必填">
                        </div>
                        <div style="flex:1.2;min-width:100px;">
                            <label
                                style="font-size:12px;color:#546e7a;font-weight:600;display:block;margin-bottom:4px;">备注</label>
                            <input id="txtRemark" type="text"
                                style="width:100%;height:28px;border:1px solid #cfd8dc;border-radius:4px;font-size:13px;padding:0 6px;"
                                placeholder="选填">
                        </div>
                        <div style="flex-shrink:0;">
                            <button id="btnAddItem"
                                style="height:28px;padding:0 14px;background:#1976d2;color:#fff;border:none;border-radius:4px;font-size:13px;cursor:pointer;font-family:'微软雅黑';">+
                                添加</button>
                        </div>
                    </div>
                </div>

                <!-- 明细列表 -->
                <div style="padding:10px 16px 0;">
                    <div
                        style="font-size:13px;font-weight:bold;color:#1565c0;margin-bottom:8px;border-left:3px solid #1976d2;padding-left:8px;">
                        已添加明细</div>
                    <div style="max-height:240px;overflow-y:auto;border:1px solid #e8eef7;border-radius:6px;">
                        <table style="width:100%;border-collapse:collapse;font-size:12px;">
                            <thead>
                                <tr style="background:#f0f4fa;position:sticky;top:0;">
                                    <th
                                        style="padding:7px 8px;text-align:left;border-bottom:1px solid #e3eaf5;color:#546e7a;">
                                        耗材名称</th>
                                    <th
                                        style="padding:7px 8px;text-align:center;border-bottom:1px solid #e3eaf5;color:#546e7a;width:50px;">
                                        单位</th>
                                    <th
                                        style="padding:7px 8px;text-align:center;border-bottom:1px solid #e3eaf5;color:#546e7a;width:65px;">
                                        数量</th>
                                    <th
                                        style="padding:7px 8px;text-align:right;border-bottom:1px solid #e3eaf5;color:#546e7a;width:90px;">
                                        单价(元)</th>
                                    <th
                                        style="padding:7px 8px;text-align:right;border-bottom:1px solid #e3eaf5;color:#546e7a;width:90px;">
                                        小计(元)</th>
                                    <th
                                        style="padding:7px 8px;text-align:left;border-bottom:1px solid #e3eaf5;color:#546e7a;">
                                        备注</th>
                                    <th
                                        style="padding:7px 8px;text-align:center;border-bottom:1px solid #e3eaf5;color:#546e7a;width:50px;">
                                        操作</th>
                                </tr>
                            </thead>
                            <tbody id="itemTbody">
                                <tr>
                                    <td colspan="7" style="text-align:center;padding:20px;color:#b0bec5;">暂无明细，请添加耗材
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="total-bar" id="itemTotal">合计：¥ 0.00</div>
                </div>
            </div>
            <div id="dlgBtns">
                <a href="javascript:void(0)" class="easyui-linkbutton" id="btnSaveDraft"
                    data-options="iconCls:'icon-save'">保存草稿</a>
                <a href="javascript:void(0)" class="easyui-linkbutton" onclick="$('#dlg').dialog('close')"
                    data-options="iconCls:'icon-cancel'">关闭</a>
            </div>
        </div>

    </body>

    </html>