# Phase 2: Implement Multi-room Service Request Support

## Changes Required

### 1. ServiceRequestService.java - Thêm `roomId` parameter

**Modify `createRequest()` signature**:
```java
public ServiceResult createRequest(int bookingId, int customerId,
                                  String serviceType, String description,
                                  String priority, Integer roomId)
```

**Update room resolution logic**:
```java
String roomNumber = null;
if (roomId != null) {
    Room room = roomRepository.findById(roomId);
    if (room != null) {
        roomNumber = room.getRoomNumber();
    }
} else if (booking.getRoomId() != null) {
    // Fallback for single-room booking
    Room room = roomRepository.findById(booking.getRoomId());
    if (room != null) {
        roomNumber = room.getRoomNumber();
    }
}
```

**Update `hasPendingRequest()` check** - change to check by roomNumber:
```java
// Check pending request for THIS ROOM only
if (serviceRequestRepository.hasPendingRequestForRoom(bookingId, serviceType, roomNumber)) {
    return ServiceResult.failure("Phòng này đã có yêu cầu " + serviceType + " đang chờ xử lý");
}
```

### 2. ServiceRequestRepository.java - Thêm method mới

**Add method**:
```java
public boolean hasPendingRequestForRoom(int bookingId, String serviceType, String roomNumber) {
    String sql = "SELECT COUNT(*) FROM ServiceRequest WHERE booking_id = ? AND service_type = ? AND room_number = ? AND status IN ('Pending', 'In Progress')";
    // Returns count > 0 if exists
}
```

### 3. ServiceRequestService.java - Update `createCleaningRequest()`
```java
public ServiceResult createCleaningRequest(int bookingId, int customerId, Integer roomId) {
    return createRequest(bookingId, customerId, ServiceTypeConstant.CLEANING, null, "Normal", roomId);
}
```

### 4. CustomerController.java - Update handlers

**handleServiceRequestPost** - thêm roomId param:
```java
Integer roomId = parseIntParam(request, "roomId");
var result = serviceRequestService.createCleaningRequest(bookingId, account.getAccountId(), roomId);
```

**handleCreateRequestPost** - thêm roomId param:
```java
Integer roomId = parseIntParam(request, "roomId");
var result = serviceRequestService.createRequest(bookingId, account.getAccountId(), serviceType, description, priority, roomId);
```

### 5. booking-detail.jsp - Thêm dropdown chọn phòng

```jsp
<c:if test="${booking.isMultiRoom()}">
    <div class="mb-3">
        <label class="form-label">Chọn phòng</label>
        <select name="roomId" class="form-select" required>
            <option value="">-- Chọn phòng --</option>
            <c:forEach var="br" items="${booking.bookingRooms}">
                <c:if test="${not empty br.room}">
                    <option value="${br.room.roomId}">Phòng ${br.room.roomNumber}</option>
                </c:if>
            </c:forEach>
        </select>
    </div>
</c:if>
```

### 6. requests.jsp - Hiển thị đúng multi-room info

```jsp
<c:choose>
    <c:when test="${not empty b.room}">
        - Phòng ${b.room.roomNumber}
    </c:when>
    <c:when test="${not empty b.bookingRooms}">
        - ${b.bookingRooms.size()} phòng
        <c:forEach var="br" items="${b.bookingRooms}">
            <c:if test="${not empty br.room}">
                ${br.room.roomNumber}
            </c:if>
        </c:forEach>
    </c:when>
</c:choose>
```

---

## Todo List

- [ ] Thêm `hasPendingRequestForRoom()` vào ServiceRequestRepository
- [ ] Sửa `createRequest()` thêm `roomId` parameter
- [ ] Sửa `createCleaningRequest()` thêm `roomId` parameter
- [ ] Sửa `CustomerController.handleServiceRequestPost()`
- [ ] Sửa `CustomerController.handleCreateRequestPost()`
- [ ] Sửa `booking-detail.jsp` thêm dropdown chọn phòng
- [ ] Sửa `requests.jsp` hiển thị multi-room đúng
- [ ] Test với single-room booking
- [ ] Test với multi-room booking

---

## Risk Assessment

1. **Breaking change**: `createRequest()` signature thay đổi - cần update tất cả callers
2. **Existing callers**:
   - `CustomerController` (2 methods) - sẽ update
   - Có thể có tests - cần update

## Success Criteria

1. Single-room booking: hoạt động như trước
2. Multi-room booking: customer có thể chọn phòng cụ thể
3. Mỗi phòng trong multi-room có thể có independent service request
4. Staff hoàn thành cleaning -> đúng phòng chuyển Available
