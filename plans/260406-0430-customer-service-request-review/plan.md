# Plan: Kiểm tra và sửa chức năng Yêu cầu dịch vụ Customer

## Context
- Vấn đề ban đầu: đồng bộ dọn phòng và yêu cầu dịch vụ
- Mở rộng: kiểm tra flow yêu cầu dịch vụ cho 1 phòng và nhiều phòng

## Issues Phát hiện

### 1. Service Request cho Multi-room Booking
**File**: `ServiceRequestService.java:createRequest()`

**Vấn đề**: Khi tạo service request, code chỉ lấy room từ `booking.getRoomId()`:
```java
if (booking.getRoomId() != null) {
    Room room = roomRepository.findById(booking.getRoomId());
    ...
}
```

**Vấn đề**: Multi-room booking có `booking.getRoomId() = null` và room info nằm trong `booking.getBookingRooms()`.

### 2. Customer Booking Selection (requests.jsp)
**Vấn đề**: Dropdown chỉ hiển thị `b.room` cho single-room, không handle multi-room:
```jsp
<c:if test="${not empty b.room}"> - Phòng ${b.room.roomNumber}</c:if>
```

### 3. Customer Booking Detail (booking-detail.jsp)
**Vấn đề**: Form tạo cleaning request không cho phép chọn phòng trong multi-room:
```jsp
<input type="hidden" name="serviceType" value="Cleaning">
```

---

## Phase 1: Kiểm tra Single Room Booking Flow

### 1.1 Backend Verification
- [ ] Kiểm tra `ServiceRequestService.createRequest()` với single-room booking
- [ ] Verify `roomNumber` được set đúng từ `booking.getRoomId()`

### 1.2 Frontend Verification
- [ ] Vào `/customer/bookings` -> chọn booking đã check-in
- [ ] Kiểm tra booking-detail hiển thị đúng phòng
- [ ] Submit cleaning request -> verify request được tạo với đúng roomNumber

### 1.3 Staff Side Verification
- [ ] Staff nhận yêu cầu -> verify hiển thị đúng phòng
- [ ] Staff hoàn thành -> verify phòng chuyển sang Available

---

## Phase 2: Kiểm tra Multi-room Booking Flow

### 2.1 Backend Verification
- [ ] Kiểm tra `ServiceRequestService.createRequest()` với multi-room booking
- [ ] Xác định: `booking.getRoomId()` = null, `booking.getBookingRooms()` có dữ liệu
- [ ] Verify `roomNumber` = null hoặc không đúng

### 2.2 Frontend Verification
- [ ] Vào `/customer/requests` -> kiểm tra dropdown booking selection
- [ ] Multi-room booking hiển thị thiếu thông tin phòng
- [ ] Submit cleaning request -> verify request được tạo nhưng không có roomNumber

### 2.3 Staff Side Verification
- [ ] Staff nhận yêu cầu -> roomNumber = null/undefined
- [ ] Staff hoàn thành -> phòng không chuyển sang Available (vì không tìm được phòng)

---

## Phase 3: Sửa lỗi

### 3.1 Sửa `ServiceRequestService.createRequest()`
**Cần sửa**: Hỗ trợ multi-room bằng cách:
1. Nếu `booking.getRoomId() != null` -> dùng room đó (single-room)
2. Nếu `booking.getBookingRooms()` có dữ liệu -> tạo nhiều service request (1 cho mỗi phòng)
3. Hoặc: yêu cầu customer chọn phòng cụ thể

### 3.2 Sửa `requests.jsp` booking selection
**Cần sửa**: Hiển thị đúng thông tin phòng:
- Single-room: `b.room.roomNumber`
- Multi-room: `b.bookingRooms` list với các room numbers

### 3.3 Sửa `booking-detail.jsp` cho multi-room
**Cần sửa**: Thêm dropdown chọn phòng khi là multi-room booking

### 3.4 Sửa `StaffCleaningService.markRoomAsClean()`
**Cần sửa**: Cập nhật đúng room khi hoàn thành cleaning request

---

## Phase 4: Test lại sau sửa

### 4.1 Single Room
- [ ] Customer tạo cleaning request -> roomNumber đúng
- [ ] Staff hoàn thành -> phòng chuyển Available

### 4.2 Multi Room
- [ ] Customer tạo cleaning request -> chọn được phòng cụ thể
- [ ] Staff hoàn thành -> đúng phòng được chọn chuyển Available

---

## Related Files

### Backend
- `ServiceRequestService.java:createRequest()` - lấy room info
- `ServiceRequestService.java:completeRequest()` - cập nhật room status
- `StaffCleaningService.java:getRoomsNeedingCleaning()` - hiển thị phòng cần dọn
- `StaffCleaningService.java:markRoomAsClean()` - hoàn thành dọn phòng

### Frontend
- `customer/booking-detail.jsp` - tạo cleaning request
- `customer/requests.jsp` - xem danh sách yêu cầu

### Entity
- `Booking.java` - có `roomId` (single) và `bookingRooms` (multi)
- `BookingRoom.java` - có `roomId` cho mỗi phòng trong multi-room

---

## Success Criteria
1. Single-room booking: service request hoạt động đầy đủ
2. Multi-room booking: customer có thể chọn phòng để yêu cầu dịch vụ
3. Staff hoàn thành cleaning -> đúng phòng chuyển Available
4. Đồng bộ giữa service request page và cleaning page
