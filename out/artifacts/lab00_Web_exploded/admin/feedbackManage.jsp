<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>反馈管理</title>
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

            .filter-bar {
                background: #f8fafc;
                border-bottom: 1px solid #dce6f5;
                padding: 6px 10px;
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

            .detail-section {
                margin-bottom: 14px;
            }

            .detail-section .sec-title {
                font-size: 12px;
                font-weight: bold;
                color: #1565c0;
                margin-bottom: 6px;
                padding-bottom: 4px;
                border-bottom: 1px solid #e3eaf5;
            }

            .detail-row {
                display: flex;
                gap: 6px;
                margin-bottom: 6px;
                font-size: 13px;
            }

            .detail-row .lbl {
                color: #78909c;
                min-width: 70px;
                flex-shrink: 0;
            }

            .detail-row .val {
                color: #263238;
                flex: 1;
                word-break: break-all;
            }

            .reply-box {
                background: #f0f4fa;
                border-radius: 6px;
                padding: 10px 12px;
                margin-bottom: 8px;
                font-size: 12px;
            }

            .reply-box .reply-meta {
                color: #90a4ae;
                margin-bottom: 4px;
            }

            .reply-box .reply-content {
                color: #37474f;
                white-space: pre-wrap;
            }

            .char-count {
                font-size: 12px;
                color: #90a4ae;
                margin-top: 3px;
            }

            .char-count.warn {
                color: #e53935;
            }
        </style>
        <script>
            var ctx = '${pageContext.request.contextPath}';
            var CATEGORIES = ['实验问题（耗材质量/数量）', '使用体验（耗材适配性）', '改进建议（采购/管理）', '其他'];
            var _currentRow = null;

            function fmtStatus(v) {
                if (v == 0) return '<span class="fs0">未查看</span>';
                if (v == 1) return '<span class="fs1">已查看</span>';
                if (v == 2) return '<span class="fs2">已处理</span>';
                return v;
            }

            $(function () {
                /* ===== 筛选组件 ===== */
                var catData = [{ id: '', text: '全部分类' }].concat($.map(CATEGORIES, function (c) { return { id: c, text: c }; }));
                $('#filterCategory').combobox({ data: catData, valueField: 'id', textField: 'text', editable: false, panelHeight: 'auto', value: '', onChange: function () { doSearch(); } });
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

                /* ===== 反馈列表 ===== */
                $('#dg').datagrid({
                    url: ctx + '/ServletUsageFeedback?action=listAll',
                    fit: true, pagination: true, rownumbers: true, singleSelect: true,
                    pageSize: 15, pageList: [10, 15, 20, 50],
                    columns: [[
                        { field: 'id', title: '反馈ID', width: 70, align: 'center' },
                        {
                            field: 'outbound_order_id', title: '领用单号', width: 80, align: 'center',
                            formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                        },
                        { field: 'consumable_names', title: '耗材名称', width: 160, formatter: function (v) { return v || '—'; } },
                        { field: 'teacher_name', title: '教师', width: 80 },
                        { field: 'category', title: '反馈分类', width: 150, formatter: function (v) { return v || '—'; } },
                        {
                            field: 'feedback_status', title: '回复状态', width: 90, align: 'center',
                            formatter: function (v) { return fmtStatus(v); }
                        },
                        {
                            field: 'content', title: '反馈内容', width: 200,
                            formatter: function (v) {
                                if (!v) return '—';
                                var s = v.length > 10 ? v.substring(0, 10) + '…' : v;
                                return '<span title="' + v.replace(/"/g, '&quot;').replace(/\n/g, ' ') + '">' + s + '</span>';
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
                            field: '_op', title: '操作', width: 100, align: 'center',
                            formatter: function (v, r) {
                                return '<a href="javascript:void(0)" onclick="openDetail(' + r.id + ')" style="color:#1976d2;font-size:12px;">详情/回复</a>';
                            }
                        }
                    ]],
                    onDblClickRow: function (idx, row) { openDetail(row.id); },
                    onLoadSuccess: function (data) {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* ===== 回复字数统计 ===== */
                setTimeout(function () {
                    var $ta = $('#replyContent').next('span').find('textarea');
                    if ($ta.length) {
                        $ta.on('input', function () {
                            var len = $(this).val().length;
                            $('#replyCharCount').text(len + ' / 500');
                            if (len > 500) $('#replyCharCount').addClass('warn');
                            else $('#replyCharCount').removeClass('warn');
                        });
                    }
                }, 300);

                /* ===== 回复提交 ===== */
                $(document).on('click', '#btnReply', function () {
                    if (!_currentRow) return;
                    var $ta = $('#replyContent').next('span').find('textarea');
                    var content = $ta.length ? $ta.val() : $('#replyContent').textbox('getValue');
                    if (!content || !content.trim()) { $.messager.alert('提示', '请填写回复内容', 'warning'); return; }
                    if (content.length > 500) { $.messager.alert('提示', '回复内容不超过500字', 'warning'); return; }
                    $.messager.progress({ title: '处理中', msg: '正在提交...' });
                    $.post(ctx + '/ServletUsageFeedback?action=reply', {
                        id: _currentRow.id, reply: content, status: '2'
                    }, function (ret) {
                        $.messager.progress('close');
                        var r = typeof ret === 'string' ? JSON.parse(ret) : ret;
                        if (r.code == '200') {
                            $.messager.show({ title: '成功', msg: '回复已提交，反馈已标记为已处理', timeout: 2500, showType: 'slide' });
                            $('#dlgDetail').dialog('close');
                            $('#dg').datagrid('reload');
                        } else { $.messager.alert('失败', r.msg, 'warning'); }
                    });
                });

                /* ===== 标记已查看 ===== */
                $(document).on('click', '#btnMarkRead', function () {
                    if (!_currentRow) return;
                    $.post(ctx + '/ServletUsageFeedback?action=reply', { id: _currentRow.id, status: '1' }, function (ret) {
                        var r = typeof ret === 'string' ? JSON.parse(ret) : ret;
                        if (r.code == '200') {
                            // 1. 弹出轻提示
                            $.messager.show({ title: '成功', msg: '已标记为查看状态', timeout: 2000, showType: 'slide' });
                            // 2. 关闭弹窗
                            $('#dlgDetail').dialog('close');
                            // 3. 刷新列表
                            $('#dg').datagrid('reload');
                        } else {
                            $.messager.alert('失败', r.msg, 'warning');
                        }
                    });
                });
            });

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

            function openDetail(fid) {
                var rows = $('#dg').datagrid('getRows');
                var row = null;
                for (var i = 0; i < rows.length; i++) { if (String(rows[i].id) === String(fid)) { row = rows[i]; break; } }
                if (!row) return;
                _currentRow = row;

                // 填充详情
                $('#detailFeedbackId').text(row.id);
                $('#detailOrderId').text(row.outbound_order_id);
                $('#detailTeacher').text(row.teacher_name || '—');
                $('#detailLab').text(row.lab_name || '—');
                $('#detailCourse').text(row.course_name || '—');
                $('#detailConsumable').text(row.consumable_names || '—');
                $('#detailCategory').text(row.category || '—');
                $('#detailStatus').html(fmtStatus(row.feedback_status));
                $('#detailContent').text(row.content || '—');
                $('#detailTime').text(row.create_time || '—');

                // 历史回复
                if (row.admin_reply) {
                    $('#replyHistory').html(
                        '<div class="reply-box">'
                        + '<div class="reply-meta">管理员回复 · ' + (row.update_time || '') + '</div>'
                        + '<div class="reply-content">' + row.admin_reply.replace(/</g, '&lt;') + '</div>'
                        + '</div>'
                    );
                } else {
                    $('#replyHistory').html('<div style="color:#b0bec5;font-size:12px;padding:8px 0;">暂无回复记录</div>');
                }

                // 清空回复框
                var $ta = $('#replyContent').next('span').find('textarea');
                if ($ta.length) $ta.val('');
                else $('#replyContent').textbox('setValue', '');
                $('#replyCharCount').text('0 / 500');

                // 已处理则隐藏回复区
                if (row.feedback_status == 2) {
                    $('#replyArea').hide();
                } else {
                    $('#replyArea').show();
                }

                // 自动标记为已查看
                if (row.feedback_status == 0) {
                    $.post(ctx + '/ServletUsageFeedback?action=reply', { id: row.id, status: '1' }, function () {
                        $('#dg').datagrid('reload');
                    });
                }

                $('#dlgDetail').dialog('open');
            }

            function markDone(fid) {
                $.messager.confirm('确认关闭', '将该反馈标记为「已处理」？', function (r) {
                    if (!r) return;
                    $.post(ctx + '/ServletUsageFeedback?action=reply', { id: fid, status: '2' }, function (ret) {
                        var res = typeof ret === 'string' ? JSON.parse(ret) : ret;
                        if (res.code == '200') { $.messager.show({ title: '成功', msg: res.msg, timeout: 2000, showType: 'slide' }); $('#dg').datagrid('reload'); }
                        else { $.messager.alert('失败', res.msg, 'warning'); }
                    });
                });
            }
        </script>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">📬</span>
            反馈管理
            <span class="sub">查看并处理教师提交的耗材使用反馈</span>
        </div>

        <div class="easyui-layout" data-options="fit:true" style="height:calc(100vh - 44px);">
            <div data-options="region:'north',border:false" style="height:auto;">
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
                    <span style="color:#90a4ae;font-size:12px;">💡 双击行查看详情</span>
                </div>
            </div>
            <div data-options="region:'center',border:false">
                <table id="dg"></table>
            </div>
        </div>

        <!-- ===== 详情/回复弹窗 ===== -->
        <div id="dlgDetail" class="easyui-dialog" title="反馈详情与回复"
            style="width:620px;height:580px;padding:14px 18px;overflow-y:auto;" data-options="closed:true,modal:true">

            <!-- 基本信息 -->
            <div class="detail-section">
                <div class="sec-title">📋 反馈基本信息</div>
                <div style="display:flex;flex-wrap:wrap;gap:0;">
                    <div class="detail-row" style="width:50%;"><span class="lbl">反馈ID：</span><span class="val"
                            id="detailFeedbackId"></span></div>
                    <div class="detail-row" style="width:50%;"><span class="lbl">领用单号：</span><span class="val"
                            id="detailOrderId" style="color:#1565c0;font-weight:bold;"></span></div>
                    <div class="detail-row" style="width:50%;"><span class="lbl">教师：</span><span class="val"
                            id="detailTeacher"></span></div>
                    <div class="detail-row" style="width:50%;"><span class="lbl">实验室：</span><span class="val"
                            id="detailLab"></span></div>
                    <div class="detail-row" style="width:50%;"><span class="lbl">课程：</span><span class="val"
                            id="detailCourse"></span></div>
                    <div class="detail-row" style="width:50%;"><span class="lbl">耗材：</span><span class="val"
                            id="detailConsumable"></span></div>
                    <div class="detail-row" style="width:50%;"><span class="lbl">反馈分类：</span><span class="val"
                            id="detailCategory"></span></div>
                    <div class="detail-row" style="width:50%;"><span class="lbl">处理状态：</span><span class="val"
                            id="detailStatus"></span></div>
                    <div class="detail-row" style="width:50%;"><span class="lbl">提交时间：</span><span class="val"
                            id="detailTime"></span></div>
                </div>
            </div>

            <!-- 反馈内容 -->
            <div class="detail-section">
                <div class="sec-title">💬 反馈内容</div>
                <div id="detailContent"
                    style="background:#f8fafc;border-radius:6px;padding:10px 12px;font-size:13px;color:#37474f;white-space:pre-wrap;min-height:60px;">
                </div>
            </div>

            <!-- 历史回复 -->
            <div class="detail-section">
                <div class="sec-title">📝 历史回复</div>
                <div id="replyHistory"></div>
            </div>

            <!-- 回复区 -->
            <div id="replyArea" class="detail-section">
                <div class="sec-title">✉️ 回复反馈</div>
                <input id="replyContent" class="easyui-textbox" style="width:100%;height:100px;"
                    data-options="multiline:true,prompt:'请填写回复内容（≤500字）'">
                <div id="replyCharCount" class="char-count">0 / 500</div>
                <div style="margin-top:10px;display:flex;gap:8px;">
                    <a id="btnReply" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                        data-options="iconCls:'icon-ok'">提交回复（标记已处理）</a>
                    <a id="btnMarkRead" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-tip',plain:true">仅标记已查看</a>
                    <a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-back',plain:true"
                        onclick="$('#dlgDetail').dialog('close')">关闭</a>
                </div>
            </div>
        </div>

    </body>

    </html>