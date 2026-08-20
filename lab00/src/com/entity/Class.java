package com.entity;

public class Class {
    private int classId; // 班级ID(主键)
    private String className; // 班级名称
    private String classCode; // 班级代码
    private int majorId; // 所属专业
    private int counselorId; // 辅导员ID
    private int studentCount; // 学生人数

    public int getClassId() {
        return classId;
    }

    public void setClassId(int classId) {
        this.classId = classId;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public String getClassCode() {
        return classCode;
    }

    public void setClassCode(String classCode) {
        this.classCode = classCode;
    }

    public int getMajorId() {
        return majorId;
    }

    public void setMajorId(int majorId) {
        this.majorId = majorId;
    }

    public int getCounselorId() {
        return counselorId;
    }

    public void setCounselorId(int counselorId) {
        this.counselorId = counselorId;
    }

    public int getStudentCount() {
        return studentCount;
    }

    public void setStudentCount(int studentCount) {
        this.studentCount = studentCount;
    }

    @Override
    public String toString() {
        return "Class{" +
                "classId=" + classId +
                ", className='" + className + '\'' +
                ", classCode='" + classCode + '\'' +
                ", majorId=" + majorId +
                ", counselorId=" + counselorId +
                ", studentCount=" + studentCount +
                '}';
    }
}