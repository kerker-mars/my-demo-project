package com.entity;

public class SystemLog {
    private int logId; // 日志ID(主键)
    private int userId; // 操作人ID
    private String operationType; // 操作类型
    private String operationContent; // 操作内容
    private String ipAddress; // IP地址
    private String operationTime; // 操作时间

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getOperationType() {
        return operationType;
    }

    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }

    public String getOperationContent() {
        return operationContent;
    }

    public void setOperationContent(String operationContent) {
        this.operationContent = operationContent;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getOperationTime() {
        return operationTime;
    }

    public void setOperationTime(String operationTime) {
        this.operationTime = operationTime;
    }

    @Override
    public String toString() {
        return "SystemLog{" +
                "logId=" + logId +
                ", userId=" + userId +
                ", operationType='" + operationType + '\'' +
                ", operationContent='" + operationContent + '\'' +
                ", ipAddress='" + ipAddress + '\'' +
                ", operationTime='" + operationTime + '\'' +
                '}';
    }
}