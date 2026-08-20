<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>出库登记</title>
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

            /* Tabs 样式 */
            .tabs-container {
                height: calc(100vh - 44px);
                display: flex;
                flex-direction: column;
            }

            .tabs-header {
                display: flex;
                background: #f0f4fa;
                border-bottom: 1px solid #e3eaf5;
            }

            .tab-btn {
                padding: 12px 28px;
                font-size: 14px;
                cursor: pointer;
                border: none;
                background: transparent;
                color: #546e7a;
                font-weight: 600;
                border-bottom: 2px solid transparent;
                transition: all .2s;
            }

            .tab-btn:hover {
                color: #1976d2;
                background: #e3f2fd;
            }

            .tab-btn.active {
                color: #1976d2;
                background: #fff;
                border-bottom-color: #1976d2;
            }

            .tab-content {
                flex: 1;
                overflow: auto;
                display: none;
            }

            .tab-content.active {
                display: flex;
                flex-direction: column;
            }

            .form-wrap {
                padding: 20px 24px;
                background: #f8fafc;
                border-bottom: 1px solid #e3eaf5;
            }

            .form-row {
                display: flex;
                align-items: flex-start;
                gap: 12px;
                margin-bottom: 14px;
            }

            .form-row .f-label {
                width: 90px;
                flex-shrink: 0;
                font-size: 13px;
                color: #546e7a;
                font-weight: 600;
                line-height: 28px;
                text-align: right;
            }

            .form-row .f-ctrl {
                flex: 1;
                max-width: 480px;
            }

            .stock-tip {
                display: inline-block;
                margin-left: 10px;
                font-size: 12px;
                color: #1976d2;
                background: #e3f2fd;
                border-radius: 4px;
                padding: 2px 10px;
                line-height: 24px;
                vertical-align: middle;
            }

            .stock-tip.warn {
                color: #e65100;
                background: #fff3e0;
            }

            .danger-warn {
                background: #fff3e0;
                border: 1px solid #ffcc80;
                border-radius: 6px;
                padding: 8px 14px;
                font-size: 12px;
                color: #e65100;
                display: none;
                margin-bottom: 14px;
            }

            .btn-submit {
                background: linear-gradient(90deg, #1565c0, #1976d2);
                color: #fff;
                border: none;
                border-radius: 5px;
                padding: 8px 28px;
                font-size: 14px;
                cursor: pointer;
                font-family: "微软雅黑";
                font-weight: bold;
            }

            .btn-submit:hover {
                background: #0d47a1;
            }

            /* 明细表格 */
            .item-section {
                padding: 0 24px 16px;
            }

            .item-section-title {
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
                margin-bottom: 8px;
                padding-bottom: 6px;
                border-bottom: 2px solid #e3eaf5;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .item-table-wrap {
                border: 1px solid #e8eef7;
                border-radius: 6px;
                overflow: hidden;
            }

            .item-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 13px;
            }

            .item-table th {
                background: #f0f4fa;
                padding: 8px 10px;
                text-align: left;
                border-bottom: 1px solid #e3eaf5;
                color: #546e7a;
                white-space: nowrap;
            }

            .item-table td {
                padding: 7px 10px;
                border-bottom: 1px solid #f5f5f5;
                vertical-align: middle;
            }

            .item-table tr:last-child td {
                border-bottom: none;
            }

            .item-table tr:hover td {
                background: #f5f9ff;
            }

            .cell-input {
                width: 100%;
                height: 26px;
                border: 1px solid #cfd8dc;
                border-radius: 3px;
                padding: 0 6px;
                font-size: 12px;
                font-family: "微软雅黑";
                outline: none;
                box-sizing: border-box;
            }

            .cell-input:focus {
                border-color: #1976d2;
            }

            .cell-input.err {
                border-color: #e53935 !important;
                background: #fff8f8;
            }

            .btn-add-row {
                font-size: 12px;
                padding: 3px 12px;
                border: 1px solid #90caf9;
                border-radius: 4px;
                background: #e3f2fd;
                color: #1976d2;
                cursor: pointer;
            }

            .btn-add-row:hover {
                background: #1976d2;
                color: #fff;
            }

            .btn-del-row {
                font-size: 12px;
                padding: 2px 8px;
                border: 1px solid #ef9a9a;
                border-radius: 4px;
                background: #ffebee;
                color: #e53935;
                cursor: pointer;
            }

            .btn-del-row:hover {
                background: #e53935;
                color: #fff;
            }

            .empty-tip {
                text-align: center;
                padding: 20px;
                color: #b0bec5;
                font-size: 13px;
            }

            /* 出库记录页面样式 */
            .records-section {
                padding: 20px 24px;
                flex: 1;
                display: flex;
                flex-direction: column;
            }

            .search-bar {
                background: #f8fafc;
                padding: 14px 18px;
                border-radius: 6px;
                margin-bottom: 14px;
                display: flex;
                gap: 12px;
                align-items: center;
                flex-wrap: wrap;
            }

            .search-label {
                font-size: 13px;
                color: #546e7a;
                font-weight: 600;
            }

            .search-input {
                border: 1px solid #cfd8dc;
                border-radius: 4px;
                padding: 6px 10px;
                font-size: 13px;
                width: 150px;
            }

            .search-input:focus {
                border-color: #1976d2;
                outline: none;
            }

            .btn-search {
                background: linear-gradient(90deg, #1565c0, #1976d2);
                color: #fff;
                border: none;
                border-radius: 4px;
                padding: 6px 20px;
                font-size: 13px;
                cursor: pointer;
            }

            .btn-search:hover {
                background: #0d47a1;
            }

            .btn-reset {
                background: #eceff1;
                color: #546e7a;
                border: none;
                border-radius: 4px;
                padding: 6px 16px;
                font-size: 13px;
                cursor: pointer;
            }

            .btn-reset:hover {
                background: #cfd8dc;
            }

            .data-grid-wrap {
                height: calc(100% - 80px);
            }

            .status-tag {
                padding: 3px 10px;
                border-radius: 12px;
                font-size: 12px;
                display: inline-block;
            }

            .status-tag.completed {
                background: #e8f5e9;
                color: #2e7d32;
            }

            /* 下拉框样式优化 */
            select.cell-input option.stock-green {
                color: #2e7d32;
                font-weight: 600;
            }

            select.cell-input option.stock-red {
                color: #e53935;
            }
        </style>
        <script>
            var ctx = '${pageContext.request.contextPath}';
            var itemRows = [];
            var consumableMap = {};  // id -> {name, unit, is_dangerous, stock_qty, has_stock}

            $(function () {
                loadConsumableOptions();
                initOutboundRecords();
            });

            // Tab 切换
            function switchTab(tabIndex) {
                $('.tab-btn').removeClass('active');
                $('.tab-btn').eq(tabIndex).addClass('active');
                $('.tab-content').removeClass('active');
                $('.tab-content').eq(tabIndex).addClass('active');

                // 如果切换到出库记录，重新加载并触发 datagrid resize
                if (tabIndex === 1) {
                    setTimeout(function () {
                        $('#recordsGrid').datagrid('resize');
                        reloadRecords();
                    }, 100);
                }
            }

            var consumableList = []; // 排序后的耗材列表

            function loadConsumableOptions() {
                $.getJSON(ctx + '/ServletOutbound?action=consumableOptionsWithStock', function (data) {
                    consumableMap = {};
                    consumableList = (data || []).slice();
                    // 排序：有库存的排前面
                    consumableList.sort(function (a, b) {
                        if (a.has_stock && !b.has_stock) return -1;
                        if (!a.has_stock && b.has_stock) return 1;
                        return b.id - a.id; // 按ID倒序
                    });
                    consumableList.forEach(function (c) {
                        consumableMap[String(c.id)] = c;
                    });
                    // 仅在明细为空时添加默认行
                    if (itemRows.length === 0) addRow();
                    else renderTable();
                }).fail(function () {
                    // 加载失败时显示提示，不阻塞页面
                    $('#itemTbody').html('<tr><td colspan="7" style="text-align:center;padding:20px;color:#e53935;">耗材数据加载失败，请刷新页面重试</td></tr>');
                });
            }

            // 获取当前已选中的耗材ID集合
            function getSelectedIds() {
                var ids = {};
                itemRows.forEach(function (r) { if (r.consumable_id) ids[String(r.consumable_id)] = true; });
                return ids;
            }

            function addRow() {
                itemRows.push({ consumable_id: '', quantity: '', purpose: '' });
                renderTable();
            }

            function removeRow(idx) {
                itemRows.splice(idx, 1);
                renderTable();
                checkDanger();
            }

            function onConsumableChange(idx, val) {
                // 防重：若其他行已选了该耗材，拒绝并重置
                if (val) {
                    for (var j = 0; j < itemRows.length; j++) {
                        if (j !== idx && String(itemRows[j].consumable_id) === String(val)) {
                            $.messager.alert('提示', '「' + (consumableMap[val] ? consumableMap[val].name : val) + '」已在第' + (j + 1) + '行，请直接修改该行数量', 'warning');
                            // 重置当前行下拉回空
                            itemRows[idx].consumable_id = '';
                            renderTable();
                            return;
                        }
                    }
                }
                itemRows[idx].consumable_id = val;
                var info = consumableMap[String(val)];
                if (info) {
                    itemRows[idx]._name = info.name;
                    itemRows[idx]._unit = info.unit;
                    itemRows[idx]._stock = info.stock_qty;
                    itemRows[idx]._dangerous = info.is_dangerous;
                    itemRows[idx]._hasStock = info.has_stock;
                }
                renderTable();
                checkDanger();
            }

            function onQtyChange(idx, val) {
                itemRows[idx].quantity = val;
            }

            function onPurposeChange(idx, val) {
                itemRows[idx].purpose = val;
            }

            function checkDanger() {
                var hasDanger = itemRows.some(function (r) {
                    var info = consumableMap[String(r.consumable_id)];
                    return info && info.is_dangerous == 1;
                });
                $('#dangerWarn').toggle(hasDanger);
            }

            function renderTable() {
                if (itemRows.length === 0) {
                    $('#itemTbody').html('<tr><td colspan="7" class="empty-tip">暂无明细，点击「添加耗材」</td></tr>');
                    return;
                }

                // 已选中的耗材ID集合（用于置灰）
                var selectedIds = getSelectedIds();

                var html = '';
                itemRows.forEach(function (r, i) {
                    var info = consumableMap[String(r.consumable_id)] || {};

                    // 当前库存显示
                    var stockTip = '';
                    if (r.consumable_id) {
                        var sq = info.stock_qty != null ? info.stock_qty : 0;
                        var cls = sq <= 0 ? 'warn' : '';
                        stockTip = '<span class="stock-tip ' + cls + '">库存: ' + sq + (info.unit || '') + '</span>';
                    }
                    var dangerTag = info.is_dangerous == 1 ? '<span style="color:#e53935;font-size:11px;margin-left:4px;">⚠危</span>' : '';

                    // 构建下拉：优化显示，有库存排前，颜色区分
                    var selOpts = '';
                    consumableList.forEach(function (c) {
                        var id = c.id;
                        var dt = c.is_dangerous == 1 ? ' 【危】' : '';
                        var sel = String(r.consumable_id) === String(id) ? 'selected' : '';
                        // 其他行已选中该耗材则置灰
                        var isUsed = selectedIds[String(id)] && String(r.consumable_id) !== String(id);
                        var disabled = isUsed ? 'disabled' : '';
                        var optStyle = isUsed ? 'style="color:#b0bec5;"' : (c.has_stock ? 'style="color:#2e7d32;font-weight:600;"' : 'style="color:#e53935;"');
                        // 优化选项文本，显示库存
                        selOpts += '<option value="' + id + '" ' + sel + ' ' + disabled + ' ' + optStyle
                            + ' data-unit="' + (c.unit || '') + '" data-stock="' + c.stock_qty + '" data-danger="' + c.is_dangerous + '">'
                            + c.name + (c.unit ? ' (' + c.unit + ')' : '') + dt + ' - 库存:' + c.stock_qty
                            + '</option>';
                    });
                    // 若当前行未选耗材，在最前面加一个不可提交的提示项
                    if (!r.consumable_id) {
                        selOpts = '<option value="" disabled selected style="color:#b0bec5;">请选择耗材</option>' + selOpts;
                    }

                    // 行错误高亮
                    var rowErr = r._err ? 'background:#fff8f8;' : '';
                    // 数量是否有错
                    var qtyErr = r._err && (!r.quantity || parseInt(r.quantity) <= 0);
                    // 耗材是否有错
                    var selErr = r._err && !r.consumable_id;

                    html += '<tr id="outRow' + i + '" style="' + rowErr + '">'
                        + '<td style="text-align:center;color:#90a4ae;width:40px;">' + (i + 1) + '</td>'
                        // 耗材列
                        + '<td style="width:260px;">'
                        + '<select class="cell-input' + (selErr ? ' err' : '') + '" onchange="onConsumableChange(' + i + ',this.value)" style="width:100%;">' + selOpts + '</select>'
                        + dangerTag
                        + '</td>'
                        + '<td style="width:60px;text-align:center;">' + (info.unit || '—') + '</td>'
                        + '<td style="width:100px;">'
                        + stockTip
                        + '</td>'
                        + '<td style="width:90px;">'
                        + '<input class="cell-input' + (qtyErr ? ' err' : '') + '" type="number" min="1" placeholder="必填"'
                        + ' value="' + (r.quantity || '') + '" onchange="onQtyChange(' + i + ',this.value)" style="width:70px;">'
                        + '</td>'
                        + '<td style="width:200px;">'
                        + '<input class="cell-input" value="' + (r.purpose || '') + '" placeholder="用途说明（选填）" onchange="onPurposeChange(' + i + ',this.value)">'
                        + '</td>'
                        + '<td style="width:60px;text-align:center;">'
                        + '<button class="btn-del-row" onclick="removeRow(' + i + ')">删除</button>'
                        + '</td>'
                        + '</tr>';
                });
                $('#itemTbody').html(html);
            }

            function doSubmit() {
                if (itemRows.length === 0) {
                    $.messager.alert('提示', '请至少添加一条出库明细', 'warning'); return;
                }

                // 同步每行的实际值到 itemRows
                $('#itemTbody tr[id^="outRow"]').each(function (i) {
                    if (!itemRows[i]) return;
                    var $row = $(this);
                    var selVal = $row.find('select.cell-input').val();
                    var qtyVal = $row.find('input[type="number"]').val();
                    var purposeVal = $row.find('input:not([type="number"])').val();
                    if (selVal !== undefined) itemRows[i].consumable_id = selVal || '';
                    if (qtyVal !== undefined) itemRows[i].quantity = qtyVal;
                    if (purposeVal !== undefined) itemRows[i].purpose = purposeVal || '';
                });

                // 清除旧错误标记
                itemRows.forEach(function (r) { r._err = false; });

                var firstErrIdx = -1;
                var errMsgs = [];

                itemRows.forEach(function (r, i) {
                    var rowNum = i + 1;
                    var hasErr = false;
                    var qty = parseInt(r.quantity);

                    if (!r.consumable_id || isNaN(qty) || qty <= 0) {
                        errMsgs.push('第' + rowNum + '行耗材未选择或数量不能为空，请补充');
                        r._err = true;
                        hasErr = true;
                    } else {
                        var info = consumableMap[String(r.consumable_id)];
                        if (info && qty > info.stock_qty) {
                            errMsgs.push('第' + rowNum + '行「' + info.name + '」：出库数量(' + qty + ')超过库存(' + info.stock_qty + ')');
                            r._err = true;
                            hasErr = true;
                        }
                    }
                    if (hasErr && firstErrIdx === -1) firstErrIdx = i;
                });

                renderTable();

                if (errMsgs.length > 0) {
                    if (firstErrIdx >= 0) {
                        var $errRow = $('#outRow' + firstErrIdx);
                        if ($errRow.length) {
                            $errRow[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
                        }
                    }
                    $.messager.alert('校验失败',
                        '<ul style="margin:4px 0;padding-left:18px;">'
                        + errMsgs.map(function (e) { return '<li style="margin-bottom:4px;">' + e + '</li>'; }).join('')
                        + '</ul>',
                        'warning');
                    return;
                }

                var purpose = itemRows.map(function (r) { return r.purpose; }).filter(Boolean).join('；');

                var hasDanger = itemRows.some(function (r) { return r._dangerous == 1; });

                if (hasDanger) {
                    $.messager.confirm('危化品出库提醒',
                        '<div style="padding:8px;color:#e53935;font-size:14px;">⚠ 注意：当前包含危化品，出库时需落实五双管理，要求双人到场</div>',
                        function (confirmed) {
                            if (!confirmed) return;
                            confirmOutbound(purpose);
                        }
                    );
                } else {
                    confirmOutbound(purpose);
                }
            }

            function confirmOutbound(purpose) {
                $.messager.confirm('确认出库', '确认执行出库并扣减库存？此操作不可撤销。', function (r) {
                    if (!r) return;
                    $.messager.progress({ title: '处理中', msg: '正在出库...' });
                    $.post(ctx + '/ServletOutbound?action=directOutbound', {
                        itemsJson: JSON.stringify(itemRows.map(function (r) {
                            return { consumable_id: r.consumable_id, quantity: parseInt(r.quantity), purpose: r.purpose };
                        })),
                        purpose: purpose
                    }, function (ret) {
                        $.messager.progress('close');
                        var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                        if (res.code == '200') {
                            $.messager.show({ title: '✔ 出库成功', msg: res.msg, timeout: 2500, showType: 'slide' });
                            itemRows = [];
                            loadConsumableOptions();
                        } else {
                            $.messager.alert('提示', res.msg, 'warning');
                        }
                    });
                });
            }

            // ========== 出库记录功能 ==========
            function initOutboundRecords() {
                $('#recordsGrid').datagrid({
                    url: ctx + '/ServletOutbound?action=listOutboundRecords',
                    method: 'get',
                    fit: true,
                    border: false,
                    striped: true,
                    pagination: true,
                    pageSize: 10,
                    pageList: [10, 20, 50],
                    rownumbers: true,
                    singleSelect: true,
                    columns: [[
                        { field: 'id', title: '出库单号', width: 100, sortable: true },
                        { field: 'apply_user_name', title: '申请人', width: 100 },
                        { field: 'course_name', title: '课程名称', width: 120 },
                        { field: 'class_name', title: '班级', width: 100 },
                        { field: 'purpose', title: '用途说明', width: 200 },
                        { field: 'item_count', title: '耗材种类', width: 90, align: 'center', formatter: function (v) { return v + '种'; } },
                        { field: 'audit_time', title: '出库时间', width: 150, sortable: true },
                        { field: 'audit_user_name', title: '操作人', width: 100 },
                        {
                            field: '_opt', title: '操作', width: 100, formatter: function (v, r, i) {
                                return '<a href="javascript:void(0)" onclick="viewRecordDetail(' + r.id + ')" style="color:#1976d2;">查看明细</a>';
                            }
                        }
                    ]],
                    toolbar: '#recordsToolbar'
                });
            }

            function reloadRecords() {
                var orderId = $('#searchOrderId').val();
                var dateFrom = $('#searchDateFrom').val();
                var dateTo = $('#searchDateTo').val();

                $('#recordsGrid').datagrid('load', {
                    order_id: orderId,
                    date_from: dateFrom,
                    date_to: dateTo
                });
            }

            function resetSearch() {
                $('#searchOrderId').val('');
                $('#searchDateFrom').val('');
                $('#searchDateTo').val('');
                reloadRecords();
            }

            function viewRecordDetail(outboundId) {
                // 打开明细弹窗
                $('<div id="detailDialog"></div>').dialog({
                    title: '出库明细（单号：' + outboundId + '）',
                    width: 700,
                    height: 450,
                    href: ctx + '/outbound/orderDetail.jsp?orderId=' + outboundId,
                    modal: true,
                    buttons: [{
                        text: '关闭',
                        handler: function () { $(this).dialog('close'); }
                    }],
                    onClose: function () { $(this).dialog('destroy'); }
                });
            }
        </script>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">📦</span>
            出库登记
            <span class="sub">实验室管理员直接登记耗材出库，实时扣减库存</span>
        </div>

        <div class="tabs-container">
            <!-- Tabs 头部 -->
            <div class="tabs-header">
                <button class="tab-btn active" onclick="switchTab(0)">新建出库</button>
                <button class="tab-btn" onclick="switchTab(1)">出库记录</button>
            </div>

            <!-- Tab 1：新建出库 -->
            <div class="tab-content active" id="tabNew" style="overflow-y:auto;flex-direction:column;">
                <!-- 危化品提示 -->
                <div id="dangerWarn" class="danger-warn" style="margin:14px 24px 0;">
                    ⚠ 当前明细中包含危险化学品，请确认已落实「五双管理」制度（双人领用、双人记录）。
                </div>

                <!-- 明细区 -->
                <div class="item-section" style="margin-top:14px;flex:1;overflow:auto;">
                    <div class="item-section-title">
                        出库明细
                        <button class="btn-add-row" onclick="addRow()">＋ 添加耗材</button>
                        <span style="font-size:11px;color:#90a4ae;font-weight:normal;">有库存耗材优先显示且标绿色，无库存标红色</span>
                    </div>
                    <div class="item-table-wrap">
                        <table class="item-table">
                            <thead>
                                <tr>
                                    <th style="width:40px;text-align:center;">序号</th>
                                    <th>耗材名称 <span style="color:#e53935;">*</span></th>
                                    <th style="width:60px;">单位</th>
                                    <th style="width:100px;">当前库存</th>
                                    <th style="width:90px;">出库数量 <span style="color:#e53935;">*</span></th>
                                    <th style="width:200px;">用途说明</th>
                                    <th style="width:60px;text-align:center;">操作</th>
                                </tr>
                            </thead>
                            <tbody id="itemTbody">
                                <tr>
                                    <td colspan="7" class="empty-tip">加载中...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- 提交按钮 -->
                <div style="padding: 16px 24px;flex-shrink:0;background:#fff;border-top:1px solid #e3eaf5;">
                    <button class="btn-submit" onclick="doSubmit()">✔ 确认出库</button>
                    <span style="font-size:12px;color:#90a4ae;margin-left:12px;">出库后库存立即扣减，请核对数量后再提交</span>
                </div>
            </div>

            <!-- Tab 2：出库记录 -->
            <div class="tab-content" id="tabRecords">
                <div class="records-section">
                    <!-- 搜索栏 -->
                    <div id="recordsToolbar" class="search-bar">
                        <span class="search-label">出库单号：</span>
                        <input type="text" id="searchOrderId" class="search-input" placeholder="请输入单号">
                        <span class="search-label">日期范围：</span>
                        <input type="date" id="searchDateFrom" class="search-input">
                        <span style="color:#90a4ae;">至</span>
                        <input type="date" id="searchDateTo" class="search-input">
                        <button class="btn-search" onclick="reloadRecords()">搜索</button>
                        <button class="btn-reset" onclick="resetSearch()">重置</button>
                    </div>
                    <!-- 数据表格 -->
                    <div id="recordsGrid" class="data-grid-wrap"></div>
                </div>
            </div>
        </div>
    </body>

    </html>