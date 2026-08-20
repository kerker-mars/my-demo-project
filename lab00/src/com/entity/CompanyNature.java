package com.entity;

public class CompanyNature {
    private int natureId; // 性质ID(主键)
    private String natureName; // 单位性质名称
    private String natureCode; // 性质代码

    public int getNatureId() {
        return natureId;
    }

    public void setNatureId(int natureId) {
        this.natureId = natureId;
    }

    public String getNatureName() {
        return natureName;
    }

    public void setNatureName(String natureName) {
        this.natureName = natureName;
    }

    public String getNatureCode() {
        return natureCode;
    }

    public void setNatureCode(String natureCode) {
        this.natureCode = natureCode;
    }

    @Override
    public String toString() {
        return "CompanyNature{" +
                "natureId=" + natureId +
                ", natureName='" + natureName + '\'' +
                ", natureCode='" + natureCode + '\'' +
                '}';
    }
}