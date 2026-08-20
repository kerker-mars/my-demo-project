<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>个人领用记录</title>
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

            .tb-wrap {
                background: #f0f4fa;
                border-bottom: 1px solid #dce6f5;
                padding: 6px 10px;
                display: flex;
                align-items: center;
                gap: 6px;
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

            .badge-danger {
                display: inline-block;
                padding: 1px 6px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #e53935;
                color: #fff;
            }

            .badge-yes {
                display: inline-block;
                padding: 1px 6px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #1976d2;
                color: #fff;
            }

            .badge-no {
                display: inline-block;
                padding: 1px 6px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: bold;
                background: #90a4ae;
                color: #fff;
            }

            .btn-primary {
                background: linear-gradient(90deg, #1565c0, #1976d2) !important;
                color: #fff !important;
                border: none !important;
                border-radius: 5px !important;
                font-weight: bold;
            }

            /* 明细弹窗内的统计条 */
            .detail-stat {
                display: flex;
                gap: 20px;
                background: #e3f2fd;
                border-radius: 6px;
                padding: 8px 14px;
                margin-bottom: 10px;
                font-size: 13px;
            }

            .detail-stat .stat-item {
                display: flex;
                flex-direction: column;
                align-items: center;
            }

            .detail-stat .stat-val {
                font-size: 20px;
                font-weight: bold;
                color: #1565c0;
                line-height: 1.2;
            }

            .detail-stat .stat-lbl {
                font-size: 11px;
                color: #78909c;
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

            function fmtStatus(v) {
                if (v == 0) return '<span class="s0">待审核</span>';
                if (v == 1) return '<span class="s1">审核通过/待出库</span>';
                if (v == 2) return '<span class="s2">已驳回</span>';
                if (v == 3) return '<span class="s3">已出库</span>';
                return v;
            }

            $(function () {
                /* ===== 主列表 ===== */
                $('#dg').datagrid({
                    url: ctx + '/ServletOutbound?action=listMine',
                    fit: true,
                    pagination: true,
                    rownumbers: true,
                    singleSelect: true,
                    pageSize: 15,
                    pageList: [10, 15, 20, 50],
                    toolbar: '#tb',
                    columns: [[
                        {
                            field: 'id', title: '领用单号', width: 90, align: 'center',
                            formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                        },
                        { field: 'lab_name', title: '实验室', width: 160 },
                        { field: 'course_name', title: '课程名称', width: 140, formatter: function (v) { return v || '—'; } },
                        { field: 'class_name', title: '班级', width: 120, formatter: function (v) { return v || '—'; } },
                        { field: 'purpose', title: '用途说明', width: 220, formatter: function (v) { return v || '—'; } },
                        { field: 'status', title: '状态', width: 160, align: 'center', formatter: fmtStatus },
                        { field: 'create_time', title: '申请时间', width: 160 },
                        { field: 'audit_time', title: '审核时间', width: 160, formatter: function (v) { return v || '—'; } }
                    ]],
                    onDblClickRow: function (idx, row) { openDetail(row); },
                    onLoadSuccess: function (data) {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* ===== 查看明细 ===== */
                $('#btnDetail').click(function () {
                    var row = $('#dg').datagrid('getSelected');
                    if (!row) { $.messager.alert('提示', '请选择一条领用记录', 'warning'); return; }
                    openDetail(row);
                });

                function openDetail(row) {
                    // 统计条
                    var statusText = '';
                    if (row.status == 0) statusText = '待审核';
                    else if (row.status == 1) statusText = '审核通过';
                    else if (row.status == 2) statusText = '已驳回';
                    else if (row.status == 3) statusText = '已出库';

                    $('#dlgStatBar').html(
                        '<div class="stat-item"><div class="stat-val">' + row.id + '</div><div class="stat-lbl">领用单号</div></div>' +
                        '<div class="stat-item"><div class="stat-val" style="font-size:14px;">' + fmtStatus(row.status) + '</div><div class="stat-lbl">当前状态</div></div>' +
                        '<div class="stat-item"><div class="stat-val" style="font-size:14px;color:#37474f;">' + (row.lab_name || '—') + '</div><div class="stat-lbl">实验室</div></div>' +
                        '<div class="stat-item"><div class="stat-val" style="font-size:14px;color:#37474f;">' + (row.course_name || '—') + '</div><div class="stat-lbl">课程</div></div>'
                    );

                    var u = ctx + '/ServletOutbound?action=getMyItems&outbound_id=' + row.id;
                    if ($('#dgItems').data('datagrid')) {
                        $('#dgItems').datagrid('options').url = u;
                        $('#dgItems').datagrid('reload');
                    } else {
                        $('#dgItems').datagrid({
                            url: u,
                            fit: true,
                            rownumbers: true,
                            singleSelect: true,
                            columns: [[
                                {
                                    field: 'consumable_name', title: '耗材名称', width: 220,
                                    formatter: function (v, r) {
                                        var d = r.is_dangerous == 1 ? ' <span class="badge-danger">危</span>' : '';
                                        return '<span style="font-weight:500;">' + (v || '') + '</span>' + d;
                                    }
                                },
                                { field: 'unit', title: '单位', width: 70, align: 'center' },
                                {
                                    field: 'quantity', title: '数量', width: 80, align: 'center',
                                    formatter: function (v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                                },
                                {
                                    field: 'should_return', title: '需归还', width: 80, align: 'center',
                                    formatter: function (v) {
                                        return v == 1 ? '<span class="badge-yes">是</span>' : '<span class="badge-no">否</span>';
                                    }
                                },
                                {
                                    field: 'is_dangerous', title: '危化品', width: 80, align: 'center',
                                    formatter: function (v) {
                                        return v == 1 ? '<span class="badge-danger">是</span>' : '<span class="badge-no">否</span>';
                                    }
                                },
                                { field: 'remark', title: '备注', width: 200, formatter: function (v) { return v || '—'; } }
                            ]]
                        });
                    }
                    $('#dlg').dialog('open');
                }

                /* ===== 刷新 ===== */
                $('#btnRefresh').click(function () { $('#dg').datagrid('reload'); });
            });
        </script>
    </head>

    <body style="height:100%;margin:0;overflow:hidden;">

        <!-- 顶部标题 -->
        <div class="page-header">
            <span style="font-size:20px;">📂</span>
            个人领用记录
            <span class="sub">查看本人所有领用申请的状态与明细，双击行可快速查看明细</span>
        </div>

        <!-- 主体 -->
        <div class="easyui-layout" data-options="fit:true" style="height:calc(100vh - 44px);">
            <div data-options="region:'north',border:false" style="height:auto;">
                <div class="global-tip">
                    📢
                    <span>耗材领用规范提醒：非消耗类耗材领用后，请务必在10日内进入【归还登记】及时归还。</span>
                </div>
                <div class="tb-wrap">
                    <a id="btnDetail" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
                        data-options="iconCls:'icon-search'">查看明细</a>
                    <span style="color:#ccc;">|</span>
                    <a id="btnRefresh" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-reload',plain:true">刷新</a>
                    <span style="color:#90a4ae;font-size:12px;margin-left:8px;">💡 双击行可快速查看明细</span>
                </div>
            </div>
            <div data-options="region:'center',border:false">
                <table id="dg"></table>
            </div>
        </div>

        <!-- 明细弹窗 -->
        <div id="dlg" class="easyui-dialog" title="领用单明细" style="width:780px;height:480px;padding:12px 14px;"
            data-options="closed:true,modal:true">
            <div class="detail-stat" id="dlgStatBar"></div>
            <div style="height:calc(100% - 80px);">
                <table id="dgItems" style="height:100%;"></table>
            </div>
        </div>

    </body>

    </html>