package com.entity;

public class Employment {
    private int employmentId; // 就业信息ID(主键)
    private int studentId; // 学生ID
    private int employmentType; // 就业类型
    private String companyName; // 单位名称
    private String jobPosition; // 职位
    private Integer companyNature; // 单位性质
    private String workCity; // 工作城市
    private String employmentTime; // 就业时间
    private String contactPhone; // 单位联系电话
    private String auditStatus; // 审核状态
    private String auditOpinion; // 审核意见
    private Integer auditorId; // 审核人ID
    private String auditTime; // 审核时间


    // 添加关联字段（不映射到数据库，仅用于前端显示）
    private String studentNumber;
    private String studentName;
    private String className;
    private String employmentTypeName; // 就业类型名称
    private String companyNatureName; // 单位性质名称

    // 必须有无参构造函数
    public Employment() {}


    // 生成对应的getter和setter方法

    public String getStudentNumber() {
        return studentNumber;
    }

    public String getClassName() {
        return className;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public void setStudentNumber(String studentNumber) {
        this.studentNumber = studentNumber;
    }

    public String getEmploymentTypeName() {
        return employmentTypeName;
    }

    public void setEmploymentTypeName(String employmentTypeName) {
        this.employmentTypeName = employmentTypeName;
    }

    public String getCompanyNatureName() {
        return companyNatureName;
    }

    public void setCompanyNatureName(String companyNatureName) {
        this.companyNatureName = companyNatureName;
    }


    public int getEmploymentId() {
        return employmentId;
    }

    public void setEmploymentId(int employmentId) {
        this.employmentId = employmentId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public int getEmploymentType() {
        return employmentType;
    }

    public void setEmploymentType(int employmentType) {
        this.employmentType = employmentType;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getJobPosition() {
        return jobPosition;
    }

    public void setJobPosition(String jobPosition) {
        this.jobPosition = jobPosition;
    }

    public Integer getCompanyNature() {
        return companyNature;
    }

    public void setCompanyNature(Integer companyNature) {
        this.companyNature = companyNature;
    }


    public String getWorkCity() {
        return workCity;
    }

    public void setWorkCity(String workCity) {
        this.workCity = workCity;
    }

    public String getEmploymentTime() {
        return employmentTime;
    }

    public void setEmploymentTime(String employmentTime) {
        this.employmentTime = employmentTime;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getAuditStatus() {
        return auditStatus;
    }

    public void setAuditStatus(String auditStatus) {
        this.auditStatus = auditStatus;
    }

    public String getAuditOpinion() {
        return auditOpinion;
    }

    public void setAuditOpinion(String auditOpinion) {
        this.auditOpinion = auditOpinion;
    }

    public Integer getAuditorId() {
        return auditorId;
    }

    public void setAuditorId(Integer auditorId) {
        this.auditorId = auditorId;
    }

    public String getAuditTime() {
        return auditTime;
    }

    public void setAuditTime(String auditTime) {
        this.auditTime = auditTime;
    }



    @Override
    public String toString() {
        return "Employment{" +
                "employmentId=" + employmentId +
                ", studentId=" + studentId +
                ", employmentType=" + employmentType +
                ", companyName='" + companyName + '\'' +
                ", jobPosition='" + jobPosition + '\'' +
                ", companyNature=" + companyNature +
                ", workCity='" + workCity + '\'' +
                ", employmentTime='" + employmentTime + '\'' +
                ", contactPhone='" + contactPhone + '\'' +
                ", auditStatus='" + auditStatus + '\'' +
                ", auditOpinion='" + auditOpinion + '\'' +
                ", auditorId=" + auditorId +
                ", auditTime='" + auditTime + '\'' +
                '}';
    }
}