package com.mycompany.hotelmanagementsystem.entity;

import java.util.List;

/**
 * DTO for unassigned room display with suggestions.
 */
public class UnassignedRoomInfo {
    private BookingRoom bookingRoom;
    private List<Room> availableRooms;
    private List<RoomSuggestionItem> suggestions;

    public UnassignedRoomInfo() {}

    public UnassignedRoomInfo(BookingRoom bookingRoom, List<Room> availableRooms, List<RoomSuggestionItem> suggestions) {
        this.bookingRoom = bookingRoom;
        this.availableRooms = availableRooms;
        this.suggestions = suggestions;
    }

    public BookingRoom getBookingRoom() { return bookingRoom; }
    public void setBookingRoom(BookingRoom bookingRoom) { this.bookingRoom = bookingRoom; }

    public List<Room> getAvailableRooms() { return availableRooms; }
    public void setAvailableRooms(List<Room> availableRooms) { this.availableRooms = availableRooms; }

    public List<RoomSuggestionItem> getSuggestions() { return suggestions; }
    public void setSuggestions(List<RoomSuggestionItem> suggestions) { this.suggestions = suggestions; }

    public boolean hasSuggestions() {
        return suggestions != null && !suggestions.isEmpty();
    }

    public boolean hasAvailableRooms() {
        return availableRooms != null && !availableRooms.isEmpty();
    }
}
