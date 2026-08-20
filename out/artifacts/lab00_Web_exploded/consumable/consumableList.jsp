<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>耗材信息维护</title>
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

            .toolbar-wrap {
                background: #f0f4fa;
                border-bottom: 1px solid #dce6f5;
                padding: 6px 10px;
                display: flex;
                align-items: center;
                gap: 6px;
                flex-wrap: wrap;
            }

            .search-wrap {
                background: #fff;
                border-bottom: 1px solid #e8eef7;
                padding: 7px 10px;
                display: flex;
                align-items: center;
                gap: 8px;
                flex-wrap: wrap;
            }

            .search-wrap label {
                font-size: 13px;
                color: #546e7a;
            }

            .badge-danger {
                display: inline-block;
                padding: 1px 8px;
                border-radius: 10px;
                font-size: 12px;
                font-weight: bold;
                background: #ffebee;
                color: #c62828;
                border: 1px solid #ef9a9a;
            }

            .badge-safe {
                display: inline-block;
                padding: 1px 8px;
                border-radius: 10px;
                font-size: 12px;
                background: #e8f5e9;
                color: #2e7d32;
                border: 1px solid #a5d6a7;
            }

            /* 弹窗表单 */
            .dlg-section {
                margin-bottom: 14px;
            }

            .dlg-row {
                display: flex;
                gap: 14px;
                margin-bottom: 10px;
            }

            .dlg-col {
                flex: 1;
                min-width: 0;
            }

            .dlg-col label {
                display: block;
                font-size: 12px;
                color: #546e7a;
                font-weight: 600;
                margin-bottom: 4px;
            }

            .dlg-col label .req {
                color: #e53935;
            }

            .dlg-col .f-err {
                color: #e53935;
                font-size: 11px;
                min-height: 13px;
                display: block;
            }

            .dlg-col.full {
                flex: 2;
            }

            .section-title {
                font-size: 13px;
                font-weight: bold;
                color: #1565c0;
                border-left: 3px solid #1976d2;
                padding-left: 8px;
                margin-bottom: 10px;
            }

            .danger-tip {
                background: #fff3e0;
                border: 1px solid #ffcc80;
                border-radius: 4px;
                padding: 6px 10px;
                font-size: 12px;
                color: #e65100;
                margin-top: 6px;
                display: none;
            }
        </style>
        <script>
            $(function () {
                /* ===== DataGrid ===== */
                $('#dg').datagrid({
                    url: '${pageContext.request.contextPath}/ServletConsumable?action=getdglist',
                    toolbar: '#tb',
                    pagination: true,
                    fit: true,
                    singleSelect: true,
                    rownumbers: true,
                    striped: true,
                    pageSize: 10,
                    pageList: [10, 20, 50],
                    columns: [[
                        { field: 'id', title: 'ID', width: 55, hidden: true },
                        { field: 'name', title: '耗材名称', width: 160 },
                        { field: 'category', title: '类别', width: 100 },
                        { field: 'spec', title: '规格型号', width: 130 },
                        { field: 'unit', title: '单位', width: 65, align: 'center' },
                        {
                            field: 'is_dangerous', title: '是否危化品', width: 80, align: 'center',
                            formatter: function (v) {
                                return v == 1 ? '<span class="badge-danger">⚠ 危化品</span>'
                                    : '<span class="badge-safe">普通</span>';
                            }
                        },
                        {
                            field: 'returnable', title: '是否需归还', width: 90, align: 'center',
                            formatter: function (v) {
                                return v == 1
                                    ? '<span style="display:inline-block;padding:1px 10px;border-radius:10px;font-size:12px;font-weight:bold;background:#1976d2;color:#fff;">是</span>'
                                    : '<span style="display:inline-block;padding:1px 10px;border-radius:10px;font-size:12px;font-weight:bold;background:#e0e0e0;color:#757575;">否</span>';
                            }
                        },
                        { field: 'storage_require', title: '存储要求', width: 160 },
                        {
                            field: 'remark', title: '备注', width: 160,
                            formatter: function (v) { return v || '—'; }
                        },
                        {
                            field: '_op', title: '操作', width: 140, align: 'center',
                            formatter: function (v, row) {
                                return '<a href="javascript:void(0)" onclick="viewItem(' + row.id + ')" style="color:#1976d2;margin-right:8px;font-size:12px;">查看</a>'
                                    + '<a href="javascript:void(0)" onclick="editItem(' + row.id + ')" style="color:#f57c00;margin-right:8px;font-size:12px;">编辑</a>'
                                    + '<a href="javascript:void(0)" onclick="delItem(' + row.id + ',\'' + row.name + '\')" style="color:#e53935;font-size:12px;">删除</a>';
                            }
                        }
                    ]],
                    loadMsg: '加载中...',
                    emptyMsg: '暂无耗材数据',
                    onLoadSuccess: function (data) {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                /* ===== 弹窗打开 ===== */
                // mode: 'add' | 'edit' | 'view'
                function openDlg(mode, data) {
                    clearDlgErrors();
                    // 重置字段
                    $('#d_id').val('');
                    $('#d_name').textbox('setValue', '');
                    $('#d_category').textbox('setValue', '');
                    $('#d_spec').textbox('setValue', '');
                    $('#d_unit').textbox('setValue', '');
                    $('#d_is_dangerous').combobox('setValue', '0');
                    $('#d_storage_require').textbox('setValue', '');
                    $('#d_remark').textbox('setValue', '');
                    $('#d_returnable').combobox('setValue', '0');
                    $('#dangerTip').hide();

                    var titles = { add: '新增耗材', edit: '编辑耗材', view: '查看耗材' };
                    $('#dlg').dialog('setTitle', titles[mode]);

                    var ro = (mode === 'view');
                    $('#d_name').textbox('readonly', ro);
                    $('#d_category').textbox('readonly', ro);
                    $('#d_spec').textbox('readonly', ro);
                    $('#d_unit').textbox('readonly', ro);
                    $('#d_storage_require').textbox('readonly', ro);
                    $('#d_remark').textbox('readonly', ro);
                    if (ro) { $('#d_is_dangerous').combobox('disable'); $('#d_returnable').combobox('disable'); }
                    else { $('#d_is_dangerous').combobox('enable'); $('#d_returnable').combobox('enable'); }
                    $('#btnSaveDlg').css('display', ro ? 'none' : '');

                    if (data) {
                        $('#d_id').val(data.id);
                        $('#d_name').textbox('setValue', data.name || '');
                        $('#d_category').textbox('setValue', data.category || '');
                        $('#d_spec').textbox('setValue', data.spec || '');
                        $('#d_unit').textbox('setValue', data.unit || '');
                        $('#d_is_dangerous').combobox('setValue', String(data.is_dangerous || '0'));
                        $('#d_storage_require').textbox('setValue', data.storage_require || '');
                        if (data.validity_period) $('#d_validity_period').numberbox('setValue', data.validity_period);
                        $('#d_remark').textbox('setValue', data.remark || '');
                        $('#d_returnable').combobox('setValue', String(data.returnable || '0'));
                        if (data.is_dangerous == 1) $('#dangerTip').show();
                    }
                    $('#dlg').dialog('open');
                }

                function loadAndOpen(id, mode) {
                    $.get('${pageContext.request.contextPath}/ServletConsumable?action=getone', { id: id }, function (ret) {
                        var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                        if (r.code == '200') openDlg(mode, r.data);
                        else $.messager.alert('错误', r.msg, 'error');
                    });
                }

                window.viewItem = function (id) { loadAndOpen(id, 'view'); };
                window.editItem = function (id) { loadAndOpen(id, 'edit'); };
                window.delItem = function (id, name) {
                    $.messager.confirm('确认删除', '确定删除耗材【' + name + '】？删除后不可恢复。', function (y) {
                        if (!y) return;
                        $.get('${pageContext.request.contextPath}/ServletConsumable?action=delete', { id: id }, function (ret) {
                            var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                            if (r.code == '200') { $.messager.show({ title: '提示', msg: '删除成功', timeout: 1500, showType: 'slide' }); $('#dg').datagrid('reload'); }
                            else $.messager.alert('提示', r.msg, 'warning');
                        });
                    });
                };

                $('#btnAdd').click(function () { openDlg('add', null); });
                $('#btnEdit').click(function () {
                    var row = $('#dg').datagrid('getSelected');
                    if (!row) { $.messager.alert('提示', '请先选择一条耗材记录', 'warning'); return; }
                    loadAndOpen(row.id, 'edit');
                });
                $('#btnDelete').click(function () {
                    var row = $('#dg').datagrid('getSelected');
                    if (!row) { $.messager.alert('提示', '请先选择一条耗材记录', 'warning'); return; }
                    delItem(row.id, row.name);
                });

                /* 危化品提示 */
                $('#d_is_dangerous').combobox({
                    onChange: function (v) { v == '1' ? $('#dangerTip').show() : $('#dangerTip').hide(); }
                });

                /* ===== 保存 ===== */
                $('#btnSaveDlg').click(function () {
                    clearDlgErrors();
                    var ok = true;
                    var name = $('#d_name').textbox('getValue').trim();
                    var category = $('#d_category').textbox('getValue').trim();
                    var unit = $('#d_unit').textbox('getValue').trim();
                    var isDanger = $('#d_is_dangerous').combobox('getValue');
                    var id = $('#d_id').val();

                    if (!name) { setDlgErr('err_name', '耗材名称不能为空'); ok = false; }
                    if (!category) { setDlgErr('err_category', '类别不能为空'); ok = false; }
                    if (!unit) { setDlgErr('err_unit', '单位不能为空'); ok = false; }
                    if (!ok) return;

                    // 唯一性校验
                    $.ajax({
                        url: '${pageContext.request.contextPath}/ServletConsumable?action=exists',
                        data: { name: name, id: id }, async: false,
                        success: function (ret) { if (ret === 'false' || ret === false) { setDlgErr('err_name', '耗材名称已存在'); ok = false; } }
                    });
                    if (!ok) return;

                    var data = {
                        name: name, category: category,
                        spec: $('#d_spec').textbox('getValue'),
                        unit: unit,
                        is_dangerous: isDanger,
                        returnable: $('#d_returnable').combobox('getValue'),
                        storage_require: $('#d_storage_require').textbox('getValue'),
                        remark: $('#d_remark').textbox('getValue')
                    };
                    var action = id ? 'update' : 'add';
                    if (id) data.id = id;

                    $.messager.progress();
                    $.post('${pageContext.request.contextPath}/ServletConsumable?action=' + action, data, function (ret) {
                        $.messager.progress('close');
                        var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                        if (r.code == '200') {
                            $.messager.show({ title: '提示', msg: r.msg, timeout: 1500, showType: 'slide' });
                            $('#dlg').dialog('close');
                            $('#dg').datagrid('reload');
                        } else {
                            $.messager.alert('提示', r.msg, 'warning');
                        }
                    });
                });

                /* ===== 搜索 ===== */
                $('#btnSearch').click(function () {
                    $('#dg').datagrid('load', {
                        name: $('#searchName').textbox('getValue'),
                        category: $('#searchCategory').textbox('getValue'),
                        is_dangerous: $('#searchDanger').combobox('getValue'),
                        returnable: $('#searchReturnable').combobox('getValue')
                    });
                });
                $('#btnClear').click(function () {
                    $('#searchName').textbox('clear');
                    $('#searchCategory').textbox('clear');
                    $('#searchDanger').combobox('setValue', '');
                    $('#searchReturnable').combobox('setValue', '');
                    $('#dg').datagrid('load', {});
                });

                function setDlgErr(id, msg) { $('#' + id).text(msg); }
                function clearDlgErrors() { $('.f-err').text(''); }
            });
        </script>
    </head>

    <body style="font-family:'微软雅黑',sans-serif;height:100%;margin:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">📦</span>
            耗材信息维护
            <span class="sub">系统管理员可在此维护耗材的基础信息</span>
        </div>

        <div style="height:calc(100% - 44px);display:flex;flex-direction:column;">
            <!-- 工具栏 -->
            <div class="toolbar-wrap" id="tb" style="flex-shrink:0;">
                <a id="btnAdd" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-add'">新增耗材</a>
                <a id="btnEdit" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-edit'">编辑</a>
                <a id="btnDelete" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-remove'">删除</a>
                <span style="border-left:1px solid #ccc;height:18px;margin:0 4px;"></span>
                <!-- 搜索区 -->
                <label>名称：</label>
                <input id="searchName" class="easyui-textbox" style="width:120px" data-options="prompt:'耗材名称'">
                <label>类别：</label>
                <input id="searchCategory" class="easyui-textbox" style="width:100px" data-options="prompt:'类别'">
                <label>是否为危化品：</label>
                <select id="searchDanger" class="easyui-combobox" style="width:90px"
                    data-options="panelHeight:'auto',editable:false,onChange:function(){ $('#dg').datagrid('load',{name: $('#searchName').textbox('getValue'),category: $('#searchCategory').textbox('getValue'),is_dangerous: $('#searchDanger').combobox('getValue'),returnable: $('#searchReturnable').combobox('getValue')}); }">
                    <option value="">全部</option>
                    <option value="0">普通</option>
                    <option value="1">危化品</option>
                </select>
                <label>是否需归还：</label>
                <select id="searchReturnable" class="easyui-combobox" style="width:90px"
                    data-options="panelHeight:'auto',editable:false,onChange:function(){ $('#dg').datagrid('load',{name: $('#searchName').textbox('getValue'),category: $('#searchCategory').textbox('getValue'),is_dangerous: $('#searchDanger').combobox('getValue'),returnable: $('#searchReturnable').combobox('getValue')}); }">
                    <option value="">全部</option>
                    <option value="0">否</option>
                    <option value="1">是</option>
                </select>
                <a id="btnSearch" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-search'">查询</a>
                <a id="btnClear" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-clear'">清空</a>
            </div>

            <div style="flex:1;overflow:hidden;">
                <table id="dg"></table>
            </div>

            <!-- ===== 新增/编辑/查看 弹窗 ===== -->
            <div id="dlg" class="easyui-dialog" style="width:560px;padding:16px 20px;"
                data-options="closed:true,modal:true,buttons:'#dlgBtns'">
                <input type="hidden" id="d_id">

                <div class="section-title">基本信息</div>
                <div class="dlg-row">
                    <div class="dlg-col">
                        <label>耗材名称 <span class="req">*</span></label>
                        <input id="d_name" class="easyui-textbox" style="width:100%">
                        <span class="f-err" id="err_name"></span>
                    </div>
                    <div class="dlg-col">
                        <label>类别 <span class="req">*</span></label>
                        <input id="d_category" class="easyui-textbox" style="width:100%"
                            data-options="prompt:'如：试剂、器皿、耗件'">
                        <span class="f-err" id="err_category"></span>
                    </div>
                </div>
                <div class="dlg-row">
                    <div class="dlg-col">
                        <label>规格型号</label>
                        <input id="d_spec" class="easyui-textbox" style="width:100%" data-options="prompt:'如：500ml、A4'">
                    </div>
                    <div class="dlg-col">
                        <label>单位 <span class="req">*</span></label>
                        <input id="d_unit" class="easyui-textbox" style="width:100%" data-options="prompt:'如：瓶、个、盒'">
                        <span class="f-err" id="err_unit"></span>
                    </div>
                </div>

                <div class="section-title" style="margin-top:6px;">安全与存储</div>
                <div class="dlg-row">
                    <div class="dlg-col">
                        <label>是否危化品 <span class="req">*</span></label>
                        <select id="d_is_dangerous" class="easyui-combobox" style="width:100%"
                            data-options="required:true,panelHeight:'auto',editable:false">
                            <option value="0">否（普通耗材）</option>
                            <option value="1">是（危险化学品）</option>
                        </select>
                    </div>
                    <div class="dlg-col">
                        <label>是否需归还 <span class="req">*</span></label>
                        <select id="d_returnable" class="easyui-combobox" style="width:100%"
                            data-options="required:true,panelHeight:'auto',editable:false">
                            <option value="0">否</option>
                            <option value="1">是</option>
                        </select>
                    </div>
                </div>
                <div class="dlg-row">
                    <div class="dlg-col full">
                        <label>存储要求</label>
                        <input id="d_storage_require" class="easyui-textbox" style="width:100%"
                            data-options="prompt:'如：避光、低温、防潮'">
                    </div>
                </div>
                <div id="dangerTip" class="danger-tip">
                    ⚠ 该耗材被标记为危险化学品，领用时将触发双人审核（五双管理）流程，请确保存储要求填写完整。
                </div>

                <div class="section-title" style="margin-top:10px;">其他</div>
                <div class="dlg-row">
                    <div class="dlg-col full">
                        <label>备注</label>
                        <input id="d_remark" class="easyui-textbox" style="width:100%;height:56px"
                            data-options="multiline:true,prompt:'选填'">
                    </div>
                </div>
            </div>
            <div id="dlgBtns">
                <a href="javascript:void(0)" class="easyui-linkbutton" id="btnSaveDlg"
                    data-options="iconCls:'icon-save'">保存</a>
                <a href="javascript:void(0)" class="easyui-linkbutton" onclick="$('#dlg').dialog('close')"
                    data-options="iconCls:'icon-cancel'">关闭</a>
            </div>

    </body>

    </html>