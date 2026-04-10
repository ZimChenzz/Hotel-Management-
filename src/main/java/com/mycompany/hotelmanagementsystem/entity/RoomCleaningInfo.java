package com.mycompany.hotelmanagementsystem.entity;

public class RoomCleaningInfo {
    private Room room;
    private ServiceRequest cleaningRequest;
    private String cleaningDescription;
    private Integer bookingId;

    public RoomCleaningInfo() {}

    public RoomCleaningInfo(Room room, ServiceRequest cleaningRequest) {
        this.room = room;
        this.cleaningRequest = cleaningRequest;
        if (cleaningRequest != null) {
            this.cleaningDescription = cleaningRequest.getDescription();
            this.bookingId = cleaningRequest.getBookingId();
        }
    }

    public Room getRoom() { return room; }
    public void setRoom(Room room) { this.room = room; }
    public ServiceRequest getCleaningRequest() { return cleaningRequest; }
    public void setCleaningRequest(ServiceRequest cleaningRequest) { this.cleaningRequest = cleaningRequest; }
    public String getCleaningDescription() { return cleaningDescription; }
    public void setCleaningDescription(String cleaningDescription) { this.cleaningDescription = cleaningDescription; }
    public Integer getBookingId() { return bookingId; }
    public void setBookingId(Integer bookingId) { this.bookingId = bookingId; }

    public String getRoomNumber() {
        return room != null ? room.getRoomNumber() : null;
    }

    public boolean hasCleaningRequest() {
        return cleaningRequest != null;
    }

    public boolean isAssigned() {
        return cleaningRequest != null && cleaningRequest.getStaffId() != null;
    }

    public Integer getStaffId() {
        return cleaningRequest != null ? cleaningRequest.getStaffId() : null;
    }

    public String getStaffName() {
        return cleaningRequest != null ? cleaningRequest.getStaffName() : null;
    }

    public String getRequestStatus() {
        return cleaningRequest != null ? cleaningRequest.getStatus() : null;
    }
}
