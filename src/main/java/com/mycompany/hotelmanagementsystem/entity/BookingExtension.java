package com.mycompany.hotelmanagementsystem.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class BookingExtension {
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int extensionId;
    private int bookingId;
    private LocalDateTime originalCheckOut;
    private LocalDateTime newCheckOut;
    private int extensionHours;
    private BigDecimal extensionPrice;
    private String status;
    private LocalDateTime createdAt;
    private Integer bookingRoomId;  // nullable for backward compat with single-room

    public BookingExtension() {}

    public int getExtensionId() { return extensionId; }
    public void setExtensionId(int extensionId) { this.extensionId = extensionId; }
    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public LocalDateTime getOriginalCheckOut() { return originalCheckOut; }
    public void setOriginalCheckOut(LocalDateTime originalCheckOut) { this.originalCheckOut = originalCheckOut; }
    public LocalDateTime getNewCheckOut() { return newCheckOut; }
    public void setNewCheckOut(LocalDateTime newCheckOut) { this.newCheckOut = newCheckOut; }
    public int getExtensionHours() { return extensionHours; }
    public void setExtensionHours(int extensionHours) { this.extensionHours = extensionHours; }
    public BigDecimal getExtensionPrice() { return extensionPrice; }
    public void setExtensionPrice(BigDecimal extensionPrice) { this.extensionPrice = extensionPrice; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Integer getBookingRoomId() { return bookingRoomId; }
    public void setBookingRoomId(Integer bookingRoomId) { this.bookingRoomId = bookingRoomId; }

    // Formatted date getters for JSP
    public String getOriginalCheckOutFormatted() {
        return originalCheckOut != null ? originalCheckOut.format(DATE_TIME_FORMATTER) : "";
    }
    public String getNewCheckOutFormatted() {
        return newCheckOut != null ? newCheckOut.format(DATE_TIME_FORMATTER) : "";
    }
    public String getCreatedAtFormatted() {
        return createdAt != null ? createdAt.format(DATE_TIME_FORMATTER) : "";
    }
}
