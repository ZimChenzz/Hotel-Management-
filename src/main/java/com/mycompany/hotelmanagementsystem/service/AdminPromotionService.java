package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.entity.Promotion;
import com.mycompany.hotelmanagementsystem.entity.RoomType;
import com.mycompany.hotelmanagementsystem.dal.PromotionRepository;
import com.mycompany.hotelmanagementsystem.dal.RoomTypeRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class AdminPromotionService {
    private final PromotionRepository promotionRepository;
    private final RoomTypeRepository roomTypeRepository;

    public AdminPromotionService() {
        this.promotionRepository = new PromotionRepository();
        this.roomTypeRepository = new RoomTypeRepository();
    }

    public List<Promotion> getAllPromotions() {
        return promotionRepository.findAll();
    }

    public Promotion getPromotionById(int promotionId) {
        return promotionRepository.findById(promotionId);
    }

    public List<RoomType> getAllRoomTypes() {
        return roomTypeRepository.findAll();
    }

    /**
     * Create a new promotion. Returns generated promotion_id on success, -1 on validation failure.
     */
    public int createPromotion(int typeId, String promoCode, BigDecimal discountPercent,
                               LocalDate startDate, LocalDate endDate) {
        if (!isValidInput(typeId, discountPercent, startDate, endDate)) return -1;

        Promotion p = new Promotion();
        p.setTypeId(typeId);
        p.setPromoCode(promoCode.toUpperCase().trim());
        p.setDiscountPercent(discountPercent);
        p.setStartDate(startDate);
        p.setEndDate(endDate);
        return promotionRepository.insert(p);
    }

    /**
     * Update existing promotion. Returns true on success.
     */
    public boolean updatePromotion(int promotionId, int typeId, String promoCode,
                                   BigDecimal discountPercent, LocalDate startDate, LocalDate endDate) {
        Promotion existing = promotionRepository.findById(promotionId);
        if (existing == null) return false;
        if (!isValidInput(typeId, discountPercent, startDate, endDate)) return false;

        existing.setTypeId(typeId);
        existing.setPromoCode(promoCode.toUpperCase().trim());
        existing.setDiscountPercent(discountPercent);
        existing.setStartDate(startDate);
        existing.setEndDate(endDate);
        return promotionRepository.update(existing) > 0;
    }

    public boolean deletePromotion(int promotionId) {
        return promotionRepository.delete(promotionId) > 0;
    }

    private boolean isValidInput(int typeId, BigDecimal discountPercent,
                                  LocalDate startDate, LocalDate endDate) {
        if (discountPercent == null
                || discountPercent.compareTo(BigDecimal.ZERO) <= 0
                || discountPercent.compareTo(BigDecimal.valueOf(100)) > 0) {
            return false;
        }
        if (startDate == null || endDate == null || endDate.isBefore(startDate)) {
            return false;
        }
        if (roomTypeRepository.findById(typeId) == null) {
            return false;
        }
        return true;
    }
}
