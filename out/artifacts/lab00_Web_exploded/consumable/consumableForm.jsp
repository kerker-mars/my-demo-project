<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <script>
        $(document).ready(function () {
            $('#ff').find('.validatebox-text').validatebox('disableValidation');
        });
    </script>
    <style>
        .validatebox-tip {
            position: absolute;
            z-index: 9999;
            background: #fff;
            border: 1px solid #ccc;
            padding: 3px 5px;
            max-width: 220px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .easyui-textbox,
        .easyui-combobox,
        .easyui-numberbox {
            margin-bottom: 5px;
        }
    </style>

    <form id="ff" method="post" style="padding:5px;">
        <div style="margin-bottom: 10px; display: none;">
            <input class="easyui-textbox" id="id" name="id" style="width:90%" data-options="label:'ID:', readonly:true">
        </div>

        <script>
            // 自定义唯一性校验：编辑时携带 id，允许“名称不变”通过校验
            $.extend($.fn.validatebox.defaults.rules, {
                consumableNameUnique: {
                    validator: function (value) {
                        var id = $('#id').val();
                        var ok = false;
                        $.ajax({
                            type: 'GET',
                            url: '${pageContext.request.contextPath}/ServletConsumable?action=exists',
                            data: { name: value, id: id },
                            async: false,
                            success: function (ret) {
                                ok = (ret === true || ret === 'true');
                            },
                            error: function () {
                                ok = true;
                            }
                        });
                        return ok;
                    },
                    message: '耗材名称已存在！'
                }
            });
        </script>

        <div style="margin-bottom: 10px">
            <input class="easyui-textbox" id="name" name="name" style="width:90%" data-options="label:'耗材名称:',
               required:<%= " edit".equals(request.getParameter("action")) ? "false" : "true" %>,
            validType:'consumableNameUnique'">
        </div>

        <div style="margin-bottom: 10px">
            <input class="easyui-textbox" name="category" style="width:90%" data-options="label:'类别:', required:true">
        </div>

        <div style="margin-bottom: 10px">
            <input class="easyui-textbox" name="spec" style="width:90%" data-options="label:'规格型号:'">
        </div>

        <div style="margin-bottom: 10px">
            <input class="easyui-textbox" name="unit" style="width:90%" data-options="label:'单位:', required:true">
        </div>

        <div style="margin-bottom: 10px">
            <select class="easyui-combobox" name="is_dangerous" style="width:90%"
                data-options="label:'是否危化品:', required:true, panelHeight:'auto', editable:false">
                <option value="0" selected>否</option>
                <option value="1">是</option>
            </select>
        </div>

        <div style="margin-bottom: 10px">
            <input class="easyui-textbox" name="storage_require" style="width:90%" data-options="label:'存储要求:'">
        </div>

        <div style="margin-bottom: 10px">
            <input class="easyui-numberbox" name="validity_period" style="width:90%"
                data-options="label:'保质期(天):', min:0, precision:0">
        </div>

        <div style="margin-bottom: 10px">
            <input class="easyui-textbox" name="remark" style="width:90%;height:60px"
                data-options="label:'备注:', multiline:true">
        </div>
    </form>