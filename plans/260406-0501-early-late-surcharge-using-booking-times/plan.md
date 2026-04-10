# Plan: Sửa logic tính phụ phí check-in/check-out sớm/muộn theo giờ đặt phòng

## Tổng quan

**Vấn đề:** Logic hiện tại dùng giờ chuẩn (14:00 check-in, 12:00 check-out) để tính phụ phí, thay vì dùng giờ khách thực sự đặt trong booking (`checkInExpected`, `checkOutExpected`).

**Yêu cầu:** Phụ phí chỉ tính khi khách check-in/check-out sớm/muộn **so với giờ HỌ ĐẶT**, không phải giờ chuẩn của khách sạn.

## Các thay đổi cần thiết

### 1. Cập nhật `DateHelper.calculateSurcharges()`

**File:** `src/main/java/com/mycompany/hotelmanagementsystem/util/DateHelper.java`

**Hiện tại:**
```java
// Early = before 14:00 (standard)
if (checkInTime.isBefore(STANDARD_CHECK_IN)) { ... }

// Late = after 12:00 (standard)
if (checkOutTime.isAfter(STANDARD_CHECK_OUT)) { ... }
```

**Cần sửa thành:**
```java
// Early = before 14:00 AND before booking's expected check-in time
if (checkInTime.isBefore(STANDARD_CHECK_IN) && checkInTime.isBefore(expectedCheckIn.toLocalTime())) { ... }

// Late = after 12:00 AND after booking's expected check-out time
if (checkOutTime.isAfter(STANDARD_CHECK_OUT) || checkOutTime.isAfter(expectedCheckOut.toLocalTime())) { ... }
```

**Logic mới:**
- **Early surcharge:** Chỉ khi `actual < 14:00` VÀ `actual < expected`
- **Late surcharge:** Chỉ khi `actual > 12:00` HOẶC `actual > expected`

### 2. Cập nhật `StaffBookingService.assignRoomToBookingRoom()`

**File:** `src/main/java/com/mycompany/hotelmanagementsystem/service/StaffBookingService.java`

Truyền thêm `checkOutExpected` vào `calculateSurcharges()`:
```java
SurchargeResult surcharge = DateHelper.calculateSurcharges(
    checkInActual,
    booking.getCheckOutExpected(),  // thêm
    rt.getPricePerHour());
```

### 3. Cập nhật `StaffBookingService.checkoutBookingRoom()`

**File:** `src/main/java/com/mycompany/hotelmanagementsystem/service/StaffBookingService.java`

Truyền thêm `checkOutExpected` vào `calculateSurcharges()`:
```java
SurchargeResult surcharge = DateHelper.calculateSurcharges(
    checkInActual,
    booking.getCheckOutExpected(),  // thêm
    rt.getPricePerHour());
```

## Chi tiết kỹ thuật

### Phương thức mới `DateHelper.calculateSurcharges()`

```java
public static SurchargeResult calculateSurcharges(
        LocalDateTime checkInActual,
        LocalDateTime checkOutActual,
        LocalDateTime checkInExpected,
        LocalDateTime checkOutExpected,
        BigDecimal pricePerHour) {

    SurchargeResult result = new SurchargeResult();

    if (pricePerHour == null || pricePerHour.compareTo(BigDecimal.ZERO) == 0) {
        return result;
    }

    // Same-day booking
    if (checkInActual.toLocalDate().equals(checkOutActual.toLocalDate())) {
        // ... existing same-day logic
    }

    // Early check-in: actual < 14:00 AND actual < expected check-in
    LocalTime checkInTime = checkInActual.toLocalTime();
    if (checkInTime.isBefore(STANDARD_CHECK_IN) &&
        checkInExpected != null &&
        checkInTime.isBefore(checkInExpected.toLocalTime())) {
        long earlyMinutes = ChronoUnit.MINUTES.between(checkInTime, STANDARD_CHECK_IN);
        long earlyHours = (long) Math.ceil(earlyMinutes / 60.0);
        result.setEarlyHours(earlyHours);
        result.setEarlySurcharge(pricePerHour.multiply(BigDecimal.valueOf(earlyHours)));
    }

    // Late check-out: actual > 12:00 OR actual > expected check-out
    LocalTime checkOutTime = checkOutActual.toLocalTime();
    boolean isLateByStandard = checkOutTime.isAfter(STANDARD_CHECK_OUT);
    boolean isLateByBooking = checkOutExpected != null &&
                              checkOutTime.isAfter(checkOutExpected.toLocalTime());

    if (isLateByStandard || isLateByBooking) {
        // Calculate late hours from the LATER of standard or expected
        LocalTime late基准 = STANDARD_CHECK_OUT;
        if (checkOutExpected != null && checkOutExpected.toLocalTime().isAfter(STANDARD_CHECK_OUT)) {
            late基准 = checkOutExpected.toLocalTime();
        }
        long lateMinutes = ChronoUnit.MINUTES.between(late基准, checkOutTime);
        long lateHours = (long) Math.ceil(lateMinutes / 60.0);
        result.setLateHours(lateHours);
        result.setLateSurcharge(pricePerHour.multiply(BigDecimal.valueOf(lateHours)));
    }

    return result;
}
```

### Overload method cho backward compatibility

Giữ method cũ để không break code khác:

```java
public static SurchargeResult calculateSurcharges(
        LocalDateTime checkIn, LocalDateTime checkOut, BigDecimal pricePerHour) {
    return calculateSurcharges(checkIn, checkOut, null, null, pricePerHour);
}
```

## Kiểm tra

- [ ] Test: Khách đặt 16:00 check-in, check-in 14:00 → Không tính early surcharge
- [ ] Test: Khách đặt 10:00 check-out, check-out 12:00 → Tính late surcharge (2 tiếng)
- [ ] Test: Khách đặt 18:00 check-out, check-out 12:00 → Không tính late surcharge
- [ ] Test: Multi-room booking với các giờ khác nhau

## Ảnh hưởng

- Chỉ ảnh hưởng `DateHelper.calculateSurcharges()` và 2 nơi gọi nó
- Không ảnh hưởng UI (checkout.jsp đã hiển thị đúng `surcharge.surchargeTotal`)
