<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>库存盘点</title>
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

            .action-bar {
                background: #fff;
                border-bottom: 1px solid #e8eef7;
                padding: 6px 10px;
                display: flex;
                align-items: center;
                gap: 8px;
                flex-wrap: wrap;
            }

            .btn-primary {
                background: #1976d2 !important;
                color: #fff !important;
                border: none !important;
                border-radius: 4px !important;
                font-weight: bold;
            }

            .btn-success {
                background: #43a047 !important;
                color: #fff !important;
                border: none !important;
                border-radius: 4px !important;
                font-weight: bold;
            }

            .section-wrap {
                height: 100%;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }

            .section-block {
                display: flex;
                flex-direction: column;
                min-height: 0;
                overflow: hidden;
            }

            .section-divider {
                height: 6px;
                background: #eceff1;
                flex-shrink: 0;
                cursor: row-resize;
            }

            .section-title {
                background: #e3f2fd;
                border-left: 4px solid #1976d2;
                border-bottom: 1px solid #bbdefb;
                padding: 5px 12px;
                font-size: 13px;
                font-weight: bold;
                color: #0d47a1;
                flex-shrink: 0;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .section-title .title-right {
                margin-left: auto;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .detail-panel {
                padding: 0;
                height: 100%;
                box-sizing: border-box;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }

            .detail-header {
                background: linear-gradient(90deg, #1565c0, #1976d2);
                color: #fff;
                padding: 8px 14px;
                font-size: 13px;
                font-weight: bold;
                flex-shrink: 0;
            }

            .info-card {
                background: #f8fafc;
                border-bottom: 1px solid #e3eaf5;
                padding: 10px 14px;
                flex-shrink: 0;
            }

            .info-grid {
                display: flex;
                flex-wrap: wrap;
                gap: 0;
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
                min-width: 60px;
                flex-shrink: 0;
            }

            .info-item .val {
                color: #263238;
                flex: 1;
            }

            .info-item.full {
                width: 100%;
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
                background: #43a047;
                color: #fff;
            }

            .danger-badge {
                display: inline-block;
                padding: 1px 6px;
                border-radius: 8px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            .diff-pos {
                color: #43a047;
                font-weight: bold;
            }

            .diff-neg {
                color: #e53935;
                font-weight: bold;
            }

            .diff-zero {
                color: #90a4ae;
            }

            .qty-input {
                width: 70px;
                padding: 2px 4px;
                border: 1px solid #cfd8dc;
                border-radius: 3px;
                font-size: 12px;
                text-align: center;
            }

            .qty-input.has-diff {
                border-color: #e53935;
            }

            .remark-input {
                width: 100%;
                padding: 2px 4px;
                border: 1px solid #cfd8dc;
                border-radius: 3px;
                font-size: 12px;
                box-sizing: border-box;
            }

            .remark-input.required {
                border-color: #e53935;
                background: #fff8f8;
            }

            .report-section {
                flex: 1;
                overflow-y: auto;
                padding: 10px 14px;
            }

            .report-title {
                font-size: 15px;
                font-weight: bold;
                color: #1565c0;
                margin-bottom: 8px;
                border-bottom: 2px solid #1976d2;
                padding-bottom: 4px;
            }

            .report-summary {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-bottom: 10px;
            }

            .summary-card {
                background: #e3f2fd;
                border-radius: 6px;
                padding: 8px 14px;
                min-width: 100px;
                text-align: center;
            }

            .summary-card .num {
                font-size: 20px;
                font-weight: bold;
                color: #1565c0;
            }

            .summary-card .lbl {
                font-size: 11px;
                color: #546e7a;
            }

            .summary-card.pos .num {
                color: #43a047;
            }

            .summary-card.neg .num {
                color: #e53935;
            }

            .report-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 12px;
                margin-bottom: 10px;
            }

            .report-table th {
                background: #e3f2fd;
                color: #0d47a1;
                padding: 5px 8px;
                border: 1px solid #bbdefb;
                text-align: center;
            }

            .report-table td {
                padding: 4px 8px;
                border: 1px solid #e0e0e0;
            }

            .report-table tr:nth-child(even) td {
                background: #f8fafc;
            }

            .log-section {
                border-top: 1px solid #e0e0e0;
                padding-top: 8px;
                margin-top: 8px;
            }

            .log-title {
                font-size: 13px;
                font-weight: bold;
                color: #546e7a;
                margin-bottom: 6px;
            }

            .log-item {
                display: flex;
                gap: 8px;
                font-size: 11px;
                padding: 3px 0;
                border-bottom: 1px solid #f0f0f0;
            }

            .log-item .adj-pos {
                color: #43a047;
                font-weight: bold;
            }

            .log-item .adj-neg {
                color: #e53935;
                font-weight: bold;
            }

            .export-bar {
                display: flex;
                gap: 8px;
                padding: 8px 0;
                flex-shrink: 0;
            }

            .btn-export {
                padding: 5px 14px;
                border-radius: 4px;
                border: none;
                cursor: pointer;
                font-size: 12px;
                font-weight: bold;
            }

            .btn-excel {
                background: #43a047;
                color: #fff;
            }

            .btn-print {
                background: #546e7a;
                color: #fff;
            }

            @media print {

                .page-header,
                .action-bar,
                .easyui-layout>div[data-options*="north"],
                .easyui-layout>div[data-options*="center"],
                .detail-header,
                .export-bar,
                .info-card {
                    display: none !important;
                }

                #printArea {
                    display: block !important;
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    z-index: 9999;
                    background: #fff;
                    padding: 20px;
                }
            }

            #printArea {
                display: none;
            }
        </style>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">
        <div class="page-header">
            <span style="font-size:20px;">📋</span>
            库存盘点管理
            <span class="sub">新建盘点单、录入实盘数量、完成盘点并回写库存</span>
        </div>

        <div id="mainLayout" class="easyui-layout" data-options="fit:true" style="height:calc(100vh - 44px);">

            <!-- 操作栏 north -->
            <div data-options="region:'north',border:false" style="height:auto;">
                <div class="action-bar">
                    <a id="btnNew" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                        data-options="iconCls:'icon-add'">新建盘点单</a>
                    <a id="btnComplete" href="javascript:void(0)" class="easyui-linkbutton btn-success"
                        data-options="iconCls:'icon-ok'">完成盘点并回写库存</a>
                    <span style="font-size:11px;color:#90a4ae;margin-left:8px;">
                        请先选择一个进行中的盘点单，再点击完成盘点
                    </span>
                </div>
            </div>

            <!-- 中间区域 center -->
            <div data-options="region:'center',border:true">
                <div class="section-wrap">
                    <!-- 上：盘点单列表 -->
                    <div class="section-block" id="topBlock" style="flex:0 0 50%;">
                        <div class="section-title">
                            <span>📋 盘点单列表</span>
                        </div>
                        <div style="flex:1;overflow:hidden;">
                            <table id="dg" style="width:100%;height:100%;"></table>
                        </div>
                    </div>
                    <div class="section-divider" id="divider"></div>
                    <!-- 下：盘点明细 -->
                    <div class="section-block" id="bottomBlock" style="flex:1;">
                        <div class="section-title" id="itemsTitle">
                            <span id="itemsTitleText">📦 盘点耗材明细（请先选择盘点单）</span>
                            <div class="title-right" id="itemsSearchBar" style="display:none;">
                                <input id="itemKeyword" type="text" placeholder="耗材名称搜索..."
                                    style="padding:3px 7px;border:1px solid #bbdefb;border-radius:3px;font-size:12px;width:140px;">
                                <button id="btnSearchItems"
                                    style="padding:3px 10px;background:#1976d2;color:#fff;border:none;border-radius:3px;font-size:12px;cursor:pointer;">搜索</button>
                            </div>
                        </div>
                        <div style="flex:1;overflow:hidden;" id="itemsTableWrap">
                            <table id="dgItems" style="width:100%;height:100%;"></table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 右侧详情面板 east -->
            <div data-options="region:'east',split:true" style="width:380px;">
                <div class="detail-panel">
                    <div class="detail-header" id="detailHeader">盘点进度详情</div>
                    <div id="detailContent" style="flex:1;overflow:hidden;display:flex;flex-direction:column;">
                        <div style="padding:30px;color:#90a4ae;text-align:center;font-size:13px;">
                            请点击左侧盘点单列表查看详情
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <!-- 新建盘点单弹窗 -->
        <div id="dlgNew" style="display:none;">
            <div style="padding:16px 20px;">
                <table style="width:100%;border-collapse:collapse;">
                    <tr>
                        <td style="padding:6px 0;width:90px;color:#546e7a;font-size:13px;">盘点周期：</td>
                        <td style="padding:6px 0;">
                            <select id="selYear"
                                style="padding:4px 8px;border:1px solid #cfd8dc;border-radius:3px;font-size:13px;">
                                <option value="2022">2022</option>
                                <option value="2023">2023</option>
                                <option value="2024">2024</option>
                                <option value="2025" selected>2025</option>
                                <option value="2026">2026</option>
                            </select>
                            <select id="selSemester"
                                style="padding:4px 8px;border:1px solid #cfd8dc;border-radius:3px;font-size:13px;margin-left:6px;">
                                <option value="春季学期">春季学期</option>
                                <option value="秋季学期">秋季学期</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:6px 0;color:#546e7a;font-size:13px;">盘点范围：</td>
                        <td style="padding:6px 0;">
                            <select id="selScope"
                                style="padding:4px 8px;border:1px solid #cfd8dc;border-radius:3px;font-size:13px;width:200px;">
                                <option value="all">全部耗材</option>
                                <option value="dangerous">仅危化品</option>
                                <option value="normal">仅非危化品</option>
                            </select>
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <!-- 完成盘点确认弹窗 -->
        <div id="dlgConfirmComplete" style="display:none;">
            <div style="padding:10px 16px;" id="confirmContent">
            </div>
        </div>

        <!-- 打印区域 -->
        <div id="printArea"></div>
        <script>
            var ctx = '${pageContext.request.contextPath}';
            var _selInv = null; // currently selected inventory row

            /* ===== EasyUI Layout Init ===== */
            $(function () {
                // Set current year default
                var yr = new Date().getFullYear();
                $('#selYear option[value="' + yr + '"]').prop('selected', true);

                // Init datagrid - inventory list
                $('#dg').datagrid({
                    fit: true,
                    pagination: true,
                    pageSize: 15,
                    pageList: [15, 30, 50],
                    singleSelect: true,
                    rownumbers: true,
                    striped: true,
                    emptyMsg: '暂无盘点单，请点击「新建盘点单」',
                    columns: [[
                        {
                            field: 'id', title: '盘点单号', width: 80, align: 'center',
                            formatter: function (v) {
                                return '<b style="color:#1565c0;">PD' + String(v).padStart(4, '0') + '</b>';
                            }
                        },
                        { field: 'period', title: '盘点周期', width: 120 },
                        {
                            field: 'scope', title: '盘点范围', width: 110, align: 'center',
                            formatter: function (v) {
                                if (v == 'all') {
                                    return '<span style="display:inline-block;padding:2px 8px;background:#fff3cd;color:#856404;border-radius:3px;font-size:12px;">全部耗材</span>';
                                } else if (v == 'dangerous') {
                                    return '<span style="display:inline-block;padding:2px 8px;background:#f8d7da;color:#721c24;border-radius:3px;font-size:12px;">仅危化品</span>';
                                } else if (v == 'normal') {
                                    return '<span style="display:inline-block;padding:2px 8px;background:#d4edda;color:#155724;border-radius:3px;font-size:12px;">仅非危化品</span>';
                                }
                                return '—';
                            }
                        },
                        { field: 'checker1_name', title: '盘点人', width: 90 },
                        {
                            field: 'status', title: '状态', width: 80, align: 'center',
                            formatter: function (v) {
                                if (v == 0) return '<span class="s0">进行中</span>';
                                if (v == 1) return '<span class="s1">已完成</span>';
                                return v;
                            }
                        },
                        {
                            field: 'create_time', title: '新建时间', width: 140,
                            formatter: function (v) {
                                return v ? String(v).substring(0, 16).replace('T', ' ') : '—';
                            }
                        },
                        {
                            field: 'check_time', title: '完成时间', width: 140,
                            formatter: function (v) {
                                return v ? String(v).substring(0, 16).replace('T', ' ') : '—';
                            }
                        }
                    ]],
                    onSelect: function (idx, row) {
                        _selInv = row;
                        loadItems(row.id);
                        renderDetailPanel(row);
                    },
                    onLoadSuccess: function () {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                // Init items datagrid (no editor - use native inputs)
                $('#dgItems').datagrid({
                    fit: true,
                    singleSelect: true,
                    rownumbers: true,
                    striped: true,
                    emptyMsg: '暂无明细数据',
                    columns: [[
                        {
                            field: 'consumable_name', title: '耗材名称', minWidth: 130,
                            formatter: function (v, row) {
                                var s = v || '—';
                                if (row.is_dangerous == 1) {
                                    s += ' <span class="danger-badge">⚠危</span>';
                                }
                                return s;
                            }
                        },
                        { field: 'unit', title: '单位', width: 50, align: 'center' },
                        { field: 'system_quantity', title: '账面数量', width: 75, align: 'center' },
                        {
                            field: 'real_quantity', title: '实盘数量', width: 90, align: 'center',
                            formatter: function (v, row) {
                                if (_selInv && _selInv.status == 1) {
                                    return '<span>' + (v !== null && v !== undefined ? v : '—') + '</span>';
                                }
                                var diff = (v !== null && v !== undefined) ? (v - row.system_quantity) : 0;
                                var hasDiff = diff !== 0;
                                var cls = hasDiff ? 'qty-input has-diff' : 'qty-input';
                                return '<input type="number" min="0" class="' + cls + '" ' +
                                    'data-id="' + row.id + '" data-sys="' + row.system_quantity + '" ' +
                                    'value="' + (v !== null && v !== undefined ? v : row.system_quantity) + '" ' +
                                    'onchange="onQtyChange(this)" />';
                            }
                        },
                        {
                            field: 'diff_quantity', title: '差异', width: 65, align: 'center',
                            formatter: function (v) {
                                if (v === null || v === undefined || v === '') return '<span class="diff-zero">0</span>';
                                var n = parseInt(v);
                                if (n > 0) return '<span class="diff-pos">+' + n + '</span>';
                                if (n < 0) return '<span class="diff-neg">' + n + '</span>';
                                return '<span class="diff-zero">0</span>';
                            }
                        },
                        {
                            field: 'remark', title: '备注', minWidth: 120,
                            formatter: function (v, row) {
                                if (_selInv && _selInv.status == 1) {
                                    return v || '—';
                                }
                                var diff = row.diff_quantity !== null ? parseInt(row.diff_quantity) : 0;
                                var needRemark = diff !== 0 && (!v || v.trim() === '');
                                var cls = needRemark ? 'remark-input required' : 'remark-input';
                                return '<input type="text" class="' + cls + '" ' +
                                    'data-id="' + row.id + '" ' +
                                    'value="' + (v ? v.replace(/"/g, '&quot;') : '') + '" ' +
                                    'placeholder="' + (needRemark ? '⚠ 差异原因必填' : '') + '" ' +
                                    'onchange="onRemarkChange(this)" />';
                            }
                        }
                    ]]
                });

                // Buttons
                $('#btnNew').click(openNewDialog);
                $('#btnComplete').click(doCompleteSummary);
                $('#btnSearchItems').click(function () {
                    if (!_selInv) return;
                    loadItems(_selInv.id);
                });
                $('#itemKeyword').keydown(function (e) {
                    if (e.keyCode === 13 && _selInv) loadItems(_selInv.id);
                });

                // Load initial data
                loadInventoryList();
            });

            /* ===== Load inventory list ===== */
            function loadInventoryList() {
                $.getJSON(ctx + '/ServletInventory?action=list', { page: 1, rows: 200 }, function (data) {
                    var rows = (data && data.rows) ? data.rows : [];
                    $('#dg').datagrid('loadData', rows);
                }).fail(function () {
                    $.messager.alert('错误', '加载盘点单列表失败', 'error');
                });
            }

            /* ===== Load items for selected inventory ===== */
            function loadItems(invId) {
                var kw = $('#itemKeyword').val() || '';
                var params = { inventory_id: invId };
                if (kw.trim()) params.keyword = kw.trim();
                $.getJSON(ctx + '/ServletInventory?action=listItems', params, function (list) {
                    $('#dgItems').datagrid('loadData', list || []);
                    $('#itemsSearchBar').show();
                    var status = _selInv ? _selInv.status : 0;
                    var statusText = status == 1 ? ' <span class="s1">已完成</span>' : ' <span class="s0">进行中</span>';
                    var pdNo = 'PD' + String(invId).padStart(4, '0');
                    $('#itemsTitleText').html('📦 盘点耗材明细 — ' + pdNo + statusText);
                }).fail(function () {
                    $.messager.alert('错误', '加载明细失败', 'error');
                });
            }

            /* ===== Real quantity change handler ===== */
            function onQtyChange(input) {
                var val = parseFloat($(input).val());
                var sys = parseFloat($(input).data('sys'));
                var id = $(input).data('id');
                if (isNaN(val) || val < 0) {
                    $(input).css('border-color', '#e53935');
                    $.messager.show({ title: '提示', msg: '实盘数量不能为负数', timeout: 2000, showType: 'slide' });
                    return;
                }
                var diff = val - sys;
                // Update diff display in same row
                var tr = $(input).closest('tr');
                var diffCell = tr.find('td').eq(4); // diff column index
                var diffHtml;
                if (diff > 0) diffHtml = '<span class="diff-pos">+' + diff + '</span>';
                else if (diff < 0) diffHtml = '<span class="diff-neg">' + diff + '</span>';
                else diffHtml = '<span class="diff-zero">0</span>';
                diffCell.find('div.datagrid-cell').html(diffHtml);

                // Update remark border
                var remarkInput = tr.find('input.remark-input');
                if (diff !== 0) {
                    $(input).addClass('has-diff');
                    if (!remarkInput.val() || remarkInput.val().trim() === '') {
                        remarkInput.addClass('required').attr('placeholder', '⚠ 差异原因必填');
                    }
                } else {
                    $(input).removeClass('has-diff');
                    remarkInput.removeClass('required').attr('placeholder', '');
                }

                // Auto save
                var remark = remarkInput.val() || '';
                $.post(ctx + '/ServletInventory?action=updateItem', { id: id, real_quantity: val, remark: remark }, function (ret) {
                    var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
                    if (res.code !== '200') {
                        $.messager.show({ title: '保存失败', msg: res.msg, timeout: 3000, showType: 'slide' });
                    }
                });
            }

            /* ===== Remark change handler ===== */
            function onRemarkChange(input) {
                var id = $(input).data('id');
                var remark = $(input).val() || '';
                var tr = $(input).closest('tr');
                var qtyInput = tr.find('input.qty-input');
                var sys = parseFloat(qtyInput.data('sys'));
                var real = parseFloat(qtyInput.val());
                var diff = isNaN(real) ? 0 : (real - sys);
                if (diff !== 0 && remark.trim() === '') {
                    $(input).addClass('required');
                } else {
                    $(input).removeClass('required');
                }
                $.post(ctx + '/ServletInventory?action=updateItem', { id: id, real_quantity: real, remark: remark }, function (ret) {
                    var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
                    if (res.code !== '200') {
                        $.messager.show({ title: '保存失败', msg: res.msg, timeout: 3000, showType: 'slide' });
                    }
                });
            }

            /* ===== Open new inventory dialog ===== */
            function openNewDialog() {
                $('#dlgNew').dialog({
                    title: '新建盘点单',
                    width: 420,
                    height: 200,
                    modal: true,
                    buttons: [{
                        text: '确认创建',
                        iconCls: 'icon-ok',
                        handler: function () { doCreateInventory(); }
                    }, {
                        text: '取消',
                        iconCls: 'icon-cancel',
                        handler: function () { $('#dlgNew').dialog('close'); }
                    }]
                });
            }

            /* ===== Create inventory ===== */
            function doCreateInventory() {
                var year = $('#selYear').val();
                var sem = $('#selSemester').val();
                var period = year + '-' + sem;
                var scope = $('#selScope').val();
                $.messager.progress({ title: '处理中', msg: '正在创建盘点单...' });
                $.post(ctx + '/ServletInventory?action=create', { period: period, scope: scope }, function (ret) {
                    $.messager.progress('close');
                    var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
                    if (res.code === '200') {
                        $('#dlgNew').dialog('close');
                        $.messager.show({ title: '✔ 创建成功', msg: res.msg, timeout: 3000, showType: 'slide' });
                        loadInventoryList();
                    } else {
                        $.messager.alert('提示', res.msg, 'warning');
                    }
                });
            }

            /* ===== Complete summary (Step 1) ===== */
            function doCompleteSummary() {
                if (!_selInv) {
                    $.messager.alert('提示', '请先选择一个盘点单', 'warning');
                    return;
                }
                if (_selInv.status == 1) {
                    $.messager.alert('提示', '该盘点单已完成', 'warning');
                    return;
                }
                $.messager.progress({ title: '处理中', msg: '正在汇总差异...' });
                $.getJSON(ctx + '/ServletInventory?action=completeSummary', { inventory_id: _selInv.id }, function (data) {
                    $.messager.progress('close');
                    if (!data || data.totalItems === undefined) {
                        $.messager.alert('提示', '获取汇总数据失败', 'error');
                        return;
                    }
                    showConfirmDialog(data);
                }).fail(function () {
                    $.messager.progress('close');
                    $.messager.alert('错误', '获取汇总失败', 'error');
                });
            }

            /* ===== Show confirm complete dialog (Step 2) ===== */
            function showConfirmDialog(data) {
                var info = data.invInfo || {};
                var diffItems = data.diffItems || [];
                var hasUnremarkDiff = false;
                $.each(diffItems, function (i, item) {
                    if (item.diff_quantity != 0 && (!item.remark || item.remark.trim() === '')) {
                        hasUnremarkDiff = true;
                    }
                });

                var html = '<div style="margin-bottom:10px;">';
                html += '<b style="color:#1565c0;">盘点单：</b>PD' + String(_selInv.id).padStart(4, '0');
                html += ' &nbsp; <b>周期：</b>' + (info.period || '—');
                html += ' &nbsp; <b>盘点人：</b>' + (info.checker1_name || '—');
                html += '</div>';

                html += '<div class="report-summary">';
                html += '<div class="summary-card"><div class="num">' + data.totalItems + '</div><div class="lbl">总耗材数</div></div>';
                html += '<div class="summary-card"><div class="num">' + data.diffCount + '</div><div class="lbl">有差异耗材</div></div>';
                html += '<div class="summary-card pos"><div class="num">+' + (data.posSum || 0) + '</div><div class="lbl">盘盈</div></div>';
                html += '<div class="summary-card neg"><div class="num">' + (data.negSum || 0) + '</div><div class="lbl">盘亏</div></div>';
                html += '</div>';

                if (diffItems.length > 0) {
                    html += '<div style="font-size:12px;font-weight:bold;color:#546e7a;margin-bottom:4px;">差异明细：</div>';
                    html += '<table class="report-table"><thead><tr>';
                    html += '<th>耗材名称</th><th>单位</th><th>账面</th><th>实盘</th><th>差异</th><th>备注</th>';
                    html += '</tr></thead><tbody>';
                    $.each(diffItems, function (i, item) {
                        var noRemark = item.diff_quantity != 0 && (!item.remark || item.remark.trim() === '');
                        var rowStyle = noRemark ? ' style="background:#fff3f3;"' : '';
                        var diff = parseInt(item.diff_quantity);
                        var diffHtml = diff > 0 ? '<span class="diff-pos">+' + diff + '</span>'
                            : diff < 0 ? '<span class="diff-neg">' + diff + '</span>'
                                : '<span class="diff-zero">0</span>';
                        var remarkHtml = noRemark
                            ? '<span style="color:#e53935;font-weight:bold;">⚠ 请先填写差异原因</span>'
                            : (item.remark || '—');
                        html += '<tr' + rowStyle + '>';
                        html += '<td>' + (item.consumable_name || '—') + '</td>';
                        html += '<td style="text-align:center;">' + (item.unit || '—') + '</td>';
                        html += '<td style="text-align:center;">' + item.system_quantity + '</td>';
                        html += '<td style="text-align:center;">' + item.real_quantity + '</td>';
                        html += '<td style="text-align:center;">' + diffHtml + '</td>';
                        html += '<td>' + remarkHtml + '</td>';
                        html += '</tr>';
                    });
                    html += '</tbody></table>';
                } else {
                    html += '<div style="color:#43a047;padding:8px;font-size:13px;">✔ 本次盘点无差异，账面与实盘完全一致。</div>';
                }

                if (hasUnremarkDiff) {
                    html += '<div style="background:#fff3e0;border:1px solid #ffb74d;border-radius:4px;padding:8px 12px;margin-top:8px;color:#e65100;font-size:12px;">';
                    html += '⚠ 存在差异但未填写备注的耗材，请先在明细列表中填写差异原因后再完成盘点。';
                    html += '</div>';
                }

                $('#confirmContent').html(html);

                var buttons = [];
                if (!hasUnremarkDiff) {
                    buttons.push({
                        text: '确认回写库存',
                        iconCls: 'icon-ok',
                        handler: function () { doComplete(); }
                    });
                }
                buttons.push({
                    text: '取消',
                    iconCls: 'icon-cancel',
                    handler: function () { $('#dlgConfirmComplete').dialog('close'); }
                });

                $('#dlgConfirmComplete').dialog({
                    title: '完成盘点确认',
                    width: 620,
                    height: 480,
                    modal: true,
                    buttons: buttons
                });
            }

            /* ===== Execute complete (Step 4) ===== */
            function doComplete() {
                $('#dlgConfirmComplete').dialog('close');
                $.messager.progress({ title: '处理中', msg: '正在回写库存...' });
                $.post(ctx + '/ServletInventory?action=complete', { inventory_id: _selInv.id }, function (ret) {
                    $.messager.progress('close');
                    var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
                    if (res.code === '200') {
                        $.messager.show({ title: '✔ 盘点完成', msg: res.msg, timeout: 4000, showType: 'slide' });
                        loadInventoryList();
                        // Reload items and show report
                        $.getJSON(ctx + '/ServletInventory?action=completeSummary', { inventory_id: _selInv.id }, function (data) {
                            _selInv.status = 1;
                            renderReport(data);
                        });
                    } else {
                        $.messager.alert('提示', res.msg, 'warning');
                    }
                });
            }

            /* ===== Render detail panel ===== */
            function renderDetailPanel(row) {
                $('#detailHeader').html('盘点进度详情 — PD' + String(row.id).padStart(4, '0'));
                if (row.status == 1) {
                    // Completed: show report
                    $.getJSON(ctx + '/ServletInventory?action=completeSummary', { inventory_id: row.id }, function (data) {
                        renderReport(data);
                    });
                } else {
                    // In progress: show info card
                    var scopeMap = { all: '全部耗材', dangerous: '仅危化品', normal: '仅非危化品' };
                    var scopeLabel = '';
                    if (row.scope == 'all') {
                        scopeLabel = '<span style="display:inline-block;padding:2px 8px;background:#fff3cd;color:#856404;border-radius:3px;font-size:12px;">全部耗材</span>';
                    } else if (row.scope == 'dangerous') {
                        scopeLabel = '<span style="display:inline-block;padding:2px 8px;background:#f8d7da;color:#721c24;border-radius:3px;font-size:12px;">仅危化品</span>';
                    } else if (row.scope == 'normal') {
                        scopeLabel = '<span style="display:inline-block;padding:2px 8px;background:#d4edda;color:#155724;border-radius:3px;font-size:12px;">仅非危化品</span>';
                    } else {
                        scopeLabel = '—';
                    }
                    var html = '<div class="info-card">';
                    html += '<div class="info-grid">';
                    html += '<div class="info-item"><span class="lbl">盘点单号：</span><span class="val"><b>PD' + String(row.id).padStart(4, '0') + '</b></span></div>';
                    html += '<div class="info-item"><span class="lbl">状态：</span><span class="val"><span class="s0">进行中</span></span></div>';
                    html += '<div class="info-item"><span class="lbl">盘点周期：</span><span class="val">' + (row.period || '—') + '</span></div>';
                    html += '<div class="info-item"><span class="lbl">盘点范围：</span><span class="val">' + scopeLabel + '</span></div>';
                    html += '<div class="info-item"><span class="lbl">盘点人：</span><span class="val">' + (row.checker1_name || '—') + '</span></div>';
                    html += '<div class="info-item"><span class="lbl">新建时间：</span><span class="val">' + (row.create_time ? String(row.create_time).substring(0, 16).replace('T', ' ') : '—') + '</span></div>';
                    html += '</div></div>';
                    html += '<div style="padding:16px;color:#90a4ae;font-size:12px;">盘点进行中，请在下方明细列表录入实盘数量，完成后点击「完成盘点并回写库存」。</div>';
                    $('#detailContent').html(html);
                }
            }

            /* ===== Render completed report ===== */
            function renderReport(data) {
                var info = data.invInfo || {};
                var diffItems = data.diffItems || [];
                var invId = _selInv ? _selInv.id : 0;

                var html = '<div class="report-section" id="reportBody">';
                html += '<div class="report-title">📊 盘点报告</div>';

                // Header info
                var scopeLabel = '';
                if (info.scope == 'all') {
                    scopeLabel = '<span style="display:inline-block;padding:2px 8px;background:#fff3cd;color:#856404;border-radius:3px;font-size:12px;">全部耗材</span>';
                } else if (info.scope == 'dangerous') {
                    scopeLabel = '<span style="display:inline-block;padding:2px 8px;background:#f8d7da;color:#721c24;border-radius:3px;font-size:12px;">仅危化品</span>';
                } else if (info.scope == 'normal') {
                    scopeLabel = '<span style="display:inline-block;padding:2px 8px;background:#d4edda;color:#155724;border-radius:3px;font-size:12px;">仅非危化品</span>';
                } else {
                    scopeLabel = '—';
                }
                html += '<div class="info-grid" style="margin-bottom:10px;">';
                html += '<div class="info-item"><span class="lbl">盘点单号：</span><span class="val"><b>PD' + String(invId).padStart(4, '0') + '</b></span></div>';
                html += '<div class="info-item"><span class="lbl">状态：</span><span class="val"><span class="s1">已完成</span></span></div>';
                html += '<div class="info-item"><span class="lbl">盘点周期：</span><span class="val">' + (info.period || '—') + '</span></div>';
                html += '<div class="info-item"><span class="lbl">盘点范围：</span><span class="val">' + scopeLabel + '</span></div>';
                html += '<div class="info-item"><span class="lbl">新建时间：</span><span class="val">' + (info.create_time ? String(info.create_time).substring(0, 16).replace('T', ' ') : '—') + '</span></div>';
                html += '<div class="info-item"><span class="lbl">完成时间：</span><span class="val">' + (info.check_time ? String(info.check_time).substring(0, 16).replace('T', ' ') : '—') + '</span></div>';
                html += '<div class="info-item"><span class="lbl">盘点人：</span><span class="val">' + (info.checker1_name || '—') + '</span></div>';
                html += '</div>';

                // Summary cards
                html += '<div class="report-summary">';
                html += '<div class="summary-card"><div class="num">' + (data.totalItems || 0) + '</div><div class="lbl">总耗材数</div></div>';
                html += '<div class="summary-card"><div class="num">' + (data.diffCount || 0) + '</div><div class="lbl">差异耗材</div></div>';
                html += '<div class="summary-card pos"><div class="num">+' + (data.posSum || 0) + '</div><div class="lbl">盘盈</div></div>';
                html += '<div class="summary-card neg"><div class="num">' + (data.negSum || 0) + '</div><div class="lbl">盘亏</div></div>';
                html += '</div>';

                // Diff table
                if (diffItems.length > 0) {
                    html += '<div style="font-size:12px;font-weight:bold;color:#546e7a;margin-bottom:4px;">差异明细：</div>';
                    html += '<table class="report-table"><thead><tr>';
                    html += '<th>耗材名称</th><th>单位</th><th>账面</th><th>实盘</th><th>差异</th><th>备注</th>';
                    html += '</tr></thead><tbody>';
                    $.each(diffItems, function (i, item) {
                        var diff = parseInt(item.diff_quantity);
                        var diffHtml = diff > 0 ? '<span class="diff-pos">+' + diff + '</span>'
                            : diff < 0 ? '<span class="diff-neg">' + diff + '</span>'
                                : '<span class="diff-zero">0</span>';
                        html += '<tr>';
                        html += '<td>' + (item.consumable_name || '—') + (item.is_dangerous == 1 ? ' <span class="danger-badge">⚠危</span>' : '') + '</td>';
                        html += '<td style="text-align:center;">' + (item.unit || '—') + '</td>';
                        html += '<td style="text-align:center;">' + item.system_quantity + '</td>';
                        html += '<td style="text-align:center;">' + item.real_quantity + '</td>';
                        html += '<td style="text-align:center;">' + diffHtml + '</td>';
                        html += '<td>' + (item.remark || '—') + '</td>';
                        html += '</tr>';
                    });
                    html += '</tbody></table>';
                } else {
                    html += '<div style="color:#43a047;padding:8px;font-size:13px;background:#f1f8e9;border-radius:4px;">✔ 本次盘点无差异，账面与实盘完全一致。</div>';
                }

                // Export buttons
                html += '<div class="export-bar">';
                html += '<button class="btn-export btn-excel" onclick="exportCSV()">📥 导出 Excel</button>';
                html += '<button class="btn-export btn-print" onclick="doPrint()">🖨 打印/导出 PDF</button>';
                html += '</div>';

                // Adjustment log
                if (diffItems.length > 0) {
                    html += '<div class="log-section">';
                    html += '<div class="log-title">📝 调整日志</div>';
                    $.each(diffItems, function (i, item) {
                        var diff = parseInt(item.diff_quantity);
                        var adjHtml = diff > 0
                            ? '<span class="adj-pos">+' + diff + '</span>'
                            : '<span class="adj-neg">' + diff + '</span>';
                        html += '<div class="log-item">';
                        html += '<span style="flex:1;">' + (item.consumable_name || '—') + '</span>';
                        html += '<span>' + adjHtml + ' ' + (item.unit || '') + '</span>';
                        html += '<span style="color:#546e7a;flex:2;">' + (item.remark || '无备注') + '</span>';
                        html += '<span style="color:#90a4ae;">' + (info.checker1_name || '—') + '</span>';
                        html += '</div>';
                    });
                    html += '</div>';
                }

                html += '</div>'; // report-section

                // Store report data for export
                window._reportData = data;
                window._reportInvId = invId;

                $('#detailContent').html(html);
            }

            /* ===== Export CSV ===== */
            function exportCSV() {
                var data = window._reportData;
                if (!data) { $.messager.alert('提示', '无报告数据可导出', 'warning'); return; }
                var invId = window._reportInvId || 0;
                var info = data.invInfo || {};
                var allItems = data.allItems || [];
                var rows = [];
                rows.push(['盘点报告']);
                rows.push(['盘点单号', 'PD' + String(invId).padStart(4, '0')]);
                rows.push(['盘点周期', info.period || '']);
                rows.push(['盘点人', info.checker1_name || '']);
                rows.push(['完成时间', info.check_time ? String(info.check_time).substring(0, 16).replace('T', ' ') : '']);
                rows.push([]);
                rows.push(['总耗材数', data.totalItems || 0, '差异耗材', data.diffCount || 0, '盘盈', data.posSum || 0, '盘亏', data.negSum || 0]);
                rows.push([]);
                rows.push(['耗材名称', '单位', '账面数量', '实盘数量', '差异', '备注']);
                $.each(allItems, function (i, item) {
                    rows.push([
                        item.consumable_name || '',
                        item.unit || '',
                        item.system_quantity,
                        item.real_quantity,
                        item.diff_quantity,
                        item.remark || ''
                    ]);
                });
                var csv = rows.map(function (r) {
                    return r.map(function (cell) {
                        var s = String(cell === null || cell === undefined ? '' : cell);
                        if (s.indexOf(',') >= 0 || s.indexOf('"') >= 0 || s.indexOf('\n') >= 0) {
                            s = '"' + s.replace(/"/g, '""') + '"';
                        }
                        return s;
                    }).join(',');
                }).join('\n');
                var bom = '\uFEFF';
                var blob = new Blob([bom + csv], { type: 'text/csv;charset=utf-8;' });
                var url = URL.createObjectURL(blob);
                var a = document.createElement('a');
                a.href = url;
                a.download = '盘点报告_PD' + String(invId).padStart(4, '0') + '.csv';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            }

            /* ===== Print ===== */
            function doPrint() {
                var reportBody = document.getElementById('reportBody');
                if (!reportBody) { $.messager.alert('提示', '无报告内容可打印', 'warning'); return; }
                var printArea = document.getElementById('printArea');
                printArea.innerHTML = reportBody.innerHTML;
                window.print();
                printArea.innerHTML = '';
            }

        </script>
    </body>

    </html>