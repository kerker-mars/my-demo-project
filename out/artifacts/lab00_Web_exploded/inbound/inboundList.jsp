<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>入库登记</title>
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

            .tb-wrap {
                background: #f0f4fa;
                border-bottom: 1px solid #dce6f5;
                padding: 6px 10px;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            /* 状态徽章 */
            .badge-done {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 12px;
                font-weight: bold;
                background: #43a047;
                color: #fff;
            }

            .badge-partial {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 12px;
                font-weight: bold;
                background: #f57c00;
                color: #fff;
            }

            /* 弹窗两列布局 */
            .dlg-layout {
                display: flex;
                height: 100%;
                gap: 0;
            }

            .dlg-left {
                width: 260px;
                flex-shrink: 0;
                border-right: 1px solid #e8eef7;
                padding: 14px 16px;
                background: #f8fafc;
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .dlg-right {
                flex: 1;
                display: flex;
                flex-direction: column;
                padding: 10px 12px;
                overflow: hidden;
            }

            .f-label {
                font-size: 12px;
                color: #546e7a;
                font-weight: 600;
                display: block;
                margin-bottom: 4px;
            }

            .f-input {
                width: 100%;
                height: 28px;
                border: 1px solid #cfd8dc;
                border-radius: 4px;
                padding: 0 8px;
                font-size: 13px;
                font-family: "微软雅黑";
                outline: none;
            }

            .f-input:focus {
                border-color: #1976d2;
            }

            .f-input.err {
                border-color: #e53935;
                background: #fff8f8;
            }

            .f-err {
                color: #e53935;
                font-size: 11px;
                min-height: 13px;
                display: block;
            }

            /* 明细表格 */
            .item-table-wrap {
                flex: 1;
                overflow: auto;
                border: 1px solid #e8eef7;
                border-radius: 6px;
            }

            .item-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 12px;
            }

            .item-table th {
                background: #f0f4fa;
                padding: 7px 8px;
                text-align: left;
                border-bottom: 1px solid #e3eaf5;
                color: #546e7a;
                white-space: nowrap;
            }

            .item-table td {
                padding: 6px 8px;
                border-bottom: 1px solid #f5f5f5;
                vertical-align: middle;
            }

            .item-table tr:last-child td {
                border-bottom: none;
            }

            .item-table tr:hover td {
                background: #f5f9ff;
            }

            /* 明细工具栏 */
            .item-tb {
                display: flex;
                align-items: center;
                gap: 6px;
                padding: 6px 0;
                flex-shrink: 0;
            }

            .item-tb-btn {
                font-size: 12px;
                padding: 3px 10px;
                border: 1px solid #90caf9;
                border-radius: 4px;
                background: #e3f2fd;
                color: #1976d2;
                cursor: pointer;
            }

            .item-tb-btn:hover {
                background: #1976d2;
                color: #fff;
            }

            .item-tb-btn.danger {
                border-color: #ef9a9a;
                background: #ffebee;
                color: #e53935;
            }

            .item-tb-btn.danger:hover {
                background: #e53935;
                color: #fff;
            }

            /* 明细行内联输入 */
            .cell-input {
                width: 100%;
                height: 24px;
                border: 1px solid #cfd8dc;
                border-radius: 3px;
                padding: 0 5px;
                font-size: 12px;
                font-family: "微软雅黑";
                outline: none;
            }

            .cell-input:focus {
                border-color: #1976d2;
            }

            .cell-input.err {
                border-color: #e53935;
                background: #fff8f8;
            }

            /* 弹窗底部 */
            .dlg-foot {
                padding: 8px 12px;
                border-top: 1px solid #e8eef7;
                display: flex;
                justify-content: flex-end;
                gap: 8px;
                flex-shrink: 0;
            }

            .btn-primary {
                background: #1976d2;
                color: #fff;
                border: none;
                border-radius: 5px;
                padding: 6px 18px;
                font-size: 13px;
                cursor: pointer;
                font-family: "微软雅黑";
            }

            .btn-primary:hover {
                background: #1565c0;
            }

            .btn-default {
                background: #eceff1;
                color: #546e7a;
                border: none;
                border-radius: 5px;
                padding: 6px 18px;
                font-size: 13px;
                cursor: pointer;
                font-family: "微软雅黑";
            }

            /* 危化品警告 */
            .danger-warn {
                background: #fff3e0;
                border: 1px solid #ffcc80;
                border-radius: 4px;
                padding: 6px 10px;
                font-size: 12px;
                color: #e65100;
                display: none;
                margin-top: 6px;
            }
        </style>
        <script>
            $(function () {
                var ctx = '${pageContext.request.contextPath}';

                /* ===== 主列表 ===== */
                $('#dgInbound').datagrid({
                    url: ctx + '/ServletInbound?action=list',
                    toolbar: '#tbInbound',
                    pagination: true,
                    fit: true,
                    singleSelect: true,
                    rownumbers: true,
                    striped: true,
                    pageSize: 10,
                    pageList: [10, 20, 50],
                    columns: [[
                        {
                            field: 'id', title: '入库单号', width: 75, align: 'center',
                            formatter: function (v) { return '<b style="color:#1565c0;">RK' + String(v).padStart(4, '0') + '</b>'; }
                        },
                        { field: 'lab_name', title: '实验室', minWidth: 160, formatter: function (v) { return v || '—'; } },
                        { field: 'plan_info', title: '关联采购计划', minWidth: 200, formatter: function (v) { return v || '—'; } },
                        { field: 'inbound_user_name', title: '入库人', width: 90 },
                        { field: 'supplier', title: '供应商', width: 130, formatter: function (v) { return v || '—'; } },
                        {
                            field: 'inbound_time', title: '入库时间', width: 150,
                            formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                        },
                        {
                            field: 'inbound_status', title: '入库状态', width: 90, align: 'center',
                            formatter: function (v) {
                                if (v === '已完成') return '<span class="badge-done">已完成</span>';
                                return '<span class="badge-partial">部分入库</span>';
                            }
                        }
                    ]],
                    onSelect: function (idx, row) { loadItems(row.id); },
                    onLoadSuccess: function () {
                        $('#dgItem').datagrid('loadData', { total: 0, rows: [] });
                        $('#detailTitle').text('入库明细（请点击左侧列表选择）');
                    }
                });

                /* ===== 右侧明细 ===== */
                $('#dgItem').datagrid({
                    fit: true, singleSelect: true, rownumbers: true, striped: true,
                    emptyMsg: '请先选择左侧入库单',
                    columns: [[
                        {
                            field: 'consumable_name', title: '耗材名称', width: 180,
                            formatter: function (v) {
                                return '<div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%;" title="' + (v || '') + '">' + (v || '—') + '</div>';
                            }
                        },
                        { field: 'unit', title: '单位', width: 55, align: 'center' },
                        { field: 'quantity', title: '入库数量', width: 75, align: 'center' },
                        {
                            field: 'unit_price', title: '单价(元)', width: 90, align: 'right',
                            formatter: function (v) {
                                var val = v ? '¥ ' + parseFloat(v).toFixed(2) : '—';
                                return '<div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%;" title="' + val + '">' + val + '</div>';
                            }
                        },
                        {
                            field: 'batch_no', title: '批次号', width: 130,
                            formatter: function (v) {
                                return '<div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%;" title="' + (v || '') + '">' + (v || '—') + '</div>';
                            }
                        },
                        {
                            field: 'product_date', title: '生产日期', width: 100,
                            formatter: function (v) {
                                if (!v) return '—';
                                var d = new Date(v);
                                if (isNaN(d.getTime())) return String(v).substring(0, 10);
                                var mm = String(d.getMonth() + 1).padStart(2, '0');
                                var dd = String(d.getDate()).padStart(2, '0');
                                var yyyy = d.getFullYear();
                                var fmt = mm + '/' + dd + '/' + yyyy;
                                return '<div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%;" title="' + fmt + '">' + fmt + '</div>';
                            }
                        },
                        {
                            field: 'expire_date', title: '失效日期', width: 100,
                            formatter: function (v) {
                                if (!v) return '—';
                                var d = new Date(v);
                                if (isNaN(d.getTime())) return String(v).substring(0, 10);
                                var mm = String(d.getMonth() + 1).padStart(2, '0');
                                var dd = String(d.getDate()).padStart(2, '0');
                                var yyyy = d.getFullYear();
                                var fmt = mm + '/' + dd + '/' + yyyy;
                                return '<div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%;" title="' + fmt + '">' + fmt + '</div>';
                            }
                        }
                    ]]
                });

                function loadItems(inboundId) {
                    $.getJSON(ctx + '/ServletInbound?action=getItems', { inbound_id: inboundId }, function (data) {
                        var rows = data || [];
                        $('#dgItem').datagrid('loadData', { total: rows.length, rows: rows });
                        $('#detailTitle').text('入库明细（共 ' + rows.length + ' 条）');
                    });
                }

                /* ===== 新建入库单弹窗 ===== */
                var itemRows = [];          // 内存中的明细行
                var currentPlanId = null;   // 当前选中的采购计划ID
                var planData = {};          // 存储所有计划的耗材数据 {plan_id: {consumables: {...}, remaining: {...}}}
                var rowSeq = 0;             // 行序号，用于批次号生成

                $('#btnAddInbound').click(function () { openInboundDlg(); });

                function openInboundDlg() {
                    itemRows = []; currentPlanId = null; planData = {}; rowSeq = 0;
                    $('#dlgInbound').dialog('open');
                    $('#dlgInbound').dialog('setTitle', '新建入库单');
                    // 重置左侧表单
                    $('#txtSupplier').val('');
                    $('#dangerWarn').hide();
                    // 加载可用采购计划（会自动选中第一个）
                    loadPlanOptions();
                    renderItemTable();
                }

                function loadPlanOptions() {
                    $.getJSON(ctx + '/ServletInbound?action=planOptionsAvailable', function (data) {
                        var opts = '';
                        (data || []).forEach(function (p) {
                            opts += '<option value="' + p.id + '">' + p.text + '</option>';
                        });
                        if (!opts) {
                            opts = '<option value="" disabled>暂无可用采购计划</option>';
                        }
                        $('#selPlan').html(opts);
                        // 默认选中第一个计划并触发加载
                        var firstVal = $('#selPlan').val();
                        if (firstVal) {
                            currentPlanId = firstVal;
                            $('#selPlan').trigger('change');
                        }
                    });
                }

                // 选择采购计划后自动加载剩余耗材
                $('#selPlan').on('change', function () {
                    var pid = $(this).val();
                    currentPlanId = pid;
                    if (!pid) {
                        itemRows = []; // 清空明细
                        renderItemTable();
                        return;
                    }

                    // 如果该计划的数据已经加载过，直接使用
                    if (planData[pid]) {
                        // 自动添加所有未入库的耗材明细
                        autoAddAllPlanItems(pid);
                        return;
                    }

                    // 加载新计划的耗材数据
                    $.getJSON(ctx + '/ServletInbound?action=planRemaining', { plan_id: pid }, function (data) {
                        var consumables = {};
                        var remaining = {};
                        (data || []).forEach(function (r) {
                            var cid = parseInt(r.consumable_id);
                            remaining[cid] = parseInt(r.remaining_qty || 0);
                            consumables[cid] = {
                                name: r.consumable_name, unit: r.unit,
                                plan_price: r.plan_price, is_dangerous: parseInt(r.is_dangerous || 0)
                            };
                        });
                        planData[pid] = { consumables: consumables, remaining: remaining };
                        // 自动添加所有未入库的耗材明细
                        autoAddAllPlanItems(pid);
                    });
                });

                // 自动添加采购计划中所有未入库的耗材明细
                function autoAddAllPlanItems(planId) {
                    var planInfo = planData[planId];
                    if (!planInfo || Object.keys(planInfo.remaining).length === 0) {
                        itemRows = [];
                        renderItemTable();
                        return;
                    }

                    // 清空现有明细，重新添加所有未入库的耗材
                    itemRows = [];
                    var keys = Object.keys(planInfo.remaining);
                    keys.forEach(function (cidStr, index) {
                        var cid = parseInt(cidStr);
                        var info = planInfo.consumables[cid];
                        rowSeq++;
                        itemRows.push({
                            consumable_id: cid,
                            consumable_name: info.name,
                            unit: info.unit,
                            quantity: planInfo.remaining[cid],
                            unit_price: info.plan_price || '',
                            batch_no: '',
                            product_date: '',
                            expire_date: '',
                            is_dangerous: info.is_dangerous,
                            _seq: rowSeq,
                            _maxQty: planInfo.remaining[cid],
                            _planId: planId
                        });
                        // 自动生成批次号
                        autoGenBatchNo(itemRows.length - 1);
                    });
                    renderItemTable();
                    // 检查是否存在危险品
                    checkDangerItems();
                }

                // 检查是否存在危险品
                function checkDangerItems() {
                    var hasDanger = itemRows.some(function (r) { return r.is_dangerous; });
                    if (hasDanger) {
                        $('#dangerWarn').show();
                    } else {
                        $('#dangerWarn').hide();
                    }
                }

                /* ===== 添加明细行 ===== */
                $('#btnAddItem').click(function () {
                    var pid = $('#selPlan').val();
                    if (!pid) {
                        $.messager.alert('提示', '请先选择采购计划', 'info');
                        return;
                    }
                    // 关联采购计划：从剩余耗材中选择
                    var planInfo = planData[pid];
                    if (!planInfo || Object.keys(planInfo.remaining).length === 0) {
                        $.messager.alert('提示', '该采购计划所有耗材已完全入库', 'info');
                        return;
                    }
                    // 找第一个未在 itemRows 中的耗材
                    var firstCid = null;
                    var keys = Object.keys(planInfo.remaining);
                    for (var i = 0; i < keys.length; i++) {
                        var cid = parseInt(keys[i]);
                        var already = itemRows.some(function (r) { return r.consumable_id === cid; });
                        if (!already) { firstCid = cid; break; }
                    }
                    if (firstCid === null) {
                        $.messager.alert('提示', '所有可入库耗材已添加到明细中', 'info');
                        return;
                    }
                    var info = planInfo.consumables[firstCid];
                    rowSeq++;
                    var today = getTodayStr();
                    itemRows.push({
                        consumable_id: firstCid,
                        consumable_name: info.name,
                        unit: info.unit,
                        quantity: planInfo.remaining[firstCid],
                        unit_price: info.plan_price || '',
                        batch_no: '',
                        product_date: '',
                        expire_date: '',
                        is_dangerous: info.is_dangerous,
                        _seq: rowSeq,
                        _maxQty: planInfo.remaining[firstCid],
                        _planId: pid // 保存该明细行对应的采购计划ID
                    });
                    renderItemTable();
                    // 自动生成批次号（最后一行）
                    autoGenBatchNo(itemRows.length - 1);
                });

                function autoGenBatchNo(idx) {
                    var seq = idx + 1;
                    $.getJSON(ctx + '/ServletInbound?action=genBatchNo', { seq: seq }, function (d) {
                        if (d && d.batch_no) {
                            itemRows[idx].batch_no = d.batch_no;
                            renderItemTable();
                        }
                    });
                }

                window.removeItemRow = function (idx) {
                    itemRows.splice(idx, 1);
                    renderItemTable();
                };

                // 行内编辑：字段变更回写到 itemRows
                window.onItemChange = function (idx, field, val) {
                    if (!itemRows[idx]) return;
                    itemRows[idx][field] = val;
                    // 耗材选择变更时更新单位/单价/危化品标记
                    if (field === 'consumable_id') {
                        var cid = parseInt(val);
                        var planId = itemRows[idx]._planId;
                        if (planId && planData[planId]) {
                            var info = planData[planId].consumables[cid];
                            if (info) {
                                itemRows[idx].consumable_name = info.name;
                                itemRows[idx].unit = info.unit;
                                itemRows[idx].unit_price = info.plan_price || '';
                                itemRows[idx].is_dangerous = info.is_dangerous;
                                itemRows[idx].quantity = planData[planId].remaining[cid] || '';
                                itemRows[idx]._maxQty = planData[planId].remaining[cid] || 999999;
                                renderItemTable();
                                autoGenBatchNo(idx);
                            }
                        }
                    }
                };

                function renderItemTable() {
                    var html = '';
                    if (itemRows.length === 0) {
                        html = '<tr><td colspan="9" style="text-align:center;padding:20px;color:#b0bec5;">暂无明细，点击"添加明细"</td></tr>';
                    } else {
                        itemRows.forEach(function (r, i) {
                            var consumableCell = '';
                            if (r._planId) {
                                // 关联采购计划：下拉选择对应计划的剩余耗材
                                var planInfo = planData[r._planId];
                                if (planInfo) {
                                    var opts = '';
                                    Object.keys(planInfo.consumables).forEach(function (cid) {
                                        var info = planInfo.consumables[cid];
                                        var sel = (parseInt(cid) === parseInt(r.consumable_id)) ? 'selected' : '';
                                        opts += '<option value="' + cid + '" ' + sel + '>' + info.name + '（' + info.unit + '）' + (info.is_dangerous ? '【危】' : '') + '</option>';
                                    });
                                    consumableCell = '<select class="cell-input" onchange="onItemChange(' + i + ',\'consumable_id\',this.value)" style="width:140px;" disabled>' + opts + '</select>';
                                } else {
                                    consumableCell = '<input class="cell-input" value="' + esc(r.consumable_name) + '" onchange="onItemChange(' + i + ',\'consumable_name\',this.value)" placeholder="耗材名称*" style="width:130px;">';
                                }
                            } else {
                                consumableCell = '<input class="cell-input" value="' + esc(r.consumable_name) + '" onchange="onItemChange(' + i + ',\'consumable_name\',this.value)" placeholder="耗材名称*" style="width:130px;">';
                            }
                            var dangerTag = r.is_dangerous ? '<span style="color:#e53935;font-size:10px;margin-left:3px;">⚠危</span>' : '';
                            html += '<tr>'
                                + '<td style="text-align:center;color:#90a4ae;">' + (i + 1) + '</td>'
                                + '<td>' + consumableCell + dangerTag + '</td>'
                                + '<td><input class="cell-input" value="' + esc(r.unit) + '" onchange="onItemChange(' + i + ',\'unit\',this.value)" style="width:50px;" ' + (r._planId ? 'readonly' : '') + '></td>'
                                + '<td><input class="cell-input" type="number" min="1" max="' + r._maxQty + '" value="' + esc(r.quantity) + '" onchange="onItemChange(' + i + ',\'quantity\',this.value)" style="width:65px;" ' + (r._planId ? '' : '') + '>'
                                + (r._planId ? '<span style="font-size:10px;color:#90a4ae;"> /' + r._maxQty + '</span>' : '') + '</td>'
                                + '<td><input class="cell-input" type="number" min="0" step="0.01" value="' + esc(r.unit_price) + '" onchange="onItemChange(' + i + ',\'unit_price\',this.value)" style="width:70px;"></td>'
                                + '<td><input class="cell-input" value="' + esc(r.batch_no) + '" style="width:110px;" readonly></td>'
                                + '<td><input class="cell-input" type="date" value="' + esc(r.product_date) + '" onchange="onItemChange(' + i + ',\'product_date\',this.value)" style="width:110px;"></td>'
                                + '<td><input class="cell-input" type="date" value="' + esc(r.expire_date) + '" onchange="onItemChange(' + i + ',\'expire_date\',this.value)" style="width:110px;"></td>'
                                + '<td style="text-align:center;"><button class="item-tb-btn danger" onclick="removeItemRow(' + i + ')">删除</button></td>'
                                + '</tr>';
                        });
                    }
                    $('#itemTbody').html(html);
                    // 更新明细数量统计
                    $('#itemCount').text(itemRows.length);
                }

                function esc(v) { return v == null ? '' : String(v).replace(/"/g, '&quot;'); }
                function getTodayStr() {
                    var d = new Date();
                    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
                }
                function pad(n) { return String(n).padStart(2, '0'); }

                /* ===== 保存入库 ===== */
                $('#btnSaveInbound').click(function () {
                    if (!validateItems()) return;
                    var payload = {
                        plan_id: $('#selPlan').val(),
                        supplier: $('#txtSupplier').val().trim(),
                        itemsJson: JSON.stringify(itemRows.map(function (r) {
                            return {
                                consumable_id: r.consumable_id,
                                quantity: r.quantity,
                                unit_price: r.unit_price,
                                batch_no: r.batch_no,
                                product_date: r.product_date || null,
                                expire_date: r.expire_date || null
                            };
                        }))
                    };
                    $.messager.progress();
                    $.ajax({
                        type: 'POST', url: ctx + '/ServletInbound?action=save', data: payload,
                        success: function (ret) {
                            $.messager.progress('close');
                            var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                            if (r.code == '200') {
                                $.messager.show({ title: '✔ 入库成功', msg: r.msg, timeout: 2000, showType: 'slide' });
                                $('#dlgInbound').dialog('close');
                                $('#dgInbound').datagrid('reload');
                                $('#dgItem').datagrid('loadData', { total: 0, rows: [] });
                            } else {
                                $.messager.alert('提示', r.msg, 'warning');
                            }
                        },
                        error: function () { $.messager.progress('close'); $.messager.alert('错误', '入库失败', 'error'); }
                    });
                });

                function validateItems() {
                    if (itemRows.length === 0) {
                        $.messager.alert('提示', '请添加至少一条入库明细', 'warning');
                        return false;
                    }
                    var today = new Date(); today.setHours(0, 0, 0, 0);
                    var errors = [];
                    var hasDangerExpireWarn = false;
                    // 重置所有输入框样式
                    $('.cell-input').removeClass('err');

                    for (var i = 0; i < itemRows.length; i++) {
                        var r = itemRows[i];
                        var row = i + 1;
                        // 必填
                        if (!r.consumable_name && !r.consumable_id) {
                            errors.push('第' + row + '行：耗材名称必填');
                            // 标红突出
                            $('#itemTbody tr').eq(i).find('select, input:first').addClass('err');
                        }
                        if (!r.quantity || parseFloat(r.quantity) <= 0) {
                            errors.push('第' + row + '行：入库数量必须为正数');
                            // 标红突出
                            $('#itemTbody tr').eq(i).find('input[type="number"]').eq(0).addClass('err');
                        }
                        if (!r.unit) {
                            errors.push('第' + row + '行：单位必填');
                            // 标红突出
                            $('#itemTbody tr').eq(i).find('input').eq(0).addClass('err');
                        }
                        if (r.unit_price === '' || r.unit_price === null || parseFloat(r.unit_price) < 0) {
                            errors.push('第' + row + '行：单价必须为非负数');
                            // 标红突出
                            $('#itemTbody tr').eq(i).find('input[type="number"]').eq(1).addClass('err');
                        }
                        if (!r.product_date) {
                            errors.push('第' + row + '行：生产日期必填');
                            // 标红突出
                            $('#itemTbody tr').eq(i).find('input[type="date"]').eq(0).addClass('err');
                        }
                        if (!r.expire_date) {
                            errors.push('第' + row + '行：失效日期必填');
                            // 标红突出
                            $('#itemTbody tr').eq(i).find('input[type="date"]').eq(1).addClass('err');
                        }
                        // 数量上限
                        if (r._maxQty && parseFloat(r.quantity) > r._maxQty) {
                            errors.push('第' + row + '行：入库数量超过剩余可入库量' + r._maxQty);
                            // 标红突出
                            $('#itemTbody tr').eq(i).find('input[type="number"]').eq(0).addClass('err');
                        }
                        // 日期校验
                        if (r.product_date) {
                            var pd = new Date(r.product_date);
                            if (pd > today) { errors.push('第' + row + '行：生产日期不能晚于今天'); }
                            if (r.expire_date) {
                                var ed = new Date(r.expire_date);
                                if (ed <= pd) { errors.push('第' + row + '行：失效日期必须晚于生产日期'); }
                                // 危化品：失效日期距今≥30天
                                if (r.is_dangerous) {
                                    var diff = Math.floor((ed - today) / (1000 * 60 * 60 * 24));
                                    if (diff < 30) { hasDangerExpireWarn = true; errors.push('第' + row + '行：危化品失效日期距今不足30天（剩余' + diff + '天），请确认'); }
                                }
                            }
                        }
                    }
                    if (errors.length > 0) {
                        if (errors.some(e => e.includes('必填'))) {
                            $.messager.alert('提示', '入库格式错误，请填写所有必填信息', 'warning');
                        } else if (errors.some(e => e.includes('超过'))) {
                            $.messager.alert('提示', '入库数量不能超过采购计划剩余可入库量，请修改', 'warning');
                        } else {
                            $.messager.alert('校验失败', '<ul style="margin:0;padding-left:16px;">' + errors.map(function (e) { return '<li>' + e + '</li>'; }).join('') + '</ul>', 'warning');
                        }
                        return false;
                    }
                    return true;
                }

                $('#btnCloseDlg').click(function () { $('#dlgInbound').dialog('close'); });
            });
        </script>
    </head>

    <body style="font-family:'微软雅黑',sans-serif;height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">📥</span>
            入库登记
            <span class="sub">实验室管理员可在此登记耗材入库，关联采购计划</span>
        </div>

        <div style="height:calc(100% - 44px);display:flex;flex-direction:column;">
            <!-- 工具栏 -->
            <div class="tb-wrap" id="tbInbound" style="flex-shrink:0;">
                <a id="btnAddInbound" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-add'">新建入库单</a>
            </div>

            <div style="flex:1;display:flex;overflow:hidden;">
                <!-- 主列表（左） -->
                <div style="flex:1;overflow:hidden;">
                    <table id="dgInbound"></table>
                </div>

                <!-- 明细面板（右） -->
                <div style="width:40%;border-left:1px solid #dce6f5;display:flex;flex-direction:column;">
                    <div style="height:100%;display:flex;flex-direction:column;">
                        <div style="background:linear-gradient(90deg,#1565c0,#1976d2);color:#fff;padding:8px 14px;font-size:13px;font-weight:bold;flex-shrink:0;"
                            id="detailTitle">
                            入库明细（请点击左侧列表选择）
                        </div>
                        <div style="flex:1;overflow:hidden;">
                            <table id="dgItem" style="width:100%;height:100%;"></table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ===== 新建入库单弹窗（两列布局） ===== -->
            <div id="dlgInbound" class="easyui-dialog" style="width:900px;height:520px;padding:0;"
                data-options="closed:true,modal:true,title:'新建入库单'">
                <div class="dlg-layout">
                    <!-- 左侧：基础信息 -->
                    <div class="dlg-left">
                        <div>
                            <label class="f-label">关联采购计划</label>
                            <select id="selPlan" class="f-input" style="height:30px;">
                            </select>
                            <span
                                style="font-size:11px;color:#90a4ae;margin-top:3px;display:block;">仅展示未完全入库的已通过计划</span>
                        </div>
                        <div>
                            <label class="f-label">供应商</label>
                            <input id="txtSupplier" type="text" class="f-input" placeholder="选填">
                        </div>
                        <div class="danger-warn" id="dangerWarn">
                            ⚠ 含危险化学品，请确保失效日期距今≥30天，并完成双人审批。
                        </div>
                        <div style="margin-top:auto;padding-top:12px;border-top:1px solid #e8eef7;">
                            <div style="font-size:12px;color:#78909c;line-height:1.8;">
                                <strong>入库说明：</strong><br>
                                • 关联采购计划时，数量不超过剩余可入库量<br>
                                • 批次号自动生成，支持手动修改（≤20位）<br>
                                • 危化品失效日期须距今≥30天
                            </div>
                        </div>
                    </div>

                    <!-- 右侧：明细表格 -->
                    <div class="dlg-right">
                        <div class="item-tb">
                            <button id="btnAddItem" class="item-tb-btn">+ 添加明细</button>
                            <span style="font-size:12px;color:#90a4ae;">共 <span id="itemCount">0</span> 条明细</span>
                        </div>
                        <div class="item-table-wrap">
                            <table class="item-table">
                                <thead>
                                    <tr>
                                        <th style="width:36px;">#</th>
                                        <th style="min-width:150px;">耗材名称</th>
                                        <th style="width:55px;">单位<span style="color:#e53935;">*</span></th>
                                        <th style="width:90px;">入库数量<span style="color:#e53935;">*</span></th>
                                        <th style="width:80px;">单价(元)<span style="color:#e53935;">*</span></th>
                                        <th style="width:120px;">批次号</th>
                                        <th style="width:115px;">生产日期<span style="color:#e53935;">*</span></th>
                                        <th style="width:115px;">失效日期<span style="color:#e53935;">*</span></th>
                                        <th style="width:50px;">操作</th>
                                    </tr>
                                </thead>
                                <tbody id="itemTbody">
                                    <tr>
                                        <td colspan="9" style="text-align:center;padding:20px;color:#b0bec5;">
                                            暂无明细，点击"添加明细"
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="dlg-foot">
                            <button id="btnSaveInbound" class="btn-primary">💾 保存入库</button>
                            <button id="btnCloseDlg" class="btn-default">关闭</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </body>

    </html>