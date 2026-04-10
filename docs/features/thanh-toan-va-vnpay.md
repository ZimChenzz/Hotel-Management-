# Thanh toan va VNPay

## Tong quan nghiep vu

Tinh nang nay cung cap cac giai phap thanh toan da dang cho khach hang va nhan vien:
- Thanh toan truc tuyen qua VNPay (the ngan hang, vi dien tu)
- Thanh toan tien mat tai quay
- Ho tro thanh toan dat phong (toan bo hoac dat coc)
- Ho tro thanh toan phu (them dem, dich vu bat them, v.v.)
- Xac thuc chi phong (HMAC-SHA512)
- Theo doi trang thai thanh toan (Pending, Success, Failed)

## Kien truc & Code Flow

Luong thanh toan co hai keu (Customer va Staff):

### Customer Payment Flow
```
Customer (JSP)
    |
    v
PaymentController (/payment/*)
    |
    +-> handleProcessGet: Hien thi don hoa
    +-> handleVNPayPost: Gui sang VNPay
    +-> handleVNPayReturn: Nhan ket qua tu VNPay
    +-> handleResult: Hien thi ket qua
    |
    v
PaymentService
    |
    +-> getOrCreateInvoice: Tao/lay hoa don
    +-> initiateVNPayPayment: Khoi tao thanh toan VNPay
    +-> processVNPayCallback: Xu ly ket qua tra ve
    |
    v
VNPayService
    |
    +-> createPaymentUrl: Tao URL thanh toan VNPay
    +-> verifySignature: Xac thuc chu ky HMAC
    +-> isPaymentSuccess: Kiem tra ma phu hoi
    |
    v
PaymentRepository, InvoiceRepository
    |
    v
Database (payment, invoice, booking)
```

### Staff Payment Flow
```
Staff (JSP)
    |
    v
StaffPaymentController (/staff/payments/*)
    |
    +-> handleProcessGet: Chon phuong thuc thanh toan
    +-> handleCashPost: Ghi nhan thanh toan tien mat
    +-> handleVNPayGet: Gui sang VNPay
    +-> handleVNPayReturn: Nhan ket qua tu VNPay
    |
    v
StaffPaymentService
    |
    +-> recordCashPayment: Ghi nhan tien mat ngay lap tuc
    +-> initiateVNPayPayment: Khoi tao VNPay
    +-> processVNPayCallback: Xu ly ket qua tra ve
```

## Chi tiet tung ham

### PaymentController

#### doGet (path=/payment/process)
- Muc dich: Hien thi trang thanh toan voi du lieu hoa don
- Input: bookingId (required), invoiceType (Extension/Remaining - optional), invoiceId (optional)
- Output: Chuyen den JSP process.jsp voi booking va invoice
- Logic xu ly:
  1. Lay bookingId tu tham so request
  2. Kiem tra account da dang nhap
  3. Kiem tra quyen truy cap (chi khach hang co the thanh toan cho booking cua minh)
  4. Xac dinh loai hoa don: Booking (mac dinh), Extension, hoac Remaining
  5. Neu invoiceId duoc cung cap thi lay truc tiep
  6. Neu invoiceType = Extension thi tim hoa don Extension chua thanh toan cuoi cung
  7. Neu invoiceType = Remaining thi tim hoa don Remaining cho thanh toan so du
  8. Neu invoiceType mac dinh va booking co trang thai Confirmed va payment type khong phai Deposit thi redirect ve trang trang thai
  9. Neu invoiceType mac dinh thi tao/lay hoa don Booking
  10. Gui booking va invoice den view de hien thi
- Xu ly loi: Redirect ve customer/bookings neu bookingId khong hop le hoac hoa don khong tim thay
- Lien ket: PaymentService.getOrCreateInvoice(), PaymentService.getInvoice(), BookingService.getBookingById()

#### doPost (path=/payment/vnpay)
- Muc dich: Tao yeu cau thanh toan VNPay va redirect sang cong VNPay
- Input: invoiceId (required)
- Output: Redirect sang VNPay hoac ve trang process voi loi
- Logic xu ly:
  1. Parse invoiceId tu request
  2. Kiem tra account da dang nhap
  3. Xay dung baseUrl tu HTTP request
  4. Lay dia chi IP cua client
  5. Goi PaymentService.initiateVNPayPayment() de tao payment record va payment URL
  6. Neu thanh cong: luu txnRef vao session va redirect sang URL VNPay
  7. Neu that bai: hien thi loi va quay lai trang process
- Xu ly loi: Neu co exception thi hien thi thong bao "Loi he thong" va redirect ve bookings
- Lien ket: PaymentService.initiateVNPayPayment(), VNPayService.getIpAddress()

#### doGet (path=/payment/vnpay-return)
- Muc dich: Xu ly ket qua tra ve tu VNPay sau khi khach hang thanh toan
- Input: Tham so tu VNPay (vnp_TxnRef, vnp_ResponseCode, vnp_SecureHash, v.v.)
- Output: Redirect sang /payment/result hoac /customer/bookings neu co loi
- Logic xu ly:
  1. Trích xuat tat ca tham so tu request
  2. Xac thuc chu ky (HMAC-SHA512) bang VNPayService.verifySignature()
  3. Neu chu ky khong hop le: redirect ve bookings voi loi invalid_signature
  4. Lay txnRef va responseCode
  5. Kiem tra session xac thuc: txnRef trong session phai trung khop voi txnRef tra ve
  6. Neu session xac thuc that bai: redirect ve bookings voi loi session_mismatch
  7. Xoa txnRef khoi session
  8. Goi PaymentService.processVNPayCallback() de cap nhat trang thai Payment
  9. Redirect sang /payment/result voi txnCode
- Xu ly loi: Xac thuc chu ky va session la quan trong de tranh tan cong
- Lien ket: VNPayService.verifySignature(), PaymentService.processVNPayCallback()

#### doGet (path=/payment/result)
- Muc dich: Hien thi ket qua thanh toan (thanh cong/that bai)
- Input: txnCode (transaction code)
- Output: Chuyen den JSP success.jsp hoac failed.jsp
- Logic xu ly:
  1. Lay txnCode tu request
  2. Tim Payment bang transaction code
  3. Lay Booking thong qua invoice cua payment
  4. Neu status = Success thi hien thi success.jsp, neu khong thi failed.jsp
- Xu ly loi: Redirect ve bookings neu txnCode khong tim thay
- Lien ket: PaymentService.getPaymentByTransaction(), PaymentService.getBookingFromPayment()

### PaymentService

#### getOrCreateInvoice(int bookingId)
- Muc dich: Tao hoac lay hoa don Booking co san
- Input: bookingId
- Output: Invoice object hoac null
- Logic xu ly:
  1. Kiem tra xem da co hoa don Booking chua
  2. Neu co thi tra ve hoa don co san
  3. Neu khong thi lay Booking
  4. Tinh so tien phai thanh toan dua tren payment type:
     - DEPOSIT: chi thanh toan so tien dat coc
     - FULL: thanh toan toan bo tien
  5. Tinh tien thue = so tien * 0.10 (10% VAT)
  6. Tong = so tien + thue
  7. Tao Invoice record va luu vao DB
  8. Tra ve Invoice object
- Xu ly loi: Return null neu booking khong tim thay hoac insert that bai
- Lien ket: InvoiceRepository, BookingRepository

#### getOrCreateInvoice(int bookingId, String invoiceType)
- Muc dich: Tao hoac lay hoa don theo loai (Booking, Extension, Remaining)
- Input: bookingId, invoiceType (BOOKING, EXTENSION, REMAINING)
- Output: Invoice object hoac null
- Logic xu ly:
  1. Kiem tra xem da co hoa don cua loai nay chua
  2. Neu loai = REMAINING thi toi = total - deposit (so du phai thanh toan)
  3. Neu so du <= 0 thi return null (khong con no)
  4. Neu loai = BOOKING va payment type = DEPOSIT thi toi = deposit amount
  5. Neu khong thi toi = toan bo tien
  6. Tinh thue va tong tien
  7. Tao va luu Invoice vao DB
- Xu ly loi: Return null neu booking null hoac insert that bai
- Lien ket: InvoiceRepository, BookingRepository

#### createExtensionInvoice(int bookingId, BigDecimal extensionPrice)
- Muc dich: Tao hoa don cho thanh toan phu (them dem, dich vu bat them)
- Input: bookingId, extensionPrice (gia tien them)
- Output: Invoice object
- Logic xu ly:
  1. Tinh thue = extensionPrice * 0.10
  2. Tinh tong = extensionPrice + thue
  3. Tao Invoice voi invoiceType = EXTENSION
  4. Luu vao DB va tra ve
- Xu ly loi: Return null neu insert that bai
- Lien ket: InvoiceRepository

#### createRemainingInvoice(int bookingId)
- Muc dich: Tao hoa don so du phai thanh toan khi checkout
- Input: bookingId
- Output: Invoice object hoac null
- Logic xu ly: Goi getOrCreateInvoice(bookingId, REMAINING)
- Lien ket: getOrCreateInvoice()

#### initiateVNPayPayment(int invoiceId, int customerId, String baseUrl, String ipAddress)
- Muc dich: Khoi tao mot giao dich thanh toan VNPay
- Input: invoiceId, customerId, baseUrl (URL ung dung), ipAddress (IP client)
- Output: PaymentResult object (chua payment object va payment URL)
- Logic xu ly:
  1. Lay Invoice tu invoiceId
  2. Kiem tra hoa don co ton tai khong
  3. Kiem tra xem hoa don da duoc thanh toan thanh cong chua
  4. Neu da thanh toan thi tra ve loi
  5. Tao txnRef (ma giao dich) bang ham generateTxnRef()
  6. Lay amount = invoice.totalAmount (cong tien, khong de do tren tien)
  7. Tao orderInfo = "Thanh toan dat phong - Invoice " + invoiceId
  8. Tao Payment record:
     - paymentMethod = "VNPay"
     - transactionCode = txnRef
     - amount = invoice.totalAmount
     - status = PENDING
  9. Luu Payment vao DB
  10. Goi VNPayService.createPaymentUrl() de tao URL VNPay
  11. Tra ve PaymentResult voi payment object va paymentUrl
- Xu ly loi: Tra ve PaymentResult.failure() neu loi
- Lien ket: InvoiceRepository, PaymentRepository, VNPayService.createPaymentUrl()

#### processVNPayCallback(String txnRef, String responseCode)
- Muc dich: Xu ly ket qua tra ve tu VNPay sau khi khach hang thanh toan
- Input: txnRef (ma giao dich), responseCode (00 = thanh cong, khac = that bai)
- Output: PaymentResult object
- Logic xu ly:
  1. Tim Payment bang txnRef
  2. Kiem tra xem Payment da duoc xu ly chua (status phai = PENDING)
  3. Kiem tra responseCode: neu = "00" thi success, khac thi failed
  4. Cap nhat Payment status thanh SUCCESS hoac FAILED
  5. Neu success thi:
     a. Lay Invoice thong qua payment
     b. Neu invoiceType = BOOKING thi cap nhat Booking status = CONFIRMED
     c. Neu invoiceType = EXTENSION thi:
        - Tim BookingExtension pending cua booking nay
        - Cap nhat extension status = CONFIRMED
        - Cap nhat booking checkOutExpected = extension.newCheckOut
  6. Tra ve PaymentResult
- Xu ly loi: Return failure neu payment khong tim thay hoac da xu ly
- Lien ket: PaymentRepository, InvoiceRepository, BookingRepository, BookingExtensionRepository

#### processVNPayIPN(String txnRef, String responseCode, long vnpAmount)
- Muc dich: Xu ly IPN (Instant Payment Notification) tu VNPay - server-to-server callback
- Input: txnRef, responseCode, vnpAmount (tien tu VNPay, chia cho 100)
- Output: String array [rspCode, message]
  - "00" = Confirm Success
  - "01" = Order not found
  - "02" = Order already confirmed
  - "04" = Invalid amount
  - "97" = Invalid signature (xac thuc ben ngoai controller)
  - "99" = Error
- Logic xu ly:
  1. Tim Payment bang txnRef
  2. Neu khong tim thay: return ["01", "Order not found"]
  3. Kiem tra tien: vnpAmount (x 100) phai = payment.amount
  4. Neu tien khong dung: return ["04", "Invalid amount"]
  5. Kiem tra status: phai = PENDING
  6. Neu da xu ly: return ["02", "Order already confirmed"]
  7. Kiem tra responseCode va cap nhat status
  8. Neu success thi cap nhat Booking status va BookingExtension (giong nhu processVNPayCallback)
  9. Return ["00", "Confirm Success"]
- Xu ly loi: Return ["99", "Unknown error"] neu co exception
- Lien ket: PaymentRepository, InvoiceRepository, BookingRepository, BookingExtensionRepository

#### getPaymentByTransaction(String transactionCode)
- Muc dich: Tim Payment bang transaction code
- Input: transactionCode
- Output: Payment object hoac null
- Lien ket: PaymentRepository.findByTransactionCode()

#### getBookingFromPayment(Payment payment)
- Muc dich: Lay Booking thong qua Payment (qua Invoice)
- Input: Payment object
- Output: Booking object hoac null
- Logic xu ly:
  1. Lay Invoice tu payment.invoiceId
  2. Lay Booking tu invoice.bookingId
  3. Tra ve Booking
- Lien ket: InvoiceRepository, BookingRepository

#### hasSuccessfulPayment(int invoiceId)
- Muc dich: Kiem tra xem hoa don da duoc thanh toan chua
- Input: invoiceId
- Output: boolean
- Lien ket: PaymentRepository.hasSuccessfulPayment()

#### findLatestInvoiceByType(int bookingId, String invoiceType)
- Muc dich: Tim hoa don gan day nhat cua booking theo loai
- Input: bookingId, invoiceType
- Output: Invoice object hoac null
- Lien ket: InvoiceRepository.findByBookingIdAndType()

### VNPayService

#### createPaymentUrl(String baseUrl, String txnRef, long amount, String orderInfo, String ipAddress)
- Muc dich: Tao URL thanh toan VNPay
- Input: baseUrl (URL ung dung), txnRef (ma giao dich), amount (tien - don vi VND), orderInfo (mo ta), ipAddress
- Output: String - URL VNPay day du
- Logic xu ly:
  1. Tao HashMap cac tham so VNPay:
     - vnp_Version = "2.1.0"
     - vnp_Command = "pay"
     - vnp_TmnCode = "2S78OR72" (merchant code sandbox)
     - vnp_Amount = amount * 100 (VNPay yeu cau nhan the x 100)
     - vnp_CurrCode = "VND"
     - vnp_TxnRef = txnRef
     - vnp_OrderInfo = orderInfo
     - vnp_OrderType = "other"
     - vnp_Locale = "vn"
     - vnp_ReturnUrl = baseUrl + "/payment/vnpay-return"
     - vnp_IpAddr = ipAddress
     - vnp_CreateDate = thoi gian hien tai (format yyyyMMddHHmmss)
     - vnp_ExpireDate = CreateDate + 15 phut
  2. Sap xep cac tham so theo thu tu alphabet
  3. Xay dung hashData: key=URLEncode(value)&key2=URLEncode(value2)...
  4. Tinh HMAC-SHA512 cu tham so va secret key
  5. Them vnp_SecureHash vao query string
  6. Xay dung URL: VNP_PAY_URL + "?" + query string (key va value deu URL encode)
  7. Tra ve URL
- Xu ly loi: Exception trong URLEncoding hoac HMAC
- Lien ket: VNPayConfig.hmacSHA512(), Calendar, SimpleDateFormat

#### createPaymentUrl(..., String returnUrl)
- Muc dich: Tao URL thanh toan voi custom return URL
- Input: Them tham so returnUrl vao signature
- Output: String - URL VNPay
- Logic xu ly: Giong nhu ham tren nhung dung returnUrl thay vi default

#### verifySignature(Map<String, String> params)
- Muc dich: Xac thuc chu ky HMAC-SHA512 tu ket qua tra ve cua VNPay
- Input: params - HashMap chua tat ca tham so tra ve tu VNPay (bao gom vnp_SecureHash)
- Output: boolean - true neu chu ky hop le, false neu khong
- Logic xu ly:
  1. Lay vnp_SecureHash tu params (chu ky nhan duoc)
  2. Tao TreeMap tu params va sap xep theo thu tu alphabet
  3. Xoa vnp_SecureHash va vnp_SecureHashType khoi map
  4. Xay dung hashData: key=URLEncode(value)&... (giong nhu createPaymentUrl)
  5. Tinh HMAC-SHA512 cu hashData va secret key
  6. So sanh (case-insensitive) voi receivedHash
  7. Tra ve true neu giong, false neu khac
- Xu ly loi: Return false neu receivedHash = null
- Lien ket: VNPayConfig.hmacSHA512()

#### isPaymentSuccess(String responseCode)
- Muc dich: Kiem tra xem thanh toan co thanh cong khong
- Input: responseCode (tu vnp_ResponseCode)
- Output: boolean
- Logic xu ly: Tra ve true neu responseCode = "00", false neu khac
- Note: "00" = successful, khac la that bai (01, 02, 99, v.v.)

#### generateTxnRef()
- Muc dich: Tao ma giao dich (transaction reference) doc nhat cho VNPay
- Output: String - ma giao dich gom 8 chu so
- Logic xu ly: Goi VNPayConfig.getRandomNumber(8)

#### getIpAddress(HttpServletRequest request)
- Muc dich: Lay dia chi IP cua client tu HTTP request
- Input: HttpServletRequest
- Output: String - IP address
- Logic xu ly: Goi VNPayConfig.getIpAddress(request)

### VNPayIPNController

#### doGet
- Muc dich: Xu ly IPN endpoint - nhan server-to-server callback tu VNPay
- Input: VNPay tham so (vnp_TxnRef, vnp_ResponseCode, vnp_Amount, vnp_SecureHash, v.v.)
- Output: JSON response {"RspCode":"00","Message":"Confirm Success"}
- Logic xu ly:
  1. Trích xuat tat ca tham so tu request
  2. Xac thuc chu ky bang VNPayService.verifySignature()
  3. Neu khong hop le: gui response {"RspCode":"97","Message":"Invalid Checksum"}
  4. Lay txnRef, responseCode, amountStr
  5. Kiem tra tham so co day du khong
  6. Parse vnpAmount tu amountStr
  7. Goi PaymentService.processVNPayIPN() de xu ly
  8. Gui JSON response voi result code va message
- Xu ly loi: Gui response JSON voi ma loi tuong ung (97, 99, etc.)
- Lien ket: VNPayService.verifySignature(), PaymentService.processVNPayIPN()

### StaffPaymentService

#### recordCashPayment(int invoiceId, int customerId, BigDecimal amount)
- Muc dich: Ghi nhan thanh toan tien mat at quay
- Input: invoiceId, customerId, amount
- Output: boolean - true neu ghi nhan thanh cong
- Logic xu ly:
  1. Tao Payment object:
     - paymentMethod = "Cash"
     - transactionCode = "CASH-" + timestamp + UUID
     - amount = amount truyen vao
     - paymentTime = LocalDateTime.now()
     - status = SUCCESS (tien mat xac nhan ngay)
  2. Luu Payment vao DB
  3. Neu success va invoiceType = BOOKING thi:
     - Lay Booking cua invoice
     - Neu booking status = PENDING thi cap nhat thanh CONFIRMED
  4. Return true neu insert thanh cong
- Xu ly loi: Return false neu insert that bai, log warning neu cap nhat status fail
- Lien ket: PaymentRepository, InvoiceRepository, BookingRepository

#### initiateVNPayPayment(int invoiceId, int customerId, String baseUrl, String ipAddress)
- Muc dich: Khoi tao thanh toan VNPay cho staff
- Input: invoiceId, customerId, baseUrl, ipAddress
- Output: PaymentResult object
- Logic xu ly:
  1. Giong nhu PaymentService.initiateVNPayPayment()
  2. Nhung orderInfo = "Thanh toan tai quay - Invoice " + invoiceId
  3. Return URL = baseUrl + "/staff/payments/vnpay-return" (staff-specific)
- Lien ket: PaymentRepository, InvoiceRepository, VNPayService

#### processVNPayCallback(String txnRef, String responseCode)
- Muc dich: Xu ly ket qua VNPay cho staff
- Input: txnRef, responseCode
- Output: PaymentResult object
- Logic xu ly: Giong nhu PaymentService nhung khong xu ly BookingExtension (chi BOOKING invoice)
- Lien ket: PaymentRepository, InvoiceRepository, BookingRepository

### StaffPaymentController

#### handleProcessGet
- Muc dich: Hien thi trang chon phuong thuc thanh toan (Cash/VNPay)
- Input: bookingId (required), invoiceType (optional)
- Output: Forward den process.jsp
- Logic xu ly:
  1. Parse va kiem tra bookingId
  2. Xu ly invoice type (Remaining/Extension/default)
  3. Lay booking va hoa don
  4. Kiem tra da thanh toan hay chua
  5. Set attributes va forward den view
- Xu ly loi: Send error 400/404 neu bookingId khong hop le

#### handleCashPost
- Muc dich: Ghi nhan thanh toan tien mat va cap nhat invoice
- Input: invoiceId, customerId, amount
- Output: Redirect sang /staff/payments/success neu thanh cong
- Logic xu ly:
  1. Parse tham so
  2. Validate amount format
  3. Goi StaffPaymentService.recordCashPayment()
  4. Neu success thi redirect sang success page
- Xu ly loi: Hien thi error message neu that bai

#### handleVNPayGet
- Muc dich: Redirect den VNPay (giong nhu customer flow)
- Input: invoiceId
- Output: Redirect sang VNPay hoac trang process voi error
- Logic xu ly: Giong nhu PaymentController nhung dung staff service
- Lien ket: StaffPaymentService.initiateVNPayPayment()

#### handleVNPayReturn
- Muc dich: Nhan ket qua tu VNPay va cap nhat trang thai
- Input: VNPay parameters
- Output: Redirect sang success page hoac error
- Logic xu ly: Giong nhu PaymentController
- Lien ket: VNPayService.verifySignature(), StaffPaymentService.processVNPayCallback()

## Luong du lieu (Data Flow)

### Customer Online Payment Flow (VNPay)
```
1. Customer xem trang payment/process?bookingId=X
   - Hien thi invoice va chon phuong thuc thanh toan

2. POST /payment/vnpay?invoiceId=Y
   - PaymentService.initiateVNPayPayment()
   - Tao Payment(status=PENDING, method=VNPay)
   - VNPayService.createPaymentUrl() tao URL voi chu ky
   - Luu txnRef vao session
   - Redirect sang VNPay gateway

3. Customer thanh toan tren VNPay
   - Nhap thong tin the ngan hang / vi dien tu
   - VNPay xu ly thanh toan va tra ve ket qua

4. GET /payment/vnpay-return?vnp_TxnRef=...&vnp_ResponseCode=...&vnp_SecureHash=...
   - Verify signature (HMAC-SHA512)
   - Verify session txnRef
   - PaymentService.processVNPayCallback()
   - Cap nhat Payment status = SUCCESS/FAILED
   - Neu success thi cap nhat Booking status = CONFIRMED
   - Redirect sang /payment/result?txnCode=...

5. GET /payment/result?txnCode=...
   - Lay Payment va Booking
   - Hien thi success.jsp hoac failed.jsp
```

### Staff Cash Payment Flow
```
1. Staff xem trang /staff/payments/process?bookingId=X&invoiceType=Booking
   - Hien thi booking details va invoice
   - Chon Cash hoac VNPay

2. POST /staff/payments/cash
   - Validate amount
   - StaffPaymentService.recordCashPayment()
   - Tao Payment(status=SUCCESS, method=Cash)
   - Neu invoice type = BOOKING thi cap nhat Booking status = CONFIRMED
   - Redirect sang /staff/payments/success

3. GET /staff/payments/success?invoiceId=Y
   - Hien thi ket qua thanh toan tien mat
```

### VNPay IPN Flow (Backend)
```
1. VNPay gui IPN request den /payment/vnpay-ipn
   - Parameter: vnp_TxnRef, vnp_ResponseCode, vnp_Amount, vnp_SecureHash

2. Verify HMAC signature

3. PaymentService.processVNPayIPN()
   - Tim Payment by txnRef
   - Verify amount (vnp_Amount / 100 = payment.amount)
   - Cap nhat Payment status
   - Neu success thi cap nhat Booking status
   - Return response code: "00" (success), "01" (not found), "02" (already processed), etc.

4. VNPay nhan response va xac nhan da xu ly
```

## Bao mat & Phan quyen

### Authentication & Authorization
- Chi khach hang co the thanh toan cho booking cua chinh minh (kiem tra customer ID)
- Staff can see all bookings va thanh toan bat ky booking
- Admin access qua staff/admin controllers

### HMAC-SHA512 Signature Verification
- Tat ca callback tu VNPay (browser return va IPN) deu co chu ky
- Signature = HMAC-SHA512(secret_key, sorted_params)
- Ung dung phai verify chu ky truoc khi tin tuong du lieu
- Chi dung sorted params (khong bao gom SecureHash va SecureHashType) de tao signature
- Secret key = "8FRDY5I7OT8Y82ZU7T8SZTWX8PENX6VK" (sandbox)

### Session Verification
- Luu txnRef vao session truoc khi redirect sang VNPay
- Sau khi VNPay tra ve, kiem tra txnRef trong session co trung khop khong
- Tranh tan cong CSRF va replay attack

### Data Validation
- Kiem tra amount tu VNPay (IPN) phai = payment.amount (x 100)
- Kiem tra invoice ton tai va status = PENDING truoc khi xu ly
- Kiem tra payment khong bi xu ly lap

### Transaction Code Uniqueness
- txnRef = 8 chu so ngau nhien (VNPay requirement)
- Transaction code cho cash = CASH-{timestamp}-{UUID} (dam bao doc nhat)

### Amount Calculation & Tax
- Tien hoa don = tien san pham + 10% VAT
- Khong duoc phep thay doi amount sau khi tao Payment
- Kiem tra amount tren VNPay co trung khop voi he thong khong

## Next Steps & Dependencies

- Implement payment history / refund flow
- Integrate with reporting/accounting module
- Setup monitoring va alert cho failed payments
- Test VNPay production environment (hien tai sandbox)
- Implement payment retry mechanism
