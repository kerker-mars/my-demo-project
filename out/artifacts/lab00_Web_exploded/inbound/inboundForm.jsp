<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="easyui-layout" data-options="fit:true">
    <div data-options="region:'north',border:false" style="height:90px;padding:5px">
        <div style="margin-bottom:10px">
            <input id="inb_plan_id" class="easyui-combobox required-field" style="width:360px"
                   data-options="label:'采购计划 *:',required:true">
        </div>
        <div>
            <input id="inb_supplier" class="easyui-textbox" style="width:360px"
                   data-options="label:'供应商:'">
        </div>
    </div>
    <div data-options="region:'center',border:false">
        <table id="dgInboundItem"></table>
    </div>

    <div id="tbInboundItem" style="height:auto;padding:5px">
        <a id="btnAddItem" href="javascript:void(0)" class="easyui-linkbutton"
           data-options="iconCls:'icon-add',plain:true">添加明细</a>
        <a id="btnRemoveItem" href="javascript:void(0)" class="easyui-linkbutton"
           data-options="iconCls:'icon-remove',plain:true">删除明细</a>
    </div>

    <div id="dlgItem" class="easyui-dialog" title="入库明细"
         style="width:580px;height:320px;padding:10px"
         data-options="closed:true,modal:true,buttons:'#dlgItemBtns'">
        <form id="ffItem" method="post">
            <div style="margin-bottom:10px">
                <input id="inb_consumable_id" class="easyui-combobox required-field" style="width:95%"
                       data-options="label:'耗材 *:',required:true">
            </div>
            <div style="margin-bottom:10px">
                <input id="inb_quantity" class="easyui-numberbox required-field" style="width:95%"
                       data-options="label:'入库数量 *:',required:true,min:1,precision:0">
            </div>
            <div style="margin-bottom:10px">
                <input id="inb_unit_price" class="easyui-numberbox required-field" style="width:95%"
                       data-options="label:'单价 *:',required:true,min:0,precision:2">
            </div>
            <div style="margin-bottom:10px">
                <input id="inb_batch_no" class="easyui-textbox" style="width:95%"
                       data-options="label:'批次号:'">
            </div>
            <div style="margin-bottom:10px">
                <input id="inb_product_date" class="easyui-datebox" style="width:95%"
                       data-options="label:'生产日期:'">
            </div>
            <div style="margin-bottom:10px">
                <input id="inb_expire_date" class="easyui-datebox" style="width:95%"
                       data-options="label:'失效日期:'">
            </div>
            <div>
                <input id="inb_remark" class="easyui-textbox" style="width:95%"
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

