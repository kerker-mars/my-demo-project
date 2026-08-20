package com.entity;

/**
 * 对应表：consumable
 */
public class Consumable {
    private Integer id;
    private String name;
    private String category;
    private String spec;
    private String unit;
    private Integer is_dangerous;
    private String storage_require;
    private Integer validity_period;
    private Integer min_safe_stock;
    private Integer max_limit_stock;
    private String remark;
    private Integer returnable;

    public Integer getMin_safe_stock() {
        return min_safe_stock;
    }

    public void setMin_safe_stock(Integer min_safe_stock) {
        this.min_safe_stock = min_safe_stock;
    }

    public Integer getMax_limit_stock() {
        return max_limit_stock;
    }

    public void setMax_limit_stock(Integer max_limit_stock) {
        this.max_limit_stock = max_limit_stock;
    }

    public Integer getReturnable() {
        return returnable;
    }

    public void setReturnable(Integer returnable) {
        this.returnable = returnable;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getSpec() {
        return spec;
    }

    public void setSpec(String spec) {
        this.spec = spec;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public Integer getIs_dangerous() {
        return is_dangerous;
    }

    public void setIs_dangerous(Integer is_dangerous) {
        this.is_dangerous = is_dangerous;
    }

    public String getStorage_require() {
        return storage_require;
    }

    public void setStorage_require(String storage_require) {
        this.storage_require = storage_require;
    }

    public Integer getValidity_period() {
        return validity_period;
    }

    public void setValidity_period(Integer validity_period) {
        this.validity_period = validity_period;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
