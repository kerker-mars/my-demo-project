package com.entity;

import java.math.BigDecimal;

public class PurchasePlanItem {
    private Integer id;
    private Integer plan_id;
    private Integer consumable_id;
    private Integer plan_quantity;
    private BigDecimal plan_price;
    private String remark;

    // 展示用
    private String consumable_name;
    private String unit;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getPlan_id() { return plan_id; }
    public void setPlan_id(Integer plan_id) { this.plan_id = plan_id; }

    public Integer getConsumable_id() { return consumable_id; }
    public void setConsumable_id(Integer consumable_id) { this.consumable_id = consumable_id; }

    public Integer getPlan_quantity() { return plan_quantity; }
    public void setPlan_quantity(Integer plan_quantity) { this.plan_quantity = plan_quantity; }

    public BigDecimal getPlan_price() { return plan_price; }
    public void setPlan_price(BigDecimal plan_price) { this.plan_price = plan_price; }

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }

    public String getConsumable_name() { return consumable_name; }
    public void setConsumable_name(String consumable_name) { this.consumable_name = consumable_name; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
}