<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>毕业生就业信息管理</title>
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/default/easyui.css">
        <link rel="stylesheet" type="text/css"
            href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/icon.css">
        <script type="text/javascript"
            src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.min.js"></script>
        <script type="text/javascript"
            src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.easyui.min.js"></script>
        <script type="text/javascript"
            src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/locale/easyui-lang-zh_CN.js"></script>

        <script>
            $(function () {
                $('#dg').datagrid({
                    url: '${pageContext.request.contextPath}/ServletEmploymentInfo?action=getdglist',
                    toolbar: '#tb',
                    pagination: true,
                    fit: true,
                    singleSelect: true,
                    rownumbers: true,
                    pageSize: 10,
                    pageList: [10, 20, 30, 50],
                    columns: [[
                        { field: 'employmentId', title: '就业ID', width: 80, hidden: true },
                        { field: 'studentId', title: '学生ID', width: 100 },
                        {
                            field: 'employmentType', title: '就业类型', width: 100,
                            formatter: function (value) {
                                var types = { '1': '正式就业', '2': '灵活就业', '3': '自主创业', '4': '升学', '5': '出国', '6': '未就业' };
                                return types[value] || value;
                            }
                        },
                        { field: 'companyName', title: '单位名称', width: 200 },
                        { field: 'jobPosition', title: '职位', width: 120 },
                        {
                            field: 'companyNature', title: '单位性质', width: 100,
                            formatter: function (value) {
                                var natures = { '1': '国有企业', '2': '民营企业', '3': '外资企业', '4': '政府机关', '5': '事业单位', '6': '其他' };
                                return natures[value] || value;
                            }
                        },
                        { field: 'workCity', title: '工作城市', width: 100 },
                        { field: 'employmentTime', title: '就业时间', width: 120 },
                        { field: 'contactPhone', title: '单位电话', width: 120 },
                        {
                            field: 'auditStatus', title: '审核状态', width: 80,
                            styler: function (value) {
                                if (value == '通过') return 'color:green;';
                                if (value == '驳回') return 'color:red;';
                                if (value == '待审核') return 'color:orange;';
                            }
                        },
                        { field: 'auditOpinion', title: '审核意见', width: 150 },
                        { field: 'auditorId', title: '审核人ID', width: 80 },
                        { field: 'auditTime', title: '审核时间', width: 150 }
                    ]],
                    loadMsg: '数据加载中，请稍候...',
                    emptyMsg: '暂无数据'
                });

                // 新增功能 - 修复后的版本
                $('#btnAdd').click(function () {
                    $('#dd').dialog({
                        title: '新增就业信息',
                        width: 500,
                        height: 600,
                        closed: false,
                        cache: false,
                        href: '${pageContext.request.contextPath}/employment/employmentInfoForm.jsp',
                        modal: true,
                        onLoad: function () {
                            // 清除表单和验证错误
                            $('#ff').form('clear');
                            clearAllValidation();
                            $('#ff').find('.validatebox-text').validatebox('disableValidation');

                            // 延迟启用验证
                            setTimeout(function () {
                                $('#ff').find('.validatebox-text').validatebox('enableValidation');
                            }, 100);
                        },
                        onClose: function () {
                            // 关闭时清除验证状态
                            $('#ff').form('clear');
                            $('#ff').find('.validatebox-text').validatebox('disableValidation');
                        },
                        buttons: [{
                            text: '保存',
                            iconCls: 'icon-save',
                            handler: function () {
                                let isOk = $('#ff').form('validate');
                                if (isOk) {
                                    $.messager.confirm('确认', '是否确认添加？', function (r) {
                                        if (r) {
                                            SaveData('add');
                                        }
                                    });
                                }
                            }
                        }, {
                            text: '退出',
                            iconCls: 'icon-back',
                            handler: function () {
                                $('#dd').dialog('close');
                            }
                        }]
                    });
                });

                // 删除功能
                $('#btnDelete').click(function () {
                    let row = $('#dg').datagrid('getSelected');
                    if (row == null) {
                        $.messager.alert('提示', '请选择要删除的数据！', 'warning');
                        return;
                    }
                    $.messager.confirm('提示', '是否要删除该就业信息？', function (r) {
                        if (r) {
                            $.ajax({
                                type: "GET",
                                url: "${pageContext.request.contextPath}/ServletEmploymentInfo?action=delete",
                                data: { employmentId: row.employmentId },
                                success: function (ret) {
                                    let result = eval("(" + ret + ")");
                                    if (result.code == '200') {
                                        $.messager.show({
                                            title: '提示',
                                            msg: result.msg,
                                            timeout: 2000,
                                            showType: 'slide'
                                        });
                                        $('#dg').datagrid('reload');
                                    } else {
                                        $.messager.alert('提示', result.msg, 'warning');
                                    }
                                }
                            });
                        }
                    });
                });

                // 编辑功能 - 修复后的版本
                $('#btnEdit').click(function () {
                    if ($('#dg').datagrid('getSelected') == null) {
                        $.messager.alert('提示', '请选择要编辑的数据！', 'warning');
                        return;
                    }

                    $('#dd').dialog({
                        title: '修改就业信息',
                        width: 500,
                        height: 600,
                        closed: false,
                        cache: false,
                        href: '${pageContext.request.contextPath}/employment/employmentInfoForm.jsp?action=edit',
                        modal: true,
                        onLoad: function () {
                            // 先清除验证错误
                            $('#ff').form('clear');
                            clearAllValidation();
                            $('#ff').find('.validatebox-text').validatebox('disableValidation');

                            let row = $('#dg').datagrid('getSelected');
                            $.ajax({
                                type: "GET",
                                url: "${pageContext.request.contextPath}/ServletEmploymentInfo?action=getone",
                                data: { employmentId: row.employmentId },
                                success: function (ret) {
                                    let result = eval("(" + ret + ")");
                                    if (result.code == '200') {
                                        // 禁用验证后再加载数据
                                        $('#studentId').textbox({
                                            readonly: true,
                                            required: true
                                        });

                                        // 加载数据
                                        $('#ff').form('load', result.data);

                                        // 延迟启用验证，确保数据已加载
                                        setTimeout(function () {
                                            $('#ff').find('.validatebox-text').validatebox('enableValidation');
                                        }, 100);
                                    } else {
                                        $.messager.alert('错误', result.msg, 'error');
                                    }
                                },
                                error: function () {
                                    $.messager.alert('错误', '获取就业信息失败', 'error');
                                }
                            });
                        },
                        onClose: function () {
                            // 关闭时清除验证状态
                            $('#ff').form('clear');
                            $('#ff').find('.validatebox-text').validatebox('disableValidation');
                        },
                        buttons: [{
                            text: '保存',
                            iconCls: 'icon-save',
                            handler: function () {
                                let isOk = $('#ff').form('validate');
                                if (isOk) {
                                    $.messager.confirm('确认', '是否确认修改？', function (r) {
                                        if (r) {
                                            SaveData('update');
                                        }
                                    });
                                }
                            }
                        }, {
                            text: '退出',
                            iconCls: 'icon-back',
                            handler: function () {
                                $('#dd').dialog('close');
                            }
                        }]
                    });
                });

                function SaveData(action) {
                    $.messager.progress();

                    // 保存前确保验证已启用
                    $('#ff').find('.validatebox-text').validatebox('enableValidation');

                    $('#ff').form('submit', {
                        url: '${pageContext.request.contextPath}/ServletEmploymentInfo?action=' + action,
                        onSubmit: function () {
                            var isValid = $(this).form('validate');
                            if (!isValid) {
                                $.messager.progress('close');
                                // 验证失败时重新禁用验证，避免持续显示错误
                                setTimeout(function () {
                                    $('#ff').find('.validatebox-text').validatebox('disableValidation');
                                }, 100);
                            }
                            return isValid;
                        },
                        success: function (data) {
                            let result = eval('(' + data + ')');
                            if (result.code == '200') {
                                $.messager.alert('提示：', result.msg, 'info');
                                $('#dd').dialog('close');
                                $('#dg').datagrid('reload');

                                // 关闭后清除验证状态
                                $('#ff').form('clear');
                                $('#ff').find('.validatebox-text').validatebox('disableValidation');
                            } else {
                                $.messager.alert('提示', result.msg, 'warning');
                            }
                            $.messager.progress('close');
                        },
                        error: function () {
                            $.messager.alert('错误', '保存数据失败', 'error');
                            $.messager.progress('close');
                        }
                    });
                }

                // 查询功能
                $('#btnSearch').click(function () {
                    let studentId = $('#searchStudentId').val();
                    let companyName = $('#searchCompanyName').val();
                    let auditStatus = $('#searchAuditStatus').combobox('getValue');

                    console.log('搜索条件:', {
                        studentId: studentId,
                        companyName: companyName,
                        auditStatus: auditStatus
                    });

                    // 重新加载数据，传递查询参数
                    $('#dg').datagrid('load', {
                        studentId: studentId,
                        companyName: companyName,
                        auditStatus: auditStatus
                    });
                });

                // 重置查询条件
                $('#btnReset').click(function () {
                    $('#searchStudentId').textbox('setValue', '');
                    $('#searchCompanyName').textbox('setValue', '');
                    $('#searchAuditStatus').combobox('setValue', '');
                    $('#dg').datagrid('load', {});
                });

                // 按回车键触发查询
                $('#searchStudentId, #searchCompanyName').keypress(function (e) {
                    if (e.keyCode == 13) {
                        $('#btnSearch').click();
                    }
                });

                // 清除所有验证错误
                function clearAllValidation() {
                    $('.validatebox-tip').remove();
                    $('.validatebox-invalid').removeClass('validatebox-invalid');
                }
            });
        </script>

        <style>
            /* 调整验证错误提示的位置，避免遮挡按钮 */
            .validatebox-tip {
                position: absolute;
                z-index: 9999;
                background: #fff;
                border: 1px solid #ccc;
                padding: 3px 5px;
                max-width: 200px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            }

            /* 确保所有输入框样式一致 */
            .easyui-textbox,
            .easyui-combobox,
            .easyui-datebox,
            .easyui-datetimebox {
                width: 90% !important;
            }

            /* 调整表单元素间距 */
            .dialog-content {
                padding: 10px;
            }
        </style>
    </head>

    <body class="easyui-layout">
        <div data-options="region:'center',border:false">
            <table id="dg"></table>
        </div>

        <div id="dd"></div>

        <div id="tb" style="height:auto;padding:10px">
            <div style="margin-bottom:5px">
                <a id="btnAdd" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-add',plain:true">新增</a>
                <a id="btnEdit" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-edit',plain:true">编辑</a>
                <a id="btnDelete" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-remove',plain:true">删除</a>
            </div>
            <div>
                <span>学生ID：</span>
                <input id="searchStudentId" class="easyui-textbox" style="width:100px">
                <span>单位名称：</span>
                <input id="searchCompanyName" class="easyui-textbox" style="width:120px">
                <span>审核状态：</span>
                <select id="searchAuditStatus" class="easyui-combobox" style="width:100px"
                    data-options="editable:false,onChange:function(){ doSearch(); }">
                    <option value="">全部</option>
                    <option value="待审核">待审核</option>
                    <option value="通过">通过</option>
                    <option value="驳回">驳回</option>
                </select>
                <a id="btnSearch" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-search'">查询</a>
                <a id="btnReset" href="javascript:void(0)" class="easyui-linkbutton"
                    data-options="iconCls:'icon-reload'">重置</a>
            </div>
        </div>
    </body>

    </html>