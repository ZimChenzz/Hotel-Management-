package com.mycompany.hotelmanagementsystem.util;

import java.math.BigDecimal;

/**
 * DTO for early/late surcharge calculation results.
 * Early check-in before 14:00 and late check-out after 12:00 incur hourly surcharges.
 * Same-day bookings (nights=0) are charged entirely by hours.
 */
public class SurchargeResult {
    private long earlyHours;
    private BigDecimal earlySurcharge;
    private long lateHours;
    private BigDecimal lateSurcharge;
    private boolean sameDayBooking;
    private long totalHours;        // for same-day: total hours charged
    private BigDecimal hourlyTotal; // for same-day: totalHours x pricePerHour

    public SurchargeResult() {
        this.earlySurcharge = BigDecimal.ZERO;
        this.lateSurcharge = BigDecimal.ZERO;
        this.hourlyTotal = BigDecimal.ZERO;
    }

    public long getEarlyHours() { return earlyHours; }
    public void setEarlyHours(long earlyHours) { this.earlyHours = earlyHours; }

    public BigDecimal getEarlySurcharge() { return earlySurcharge; }
    public void setEarlySurcharge(BigDecimal earlySurcharge) { this.earlySurcharge = earlySurcharge; }

    public long getLateHours() { return lateHours; }
    public void setLateHours(long lateHours) { this.lateHours = lateHours; }

    public BigDecimal getLateSurcharge() { return lateSurcharge; }
    public void setLateSurcharge(BigDecimal lateSurcharge) { this.lateSurcharge = lateSurcharge; }

    public boolean isSameDayBooking() { return sameDayBooking; }
    public void setSameDayBooking(boolean sameDayBooking) { this.sameDayBooking = sameDayBooking; }

    public long getTotalHours() { return totalHours; }
    public void setTotalHours(long totalHours) { this.totalHours = totalHours; }

    public BigDecimal getHourlyTotal() { return hourlyTotal; }
    public void setHourlyTotal(BigDecimal hourlyTotal) { this.hourlyTotal = hourlyTotal; }

    public BigDecimal getSurchargeTotal() {
        if (sameDayBooking) return hourlyTotal;
        return earlySurcharge.add(lateSurcharge);
    }
}
