package com.mycompany.hotelmanagementsystem.util;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public final class DateHelper {
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("HH:mm");
    public static final LocalTime STANDARD_CHECK_IN = LocalTime.of(14, 0);
    public static final LocalTime STANDARD_CHECK_OUT = LocalTime.of(12, 0);

    private DateHelper() {}

    public static LocalDate parseDate(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) return null;
        return LocalDate.parse(dateStr, DATE_FORMAT);
    }

    // Default check-in time: 14:00
    public static LocalDateTime toCheckInTime(LocalDate date) {
        return date.atTime(14, 0);
    }

    // Default check-out time: 12:00
    public static LocalDateTime toCheckOutTime(LocalDate date) {
        return date.atTime(12, 0);
    }

    /**
     * Parse check-in date with custom time from form (e.g. "14:30", "09:15").
     * Falls back to default 14:00 if timeStr is invalid.
     */
    public static LocalDateTime toCheckInTime(LocalDate date, String timeStr) {
        LocalTime time = parseTime(timeStr, LocalTime.of(14, 0));
        return date.atTime(time);
    }

    /**
     * Parse check-out date with custom time from form (e.g. "12:00", "10:30").
     * Falls back to default 12:00 if timeStr is invalid.
     */
    public static LocalDateTime toCheckOutTime(LocalDate date, String timeStr) {
        LocalTime time = parseTime(timeStr, LocalTime.of(12, 0));
        return date.atTime(time);
    }

    // Parse "HH:mm" string, fallback to default if invalid
    private static LocalTime parseTime(String timeStr, LocalTime defaultTime) {
        if (timeStr == null || timeStr.isEmpty()) return defaultTime;
        try {
            return LocalTime.parse(timeStr, TIME_FORMAT);
        } catch (Exception e) {
            return defaultTime;
        }
    }

    public static long calculateNights(LocalDateTime checkIn, LocalDateTime checkOut) {
        long nights = ChronoUnit.DAYS.between(checkIn.toLocalDate(), checkOut.toLocalDate());
        return Math.max(nights, 0);  // return 0 for same-day instead of forcing 1
    }

    public static boolean isFutureDate(LocalDateTime dateTime) {
        return dateTime.isAfter(LocalDateTime.now());
    }

    /**
     * Calculate early/late surcharges based on actual vs expected check-in/out times.
     * Early surcharge: actual check-in BEFORE expected check-in time.
     * Late surcharge: actual check-out AFTER expected check-out time.
     * Same-day bookings (same date) are charged entirely by hours.
     */
    public static SurchargeResult calculateSurcharges(
            LocalDateTime checkInActual, LocalDateTime checkOutActual,
            LocalDateTime checkInExpected, LocalDateTime checkOutExpected,
            BigDecimal pricePerHour) {

        SurchargeResult result = new SurchargeResult();

        if (pricePerHour == null || pricePerHour.compareTo(BigDecimal.ZERO) == 0) {
            return result;
        }

        // Same-day booking: charge by hours only
        if (checkInActual.toLocalDate().equals(checkOutActual.toLocalDate())) {
            long totalMinutes = ChronoUnit.MINUTES.between(checkInActual, checkOutActual);
            if (totalMinutes <= 0) totalMinutes = 60;
            long totalHours = (long) Math.ceil(totalMinutes / 60.0);
            result.setSameDayBooking(true);
            result.setTotalHours(totalHours);
            result.setHourlyTotal(pricePerHour.multiply(BigDecimal.valueOf(totalHours)));
            return result;
        }

        result.setSameDayBooking(false);

        // Early check-in surcharge: actual check-in BEFORE expected check-in
        if (checkInExpected != null && checkInActual.isBefore(checkInExpected)) {
            long earlyMinutes = ChronoUnit.MINUTES.between(checkInActual, checkInExpected);
            long earlyHours = (long) Math.ceil(earlyMinutes / 60.0);
            if (earlyHours <= 0) earlyHours = 1;  // minimum 1 hour
            result.setEarlyHours(earlyHours);
            result.setEarlySurcharge(pricePerHour.multiply(BigDecimal.valueOf(earlyHours)));
        }

        // Late check-out surcharge: actual check-out AFTER expected check-out
        if (checkOutExpected != null && checkOutActual.isAfter(checkOutExpected)) {
            long lateMinutes = ChronoUnit.MINUTES.between(checkOutExpected, checkOutActual);
            long lateHours = (long) Math.ceil(lateMinutes / 60.0);
            if (lateHours <= 0) lateHours = 1;  // minimum 1 hour
            result.setLateHours(lateHours);
            result.setLateSurcharge(pricePerHour.multiply(BigDecimal.valueOf(lateHours)));
        }

        return result;
    }

    /**
     * Backward-compatible overload without expected times.
     * No surcharge if no expected times provided (all zero).
     */
    public static SurchargeResult calculateSurcharges(
            LocalDateTime checkIn, LocalDateTime checkOut, BigDecimal pricePerHour) {
        return calculateSurcharges(checkIn, checkOut, null, null, pricePerHour);
    }
}
