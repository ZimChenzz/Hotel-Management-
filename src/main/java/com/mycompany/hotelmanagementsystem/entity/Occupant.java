package com.mycompany.hotelmanagementsystem.entity;

public class Occupant {
    private int occupantId;
    private int bookingId;
    private String fullName;
    private String idCardNumber;
    private String phoneNumber;
    private Integer bookingRoomId;  // nullable, for per-room guest assignment

    public Occupant() {}

    public int getOccupantId() { return occupantId; }
    public void setOccupantId(int occupantId) { this.occupantId = occupantId; }
    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getIdCardNumber() { return idCardNumber; }
    public void setIdCardNumber(String idCardNumber) { this.idCardNumber = idCardNumber; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public Integer getBookingRoomId() { return bookingRoomId; }
    public void setBookingRoomId(Integer bookingRoomId) { this.bookingRoomId = bookingRoomId; }
}
