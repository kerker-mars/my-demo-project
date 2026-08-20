<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>提交领用申请</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/themes/icon.css">
    <script src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/jquery.easyui.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/plugins/jquery-easyui-1.9.14/locale/easyui-lang-zh_CN.js"></script>
    <style>
        html, body { height: 100%; margin: 0; font-family: "微软雅黑", sans-serif; background: #f0f4fa; }

        .page-header {
            background: linear-gradient(90deg, #1565c0, #1976d2);
            color: #fff;
            padding: 10px 18px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 15px;
            font-weight: bold;
            letter-spacing: 1px;
        }
        .page-header .icon { font-size: 20px; }

        .form-card {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 1px 6px rgba(21,101,192,0.10);
            margin: 12px 14px 8px;
            padding: 14px 18px 10px;
        }
        .form-card .card-title {
            font-size: 13px;
            font-weight: bold;
            color: #1565c0;
            margin-bottom: 10px;
            padding-bottom: 6px;
            border-bottom: 2px solid #e3eaf5;
        }
        .form-row { display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-start; }
        .form-item { display: flex; flex-direction: column; gap: 4px; }
        .form-item label { font-size: 12px; color: #546e7a; font-weight: 600; }

        .tb-wrap {
            background: #f0f4fa;
            border-bottom: 1px solid #dce6f5;
            padding: 6px 10px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .btn-primary {
            background: linear-gradient(90deg,#1565c0,#1976d2);
            color: #fff !important;
            border: none !important;
            border-radius: 5px !important;
            font-weight: bold;
            padding: 0 16px !important;
        }
        .btn-primary:hover { background: linear-gradient(90deg,#0d47a1,#1565c0) !important; }

        .badge-danger {
            display: inline-block; padding: 1px 7px; border-radius: 10px;
            font-size: 11px; font-weight: bold; background: #e53935; color: #fff;
        }
        .badge-safe {
            display: inline-block; padding: 1px 7px; border-radius: 10px;
            font-size: 11px; font-weight: bold; background: #43a047; color: #fff;
        }
        .badge-yes {
            display: inline-block; padding: 1px 7px; border-radius: 10px;
            font-size: 11px; font-weight: bold; background: #1976d2; color: #fff;
        }
        .badge-no {
            display: inline-block; padding: 1px 7px; border-radius: 10px;
            font-size: 11px; font-weight: bold; background: #90a4ae; color: #fff;
        }

        /* 弹窗表单 */
        .dlg-form-row { margin-bottom: 12px; }
        .dlg-form-row label { display: block; font-size: 12px; color: #546e7a; font-weight: 600; margin-bottom: 4px; }
    </style>
    <script>
    var ctx = '${pageContext.request.contextPath}';

    $(function () {
        /* ===== 明细表格 ===== */
        $('#dgItems').datagrid({
            fit: true,
            singleSelect: true,
            rownumbers: true,
            toolbar: '#tbItems',
            columns: [[
                {field: 'consumable_id', hidden: true},
                {field: 'consumable_name', title: '耗材名称', width: 220,
                    formatter: function(v, row) {
                        var danger = row.is_dangerous == 1
                            ? ' <span class="badge-danger">危</span>' : '';
                        return '<span style="font-weight:500;">' + (v||'') + '</span>' + danger;
                    }
                },
                {field: 'unit', title: '单位', width: 70, align: 'center'},
                {field: 'quantity', title: '申请数量', width: 90, align: 'center',
                    formatter: function(v) { return '<b style="color:#1565c0;">' + v + '</b>'; }
                },
                {field: 'should_return', title: '需归还', width: 80, align: 'center',
                    formatter: function(v) {
                        return v == 1
                            ? '<span class="badge-yes">是</span>'
                            : '<span class="badge-no">否</span>';
                    }
                },
                {field: 'remark', title: '备注', width: 200, formatter: function(v){ return v||'—'; }}
            ]],
            data: {total: 0, rows: []}
        });

        /* ===== 添加明细 ===== */
        $('#btnAddItem').click(function () {
            $('#dlgItem').dialog('open');
            $('#ffItem').form('clear');
            $('#consumable_id').combobox('clear');
            $('#quantity').numberbox('setValue', '');
            $('#should_return').combobox('setValue', '0');
            $('#remark').textbox('setValue', '');
        });

        /* ===== 删除明细 ===== */
        $('#btnRemoveItem').click(function () {
            var row = $('#dgItems').datagrid('getSelected');
            if (!row) { $.messager.alert('提示', '请选择要删除的明细行', 'warning'); return; }
            var idx = $('#dgItems').datagrid('getRowIndex', row);
            $('#dgItems').datagrid('deleteRow', idx);
        });

        /* ===== 保存明细弹窗 ===== */
        $('#btnSaveItem').click(function () {
            if (!$('#ffItem').form('validate')) return;
            var c = $('#consumable_id').combobox('getValue');
            if (!c) { $.messager.alert('提示', '请选择耗材', 'warning'); return; }
            var qty = parseInt($('#quantity').numberbox('getValue'));
            if (!qty || qty <= 0) { $.messager.alert('提示', '数量必须大于0', 'warning'); return; }

            var data = $('#consumable_id').combobox('getData');
            var sel = null;
            for (var i = 0; i < data.length; i++) {
                if (String(data[i].id) === String(c)) { sel = data[i]; break; }
            }
            var row = {
                consumable_id: parseInt(c),
                consumable_name: sel ? sel.name : $('#consumable_id').combobox('getText'),
                unit: sel ? sel.unit : '',
                is_dangerous: sel ? sel.is_dangerous : 0,
                quantity: qty,
                should_return: parseInt($('#should_return').combobox('getValue') || '0'),
                remark: $('#remark').textbox('getValue')
            };
            $('#dgItems').datagrid('appendRow', row);
            $('#dlgItem').dialog('close');
        });

        /* ===== 提交申请 ===== */
        $('#btnSubmit').click(function () {
            var items = $('#dgItems').datagrid('getRows');
            if (!items || items.length === 0) {
                $.messager.alert('提示', '请先添加领用明细', 'warning'); return;
            }
            var purpose = $.trim($('#purpose').textbox('getValue'));
            if (!purpose) { $.messager.alert('提示', '请填写用途说明', 'warning'); return; }

            $.messager.confirm('确认提交', '确认提交本次领用申请？提交后等待实验室管理员审核。', function (r) {
                if (!r) return;
                $.messager.progress({ title: '处理中', msg: '正在提交...' });
                $.ajax({
                    type: 'POST',
                    url: ctx + '/ServletOutbound?action=create',
                    data: {
                        course_name: $('#course_name').textbox('getValue'),
                        class_name:  $('#class_name').textbox('getValue'),
                        purpose:     purpose,
                        itemsJson:   JSON.stringify(items.map(function(it) {
                            return { consumable_id: it.consumable_id, quantity: it.quantity,
                                     should_return: it.should_return, remark: it.remark };
                        }))
                    },
                    success: function (ret) {
                        $.messager.progress('close');
                        var r2 = (typeof ret === 'string') ? JSON.parse(ret) : ret;
                        if (r2.code == '200') {
                            $.messager.alert('提交成功', r2.msg, 'info');
                            $('#dgItems').datagrid('loadData', {total:0, rows:[]});
                            $('#course_name').textbox('setValue','');
                            $('#class_name').textbox('setValue','');
                            $('#purpose').textbox('setValue','');
                        } else {
                            $.messager.alert('提交失败', r2.msg, 'warning');
                        }
                    },
                    error: function () {
                        $.messager.progress('close');
                        $.messager.alert('错误', '网络异常，请稍后重试', 'error');
                    }
                });
            });
        });
    });
    </script>
</head>
<body style="height:100%;margin:0;overflow:hidden;">

<!-- 顶部标题 -->
<div class="page-header">
    <span class="icon">📋</span> 提交领用申请
    <span style="font-size:12px;font-weight:normal;opacity:.8;margin-left:8px;">填写申请信息并添加所需耗材明细，提交后等待审核</span>
</div>

<!-- 申请信息卡片 -->
<div class="form-card">
    <div class="card-title">📝 申请基本信息</div>
    <div class="form-row">
        <div class="form-item">
            <label>课程名称</label>
            <input id="course_name" class="easyui-textbox" style="width:220px"
                   data-options="prompt:'请输入课程名称'">
        </div>
        <div class="form-item">
            <label>班级信息</label>
            <input id="class_name" class="easyui-textbox" style="width:220px"
                   data-options="prompt:'请输入班级'">
        </div>
        <div class="form-item" style="flex:1;min-width:280px;">
            <label>用途说明 <span style="color:#e53935;">*</span></label>
            <input id="purpose" class="easyui-textbox" style="width:100%;height:52px"
                   data-options="multiline:true,required:true,prompt:'请描述本次领用的具体用途（必填）'">
        </div>
        <div class="form-item" style="justify-content:flex-end;padding-bottom:2px;">
            <a id="btnSubmit" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
               data-options="iconCls:'icon-save'" style="height:52px;font-size:14px;">提 交 申 请</a>
        </div>
    </div>
</div>

<!-- 明细表格区域 -->
<div style="margin:0 14px;background:#fff;border-radius:8px;box-shadow:0 1px 6px rgba(21,101,192,0.10);overflow:hidden;height:calc(100vh - 220px);">
    <table id="dgItems"></table>
</div>

<!-- 工具栏 -->
<div id="tbItems" style="padding:5px 8px;background:#f0f4fa;border-bottom:1px solid #dce6f5;display:flex;align-items:center;gap:6px;">
    <a id="btnAddItem" href="javascript:void(0)" class="easyui-linkbutton"
       data-options="iconCls:'icon-add',plain:true">添加耗材</a>
    <span style="color:#ccc;">|</span>
    <a id="btnRemoveItem" href="javascript:void(0)" class="easyui-linkbutton"
       data-options="iconCls:'icon-remove',plain:true">删除选中</a>
    <span style="color:#90a4ae;font-size:12px;margin-left:8px;">⚠ 危险化学品领用需经双人审核，请如实填写</span>
</div>

<!-- 添加明细弹窗 -->
<div id="dlgItem" class="easyui-dialog" title="添加领用耗材"
     style="width:480px;padding:16px 20px;"
     data-options="closed:true,modal:true,buttons:'#dlgItemBtns'">
    <form id="ffItem">
        <div class="dlg-form-row">
            <label>选择耗材 <span style="color:#e53935;">*</span></label>
            <input id="consumable_id" class="easyui-combobox" style="width:100%"
                   data-options="required:true,valueField:'id',textField:'text',
                       url:'${pageContext.request.contextPath}/ServletOutbound?action=consumableOptions',
                       method:'get',panelHeight:240,
                       prompt:'请选择耗材（含危化品标注）'">
        </div>
        <div class="dlg-form-row">
            <label>申请数量 <span style="color:#e53935;">*</span></label>
            <input id="quantity" class="easyui-numberbox" style="width:100%"
                   data-options="required:true,min:1,precision:0,prompt:'请输入数量'">
        </div>
        <div class="dlg-form-row">
            <label>是否需要归还</label>
            <select id="should_return" class="easyui-combobox" style="width:100%"
                    data-options="panelHeight:'auto',editable:false">
                <option value="0" selected>否（消耗性耗材）</option>
                <option value="1">是（需归还）</option>
            </select>
        </div>
        <div class="dlg-form-row">
            <label>备注说明</label>
            <input id="remark" class="easyui-textbox" style="width:100%"
                   data-options="prompt:'可填写规格要求等（选填）'">
        </div>
    </form>
</div>
<div id="dlgItemBtns">
    <a id="btnSaveItem" href="javascript:void(0)" class="easyui-linkbutton btn-primary"
       data-options="iconCls:'icon-ok'">确认添加</a>
    <a href="javascript:void(0)" class="easyui-linkbutton"
       data-options="iconCls:'icon-back'" onclick="$('#dlgItem').dialog('close')">取消</a>
</div>

</body>
</html>
