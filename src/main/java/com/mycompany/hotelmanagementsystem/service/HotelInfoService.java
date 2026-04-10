package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.dal.HotelInfoRepository;
import com.mycompany.hotelmanagementsystem.entity.HotelInfo;

/**
 * Service layer for hotel info management.
 * Handles business logic for the singleton hotel info record.
 */
public class HotelInfoService {
    private final HotelInfoRepository hotelInfoRepository;

    public HotelInfoService() {
        this.hotelInfoRepository = new HotelInfoRepository();
    }

    /**
     * Get hotel info. Creates default row if none exists.
     */
    public HotelInfo getHotelInfo() {
        HotelInfo info = hotelInfoRepository.findFirst();
        if (info == null) {
            hotelInfoRepository.insertDefault();
            info = hotelInfoRepository.findFirst();
        }
        return info;
    }

    /**
     * Update hotel info from form parameters.
     * Returns true if update succeeded.
     */
    public boolean updateHotelInfo(HotelInfo info) {
        try {
            // Ensure row exists
            HotelInfo existing = hotelInfoRepository.findFirst();
            if (existing == null) {
                hotelInfoRepository.insertDefault();
                existing = hotelInfoRepository.findFirst();
            }
            info.setInfoId(existing.getInfoId());
            return hotelInfoRepository.update(info) > 0;
        } catch (Exception e) {
            throw new RuntimeException("Failed to update hotel info", e);
        }
    }
}
