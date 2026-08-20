<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script>
    // 自定义验证规则
    $.extend($.fn.validatebox.defaults.rules, {
        phone: {
            validator: function(value){
                return /^[\d\-()+\s]{0,20}$/.test(value) || value === '';
            },
            message: '请输入正确的电话号码格式'
        }
    });

    // 清除所有验证错误
    function clearAllValidation() {
        $('.validatebox-tip').remove();
        $('.validatebox-invalid').removeClass('validatebox-invalid');
    }

    $(document).ready(function() {
        // 初始化时禁用验证
        $('#ff').find('.validatebox-text').validatebox('disableValidation');

        // 如果是编辑模式，设置学生ID为只读
        if('edit' == '<%=request.getParameter("action")%>') {
            $('#studentId').textbox({
                readonly: true,
                required: true
            });
        }
    });

    // 移除原来的自动加载逻辑，改为在对话框onLoad中控制
</script>

<form id="ff" method="post" style="padding:5px;">
    <!-- 就业ID（编辑时显示） -->
    <div style="margin-bottom: 10px;display: none;">
        <input class="easyui-textbox" id="employmentId" name="employmentId" style="width:90%"
               data-options="label:'就业ID:', readonly:true">
    </div>

    <!-- 学生ID -->
    <div style="margin-bottom: 10px">
        <input class="easyui-textbox" id="studentId" name="studentId" style="width:90%"
               data-options="label:'学生ID:', required:true,
               validType: {
                   remote: ['${pageContext.request.contextPath}/ServletEmploymentInfo?action=existsStudent','studentId']
               }, invalidMessage:'学生不存在或已录入就业信息！'">
    </div>

    <!-- 就业类型 -->
    <div style="margin-bottom: 10px">
        <select class="easyui-combobox" name="employmentType" style="width:90%"
                data-options="label:'就业类型:', required:true, editable:false">
            <option value="1">正式就业</option>
            <option value="2">灵活就业</option>
            <option value="3">自主创业</option>
            <option value="4">升学</option>
            <option value="5">出国</option>
            <option value="6">未就业</option>
        </select>
    </div>

    <!-- 单位名称 -->
    <div style="margin-bottom: 10px">
        <input class="easyui-textbox" name="companyName" style="width:90%"
               data-options="label:'单位名称:', required:true, validType:'length[2,200]'">
    </div>

    <!-- 职位 -->
    <div style="margin-bottom: 10px">
        <input class="easyui-textbox" name="jobPosition" style="width:90%"
               data-options="label:'职位:', required:false, validType:'length[0,100]'">
    </div>

    <!-- 单位性质 -->
    <div style="margin-bottom: 10px">
        <select class="easyui-combobox" name="companyNature" style="width:90%"
                data-options="label:'单位性质:', required:false, editable:false">
            <option value="1">国有企业</option>
            <option value="2">民营企业</option>
            <option value="3">外资企业</option>
            <option value="4">政府机关</option>
            <option value="5">事业单位</option>
            <option value="6">其他</option>
        </select>
    </div>

    <!-- 工作城市 -->
    <div style="margin-bottom: 10px">
        <input class="easyui-textbox" name="workCity" style="width:90%"
               data-options="label:'工作城市:', required:false, validType:'length[0,100]'">
    </div>

    <!-- 就业时间 - 修复样式一致性 -->
    <div style="margin-bottom: 10px">
        <input class="easyui-datebox" name="employmentTime" style="width:90%"
               data-options="label:'就业时间:', required:true, editable:false">
    </div>

    <!-- 单位联系电话 -->
    <div style="margin-bottom: 10px">
        <input class="easyui-textbox" name="contactPhone" style="width:90%"
               data-options="label:'单位联系电话:', required:false, validType:'phone'">
    </div>

    <!-- 审核状态 -->
    <div style="margin-bottom: 10px">
        <select class="easyui-combobox" name="auditStatus" style="width:90%"
                data-options="label:'审核状态:', required:true, editable:false">
            <option value="待审核">待审核</option>
            <option value="通过">通过</option>
            <option value="驳回">驳回</option>
        </select>
    </div>

    <!-- 审核意见 -->
    <div style="margin-bottom: 10px">
        <input class="easyui-textbox" name="auditOpinion" style="width:90%;height:60px"
               data-options="label:'审核意见:', required:false, multiline:true, validType:'length[0,500]'">
    </div>

    <!-- 审核人ID -->
    <div style="margin-bottom: 10px">
        <input class="easyui-textbox" name="auditorId" style="width:90%"
               data-options="label:'审核人ID:', required:false, validType:'number'">
    </div>

    <!-- 审核时间 - 修复样式一致性 -->
    <div style="margin-bottom: 10px">
        <input class="easyui-datetimebox" name="auditTime" style="width:90%"
               data-options="label:'审核时间:', required:false, editable:false, showSeconds:true">
    </div>
</form>