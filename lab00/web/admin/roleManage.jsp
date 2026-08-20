<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html style="height:100%;">

    <head>
        <meta charset="UTF-8">
        <title>角色权限配置</title>
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

            .role-card {
                background: #fff;
                border: 1px solid #e0e0e0;
                border-radius: 6px;
                padding: 16px 20px;
                margin-bottom: 12px;
                display: flex;
                align-items: flex-start;
                gap: 16px;
            }

            .role-icon {
                width: 44px;
                height: 44px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 20px;
                flex-shrink: 0;
                color: #fff;
                font-weight: bold;
            }

            .icon-sysadmin {
                background: #F44336;
            }

            .icon-labadmin {
                background: #2196F3;
            }

            .icon-teacher {
                background: #4CAF50;
            }

            .role-info {
                flex: 1;
            }

            .role-name {
                font-size: 15px;
                font-weight: bold;
                color: #333;
                margin-bottom: 4px;
            }

            .role-desc {
                font-size: 13px;
                color: #666;
                margin-bottom: 8px;
            }

            .role-perms {
                font-size: 12px;
                color: #888;
            }

            .perm-tag {
                display: inline-block;
                background: #E3F2FD;
                color: #1565C0;
                border-radius: 3px;
                padding: 2px 7px;
                margin: 2px 3px 2px 0;
                font-size: 12px;
            }

            .perm-tag.danger {
                background: #FFEBEE;
                color: #B71C1C;
            }

            .notice-bar {
                background: #FFF8E1;
                border-left: 4px solid #FFC107;
                padding: 10px 14px;
                margin-bottom: 14px;
                font-size: 13px;
                color: #795548;
                border-radius: 0 4px 4px 0;
            }

            .edit-btn {
                color: #FF9800;
                cursor: pointer;
                font-size: 13px;
                text-decoration: none;
                white-space: nowrap;
            }

            .edit-btn:hover {
                text-decoration: underline;
            }
        </style>
        <script>
            $(function () {
                // 角色固定数据（与数据库 sys_role 对应，id 固定不变）
                var roles = [
                    {
                        id: null, // 从接口加载
                        key: '系统管理员',
                        iconClass: 'icon-sysadmin',
                        label: '系统管理员',
                        perms: ['用户管理', '角色权限配置', '耗材信息维护', '采购计划审核', '数据统计分析'],
                        dangerPerms: []
                    },
                    {
                        id: null,
                        key: '实验室管理员',
                        iconClass: 'icon-labadmin',
                        label: '实验室管理员',
                        perms: ['采购计划填报', '入库登记', '出库登记', '领用申请审核', '归还登记审核', '报废登记', '库存盘点', '反馈管理'],
                        dangerPerms: []
                    },
                    {
                        id: null,
                        key: '教师',
                        iconClass: 'icon-teacher',
                        label: '教师',
                        perms: ['领用申请管理', '归还登记', '使用反馈'],
                        dangerPerms: []
                    }
                ];

                // 加载角色数据并渲染
                $.get('${pageContext.request.contextPath}/ServletSysRole?action=list&page=1&rows=20', function (ret) {
                    var r = (typeof ret === 'string') ? eval('(' + ret + ')') : ret;
                    var rows = r.rows || [];
                    // 将数据库描述和id回填到 roles
                    for (var i = 0; i < rows.length; i++) {
                        for (var j = 0; j < roles.length; j++) {
                            if (rows[i].role_name && rows[i].role_name.indexOf(roles[j].key) >= 0) {
                                roles[j].id = rows[i].id;
                                roles[j].dbDesc = rows[i].description || '';
                                roles[j].userCount = rows[i].user_count || 0;
                            }
                        }
                    }
                    renderCards();
                });

                function renderCards() {
                    var html = '';
                    for (var i = 0; i < roles.length; i++) {
                        var r = roles[i];
                        var permHtml = '';
                        for (var p = 0; p < r.perms.length; p++) {
                            permHtml += '<span class="perm-tag">' + r.perms[p] + '</span>';
                        }
                        for (var d = 0; d < r.dangerPerms.length; d++) {
                            permHtml += '<span class="perm-tag danger">⚠ ' + r.dangerPerms[d] + '</span>';
                        }
                        var desc = r.dbDesc || '（暂无说明）';
                        var userCount = r.userCount !== undefined ? r.userCount : '-';
                        html += '<div class="role-card" id="card_' + i + '">' +
                            '<div class="role-icon ' + r.iconClass + '">' + r.label.charAt(0) + '</div>' +
                            '<div class="role-info">' +
                            '  <div class="role-name">' + r.label +
                            '    <span style="font-size:12px;color:#999;font-weight:normal;margin-left:10px;">当前用户数：' + userCount + '</span>' +
                            '    <a class="edit-btn" style="margin-left:12px;" onclick="editDesc(' + i + ')">✏ 编辑说明</a>' +
                            '  </div>' +
                            '  <div class="role-desc" id="desc_' + i + '">' + desc + '</div>' +
                            '  <div class="role-perms">功能权限：' + permHtml + '</div>' +
                            '</div>' +
                            '</div>';
                    }
                    $('#roleContainer').html(html);
                }

                window.editDesc = function (idx) {
                    var r = roles[idx];
                    $('#editRoleIdx').val(idx);
                    $('#editRoleId').val(r.id);
                    $('#editRoleName').text(r.label);
                    $('#editDesc').textbox('setValue', r.dbDesc || '');
                    $('#dlg').dialog('open');
                };

                $('#btnSaveDlg').click(function () {
                    var idx = parseInt($('#editRoleIdx').val());
                    var id = $('#editRoleId').val();
                    var desc = $('#editDesc').textbox('getValue');
                    if (!id) {
                        $.messager.alert('提示', '角色ID未加载，请刷新页面后重试', 'warning');
                        return;
                    }
                    $.messager.progress();
                    $.post('${pageContext.request.contextPath}/ServletSysRole?action=update', {
                        id: id,
                        role_name: roles[idx].label,
                        description: desc
                    }, function (ret) {
                        $.messager.progress('close');
                        var r = (typeof ret === 'string') ? eval('(' + ret + ')') : ret;
                        if (r.code == '200') {
                            roles[idx].dbDesc = desc;
                            $('#desc_' + idx).text(desc || '（暂无说明）');
                            $('#dlg').dialog('close');
                            $.messager.show({ title: '提示', msg: '保存成功', timeout: 1500, showType: 'slide' });
                        } else {
                            $.messager.alert('提示', r.msg, 'warning');
                        }
                    });
                });
            });
        </script>
    </head>

    <body style="height:100%;margin:0;padding:0;overflow:hidden;">

        <div class="page-header">
            <span style="font-size:20px;">🔐</span>
            角色权限配置
            <span class="sub">查看和配置系统角色的权限说明</span>
        </div>

        <div style="width:100%;height:calc(100% - 44px);padding:16px;overflow-y:auto;background:#f5f5f5;">
            <div class="notice-bar">
                本系统固定三类角色，角色名称与权限范围不可修改。可编辑各角色的说明文字。
            </div>
            <div id="roleContainer">
                <p style="color:#999;padding:20px;">加载中...</p>
            </div>
        </div>

        <div id="dlg" class="easyui-dialog" style="width:460px;padding:14px"
            data-options="closed:true,modal:true,title:'编辑角色说明',buttons:'#dlgBtns'">
            <input type="hidden" id="editRoleIdx">
            <input type="hidden" id="editRoleId">
            <table cellpadding="8" style="width:100%;">
                <tr>
                    <td style="width:80px;color:#666;">角色名称：</td>
                    <td><strong id="editRoleName"></strong></td>
                </tr>
                <tr>
                    <td style="vertical-align:top;color:#666;">角色说明：</td>
                    <td>
                        <input id="editDesc" class="easyui-textbox" style="width:100%;height:80px"
                            data-options="multiline:true,prompt:'请输入角色说明（可选）'">
                    </td>
                </tr>
            </table>
        </div>
        <div id="dlgBtns">
            <a href="javascript:void(0)" class="easyui-linkbutton" id="btnSaveDlg"
                data-options="iconCls:'icon-save'">保存</a>
            <a href="javascript:void(0)" class="easyui-linkbutton" onclick="$('#dlg').dialog('close')"
                data-options="iconCls:'icon-cancel'">取消</a>
        </div>
    </body>

    </html>