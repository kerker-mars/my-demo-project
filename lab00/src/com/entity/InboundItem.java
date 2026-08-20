package com.entity;

import java.math.BigDecimal;
import java.time.LocalDate;

public class InboundItem {
    private Integer id;
    private Integer inbound_id;
    private Integer consumable_id;
    private String batch_no;
    private Integer quantity;
    private BigDecimal unit_price;
    private LocalDate product_date;
    private LocalDate expire_date;

    // 展示用
    private String consumable_name;
    private String unit;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getInbound_id() { return inbound_id; }
    public void setInbound_id(Integer inbound_id) { this.inbound_id = inbound_id; }

    public Integer getConsumable_id() { return consumable_id; }
    public void setConsumable_id(Integer consumable_id) { this.consumable_id = consumable_id; }

    public String getBatch_no() { return batch_no; }
    public void setBatch_no(String batch_no) { this.batch_no = batch_no; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public BigDecimal getUnit_price() { return unit_price; }
    public void setUnit_price(BigDecimal unit_price) { this.unit_price = unit_price; }

    public LocalDate getProduct_date() { return product_date; }
    public void setProduct_date(LocalDate product_date) { this.product_date = product_date; }

    public LocalDate getExpire_date() { return expire_date; }
    public void setExpire_date(LocalDate expire_date) { this.expire_date = expire_date; }

    public String getConsumable_name() { return consumable_name; }
    public void setConsumable_name(String consumable_name) { this.consumable_name = consumable_name; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
}