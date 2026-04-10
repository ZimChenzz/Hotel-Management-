# Phase 3: Verify và Fix đồng bộ Cleaning với Service Request

## Đã thực hiện (từ session trước)

### Fix trong `ServiceRequestService.completeRequest()`
Đã thêm logic để cập nhật room status khi hoàn thành cleaning request:

```java
if (serviceRequestRepository.complete(requestId, notes) > 0) {
    // If this is a CLEANING request, also update room status to AVAILABLE
    if (ServiceTypeConstant.CLEANING.equals(request.getServiceType())
            && request.getRoomNumber() != null) {
        Room room = roomRepository.findByRoomNumber(request.getRoomNumber());
        if (room != null) {
            roomRepository.updateStatus(room.getRoomId(), RoomStatus.AVAILABLE);
        }
    }
    return ServiceResult.success("Yêu cầu đã được hoàn thành");
}
```

### Debug logging đã thêm
1. `ServiceRequestService.completeRequest()` - log serviceType, roomNumber, update result
2. `StaffCleaningService.getRoomsNeedingCleaning()` - log số phòng đang có trạng thái CLEANING

---

## Vấn đề cần verify

### Vấn đề 1: Thẻ vẫn còn trên trang cleaning sau khi hoàn thành

**Có thể nguyên nhân**:
1. Server chưa restart sau khi deploy code mới
2. Trình duyệt đang cache trang cũ
3. Logic tìm phòng có vấn đề

**Debug steps**:
1. Restart server
2. Hard refresh trang cleaning (Ctrl+F5)
3. Kiểm tra console log cho debug output

### Vấn đề 2: Staff hoàn thành qua "Yêu cầu dịch vụ" nhưng cleaning page không cập nhật

**Root cause đã xác định**:
- Trước fix: `completeRequest()` không cập nhật room status
- Sau fix: đã thêm logic cập nhật room status

**Cần verify**:
1. Khi hoàn thành cleaning request qua service-requests page
2. Room status chuyển từ CLEANING -> AVAILABLE
3. Cleaning page không còn hiển thị phòng đó

---

## Verification Checklist

- [ ] Restart server với code mới
- [ ] Mở cleaning page, kiểm tra debug log "getRoomsNeedingCleaning"
- [ ] Hoàn thành cleaning request qua service-requests
- [ ] Kiểm tra debug log "completeRequest"
- [ ] Refresh cleaning page -> phòng đã hoàn thành không còn hiển thị
- [ ] Verify trong database: Room status = AVAILABLE

---

## Backup Plan nếu fix không hoạt động

Nếu sau khi restart và clear cache mà vấn đề vẫn xảy ra:

### Nguyên nhân có thể khác
1. `roomRepository.updateStatus()` không hoạt động đúng
2. Room không được tìm thấy qua `findByRoomNumber()`
3. Có nhiều service request cùng roomNumber

### Debug thêm
1. Log SQL query được thực thi
2. Log kết quả `updateStatus()`
3. Check xem có exception bị swallow không
