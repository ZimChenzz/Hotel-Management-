package com.mycompany.hotelmanagementsystem.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ServiceRequest {
    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int requestId;
    private int bookingId;
    private Integer staffId;
    private String serviceType;
    private LocalDateTime requestTime;
    private String status;
    private String description;
    private String priority;
    private String notes;
    private LocalDateTime completedTime;
    private String roomNumber;

    // Transient for display
    private Booking booking;
    private String staffName;

    public ServiceRequest() {}

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }
    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public Integer getStaffId() { return staffId; }
    public void setStaffId(Integer staffId) { this.staffId = staffId; }
    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }
    public LocalDateTime getRequestTime() { return requestTime; }
    public void setRequestTime(LocalDateTime requestTime) { this.requestTime = requestTime; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public LocalDateTime getCompletedTime() { return completedTime; }
    public void setCompletedTime(LocalDateTime completedTime) { this.completedTime = completedTime; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public Booking getBooking() { return booking; }
    public void setBooking(Booking booking) { this.booking = booking; }
    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    // Formatted date getters for JSP
    public String getRequestTimeFormatted() {
        return requestTime != null ? requestTime.format(DT_FMT) : "";
    }

    public String getCompletedTimeFormatted() {
        return completedTime != null ? completedTime.format(DT_FMT) : "";
    }
}
