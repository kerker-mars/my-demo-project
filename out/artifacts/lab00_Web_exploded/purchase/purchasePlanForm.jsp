<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="easyui-layout" data-options="fit:true">
    <div data-options="region:'center',border:false">
        <table id="dgPlanItem"></table>
    </div>

    <div id="tbPlanItem" style="height:auto;padding:5px">
        <a id="btnAddItem" href="javascript:void(0)" class="easyui-linkbutton"
           data-options="iconCls:'icon-add',plain:true">添加明细</a>
        <a id="btnRemoveItem" href="javascript:void(0)" class="easyui-linkbutton"
           data-options="iconCls:'icon-remove',plain:true">删除明细</a>
    </div>

    <div id="dlgItem" class="easyui-dialog" title="采购明细"
         style="width:520px;height:260px;padding:10px"
         data-options="closed:true,modal:true,buttons:'#dlgItemBtns'">
        <form id="ffItem" method="post">
            <div style="margin-bottom:10px">
                <input id="consumable_id" class="easyui-combobox required-field" style="width:95%"
                       data-options="label:'耗材 *:',required:true">
            </div>
            <div style="margin-bottom:10px">
                <input id="plan_quantity" class="easyui-numberbox required-field" style="width:95%"
                       data-options="label:'计划数量 *:',required:true,min:1,precision:0">
            </div>
            <div style="margin-bottom:10px">
                <input id="plan_price" class="easyui-numberbox required-field" style="width:95%"
                       data-options="label:'计划单价 *:',required:true,min:0,precision:2">
            </div>
            <div>
                <input id="remark" class="easyui-textbox" style="width:95%"
                       data-options="label:'备注:'">
            </div>
        </form>
    </div>
    <div id="dlgItemBtns">
        <a id="btnSaveItem" href="javascript:void(0)" class="easyui-linkbutton"
           data-options="iconCls:'icon-save'">保存</a>
        <a href="javascript:void(0)" class="easyui-linkbutton"
           data-options="iconCls:'icon-back'" onclick="$('#dlgItem').dialog('close')">取消</a>
    </div>
</div>

