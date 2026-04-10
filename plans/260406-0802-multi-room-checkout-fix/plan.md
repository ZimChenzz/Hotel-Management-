# Plan: Sửa lỗi Multi-room Checkout

## Vấn đề

**Mô tả**: Khi checkout 1 phòng trong multi-room booking, các phòng còn lại vẫn ở trạng thái CHECKED_IN.

**Nguyên nhân**: `handleCheckoutBookingRoom` gọi `checkoutBookingRoom(bookingRoomId)` - chỉ checkout phòng được chỉ định, không checkout các phòng khác.

## Current Flow

```
Staff click "Checkout" 1 phòng
  -> handleCheckoutBookingRoom()
    -> staffBookingService.checkoutBookingRoom(bookingRoomId)
      -> Chỉ checkout phòng đó
      -> Các phòng còn lại vẫn CHECKED_IN
```

## Expected Flow

```
Staff click "Checkout" 1 phòng
  -> Kiểm tra booking có multi-room không
  -> Nếu có multi-room:
    -> Gọi bulkCheckout(bookingId) -> checkout TẤT CẢ phòng
  -> Nếu single-room:
    -> checkoutBookingRoom(bookingRoomId) -> checkout phòng đó
```

## Giải pháp

### Sửa `StaffBookingController.handleCheckoutBookingRoom()`

Thêm logic kiểm tra multi-room:

```java
private void handleCheckoutBookingRoom(HttpServletRequest request, HttpServletResponse response) {
    int bookingId = parseIntParam(request, "bookingId");
    int bookingRoomId = parseIntParam(request, "bookingRoomId");

    // Check if this is a multi-room booking
    Booking booking = bookingRepository.findByIdWithDetails(bookingId);
    boolean isMultiRoom = booking != null && booking.isMultiRoom();

    // For multi-room bookings, checkout all rooms at once
    if (isMultiRoom) {
        boolean success = staffBookingService.bulkCheckout(bookingId);
        // redirect...
        return;
    }

    // For single-room, proceed with individual checkout
    boolean success = staffBookingService.checkoutBookingRoom(bookingRoomId);
    // redirect...
}
```

### Alternative: Sửa trong Service layer

Sửa `checkoutBookingRoom()` để tự động checkout các phòng khác nếu là multi-room:

```java
public boolean checkoutBookingRoom(int bookingRoomId) {
    BookingRoom br = bookingRoomRepository.findById(bookingRoomId);
    Booking booking = bookingRepository.findByIdWithDetails(br.getBookingId());

    // If multi-room booking, checkout all rooms
    if (booking != null && booking.isMultiRoom()) {
        return bulkCheckout(br.getBookingId());
    }

    // Single-room: proceed normal
    // ... existing checkout logic
}
```

## Files cần sửa

### Option 1: Controller fix
- `StaffBookingController.java` - `handleCheckoutBookingRoom()`

### Option 2: Service fix
- `StaffBookingService.java` - `checkoutBookingRoom()`

## Recommendation

**Chọn Option 2 (Service layer)** vì:
- Tất cả các caller gọi `checkoutBookingRoom` đều được hưởng lợi
- Logic checkout tập trung ở 1 nơi
- Tránh duplicate code ở controller

## Todo List

- [ ] Sửa `StaffBookingService.checkoutBookingRoom()` thêm multi-room check
- [ ] Test checkout với single-room booking
- [ ] Test checkout với multi-room booking
- [ ] Verify tất cả phòng được checkout khi checkout 1 phòng trong multi-room
