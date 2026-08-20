<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>使用反馈</title>
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

            .submit-card {
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 1px 6px rgba(21, 101, 192, .10);
                margin: 10px 14px 8px;
                padding: 14px 18px 12px;
            }

            .card-title {
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
                margin-bottom: 10px;
                padding-bottom: 6px;
                border-bottom: 2px solid #e3eaf5;
                display: flex;
                align-items: center;
                gap: 6px;
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

            .char-count {
                font-size: 12px;
                color: #90a4ae;
                margin-top: 3px;
            }

            .char-count.warn {
                color: #e53935;
            }

            .tip-bar {
                background: #fff8e1;
                border-left: 3px solid #f57c00;
                border-radius: 4px;
                padding: 6px 12px;
                font-size: 12px;
                color: #e65100;
                margin-top: 10px;
            }

            .list-card {
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 1px 6px rgba(21, 101, 192, .10);
                margin: 0 14px;
                overflow: hidden;
            }

            .list-card-title {
                background: #f0f4fa;
                border-bottom: 2px solid #1976d2;
                padding: 7px 14px;
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
            }

            .filter-bar {
                background: #f8fafc;
                border-bottom: 1px solid #dce6f5;
                padding: 5px 10px;
                display: flex;
                align-items: center;
                gap: 8px;
                flex-wrap: wrap;
            }

            .btn-primary {
                background: linear-gradient(90deg, #1565c0, #1976d2) !important;
                color: #fff !important;
                border: none !important;
                border-radius: 5px !important;
                font-weight: bold;
            }

            /* 状态徽章 */
            .fs0 {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #90a4ae;
                color: #fff;
            }

            .fs1 {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #FF9800;
                color: #fff;
            }

            .fs2 {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #43a047;
                color: #fff;
            }

            .os0 {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #FF9800;
                color: #fff;
            }

            .os1 {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #2196F3;
                color: #fff;
            }

            .os2 {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            .os3 {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #43a047;
                color: #fff;
            }

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
        </style>
        <script>
            var ctx = '${pageContext.request.contextPath}';
            var CATEGORIES = ['实验问题（耗材质量/数量）', '使用体验（耗材适配性）', '改进建议（采购/管理）', '其他'];

            function fmtFeedbackStatus(v) {
                if (v == 0) return '<span class="fs0">未查看</span>';
                if (v == 1) return '<span class="fs1">已查看</span>';
                if (v == 2) return '<span class="fs2">已处理</span>';
                return v;
            }
            function fmtOrderStatus(v) {
                if (v == 0) return '<span class="os0">待审核</span>';
                if (v == 1) return '<span class="os1">待出库</span>';
                if (v == 2) return '<span class="os2">已驳回</span>';
                if (v == 3) return '<span class="os3">已出库</span>';
                return v;
            }

            $(function () {
                /* ===== 领用单下拉（已出库优先） ===== */
                $('#outbound_order_id').combobox({
                    url: ctx + '/ServletUsageFeedback?action=myOrderOptions',
                    valueField: 'id', textField: 'displayText',
                    editable: false, panelHeight: 280,
                    prompt: '请选择领用单',
                    loadFilter: function (rows) {
                        if (!rows) return [];
                        // 前端兜底过滤：只保留已出库状态（兼容多种可能的状态值）
                        var filteredRows = $.grep(rows, function (r) {
                            var status = r.status;
                            return status == 3 || status === '3' || status === '已出库' ||
                                (r.text && r.text.indexOf('已出库') > -1);
                        });

                        // 如果过滤后没有数据，返回所有（临时容错方案）
                        if (filteredRows.length === 0) {
                            filteredRows = rows;
                        }

                        // 修改 text 字段为简洁的显示格式（单号 + 时间）
                        return $.map(filteredRows, function (r) {
                            var displayText = '单号' + (r.id || '');
                            return $.extend({}, r, {
                                id: r.id != null ? String(r.id) : '',
                                displayText: displayText,
                                originalText: r.text
                            });
                        });
                    },
                    formatter: function (row) {
                        return '<div style="padding:4px 6px;display:flex;justify-content:space-between;align-items:center;">' +
                            '<span style="font-weight:bold;color:#1565c0;">单号' + (row.id || '') + '</span>' +
                            '<span style="color:#90a4ae;font-size:11px;">' + (row.create_time || '') + '</span>' +
                            '</div>';
                    }
                });

                /* ===== 反馈分类下拉 ===== */
                var catData = $.map(CATEGORIES, function (c) { return { id: c, text: c }; });
                $('#category').combobox({
                    data: catData, valueField: 'id', textField: 'text',
                    editable: false, panelHeight: 'auto', prompt: '请选择反馈分类'
                });

                /* ===== 字数统计（用原生 input 事件，避免 EasyUI onChange 不实时触发） ===== */
                $('#content').textbox({
                    multiline: true,
                    prompt: '请描述使用体验、质量问题、改进建议等（500字以内，支持换行）'
                });
                // 绑定到底层 textarea 的 input 事件，实时计数
                $(document).on('input', '#content + span textarea, textarea[textboxname="content"]', function () {
                    var len = $(this).val().length;
                    $('#charCount').text(len + ' / 500');
                    if (len > 500) $('#charCount').addClass('warn');
                    else $('#charCount').removeClass('warn');
                });
                // 兜底：也监听 EasyUI textbox 包裹层内的 textarea
                setTimeout(function () {
                    var $ta = $('#content').next('span').find('textarea');
                    if ($ta.length) {
                        $ta.on('input', function () {
                            var len = $(this).val().length;
                            $('#charCount').text(len + ' / 500');
                            if (len > 500) $('#charCount').addClass('warn');
                            else $('#charCount').removeClass('warn');
                        });
                    }
                }, 300);

                /* ===== 历史反馈列表 ===== */
                $('#dg').datagrid({
                    url: ctx + '/ServletUsageFeedback?action=listMine',
                    fit: true, pagination: true, rownumbers: true, singleSelect: true,
                    pageSize: 10, pageList: [10, 20, 50],
                    columns: [[
                        { field: 'id', title: 'ID', width: 55, align: 'center' },
                        {
                            field: 'outbound_order_id', title: '领用单号', width: 80, align: 'center',
                            formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                        },
                        { field: 'category', title: '反馈分类', width: 160, formatter: function (v) { return v || '—'; } },
                        {
                            field: 'feedback_status', title: '处理状态', width: 90, align: 'center',
                            formatter: function (v) { return fmtFeedbackStatus(v); }
                        },
                        {
                            field: 'order_status', title: '单据状态', width: 90, align: 'center',
                            formatter: function (v) { return fmtOrderStatus(v); }
                        },
                        { field: 'course_name', title: '课程', width: 120, formatter: function (v) { return v || '—'; } },
                        {
                            field: 'content', title: '反馈内容', width: 240,
                            formatter: function (v) {
                                if (!v) return '—';
                                var s = v.length > 50 ? v.substring(0, 50) + '...' : v;
                                return '<span title="' + v.replace(/"/g, '&quot;').replace(/\n/g, ' ') + '">' + s + '</span>';
                            }
                        },
                        {
                            field: 'admin_reply', title: '管理员回复', width: 180,
                            formatter: function (v) {
                                if (!v) return '<span style="color:#b0bec5;">暂无回复</span>';
                                var s = v.length > 40 ? v.substring(0, 40) + '...' : v;
                                return '<span style="color:#43a047;" title="' + v.replace(/"/g, '&quot;') + '">' + s + '</span>';
                            }
                        },
                        {
                            field: 'create_time', title: '提交时间', width: 140,
                            formatter: function (v) {
                                if (!v) return '—';
                                return String(v).replace('T', ' ');
                            }
                        },
                        {
                            field: 'update_time', title: '最后更新', width: 140,
                            formatter: function (v) {
                                if (!v) return '—';
                                return String(v).replace('T', ' ');
                            }
                        },
                        {
                            field: '_op', title: '操作', width: 60, align: 'center',
                            formatter: function (v, r) {
                                return '<a href="javascript:void(0)" onclick="openEdit(' + r.id + ')" style="color:#1976d2;font-size:12px;">编辑</a>';
                            }
                        }
                    ]],
                    onDblClickRow: function (idx, row) { openEdit(row.id); },
                    onLoadSuccess: function (data) {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* ===== 筛选 ===== */
                var filterCatData = [{ id: '', text: '全部分类' }].concat($.map(CATEGORIES, function (c) { return { id: c, text: c }; }));
                $('#filterCategory').combobox({ data: filterCatData, valueField: 'id', textField: 'text', editable: false, panelHeight: 'auto', value: '' });
                $('#filterStatus').combobox({
                    data: [{ id: '', text: '全部状态' }, { id: '0', text: '未查看' }, { id: '1', text: '已查看' }, { id: '2', text: '已处理' }],
                    valueField: 'id', textField: 'text', editable: false, panelHeight: 'auto', value: '',
                    onChange: function () { doSearch(); }
                });
                $('#filterKeyword').textbox({ prompt: '领用单号', onKeyDown: function (e) { if (e.keyCode == 13) doSearch(); } });
                $('#btnSearch').click(function () { doSearch(); });
                $('#btnReset').click(function () {
                    $('#filterCategory').combobox('setValue', '');
                    $('#filterStatus').combobox('setValue', '');
                    $('#filterKeyword').textbox('setValue', '');
                    $('#filterDateFrom').datebox('setValue', '');
                    $('#filterDateTo').datebox('setValue', '');
                    doSearch();
                });

                /* ===== 提交反馈 ===== */
                $(document).on('click', '#btnSave', function () {
                    var oid = $('#outbound_order_id').combobox('getValue');
                    var cat = $('#category').combobox('getValue');
                    // 从底层 textarea 取值，确保拿到实际输入内容
                    var $ta = $('#content').next('span').find('textarea');
                    var content = $ta.length ? $ta.val() : $('#content').textbox('getValue');
                    if (!oid) { $.messager.alert('提示', '请选择领用单', 'warning'); return; }
                    if (!cat) { $.messager.alert('提示', '请选择反馈分类', 'warning'); return; }
                    if (!content || !content.trim()) { $.messager.alert('提示', '请填写反馈内容', 'warning'); return; }
                    if (content.length > 500) { $.messager.alert('提示', '反馈内容不能超过500字', 'warning'); return; }

                    $.messager.progress({ title: '处理中', msg: '正在提交...' });
                    $.post(ctx + '/ServletUsageFeedback?action=save', {
                        outbound_order_id: oid, category: cat, content: content
                    }, function (ret) {
                        $.messager.progress('close');
                        var r = typeof ret === 'string' ? JSON.parse(ret) : ret;
                        if (r.code == '200') {
                            $.messager.show({ title: '提交成功', msg: r.msg, timeout: 2500, showType: 'slide' });
                            $('#dg').datagrid('reload');
                            $('#content').textbox('setValue', '');
                            $('#charCount').text('0 / 500');
                        } else { $.messager.alert('提交失败', r.msg, 'warning'); }
                    });
                });

                /* ===== 清空（保留领用单选择） ===== */
                $(document).on('click', '#btnClear', function () {
                    $('#category').combobox('clear');
                    $('#content').textbox('setValue', '');
                    $('#charCount').text('0 / 500');
                });
            });

            /* ===== 筛选查询 ===== */
            function doSearch() {
                var kw = ''; try { kw = $('#filterKeyword').textbox('getValue'); } catch (e) { }
                $('#dg').datagrid('load', {
                    category: $('#filterCategory').combobox('getValue'),
                    feedback_status: $('#filterStatus').combobox('getValue'),
                    keyword: kw,
                    date_from: $('#filterDateFrom').datebox('getValue'),
                    date_to: $('#filterDateTo').datebox('getValue')
                });
            }

            /* ===== 编辑历史反馈 ===== */
            var _editId = null;
            function openEdit(fid) {
                // 从列表找到该行
                var rows = $('#dg').datagrid('getRows');
                var row = null;
                for (var i = 0; i < rows.length; i++) { if (String(rows[i].id) === String(fid)) { row = rows[i]; break; } }
                if (!row) return;
                _editId = fid;
                // 填充编辑弹窗
                $('#editCategory').combobox('setValue', row.category || '其他');
                $('#editContent').textbox('setValue', row.content || '');
                $('#editCharCount').text((row.content ? row.content.length : 0) + ' / 500');
                $('#editOrderInfo').html(
                    '领用单号：<b style="color:#1565c0;">' + row.outbound_order_id + '</b>'
                    + '&nbsp;&nbsp;课程：' + (row.course_name || '—')
                    + '&nbsp;&nbsp;提交时间：' + (row.create_time || '—')
                );
                $('#dlgEdit').dialog('open');
            }

            $(document).on('click', '#btnEditSave', function () {
                if (!_editId) return;
                var cat = $('#editCategory').combobox('getValue');
                var content = $('#editContent').textbox('getValue');
                if (!cat) { $.messager.alert('提示', '请选择反馈分类', 'warning'); return; }
                if (!content || !content.trim()) { $.messager.alert('提示', '请填写反馈内容', 'warning'); return; }
                if (content.length > 500) { $.messager.alert('提示', '反馈内容不能超过500字', 'warning'); return; }

                $.messager.confirm('确认修改', '修改后将覆盖原反馈内容，是否确认？', function (r) {
                    if (!r) return;
                    $.messager.progress({ title: '处理中', msg: '正在保存...' });
                    $.post(ctx + '/ServletUsageFeedback?action=update', {
                        id: _editId, category: cat, content: content
                    }, function (ret) {
                        $.messager.progress('close');
                        var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
                        if (res.code == '200') {
                            $.messager.show({ title: '修改成功', msg: res.msg, timeout: 2500, showType: 'slide' });
                            $('#dlgEdit').dialog('close');
                            $('#dg').datagrid('reload');
                            _editId = null;
                        } else { $.messager.alert('失败', res.msg, 'warning'); }
                    });
                });
            });
        </script>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <!-- 顶部标题 -->
        <div class="page-header">
            <span style="font-size:20px;">💬</span>
            使用反馈
            <span class="sub">对已领用的耗材提交使用体验或质量反馈，支持分类管理</span>
        </div>

        <!-- 提交卡片 -->
        <div class="submit-card">
            <div class="card-title">✏️ 提交反馈</div>
            <div class="form-row">
                <div class="form-item" style="min-width:240px;flex:1;">
                    <label>选择领用单 <span class="req">*</span></label>
                    <input id="outbound_order_id" style="width:100%;">
                </div>
                <div class="form-item" style="min-width:200px;">
                    <label>反馈分类 <span class="req">*</span></label>
                    <input id="category" style="width:220px;">
                </div>
                <div class="form-item" style="flex:2;min-width:280px;">
                    <label>反馈内容 <span class="req">*</span></label>
                    <input id="content" class="easyui-textbox" style="width:100%;height:72px;">
                    <div id="charCount" class="char-count">0 / 500</div>
                </div>
                <div class="form-item" style="justify-content:flex-end;padding-bottom:22px;gap:6px;">
                    <a id="btnSave" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                        data-options="iconCls:'icon-save'" style="height:36px;padding:0 18px;">提交反馈</a>
                    <a id="btnClear" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-undo',plain:true" style="margin-top:6px;">清空内容</a>
                </div>
            </div>
            <div class="tip-bar">⚠ 同一领用单只保留一条反馈，再次提交将覆盖原内容。双击历史记录可编辑。</div>
        </div>

        <!-- 历史反馈列表 -->
        <div class="list-card" style="height:calc(100vh - 258px);">
            <div class="list-card-title">📋 我的反馈历史</div>
            <!-- 筛选栏 -->
            <div class="filter-bar">
                <span style="font-size:12px;color:#546e7a;font-weight:600;">筛选：</span>
                <input id="filterCategory" style="width:160px;">
                <input id="filterStatus" style="width:100px;">
                <input id="filterKeyword" class="easyui-textbox" style="width:100px;">
                <input id="filterDateFrom" class="easyui-datebox" style="width:115px;" data-options="prompt:'开始日期'">
                <span style="color:#ccc;">~</span>
                <input id="filterDateTo" class="easyui-datebox" style="width:115px;" data-options="prompt:'结束日期'">
                <a id="btnSearch" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                    data-options="iconCls:'icon-search'">查询</a>
                <a id="btnReset" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-undo',plain:true">重置</a>
                <span style="color:#90a4ae;font-size:12px;">💡 双击行可编辑反馈</span>
            </div>
            <div style="height:calc(100% - 72px);">
                <table id="dg" style="height:100%;"></table>
            </div>
        </div>

        <!-- ===== 编辑反馈弹窗 ===== -->
        <div id="dlgEdit" class="easyui-dialog" title="编辑反馈" style="width:520px;padding:16px 20px;"
            data-options="closed:true,modal:true,buttons:'#dlgEditBtns'">
            <div id="editOrderInfo"
                style="background:#e3f2fd;border-left:3px solid #1976d2;border-radius:4px;padding:7px 12px;font-size:12px;color:#1565c0;margin-bottom:14px;">
            </div>
            <div class="dlg-row">
                <label>反馈分类 <span class="req">*</span></label>
                <input id="editCategory" style="width:100%;">
            </div>
            <div class="dlg-row">
                <label>反馈内容 <span class="req">*</span></label>
                <input id="editContent" class="easyui-textbox" style="width:100%;height:120px;"
                    data-options="multiline:true,onChange:function(v){var l=v?v.length:0;$('#editCharCount').text(l+' / 500');if(l>500)$('#editCharCount').addClass('warn');else $('#editCharCount').removeClass('warn');}">
                <div id="editCharCount" class="char-count">0 / 500</div>
            </div>
        </div>
        <div id="dlgEditBtns">
            <a id="btnEditSave" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                data-options="iconCls:'icon-ok'">确认修改</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back'"
                onclick="$('#dlgEdit').dialog('close')">取消</a>
        </div>

        <!-- editCategory 初始化（需在 DOM ready 后） -->
        <script>
            $(function () {
                var catData2 = $.map(['实验问题（耗材质量/数量）', '使用体验（耗材适配性）', '改进建议（采购/管理）', '其他'],
                    function (c) { return { id: c, text: c }; });
                $('#editCategory').combobox({ data: catData2, valueField: 'id', textField: 'text', editable: false, panelHeight: 'auto' });
            });
        </script>

    </body>

    </html>