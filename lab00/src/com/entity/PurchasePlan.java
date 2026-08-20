package com.entity;

import java.time.LocalDateTime;

public class PurchasePlan {
    private Integer id;
    private Integer lab_id;
    private Integer apply_user_id;
    private java.math.BigDecimal total_amount;
    private Integer status;
    private LocalDateTime create_time;
    private Integer audit_user_id;
    private LocalDateTime audit_time;
    private String audit_comment;

    // 展示用字段（非表字段）
    private String lab_name;
    private String apply_user_name;
    private String audit_user_name;

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

    public java.math.BigDecimal getTotal_amount() {
        return total_amount;
    }

    public void setTotal_amount(java.math.BigDecimal total_amount) {
        this.total_amount = total_amount;
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

    public String getAudit_comment() {
        return audit_comment;
    }

    public void setAudit_comment(String audit_comment) {
        this.audit_comment = audit_comment;
    }

    public String getLab_name() {
        return lab_name;
    }

    public void setLab_name(String lab_name) {
        this.lab_name = lab_name;
    }

    public String getApply_user_name() {
        return apply_user_name;
    }

    public void setApply_user_name(String apply_user_name) {
        this.apply_user_name = apply_user_name;
    }

    public String getAudit_user_name() {
        return audit_user_name;
    }

    public void setAudit_user_name(String audit_user_name) {
        this.audit_user_name = audit_user_name;
    }
}