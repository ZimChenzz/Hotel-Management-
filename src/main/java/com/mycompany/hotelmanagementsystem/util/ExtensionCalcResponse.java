package com.mycompany.hotelmanagementsystem.util;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ExtensionCalcResponse {
    private static final DateTimeFormatter DT_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int bookingId;
    private LocalDateTime originalCheckOut;
    private LocalDateTime newCheckOut;
    private int extraHours;
    private BigDecimal extensionPrice;
    private BigDecimal pricePerHour;
    private BigDecimal basePrice;
    private boolean hourlyRate; // true if <= 12h (hourly), false if > 12h (nightly)

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public LocalDateTime getOriginalCheckOut() { return originalCheckOut; }
    public void setOriginalCheckOut(LocalDateTime originalCheckOut) { this.originalCheckOut = originalCheckOut; }
    public LocalDateTime getNewCheckOut() { return newCheckOut; }
    public void setNewCheckOut(LocalDateTime newCheckOut) { this.newCheckOut = newCheckOut; }
    public int getExtraHours() { return extraHours; }
    public void setExtraHours(int extraHours) { this.extraHours = extraHours; }
    public BigDecimal getExtensionPrice() { return extensionPrice; }
    public void setExtensionPrice(BigDecimal extensionPrice) { this.extensionPrice = extensionPrice; }
    public BigDecimal getPricePerHour() { return pricePerHour; }
    public void setPricePerHour(BigDecimal pricePerHour) { this.pricePerHour = pricePerHour; }
    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }
    public boolean isHourlyRate() { return hourlyRate; }
    public void setHourlyRate(boolean hourlyRate) { this.hourlyRate = hourlyRate; }

    public String getOriginalCheckOutFormatted() {
        return originalCheckOut != null ? originalCheckOut.format(DT_FORMATTER) : "";
    }

    public String getNewCheckOutFormatted() {
        return newCheckOut != null ? newCheckOut.format(DT_FORMATTER) : "";
    }
}
