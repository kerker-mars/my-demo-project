package com.entity;

/**
 * 对应表：outbound_item（领用明细）
 */
public class OutboundItem {
    private Integer id;
    private Integer outbound_id;
    private Integer consumable_id;
    private Integer quantity;
    private Integer should_return;
    private String remark;

    // 便于列表展示（非表字段）
    private String consumable_name;
    private String unit;
    private Integer is_dangerous;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getOutbound_id() { return outbound_id; }
    public void setOutbound_id(Integer outbound_id) { this.outbound_id = outbound_id; }
    public Integer getConsumable_id() { return consumable_id; }
    public void setConsumable_id(Integer consumable_id) { this.consumable_id = consumable_id; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public Integer getShould_return() { return should_return; }
    public void setShould_return(Integer should_return) { this.should_return = should_return; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public String getConsumable_name() { return consumable_name; }
    public void setConsumable_name(String consumable_name) { this.consumable_name = consumable_name; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public Integer getIs_dangerous() { return is_dangerous; }
    public void setIs_dangerous(Integer is_dangerous) { this.is_dangerous = is_dangerous; }
}

