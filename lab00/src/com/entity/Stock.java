package com.entity;

/**
 * 对应表：stock（实验室+耗材库存）
 */
public class Stock {
    private Integer id;
    private Integer lab_id;
    private Integer consumable_id;
    private Integer total_quantity;
    private Integer safe_quantity;
    private Integer warning_quantity;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getLab_id() { return lab_id; }
    public void setLab_id(Integer lab_id) { this.lab_id = lab_id; }
    public Integer getConsumable_id() { return consumable_id; }
    public void setConsumable_id(Integer consumable_id) { this.consumable_id = consumable_id; }
    public Integer getTotal_quantity() { return total_quantity; }
    public void setTotal_quantity(Integer total_quantity) { this.total_quantity = total_quantity; }
    public Integer getSafe_quantity() { return safe_quantity; }
    public void setSafe_quantity(Integer safe_quantity) { this.safe_quantity = safe_quantity; }
    public Integer getWarning_quantity() { return warning_quantity; }
    public void setWarning_quantity(Integer warning_quantity) { this.warning_quantity = warning_quantity; }
}

