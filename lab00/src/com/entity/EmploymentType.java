package com.entity;

public class EmploymentType {
    private int typeId; // 类型ID(主键)
    private String typeName; // 就业类型名称
    private String typeCode; // 类型代码

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getTypeCode() {
        return typeCode;
    }

    public void setTypeCode(String typeCode) {
        this.typeCode = typeCode;
    }

    @Override
    public String toString() {
        return "EmploymentType{" +
                "typeId=" + typeId +
                ", typeName='" + typeName + '\'' +
                ", typeCode='" + typeCode + '\'' +
                '}';
    }
}