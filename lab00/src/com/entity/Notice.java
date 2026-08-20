package com.entity;

import java.time.LocalDateTime;

public class Notice {
    private Integer noticeId; // 公告ID，主键自增
    private String title; // 公告标题
    private String content; // 公告内容
    private Integer publisherId; // 发布人ID
    private LocalDateTime publishTime; // 发布时间
    private LocalDateTime expireTime; // 过期时间
    private String status; // 状态：已发布、草稿、已过期

    // 无参构造
    public Notice() {
    }

    // getter和setter方法
    public Integer getNoticeId() {
        return noticeId;
    }

    public void setNoticeId(Integer noticeId) {
        this.noticeId = noticeId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Integer getPublisherId() {
        return publisherId;
    }

    public void setPublisherId(Integer publisherId) {
        this.publisherId = publisherId;
    }

    public LocalDateTime getPublishTime() {
        return publishTime;
    }

    public void setPublishTime(LocalDateTime publishTime) {
        this.publishTime = publishTime;
    }

    public LocalDateTime getExpireTime() {
        return expireTime;
    }

    public void setExpireTime(LocalDateTime expireTime) {
        this.expireTime = expireTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // toString方法
    @Override
    public String toString() {
        return "Notice{" +
                "noticeId=" + noticeId +
                ", title='" + title + '\'' +
                ", content='" + content + '\'' +
                ", publisherId=" + publisherId +
                ", publishTime=" + publishTime +
                ", expireTime=" + expireTime +
                ", status='" + status + '\'' +
                '}';
    }
}