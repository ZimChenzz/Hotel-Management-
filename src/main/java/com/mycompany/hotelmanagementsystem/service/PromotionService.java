package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.entity.Promotion;
import com.mycompany.hotelmanagementsystem.dal.PromotionRepository;

/**
 * Shared service for customer-facing and booking promotion lookups.
 * Used by RoomController (display badges) and BookingService (discount calc).
 */
public class PromotionService {
    private final PromotionRepository promotionRepository;

    public PromotionService() {
        this.promotionRepository = new PromotionRepository();
    }

    /**
     * Get the currently active promotion for a room type.
     * Returns null if no active promotion exists.
     */
    public Promotion getActivePromotion(int typeId) {
        return promotionRepository.findActiveByTypeId(typeId);
    }
}
