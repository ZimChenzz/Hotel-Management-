# Gia Han Dat Phong

## Tong quan nghiep vu

Chuc nang gia han cho phep khach hang (dang checked-in) yeu cau gia han thoi gian o them, khong can huy booking cu. Tinh toan gia gia han dua tren so gio them: <= 12h tinh theo gio (pricePerHour * hours), > 12h tinh theo dem (ceil(hours/24) * basePrice). Each extension tao mot invoice rieng va yeu cau thanh toan. Sau khi thanh toan, check_out_expected cua booking duoc cap nhat.

## Kien truc & Code Flow

```
Customer GUI
   |
   v
BookingExtensionController (common/booking/extend)
   |
   v
BookingExtensionService / BookingService
   |
   v
BookingExtensionRepository / BookingRepository / RoomTypeRepository / InvoiceRepository
   |
   v
Database (BookingExtension, Booking, RoomType, Invoice)
```

### Trang thai Extension

```
Pending (chua thanh toan)
  |
  v
Confirmed (da thanh toan, update checkout booking)
  |
Cancelled (huy hoac khong thanh toan)
```

## Chi tiet tung ham

### Entity Classes

#### BookingExtension
- **Muc dich**: Dai dien mot yeu cau gia han
- **Thuoc tinh**:
  - extensionId: Khoa chinh
  - bookingId: Tham chieu booking (FK)
  - originalCheckOut: Thoi gian tra phong du kien ban dau
  - newCheckOut: Thoi gian tra phong sau gia han (originalCheckOut + extraHours)
  - extensionHours: So gio them (VD: 3, 24)
  - extensionPrice: Tong tien gia han (sau tinh toan gio/dem)
  - status: Pending / Confirmed / Cancelled
  - createdAt: Thoi diem tao yeu cau

### Utility Classes

#### ExtensionCalcResponse
- **Muc dich**: Ket qua tinh toan gia gia han chi tiet
- **Thuoc tinh**:
  - bookingId: ID booking
  - originalCheckOut: Checkout ban dau
  - newCheckOut: Checkout sau gia han
  - extraHours: So gio them
  - extensionPrice: So tien phai tra
  - pricePerHour: Gia theo gio (tu RoomType)
  - basePrice: Gia theo dem (tu RoomType)
  - hourlyRate: boolean - true neu tinh theo gio, false neu tinh theo dem
- **Logic**:
  - hourlyRate = true neu extraHours <= 12
  - hourlyRate = false neu extraHours > 12

### Service Classes

#### BookingExtensionService

##### canExtend(bookingId)
- **Muc dich**: Kiem tra co the gia han booking hay khong
- **Output**: ServiceResult (success/failure message)
- **Logic xu ly**:
  1. Query booking = bookingRepository.findByIdWithDetails(bookingId)
  2. Neu booking null -> failure "Khong tim thay dat phong"
  3. Validate status: booking.status phai = CHECKED_IN
     - Neu khong -> failure "Chi co the gia han khi da check-in"
  4. Check conflict: co booking nao sau currentCheckOut khong?
     - hasConflictAfterDate(booking.roomId, booking.checkOutExpected)
     - Neu co -> failure "Phong da co nguoi dat sau, khong the gia han"
  5. Return success
- **Lien ket**: BookingRepository

##### calculateExtension(bookingId, extraHours)
- **Muc dich**: Tinh toan chi tiet gia gia han
- **Input**:
  - bookingId: ID booking
  - extraHours: So gio them (> 0)
- **Output**: ExtensionCalcResponse hoac null neu error
- **Logic xu ly**:
  1. Validate extraHours > 0
  2. Query booking = bookingRepository.findByIdWithDetails(bookingId)
  3. Query roomType (get tu booking)
  4. Tinh gia theo hours:
     - **Case 1: extraHours <= 12 (hourly rate)**
       - price = pricePerHour * extraHours
       - isHourly = true
     - **Case 2: extraHours > 12 (nightly rate)**
       - nights = ceil(extraHours / 24.0)
       - price = basePrice * nights
       - isHourly = false
  5. Tinh newCheckOut = originalCheckOut + extraHours
  6. Tao ExtensionCalcResponse
  7. Return response
- **Example**:
  - extraHours = 3, pricePerHour = 25000 -> price = 75000 (hourly)
  - extraHours = 30, basePrice = 500000 -> nights = ceil(30/24) = 2, price = 1000000 (nightly)
- **Lien ket**: BookingRepository, RoomTypeRepository

##### requestExtension(bookingId, extraHours)
- **Muc dich**: Tao yeu cau gia han (validate + create extension + create invoice)
- **Input**: bookingId, extraHours
- **Output**: ServiceResult voi extensionId+invoiceId trong message (format: "extensionId,invoiceId")
- **Logic xu ly**:
  1. Validate: canExtend(bookingId)
     - Neu failure, return failure message
  2. Tinh toan: calculateExtension(bookingId, extraHours)
     - Neu null, return failure
  3. Tao BookingExtension record:
     - setBookingId, setOriginalCheckOut = calc.originalCheckOut
     - setNewCheckOut = calc.newCheckOut
     - setExtensionHours = extraHours
     - setExtensionPrice = calc.extensionPrice
     - setStatus = "Pending"
  4. Insert extension: extensionId = extensionRepository.insert(ext)
     - Neu <= 0, return failure
  5. Tinh tax: taxAmount = extensionPrice * TAX_RATE (0.10 = 10%)
  6. Tinh total: totalAmount = extensionPrice + taxAmount
  7. Tao Invoice record:
     - setBookingId
     - setTotalAmount
     - setTaxAmount
     - setInvoiceType = EXTENSION
  8. Insert invoice: invoiceId = invoiceRepository.insert(invoice)
     - Neu <= 0, return failure
  9. Return success message: "extensionId,invoiceId" (dung cho redirect payment)
- **Lien ket**: BookingExtensionRepository, InvoiceRepository

##### confirmExtension(extensionId)
- **Muc dich**: Xac nhan gia han sau khi thanh toan (update status + update booking checkout)
- **Input**: extensionId
- **Output**: boolean - true neu thanh cong
- **Logic xu ly**:
  1. Query ext = extensionRepository.findById(extensionId)
  2. Neu null -> return false
  3. Update extension: extensionRepository.updateStatus(extensionId, "Confirmed")
  4. Query booking = bookingRepository.findById(ext.bookingId)
  5. Update booking checkout: updateCheckOutExpected(ext.bookingId, ext.newCheckOut)
  6. Return true
- **Lien ket**: BookingExtensionRepository, BookingRepository

##### getExtensionsByBooking(bookingId)
- **Muc dich**: Lay danh sach tat ca extension cua booking (lich su)
- **Output**: List<BookingExtension>
- **Lien ket**: BookingExtensionRepository

##### getExtensionById(extensionId)
- **Output**: BookingExtension hoac null

##### getExtensionHistory(bookingId)
- **Muc dich**: Lay lich su extension voi details (formatted dates, price info)
- **Output**: List<BookingExtension>

#### BookingService (co them methods cho extension)

##### getBookingById(bookingId)
- **Dung**: Used by extension controller de lay booking info

### Repository Classes

#### BookingExtensionRepository

##### insert(BookingExtension ext)
- **SQL**:
  ```sql
  INSERT INTO BookingExtension (booking_id, original_check_out, new_check_out,
    extension_hours, extension_price, status)
  VALUES (?, ?, ?, ?, ?, ?)
  ```
- **Output**: int - extensionId (auto-generated)

##### findById(extensionId)
- **SQL**: SELECT * FROM BookingExtension WHERE extension_id = ?
- **Output**: BookingExtension

##### findByBookingId(bookingId)
- **SQL**: SELECT * FROM BookingExtension WHERE booking_id = ? ORDER BY created_at
- **Output**: List<BookingExtension>

##### updateStatus(extensionId, status)
- **SQL**: UPDATE BookingExtension SET status = ? WHERE extension_id = ?

##### findPendingByBookingId(bookingId)
- **Muc dich**: Lay extension pending moi nhat cua booking (dung khi confirm payment)
- **SQL**: SELECT TOP 1 * FROM BookingExtension WHERE booking_id = ? AND status = 'Pending' ORDER BY extension_id DESC
- **Output**: BookingExtension hoac null

#### BookingRepository (co them methods cho extension)

##### hasConflictAfterDate(roomId, afterDate)
- **Muc dich**: Kiem tra co booking nao sau thoi diem chi dinh khong
- **SQL**:
  ```sql
  SELECT COUNT(*) FROM Booking
  WHERE room_id = ? AND status IN ('Pending', 'Confirmed', 'CheckedIn')
  AND check_in_expected >= ?
  ```
- **Output**: boolean - true neu co conflict

##### updateCheckOutExpected(bookingId, newCheckOut)
- **SQL**: UPDATE Booking SET check_out_expected = ? WHERE booking_id = ?
- **Output**: int - so hang cap nhat

### Controller Classes

#### BookingExtensionController

##### @WebServlet("/booking/extend", "/booking/extend/confirm")

##### handleExtendGet (GET /booking/extend)
- **Input**: bookingId (query param)
- **Logic xu ly**:
  1. Parse bookingId
  2. Neu null, redirect /customer/bookings
  3. Get logged-in customer
  4. Query booking = bookingService.getBookingById(bookingId)
  5. Validate: booking ton tai va customer_id trung hop
     - Neu khong trang, return HTTP 403
  6. Check canExtend: extensionService.canExtend(bookingId)
  7. Lay extension history: getExtensionsByBooking(bookingId)
  8. Dat vao request:
     - booking
     - canExtend (boolean)
     - canExtendMessage
     - extensions (lich su)
- **Template**: /WEB-INF/views/booking/extend.jsp
- **Lien ket**: BookingExtensionService, BookingService

##### handleExtendPost (POST /booking/extend)
- **Muc dich**: Tinh toan extension, hien thi confirmation
- **Input form**: bookingId, extraHours
- **Logic xu ly**:
  1. Parse bookingId va extraHours
  2. Validate: extraHours > 0 va <= 720 (30 ngay)
     - Neu khong hop le, set error message
     - handleExtendGet() reload form voi error
  3. Get logged-in customer
  4. Query booking = bookingService.getBookingById(bookingId)
  5. Validate ownership + canExtend
  6. Tinh toan: calc = extensionService.calculateExtension(bookingId, extraHours)
  7. Neu null, set error + reload form
  8. Store in session: pendingExtension = calc
  9. Redirect /booking/extend/confirm
- **Lien ket**: BookingExtensionService

##### handleConfirmGet (GET /booking/extend/confirm)
- **Logic xu ly**:
  1. Lay pendingExtension tu session
  2. Neu null, redirect /customer/bookings
  3. Dat vao request: extension calc, total, tax, price breakdown
- **Template**: /WEB-INF/views/booking/extend/confirm.jsp

##### handleConfirmPost (POST /booking/extend/confirm)
- **Muc dich**: Tao extension record + invoice, redirect payment
- **Logic xu ly**:
  1. Lay pendingExtension tu session
  2. Parse bookingId = pendingExtension.bookingId
  3. Parse extraHours = pendingExtension.extraHours
  4. Goi extensionService.requestExtension(bookingId, extraHours)
  5. Neu failure, set error + handleConfirmGet() reload
  6. Neu success:
     - Parse extensionId, invoiceId tu message ("extensionId,invoiceId")
     - Xoa session: pendingExtension
     - Redirect toi payment gateway (VNPay) voi invoiceId
- **Lien ket**: BookingExtensionService

##### parseIntParam(request, name)
- **Logic**: An toan parse integer param (tuong tu BookingController)

### Payment Integration (via VNPayService)

#### Payment flow cho extension

1. BookingExtensionController redirect toi VNPay voi:
   - invoiceId
   - totalAmount (extensionPrice + tax)
   - returnUrl = /booking/extend/confirm-payment

2. Customer thanh toan tren VNPay

3. VNPay callback toi VNPayIPNController
   - Verify signature
   - Update payment status

4. Success: Update extension status = CONFIRMED
   - Goi BookingExtensionService.confirmExtension(extensionId)
     - extensionRepository.updateStatus("Confirmed")
     - bookingRepository.updateCheckOutExpected(ext.newCheckOut)
   - Redirect /booking/status?id=X

## Luong du lieu (Data Flow)

### Use Case: Customer request extension

1. Customer GET /booking/extend?bookingId=X (from booking detail page)
   - BookingService.getBookingById(X) -> load chi tiet booking
   - BookingExtensionService.canExtend(X) -> check co the gia han khong
   - BookingExtensionService.getExtensionsByBooking(X) -> lich su
   - Display form "Nhap so gio them"

2. Customer chon gio + submit POST /booking/extend
   - BookingExtensionService.calculateExtension(X, 3)
     - Query RoomType
     - If 3 hours <= 12: price = 25000 * 3 = 75000 (hourly)
     - newCheckOut = originalCheckOut + 3 hours
   - Store in session: pendingExtension
   - Redirect /booking/extend/confirm

3. GET /booking/extend/confirm
   - Display: originalCheckOut, newCheckOut, hours, price, tax, total
   - Form "Xac nhan gia han?"

4. Customer confirm POST /booking/extend/confirm
   - BookingExtensionService.requestExtension(X, 3)
     - canExtend() validate
     - calculateExtension() tinh gia
     - INSERT BookingExtension (booking_id=X, hours=3, price=75000, status=Pending)
     - TAX = 75000 * 0.10 = 7500
     - TOTAL = 82500
     - INSERT Invoice (booking_id=X, total=82500, tax=7500, type=EXTENSION)
     - Return "extensionId,invoiceId"
   - Session clear
   - Redirect toi VNPay voi invoiceId + amount = 82500

5. VNPayIPNController (callback)
   - Verify signature
   - Lay invoiceId, status
   - Neu status = 00 (success):
     - InvoiceRepository.updateStatus(invoiceId, PAID)
     - BookingExtensionService.confirmExtension(extensionId)
       - UPDATE BookingExtension SET status = 'Confirmed'
       - UPDATE Booking SET check_out_expected = newCheckOut
     - Redirect /booking/status?id=X (success page)
   - Neu failure -> redirect error page

6. GET /booking/status
   - Display "Gia han thanh cong, check-out moi: newCheckOut"
   - Booking da cap nhat check_out_expected

### Use Case: Multiple extensions on same booking

1. Booking ban dau: check_out = 2024-01-15 15:00
2. Extension 1: +3 hours -> check_out = 2024-01-15 18:00, price = 75000
3. Customer can request extension 2: +24 hours -> check_out = 2024-01-16 18:00
   - canExtend: check co conflict sau 2024-01-15 18:00? -> NO
   - calculateExtension: 24 hours > 12, nights = ceil(24/24) = 1, price = 500000 (basePrice)
4. Each extension co separate invoice va thanh toan rieng

## Bao mat & Phan quyen

### Authentication & Authorization

- BookingExtensionController: Yeu cau Customer auth
- Check: extension.booking.customer_id == loggedInAccount.accountId
- Neu khong trang, return HTTP 403 Forbidden

### Business Logic Validation

- **Can only extend if CHECKED_IN**: status == "CheckedIn"
- **No future bookings on same room**: hasConflictAfterDate() check
- **Extension hours must be > 0**: extraHours > 0
- **Max extension = 30 days**: extraHours <= 720
- **Pricing logic**:
  - <= 12h: hourly rate = pricePerHour * hours
  - > 12h: nightly rate = basePrice * ceil(hours/24)
- **Tax always 10%**: TAX_RATE = 0.10
- **Cannot cancel after confirmed**: Extension status = Confirmed thi ko the huy

### SQL Injection Prevention

- Toan bo query su dung PreparedStatement voi placeholder (?)
- Khong concatenation vao SQL

### Data Integrity

- BookingExtension.booking_id -> FK to Booking (must exist)
- newCheckOut > originalCheckOut (validated in calculateExtension)
- extensionPrice > 0 (calculated from valid room type pricing)
- Tax calculated consistently (extensionPrice * 0.10)

### Concurrency Issues

- When multiple extensions on same booking:
  - Each extension validate separately (no overlap check)
  - hasConflictAfterDate checks after CURRENT extension newCheckOut
  - Booking checkout update: last payment wins (could be issue - consider lock)

### Security Considerations

- VNPay callback verify signature (prevent fake payments)
- InvoiceRepository luu transaction history
- Audit log updates (booking checkout timestamp)
- Payment amount must match calculated amount exactly
