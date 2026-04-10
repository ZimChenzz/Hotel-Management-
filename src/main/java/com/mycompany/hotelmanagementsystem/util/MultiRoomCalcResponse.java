package com.mycompany.hotelmanagementsystem.util;

import com.mycompany.hotelmanagementsystem.entity.Voucher;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * DTO for multi-room booking price calculation.
 * Aggregates individual room calculations into one booking total.
 */
public class MultiRoomCalcResponse {
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private LocalDateTime checkIn;
    private LocalDateTime checkOut;
    private long nights;
    private List<BookingCalcResponse> roomCalcs;  // per-room calculations
    private BigDecimal subtotal;                   // sum of room subtotals
    private BigDecimal totalPromotionDiscount;     // sum of per-room promotions
    private BigDecimal voucherDiscount;            // applied once to total
    private Voucher voucher;
    private BigDecimal total;                      // final payable amount
    private BigDecimal depositAmount;
    private boolean allStandardRooms;              // true if all rooms have deposit=0
    private BigDecimal totalEarlySurcharge;
    private BigDecimal totalLateSurcharge;
    private BigDecimal totalSurcharges;
    private boolean sameDayBooking;

    public MultiRoomCalcResponse() {
        this.subtotal = BigDecimal.ZERO;
        this.totalPromotionDiscount = BigDecimal.ZERO;
        this.voucherDiscount = BigDecimal.ZERO;
        this.total = BigDecimal.ZERO;
        this.depositAmount = BigDecimal.ZERO;
        this.totalEarlySurcharge = BigDecimal.ZERO;
        this.totalLateSurcharge = BigDecimal.ZERO;
        this.totalSurcharges = BigDecimal.ZERO;
    }

    public LocalDateTime getCheckIn() { return checkIn; }
    public void setCheckIn(LocalDateTime checkIn) { this.checkIn = checkIn; }

    public LocalDateTime getCheckOut() { return checkOut; }
    public void setCheckOut(LocalDateTime checkOut) { this.checkOut = checkOut; }

    public long getNights() { return nights; }
    public void setNights(long nights) { this.nights = nights; }

    public List<BookingCalcResponse> getRoomCalcs() { return roomCalcs; }
    public void setRoomCalcs(List<BookingCalcResponse> roomCalcs) { this.roomCalcs = roomCalcs; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getTotalPromotionDiscount() { return totalPromotionDiscount; }
    public void setTotalPromotionDiscount(BigDecimal totalPromotionDiscount) { this.totalPromotionDiscount = totalPromotionDiscount; }

    public BigDecimal getVoucherDiscount() { return voucherDiscount; }
    public void setVoucherDiscount(BigDecimal voucherDiscount) { this.voucherDiscount = voucherDiscount; }

    public Voucher getVoucher() { return voucher; }
    public void setVoucher(Voucher voucher) { this.voucher = voucher; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public BigDecimal getDepositAmount() { return depositAmount; }
    public void setDepositAmount(BigDecimal depositAmount) { this.depositAmount = depositAmount; }

    public boolean isAllStandardRooms() { return allStandardRooms; }
    public void setAllStandardRooms(boolean allStandardRooms) { this.allStandardRooms = allStandardRooms; }

    public BigDecimal getTotalEarlySurcharge() { return totalEarlySurcharge; }
    public void setTotalEarlySurcharge(BigDecimal totalEarlySurcharge) { this.totalEarlySurcharge = totalEarlySurcharge; }

    public BigDecimal getTotalLateSurcharge() { return totalLateSurcharge; }
    public void setTotalLateSurcharge(BigDecimal totalLateSurcharge) { this.totalLateSurcharge = totalLateSurcharge; }

    public BigDecimal getTotalSurcharges() { return totalSurcharges; }
    public void setTotalSurcharges(BigDecimal totalSurcharges) { this.totalSurcharges = totalSurcharges; }

    public boolean isSameDayBooking() { return sameDayBooking; }
    public void setSameDayBooking(boolean sameDayBooking) { this.sameDayBooking = sameDayBooking; }

    // Formatted date getters for JSP
    public String getCheckInFormatted() {
        return checkIn != null ? checkIn.format(DATE_FORMATTER) : "";
    }

    public String getCheckOutFormatted() {
        return checkOut != null ? checkOut.format(DATE_FORMATTER) : "";
    }

    public int getTotalRoomCount() {
        return roomCalcs != null ? roomCalcs.size() : 0;
    }

    public String getVoucherCode() {
        return voucher != null ? voucher.getCode() : null;
    }
}
