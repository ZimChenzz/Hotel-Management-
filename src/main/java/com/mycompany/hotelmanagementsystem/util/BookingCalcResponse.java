package com.mycompany.hotelmanagementsystem.util;

import com.mycompany.hotelmanagementsystem.entity.Promotion;
import com.mycompany.hotelmanagementsystem.entity.Room;
import com.mycompany.hotelmanagementsystem.entity.RoomType;
import com.mycompany.hotelmanagementsystem.entity.Voucher;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class BookingCalcResponse {
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private RoomType roomType;
    private Room room;
    private LocalDateTime checkIn;
    private LocalDateTime checkOut;
    private long nights;
    private BigDecimal subtotal;
    private Promotion promotion;        // active promotion (null if none)
    private BigDecimal promotionDiscount; // calculated promotion discount amount
    private BigDecimal discount;        // voucher discount
    private BigDecimal total;
    private Voucher voucher;
    private BigDecimal depositPercent;
    private BigDecimal depositAmount;
    private boolean standardRoom;
    private BigDecimal pricePerHour;
    private BigDecimal earlySurcharge;
    private BigDecimal lateSurcharge;
    private long earlyHours;
    private long lateHours;
    private boolean sameDayBooking;
    private long totalHours;           // for same-day bookings
    private BigDecimal surchargeTotal;

    public RoomType getRoomType() { return roomType; }
    public void setRoomType(RoomType roomType) { this.roomType = roomType; }
    public Room getRoom() { return room; }
    public void setRoom(Room room) { this.room = room; }
    public LocalDateTime getCheckIn() { return checkIn; }
    public void setCheckIn(LocalDateTime checkIn) { this.checkIn = checkIn; }
    public LocalDateTime getCheckOut() { return checkOut; }
    public void setCheckOut(LocalDateTime checkOut) { this.checkOut = checkOut; }
    public long getNights() { return nights; }
    public void setNights(long nights) { this.nights = nights; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    public Promotion getPromotion() { return promotion; }
    public void setPromotion(Promotion promotion) { this.promotion = promotion; }
    public BigDecimal getPromotionDiscount() { return promotionDiscount; }
    public void setPromotionDiscount(BigDecimal promotionDiscount) { this.promotionDiscount = promotionDiscount; }
    public BigDecimal getDiscount() { return discount; }
    public void setDiscount(BigDecimal discount) { this.discount = discount; }
    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
    public Voucher getVoucher() { return voucher; }
    public void setVoucher(Voucher voucher) { this.voucher = voucher; }
    public BigDecimal getDepositPercent() { return depositPercent; }
    public void setDepositPercent(BigDecimal depositPercent) { this.depositPercent = depositPercent; }
    public BigDecimal getDepositAmount() { return depositAmount; }
    public void setDepositAmount(BigDecimal depositAmount) { this.depositAmount = depositAmount; }
    public boolean isStandardRoom() { return standardRoom; }
    public void setStandardRoom(boolean standardRoom) { this.standardRoom = standardRoom; }
    public BigDecimal getPricePerHour() { return pricePerHour; }
    public void setPricePerHour(BigDecimal pricePerHour) { this.pricePerHour = pricePerHour; }

    public BigDecimal getEarlySurcharge() { return earlySurcharge; }
    public void setEarlySurcharge(BigDecimal earlySurcharge) { this.earlySurcharge = earlySurcharge; }
    public BigDecimal getLateSurcharge() { return lateSurcharge; }
    public void setLateSurcharge(BigDecimal lateSurcharge) { this.lateSurcharge = lateSurcharge; }
    public long getEarlyHours() { return earlyHours; }
    public void setEarlyHours(long earlyHours) { this.earlyHours = earlyHours; }
    public long getLateHours() { return lateHours; }
    public void setLateHours(long lateHours) { this.lateHours = lateHours; }
    public boolean isSameDayBooking() { return sameDayBooking; }
    public void setSameDayBooking(boolean sameDayBooking) { this.sameDayBooking = sameDayBooking; }
    public long getTotalHours() { return totalHours; }
    public void setTotalHours(long totalHours) { this.totalHours = totalHours; }
    public BigDecimal getSurchargeTotal() { return surchargeTotal; }
    public void setSurchargeTotal(BigDecimal surchargeTotal) { this.surchargeTotal = surchargeTotal; }

    // Formatted date getters for JSP
    public String getCheckInFormatted() {
        return checkIn != null ? checkIn.format(DATE_FORMATTER) : "";
    }
    public String getCheckOutFormatted() {
        return checkOut != null ? checkOut.format(DATE_FORMATTER) : "";
    }
}
