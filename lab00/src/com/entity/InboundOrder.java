package com.entity;

import java.time.LocalDateTime;

public class InboundOrder {
    private Integer id;
    private Integer plan_id;
    private Integer lab_id;
    private Integer inbound_user_id;
    private String supplier;
    private LocalDateTime inbound_time;
    private Integer status;

    // 展示用
    private String lab_name;
    private String inbound_user_name;
    private String plan_code; // 可选

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getPlan_id() { return plan_id; }
    public void setPlan_id(Integer plan_id) { this.plan_id = plan_id; }

    public Integer getLab_id() { return lab_id; }
    public void setLab_id(Integer lab_id) { this.lab_id = lab_id; }

    public Integer getInbound_user_id() { return inbound_user_id; }
    public void setInbound_user_id(Integer inbound_user_id) { this.inbound_user_id = inbound_user_id; }

    public String getSupplier() { return supplier; }
    public void setSupplier(String supplier) { this.supplier = supplier; }

    public LocalDateTime getInbound_time() { return inbound_time; }
    public void setInbound_time(LocalDateTime inbound_time) { this.inbound_time = inbound_time; }

    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }

    public String getLab_name() { return lab_name; }
    public void setLab_name(String lab_name) { this.lab_name = lab_name; }

    public String getInbound_user_name() { return inbound_user_name; }
    public void setInbound_user_name(String inbound_user_name) { this.inbound_user_name = inbound_user_name; }

    public String getPlan_code() { return plan_code; }
    public void setPlan_code(String plan_code) { this.plan_code = plan_code; }
}