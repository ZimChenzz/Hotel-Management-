package com.mycompany.hotelmanagementsystem.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class BookingRoom {
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int bookingRoomId;
    private int bookingId;
    private Integer roomId;          // nullable until staff assigns
    private int typeId;
    private BigDecimal unitPrice;
    private BigDecimal earlySurcharge;
    private BigDecimal lateSurcharge;
    private BigDecimal promotionDiscount;
    private String status;
    private LocalDateTime checkInActual;
    private LocalDateTime checkOutActual;
    private LocalDateTime createdAt;

    // Navigation properties (lazy loaded for display)
    private Room room;
    private RoomType roomType;
    private List<Occupant> occupants;
    private List<BookingExtension> extensions;

    public BookingRoom() {}

    public int getBookingRoomId() { return bookingRoomId; }
    public void setBookingRoomId(int bookingRoomId) { this.bookingRoomId = bookingRoomId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public Integer getRoomId() { return roomId; }
    public void setRoomId(Integer roomId) { this.roomId = roomId; }

    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public BigDecimal getEarlySurcharge() { return earlySurcharge; }
    public void setEarlySurcharge(BigDecimal earlySurcharge) { this.earlySurcharge = earlySurcharge; }

    public BigDecimal getLateSurcharge() { return lateSurcharge; }
    public void setLateSurcharge(BigDecimal lateSurcharge) { this.lateSurcharge = lateSurcharge; }

    public BigDecimal getPromotionDiscount() { return promotionDiscount; }
    public void setPromotionDiscount(BigDecimal promotionDiscount) { this.promotionDiscount = promotionDiscount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCheckInActual() { return checkInActual; }
    public void setCheckInActual(LocalDateTime checkInActual) { this.checkInActual = checkInActual; }

    public LocalDateTime getCheckOutActual() { return checkOutActual; }
    public void setCheckOutActual(LocalDateTime checkOutActual) { this.checkOutActual = checkOutActual; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Room getRoom() { return room; }
    public void setRoom(Room room) { this.room = room; }

    public RoomType getRoomType() { return roomType; }
    public void setRoomType(RoomType roomType) { this.roomType = roomType; }

    public List<Occupant> getOccupants() { return occupants; }
    public void setOccupants(List<Occupant> occupants) { this.occupants = occupants; }

    public List<BookingExtension> getExtensions() { return extensions; }
    public void setExtensions(List<BookingExtension> extensions) { this.extensions = extensions; }

    // Formatted date getters for JSP
    public String getCheckInActualFormatted() {
        return checkInActual != null ? checkInActual.format(DATE_TIME_FORMATTER) : "";
    }

    public String getCheckOutActualFormatted() {
        return checkOutActual != null ? checkOutActual.format(DATE_TIME_FORMATTER) : "";
    }

    public String getCreatedAtFormatted() {
        return createdAt != null ? createdAt.format(DATE_TIME_FORMATTER) : "";
    }
}
