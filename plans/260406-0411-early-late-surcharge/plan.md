---
title: "Implement Early/Late Check-in/out Surcharge at Actual Time"
description: "Calculate and apply surcharge when staff performs actual check-in before 14:00 or check-out after 12:00"
status: pending
priority: P2
effort: 6h
branch: main
tags: [surcharge, check-in, check-out, staff-booking]
created: 2026-04-06
---

## Overview

Currently surcharge is only calculated at booking creation time based on expected check-in/check-out times. This plan implements surcharge recalculation when staff performs actual check-in/check-out, adding any additional charges to the checkout invoice.

## Problem Statement

- Booking created with expected check-in 14:00, check-out 12:00
- Staff checks in guest at 10:00 (early check-in < 14:00) - no surcharge calculated
- Staff checks out guest at 15:00 (late check-out > 12:00) - no surcharge calculated
- Guest should pay early check-in + late check-out fees but doesn't

## Key Entities (Already Exist)

- `Booking` has `earlySurcharge` and `lateSurcharge` fields
- `BookingRoom` has `earlySurcharge` and `lateSurcharge` fields
- `DateHelper.calculateSurcharges()` - calculates surcharge based on actual times
- `SurchargeResult` DTO - holds surcharge calculation results

## Files to Modify

| File | Purpose |
|------|---------|
| `BookingRepository.java` | Add methods to update early/late surcharge |
| `BookingRoomRepository.java` | Add methods to update early/late surcharge |
| `StaffBookingService.java` | Calculate surcharge on actual check-in/check-out |
| `checkout.jsp` | Display surcharge breakdown |

---

## Phase 1: Add Repository Methods

### 1.1 BookingRoomRepository.java

Add methods to update surcharges per room:

```java
public int updateEarlySurcharge(int bookingRoomId, BigDecimal earlySurcharge) {
    return executeUpdate(
        "UPDATE BookingRoom SET early_surcharge = ? WHERE booking_room_id = ?",
        earlySurcharge, bookingRoomId);
}

public int updateLateSurcharge(int bookingRoomId, BigDecimal lateSurcharge) {
    return executeUpdate(
        "UPDATE BookingRoom SET late_surcharge = ? WHERE booking_room_id = ?",
        lateSurcharge, bookingRoomId);
}
```

### 1.2 BookingRepository.java

Add methods to update booking-level surcharge (sum of all rooms):

```java
public int updateEarlySurcharge(int bookingId, BigDecimal earlySurcharge) {
    return executeUpdate(
        "UPDATE Booking SET early_surcharge = ? WHERE booking_id = ?",
        earlySurcharge, bookingId);
}

public int updateLateSurcharge(int bookingId, BigDecimal lateSurcharge) {
    return executeUpdate(
        "UPDATE Booking SET late_surcharge = ? WHERE booking_id = ?",
        lateSurcharge, bookingId);
}
```

---

## Phase 2: Update StaffBookingService

### 2.1 Modify `assignRoom(int bookingId, int roomId)`

Location: Line 96-114

Add early surcharge calculation when actual check-in is before 14:00:

```java
public boolean assignRoom(int bookingId, int roomId) {
    // ... existing code ...

    // Set check-in actual time
    LocalDateTime checkInActual = LocalDateTime.now();
    bookingRepository.updateCheckInActual(bookingId, checkInActual);

    // Calculate early surcharge if check-in before 14:00
    Booking booking = bookingRepository.findById(bookingId);
    if (booking != null && booking.getRoomType() != null) {
        BigDecimal pricePerHour = booking.getRoomType().getPricePerHour();
        if (pricePerHour != null && pricePerHour.compareTo(BigDecimal.ZERO) > 0) {
            SurchargeResult surcharge = DateHelper.calculateSurcharges(
                checkInActual, booking.getCheckOutExpected(), pricePerHour);
            if (surcharge.getEarlySurcharge().compareTo(BigDecimal.ZERO) > 0) {
                // Update BookingRoom surcharge if this is a multi-room booking
                // For single-room, update Booking directly
                bookingRepository.updateEarlySurcharge(bookingId, surcharge.getEarlySurcharge());
            }
        }
    }

    // ... rest of existing code ...
}
```

### 2.2 Modify `processCheckout(int bookingId)`

Location: Line 136-170

Add late surcharge calculation when actual check-out is after 12:00:

```java
public boolean processCheckout(int bookingId) {
    // ... existing code ...

    // Set check-out actual time
    LocalDateTime checkOutActual = LocalDateTime.now();
    bookingRepository.updateCheckOutActual(bookingId, checkOutActual);

    // Calculate late surcharge if check-out after 12:00
    Booking booking = bookingRepository.findById(bookingId);
    if (booking != null && booking.getRoomType() != null) {
        BigDecimal pricePerHour = booking.getRoomType().getPricePerHour();
        if (pricePerHour != null && pricePerHour.compareTo(BigDecimal.ZERO) > 0) {
            // Use actual check-in if available, otherwise expected
            LocalDateTime checkIn = booking.getCheckInActual() != null
                ? booking.getCheckInActual()
                : booking.getCheckInExpected();
            SurchargeResult surcharge = DateHelper.calculateSurcharges(
                checkIn, checkOutActual, pricePerHour);
            if (surcharge.getLateSurcharge().compareTo(BigDecimal.ZERO) > 0) {
                bookingRepository.updateLateSurcharge(bookingId, surcharge.getLateSurcharge());
            }
        }
    }

    // ... rest of existing code ...
}
```

### 2.3 Add Method to Get Surcharge for Display

Add method to get surcharge details for checkout UI:

```java
public SurchargeResult getActualSurcharge(int bookingId) {
    Booking booking = bookingRepository.findById(bookingId);
    if (booking == null || booking.getRoomType() == null) {
        return new SurchargeResult();
    }
    BigDecimal pricePerHour = booking.getRoomType().getPricePerHour();
    LocalDateTime checkIn = booking.getCheckInActual() != null
        ? booking.getCheckInActual()
        : booking.getCheckInExpected();
    LocalDateTime checkOut = booking.getCheckOutActual() != null
        ? booking.getCheckOutActual()
        : booking.getCheckOutExpected();
    return DateHelper.calculateSurcharges(checkIn, checkOut, pricePerHour);
}
```

---

## Phase 3: Update Checkout UI

### 3.1 checkout.jsp

Add surcharge display section after "Tiền phòng" row:

```jsp
<c:if test="${surcharge != null && surcharge.surchargeTotal > 0}">
    <tr>
        <td>Phụ phí check-in muộn check-out sớm:</td>
        <td class="text-end text-danger">
            + <fmt:formatNumber value="${surcharge.surchargeTotal}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
        </td>
    </tr>
</c:if>
```

---

## Phase 4: Test Scenarios

| Scenario | Expected Result |
|----------|----------------|
| Book 14:00-12:00, check-in 10:00, check-out 15:00 | Early + Late surcharge applied |
| Book 14:00-12:00, check-in 14:00, check-out 12:00 | No surcharge |
| Book 14:00-12:00, check-in 10:00, check-out 11:00 | Early surcharge only |
| Book 14:00-12:00, check-in 13:00, check-out 15:00 | Late surcharge only |

---

## Success Criteria

1. Staff check-in before 14:00 triggers early surcharge calculation
2. Staff check-out after 12:00 triggers late surcharge calculation
3. Surcharge is stored in Booking/BookingRoom records
4. Checkout page displays surcharge breakdown
5. Additional surcharge is added to invoice amount

## Design Decisions

- **Invoice**: Surcharge added to existing invoice (not new line)
- **Multi-room**: Surcharge calculated at booking level (total), not per room
- **UI Display**: Surcharge shown as combined total ("Phụ phí check-in muộn/check-out sớm")

## Risk Assessment

- **Risk**: Surcharge already calculated at booking time, may double-charge
- **Mitigation**: Use fresh calculation at actual check-in/out time (replaces expected surcharge)
