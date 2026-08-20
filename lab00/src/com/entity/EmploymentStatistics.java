package com.entity;

public class EmploymentStatistics {
    private int statId; // 统计ID(主键)
    private int classId; // 班级ID
    private String statDate; // 统计日期
    private int totalStudents; // 总学生数
    private int employedCount; // 已就业人数
    private int unemployedCount; // 未就业人数
    private int furtherStudyCount; // 深造人数
    private Double employmentRate; // 就业率
    private String createTime; // 创建时间

    public int getStatId() {
        return statId;
    }

    public void setStatId(int statId) {
        this.statId = statId;
    }

    public int getClassId() {
        return classId;
    }

    public void setClassId(int classId) {
        this.classId = classId;
    }

    public String getStatDate() {
        return statDate;
    }

    public void setStatDate(String statDate) {
        this.statDate = statDate;
    }

    public int getTotalStudents() {
        return totalStudents;
    }

    public void setTotalStudents(int totalStudents) {
        this.totalStudents = totalStudents;
    }

    public int getEmployedCount() {
        return employedCount;
    }

    public void setEmployedCount(int employedCount) {
        this.employedCount = employedCount;
    }

    public int getUnemployedCount() {
        return unemployedCount;
    }

    public void setUnemployedCount(int unemployedCount) {
        this.unemployedCount = unemployedCount;
    }

    public int getFurtherStudyCount() {
        return furtherStudyCount;
    }

    public void setFurtherStudyCount(int furtherStudyCount) {
        this.furtherStudyCount = furtherStudyCount;
    }

    public Double getEmploymentRate() {
        return employmentRate;
    }

    public void setEmploymentRate(Double employmentRate) {
        this.employmentRate = employmentRate;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    @Override
    public String toString() {
        return "EmploymentStatistics{" +
                "statId=" + statId +
                ", classId=" + classId +
                ", statDate='" + statDate + '\'' +
                ", totalStudents=" + totalStudents +
                ", employedCount=" + employedCount +
                ", unemployedCount=" + unemployedCount +
                ", furtherStudyCount=" + furtherStudyCount +
                ", employmentRate=" + employmentRate +
                ", createTime='" + createTime + '\'' +
                '}';
    }
}