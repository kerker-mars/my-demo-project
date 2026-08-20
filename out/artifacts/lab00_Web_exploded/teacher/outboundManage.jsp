﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>领用申请管理</title>
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
                background: #f0f4fa;
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

            /* ===== 通用 ===== */
            .badge-danger {
                display: inline-block;
                padding: 1px 7px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            /* 危化品高亮行 */
            .danger-row {
                background: #ffebee !important;
            }

            .badge-yes {
                display: inline-block;
                padding: 1px 7px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #1976d2;
                color: #fff;
            }

            .badge-no {
                display: inline-block;
                padding: 1px 7px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #90a4ae;
                color: #fff;
            }

            .s-1 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #78909c;
                color: #fff;
            }

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
                background: #2196F3;
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

            .s3 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #43a047;
                color: #fff;
            }

            .s4 {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #7b1fa2;
                color: #fff;
            }

            .btn-primary {
                background: linear-gradient(90deg, #1565c0, #1976d2) !important;
                color: #fff !important;
                border: none !important;
                border-radius: 5px !important;
                font-weight: bold;
            }

            /* ===== 申请表单 ===== */
            .form-card {
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 1px 6px rgba(21, 101, 192, .10);
                margin: 10px 12px 8px;
                padding: 12px 16px 10px;
            }

            .card-title {
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
                margin-bottom: 10px;
                padding-bottom: 6px;
                border-bottom: 2px solid #e3eaf5;
            }

            .form-row {
                display: flex;
                gap: 14px;
                flex-wrap: wrap;
                align-items: flex-start;
            }

            .form-item {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .form-item label {
                font-size: 12px;
                color: #546e7a;
                font-weight: 600;
            }

            .req {
                color: #e53935;
            }

            /* ===== 空状态 ===== */
            .empty-tip {
                text-align: center;
                padding: 30px 0;
                color: #b0bec5;
                font-size: 13px;
            }

            /* ===== 进度条 ===== */
            .progress-wrap {
                display: flex;
                align-items: center;
                gap: 0;
                padding: 16px 10px;
            }

            .progress-step {
                display: flex;
                flex-direction: column;
                align-items: center;
                flex: 1;
                position: relative;
            }

            .progress-step:not(:last-child)::after {
                content: '';
                position: absolute;
                top: 14px;
                left: 50%;
                width: 100%;
                height: 2px;
                background: #e0e0e0;
                z-index: 0;
            }

            .progress-step.done::after {
                background: #43a047;
            }

            .progress-step.active::after {
                background: #1976d2;
            }

            .step-dot {
                width: 28px;
                height: 28px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 12px;
                font-weight: bold;
                z-index: 1;
                position: relative;
            }

            .step-dot.done {
                background: #43a047;
                color: #fff;
            }

            .step-dot.active {
                background: #1976d2;
                color: #fff;
                box-shadow: 0 0 0 4px rgba(25, 118, 210, .2);
            }

            .step-dot.wait {
                background: #e0e0e0;
                color: #90a4ae;
            }

            .step-dot.reject {
                background: #e53935;
                color: #fff;
            }

            .step-label {
                font-size: 11px;
                color: #546e7a;
                margin-top: 5px;
                text-align: center;
            }

            .step-label.active {
                color: #1565c0;
                font-weight: bold;
            }

            .step-label.reject {
                color: #e53935;
                font-weight: bold;
            }

            /* ===== 筛选栏 ===== */
            .filter-bar {
                background: #f8fafc;
                border-bottom: 1px solid #dce6f5;
                padding: 6px 10px;
                display: flex;
                align-items: center;
                gap: 8px;
                flex-wrap: wrap;
            }

            /* ===== 弹窗表单行 ===== */
            .dlg-row {
                margin-bottom: 12px;
            }

            .dlg-row label {
                display: block;
                font-size: 12px;
                color: #546e7a;
                font-weight: 600;
                margin-bottom: 4px;
            }

            /* ===== 确认弹窗 ===== */
            .confirm-box {
                padding: 4px 0;
            }

            .confirm-box .c-line {
                padding: 5px 0;
                font-size: 13px;
                color: #37474f;
                border-bottom: 1px solid #f0f4fa;
            }

            .confirm-box .c-line:last-child {
                border-bottom: none;
            }

            .confirm-box .c-key {
                color: #78909c;
                margin-right: 6px;
            }

            .confirm-box .c-warn {
                color: #e53935;
                font-weight: bold;
            }

            /* 全局提示框 */
            .global-tip {
                background: #fff3e0;
                border-left: 4px solid #ff9800;
                padding: 10px 14px;
                font-size: 13px;
                color: #e65100;
                display: flex;
                align-items: center;
                gap: 8px;
            }
        </style>
        <script>
            var ctx = '${pageContext.request.contextPath}';
            var draftId = null; // 当前草稿ID

            /* ===== 加载最近的草稿数据 ===== */
            function loadLatestDraft() {
                $.getJSON(ctx + '/ServletOutbound?action=getLatestDraft', function (data) {
                    if (data && data.code == '200' && data.data) {
                        var draft = data.data;
                        draftId = draft.id;
                        // 回填课程、班级、用途
                        if (draft.course_name) {
                            $('#course_name').combobox('setValue', draft.course_name);
                            $('#course_name').combobox('setText', draft.course_name);
                        }
                        if (draft.class_name) {
                            $('#class_name').combobox('setValue', draft.class_name);
                            $('#class_name').combobox('setText', draft.class_name);
                        }
                        if (draft.purpose) {
                            $('#purpose').textbox('setValue', draft.purpose);
                        }
                        // 加载明细
                        if (draft.items && draft.items.length > 0) {
                            $('#dgItems').datagrid('loadData', { total: draft.items.length, rows: draft.items });
                            updateSummary();
                            $.messager.show({
                                title: '已加载草稿',
                                msg: '检测到未完成的草稿，已自动恢复',
                                timeout: 2500,
                                showType: 'slide'
                            });
                        }
                    }
                }).fail(function () { });
            }

            /* ===== 状态格式化 ===== */
            function fmtStatus(v, tip) {
                var map = {
                    '-1': ['草稿', 's-1', '已保存草稿，可继续编辑后提交'],
                    '0': ['待审核', 's0', '已提交，等待实验室管理员审核'],
                    '1': ['初审通过', 's1', '初审通过，等待出库或危化品二审'],
                    '2': ['已驳回', 's2', '申请被驳回，可查看原因后重新提交'],
                    '3': ['已出库', 's3', '耗材已出库，可前往归还登记'],
                    '4': ['二审通过', 's4', '危化品二审通过，等待出库']
                };
                var info = map[String(v)] || [v, 's0', ''];
                if (tip) return '<span class="' + info[1] + '" title="' + info[2] + '">' + info[0] + '</span>';
                return '<span class="' + info[1] + '">' + info[0] + '</span>';
            }

            $(function () {
                /* ===== 加载最近的草稿数据 ===== */
                loadLatestDraft();

                /* ===== Tab 切换 ===== */
                $('#mainTabs').tabs({
                    onSelect: function (title) {
                        if (title === '📂 我的领用记录') { $('#dgList').datagrid('reload'); }
                    }
                });

                /* ===== ① 申请表单 Tab ===== */
                // 课程下拉（不可编辑）
                $('#course_name').combobox({
                    url: ctx + '/ServletOutbound?action=courseOptions',
                    valueField: 'value', textField: 'text',
                    editable: false, panelHeight: 200,
                    prompt: '请选择课程名称'
                });
                // 班级下拉（不可编辑）
                $('#class_name').combobox({
                    url: ctx + '/ServletOutbound?action=classOptions',
                    valueField: 'value', textField: 'text',
                    editable: false, panelHeight: 200,
                    prompt: '请选择班级'
                });

                /* ===== 明细表格 ===== */
                $('#dgItems').datagrid({
                    fit: true, singleSelect: true, rownumbers: true,
                    toolbar: '#tbItems',
                    emptyMsg: '<div class="empty-tip">📦 暂无耗材明细，请点击「添加耗材」</div>',
                    columns: [[
                        { field: 'consumable_id', hidden: true },
                        {
                            field: 'consumable_name', title: '耗材名称', width: 200,
                            formatter: function (v, r) {
                                var d = r.is_dangerous == 1 ? ' <span class="badge-danger">危</span>' : '';
                                return '<span style="font-weight:500;">' + (v || '') + '</span>' + d;
                            }
                        },
                        { field: 'unit', title: '单位', width: 65, align: 'center' },
                        {
                            field: 'stock_qty', title: '当前库存', width: 90, align: 'center',
                            formatter: function (v) {
                                var n = parseInt(v || 0);
                                var c = n <= 0 ? '#e53935' : n <= 10 ? '#f57c00' : '#43a047';
                                return '<b style="color:' + c + ';">' + n + '</b>';
                            }
                        },
                        {
                            field: 'quantity', title: '申请数量', width: 90, align: 'center',
                            formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                        },
                        {
                            field: 'should_return', title: '需归还', width: 80, align: 'center',
                            formatter: function (v) {
                                return v == 1 ? '<span class="badge-yes">是</span>' : '<span class="badge-no">消耗品</span>';
                            }
                        },
                        { field: 'remark', title: '备注', width: 160, formatter: function (v) { return v || '—'; } },
                        {
                            field: '_op', title: '操作', width: 110, align: 'center',
                            formatter: function (v, r, idx) {
                                return '<a href="javascript:void(0)" onclick="editItem(' + idx + ')" style="color:#1976d2;font-size:12px;margin-right:8px;">编辑</a>'
                                    + '<a href="javascript:void(0)" onclick="delItem(' + idx + ')" style="color:#e53935;font-size:12px;">删除</a>';
                            }
                        }
                    ]],
                    data: { total: 0, rows: [] }
                });

                /* ===== 添加耗材弹窗 ===== */
                $('#btnAddItem').click(function () {
                    $('#dlgItem').dialog('open');
                    $('#ffItem').form('clear');
                    $('#sel_consumable').combobox('clear');
                    $('#sel_qty').numberbox('setValue', '');
                    $('#sel_remark').textbox('setValue', '');
                    $('#stockTip').text('');
                    $('#returnTip').text('');
                });

                // 耗材下拉（含库存，智能排序，状态高亮）
                var consumableData = [];
                $.ajax({
                    url: ctx + '/ServletOutbound?action=consumableOptionsWithStock',
                    type: 'get',
                    dataType: 'json',
                    async: false,
                    success: function (data) {
                        // 智能排序：有库存的靠前，无库存的靠后
                        consumableData = data.sort(function (a, b) {
                            var aStock = parseInt(a.stock_qty || 0);
                            var bStock = parseInt(b.stock_qty || 0);
                            if (aStock > 0 && bStock <= 0) return -1;
                            if (aStock <= 0 && bStock > 0) return 1;
                            return 0;
                        });
                    }
                });

                $('#sel_consumable').combobox({
                    data: consumableData,
                    valueField: 'id', textField: 'text',
                    editable: false, panelHeight: 260,
                    prompt: '请选择耗材',
                    onShowPanel: function () {
                        setTimeout(function () {
                            var panel = $('#sel_consumable').combobox('panel');
                            panel.find('.combobox-item').each(function (index) {
                                var item = consumableData[index];
                                if (item) {
                                    var stock = parseInt(item.stock_qty || 0);
                                    if (stock <= 0) {
                                        $(this).css('color', '#e53935');
                                        $(this).css('background-color', '#fff5f5');
                                    } else {
                                        $(this).css('color', '#43a047');
                                    }
                                }
                            });
                        }, 50);
                    },
                    onChange: function (newValue, oldValue) {
                        if (newValue) {
                            var data = $('#sel_consumable').combobox('getData');
                            var selectedItem = null;
                            for (var i = 0; i < data.length; i++) {
                                if (String(data[i].id) === String(newValue)) {
                                    selectedItem = data[i];
                                    break;
                                }
                            }
                            if (selectedItem) {
                                var sq = parseInt(selectedItem.stock_qty || 0);
                                if (sq <= 0) {
                                    $.messager.alert('提示', '该耗材库存不足，无法选择', 'warning');
                                    setTimeout(function () {
                                        $('#sel_consumable').combobox('clear');
                                    }, 50);
                                }
                            }
                        }
                    },
                    onSelect: function (rec) {
                        var sq = parseInt(rec.stock_qty || 0);
                        if (sq <= 0) {
                            return;
                        }
                        var c = sq <= 10 ? '#f57c00' : '#43a047';
                        $('#stockTip').html('当前库存：<b style="color:' + c + ';">' + sq + '</b> ' + (rec.unit || ''));
                        var ret = parseInt(rec.returnable || 0);
                        $('#returnTip').html(ret == 1
                            ? '<span class="badge-yes">需归还</span> 该耗材为可归还器皿'
                            : '<span class="badge-no">消耗品</span> 该耗材为一次性消耗品');
                        $('#sel_returnable').val(ret);
                        $('#sel_stock').val(sq);
                    }
                });

                $('#btnSaveItem').click(function () {
                    var c = $('#sel_consumable').combobox('getValue');
                    if (!c) { $.messager.alert('提示', '请选择耗材', 'warning'); return; }
                    var qty = parseInt($('#sel_qty').numberbox('getValue'));
                    if (!qty || qty <= 0) { $.messager.alert('提示', '数量必须大于0', 'warning'); return; }
                    var sq = parseInt($('#sel_stock').val() || 0);
                    if (qty > sq) { $.messager.alert('提示', '申请数量（' + qty + '）不能超过当前库存（' + sq + '）', 'warning'); return; }

                    var data = $('#sel_consumable').combobox('getData');
                    var sel = null;
                    for (var i = 0; i < data.length; i++) { if (String(data[i].id) === String(c)) { sel = data[i]; break; } }

                    // 检查是否已添加
                    var rows = $('#dgItems').datagrid('getRows');
                    for (var j = 0; j < rows.length; j++) {
                        if (String(rows[j].consumable_id) === String(c)) {
                            $.messager.alert('提示', '该耗材已在明细中，请修改数量', 'warning'); return;
                        }
                    }

                    var row = {
                        consumable_id: parseInt(c),
                        consumable_name: sel ? sel.name : '',
                        unit: sel ? sel.unit : '',
                        is_dangerous: sel ? sel.is_dangerous : 0,
                        stock_qty: sq,
                        quantity: qty,
                        should_return: parseInt($('#sel_returnable').val() || 0),
                        remark: $('#sel_remark').textbox('getValue')
                    };
                    $('#dgItems').datagrid('appendRow', row);
                    updateSummary();
                    $('#dlgItem').dialog('close');
                });

                /* ===== 保存草稿 ===== */
                $('#btnDraft').click(function () {
                    var items = $('#dgItems').datagrid('getRows');
                    $.messager.progress({ title: '处理中', msg: '正在保存草稿...' });
                    $.ajax({
                        type: 'POST', url: ctx + '/ServletOutbound?action=saveDraft',
                        data: buildFormData(items),
                        success: function (ret) {
                            $.messager.progress('close');
                            var r = typeof ret === 'string' ? JSON.parse(ret) : ret;
                            if (r.code == '200') {
                                if (r.data && r.data.id) draftId = r.data.id;
                                $.messager.show({ title: '草稿已保存', msg: '草稿ID：' + draftId + '，可随时在我的领用记录里复制后继续编辑', timeout: 3000, showType: 'slide' });
                            } else { $.messager.alert('失败', r.msg, 'warning'); }
                        },
                        error: function () { $.messager.progress('close'); $.messager.alert('错误', '网络异常', 'error'); }
                    });
                });

                /* ===== 提交申请 ===== */
                $('#btnSubmit').click(function () {
                    var course = $('#course_name').combobox('getValue') || $('#course_name').combobox('getText');
                    var cls = $('#class_name').combobox('getValue') || $('#class_name').combobox('getText');
                    var purpose = $.trim($('#purpose').textbox('getValue'));
                    if (!course) { $.messager.alert('提示', '请选择或填写课程名称', 'warning'); return; }
                    if (!cls) { $.messager.alert('提示', '请选择或填写班级信息', 'warning'); return; }
                    if (!purpose || purpose.length < 10) { $.messager.alert('提示', '用途说明不少于10个字', 'warning'); return; }
                    var items = $('#dgItems').datagrid('getRows');
                    if (!items || items.length === 0) { $.messager.alert('提示', '请先添加领用明细', 'warning'); return; }

                    // 统计危化品
                    var dangerCount = 0;
                    items.forEach(function (it) { if (it.is_dangerous == 1) dangerCount++; });

                    // 如果包含危化品，先显示警示确认框
                    if (dangerCount > 0) {
                        $.messager.confirm('危化品领用提醒',
                            '<div style="padding:8px;color:#e53935;font-size:14px;">⚠ 注意：当前包含危化品，领用时需落实五双管理，要求双人到场</div>',
                            function (confirmed) {
                                if (!confirmed) return;
                                submitApplication(course, cls, purpose, items, dangerCount);
                            }
                        );
                    } else {
                        submitApplication(course, cls, purpose, items, dangerCount);
                    }
                });

                /* ===== 实际提交申请 ===== */
                function submitApplication(course, cls, purpose, items, dangerCount) {
                    // 构建确认弹窗内容
                    var html = '<div class="confirm-box">'
                        + '<div class="c-line"><span class="c-key">课程：</span>' + course + '</div>'
                        + '<div class="c-line"><span class="c-key">班级：</span>' + cls + '</div>'
                        + '<div class="c-line"><span class="c-key">用途：</span>' + purpose + '</div>'
                        + '<div class="c-line"><span class="c-key">耗材种数：</span><b>' + items.length + '</b> 种'
                        + (dangerCount > 0 ? '，其中 <span class="c-warn">危化品 ' + dangerCount + ' 种</span>（需双人审核）' : '') + '</div>'
                        + '<div class="c-line" style="color:#546e7a;font-size:12px;">提交后可在「我的领用记录」中查看进度</div>'
                        + '</div>';

                    // 自定义确认弹窗
                    $('#confirmContent').html(html);
                    $('#dlgConfirm').dialog('open');
                }

                // 确认弹窗：查看明细
                $('#btnPreviewItems').click(function () {
                    var items = $('#dgItems').datagrid('getRows');
                    var html = '<table style="width:100%;border-collapse:collapse;font-size:12px;">'
                        + '<tr style="background:#f0f4fa;"><th style="padding:6px 8px;text-align:left;">耗材</th><th style="padding:6px 8px;">单位</th><th style="padding:6px 8px;">数量</th><th style="padding:6px 8px;">库存</th><th style="padding:6px 8px;">归还</th></tr>';
                    items.forEach(function (it) {
                        var d = it.is_dangerous == 1 ? '<span class="badge-danger">危</span>' : '';
                        html += '<tr style="border-bottom:1px solid #f0f4fa;">'
                            + '<td style="padding:6px 8px;">' + (it.consumable_name || '') + d + '</td>'
                            + '<td style="padding:6px 8px;text-align:center;">' + (it.unit || '') + '</td>'
                            + '<td style="padding:6px 8px;text-align:center;color:#1565c0;font-weight:bold;">' + it.quantity + '</td>'
                            + '<td style="padding:6px 8px;text-align:center;">' + (it.stock_qty || 0) + '</td>'
                            + '<td style="padding:6px 8px;text-align:center;">' + (it.should_return == 1 ? '<span class="badge-yes">是</span>' : '<span class="badge-no">否</span>') + '</td>'
                            + '</tr>';
                    });
                    html += '</table>';
                    $('#dlgPreview').dialog('open');
                    $('#previewContent').html(html);
                });

                // 确认弹窗：确认提交
                $('#btnConfirmSubmit').click(function () {
                    $('#dlgConfirm').dialog('close');
                    var items = $('#dgItems').datagrid('getRows');
                    $.messager.progress({ title: '处理中', msg: '正在提交...' });
                    $.ajax({
                        type: 'POST', url: ctx + '/ServletOutbound?action=create',
                        data: buildFormData(items),
                        success: function (ret) {
                            $.messager.progress('close');
                            var r = typeof ret === 'string' ? JSON.parse(ret) : ret;
                            if (r.code == '200') {
                                var newId = r.data && r.data.id ? r.data.id : '';
                                // 清空表单
                                clearForm();
                                draftId = null;
                                // 成功提示 + 引导
                                $('#successOrderId').text(newId ? newId : '');
                                $('#dlgSuccess').dialog('open');
                                // 刷新记录列表
                                $('#dgList').datagrid('reload');
                            } else { $.messager.alert('提交失败', r.msg, 'warning'); }
                        },
                        error: function () { $.messager.progress('close'); $.messager.alert('错误', '网络异常', 'error'); }
                    });
                });

                // 提交成功：前往查看进度
                $('#btnGotoList').click(function () {
                    var orderId = $('#successOrderId').text();
                    $('#dlgSuccess').dialog('close');
                    $('#mainTabs').tabs('select', '📂 我的领用记录');
                    // 等列表加载完后，自动弹出该单的进度
                    if (orderId) {
                        setTimeout(function () {
                            showProgressById(parseInt(orderId));
                        }, 800);
                    }
                });

                /* ===== ② 我的领用记录 Tab ===== */
                $('#dgList').datagrid({
                    url: ctx + '/ServletOutbound?action=listMine',
                    fit: true, pagination: true, rownumbers: true, singleSelect: true,
                    pageSize: 15, pageList: [10, 15, 20, 50],
                    toolbar: '#tbList',
                    columns: [[
                        {
                            field: 'id', title: '单号', width: 90, align: 'center',
                            formatter: function (v, r) {
                                var dangerTag = r.has_dangerous ? '<span class="badge-danger" style="margin-right:4px;">危</span>' : '';
                                return dangerTag + '<b style="color:#1565c0;">' + v + '</b>';
                            }
                        },
                        { field: 'lab_name', title: '实验室', width: 150 },
                        { field: 'course_name', title: '课程', width: 130, formatter: function (v) { return v || '—'; } },
                        { field: 'class_name', title: '班级', width: 120, formatter: function (v) { return v || '—'; } },
                        { field: 'purpose', title: '用途', width: 200, formatter: function (v) { return v || '—'; } },
                        {
                            field: 'status', title: '状态', width: 120, align: 'center',
                            formatter: function (v) { return fmtStatus(v, true); }
                        },
                        {
                            field: 'audit_user_name', title: '审核人', width: 90,
                            formatter: function (v, r) {
                                if (r.status == 0 || r.status == -1) return '—';
                                return v || '—';
                            }
                        },
                        {
                            field: 'create_time', title: '申请时间', width: 150,
                            formatter: function (v) {
                                if (!v) return '—';
                                return String(v).replace('T', ' ');
                            }
                        },
                        {
                            field: 'audit_time', title: '审核时间', width: 150,
                            formatter: function (v, r) {
                                if (r.status == 0 || r.status == -1) return '—';
                                if (!v) return '—';
                                return String(v).replace('T', ' ');
                            }
                        },
                        {
                            field: '_op', title: '操作', width: 170, align: 'center',
                            formatter: function (v, r) {
                                var btns = '<a href="javascript:void(0)" onclick="showDetail(' + r.id + ')" style="color:#1976d2;font-size:12px;margin-right:6px;">明细</a>';
                                btns += '<a href="javascript:void(0)" onclick="showProgress(' + r.id + ')" style="color:#8e24aa;font-size:12px;margin-right:6px;">进度</a>';
                                if (r.status == 0) {
                                    btns += '<a href="javascript:void(0)" onclick="cancelOrder(' + r.id + ')" style="color:#f57c00;font-size:12px;margin-right:6px;">撤销</a>';
                                }
                                if (r.status == -1 || r.status == 2) {
                                    btns += '<a href="javascript:void(0)" onclick="copyOrder(' + r.id + ')" style="color:#43a047;font-size:12px;">复制</a>';
                                }
                                return btns;
                            }
                        }
                    ]],
                    onDblClickRow: function (idx, row) { showDetail(row.id); },
                    rowStyler: function (index, row) {
                        if (row.has_dangerous) {
                            return 'danger-row';
                        }
                    }
                });

                /* ===== 筛选 ===== */
                $('#btnSearch').click(function () { doSearch(); });
                $('#btnReset').click(function () {
                    $('#filterStatus').combobox('setValue', '');
                    $('#filterKeyword').textbox('setValue', '');
                    $('#filterDateFrom').datebox('setValue', '');
                    $('#filterDateTo').datebox('setValue', '');
                    doSearch();
                });
                $('#filterKeyword').textbox({ prompt: '申请单号', onKeyDown: function (e) { if (e.keyCode == 13) doSearch(); } });
                $('#filterStatus').combobox({
                    data: [{ id: '', text: '全部状态' }, { id: '-1', text: '草稿' }, { id: '0', text: '待审核' }, { id: '1', text: '审核通过' }, { id: '2', text: '已驳回' }, { id: '3', text: '已出库' }],
                    valueField: 'id', textField: 'text', editable: false, panelHeight: 'auto', value: '',
                    onChange: function () { doSearch(); }
                });
            });

            /* ===== 工具函数 ===== */
            // 更新合计显示
            function updateSummary() {
                var rows = $('#dgItems').datagrid('getRows');
                if (rows.length === 0) {
                    $('#itemsSummary').hide();
                    return;
                }
                var totalQty = 0;
                for (var i = 0; i < rows.length; i++) {
                    totalQty += parseInt(rows[i].quantity || 0);
                }
                $('#summaryTypes').text(rows.length);
                $('#summaryTotal').text(totalQty);
                $('#itemsSummary').show();
            }

            function buildFormData(items) {
                return {
                    id: draftId || '',
                    draft_id: draftId || '',
                    course_name: $('#course_name').combobox('getValue') || $('#course_name').combobox('getText'),
                    class_name: $('#class_name').combobox('getValue') || $('#class_name').combobox('getText'),
                    purpose: $('#purpose').textbox('getValue'),
                    itemsJson: JSON.stringify((items || []).map(function (it) {
                        return { consumable_id: it.consumable_id, quantity: it.quantity, should_return: it.should_return, remark: it.remark };
                    }))
                };
            }

            function clearForm() {
                $('#course_name').combobox('clear');
                $('#class_name').combobox('clear');
                $('#purpose').textbox('setValue', '');
                $('#dgItems').datagrid('loadData', { total: 0, rows: [] });
                updateSummary();
                draftId = null;
            }

            function delItem(idx) {
                $('#dgItems').datagrid('deleteRow', idx);
                updateSummary();
            }

            /* ===== 编辑明细行（只允许改数量和备注） ===== */
            var _editIdx = -1;
            function editItem(idx) {
                var rows = $('#dgItems').datagrid('getRows');
                var row = rows[idx];
                if (!row) return;
                _editIdx = idx;
                // 填充弹窗
                $('#editItemName').text(row.consumable_name + (row.is_dangerous == 1 ? '【危】' : ''));
                $('#editItemUnit').text(row.unit || '');
                $('#editItemStock').text(row.stock_qty || 0);
                $('#editQty').numberbox('setValue', row.quantity);
                $('#editQty').numberbox('options').max = parseInt(row.stock_qty || 9999);
                $('#editRemark').textbox('setValue', row.remark || '');
                $('#dlgEditItem').dialog('open');
            }

            function saveEditItem() {
                if (_editIdx < 0) return;
                var qty = parseInt($('#editQty').numberbox('getValue'));
                if (!qty || qty <= 0) { $.messager.alert('提示', '数量必须大于0', 'warning'); return; }
                var rows = $('#dgItems').datagrid('getRows');
                var row = rows[_editIdx];
                var sq = parseInt(row.stock_qty || 0);
                if (qty > sq) { $.messager.alert('提示', '申请数量（' + qty + '）不能超过当前库存（' + sq + '）', 'warning'); return; }
                $('#dgItems').datagrid('updateRow', { index: _editIdx, row: { quantity: qty, remark: $('#editRemark').textbox('getValue') } });
                updateSummary();
                $('#dlgEditItem').dialog('close');
                _editIdx = -1;
            }

            function doSearch() {
                var kw = '';
                try { kw = $('#filterKeyword').textbox('getValue'); } catch (e) { kw = $('#filterKeyword').val() || ''; }
                var st = '';
                try { st = $('#filterStatus').combobox('getValue'); } catch (e) { st = ''; }
                var df = '';
                try { df = $('#filterDateFrom').datebox('getValue'); } catch (e) { df = ''; }
                var dt = '';
                try { dt = $('#filterDateTo').datebox('getValue'); } catch (e) { dt = ''; }
                $('#dgList').datagrid('load', {
                    status_filter: st,
                    keyword: kw,
                    date_from: df,
                    date_to: dt
                });
            }

            /* ===== 查看明细 ===== */
            function showDetail(oid) {
                var u = ctx + '/ServletOutbound?action=getMyItems&outbound_id=' + oid;
                if ($('#dgDetail').data('datagrid')) {
                    $('#dgDetail').datagrid('options').url = u;
                    $('#dgDetail').datagrid('reload');
                } else {
                    $('#dgDetail').datagrid({
                        url: u, fit: true, rownumbers: true, singleSelect: true,
                        columns: [[
                            {
                                field: 'consumable_name', title: '耗材名称', width: 200,
                                formatter: function (v, r) { var d = r.is_dangerous == 1 ? '<span class="badge-danger">危</span>' : ''; return '<span style="font-weight:500;">' + (v || '') + '</span>' + d; }
                            },
                            { field: 'unit', title: '单位', width: 65, align: 'center' },
                            { field: 'quantity', title: '数量', width: 80, align: 'center', formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; } },
                            {
                                field: 'should_return', title: '需归还', width: 80, align: 'center',
                                formatter: function (v) { return v == 1 ? '<span class="badge-yes">是</span>' : '<span class="badge-no">否</span>'; }
                            },
                            {
                                field: 'is_dangerous', title: '危化品', width: 80, align: 'center',
                                formatter: function (v) { return v == 1 ? '<span class="badge-danger">是</span>' : '<span class="badge-no">否</span>'; }
                            },
                            { field: 'remark', title: '备注', width: 180, formatter: function (v) { return v || '—'; } }
                        ]]
                    });
                }
                $('#dlgDetail').dialog('open');
            }

            /* ===== 审批进度条（通过行数据） ===== */
            function showProgress(oid, el) {
                // 先从列表缓存找，找不到就 AJAX 查
                var rows = $('#dgList').datagrid('getRows');
                var row = null;
                for (var i = 0; i < rows.length; i++) { if (String(rows[i].id) === String(oid)) { row = rows[i]; break; } }
                if (row) {
                    renderProgress(row);
                } else {
                    showProgressById(oid);
                }
            }

            /* ===== 审批进度条（通过 AJAX 查单条记录） ===== */
            function showProgressById(oid) {
                $.getJSON(ctx + '/ServletOutbound?action=listMine&keyword=' + oid + '&page=1&rows=1', function (data) {
                    var rows = data.rows || [];
                    if (rows.length > 0) {
                        renderProgress(rows[0]);
                    } else {
                        $.messager.alert('提示', '未找到该申请单，请刷新后重试', 'warning');
                    }
                }).fail(function () {
                    $.messager.alert('错误', '加载进度失败', 'error');
                });
            }

            /* ===== 渲染进度条 ===== */
            function renderProgress(row) {
                var status = parseInt(row.status);
                // 节点定义：提交→待审核→初审→[危化品二审]→出库
                var steps = [
                    { label: '提交申请', dot: 'done', desc: '申请已提交' },
                    { label: '待审核', dot: status >= 0 ? (status === 0 ? 'active' : 'done') : 'wait', desc: '等待实验室管理员审核' },
                    { label: '初审结果', dot: status === 2 ? 'reject' : (status >= 1 ? 'done' : 'wait'), desc: status === 2 ? '申请已被驳回' : '初审通过' },
                    { label: '出库', dot: status === 3 ? 'done' : (status >= 1 && status !== 2 ? 'active' : 'wait'), desc: '耗材已出库' }
                ];
                if (status === 2) { steps[2].label = '已驳回'; }
                if (status === 3) { steps[3].dot = 'done'; }

                var html = '<div style="background:#e3f2fd;border-radius:6px;padding:10px 14px;margin-bottom:12px;font-size:12px;">'
                    + '<span style="color:#1565c0;font-weight:bold;">申请单号：' + row.id + '</span>'
                    + '&nbsp;&nbsp;当前状态：' + fmtStatus(status, false)
                    + (row.course_name ? '&nbsp;&nbsp;课程：' + row.course_name : '')
                    + '</div>';

                html += '<div class="progress-wrap">';
                steps.forEach(function (s, i) {
                    var connClass = '';
                    if (i < steps.length - 1) {
                        // 连接线颜色：下一步已完成则绿色，当前激活则蓝色，否则灰色
                        var nextDot = steps[i + 1].dot;
                        connClass = (nextDot === 'done') ? 'done' : (nextDot === 'active' ? 'active' : '');
                    }
                    html += '<div class="progress-step ' + (i < steps.length - 1 ? connClass : '') + '">'
                        + '<div class="step-dot ' + s.dot + '">' + (i + 1) + '</div>'
                        + '<div class="step-label ' + s.dot + '">' + s.label + '</div>'
                        + '<div style="font-size:10px;color:#90a4ae;margin-top:2px;text-align:center;">' + s.desc + '</div>'
                        + '</div>';
                });
                html += '</div>';

                // 驳回原因
                if (status === 2) {
                    html += '<div style="padding:8px 14px;background:#ffebee;border-radius:6px;font-size:12px;color:#c62828;margin:4px 10px 0;">'
                        + '<div style="font-weight:bold;margin-bottom:4px;">驳回审核人：' + (row.audit_user_name || '—') + '</div>'
                        + '<div style="margin-top:4px;"><span style="font-weight:bold;">驳回原因：</span>' + (row.reject_reason || '—') + '</div>'
                        + '</div>';
                }
                // 出库提示
                if (status === 3) {
                    html += '<div style="padding:8px 14px;background:#e8f5e9;border-radius:6px;font-size:12px;color:#2e7d32;margin:4px 10px 0;">'
                        + '✅ 耗材已出库，如需归还请前往「归还登记」</div>';
                }
                // 待审核提示
                if (status === 0) {
                    html += '<div style="padding:8px 14px;background:#fff8e1;border-radius:6px;font-size:12px;color:#f57c00;margin:4px 10px 0;">'
                        + '⏳ 申请已提交，请耐心等待实验室管理员审核。如需修改，请关闭此弹窗，在【我的领用记录】列表中点击「撤销」后重新发起。</div>';
                }

                $('#progressContent').html(html);
                $('#dlgProgress').dialog('open');
            }

            /* ===== 撤销申请 ===== */
            function cancelOrder(oid) {
                $.messager.confirm('确认撤销', '确认撤销该领用申请？撤销后将变为草稿状态，可重新编辑提交。', function (r) {
                    if (!r) return;
                    $.post(ctx + '/ServletOutbound?action=cancel', { id: oid }, function (ret) {
                        var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
                        if (res.code == '200') { $.messager.show({ title: '成功', msg: res.msg, timeout: 2500, showType: 'slide' }); $('#dgList').datagrid('reload'); }
                        else { $.messager.alert('失败', res.msg, 'warning'); }
                    });
                });
            }

            /* ===== 复制申请（填充到表单，含课程/班级/用途） ===== */
            function copyOrder(oid) {
                $.messager.confirm('复制申请', '将该申请的课程、班级、用途及耗材明细全部复制到新申请表单？', function (r) {
                    if (!r) return;

                    // 先获取申请基本信息
                    $.getJSON(ctx + '/ServletOutbound?action=listMine&keyword=' + oid + '&page=1&rows=1', function (data) {
                        var rows = data.rows || [];
                        var orderInfo = rows.length > 0 ? rows[0] : {};

                        // 获取明细
                        $.getJSON(ctx + '/ServletOutbound?action=getMyItems&outbound_id=' + oid, function (items) {
                            // 切换到提交申请Tab
                            $('#mainTabs').tabs('select', '📋 提交新申请');
                            clearForm();

                            // 回填课程、班级、用途
                            if (orderInfo.course_name) {
                                $('#course_name').combobox('setValue', orderInfo.course_name);
                                $('#course_name').combobox('setText', orderInfo.course_name);
                            }
                            if (orderInfo.class_name) {
                                $('#class_name').combobox('setValue', orderInfo.class_name);
                                $('#class_name').combobox('setText', orderInfo.class_name);
                            }
                            if (orderInfo.purpose) {
                                $('#purpose').textbox('setValue', orderInfo.purpose);
                            }

                            if (!items || items.length === 0) {
                                $.messager.show({ title: '已复制', msg: '基本信息已填入，该申请无耗材明细', timeout: 3000, showType: 'slide' });
                                return;
                            }

                            // 获取最新库存信息后填入明细
                            $.getJSON(ctx + '/ServletOutbound?action=consumableOptionsWithStock', function (stockList) {
                                var stockMap = {};
                                (stockList || []).forEach(function (s) { stockMap[String(s.id)] = s; });
                                var dgRows = [];
                                items.forEach(function (it) {
                                    var s = stockMap[String(it.consumable_id)] || {};
                                    dgRows.push({
                                        consumable_id: it.consumable_id,
                                        consumable_name: it.consumable_name,
                                        unit: it.unit,
                                        is_dangerous: it.is_dangerous,
                                        stock_qty: s.stock_qty || 0,
                                        quantity: it.quantity,
                                        should_return: it.should_return,
                                        remark: it.remark
                                    });
                                });
                                $('#dgItems').datagrid('loadData', { total: dgRows.length, rows: dgRows });
                                updateSummary();
                                $.messager.show({ title: '已复制', msg: '课程、班级、用途及耗材明细已填入，确认后提交', timeout: 3500, showType: 'slide' });
                            });
                        });
                    });
                });
            }
        </script>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">📋</span>
            领用申请管理
            <span class="sub">教师可在此提交新的耗材领用申请，并查看历史记录</span>
        </div>

        <!-- 主 Tabs -->
        <div id="mainTabs" class="easyui-tabs" data-options="fit:true" style="height:calc(100% - 44px);">

            <!-- ===== Tab 1：提交新申请 ===== -->
            <div title="📋 提交新申请" style="overflow-y:auto;height:100%;background:#f0f4fa;">

                <!-- 基本信息卡片 -->
                <div class="form-card">
                    <div class="card-title">📝 申请基本信息</div>
                    <div class="form-row">
                        <div class="form-item">
                            <label>课程名称 <span class="req">*</span></label>
                            <input id="course_name" style="width:300px;">
                            <div style="font-size:12px;color:#90a4ae;margin-top:4px;">
                                💡 保存草稿后，可随时在【我的领用记录】里复制后继续编辑~
                            </div>
                        </div>
                        <div class="form-item">
                            <label>班级信息 <span class="req">*</span></label>
                            <input id="class_name" style="width:280px;">
                        </div>
                        <div class="form-item" style="flex:1;min-width:260px;">
                            <label>用途说明 <span class="req">*</span>
                                <span style="color:#90a4ae;font-weight:normal;font-size:11px;">（不少于10字）</span>
                            </label>
                            <input id="purpose" class="easyui-textbox" style="width:100%;height:52px;"
                                data-options="multiline:true,prompt:'请详细描述本次领用的具体用途（必填，不少于10字）'">
                        </div>
                        <div class="form-item" style="justify-content:flex-end;padding-bottom:2px;gap:6px;">
                            <a id="btnSubmit" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                                data-options="iconCls:'icon-save'" style="height:36px;">提 交 申 请</a>
                            <a id="btnDraft" href="javascript:void(0)" class="easyui-linkbutton"
                                data-options="iconCls:'icon-edit',plain:true" style="height:36px;">保存草稿</a>
                        </div>
                    </div>
                </div>

                <!-- 明细表格 -->
                <div
                    style="margin:0 12px;background:#fff;border-radius:8px;box-shadow:0 1px 6px rgba(21,101,192,.10);overflow:hidden;height:calc(100vh - 210px);">
                    <table id="dgItems"></table>
                </div>

                <!-- 合计行 -->
                <div id="itemsSummary"
                    style="margin:0 12px;padding:8px 16px;background:#f8fafc;border-radius:0 0 8px 8px;border-top:1px solid #e3eaf5;font-size:13px;color:#546e7a;display:none;">
                    <span style="font-weight:bold;color:#1565c0;">合计：</span>
                    共申请 <b id="summaryTypes" style="color:#1565c0;">0</b> 种耗材，
                    总计 <b id="summaryTotal" style="color:#1565c0;">0</b> 件
                </div>

                <!-- 工具栏 -->
                <div id="tbItems"
                    style="padding:5px 8px;background:#f0f4fa;border-bottom:1px solid #dce6f5;display:flex;align-items:center;gap:6px;">
                    <a id="btnAddItem" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                        data-options="iconCls:'icon-add'">添加耗材</a>
                    <span style="color:#90a4ae;font-size:12px;margin-left:6px;">⚠ 危险化学品领用需经双人审核</span>
                </div>
            </div>

            <!-- ===== Tab 2：我的领用记录 ===== -->
            <div title="📂 我的领用记录" style="overflow:hidden;height:100%;">
                <div class="easyui-layout" data-options="fit:true">
                    <!-- 筛选栏 -->
                    <div data-options="region:'north',border:false" style="height:auto;">
                        <div class="global-tip">
                            📢
                            <span>耗材领用规范提醒：非消耗类耗材领用后，请务必在10日内进入【归还登记】及时归还。</span>
                        </div>
                        <div class="filter-bar">
                            <span style="font-size:12px;color:#546e7a;font-weight:600;">筛选：</span>
                            <input id="filterStatus" style="width:110px;">
                            <input id="filterKeyword" class="easyui-textbox" style="width:110px;">
                            <input id="filterDateFrom" class="easyui-datebox" style="width:120px;"
                                data-options="prompt:'开始日期'">
                            <span style="color:#ccc;">~</span>
                            <input id="filterDateTo" class="easyui-datebox" style="width:120px;"
                                data-options="prompt:'结束日期'">
                            <a id="btnSearch" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                                data-options="iconCls:'icon-search'">查询</a>
                            <a id="btnReset" href="javascript:void(0)" class="easyui-linkbutton"
                                data-options="iconCls:'icon-undo',plain:true">重置</a>
                            <span style="color:#90a4ae;font-size:12px;margin-left:4px;">💡 点击单号查看审批进度，双击行查看明细</span>
                        </div>
                    </div>
                    <div data-options="region:'center',border:false">
                        <table id="dgList"></table>
                    </div>
                </div>
                <!-- 工具栏（空，占位） -->
                <div id="tbList" style="display:none;"></div>
            </div>

        </div><!-- /mainTabs -->

        <!-- ===== 添加耗材弹窗 ===== -->
        <div id="dlgItem" class="easyui-dialog" title="添加领用耗材" style="width:500px;padding:16px 20px;"
            data-options="closed:true,modal:true,buttons:'#dlgItemBtns'">
            <form id="ffItem">
                <div class="dlg-row">
                    <label>选择耗材 <span class="req">*</span></label>
                    <input id="sel_consumable" style="width:100%;">
                    <div id="stockTip" style="margin-top:4px;font-size:12px;color:#546e7a;"></div>
                </div>
                <div class="dlg-row">
                    <label>申请数量 <span class="req">*</span></label>
                    <input id="sel_qty" class="easyui-numberbox" style="width:100%;"
                        data-options="min:1,precision:0,prompt:'请输入数量（不超过库存）'">
                </div>
                <div class="dlg-row">
                    <label>归还属性（系统自动）</label>
                    <div id="returnTip" style="font-size:12px;color:#546e7a;padding:6px 0;">请先选择耗材</div>
                    <input type="hidden" id="sel_returnable" value="0">
                    <input type="hidden" id="sel_stock" value="0">
                </div>
                <div class="dlg-row">
                    <label>备注说明</label>
                    <input id="sel_remark" class="easyui-textbox" style="width:100%;"
                        data-options="prompt:'可填写规格要求等（选填）'">
                </div>
            </form>
        </div>
        <div id="dlgItemBtns">
            <a id="btnSaveItem" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                data-options="iconCls:'icon-ok'">确认添加</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back'"
                onclick="$('#dlgItem').dialog('close')">取消</a>
        </div>

        <!-- ===== 编辑明细弹窗 ===== -->
        <div id="dlgEditItem" class="easyui-dialog" title="编辑领用明细" style="width:420px;padding:16px 20px;"
            data-options="closed:true,modal:true,buttons:'#dlgEditItemBtns'">
            <div style="margin-bottom:12px;padding:8px 12px;background:#f0f4fa;border-radius:6px;font-size:13px;">
                <span style="color:#546e7a;">耗材：</span><b id="editItemName" style="color:#1565c0;"></b>
                &nbsp;&nbsp;<span style="color:#546e7a;">单位：</span><span id="editItemUnit"></span>
                &nbsp;&nbsp;<span style="color:#546e7a;">库存：</span><b id="editItemStock" style="color:#43a047;"></b>
            </div>
            <div class="dlg-row">
                <label>申请数量 <span class="req">*</span></label>
                <input id="editQty" class="easyui-numberbox" style="width:100%;"
                    data-options="required:true,min:1,precision:0,prompt:'请输入数量（不超过库存）'">
            </div>
            <div class="dlg-row">
                <label>备注说明</label>
                <input id="editRemark" class="easyui-textbox" style="width:100%;" data-options="prompt:'可填写规格要求等（选填）'">
            </div>
        </div>
        <div id="dlgEditItemBtns">
            <a href="javascript:void(0)" class="easyui-linkbutton btn-primary" data-options="iconCls:'icon-ok'"
                onclick="saveEditItem()">保存修改</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back'"
                onclick="$('#dlgEditItem').dialog('close')">取消</a>
        </div>

        <!-- ===== 提交确认弹窗 ===== -->
        <div id="dlgConfirm" class="easyui-dialog" title="确认提交领用申请" style="width:480px;padding:16px 20px;"
            data-options="closed:true,modal:true,buttons:'#dlgConfirmBtns'">
            <div id="confirmContent"></div>
        </div>
        <div id="dlgConfirmBtns">
            <a id="btnConfirmSubmit" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                data-options="iconCls:'icon-ok'">确认提交</a>
            <a id="btnPreviewItems" href="javascript:void(0)" class="easyui-linkbutton"
                data-options="iconCls:'icon-search',plain:true">查看申请明细</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back'"
                onclick="$('#dlgConfirm').dialog('close')">取消</a>
        </div>

        <!-- ===== 明细预览弹窗 ===== -->
        <div id="dlgPreview" class="easyui-dialog" title="申请耗材明细预览"
            style="width:600px;height:360px;padding:12px 16px;overflow-y:auto;" data-options="closed:true,modal:true">
            <div id="previewContent"></div>
        </div>

        <!-- ===== 提交成功弹窗 ===== -->
        <div id="dlgSuccess" class="easyui-dialog" title="🎉 提交成功" style="width:400px;padding:20px 24px;"
            data-options="closed:true,modal:true,buttons:'#dlgSuccessBtns'">
            <div style="text-align:center;">
                <div style="font-size:40px;margin-bottom:12px;">✅</div>
                <div style="font-size:15px;font-weight:bold;color:#43a047;margin-bottom:8px;">领用申请提交成功！</div>
                <div style="font-size:13px;color:#546e7a;">申请单号：<b id="successOrderId" style="color:#1565c0;"></b></div>
                <div style="font-size:12px;color:#90a4ae;margin-top:8px;">等待实验室管理员审核，可在「我的领用记录」中查看进度</div>
            </div>
        </div>
        <div id="dlgSuccessBtns">
            <a id="btnGotoList" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                data-options="iconCls:'icon-search'">前往查看进度</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-ok',plain:true"
                onclick="$('#dlgSuccess').dialog('close')">关闭</a>
        </div>

        <!-- ===== 明细查看弹窗 ===== -->
        <div id="dlgDetail" class="easyui-dialog" title="领用单明细" style="width:720px;height:400px;padding:10px 12px;"
            data-options="closed:true,modal:true">
            <table id="dgDetail" style="height:100%;"></table>
        </div>

        <!-- ===== 审批进度弹窗 ===== -->
        <div id="dlgProgress" class="easyui-dialog" title="审批进度" style="width:500px;padding:10px 14px;"
            data-options="closed:true,modal:true">
            <div id="progressContent"></div>
        </div>

    </body>

    </html>
    $.post(ctx + '/ServletOutbound?action=cancel', { id: oid }, function (ret) {
    var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
    if (res.code == '200') { $.messager.show({ title: '成功', msg: res.msg, timeout: 2500, showType: 'slide' });
    $('#dgList').datagrid('reload'); }
    else { $.messager.alert('失败', res.msg, 'warning'); }
    });
    });
    }

    /* ===== 复制申请（填充到表单，含课程/班级/用途） ===== */
    function copyOrder(oid) {
    $.messager.confirm('复制申请', '将该申请的课程、班级、用途及耗材明细全部复制到新申请表单？', function (r) {
    if (!r) return;

    // 先获取申请基本信息
    $.getJSON(ctx + '/ServletOutbound?action=listMine&keyword=' + oid + '&page=1&rows=1', function (data) {
    var rows = data.rows || [];
    var orderInfo = rows.length > 0 ? rows[0] : {};

    // 获取明细
    $.getJSON(ctx + '/ServletOutbound?action=getMyItems&outbound_id=' + oid, function (items) {
    // 切换到提交申请Tab
    $('#mainTabs').tabs('select', '📋 提交新申请');
    clearForm();

    // 回填课程、班级、用途
    if (orderInfo.course_name) {
    $('#course_name').combobox('setValue', orderInfo.course_name);
    $('#course_name').combobox('setText', orderInfo.course_name);
    }
    if (orderInfo.class_name) {
    $('#class_name').combobox('setValue', orderInfo.class_name);
    $('#class_name').combobox('setText', orderInfo.class_name);
    }
    if (orderInfo.purpose) {
    $('#purpose').textbox('setValue', orderInfo.purpose);
    }

    if (!items || items.length === 0) {
    $.messager.show({ title: '已复制', msg: '基本信息已填入，该申请无耗材明细', timeout: 3000, showType: 'slide' });
    return;
    }

    // 获取最新库存信息后填入明细
    $.getJSON(ctx + '/ServletOutbound?action=consumableOptionsWithStock', function (stockList) {
    var stockMap = {};
    (stockList || []).forEach(function (s) { stockMap[String(s.id)] = s; });
    var dgRows = [];
    items.forEach(function (it) {
    var s = stockMap[String(it.consumable_id)] || {};
    dgRows.push({
    consumable_id: it.consumable_id,
    consumable_name: it.consumable_name,
    unit: it.unit,
    is_dangerous: it.is_dangerous,
    stock_qty: s.stock_qty || 0,
    quantity: it.quantity,
    should_return: it.should_return,
    remark: it.remark
    });
    });
    $('#dgItems').datagrid('loadData', { total: dgRows.length, rows: dgRows });
    $.messager.show({ title: '已复制', msg: '课程、班级、用途及耗材明细已填入，确认后提交', timeout: 3500, showType: 'slide' });
    });
    });
    });
    });
    }
    </script>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">📋</span>
            领用申请管理
            <span class="sub">教师可在此提交新的耗材领用申请，并查看历史记录</span>
        </div>

        <!-- 主 Tabs -->
        <div id="mainTabs" class="easyui-tabs" data-options="fit:true" style="height:calc(100% - 44px);">

            <!-- ===== Tab 1：提交新申请 ===== -->
            <div title="📋 提交新申请" style="overflow-y:auto;height:100%;background:#f0f4fa;">

                <!-- 基本信息卡片 -->
                <div class="form-card">
                    <div class="card-title">📝 申请基本信息</div>
                    <div class="form-row">
                        <div class="form-item">
                            <label>课程名称 <span class="req">*</span></label>
                            <input id="course_name" style="width:300px;">
                            <div style="font-size:12px;color:#90a4ae;margin-top:4px;">
                                💡 保存草稿后，可随时在【我的领用记录】里复制后继续编辑~
                            </div>
                        </div>
                        <div class="form-item">
                            <label>班级信息 <span class="req">*</span></label>
                            <input id="class_name" style="width:280px;">
                        </div>
                        <div class="form-item" style="flex:1;min-width:260px;">
                            <label>用途说明 <span class="req">*</span>
                                <span style="color:#90a4ae;font-weight:normal;font-size:11px;">（不少于10字）</span>
                            </label>
                            <input id="purpose" class="easyui-textbox" style="width:100%;height:52px;"
                                data-options="multiline:true,prompt:'请详细描述本次领用的具体用途（必填，不少于10字）'">
                        </div>
                        <div class="form-item" style="justify-content:flex-end;padding-bottom:2px;gap:6px;">
                            <a id="btnSubmit" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                                data-options="iconCls:'icon-save'" style="height:36px;">提 交 申 请</a>
                            <a id="btnDraft" href="javascript:void(0)" class="easyui-linkbutton"
                                data-options="iconCls:'icon-edit',plain:true" style="height:36px;">保存草稿</a>
                        </div>
                    </div>
                </div>

                <!-- 明细表格 -->
                <div
                    style="margin:0 12px;background:#fff;border-radius:8px;box-shadow:0 1px 6px rgba(21,101,192,.10);overflow:hidden;height:calc(100vh - 210px);">
                    <table id="dgItems"></table>
                </div>

                <!-- 合计行 -->
                <div id="itemsSummary"
                    style="margin:0 12px;padding:8px 16px;background:#f8fafc;border-radius:0 0 8px 8px;border-top:1px solid #e3eaf5;font-size:13px;color:#546e7a;display:none;">
                    <span style="font-weight:bold;color:#1565c0;">合计：</span>
                    共申请 <b id="summaryTypes" style="color:#1565c0;">0</b> 种耗材，
                    总计 <b id="summaryTotal" style="color:#1565c0;">0</b> 件
                </div>

                <!-- 工具栏 -->
                <div id="tbItems"
                    style="padding:5px 8px;background:#f0f4fa;border-bottom:1px solid #dce6f5;display:flex;align-items:center;gap:6px;">
                    <a id="btnAddItem" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                        data-options="iconCls:'icon-add'">添加耗材</a>
                    <span style="color:#90a4ae;font-size:12px;margin-left:6px;">⚠ 危险化学品领用需经双人审核</span>
                </div>
            </div>

            <!-- ===== Tab 2：我的领用记录 ===== -->
            <div title="📂 我的领用记录" style="overflow:hidden;height:100%;">
                <div class="easyui-layout" data-options="fit:true">
                    <!-- 筛选栏 -->
                    <div data-options="region:'north',border:false" style="height:auto;">
                        <div class="global-tip">
                            📢
                            <span>耗材领用规范提醒：非消耗类耗材领用后，请务必在10日内进入【归还登记】及时归还。</span>
                        </div>
                        <div class="filter-bar">
                            <span style="font-size:12px;color:#546e7a;font-weight:600;">筛选：</span>
                            <input id="filterStatus" style="width:110px;">
                            <input id="filterKeyword" class="easyui-textbox" style="width:110px;">
                            <input id="filterDateFrom" class="easyui-datebox" style="width:120px;"
                                data-options="prompt:'开始日期'">
                            <span style="color:#ccc;">~</span>
                            <input id="filterDateTo" class="easyui-datebox" style="width:120px;"
                                data-options="prompt:'结束日期'">
                            <a id="btnSearch" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                                data-options="iconCls:'icon-search'">查询</a>
                            <a id="btnReset" href="javascript:void(0)" class="easyui-linkbutton"
                                data-options="iconCls:'icon-undo',plain:true">重置</a>
                            <span style="color:#90a4ae;font-size:12px;margin-left:4px;">💡 点击单号查看审批进度，双击行查看明细</span>
                        </div>
                    </div>
                    <div data-options="region:'center',border:false">
                        <table id="dgList"></table>
                    </div>
                </div>
                <!-- 工具栏（空，占位） -->
                <div id="tbList" style="display:none;"></div>
            </div>

        </div><!-- /mainTabs -->

        <!-- ===== 添加耗材弹窗 ===== -->
        <div id="dlgItem" class="easyui-dialog" title="添加领用耗材" style="width:500px;padding:16px 20px;"
            data-options="closed:true,modal:true,buttons:'#dlgItemBtns'">
            <form id="ffItem">
                <div class="dlg-row">
                    <label>选择耗材 <span class="req">*</span></label>
                    <input id="sel_consumable" style="width:100%;">
                    <div id="stockTip" style="margin-top:4px;font-size:12px;color:#546e7a;"></div>
                </div>
                <div class="dlg-row">
                    <label>申请数量 <span class="req">*</span></label>
                    <input id="sel_qty" class="easyui-numberbox" style="width:100%;"
                        data-options="min:1,precision:0,prompt:'请输入数量（不超过库存）'">
                </div>
                <div class="dlg-row">
                    <label>归还属性（系统自动）</label>
                    <div id="returnTip" style="font-size:12px;color:#546e7a;padding:6px 0;">请先选择耗材</div>
                    <input type="hidden" id="sel_returnable" value="0">
                    <input type="hidden" id="sel_stock" value="0">
                </div>
                <div class="dlg-row">
                    <label>备注说明</label>
                    <input id="sel_remark" class="easyui-textbox" style="width:100%;"
                        data-options="prompt:'可填写规格要求等（选填）'">
                </div>
            </form>
        </div>
        <div id="dlgItemBtns">
            <a id="btnSaveItem" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                data-options="iconCls:'icon-ok'">确认添加</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back'"
                onclick="$('#dlgItem').dialog('close')">取消</a>
        </div>

        <!-- ===== 编辑明细弹窗 ===== -->
        <div id="dlgEditItem" class="easyui-dialog" title="编辑领用明细" style="width:420px;padding:16px 20px;"
            data-options="closed:true,modal:true,buttons:'#dlgEditItemBtns'">
            <div style="margin-bottom:12px;padding:8px 12px;background:#f0f4fa;border-radius:6px;font-size:13px;">
                <span style="color:#546e7a;">耗材：</span><b id="editItemName" style="color:#1565c0;"></b>
                &nbsp;&nbsp;<span style="color:#546e7a;">单位：</span><span id="editItemUnit"></span>
                &nbsp;&nbsp;<span style="color:#546e7a;">库存：</span><b id="editItemStock" style="color:#43a047;"></b>
            </div>
            <div class="dlg-row">
                <label>申请数量 <span class="req">*</span></label>
                <input id="editQty" class="easyui-numberbox" style="width:100%;"
                    data-options="required:true,min:1,precision:0,prompt:'请输入数量（不超过库存）'">
            </div>
            <div class="dlg-row">
                <label>备注说明</label>
                <input id="editRemark" class="easyui-textbox" style="width:100%;" data-options="prompt:'可填写规格要求等（选填）'">
            </div>
        </div>
        <div id="dlgEditItemBtns">
            <a href="javascript:void(0)" class="easyui-linkbutton btn-primary" data-options="iconCls:'icon-ok'"
                onclick="saveEditItem()">保存修改</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back'"
                onclick="$('#dlgEditItem').dialog('close')">取消</a>
        </div>

        <!-- ===== 提交确认弹窗 ===== -->
        <div id="dlgConfirm" class="easyui-dialog" title="确认提交领用申请" style="width:480px;padding:16px 20px;"
            data-options="closed:true,modal:true,buttons:'#dlgConfirmBtns'">
            <div id="confirmContent"></div>
        </div>
        <div id="dlgConfirmBtns">
            <a id="btnConfirmSubmit" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                data-options="iconCls:'icon-ok'">确认提交</a>
            <a id="btnPreviewItems" href="javascript:void(0)" class="easyui-linkbutton"
                data-options="iconCls:'icon-search',plain:true">查看申请明细</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back'"
                onclick="$('#dlgConfirm').dialog('close')">取消</a>
        </div>

        <!-- ===== 明细预览弹窗 ===== -->
        <div id="dlgPreview" class="easyui-dialog" title="申请耗材明细预览"
            style="width:600px;height:360px;padding:12px 16px;overflow-y:auto;" data-options="closed:true,modal:true">
            <div id="previewContent"></div>
        </div>

        <!-- ===== 提交成功弹窗 ===== -->
        <div id="dlgSuccess" class="easyui-dialog" title="🎉 提交成功" style="width:400px;padding:20px 24px;"
            data-options="closed:true,modal:true,buttons:'#dlgSuccessBtns'">
            <div style="text-align:center;">
                <div style="font-size:40px;margin-bottom:12px;">✅</div>
                <div style="font-size:15px;font-weight:bold;color:#43a047;margin-bottom:8px;">领用申请提交成功！</div>
                <div style="font-size:13px;color:#546e7a;">申请单号：<b id="successOrderId" style="color:#1565c0;"></b></div>
                <div style="font-size:12px;color:#90a4ae;margin-top:8px;">等待实验室管理员审核，可在「我的领用记录」中查看进度</div>
            </div>
        </div>
        <div id="dlgSuccessBtns">
            <a id="btnGotoList" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                data-options="iconCls:'icon-search'">前往查看进度</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-ok',plain:true"
                onclick="$('#dlgSuccess').dialog('close')">关闭</a>
        </div>

        <!-- ===== 明细查看弹窗 ===== -->
        <div id="dlgDetail" class="easyui-dialog" title="领用单明细" style="width:720px;height:400px;padding:10px 12px;"
            data-options="closed:true,modal:true">
            <table id="dgDetail" style="height:100%;"></table>
        </div>

        <!-- ===== 审批进度弹窗 ===== -->
        <div id="dlgProgress" class="easyui-dialog" title="审批进度" style="width:500px;padding:10px 14px;"
            data-options="closed:true,modal:true">
            <div id="progressContent"></div>
        </div>

    </body>

    </html>