package com.mycompany.hotelmanagementsystem.entity;

import java.math.BigDecimal;

public class Voucher {
    private int voucherId;
    private String code;
    private BigDecimal discountAmount;
    private BigDecimal minOrderValue;
    private boolean isActive;

    public Voucher() {}

    public int getVoucherId() { return voucherId; }
    public void setVoucherId(int voucherId) { this.voucherId = voucherId; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }
    public BigDecimal getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(BigDecimal minOrderValue) { this.minOrderValue = minOrderValue; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
