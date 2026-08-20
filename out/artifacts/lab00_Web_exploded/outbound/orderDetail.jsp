<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>出库明细</title>
    <link rel="stylesheet" type="text/css" href="static/plugins/jquery-easyui-1.9.14/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="static/plugins/jquery-easyui-1.9.14/themes/icon.css">
    <script src="static/plugins/jquery-easyui-1.9.14/jquery.min.js"></script>
    <script src="static/plugins/jquery-easyui-1.9.14/jquery.easyui.min.js"></script>
    <style>
        body { font-family: "微软雅黑", sans-serif; margin: 10px; }
        .info-bar { margin-bottom: 15px; padding: 10px; background: #f5f7fa; border-radius: 4px; border-left: 3px solid #1976d2; }
        .info-label { font-weight: bold; color: #607d8b; margin-right: 5px; }
        .info-value { color: #37474f; }
    </style>
</head>
<body>
<%
    String orderId = request.getParameter("orderId");
%>
<div class="info-bar">
    <span class="info-label">出库单号：</span><span class="info-value"><%= orderId %></span>
</div>
<table id="detailTable" class="easyui-datagrid" fit="true" rownumbers="true" striped="true"
       pagination="false" singleSelect="true" toolbar="#tb">
    <thead>
        <tr>
            <th field="consumable_name" width="200">耗材名称</th>
            <th field="unit" width="80" align="center">单位</th>
            <th field="quantity" width="100" align="center">数量</th>
            <th field="is_dangerous" width="80" align="center" formatter="formatDanger">危化品</th>
            <th field="remark" width="250">备注</th>
        </tr>
    </thead>
</table>

<script type="text/javascript">
    var ctx = '${pageContext.request.contextPath}';
    var orderId = '<%= orderId %>';
    
    function formatDanger(val) {
        return val == 1 ? '<span style="color:#e53935;font-weight:bold">是</span>' : '<span style="color:#90a4ae">否</span>';
    }
    
    $(function() {
        // 加载明细数据
        $('#detailTable').datagrid({
            url: ctx + '/ServletOutbound?action=getItems',
            method: 'get',
            queryParams: { outbound_id: orderId },
            emptyMsg: '暂无明细数据'
        });
    });
</script>
</body>
</html>
