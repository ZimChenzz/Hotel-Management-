package com.mycompany.hotelmanagementsystem.entity;

public class RoomSuggestionItem {
    private int bookingRoomId;
    private int suggestedRoomId;
    private String roomTypeName;
    private String suggestedRoomNumber;

    public RoomSuggestionItem() {}

    public RoomSuggestionItem(int bookingRoomId, int suggestedRoomId, String roomTypeName, String suggestedRoomNumber) {
        this.bookingRoomId = bookingRoomId;
        this.suggestedRoomId = suggestedRoomId;
        this.roomTypeName = roomTypeName;
        this.suggestedRoomNumber = suggestedRoomNumber;
    }

    public int getBookingRoomId() { return bookingRoomId; }
    public void setBookingRoomId(int bookingRoomId) { this.bookingRoomId = bookingRoomId; }

    public int getSuggestedRoomId() { return suggestedRoomId; }
    public void setSuggestedRoomId(int suggestedRoomId) { this.suggestedRoomId = suggestedRoomId; }

    public String getRoomTypeName() { return roomTypeName; }
    public void setRoomTypeName(String roomTypeName) { this.roomTypeName = roomTypeName; }

    public String getSuggestedRoomNumber() { return suggestedRoomNumber; }
    public void setSuggestedRoomNumber(String suggestedRoomNumber) { this.suggestedRoomNumber = suggestedRoomNumber; }
}
