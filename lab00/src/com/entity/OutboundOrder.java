package com.entity;

import java.time.LocalDateTime;

/**
 * 对应表：outbound_order（领用申请/出库单）
 */
public class OutboundOrder {
    private Integer id;
    private Integer lab_id;
    private Integer apply_user_id;
    private String course_name;
    private String class_name;
    private String purpose;
    private Integer status;
    private LocalDateTime create_time;
    private Integer audit_user_id;
    private LocalDateTime audit_time;
    private Integer second_audit_user_id;
    private LocalDateTime second_audit_time;
    private String reject_reason;

    // 便于列表展示（非表字段，可为空）
    private String apply_user_name;
    private String lab_name;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getLab_id() {
        return lab_id;
    }

    public void setLab_id(Integer lab_id) {
        this.lab_id = lab_id;
    }

    public Integer getApply_user_id() {
        return apply_user_id;
    }

    public void setApply_user_id(Integer apply_user_id) {
        this.apply_user_id = apply_user_id;
    }

    public String getCourse_name() {
        return course_name;
    }

    public void setCourse_name(String course_name) {
        this.course_name = course_name;
    }

    public String getClass_name() {
        return class_name;
    }

    public void setClass_name(String class_name) {
        this.class_name = class_name;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public LocalDateTime getCreate_time() {
        return create_time;
    }

    public void setCreate_time(LocalDateTime create_time) {
        this.create_time = create_time;
    }

    public Integer getAudit_user_id() {
        return audit_user_id;
    }

    public void setAudit_user_id(Integer audit_user_id) {
        this.audit_user_id = audit_user_id;
    }

    public LocalDateTime getAudit_time() {
        return audit_time;
    }

    public void setAudit_time(LocalDateTime audit_time) {
        this.audit_time = audit_time;
    }

    public Integer getSecond_audit_user_id() {
        return second_audit_user_id;
    }

    public void setSecond_audit_user_id(Integer second_audit_user_id) {
        this.second_audit_user_id = second_audit_user_id;
    }

    public LocalDateTime getSecond_audit_time() {
        return second_audit_time;
    }

    public void setSecond_audit_time(LocalDateTime second_audit_time) {
        this.second_audit_time = second_audit_time;
    }

    public String getReject_reason() {
        return reject_reason;
    }

    public void setReject_reason(String reject_reason) {
        this.reject_reason = reject_reason;
    }

    public String getApply_user_name() {
        return apply_user_name;
    }

    public void setApply_user_name(String apply_user_name) {
        this.apply_user_name = apply_user_name;
    }

    public String getLab_name() {
        return lab_name;
    }

    public void setLab_name(String lab_name) {
        this.lab_name = lab_name;
    }
}
