# Yeu cau Dich vu (Service Request System)

## Tong quan nghiep vu

Tinh nang nay cho phep khach hang yeu cau cac dich vu trong qua trinh o lai:
- Danh sach loai dich vu: Cleaning, Maintenance, Food & Beverage, Supplies
- Khach hang gui yeu cau dich vu (co uu tien: Low, Normal, High)
- Staff nhan yeu cau, xu ly va danh dau hoan thanh
- Admin quan ly tat ca yeu cau (filter theo trang thai, loai)
- Theo doi trang thai yeu cau: Pending -> In Progress -> Completed/Cancelled/Rejected
- Xem lich su yeu cau va ghi chu tu staff

## Kien truc & Code Flow

### Customer Service Request Flow
```
Customer (JSP)
    |
    v
ServiceRequestController (customer/) - KHONG DUOC DEFINED
    |
    v
ServiceRequestService
    |
    +-> createRequest: Gui yeu cau dich vu
    +-> getBookingRequests: Xem yeu cau cua booking
    +-> cancelRequest: Huy yeu cau
    |
    v
ServiceRequestRepository
    |
    v
Database (service_request table)
```

### Staff Service Request Flow
```
Staff (JSP)
    |
    v
StaffServiceRequestController (/staff/service-requests/*)
    |
    +-> handleListGet: Xem danh sach yeu cau
    +-> handleAssignPost: Nhan yeu cau (assign to self)
    +-> handleCompletePost: Danh dau hoan thanh
    +-> handleRejectPost: Tu choi yeu cau
    |
    v
ServiceRequestService
    |
    +-> getPendingRequests: Lay yeu cau dang cho
    +-> getStaffRequests: Lay yeu cau duoc phan cong
    +-> assignToStaff: Nhan yeu cau
    +-> completeRequest: Danh dau hoan thanh
    +-> rejectRequest: Tu choi xu ly
    +-> getRequestStats: Thong ke yeu cau
    |
    v
ServiceRequestRepository
    |
    v
Database (service_request table)
```

### Admin Service Request Flow
```
Admin (JSP)
    |
    v
AdminServiceRequestController (/admin/service-requests)
    |
    +-> handleGet: Xem danh sach (filter by status/type)
    |
    v
ServiceRequestService
    |
    +-> getAllRequests: Lay tat ca yeu cau
    +-> getRequestsByStatus: Lay theo trang thai
    +-> getRequestStats: Thong ke
    |
    v
ServiceRequestRepository
    |
    v
Database (service_request table)
```

## Chi tiet tung ham

### ServiceRequest Entity

#### Fields
- requestId (int): ID yeu cau
- bookingId (int): ID dat phong lien quan
- staffId (Integer): ID nhan vien phu cap (null neu chua phan cong)
- serviceType (String): Loai dich vu (Cleaning, Maintenance, Food & Beverage, Supplies)
- requestTime (LocalDateTime): Thoi gian gui yeu cau
- status (String): Trang thai (Pending, In Progress, Completed, Cancelled, Rejected)
- description (String): Mo ta chi tiet ve yeu cau
- priority (String): Muc do uu tien (Low, Normal, High)
- notes (String): Ghi chu tu staff sau khi hoan thanh / tu choi
- completedTime (LocalDateTime): Thoi gian hoan thanh
- roomNumber (String): So phong (lay tu Room)
- booking (Booking - transient): Du lieu dat phong hien thi
- staffName (String - transient): Ten nhan vien xu ly

### ServiceTypeConstant

#### Fields
- CLEANING = "Cleaning" (Dọn phòng)
- MAINTENANCE = "Maintenance" (Bảo trì, sửa chữa)
- FOOD_BEVERAGE = "Food & Beverage" (Đồ ăn & nước uống)
- SUPPLIES = "Supplies" (Vật dụng, đồ dùng)

#### Methods
- isValid(String type): boolean - kiem tra loai dich vu hop le
- getDisplayName(String type): String - lay ten hien thi (tieng Viet)

### ServiceRequestStatusConstant

#### Fields
- PENDING = "Pending" (Cho xu ly)
- IN_PROGRESS = "In Progress" (Dang xu ly)
- COMPLETED = "Completed" (Hoan thanh)
- CANCELLED = "Cancelled" (Huy yeu cau)
- REJECTED = "Rejected" (Tu choi)

### ServiceRequestService

#### createRequest(int bookingId, int customerId, String serviceType, String description, String priority)
- Muc dich: Khach hang tao yeu cau dich vu
- Input: bookingId, customerId, serviceType, description, priority
- Output: ServiceResult object (success/failure message)
- Logic xu ly:
  1. Lay Booking theo bookingId
  2. Kiem tra booking ton tai va soan chinh cua customer nay
  3. Kiem tra trang thai booking = CHECKED_IN (chi co the yeu cau khi da nhan phong)
  4. Kiem tra serviceType co hop le khong (goi ServiceTypeConstant.isValid())
  5. Kiem tra xem da co yeu cau pending cua service type nay chua
     (Tranh khach hang gui nhieu yeu cau giong nhau)
  6. Lay so phong tu Booking.roomId -> Room.roomNumber
  7. Tao ServiceRequest:
     - bookingId = bookingId
     - serviceType = serviceType
     - status = PENDING
     - description = description
     - priority = priority neu co, neu khong thi = "Normal"
     - roomNumber = roomNumber
     - requestTime = LocalDateTime.now()
  8. Insert vao DB
  9. Tra ve ServiceResult.success("Yeu cau dich vu da duoc gui thanh cong")
- Xu ly loi:
  - Booking khong ton tai -> "Khong tim thay dat phong"
  - Booking chua checked in -> "Chi co the yeu cau dich vu khi da nhan phong"
  - Service type khong hop le -> "Loai dich vu khong hop le"
  - Da co yeu cau pending -> "Ban da co yeu cau [ServiceType] dang cho xu ly"
  - Insert that bai -> "Khong the tao yeu cau"
- Lien ket: BookingRepository, RoomRepository, ServiceRequestRepository, ServiceTypeConstant

#### createCleaningRequest(int bookingId, int customerId)
- Muc dich: Backward-compatible method de tao yeu cau cleaning
- Input: bookingId, customerId
- Output: ServiceResult object
- Logic xu ly: Goi createRequest(..., ServiceTypeConstant.CLEANING, null, "Normal")
- Lien ket: createRequest()

#### getBookingRequests(int bookingId)
- Muc dich: Lay danh sach yeu cau cua booking
- Input: bookingId
- Output: List<ServiceRequest>
- Lien ket: ServiceRequestRepository.findByBookingId()

#### cancelRequest(int requestId, int customerId)
- Muc dich: Khach hang huy yeu cau cua chinh minh
- Input: requestId, customerId
- Output: ServiceResult object
- Logic xu ly:
  1. Lay ServiceRequest theo requestId
  2. Kiem tra ton tai
  3. Lay Booking cua request
  4. Kiem tra booking soan chinh cua customer nay
  5. Kiem tra status = PENDING (chi co the huy yeu cau dang cho)
  6. Cap nhat status = CANCELLED
  7. Tra ve ServiceResult.success("Yeu cau dich vu da duoc huy")
- Xu ly loi:
  - Request khong ton tai -> "Khong tim thay yeu cau dich vu"
  - Booking khong soan chinh -> "Ban khong co quyen huy yeu cau nay"
  - Status khong phai Pending -> "Chi co the huy yeu cau dang o trang thai cho xu ly"
  - Update that bai -> "Khong the huy yeu cau"
- Lien ket: ServiceRequestRepository, BookingRepository

#### getAllRequests()
- Muc dich: Admin xem danh sach tat ca yeu cau
- Output: List<ServiceRequest>
- Lien ket: ServiceRequestRepository.findAll()

#### getPendingRequests()
- Muc dich: Staff xem yeu cau dang cho va dang xu ly
- Output: List<ServiceRequest> (status = PENDING hoac IN_PROGRESS)
- Lien ket: ServiceRequestRepository.findPendingAndInProgress()

#### getStaffRequests(int staffId)
- Muc dich: Lay yeu cau duoc phan cong cho staff
- Input: staffId
- Output: List<ServiceRequest>
- Lien ket: ServiceRequestRepository.findByStaffId()

#### getRequestsByStatus(String status)
- Muc dich: Lay yeu cau theo trang thai
- Input: status (Pending, In Progress, Completed, Cancelled, Rejected)
- Output: List<ServiceRequest>
- Lien ket: ServiceRequestRepository.findByStatus()

#### assignToStaff(int requestId, int staffId)
- Muc dich: Staff nhan yeu cau (assign to self)
- Input: requestId, staffId
- Output: ServiceResult object
- Logic xu ly:
  1. Lay ServiceRequest theo requestId
  2. Kiem tra ton tai
  3. Kiem tra status = PENDING (chi co the nhan yeu cau dang cho)
  4. Cap nhat staffId = staffId va status = IN_PROGRESS
  5. Tra ve ServiceResult.success("Da nhan xu ly yeu cau thanh cong")
- Xu ly loi:
  - Request khong ton tai -> "Khong tim thay yeu cau"
  - Status khong phai Pending -> "Chi co the nhan yeu cau dang o trang thai cho xu ly"
  - Update that bai -> "Khong the nhan yeu cau"
- Lien ket: ServiceRequestRepository

#### completeRequest(int requestId, int staffId, String notes)
- Muc dich: Staff danh dau yeu cau hoan thanh
- Input: requestId, staffId (staff dang xu ly), notes (ghi chu)
- Output: ServiceResult object
- Logic xu ly:
  1. Lay ServiceRequest theo requestId
  2. Kiem tra ton tai
  3. Kiem tra status = IN_PROGRESS
  4. Kiem tra staffId cua request = staffId truy en vao
     (Chi staff duoc phan cong moi co the danh dau hoan thanh)
  5. Cap nhat status = COMPLETED, completedTime = now(), notes = notes
  6. Tra ve ServiceResult.success("Yeu cau da duoc hoan thanh")
- Xu ly loi:
  - Request khong ton tai -> "Khong tim thay yeu cau"
  - Status khong phai In Progress -> "Chi co the hoan thanh yeu cau dang xu ly"
  - Staff khong duoc phan cong -> "Ban khong duoc phan cong xu ly yeu cau nay"
  - Update that bai -> "Khong the hoan thanh yeu cau"
- Lien ket: ServiceRequestRepository

#### rejectRequest(int requestId, int staffId, String notes)
- Muc dich: Staff tu choi (khong the) xu ly yeu cau
- Input: requestId, staffId, notes (ly do tu choi)
- Output: ServiceResult object
- Logic xu ly:
  1. Lay ServiceRequest theo requestId
  2. Kiem tra ton tai
  3. Kiem tra status = IN_PROGRESS
  4. Kiem tra staffId = staffId
  5. Cap nhat status = REJECTED, completedTime = now(), notes = notes
  6. Tra ve ServiceResult.success("Yeu cau da bi tu choi")
- Xu ly loi: Tuong tu completeRequest()
- Lien ket: ServiceRequestRepository

#### getRequestStats()
- Muc dich: Lay thong ke yeu cau (cho dashboard)
- Output: Map<String, Integer> chua:
  - "totalToday": Tong yeu cau hom nay
  - "pending": So yeu cau dang cho
  - "inProgress": So yeu cau dang xu ly
  - "completedToday": So yeu cau hoan thanh hom nay
  - "total": Tong tat ca yeu cau (all statuses)
- Logic xu ly: Query tung thong ke tu repository
- Lien ket: ServiceRequestRepository (countToday, countByStatus, countTodayByStatus)

### StaffServiceRequestController

#### doGet (path=/staff/service-requests)
- Muc dich: Staff xem danh sach yeu cau (voi filter by tab va type)
- Input: tab (all/my), type (filter by service type)
- Output: Forward den /WEB-INF/views/staff/service-requests/list.jsp
- Logic xu ly:
  1. Lay account (staff) tu session
  2. Kiem tra tab parameter:
     - "my" -> lay yeu cau duoc phan cong cho staff nay
     - Khac (mac dinh "all") -> lay tat ca yeu cau pending va in progress
  3. Neu type parameter thi filter by serviceType
  4. Lay thong ke yeu cau
  5. Set attributes:
     - serviceRequests: danh sach yeu cau
     - currentTab: tab hien tai
     - typeFilter: filter type
     - stats: thong ke
     - activePage: "service-requests"
     - pageTitle: "Yeu cau dich vu"
  6. Forward den list.jsp
- Lien ket: SessionHelper.getLoggedInAccount(), ServiceRequestService

#### doPost (path=/staff/service-requests/assign)
- Muc dich: Staff nhan yeu cau (assign to self)
- Input: requestId
- Output: Redirect ve /staff/service-requests voi message
- Logic xu ly:
  1. Lay account (staff) tu session
  2. Parse requestId
  3. Goi ServiceRequestService.assignToStaff(requestId, staffId)
  4. Set flash message (success hoac error)
  5. Redirect ve service-requests page
- Lien ket: ServiceRequestService, SessionHelper

#### doPost (path=/staff/service-requests/complete)
- Muc dich: Staff danh dau yeu cau hoan thanh
- Input: requestId, notes (ghi chu)
- Output: Redirect ve /staff/service-requests?tab=my
- Logic xu ly:
  1. Lay account (staff) tu session
  2. Parse requestId va notes
  3. Goi ServiceRequestService.completeRequest(requestId, staffId, notes)
  4. Set flash message
  5. Redirect ve "my" tab
- Lien ket: ServiceRequestService, SessionHelper

#### doPost (path=/staff/service-requests/reject)
- Muc dich: Staff tu choi yeu cau
- Input: requestId, notes (ly do)
- Output: Redirect ve /staff/service-requests?tab=my
- Logic xu ly: Tuong tu completeRequest nhung goi rejectRequest()
- Lien ket: ServiceRequestService, SessionHelper

### AdminServiceRequestController

#### doGet (path=/admin/service-requests)
- Muc dich: Admin xem danh sach tat ca yeu cau (co filter by status va type)
- Input: status (filter by status), type (filter by service type)
- Output: Forward den /WEB-INF/views/admin/service-requests/list.jsp
- Logic xu ly:
  1. Kiem tra status parameter:
     - Neu co thi goi ServiceRequestService.getRequestsByStatus(status)
     - Neu khong thi goi ServiceRequestService.getAllRequests()
  2. Neu type parameter thi filter list by serviceType
  3. Lay thong ke yeu cau
  4. Set attributes:
     - serviceRequests: danh sach sau filter
     - stats: thong ke
     - statusFilter: status da filter
     - typeFilter: type da filter
     - activePage: "service-requests"
     - pageTitle: "Quan ly yeu cau dich vu"
  5. Forward den list.jsp
- Lien ket: ServiceRequestService

## Luong du lieu (Data Flow)

### Customer Request Service Flow
```
1. Customer xem phong sau khi checked in
   - Hien thi button / menu "Request Service"

2. POST /customer/service-requests/create
   - ServiceRequestService.createRequest(bookingId, customerId, serviceType, description, priority)
   - Validate booking status (CHECKED_IN)
   - Validate service type (Cleaning/Maintenance/Food & Beverage/Supplies)
   - Check pending request (avoid duplicate)
   - Get room number tu Booking.roomId
   - Insert ServiceRequest(status=PENDING)
   - Return success message

3. Customer xem yeu cau da gui
   - Hien thi danh sach yeu cau cua booking
   - Hien thi trang thai (Pending, In Progress, Completed)
   - Cho phep cancel (chi neu Pending)

4. POST /customer/service-requests/cancel?requestId=X
   - ServiceRequestService.cancelRequest(requestId, customerId)
   - Cap nhat status = CANCELLED
```

### Staff Accept & Complete Flow
```
1. Staff xem danh sach yeu cau
   - GET /staff/service-requests
   - Default tab "all" hien thi PENDING va IN_PROGRESS requests
   - Filter by service type (Cleaning, Maintenance, etc.)

2. Staff nhan yeu cau (assign to self)
   - POST /staff/service-requests/assign?requestId=X
   - ServiceRequestService.assignToStaff(requestId, staffId)
   - Cap nhat staffId va status = IN_PROGRESS
   - Yeu cau xuat hien trong tab "my"

3. Staff xu ly yeu cau va danh dau hoan thanh
   - POST /staff/service-requests/complete?requestId=X&notes=...
   - ServiceRequestService.completeRequest(requestId, staffId, notes)
   - Cap nhat status = COMPLETED, completedTime = now()
   - Neu co van de, co the tu choi:
     - POST /staff/service-requests/reject?requestId=X&notes=...
     - Cap nhat status = REJECTED

4. Customer xem trang thai cap nhat (Completed hoac Rejected)
   - Hien thi ghi chu tu staff neu co
```

### Admin Monitoring Flow
```
1. Admin xem dashboard hoac service-requests page
   - GET /admin/service-requests
   - Hien thi tat ca yeu cau (Pending, In Progress, Completed, etc.)
   - Stats: today's requests, pending count, in progress count
   - Filter by status hoac service type

2. Admin co the:
   - Xem chi tiet yeu cau (customer, room, description)
   - Xem staff duoc phan cong
   - Xem ghi chu hoan thanh / tu choi
   - Theo doi completion rate
```

## Bao mat & Phan quyen

### Authentication & Authorization
- Customer chi co the tao / xem / huy yeu cau cua booking cua chinh minh
- Staff chi co the:
  - Nhan yeu cau (assign to self)
  - Hoan thanh / tu choi yeu cau duoc phan cong cho minh
- Admin co the xem tat ca yeu cau va thong ke

### Input Validation
- Service type phai valid (Cleaning, Maintenance, Food & Beverage, Supplies)
- Priority phai valid (Low, Normal, High) hoac default "Normal"
- Description can be any text (no special restrictions)
- Booking status phai = CHECKED_IN de gui yeu cau

### Business Rules
- Chi tao 1 yeu cau pending cho moi service type tren 1 booking
  (Tranh spam, khach hang yeu cau 5 lan cleaning giong nhau)
- Staff chi co the complete/reject yeu cau duoc phan cong cho minh
- Chi co the huy yeu cau khi dang Pending (khong the huy khi In Progress)

## Hang so & Quy tac (Constants)

### Service Types
- Cleaning (Dọn phòng)
- Maintenance (Bảo trì, sửa chữa dung cu)
- Food & Beverage (Dịch vụ thức ăn, đồ uống)
- Supplies (Vật dụng, dung cụ bổ sung)

### Status Transitions
```
PENDING
  |
  +-> IN_PROGRESS (staff accept)
  |     |
  |     +-> COMPLETED (staff finish)
  |     +-> REJECTED (staff cannot do it)
  |
  +-> CANCELLED (customer cancel)
```

### Priority Levels
- Low (Uu tien thap - khong khan)
- Normal (Uu tien binh thuong - mac dinh)
- High (Uu tien cao - can toc do)

## Phuong phap Query & Performance

### Queries su dung
- findByBookingId(bookingId): Tim yeu cau theo booking
- findAll(): Lay tat ca yeu cau (admin)
- findByStatus(status): Lay theo trang thai
- findByStaffId(staffId): Lay yeu cau cua staff
- findPendingAndInProgress(): Lay yeu cau dang cho + dang xu ly (staff dashboard)
- hasPendingRequest(bookingId, serviceType): Kiem tra pending trung (efficient)
- countToday(), countByStatus(), countTodayByStatus(): Thong ke

### Performance Optimization
- Index on bookingId, staffId, status fields
- Pagination cho danh sach (limit 20-50 requests/page)
- Cache thong ke (update every 5 minutes)
- Query with JOINs de lay chi tiet booking va staff name

## Phuong phap Feedback Integration

### Feedback-like Feature (Optional)
- Sau khi yeu cau completed, khach hang co the danh gia chat luong dich vu
- Rating 1-5 sao cho service execution
- Comment ve dich vu (chanh phuc, de xuat cai tien)

## Next Steps & Dependencies

- Implement notification khi staff phan cong yeu cau
- Add email alert cho admin khi co yeu cau moi
- Integrate voi inventory system (tracking supplies used)
- Add time estimate va actual time spent tracking
- Implement SLA (Service Level Agreement) monitoring
- Add customer feedback on service quality
- Create service request analytics / reporting dashboard
