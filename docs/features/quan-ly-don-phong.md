# Quan ly Don phong

## Tong quan nghiep vu

Tính năng quản lý dọn phòng (cleaning management) cho phép nhân viên theo dõi và cập nhật trạng thái dọn dẹp các phòng sau khi khách checkout hoặc phòng cần vệ sinh. Khi một phòng chuyển sang trạng thái "CLEANING" (đang dọn), nhân viên có thể xem danh sách những phòng cần dọn, sau đó đánh dấu phòng đã hoàn thành dọn dẹp để chuyển về trạng thái "AVAILABLE" (sẵn sàng cho khách mới).

Đây là một quy trình quan trọng để đảm bảo phòng sạch sẽ trước khi cho khách ở, giảm thời gian phòng "down" và tối ưu hóa tỷ lệ lấp đầy phòng khách sạn.

## Kien truc & Code Flow

```
Request (GET/POST) -> StaffCleaningController
                   -> StaffCleaningService (business logic)
                   -> RoomRepository (data access)
                   -> Database (Room table - status update)
```

### Luong goi dich vu chinh:
1. Xem danh sách phòng cần dọn: GET /staff/cleaning -> Controller -> Service -> Repository -> JSP view
2. Đánh dấu phòng đã dọn xong: POST /staff/cleaning/update -> Controller -> Service -> Repository -> update status
3. Xem chi tiết phòng: GET /staff/rooms/detail?id=X (có nút "Mark as Clean")
4. Cập nhật trạng thái phòng từ CLEANING -> AVAILABLE

## Chi tiet tung ham

### StaffCleaningController

#### handleCleaningList(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Hiển thị danh sách tất cả phòng đang trong quá trình dọn (CLEANING status)
- **Input**: request, response
- **Output**: Danh sách Room objects với status=CLEANING được forward đến view
- **Logic xu ly**:
  1. Gọi staffCleaningService.getRoomsNeedingCleaning()
  2. Nhận về List<Room> chứa tất cả phòng có status="CLEANING"
  3. Kiểm tra parameter "success":
     - Nếu success="cleaned" -> set attribute success message: "Đã đánh dấu phòng hoàn thành dọn dẹp!"
  4. Set attributes:
     - "rooms": danh sách phòng
     - "activePage": "cleaning"
     - "pageTitle": "Quản lý dọn phòng"
  5. Forward request đến /WEB-INF/views/staff/cleaning/list.jsp
- **Xu ly loi**: Không có
- **Lien ket**: StaffCleaningService.getRoomsNeedingCleaning()

#### handleUpdateCleaning(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Xử lý yêu cầu cập nhật trạng thái phòng từ CLEANING -> AVAILABLE
- **Input**: request (parameters: roomId, status), response
- **Output**: Redirect hoặc forward view
- **Logic xu ly**:
  1. Parse parameter "roomId" thành String, kiểm tra null/empty
     - Nếu null/empty -> send error 400 "Missing room ID"
  2. Parse roomId thành int (nếu fail -> NumberFormatException -> send error 400)
  3. Kiểm tra parameter "status":
     - Nếu status = "Available" (case-sensitive):
       a. Gọi staffCleaningService.markRoomAsClean(roomId)
       b. Nếu success=true:
          - Lấy header "Referer" để kiểm tra người dùng từ đâu
          - Nếu referer chứa "/staff/rooms/detail" -> redirect đến /staff/rooms/detail?id=roomId
          - Ngược lại -> redirect đến /staff/cleaning?success=cleaned
          - Return (kết thúc xử lý)
       c. Nếu success=false:
          - Set error attribute "Không thể cập nhật trạng thái phòng"
          - Call handleCleaningList() để hiển thị danh sách lại
  4. Nếu status khác "Available" -> không làm gì, just set error và display list
- **Xu ly loi**:
  - NumberFormatException: send error 400 "Invalid room ID"
  - Null roomId: send error 400 "Missing room ID"
  - Update fail: set error message, forward list view
- **Lien ket**: StaffCleaningService.markRoomAsClean()

### StaffCleaningService

#### getRoomsNeedingCleaning()
- **Muc dich**: Lấy danh sách tất cả phòng đang cần dọn (status = CLEANING)
- **Input**: Không có
- **Output**: List<Room> chứa tất cả phòng với status=CLEANING
- **Logic xu ly**:
  1. Gọi roomRepository.findByStatus(RoomStatus.CLEANING)
  2. Return danh sách phòng
- **Xu ly loi**: Không có (nếu không có phòng nào, return empty list)
- **Lien ket**: RoomRepository.findByStatus()

#### countRoomsNeedingCleaning()
- **Muc dich**: Đếm số lượng phòng cần dọn (dùng cho dashboard/stats)
- **Input**: Không có
- **Output**: int - số phòng đang CLEANING
- **Logic xu ly**:
  1. Gọi roomRepository.countByStatus(RoomStatus.CLEANING)
  2. Return số lượng
- **Xu ly loi**: Không có
- **Lien ket**: RoomRepository.countByStatus()

#### markRoomAsClean(int roomId)
- **Muc dich**: Cập nhật trạng thái phòng từ CLEANING -> AVAILABLE
- **Input**: roomId
- **Output**: boolean - true nếu update thành công, false nếu fail
- **Logic xu ly**:
  1. Gọi roomRepository.updateStatus(roomId, RoomStatus.AVAILABLE)
  2. Return (rows affected > 0)
- **Xu ly loi**: Không có (return false nếu update fail)
- **Lien ket**: RoomRepository.updateStatus()

#### getRoomDetail(int roomId)
- **Muc dich**: Lấy chi tiết phòng kèm thông tin loại phòng (dùng cho detail page)
- **Input**: roomId
- **Output**: Room object với thông tin loại phòng
- **Logic xu ly**:
  1. Gọi roomRepository.findWithRoomType(roomId)
  2. Return Room object
- **Xu ly loi**: Return null nếu không tìm thấy
- **Lien ket**: RoomRepository.findWithRoomType()

### RoomStatus Constant

- **AVAILABLE**: "Available" - phòng sẵn sàng cho khách mới
- **CLEANING**: "Cleaning" - phòng đang dọn dẹp
- **OCCUPIED**: "Occupied" - phòng đang có khách ở
- **MAINTENANCE**: "Maintenance" - phòng đang bảo trì
- Các giá trị này được sử dụng để filter & update trong database

### RoomRepository Methods

#### findByStatus(String status)
- **Muc dich**: Lấy danh sách phòng theo trạng thái
- **Input**: status (ví dụ: "Cleaning")
- **Output**: List<Room>
- **SQL**: `SELECT * FROM Room WHERE status = ?`

#### countByStatus(String status)
- **Muc dich**: Đếm phòng theo trạng thái
- **Input**: status
- **Output**: int

#### updateStatus(int roomId, String newStatus)
- **Muc dich**: Cập nhật trạng thái phòng
- **Input**: roomId, newStatus
- **Output**: int - số rows affected
- **SQL**: `UPDATE Room SET status = ? WHERE room_id = ?`

#### findWithRoomType(int roomId)
- **Muc dich**: Lấy phòng kèm JOIN với RoomType (để lấy typeName, basePrice, etc.)
- **Input**: roomId
- **Output**: Room object với thông tin type
- **SQL**: `SELECT r.*, rt.type_name, rt.base_price FROM Room r JOIN RoomType rt ON r.type_id = rt.type_id WHERE r.room_id = ?`

## Luong du lieu (Data Flow)

### Xem danh sách phòng cần dọn:
```
1. Nhân viên truy cập /staff/cleaning
2. StaffCleaningController.handleCleaningList():
   - Gọi StaffCleaningService.getRoomsNeedingCleaning()
   - Query DB: SELECT * FROM Room WHERE status = 'Cleaning'
   - Return List<Room>
3. Controller forward đến list.jsp
4. View hiển thị bảng: room_number, room_type, current_status, action buttons
5. Mỗi row có button "Mark as Clean" POST /staff/cleaning/update
```

### Đánh dấu phòng đã dọn xong:
```
1. Nhân viên click "Mark as Clean" button trên phòng X
2. Submit form POST /staff/cleaning/update
   Parameters:
   - roomId: X
   - status: "Available"
3. StaffCleaningController.handleUpdateCleaning():
   - Parse roomId = X, status = "Available"
   - Kiểm tra status = "Available" -> đúng
   - Gọi StaffCleaningService.markRoomAsClean(X)
   - Service gọi RoomRepository.updateStatus(X, "Available")
   - SQL: UPDATE Room SET status = 'Available' WHERE room_id = X
4. Update thành công -> return true
5. Controller kiểm tra Referer:
   - Nếu từ /staff/rooms/detail -> redirect đến detail page
   - Nếu từ /staff/cleaning -> redirect đến cleaning list với success=cleaned
6. View hiển thị success message: "Đã đánh dấu phòng hoàn thành dọn dẹp!"
7. Danh sách refresh, phòng X không còn trong list (status change)
```

### Luong khi phòng cần dọn:
```
1. Khách checkout từ phòng X
2. BookingService hoặc RoomController cập nhật: Room status = "Cleaning"
3. Lập tức, phòng X xuất hiện trong danh sách /staff/cleaning
4. Nhân viên dọn phòng
5. Nhân viên click Mark as Clean
6. Phòng chuyển về "Available"
7. Phòng sẵn sàng cho khách mới

Alternative flow từ detail page:
1. Nhân viên xem /staff/rooms/detail?id=X
2. Nếu status = Cleaning, có button "Mark as Clean"
3. Click button, POST /staff/cleaning/update?roomId=X&status=Available
4. Update thành công -> redirect đến same detail page
5. Page refresh, status = Available
6. Button biến mất
```

## Bao mat & Phan quyen

- Chỉ staff (nhân viên) có quyền xem & update cleaning status (StaffAuthFilter)
- Không có permission cấp chi tiết, tất cả staff đều có quyền dọn bất kỳ phòng nào
- Không có audit log (không track ai dọn phòng khi), có thể cần thêm feature này
- Số lượng phòng cần dọn được lấy từ DB realtime, không cache
- SQL update sử dụng PreparedStatement (tránh SQL injection)
- Không có rate limiting (nhân viên có thể spam update, nhưng DB chỉ update một lần)

## Lien ket doi tuong

- StaffCleaningService: sử dụng RoomRepository
- StaffCleaningController: được bảo vệ bằng StaffAuthFilter
- StaffDashboardController: có thể gọi countRoomsNeedingCleaning() để hiển thị stats
- StaffRoomController: detail page có thể gọi getRoomDetail() & show "Mark as Clean" button
- BookingService: khi booking checkout, cập nhật status -> "Cleaning"
- RoomService: manage room status transitions

## Cac bien va constants

- RoomStatus constants:
  - AVAILABLE = "Available"
  - CLEANING = "Cleaning"
  - OCCUPIED = "Occupied"
  - MAINTENANCE = "Maintenance"
- HTTP parameter: "status" (string, case-sensitive)
- HTTP parameter: "roomId" (string, parse to int)
- Referer header: để phát hiện user từ đâu (detail page vs list page)

## Di eu kien & edge cases

1. **Phòng không tồn tại**: Nếu roomId không tìm thấy -> update fail -> return false
2. **Room status khác "Cleaning"**: Service vẫn cập nhật (không check current status)
   - Có thể là issue nếu phòng đã Available, click Mark as Clean lại
   - Recommendation: controller nên check status trước khi call markRoomAsClean()
3. **Concurrent updates**: Nếu 2 nhân viên click Mark as Clean cùng lúc
   - Cả 2 sẽ update -> chỉ 1 lần update thành công
   - Không có issue (status chỉ update thành Available, idempotent)
4. **NumberFormatException**: Nếu roomId không phải int
   - Controller bắt exception -> return 400 error
5. **Missing roomId**: Nếu parameter roomId = null/empty
   - Controller check trước parse -> return 400 error

## Summary

Tính năng quản lý dọn phòng là một công cụ quan trọng để quản lý vòng đời phòng sau checkout. Kiến trúc tương đối đơn giản: Controller nhận request -> Service gọi Repository -> Update Room status trong DB. Không có validation phức tạp, chỉ cập nhật status từ CLEANING -> AVAILABLE. Tính năng có thể được mở rộng thêm: audit log (ai dọn khi nào), khảo sát chất lượng, thời gian dọn trung bình, etc.
