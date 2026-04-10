# Phase 1: Phân tích chi tiết Service Request Flow

## Vấn đề đã xác định

### 1. `ServiceRequestService.createRequest()` - Thiếu hỗ trợ Multi-room

**Dòng 52-58**:
```java
// Resolve room number for display
String roomNumber = null;
if (booking.getRoomId() != null) {
    Room room = roomRepository.findById(booking.getRoomId());
    if (room != null) {
        roomNumber = room.getRoomNumber();
    }
}
```

**Vấn đề**:
- `booking.getRoomId()` chỉ set cho single-room booking
- Multi-room booking có `booking.getRoomId() = null`
- Multi-room booking lưu room info trong `booking.getBookingRooms()`

**Kết quả**: Multi-room booking tạo service request với `roomNumber = null`

### 2. `hasPendingRequest()` check sai scope

**Dòng 48**:
```java
if (serviceRequestRepository.hasPendingRequest(bookingId, serviceType)) {
    return ServiceResult.failure("Bạn đã có yêu cầu " + serviceType + " đang chờ xử lý");
}
```

**Vấn đề**:
- Check theo `bookingId` toàn booking
- Multi-room: nếu phòng A đã có pending request, phòng B không thể tạo
- Nên check theo `roomNumber` cụ thể

### 3. Customer Frontend không cho phép chọn phòng

**booking-detail.jsp**:
```jsp
<input type="hidden" name="serviceType" value="Cleaning">
```

**Vấn đề**:
- Không có dropdown chọn phòng
- Không distinguish được multi-room

---

## Phân tích Multi-room vs Single-room

### Single-room Booking
- `booking.getRoomId()` = ID của phòng đã assign
- `booking.getBookingRooms()` = null hoặc empty
- Flow hiện tại: **HOẠT ĐỘNG**

### Multi-room Booking (Walk-in multi-room, hoặc booking nhiều phòng)
- `booking.getRoomId()` = null
- `booking.getBookingRooms()` = list các phòng đã assign
- Mỗi `BookingRoom` có `roomId` riêng
- Flow hiện tại: **KHÔNG HOẠT ĐỘNG** (roomNumber = null)

---

## Giải pháp đề xuất

### Option A: Thêm `roomId` parameter
1. Thêm `Integer roomId` parameter vào `createRequest()`
2. Customer chọn phòng từ dropdown
3. Backend tạo request với đúng `roomNumber`

### Option B: Tự động tạo request cho tất cả phòng
1. Khi customer tạo cleaning request cho multi-room
2. Tự động tạo request cho tất cả các phòng đã check-in
3. Staff hoàn thành từng phòng riêng biệt

**Recommendation**: Option A - linh hoạt hơn, customer có thể chọn phòng cần dịch vụ.

---

## Related Code Files

### Backend
- `ServiceRequestService.java:createRequest()` - lines 32-78
- `ServiceRequestService.java:hasPendingRequest()` - check theo bookingId
- `ServiceRequestRepository.java:hasPendingRequest()` - SQL query

### Frontend
- `customer/booking-detail.jsp` - form tạo request
- `customer/requests.jsp` - dropdown chọn booking

### Entity
- `Booking.java` - `roomId` vs `bookingRooms`
- `BookingRoom.java` - có `roomId` riêng
