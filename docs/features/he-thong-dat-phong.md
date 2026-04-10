# He Thong Dat Phong

## Tong quan nghiep vu

He thong dat phong cho phep khach hang dat phong, tinh toan gia voi cac yeu to: gia co ban, khuyen mai, voucher, tien dat. Khach hang phai xac nhan thong tin truoc khi thanh toan. Staff quan ly danh sach booking, giao phong, quan ly khach o, xu ly check-out. Cac booking co trang thai: Pending (chua thanh toan), Confirmed (da thanh toan), CheckedIn (da nhap phong), CheckedOut, Cancelled. Phong duoc tu dong phan cong khi tao booking, staff co the giao lai khi check-in.

## Kien truc & Code Flow

### Khong gian phong

```
Customer/Staff/Admin GUI
   |
   v
BookingController / StaffBookingController (common, staff endpoints)
   |
   v
BookingService / StaffBookingService
   |
   v
BookingRepository / RoomRepository / RoomTypeRepository / VoucherRepository / PromotionRepository / OccupantRepository
   |
   v
Database (Booking, Room, RoomType, Voucher, Promotion, Occupant, Payment, Invoice)
```

### Trang thai Booking

```
Pending (chua thanh toan)
  |
  v
Confirmed (da thanh toan)
  |
  v
CheckedIn (da check-in tai quay)
  |
  v
CheckedOut (da check-out)
  |
Cancelled (huy)
```

### Loai dat phong

- Online Booking: Customer tu trang web (auto assign phong)
- Walk-in: Staff tao khi khach den ko co dat truoc (manual assign + tim phong)

## Chi tiet tung ham

### Entity Classes

#### Booking
- **Muc dich**: Dai dien mot don dat phong
- **Thuoc tinh**:
  - bookingId: Khoa chinh
  - customerId: Tham chieu customer (Account)
  - roomId: Phong gan (nullable, co the chua gan khi pending)
  - typeId: Loai phong duoc chon
  - voucherId: Voucher ap dung (nullable)
  - bookingDate: Thoi diem tao booking
  - checkInExpected: Thoi gian nhan phong du kien
  - checkOutExpected: Thoi gian tra phong du kien
  - checkInActual: Thoi gian nhan phong thuc te (sau khi check-in)
  - checkOutActual: Thoi gian tra phong thuc te
  - totalPrice: Tong tien sau cac khau tru
  - paymentType: FULL / DEPOSIT
  - depositAmount: So tien dat (khac vs totalPrice)
  - status: Pending / Confirmed / CheckedIn / CheckedOut / Cancelled
  - note: Ghi chu them
  - room: Lazy load
  - roomType: Lazy load
  - customer: Lazy load
- **Business logic**:
  - Khi pending: roomId co the null, guest name luu trong Occupant
  - Khi checked-in: roomId phai gan, checkInActual duoc set
  - Khi checked-out: checkOutActual duoc set

### Utility Classes

#### BookingCalcResponse
- **Muc dich**: Ket qua tinh toan gia dat phong chi tiet
- **Thuoc tinh**:
  - roomType: Loai phong
  - room: Phong (neu da select)
  - checkIn / checkOut: Thoi gian
  - nights: So dem tinh toan
  - subtotal: basePrice * nights
  - promotion: Promotion dang ap dung (neu co)
  - promotionDiscount: So tien giam tu promotion
  - discount: So tien giam tu voucher
  - total: subtotal - promotionDiscount - discount
  - voucher: Voucher duoc su dung
  - depositPercent: Ty le tien dat (%)
  - depositAmount: So tien dat (fixed = total * depositPercent / 100)
  - standardRoom: true neu khong yeu cau tien dat
  - pricePerHour: Gia theo gio (dung cho extension sau)

#### BookingResult
- **Muc dich**: Ket qua tao booking (success/failure)
- **Thuoc tinh**:
  - success: boolean
  - message: Chi tiet (loi hoac thanh cong)
  - booking: Booking object (neu thanh cong)
- **Static methods**:
  - success(message, booking)
  - failure(message) -> return new BookingResult(false, message, null)

#### WalkInCustomerResult
- **Muc dich**: Ket qua tim kiem/tao customer walk-in
- **Thuoc tinh**:
  - accountId: ID khach
  - status: FOUND_BY_PHONE / FOUND_BY_EMAIL / CREATED
  - existingName / existingPhone: Thong tin khach co san (neu FOUND)
  - generatedPassword: Mat khau auto-gen (neu CREATED)
  - email: Email

### Service Classes

#### BookingService (Customer/Public)

##### calculateBooking(typeId, roomId, checkIn, checkOut, voucherCode)
- **Muc dich**: Tinh toan chi tiet gia dat phong
- **Input**:
  - typeId: Loai phong da chon
  - roomId: Phong cu the (da select)
  - checkIn: Thoi gian nhan phong
  - checkOut: Thoi gian tra phong
  - voucherCode: Ma voucher (nullable)
- **Output**: BookingCalcResponse voi chi tiet tinh toan
- **Logic xu ly**:
  1. Query roomType = roomTypeRepository.findById(typeId)
  2. Query room = roomRepository.findById(roomId)
  3. Validate: neu room.typeId != typeId -> return null
  4. Tinh nights = calculateNights(checkIn, checkOut)
  5. Tinh subtotal = basePrice * nights
  6. Tim active promotion: promotion = promotionRepository.findActiveByTypeId(typeId)
  7. Neu co promotion:
     - promotionDiscount = (basePrice * discountPercent / 100) * nights
     - Cap promotionDiscount <= subtotal
  8. Neu voucherCode co:
     - voucher = voucherRepository.findByCode(voucherCode)
     - Neu voucher active va subtotal >= minOrderValue:
       - voucherDiscount = voucher.discountAmount
       - voucherDiscount = min(voucherDiscount, remaining after promotion)
  9. total = subtotal - promotionDiscount - voucherDiscount
  10. depositPercent = roomType.depositPercent (default = 0 neu standard room)
  11. depositAmount = total * depositPercent / 100
  12. Tao BookingCalcResponse voi tat ca chi tiet
- **Validation**:
  - typeId, roomId phai hop le
  - room phai thuoc type duoc chon
- **Lien ket**: RoomTypeRepository, RoomRepository, PromotionRepository, VoucherRepository

##### getAvailableRooms(typeId, checkIn, checkOut)
- **Muc dich**: Lay danh sach phong co san trong thoi gian
- **Output**: List<Room> khong xung dot
- **Logic**: Goi RoomRepository.findAvailableForDates()

##### getOccupiedDateRanges(typeId)
- **Muc dich**: Lay danh sach khoang thoi gian dang bi dat cho loai phong
- **Output**: List<LocalDateTime[]> - cac khoang [checkInExpected, checkOutExpected]
- **Dung**: Hien thi calendar "ngay buan" tren giao dien booking
- **Logic**: Goi BookingRepository.findOccupiedDateRangesByTypeId()

##### createBooking(customerId, roomId, checkIn, checkOut, totalPrice, voucherId, note, occupants, paymentType, depositAmount)
- **Muc dich**: Tao booking moi (sau payment)
- **Input**:
  - customerId: ID khach
  - roomId: Phong gan
  - checkIn / checkOut: Thoi gian
  - totalPrice: Tong tien tinh toan
  - voucherId: ID voucher (nullable)
  - note: Ghi chu (nullable)
  - occupants: List<Occupant> - danh sach khach o
  - paymentType: FULL / DEPOSIT
  - depositAmount: So tien da coc (neu DEPOSIT)
- **Output**: BookingResult (success/failure)
- **Logic xu ly**:
  1. Validate thoi gian:
     - checkIn phai >= hien tai (future date)
     - checkOut > checkIn
     - Khoang thoi gian <= 30 ngay
  2. Check phong co san: isRoomAvailable(roomId, checkIn, checkOut)
  3. Query room = roomRepository.findById(roomId)
  4. Tao Booking object:
     - setCustomerId, setRoomId, setTypeId = room.typeId
     - setCheckInExpected, setCheckOutExpected
     - setTotalPrice, setVoucherId, setNote
     - setStatus = BookingStatus.PENDING
     - setPaymentType
     - setDepositAmount
  5. Insert booking: bookingId = bookingRepository.insert(booking)
  6. Neu bookingId <= 0 -> return failure
  7. Voi moi occupant (neu co):
     - Validate name khong rong
     - setBookingId = bookingId
     - occupantRepository.insert()
  8. Return success(booking)
- **Xu ly loi**:
  - Ngay khong hop le, phong khong co san, booking toi da 30 ngay
- **Lien ket**: RoomRepository, BookingRepository, OccupantRepository

##### getBookingById(bookingId)
- **Muc dich**: Lay chi tiet booking
- **Output**: Booking
- **Special**: Tu dong cancel neu booking overdue
  - Neu status = Pending hoac Confirmed
  - Va checkInExpected + 1 phut < hien tai
  - -> tu dong cancel + tra ve status = Cancelled
- **Logic**: Goi BookingRepository.findByIdWithDetails()

##### getCustomerBookings(customerId)
- **Output**: List<Booking> cua customer, order by booking_date DESC

##### updateBookingStatus(bookingId, status)
- **Output**: boolean
- **Lien ket**: BookingRepository

##### getBookingOccupants(bookingId)
- **Output**: List<Occupant>

##### cancelBooking(bookingId, customerId)
- **Muc dich**: Huy booking (customer tu huy truoc khi check-in)
- **Output**: ServiceResult (success/failure message)
- **Logic xu ly**:
  1. Query booking = bookingRepository.findById(bookingId)
  2. Validate: booking ton tai va customerId trung hop
  3. Validate: status phai la Pending hoac Confirmed (ko huy duoc khi da checked-in)
  4. Goi bookingRepository.updateStatus(bookingId, CANCELLED)
  5. Return success neu cap nhat thanh cong

##### isOverdueBooking(booking)
- **Muc dich**: Kiem tra booking da qua han check-in khong
- **Logic**: checkInExpected + 1 phut < hien tai = overdue

#### StaffBookingService

##### getActiveBookings()
- **Muc dich**: Lay booking dang hoat dong (staff view)
- **Output**: List<Booking> voi status IN (Pending, Confirmed, CheckedIn)

##### getBookingsByStatus(status)
- **Output**: List<Booking> voi status chi dinh

##### getAllBookings()
- **Output**: List<Booking> toan bo

##### getBookingDetail(bookingId)
- **Output**: Booking voi chi tiet day du

##### countByStatus(status)
- **Output**: int

##### assignRoom(bookingId, roomId)
- **Muc dich**: Giao phong khi guest check-in (staff verify)
- **Logic xu ly**:
  1. Query booking
  2. Goi bookingRepository.updateRoomId(bookingId, roomId)
  3. Goi bookingRepository.updateStatus(bookingId, CHECKED_IN)
  4. Goi bookingRepository.updateCheckInActual(bookingId, LocalDateTime.now())
  5. Goi roomRepository.updateStatus(roomId, OCCUPIED)
- **Output**: boolean

##### getOccupants(bookingId)
- **Output**: List<Occupant>

##### saveOccupants(bookingId, occupants)
- **Muc dich**: Cap nhat danh sach khach o
- **Logic**:
  1. Xoa tat ca occupants cu
  2. Them occupants moi
- **Output**: boolean

##### processCheckout(bookingId)
- **Muc dich**: Xu ly checkout, cap nhat thong tin va auto create cleaning request
- **Logic xu ly**:
  1. Query booking
  2. Goi bookingRepository.updateStatus(bookingId, CHECKED_OUT)
  3. Goi bookingRepository.updateCheckOutActual(bookingId, LocalDateTime.now())
  4. Neu booking.roomId co:
     - Goi roomRepository.updateStatus(roomId, CLEANING)
     - Auto tao ServiceRequest (cleaning):
       - setBookingId, setServiceType = CLEANING
       - setStatus = PENDING
       - setDescription = "Don phong sau checkout (auto)"
       - setRoomNumber = room.roomNumber
       - serviceRequestRepository.insert()
- **Output**: boolean

##### createWalkInBooking(...)
- **Muc dich**: Tao booking cho khach walk-in
- **Logic**: Tuong tu createBooking nhung co them buoc tim/tao customer account

##### Cac lenh getter/query khac
- getRoomHistory, getExtensionHistory, getOccupants, etc.

### Repository Classes

#### BookingRepository

##### insert(Booking booking)
- **SQL**:
  ```sql
  INSERT INTO Booking (customer_id, room_id, type_id, voucher_id,
    check_in_expected, check_out_expected, total_price,
    payment_type, deposit_amount, status, note)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ```
- **Output**: int - bookingId (auto-generated)

##### findById(bookingId)
- **SQL**: SELECT * FROM Booking WHERE booking_id = ?
- **Output**: Booking

##### findByIdWithDetails(bookingId)
- **Muc dich**: Query voi JOIN Room + RoomType de get chi tiet
- **SQL**:
  ```sql
  SELECT b.*, r.room_number,
    rt.type_id, rt.type_name, rt.base_price, rt.price_per_hour, rt.deposit_percent
  FROM Booking b
  LEFT JOIN Room r ON b.room_id = r.room_id
  JOIN RoomType rt ON b.type_id = rt.type_id
  WHERE b.booking_id = ?
  ```
- **Output**: Booking voi RoomType + Room details

##### findByCustomerId(customerId)
- **SQL**:
  ```sql
  SELECT b.*, r.room_number, rt.type_name
  FROM Booking b
  LEFT JOIN Room r ON b.room_id = r.room_id
  JOIN RoomType rt ON b.type_id = rt.type_id
  WHERE b.customer_id = ?
  ORDER BY b.booking_date DESC
  ```
- **Output**: List<Booking>

##### updateStatus(bookingId, status)
- **SQL**: UPDATE Booking SET status = ? WHERE booking_id = ?

##### isRoomAvailable(roomId, checkIn, checkOut)
- **Muc dich**: Kiem tra phong co san trong thoi gian khong (khong xung dot voi booking active)
- **SQL**:
  ```sql
  SELECT COUNT(*) FROM Booking
  WHERE room_id = ? AND status IN ('Pending', 'Confirmed', 'CheckedIn')
  AND NOT (check_out_expected <= ? OR check_in_expected >= ?)
  ```
- **Output**: boolean - true neu available

##### findByStatus(status)
- **SQL**: SELECT ... FROM Booking WHERE status = ? ORDER BY check_in_expected ASC
- **Output**: List<Booking> voi details

##### findByStatuses(List<String> statuses)
- **Muc dich**: Query voi multiple status values
- **SQL**: SELECT ... WHERE status IN (?, ?, ...) ORDER BY check_in_expected ASC

##### findAll()
- **SQL**: SELECT ... ORDER BY booking_date DESC

##### countByStatus(status)
- **Output**: int

##### updateRoomId(bookingId, roomId)
- **SQL**: UPDATE Booking SET room_id = ? WHERE booking_id = ?

##### updateCheckInActual/updateCheckOutActual(bookingId, dateTime)
- **SQL**: UPDATE Booking SET check_in_actual/check_out_actual = ? WHERE booking_id = ?

##### updateCheckOutExpected(bookingId, newCheckOut)
- **SQL**: UPDATE Booking SET check_out_expected = ? WHERE booking_id = ?
- **Dung**: Khi extend booking

##### cancelOverdueBookings()
- **Muc dich**: Batch cancel tat ca booking overdue (1 min qua check-in)
- **SQL**:
  ```sql
  UPDATE Booking SET status = 'Cancelled'
  WHERE status IN ('Pending', 'Confirmed')
  AND DATEADD(MINUTE, 1, check_in_expected) < GETDATE()
  ```
- **Output**: int - so booking bi cancel

##### findOccupiedDateRangesByTypeId(typeId)
- **Muc dich**: Lay khoang thoi gian dang bi dat
- **SQL**: Query Booking voi type_id va status active
- **Output**: List<LocalDateTime[]>

##### findByRoomId(roomId)
- **Output**: List<Booking> cua phong

##### findCurrentBookingForRoom(roomId)
- **Muc dich**: Lay booking dang checked-in cua phong
- **Output**: Booking hoac null

##### hasConflictAfterDate(roomId, afterDate)
- **Muc dich**: Kiem tra co booking sau thoi diem nay khong
- **Logic**: Check booking voi check_in_expected >= afterDate
- **Output**: boolean

### Controller Classes

#### BookingController (Customer)

##### @WebServlet("/booking/create", "/booking/confirm", "/booking/status", "/booking/availability")

##### handleCreateGet (GET /booking/create)
- **Input**: typeId (query param)
- **Logic xu ly**:
  1. Parse typeId
  2. Neu null, redirect den /rooms
  3. Query roomType = RoomService.getRoomTypeById(typeId)
  4. Neu null, return HTTP 404
  5. Dat vao request: roomType, minDate = today, maxDate = today + 6 months
- **Template**: /WEB-INF/views/booking/create.jsp

##### handleCreatePost (POST /booking/create)
- **Input form**: typeId, checkIn, checkOut, checkInTime, checkOutTime, voucherCode
- **Logic xu ly**:
  1. Parse typeId
  2. Parse checkIn = DateHelper.toCheckInTime(parseDate, timeString)
  3. Parse checkOut = DateHelper.toCheckOutTime(parseDate, timeString)
  4. Query available rooms: getAvailableRooms(typeId, checkIn, checkOut)
  5. Neu khong co phong, set error + forward back toi form
  6. Auto-select room dau tien: room = availableRooms.get(0)
  7. Tinh toan: calc = calculateBooking(typeId, room.roomId, checkIn, checkOut, voucherCode)
  8. Luu vao session: pendingBooking = calc
  9. Luu vao session: bookingCustomerId = loggedInAccount.accountId
  10. Redirect den /booking/confirm
- **Lien ket**: BookingService, RoomService

##### handleConfirmGet (GET /booking/confirm)
- **Logic xu ly**:
  1. Lay pendingBooking tu session
  2. Neu null, redirect den /rooms
  3. Dat vao request: calc, tong tien, khau tru, tien dat
- **Template**: /WEB-INF/views/booking/confirm.jsp

##### handleConfirmPost (POST /booking/confirm)
- **Input form**: occupant names, payment choice (FULL/DEPOSIT)
- **Logic xu ly**:
  1. Lay pendingBooking + customerId tu session
  2. Xu ly occupant list
  3. Tao Occupant objects
  4. Goi BookingService.createBooking(...)
  5. Neu success:
     - Xoa session attributes
     - Redirect toi payment page (VNPay) voi bookingId
  6. Neu failure:
     - Set error message, forward back toi confirm page
- **Lien ket**: BookingService

##### handleStatusGet (GET /booking/status)
- **Input**: bookingId
- **Muc dich**: API endpoint tra ve trang thai booking (JSON)
- **Output**: JSON voi status + message

##### handleAvailabilityApi (GET /booking/availability)
- **Input**: typeId, checkIn, checkOut
- **Muc dich**: AJAX endpoint kiem tra tinh san san cua phong
- **Logic**: Goi getAvailableRooms(), tra ve JSON
- **Output**: JSON {available: true/false, count: N}

#### StaffBookingController

##### @WebServlet(urlPatterns = {...})

##### handleBookingList (GET /staff/bookings)
- **Input**: status (query param, optional)
- **Logic xu ly**:
  1. Neu status co, goi getBookingsByStatus(status)
  2. Neu khong, goi getActiveBookings()
  3. Dat vao request: bookings, filterStatus (neu co)
- **Template**: /WEB-INF/views/staff/bookings/list.jsp

##### handleBookingDetail (GET /staff/bookings/detail)
- **Input**: id (bookingId)
- **Logic**: Query getBookingDetail(), load occupants, extensions

##### handleAssignRoomGet/Post
- **Muc dich**: Hien thi form va xu ly giao phong
- **Logic**: assignRoom() -> update trang thai

##### handleOccupantsGet/Post
- **Muc dich**: Quan ly danh sach khach o

##### handleCheckoutGet/Post
- **Muc dich**: Xu ly checkout

##### handleWalkInStep1/2/3 (Get/Post)
- **Muc dich**: Tao booking walk-in (3 buoc)
  - Step 1: Tim khach o theo dien thoai/email hoac tao tai khoan
  - Step 2: Chon loai phong va thoi gian
  - Step 3: Chon phong va xac nhan

## Luong du lieu (Data Flow)

### Use Case: Customer online booking

1. Customer GET /booking/create?typeId=1
   - RoomService.getRoomTypeById(1) + load details
   - Template hien thi form chon check-in/out

2. Customer chon ngay va submit GET /booking/availability
   - BookingService.getAvailableRooms()
   - Return JSON {available: X rooms}

3. Customer submit form POST /booking/create
   - BookingService.getAvailableRooms() -> select room[0]
   - BookingService.calculateBooking(typeId, roomId, checkIn, checkOut, voucher)
     - Query RoomType + Promotion + Voucher
     - Tinh: subtotal, discount, total, deposit
   - Store in session: pendingBooking, customerId
   - Redirect /booking/confirm

4. GET /booking/confirm
   - Display pendingBooking details, occupant form, payment choice

5. POST /booking/confirm
   - BookingService.createBooking(customerId, roomId, total, voucherId, occupants, paymentType, depositAmount)
     - INSERT INTO Booking
     - INSERT INTO Occupant (x N)
   - Session clear
   - Redirect to payment gateway (VNPay) voi bookingId

6. Payment callback
   - Update booking status = CONFIRMED (sau khi payment success)

### Use Case: Staff manage bookings

1. Staff GET /staff/bookings
   - StaffBookingService.getActiveBookings()
     - SELECT booking voi status IN (Pending, Confirmed, CheckedIn)
   - Template hien thi danh sach

2. Staff GET /staff/bookings/detail?id=X
   - StaffBookingService.getBookingDetail(X)
     - Query booking voi details
   - Load occupants
   - Load extensions
   - Display form assign room

3. Staff POST /staff/bookings/assign
   - StaffBookingService.assignRoom(bookingId, roomId)
     - UPDATE Booking SET room_id = ?, status = 'CheckedIn', check_in_actual = now()
     - UPDATE Room SET status = 'Occupied'
   - Redirect back with success

4. Staff POST /staff/bookings/checkout
   - StaffBookingService.processCheckout(bookingId)
     - UPDATE Booking SET status = 'CheckedOut', check_out_actual = now()
     - UPDATE Room SET status = 'Cleaning'
     - Auto INSERT ServiceRequest (cleaning)

### Use Case: Walk-in booking

1. Staff GET /staff/bookings/walkin (Step 1)
   - Form: phone, email, name, toan quyền chi tiet khach

2. Staff POST (Step 1)
   - StaffBookingService.findOrCreateWalkInCustomer(phone, email, name)
     - Query Account voi phone hoac email
     - Neu co, return account_id + status = FOUND_BY_PHONE/EMAIL
     - Neu khong, tao Account moi voi password random + status = CREATED
   - Store in session
   - Redirect Step 2

3. Staff GET /staff/bookings/walkin-room (Step 2)
   - Form: chon room type + check-in/out

4. Staff POST (Step 2)
   - BookingService.getAvailableRooms()
   - Display danh sach phong + gia
   - Redirect Step 3

5. Staff GET /staff/bookings/walkin-confirm (Step 3)
   - Display chon phong + tong tien

6. Staff POST (Step 3)
   - StaffBookingService.createBooking() hoac createWalkInBooking()
   - Booking status = CONFIRMED luon (khong can payment)
   - Assign phong ngay: assignRoom()
   - Redirect to checkout

## Bao mat & Phan quyen

### Authentication

- BookingController: Yeu cau Customer auth (SessionHelper.getLoggedInAccount())
- StaffBookingController: Yeu cau Staff auth (StaffAuthFilter)
- URL redirect neu not auth: /login

### Authorization

- Customer chi xem/quan ly booking cua chinh minh
  - Code check: booking.customerId == loggedInAccount.accountId
  - Neu khong trang, return HTTP 403 Forbidden

### SQL Injection Prevention

- Toan bo query su dung PreparedStatement voi placeholder (?)
- Khong bao gio string concatenation vao SQL

### Business Logic Validation

- **Check-in must be future date**: LocalDateTime.now().isBefore(checkIn)
- **Check-out after check-in**: checkOut.isAfter(checkIn)
- **Max booking length 30 days**: ChronoUnit.DAYS.between() <= 30
- **Room must be available**: isRoomAvailable(roomId, checkIn, checkOut)
- **Booking can only be cancelled if Pending/Confirmed**: status check
- **Overdue auto-cancel**: 1 minute after expected check-in time

### Data Integrity

- Booking.typeId luon truy tro the phong hop le (FK constraint)
- Booking.roomId dung khi CheckedIn hoac sau (nullable cho Pending)
- Occupant.bookingId phai ton tai (FK constraint)
- Tien dat: depositAmount = totalPrice * depositPercent / 100 (validated)

### Concurrency

- Room availability check + booking create trong transaction (prevent double-booking)
- Occupant update: delete old + insert new (atomic)
