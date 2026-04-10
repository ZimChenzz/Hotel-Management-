package com.mycompany.hotelmanagementsystem.util;

import com.mycompany.hotelmanagementsystem.entity.Booking;

public class BookingResult {
    private boolean success;
    private String message;
    private Booking booking;

    public BookingResult(boolean success, String message, Booking booking) {
        this.success = success;
        this.message = message;
        this.booking = booking;
    }

    public static BookingResult success(String message, Booking booking) {
        return new BookingResult(true, message, booking);
    }

    public static BookingResult failure(String message) {
        return new BookingResult(false, message, null);
    }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public Booking getBooking() { return booking; }
}
