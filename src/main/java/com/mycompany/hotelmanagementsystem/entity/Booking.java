package com.mycompany.hotelmanagementsystem.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class Booking {
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private int bookingId;
    private int customerId;
    private Integer roomId;       // nullable - staff assigns room at check-in
    private int typeId;            // room type selected by customer
    private Integer voucherId;
    private LocalDateTime bookingDate;
    private LocalDateTime checkInExpected;
    private LocalDateTime checkOutExpected;
    private LocalDateTime checkInActual;
    private LocalDateTime checkOutActual;
    private BigDecimal totalPrice;
    private String paymentType;
    private BigDecimal depositAmount;
    private String status;
    private String note;
    private Room room;
    private RoomType roomType;     // for display when room is not yet assigned
    private Customer customer;
    private List<BookingRoom> bookingRooms;  // multi-room list
    private BigDecimal earlySurcharge;       // total early surcharge across all rooms
    private BigDecimal lateSurcharge;        // total late surcharge across all rooms

    public Booking() {}

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    public Integer getRoomId() { return roomId; }
    public void setRoomId(Integer roomId) { this.roomId = roomId; }
    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public RoomType getRoomType() { return roomType; }
    public void setRoomType(RoomType roomType) { this.roomType = roomType; }
    public Integer getVoucherId() { return voucherId; }
    public void setVoucherId(Integer voucherId) { this.voucherId = voucherId; }
    public LocalDateTime getBookingDate() { return bookingDate; }
    public void setBookingDate(LocalDateTime bookingDate) { this.bookingDate = bookingDate; }
    public LocalDateTime getCheckInExpected() { return checkInExpected; }
    public void setCheckInExpected(LocalDateTime checkIn) { this.checkInExpected = checkIn; }
    public LocalDateTime getCheckOutExpected() { return checkOutExpected; }
    public void setCheckOutExpected(LocalDateTime checkOut) { this.checkOutExpected = checkOut; }
    public LocalDateTime getCheckInActual() { return checkInActual; }
    public void setCheckInActual(LocalDateTime checkIn) { this.checkInActual = checkIn; }
    public LocalDateTime getCheckOutActual() { return checkOutActual; }
    public void setCheckOutActual(LocalDateTime checkOut) { this.checkOutActual = checkOut; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
    public String getPaymentType() { return paymentType; }
    public void setPaymentType(String paymentType) { this.paymentType = paymentType; }
    public BigDecimal getDepositAmount() { return depositAmount; }
    public void setDepositAmount(BigDecimal depositAmount) { this.depositAmount = depositAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public Room getRoom() { return room; }
    public void setRoom(Room room) { this.room = room; }
    public Customer getCustomer() { return customer; }
    public void setCustomer(Customer customer) { this.customer = customer; }
    public List<BookingRoom> getBookingRooms() { return bookingRooms; }
    public void setBookingRooms(List<BookingRoom> bookingRooms) { this.bookingRooms = bookingRooms; }
    public BigDecimal getEarlySurcharge() { return earlySurcharge; }
    public void setEarlySurcharge(BigDecimal earlySurcharge) { this.earlySurcharge = earlySurcharge; }
    public BigDecimal getLateSurcharge() { return lateSurcharge; }
    public void setLateSurcharge(BigDecimal lateSurcharge) { this.lateSurcharge = lateSurcharge; }

    public boolean isMultiRoom() {
        return bookingRooms != null && bookingRooms.size() > 1;
    }

    public int getRoomCount() {
        return bookingRooms != null ? bookingRooms.size() : (roomId != null ? 1 : 0);
    }

    // Formatted date getters for JSP
    public String getCheckInExpectedFormatted() {
        return checkInExpected != null ? checkInExpected.format(DATE_TIME_FORMATTER) : "";
    }
    public String getCheckOutExpectedFormatted() {
        return checkOutExpected != null ? checkOutExpected.format(DATE_TIME_FORMATTER) : "";
    }
    public String getCheckInExpectedDateOnly() {
        return checkInExpected != null ? checkInExpected.format(DATE_FORMATTER) : "";
    }
    public String getCheckOutExpectedDateOnly() {
        return checkOutExpected != null ? checkOutExpected.format(DATE_FORMATTER) : "";
    }
    public String getBookingDateFormatted() {
        return bookingDate != null ? bookingDate.format(DATE_TIME_FORMATTER) : "";
    }
}
