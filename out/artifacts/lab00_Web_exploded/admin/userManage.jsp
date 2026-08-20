<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html style="height:100%;">

    <head>
        <meta charset="UTF-8">
        <title>用户管理</title>
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
                overflow: hidden;
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

            /* ===== 搜索栏 ===== */
            .search-bar {
                background: #fff;
                border-bottom: 1px solid #e3eaf5;
                padding: 8px 12px;
                display: flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 6px;
            }

            .search-bar label {
                font-size: 13px;
                color: #546e7a;
            }

            /* ===== 工具栏 ===== */
            .toolbar-bar {
                background: #f0f4fa;
                border-bottom: 1px solid #e3eaf5;
                padding: 6px 10px;
            }

            /* ===== 角色/状态徽章 ===== */
            .badge {
                display: inline-block;
                padding: 2px 9px;
                border-radius: 10px;
                font-size: 12px;
                font-weight: bold;
                color: #fff;
            }

            .badge-admin {
                background: #e53935;
            }

            .badge-lab {
                background: #1976d2;
            }

            .badge-teacher {
                background: #43a047;
            }

            .badge-on {
                background: #43a047;
            }

            .badge-off {
                background: #e53935;
            }

            /* ===== 操作链接 ===== */
            .op-link {
                font-size: 12px;
                cursor: pointer;
                text-decoration: none;
                margin-right: 6px;
            }

            .op-view {
                color: #1976d2;
            }

            .op-edit {
                color: #f57c00;
            }

            .op-stop {
                color: #e53935;
            }

            .op-start {
                color: #43a047;
            }

            /* ===== 弹窗表单 ===== */
            .dlg-form {
                padding: 4px 0;
            }

            .f-row {
                display: flex;
                gap: 16px;
                margin-bottom: 14px;
            }

            .f-col {
                flex: 1;
                min-width: 0;
            }

            .f-label {
                font-size: 13px;
                color: #546e7a;
                font-weight: 600;
                margin-bottom: 5px;
                display: block;
            }

            .f-label .req {
                color: #e53935;
                margin-left: 2px;
            }

            .f-err {
                color: #e53935;
                font-size: 11px;
                margin-top: 3px;
                min-height: 14px;
                display: block;
            }

            /* 密码行：用原生 input 替代 EasyUI passwordbox，彻底避免 disable/enable 破坏 DOM */
            .pwd-input {
                width: 100%;
                height: 28px;
                border: 1px solid #cfd8dc;
                border-radius: 4px;
                padding: 0 8px;
                font-size: 13px;
                color: #263238;
                background: #f8fafc;
                outline: none;
                box-sizing: border-box;
                transition: border-color 0.2s;
            }

            .pwd-input:focus {
                border-color: #1976d2;
                background: #fff;
            }

            .pwd-input[readonly] {
                background: #f0f4fa;
                color: #90a4ae;
                cursor: default;
            }

            .pwd-input.hidden-row {
                display: none;
            }

            /* 密码框包装器 */
            .pwd-wrapper {
                position: relative;
            }

            .pwd-toggle {
                position: absolute;
                right: 8px;
                top: 50%;
                transform: translateY(-50%);
                cursor: pointer;
                font-size: 14px;
                color: #90a4ae;
                user-select: none;
                transition: color 0.2s;
            }

            .pwd-toggle:hover {
                color: #1976d2;
            }

            /* 状态单选 */
            .radio-group {
                padding-top: 4px;
            }

            .radio-group label {
                font-size: 13px;
                color: #37474f;
                margin-right: 16px;
                cursor: pointer;
            }

            .radio-group input[type=radio] {
                margin-right: 4px;
                accent-color: #1976d2;
            }

            /* 弹窗标题栏蓝色 */
            .panel-header {
                background: linear-gradient(90deg, #1565c0, #1976d2) !important;
            }

            .panel-title {
                color: #fff !important;
                font-weight: bold !important;
            }
        </style>

        <script>
            $(function () {
                /* ===== DataGrid ===== */
                $('#dg').datagrid({
                    url: '${pageContext.request.contextPath}/ServletSysUser?action=list',
                    fit: true,
                    pagination: true,
                    rownumbers: true,
                    singleSelect: false,
                    pageSize: 10,
                    striped: true,
                    toolbar: '#tb',
                    columns: [[
                        { field: 'ck', checkbox: true, width: 36 },
                        { field: 'username', title: '账号', width: 110 },
                        { field: 'real_name', title: '姓名', width: 90 },
                        {
                            field: 'role_name', title: '角色', width: 120,
                            formatter: function (v) {
                                if (!v) return '';
                                var cls = v.indexOf('系统管理员') >= 0 ? 'badge-admin'
                                    : v.indexOf('实验室管理员') >= 0 ? 'badge-lab' : 'badge-teacher';
                                return '<span class="badge ' + cls + '">' + v + '</span>';
                            }
                        },
                        { field: 'lab_name', title: '实验室', width: 180 },
                        { field: 'phone', title: '电话', width: 115 },
                        {
                            field: 'email', title: '邮箱', width: 150,
                            formatter: function (v) { return v ? '<span title="' + v + '">' + v + '</span>' : ''; }
                        },
                        {
                            field: 'status', title: '状态', width: 68, align: 'center',
                            formatter: function (v) {
                                return v == 1 ? '<span class="badge badge-on">启用</span>'
                                    : '<span class="badge badge-off">停用</span>';
                            }
                        },
                        {
                            field: 'create_time', title: '创建时间', width: 150,
                            formatter: function (v) {
                                if (!v) return '';
                                var d = new Date(v);
                                return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate())
                                    + ' ' + pad(d.getHours()) + ':' + pad(d.getMinutes()) + ':' + pad(d.getSeconds());
                            }
                        },
                        {
                            field: 'action', title: '操作', width: 160, align: 'center',
                            formatter: function (v, row, idx) {
                                var view = '<a class="op-link op-view" onclick="viewRow(' + idx + ')">查看</a>';
                                var edit = '<a class="op-link op-edit" onclick="editRow(' + idx + ')">编辑</a>';
                                var isSuperAdmin = row.role_name && row.role_name.indexOf('系统管理员') >= 0;
                                var isAdminUser = row.username == 'admin';
                                var tog = '';
                                if (row.status == 1) {
                                    if (!(isSuperAdmin && isAdminUser)) {
                                        tog = '<a class="op-link op-stop"  onclick="toggleStatus(' + row.id + ',0)">停用</a>';
                                    }
                                } else {
                                    tog = '<a class="op-link op-start" onclick="toggleStatus(' + row.id + ',1)">启用</a>';
                                }
                                return view + edit + tog;
                            }
                        }
                    ]],
                    onLoadSuccess: function (data) {
                        $(this).datagrid('getPager').pagination({
                            displayMsg: '{from} - {to} 共 {total} 条'
                        });
                    }
                });

                function pad(n) { return String(n).padStart(2, '0'); }

                /* ===== 弹窗控制 ===== */
                // isNew: 新增  isView: 只读查看
                function openDlg(isNew, isView) {
                    // 重置所有字段
                    $('#uid').val('');
                    $('#f_username').textbox('setValue', '').textbox('readonly', !isNew);
                    $('#f_realname').textbox('setValue', '').textbox('readonly', isView);
                    $('#f_phone').textbox('setValue', '').textbox('readonly', isView);
                    $('#f_email').textbox('setValue', '').textbox('readonly', isView);
                    $('#f_role').combobox('setValue', '').combobox('setText', '');
                    $('#f_lab').combobox('setValue', '').combobox('setText', '');
                    $('input[name="status"][value="1"]').prop('checked', true);
                    $('input[name="status"]').prop('disabled', isView);
                    clearErrors();

                    // 密码行：新增/编辑显示，查看隐藏
                    if (isView) {
                        $('#pwd-row').hide();
                    } else {
                        $('#pwd-row').show();
                        // 直接清空原生 input，不调用 passwordbox API
                        $('#f_password').val('');
                        $('#f_confirm').val('');
                        // 新增时 placeholder 提示必填，编辑时提示可选
                        if (isNew) {
                            $('#f_password').attr('placeholder', '请输入密码（必填）');
                            $('#f_confirm').attr('placeholder', '请再次输入密码');
                        } else {
                            $('#f_password').attr('placeholder', '不修改请留空');
                            $('#f_confirm').attr('placeholder', '不修改请留空');
                        }
                    }

                    // 角色/实验室 enable/disable
                    if (isView) {
                        $('#f_role').combobox('disable');
                        $('#f_lab').combobox('disable');
                    } else {
                        $('#f_role').combobox('enable');
                        $('#f_lab').combobox('enable');
                    }

                    $('#btnSaveDlg').css('display', isView ? 'none' : '');
                    $('#dlg').dialog('setTitle', isNew ? '新增用户' : (isView ? '查看用户' : '编辑用户'));
                    $('#dlg').dialog('open');
                }

                function fillFormData(row) {
                    $('#uid').val(row.id);
                    $('#f_username').textbox('setValue', row.username || '');
                    $('#f_realname').textbox('setValue', row.real_name || '');
                    $('#f_phone').textbox('setValue', row.phone || '');
                    $('#f_email').textbox('setValue', row.email || '');
                    $('input[name="status"][value="' + (row.status || 1) + '"]').prop('checked', true);

                    // 角色
                    $('#f_role').combobox('setValue', String(row.role_id || ''));

                    // 实验室：等角色 combobox 渲染后再判断
                    setTimeout(function () {
                        var rn = $('#f_role').combobox('getText') || '';
                        if (rn.indexOf('系统管理员') >= 0) {
                            $('#f_lab').combobox('disable').combobox('setValue', '').combobox('setText', '');
                        } else {
                            $('#f_lab').combobox('enable');
                            if (row.lab_id != null && row.lab_id !== '') {
                                var data = $('#f_lab').combobox('getData');
                                if (data && data.length > 0) {
                                    $('#f_lab').combobox('setValue', String(row.lab_id));
                                } else {
                                    var pid = String(row.lab_id);
                                    $('#f_lab').combobox({ onLoadSuccess: function () { $('#f_lab').combobox('setValue', pid); } });
                                    $('#f_lab').combobox('reload');
                                }
                            }
                        }
                    }, 80);
                }

                /* ===== 按钮事件 ===== */
                $('#btnAdd').click(function () { openDlg(true, false); });

                $('#btnEdit').click(function () {
                    var rows = $('#dg').datagrid('getSelections');
                    if (!rows.length) { $.messager.alert('提示', '请选择要编辑的用户', 'warning'); return; }
                    if (rows.length > 1) { $.messager.alert('提示', '编辑只能选一条记录', 'warning'); return; }
                    openDlg(false, false);
                    fillFormData(rows[0]);
                });

                window.editRow = function (idx) {
                    var row = $('#dg').datagrid('getRows')[idx];
                    if (row) { openDlg(false, false); fillFormData(row); }
                };
                window.viewRow = function (idx) {
                    var row = $('#dg').datagrid('getRows')[idx];
                    if (row) { openDlg(false, true); fillFormData(row); }
                };

                window.toggleStatus = function (id, s) {
                    if (s == 0) {
                        var rows = $('#dg').datagrid('getRows');
                        for (var i = 0; i < rows.length; i++) {
                            if (rows[i].id == id) {
                                var isSuperAdmin = rows[i].role_name && rows[i].role_name.indexOf('系统管理员') >= 0;
                                var isCurrentUser = rows[i].id == '${sessionScope.user.id}';
                                if (isSuperAdmin && isCurrentUser) {
                                    $.messager.alert('提示', '系统安全拦截：禁止停用或删除当前正在使用的超级管理员账号', 'warning');
                                    return;
                                }
                                break;
                            }
                        }
                    }
                    $.messager.confirm('确认', '确定要' + (s == 1 ? '启用' : '停用') + '该用户？', function (y) {
                        if (!y) return;
                        $.post('${pageContext.request.contextPath}/ServletSysUser?action=updateStatus',
                            { id: id, status: s }, function (ret) {
                                var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                                if (r.code == '200') { $.messager.show({ title: '提示', msg: r.msg, timeout: 1500, showType: 'slide' }); $('#dg').datagrid('reload'); }
                                else $.messager.alert('提示', r.msg, 'warning');
                            });
                    });
                };

                /* ===== 保存 ===== */
                $('#btnSaveDlg').click(function () {
                    var isNew = !$('#uid').val();
                    clearErrors();
                    var ok = true;

                    var username = $('#f_username').textbox('getValue').trim();
                    var realname = $('#f_realname').textbox('getValue').trim();
                    var password = $('#f_password').val();
                    var confirm = $('#f_confirm').val();
                    var roleId = $('#f_role').combobox('getValue');
                    var labId = $('#f_lab').combobox('getValue');
                    var phone = $('#f_phone').textbox('getValue').trim();
                    var email = $('#f_email').textbox('getValue').trim();
                    var status = $('input[name="status"]:checked').val();

                    if (isNew && !username) { setErr('err_username', '请输入账号'); ok = false; }
                    if (!realname) { setErr('err_realname', '请输入姓名'); ok = false; }
                    if (isNew && !password) { setErr('err_password', '请输入密码'); ok = false; }
                    if (password && password !== confirm) { setErr('err_confirm', '两次密码不一致'); ok = false; }
                    if (!roleId) { setErr('err_role', '请选择角色'); ok = false; }
                    var rn = $('#f_role').combobox('getText') || '';
                    if (rn.indexOf('系统管理员') < 0 && !labId) { setErr('err_lab', '请选择实验室'); ok = false; }
                    if (phone && !/^1[3-9]\d{9}$/.test(phone)) { setErr('err_phone', '手机号格式有误'); ok = false; }
                    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { setErr('err_email', '邮箱格式有误'); ok = false; }
                    if (!ok) return;

                    var data = { real_name: realname, role_id: roleId, lab_id: labId, phone: phone, email: email, status: status };
                    var url;
                    if (isNew) {
                        url = '${pageContext.request.contextPath}/ServletSysUser?action=save';
                        data.username = username;
                        data.password = password;
                    } else {
                        url = '${pageContext.request.contextPath}/ServletSysUser?action=update';
                        data.id = $('#uid').val();
                        if (password) data.password = password;
                    }
                    $.messager.progress();
                    $.post(url, data, function (ret) {
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

                /* ===== 批量操作 ===== */
                $('#btnDisable').click(function () {
                    var rows = $('#dg').datagrid('getSelections');
                    if (!rows.length) { $.messager.alert('提示', '请选择用户', 'warning'); return; }
                    for (var i = 0; i < rows.length; i++) {
                        var isSuperAdmin = rows[i].role_name && rows[i].role_name.indexOf('系统管理员') >= 0;
                        var isCurrentUser = rows[i].id == '${sessionScope.user.id}';
                        if (isSuperAdmin && isCurrentUser) {
                            $.messager.alert('提示', '系统安全拦截：禁止停用或删除当前正在使用的超级管理员账号', 'warning');
                            return;
                        }
                    }
                    var ids = rows.map(function (r) { return r.id; });
                    $.messager.confirm('确认', '确定停用所选用户？', function (y) {
                        if (!y) return;
                        $.post('${pageContext.request.contextPath}/ServletSysUser?action=batchDisable', { ids: ids.join(',') }, function (ret) {
                            var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                            if (r.code == '200') { $.messager.show({ title: '提示', msg: r.msg, timeout: 1500, showType: 'slide' }); $('#dg').datagrid('reload'); }
                            else $.messager.alert('提示', r.msg, 'warning');
                        });
                    });
                });
                $('#btnEnable').click(function () {
                    var rows = $('#dg').datagrid('getSelections');
                    if (!rows.length) { $.messager.alert('提示', '请选择用户', 'warning'); return; }
                    var ids = rows.map(function (r) { return r.id; });
                    $.post('${pageContext.request.contextPath}/ServletSysUser?action=batchEnable', { ids: ids.join(',') }, function (ret) {
                        var r = typeof ret === 'string' ? eval('(' + ret + ')') : ret;
                        if (r.code == '200') { $.messager.show({ title: '提示', msg: r.msg, timeout: 1500, showType: 'slide' }); $('#dg').datagrid('reload'); }
                        else $.messager.alert('提示', r.msg, 'warning');
                    });
                });
                $('#btnExport').click(function () {
                    var rows = $('#dg').datagrid('getSelections');
                    if (!rows.length) { $.messager.alert('提示', '请选择用户', 'warning'); return; }
                    var ids = rows.map(function (r) { return r.id; });
                    window.location.href = '${pageContext.request.contextPath}/ServletSysUser?action=export&ids=' + ids.join(',');
                });

                /* ===== 搜索 ===== */
                $('#btnSearch').click(function () {
                    $('#dg').datagrid('load', {
                        real_name: $('#searchName').textbox('getValue'),
                        role_id: $('#searchRole').combobox('getValue'),
                        status: $('#searchStatus').combobox('getValue')
                    });
                });
                $('#btnReset').click(function () {
                    $('#searchName').textbox('clear');
                    $('#searchRole').combobox('clear');
                    $('#searchStatus').combobox('clear');
                    $('#dg').datagrid('load', {});
                });

                /* ===== 工具函数 ===== */
                function setErr(id, msg) { $('#' + id).text(msg); }
                function clearErrors() { $('.f-err').text(''); }

                /* 当前登录用户信息（从 session 获取） */
                var currentUser = {
                    id: '${sessionScope.user.id}',
                    username: '${sessionScope.user.username}',
                    role_name: '${sessionScope.user.role_name}'
                };

                /* 判断是否为当前登录的超管 */
                function isCurrentSuperAdmin(row) {
                    return row.role_name && row.role_name.indexOf('系统管理员') >= 0
                        && row.id == currentUser.id;
                }

                /* 超管保护提示 */
                function showSuperAdminBlock() {
                    $.messager.alert('提示', '系统安全拦截：禁止停用或删除当前正在使用的超级管理员账号', 'warning');
                }
            });

            /* 密码可见性切换函数 */
            function togglePwd(inputId, iconId) {
                var input = document.getElementById(inputId);
                var icon = document.getElementById(iconId);
                if (input.type === 'password') {
                    input.type = 'text';
                    icon.innerHTML = '👁️';
                } else {
                    input.type = 'password';
                    icon.innerHTML = '👁';
                }
            }
        </script>
    </head>

    <body style="height:100%;margin:0;padding:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">👥</span>
            用户管理
            <span class="sub">系统管理员可在此管理系统用户，支持增删改查</span>
        </div>

        <div style="height:calc(100% - 44px);display:flex;flex-direction:column;">
            <!-- 搜索 + 工具栏 -->
            <div style="flex-shrink:0;">
                <div class="search-bar">
                    <label>姓名：</label>
                    <input id="searchName" class="easyui-textbox" style="width:120px" data-options="prompt:'请输入姓名'">
                    <label>角色：</label>
                    <input id="searchRole" class="easyui-combobox" style="width:130px"
                        data-options="editable:false,valueField:'id',textField:'text',url:'${pageContext.request.contextPath}/ServletSysRole?action=listAll',onChange:function(){ $('#dg').datagrid('load',{real_name: $('#searchName').textbox('getValue'),role_id: $('#searchRole').combobox('getValue'),status: $('#searchStatus').combobox('getValue')}); }">
                    <label>状态：</label>
                    <input id="searchStatus" class="easyui-combobox" style="width:90px"
                        data-options="editable:false,valueField:'value',textField:'text',data:[{value:'1',text:'启用'},{value:'0',text:'停用'}],onChange:function(){ $('#dg').datagrid('load',{real_name: $('#searchName').textbox('getValue'),role_id: $('#searchRole').combobox('getValue'),status: $('#searchStatus').combobox('getValue')}); }">
                    <a id="btnSearch" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-search'">查询</a>
                    <a id="btnReset" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-reload'">重置</a>
                </div>
                <div id="tb" class="toolbar-bar">
                    <a id="btnAdd" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-add'">新增</a>
                    <a id="btnEdit" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-edit'">编辑</a>
                    <a id="btnEnable" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-ok'">批量启用</a>
                    <a id="btnDisable" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-cancel'">批量停用</a>
                    <a id="btnExport" href="javascript:void(0)" class="easyui-linkbutton"
                        data-options="iconCls:'icon-save'">批量导出</a>
                </div>
            </div>
            <div style="flex:1;overflow:hidden;">
                <table id="dg"></table>
            </div>
        </div>

        <!-- ===== 新增/编辑/查看 弹窗 ===== -->
        <div id="dlg" class="easyui-dialog" style="width:580px;padding:16px 20px;"
            data-options="closed:true,modal:true,buttons:'#dlgBtns'">
            <input type="hidden" id="uid">
            <div class="dlg-form">

                <!-- 账号 + 姓名 -->
                <div class="f-row">
                    <div class="f-col">
                        <span class="f-label">账号<span class="req">*</span></span>
                        <input id="f_username" class="easyui-textbox" style="width:100%"
                            data-options="prompt:'新增时填写，编辑不可改'">
                        <span class="f-err" id="err_username"></span>
                    </div>
                    <div class="f-col">
                        <span class="f-label">姓名<span class="req">*</span></span>
                        <input id="f_realname" class="easyui-textbox" style="width:100%">
                        <span class="f-err" id="err_realname"></span>
                    </div>
                </div>

                <!-- 密码行（查看时整行隐藏） -->
                <div class="f-row" id="pwd-row">
                    <div class="f-col">
                        <span class="f-label">密码<span class="req">*</span></span>
                        <!-- 使用原生 input[type=password]，添加密码可见切换 -->
                        <div class="pwd-wrapper">
                            <input type="password" id="f_password" class="pwd-input" placeholder="请输入密码（必填）"
                                autocomplete="new-password">
                            <span class="pwd-toggle" id="togglePassword"
                                onclick="togglePwd('f_password', 'togglePassword')">👁</span>
                        </div>
                        <span class="f-err" id="err_password"></span>
                    </div>
                    <div class="f-col">
                        <span class="f-label">确认密码<span class="req">*</span></span>
                        <div class="pwd-wrapper">
                            <input type="password" id="f_confirm" class="pwd-input" placeholder="请再次输入密码"
                                autocomplete="new-password">
                            <span class="pwd-toggle" id="toggleConfirm"
                                onclick="togglePwd('f_confirm', 'toggleConfirm')">👁</span>
                        </div>
                        <span class="f-err" id="err_confirm"></span>
                    </div>
                </div>

                <!-- 角色 + 实验室 -->
                <div class="f-row">
                    <div class="f-col">
                        <span class="f-label">角色<span class="req">*</span></span>
                        <input id="f_role" style="width:100%">
                        <span class="f-err" id="err_role"></span>
                    </div>
                    <div class="f-col" id="labField">
                        <span class="f-label">实验室<span class="req">*</span></span>
                        <input id="f_lab" style="width:100%">
                        <span class="f-err" id="err_lab"></span>
                    </div>
                </div>

                <!-- 电话 + 邮箱 -->
                <div class="f-row">
                    <div class="f-col">
                        <span class="f-label">电话</span>
                        <input id="f_phone" class="easyui-textbox" style="width:100%" data-options="prompt:'选填'">
                        <span class="f-err" id="err_phone"></span>
                    </div>
                    <div class="f-col">
                        <span class="f-label">邮箱</span>
                        <input id="f_email" class="easyui-textbox" style="width:100%" data-options="prompt:'选填'">
                        <span class="f-err" id="err_email"></span>
                    </div>
                </div>

                <!-- 状态 -->
                <div class="f-row">
                    <div class="f-col">
                        <span class="f-label">状态<span class="req">*</span></span>
                        <div class="radio-group">
                            <label><input type="radio" name="status" value="1" checked> 启用</label>
                            <label><input type="radio" name="status" value="0"> 停用</label>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        <div id="dlgBtns">
            <a href="javascript:void(0)" class="easyui-linkbutton" id="btnSaveDlg"
                data-options="iconCls:'icon-save'">保存</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" onclick="$('#dlg').dialog('close')"
                data-options="iconCls:'icon-cancel'">取消</a>
        </div>

        <!-- 初始化 combobox（放在 body 末尾，确保 DOM 已就绪） -->
        <script>
            $(function () {
                var ctx = '${pageContext.request.contextPath}';
                $('#f_role').combobox({
                    editable: false,
                    valueField: 'id', textField: 'text',
                    url: ctx + '/ServletSysRole?action=listAll',
                    loadFilter: function (rows) {
                        return $.map(rows || [], function (r) { return $.extend({}, r, { id: r.id != null ? String(r.id) : '' }); });
                    },
                    onChange: function (val, oldVal) {
                        var rn = $('#f_role').combobox('getText') || '';
                        if (rn.indexOf('系统管理员') >= 0) {
                            // 系统管理员：隐藏实验室字段，清空数据
                            $('#labField').hide();
                            $('#f_lab').combobox('setValue', '').combobox('setText', '');
                        } else {
                            // 其他角色：显示实验室字段
                            $('#labField').show();
                        }
                    }
                });
                $('#f_lab').combobox({
                    editable: false,
                    valueField: 'id', textField: 'text',
                    url: ctx + '/ServletSysUser?action=labOptions',
                    loadFilter: function (rows) {
                        return $.map(rows || [], function (r) { return $.extend({}, r, { id: r.id != null ? String(r.id) : '' }); });
                    }
                });
            });
        </script>

    </body>

    </html>