package com.mycompany.hotelmanagementsystem.entity;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Promotion {
    private int promotionId;
    private int typeId;
    private String promoCode;
    private BigDecimal discountPercent;
    private LocalDate startDate;
    private LocalDate endDate;

    // Transient field populated by JOIN queries (not a DB column)
    private String typeName;

    public Promotion() {}

    public int getPromotionId() { return promotionId; }
    public void setPromotionId(int promotionId) { this.promotionId = promotionId; }
    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public String getPromoCode() { return promoCode; }
    public void setPromoCode(String promoCode) { this.promoCode = promoCode; }
    public BigDecimal getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(BigDecimal discountPercent) { this.discountPercent = discountPercent; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }

    // Derived status from date range at runtime - no DB column needed
    public String getStatus() {
        LocalDate today = LocalDate.now();
        if (today.isBefore(startDate)) return "upcoming";
        if (today.isAfter(endDate)) return "expired";
        return "active";
    }

    public boolean isActive() {
        return "active".equals(getStatus());
    }
}
