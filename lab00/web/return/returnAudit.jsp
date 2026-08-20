<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>归还登记审核</title>
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

            .chem-banner {
                background: #ff6f00;
                color: #fff;
                padding: 5px 14px;
                font-size: 12px;
                font-weight: bold;
                letter-spacing: .3px;
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

            .filter-bar label {
                font-size: 12px;
                color: #546e7a;
            }

            .action-bar {
                background: #fff;
                border-bottom: 1px solid #e8eef7;
                padding: 5px 10px;
                display: flex;
                align-items: center;
                gap: 6px;
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

            /* 危化品徽章 */
            .danger-badge {
                display: inline-block;
                padding: 1px 7px;
                border-radius: 8px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            /* 逾期徽章 */
            .overdue-badge {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 6px;
                font-size: 11px;
                font-weight: bold;
                background: #c62828;
                color: #fff;
                margin-left: 6px;
            }

            /* 倒计时样式 */
            .countdown-green {
                color: #43a047;
                font-weight: 500;
            }

            .countdown-orange {
                color: #ff9800;
                font-weight: bold;
            }

            .countdown-red {
                color: #e53935;
                font-weight: bold;
            }

            /* 右侧详情面板 */
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
                min-width: 72px;
                flex-shrink: 0;
            }

            .info-row .val {
                color: #263238;
                flex: 1;
                word-break: break-all;
            }

            .reject-box {
                background: #fff8e1;
                border: 1px solid #ffe082;
                border-radius: 6px;
                padding: 10px 12px;
                font-size: 13px;
                color: #5d4037;
                white-space: pre-wrap;
                min-height: 40px;
            }

            .danger-warn-box {
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
                border-color: #1976d2;
            }
        </style>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <%--=====页面头部=====--%>
            <div class="page-header">
                <span style="font-size:20px;">↩️</span>
                归还登记审核
                <span class="sub">查看并审核教师提交的耗材归还申请，通过后自动回补库存</span>
            </div>

            <%--=====EasyUI 布局=====--%>
                <div class="easyui-layout" data-options="fit:true" style="height:calc(100vh - 44px);">

                    <%-- north：危化品横幅 + 筛选栏 + 操作栏 --%>
                        <div data-options="region:'north',border:false" style="height:auto;">

                            <div class="chem-banner">
                                ⚠ 含危化品的归还申请需双人现场核验后再执行审核通过
                            </div>

                            <div class="filter-bar">
                                <label>状态：</label>
                                <select id="filterStatus" class="easyui-combobox" style="width:100px;"
                                    data-options="editable:false,panelHeight:'auto',onChange:function(){ doSearch(); }">
                                    <option value="">全部</option>
                                    <option value="0">待审核</option>
                                    <option value="1">已通过</option>
                                    <option value="2">已驳回</option>
                                </select>

                                <label>耗材名称：</label>
                                <input id="filterConsumable" class="easyui-textbox" style="width:130px;"
                                    data-options="prompt:'耗材名称'">

                                <label>归还人：</label>
                                <input id="filterUser" class="easyui-textbox" style="width:110px;"
                                    data-options="prompt:'归还人姓名'">

                                <label>课程：</label>
                                <input id="filterCourse" class="easyui-textbox" style="width:110px;"
                                    data-options="prompt:'课程名称'">

                                <label>班级：</label>
                                <input id="filterClass" class="easyui-textbox" style="width:110px;"
                                    data-options="prompt:'班级名称'">

                                <a id="btnSearch" href="javascript:void(0)" class="easyui-linkbutton"
                                    data-options="iconCls:'icon-search'">查询</a>
                                <a id="btnReset" href="javascript:void(0)" class="easyui-linkbutton"
                                    data-options="iconCls:'icon-undo',plain:true">重置</a>
                            </div>

                            <div class="action-bar">
                                <a href="javascript:doPass()" class="easyui-linkbutton btn-pass"
                                    data-options="iconCls:'icon-ok'">审核通过</a>
                                <a href="javascript:openRejectDlg()" class="easyui-linkbutton btn-reject"
                                    data-options="iconCls:'icon-cancel'">驳回</a>
                            </div>
                        </div>

                        <%-- center：主列表 --%>
                            <div data-options="region:'center',border:true">
                                <table id="dg"></table>
                            </div>

                            <%-- east：详情面板 --%>
                                <div data-options="region:'east',split:true" style="width:400px;">
                                    <div class="detail-panel" id="detailPanel">
                                        <div class="no-select">请点击左侧列表查看归还详情</div>
                                    </div>
                                </div>

                </div>

                <%--=====驳回弹窗=====--%>
                    <div id="dlgReject" class="easyui-dialog" style="width:420px;padding:16px 20px;"
                        data-options="title:'填写驳回理由',modal:true,closed:true,buttons:'#dlgRejectBtns'">
                        <p style="margin:0 0 8px;font-size:13px;color:#546e7a;">请说明驳回原因，该信息将反馈给归还人。</p>
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
                        var _selRow = null;

                        /* ===== 归还倒计时计算函数 ===== */
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
                            /* ===== 筛选按钮 ===== */
                            $('#btnSearch').click(function () { doSearch(); });
                            $('#btnReset').click(function () {
                                try { $('#filterStatus').combobox('setValue', ''); } catch (e) { $('#filterStatus').val(''); }
                                try { $('#filterConsumable').textbox('setValue', ''); } catch (e) { }
                                try { $('#filterUser').textbox('setValue', ''); } catch (e) { }
                                try { $('#filterCourse').textbox('setValue', ''); } catch (e) { }
                                try { $('#filterClass').textbox('setValue', ''); } catch (e) { }
                                doSearch();
                            });

                            /* ===== 主列表 ===== */
                            $('#dg').datagrid({
                                url: ctx + '/ServletReturn?action=listAll',
                                fit: true, pagination: true, singleSelect: true, rownumbers: true, striped: true,
                                pageSize: 15, pageList: [15, 30, 50],
                                columns: [[
                                    {
                                        field: 'id', title: '归还ID', width: 140, align: 'center',
                                        formatter: function (v, row) {
                                            var overdue = '';
                                            // 判断是否逾期：归还时间 - 领用时间 > 10天
                                            if (row.borrow_time && row.apply_time) {
                                                var borrowDate = new Date(row.borrow_time);
                                                var applyDate = new Date(row.apply_time);
                                                var diffDays = Math.floor((applyDate - borrowDate) / (1000 * 60 * 60 * 24));
                                                if (diffDays > 10) {
                                                    overdue = '<span class="overdue-badge">已逾期</span>';
                                                }
                                            }
                                            return '<b style="color:#1565c0;">#' + v + '</b>' + overdue;
                                        }
                                    },

                                    {
                                        field: 'is_dangerous', title: '危化品', width: 65, align: 'center',
                                        formatter: function (v) {
                                            return v == 1 ? '<span class="danger-badge">⚠危</span>' : '';
                                        }
                                    },

                                    { field: 'return_user_name', title: '归还人', width: 85 },

                                    { field: 'consumable_name', title: '耗材名称', minWidth: 140 },

                                    { field: 'unit', title: '单位', width: 50, align: 'center' },

                                    {
                                        field: 'return_quantity', title: '归还数量', width: 75, align: 'center',
                                        formatter: function (v) { return '<b style="color:#1976d2;">' + v + '</b>'; }
                                    },

                                    {
                                        field: 'course_name', title: '课程', width: 120,
                                        formatter: function (v) { return v || '—'; }
                                    },

                                    {
                                        field: 'class_name', title: '班级', width: 110,
                                        formatter: function (v) { return v || '—'; }
                                    },

                                    {
                                        field: 'borrow_time', title: '领用时间', width: 135,
                                        formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                                    },

                                    {
                                        field: 'apply_time', title: '归还时间', width: 135,
                                        formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                                    },

                                    {
                                        field: 'status', title: '状态', width: 80, align: 'center',
                                        formatter: function (v) {
                                            if (v == 0) return '<span class="s0">待审核</span>';
                                            if (v == 1) return '<span class="s1">已通过</span>';
                                            if (v == 2) return '<span class="s2">已驳回</span>';
                                            return v;
                                        }
                                    },

                                    {
                                        field: 'check_user_name', title: '审核人', width: 85,
                                        formatter: function (v) { return v || '—'; }
                                    },

                                    {
                                        field: 'check_time', title: '审核时间', width: 135,
                                        formatter: function (v) { return v ? String(v).substring(0, 16).replace('T', ' ') : '—'; }
                                    },

                                    {
                                        field: 'reject_reason', title: '驳回理由', minWidth: 130,
                                        formatter: function (v) {
                                            if (!v) return '—';
                                            var safe = v.replace(/</g, '&lt;').replace(/"/g, '&quot;');
                                            return v.length > 18
                                                ? '<span title="' + safe + '">' + safe.substring(0, 18) + '…</span>'
                                                : safe;
                                        }
                                    }
                                ]],
                                onSelect: function (idx, row) {
                                    _selRow = row;
                                    renderDetail(row);
                                },
                                onLoadSuccess: function () {
                                    _selRow = null;
                                    $('#detailPanel').html('<div class="no-select">请点击左侧列表查看归还详情</div>');
                                    $(this).datagrid('getPager').pagination({
                                        displayMsg: '{from} - {to} 共 {total} 条'
                                    });
                                }
                            });
                        });

                        /* ===== 筛选查询 ===== */
                        function doSearch() {
                            var params = {};
                            try { var s = $('#filterStatus').combobox('getValue'); if (s !== '') params.status = s; } catch (e) { }
                            try { var c = $('#filterConsumable').textbox('getValue'); if (c) params.consumable_name = c; } catch (e) { }
                            try { var u = $('#filterUser').textbox('getValue'); if (u) params.return_user = u; } catch (e) { }
                            try { var cr = $('#filterCourse').textbox('getValue'); if (cr) params.course_name = cr; } catch (e) { }
                            try { var cl = $('#filterClass').textbox('getValue'); if (cl) params.class_name = cl; } catch (e) { }
                            $('#dg').datagrid('load', params);
                        }

                        /* ===== 审核通过 ===== */
                        function doPass() {
                            var row = _getChecked(); if (!row) return;
                            $.messager.confirm('确认审核通过',
                                '确认通过该归还申请？<br>通过后将回补库存 <b>+' + row.return_quantity + '</b> ' + (row.unit || ''),
                                function (r) {
                                    if (!r) return;
                                    $.messager.progress();
                                    $.post(ctx + '/ServletReturn?action=audit', { id: row.id, pass: 1 }, function (ret) {
                                        $.messager.progress('close');
                                        var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                                        if (res.code == '200') {
                                            $.messager.show({ title: '✔ 审核通过', msg: '归还审核通过，库存已回补 +' + row.return_quantity + ' 件', timeout: 2500, showType: 'slide' });
                                            $('#dg').datagrid('reload');
                                        } else {
                                            $.messager.alert('提示', res.msg, 'warning');
                                        }
                                    });
                                }
                            );
                        }

                        /* ===== 打开驳回弹窗 ===== */
                        function openRejectDlg() {
                            var row = _getChecked(); if (!row) return;
                            $('#rejectReasonInput').val('');
                            $('#dlgReject').dialog('open');
                        }

                        /* ===== 确认驳回 ===== */
                        function confirmReject() {
                            var reason = $('#rejectReasonInput').val().trim();
                            if (!reason) {
                                $.messager.alert('提示', '请填写驳回理由', 'warning');
                                return;
                            }
                            var row = _selRow;
                            $.messager.progress();
                            $.post(ctx + '/ServletReturn?action=audit', { id: row.id, pass: 0, reject_reason: reason }, function (ret) {
                                $.messager.progress('close');
                                var res = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                                if (res.code == '200') {
                                    $('#dlgReject').dialog('close');
                                    $.messager.show({ title: '已驳回', msg: res.msg, timeout: 2000, showType: 'slide' });
                                    $('#dg').datagrid('reload');
                                } else {
                                    $.messager.alert('提示', res.msg, 'warning');
                                }
                            });
                        }

                        /* ===== 渲染右侧详情面板 ===== */
                        function renderDetail(row) {
                            var dangerHtml = row.is_dangerous == 1
                                ? '<div class="danger-warn-box">⚠ 该耗材为危险化学品，归还须双人现场核验，审核前请确认已完成核验记录。</div>'
                                : '';

                            // 检查是否逾期
                            var overdueHtml = '';
                            if (row.borrow_time && row.apply_time) {
                                var borrowDate = new Date(row.borrow_time);
                                var applyDate = new Date(row.apply_time);
                                var diffDays = Math.floor((applyDate - borrowDate) / (1000 * 60 * 60 * 24));
                                if (diffDays > 10) {
                                    overdueHtml = '<div class="danger-warn-box">⚠ 该归还申请已逾期 ' + (diffDays - 10) + ' 天（领用日期：' + (row.borrow_time ? String(row.borrow_time).substring(0, 10) : '—') + '）</div>';
                                }
                            }

                            var statusHtml = '';
                            if (row.status == 0) statusHtml = '<span class="s0">待审核</span>';
                            else if (row.status == 1) statusHtml = '<span class="s1">已通过</span>';
                            else if (row.status == 2) statusHtml = '<span class="s2">已驳回</span>';

                            var auditSection = '';
                            if (row.status == 1 || row.status == 2) {
                                auditSection =
                                    '<div class="info-row"><span class="lbl">审核人：</span><span class="val">' + (row.check_user_name || '—') + '</span></div>' +
                                    '<div class="info-row"><span class="lbl">审核时间：</span><span class="val">' + (row.check_time ? String(row.check_time).substring(0, 16).replace('T', ' ') : '—') + '</span></div>';
                            }

                            var rejectSection = '';
                            if (row.status == 2) {
                                rejectSection =
                                    '<div style="font-size:12px;font-weight:bold;color:#546e7a;margin:10px 0 6px;">驳回理由：</div>' +
                                    '<div class="reject-box">' + (row.reject_reason || '—').replace(/</g, '&lt;') + '</div>';
                            }

                            var stockTip = row.status == 0
                                ? '<div style="margin-top:12px;padding:10px;background:#e8f5e9;border-radius:6px;font-size:12px;color:#2e7d32;">✔ 审核通过后，将自动回补库存 <b>+' + row.return_quantity + '</b> ' + (row.unit || '') + '</div>'
                                : '';

                            $('#detailPanel').html(
                                '<div class="detail-title">归还申请 <b style="color:#1565c0;">#' + row.id + '</b> 详情</div>' +
                                dangerHtml +
                                overdueHtml +
                                '<div class="info-card">' +
                                '<div class="info-row"><span class="lbl">归还人：</span><span class="val">' + (row.return_user_name || '—') + '</span></div>' +
                                '<div class="info-row"><span class="lbl">耗材：</span><span class="val"><b>' + (row.consumable_name || '—') + '</b>（' + (row.unit || '') + '）</span></div>' +
                                '<div class="info-row"><span class="lbl">归还数量：</span><span class="val"><b style="color:#1976d2;font-size:15px;">' + row.return_quantity + '</b> ' + (row.unit || '') + '</span></div>' +
                                '<div class="info-row"><span class="lbl">课程：</span><span class="val">' + (row.course_name || '—') + '</span></div>' +
                                '<div class="info-row"><span class="lbl">班级：</span><span class="val">' + (row.class_name || '—') + '</span></div>' +
                                '<div class="info-row"><span class="lbl">领用时间：</span><span class="val">' + (row.borrow_time ? String(row.borrow_time).substring(0, 16).replace('T', ' ') : '—') + '</span></div>' +
                                '<div class="info-row"><span class="lbl">归还时间：</span><span class="val">' + (row.apply_time ? String(row.apply_time).substring(0, 16).replace('T', ' ') : '—') + '</span></div>' +
                                '<div class="info-row"><span class="lbl">状态：</span><span class="val">' + statusHtml + '</span></div>' +
                                auditSection +
                                '</div>' +
                                rejectSection +
                                stockTip
                            );
                        }

                        /* ===== 内部：校验选中行且 status=0 ===== */
                        function _getChecked() {
                            if (!_selRow) {
                                $.messager.alert('提示', '请先选择一条归还记录', 'warning');
                                return null;
                            }
                            if (_selRow.status != 0) {
                                $.messager.alert('提示', '只能审核「待审核」状态的记录', 'warning');
                                return null;
                            }
                            return _selRow;
                        }
                    </script>
    </body>

    </html>