# Tong quan Kien truc He thong

## Overview - Kiến trúc tổng thể

Hệ thống Hotel Management System được xây dựng theo kiến trúc 3-Layer (Three-tier architecture):

```
Presentation Layer (JSP Views)
         |
         v
Business Logic Layer (Service + Util)
         |
         v
Data Access Layer (Repository)
         |
         v
Database Layer (SQL Server)
```

Hệ thống sử dụng Jakarta EE (Jakarta Servlet, Jakarta Mail) cho web framework.

---

## 1. Lop Presentation (Presentation Layer)

### Controllers

Các controller xử lý HTTP request và điều hướng logic:

- **admin/AdminDashboardController**: Hiển thị dashboard tổng quan
- **admin/AdminReportController**: Báo cáo công suất phòng, doanh thu
- **admin/AdminHotelInfoController**: Quản lý thông tin khách sạn
- **admin/AdminSettingsController**: Cài đặt hệ thống
- **admin/AdminCustomerController**: Quản lý khách hàng
- **admin/AdminRoomController**: Quản lý phòng
- **admin/AdminStaffController**: Quản lý nhân viên
- **admin/AdminUsersController**: Quản lý tài khoản người dùng
- **admin/AdminPromotionController**: Quản lý khuyến mại
- **admin/AdminVoucherController**: Quản lý voucher
- **admin/AdminServiceRequestController**: Quản lý yêu cầu dịch vụ
- **admin/AdminFeedbackController**: Quản lý phản hồi khách hàng
- **common/AuthController**: Xử lý login/logout
- **common/BookingController**: Đặt phòng (khách hàng)
- **common/BookingExtensionController**: Gia hạn đặt phòng
- **common/PaymentController**: Thanh toán
- **common/RoomController**: Xem danh sách phòng
- **common/VNPayIPNController**: Xử lý callback từ VNPay
- **common/HomeController**: Trang chủ
- **customer/CustomerController**: Trang khách hàng
- **staff/StaffDashboardController**: Dashboard nhân viên
- **staff/StaffLoginController**: Login nhân viên
- **staff/StaffBookingController**: Quản lý đặt phòng (staff)
- **staff/StaffPaymentController**: Xử lý thanh toán (staff)
- **staff/StaffRoomController**: Quản lý phòng (staff)
- **staff/StaffCleaningController**: Quản lý vệ sinh phòng
- **staff/StaffServiceRequestController**: Xử lý yêu cầu dịch vụ

### Filters

Các filter xử lý cross-cutting concerns:

- **EncodingFilter**: Set character encoding UTF-8 cho tất cả request/response
- **AuthFilter**: Kiểm tra login cho customer routes (/customer/*, /booking/*, /payment/*)
- **AdminAuthFilter**: Kiểm tra admin login và permission cho /admin/* routes
- **StaffAuthFilter**: Kiểm tra staff login và permission cho /staff/* routes

### Flow Request:

```
Request
  |
  v
EncodingFilter (set UTF-8)
  |
  v
AuthFilter / AdminAuthFilter / StaffAuthFilter (check login)
  |
  +---> Nếu không login: redirect /auth/login
  |
  v
Controller.doGet() / doPost()
  |
  v
Service Layer
  |
  v
set request attributes + forward JSP
```

---

## 2. Lop Business Logic (Service Layer)

### Service Classes

Các service xử lý business logic:

- **AdminReportService**: Lấy thống kê dashboard, báo cáo công suất, doanh thu
- **HotelInfoService**: Quản lý thông tin khách sạn (singleton)
- **AccountService**: Xử lý tài khoản người dùng (login, register)
- **CustomerService**: Quản lý khách hàng
- **BookingService**: Quản lý đặt phòng, tính giá
- **BookingExtensionService**: Quản lý gia hạn đặt phòng
- **PaymentService**: Xử lý thanh toán, VNPay integration
- **RoomService**: Quản lý phòng, tìm kiếm phòng trống
- **PromotionService**: Quản lý khuyến mại
- **VoucherService**: Quản lý voucher, kiểm tra mã voucher
- **FeedbackService**: Quản lý phản hồi khách hàng
- **ServiceRequestService**: Quản lý yêu cầu dịch vụ
- **BookingSchedulerService**: Tự động hủy đơn đặt phòng quá hạn thanh toán

### Utility Classes

Các helper class cung cấp hàm tiện ích:

- **DateHelper**: Xử lý date/time (parseDate, check-in time, check-out time, tính số đêm)
- **SessionHelper**: Quản lý session (getLoggedInAccount, setLoggedInAccount, logout)
- **ValidationHelper**: Kiểm tra dữ liệu (email, phone, password, sanitize HTML)
- **EmailHelper**: Gửi email (OTP, walk-in credentials) sử dụng JavaMail
- **PasswordHelper**: Mã hóa password (bcrypt)
- **OtpHelper**: Tạo và kiểm tra OTP
- **GoogleOAuthHelper**: Xác thực Google OAuth

### Response Classes (DTO)

Các class đóng gói kết quả trả về:

- **AuthResult**: Kết quả login (success, account, message)
- **BookingResult**: Kết quả đặt phòng (success, bookingId, message)
- **BookingCalcResponse**: Tính giá đặt phòng (nights, basePrice, totalPrice)
- **ExtensionCalcResponse**: Tính giá gia hạn
- **PaymentResult**: Kết quả thanh toán
- **ServiceResult**: Kết quả xử lý yêu cầu dịch vụ
- **WalkInCustomerResult**: Kết quả tạo khách hàng walk-in

---

## 3. Lop Data Access (DAL - Data Access Layer)

### BaseRepository (Generic Base Class)

```java
public abstract class BaseRepository<T> {
    protected Connection getConnection()
    protected abstract T mapRow(ResultSet rs)
    protected T queryOne(String sql, Object... params)
    protected List<T> queryList(String sql, Object... params)
    protected int executeUpdate(String sql, Object... params)
    protected int executeInsert(String sql, Object... params)
}
```

Cấp cơ sở cung cấp các phương thức CRUD chung.

### Concrete Repositories

- **AccountRepository**: Query Account (login, findById, insert, update)
- **CustomerRepository**: Query Customer (findById, findAll, countAll, insert, update)
- **RoomRepository**: Query Room (findAvailable, countAll, countByStatus, update)
- **RoomTypeRepository**: Query RoomType
- **RoomImageRepository**: Query RoomImage
- **BookingRepository**: Query Booking (findByCustomer, countAll, sumTotalPrice, countByDateRange, sumTotalPriceByDateRange)
- **BookingExtensionRepository**: Query BookingExtension
- **PaymentRepository**: Query Payment
- **InvoiceRepository**: Query Invoice
- **PromotionRepository**: Query Promotion
- **VoucherRepository**: Query Voucher (findByCode)
- **FeedbackRepository**: Query Feedback
- **ServiceRequestRepository**: Query ServiceRequest
- **HotelInfoRepository**: Query HotelInfo (singleton - findFirst)
- **AmenityRepository**: Query Amenity
- **AmenityMappingRepository**: Query Room-Amenity mapping

### Query Pattern:

```java
// Single result
T obj = repository.queryOne("SELECT * FROM Table WHERE id = ?", id);

// Multiple results
List<T> list = repository.queryList("SELECT * FROM Table WHERE status = ?", status);

// Insert with auto-generated key
int newId = repository.executeInsert("INSERT INTO Table VALUES (?, ?)", val1, val2);

// Update
int rowsAffected = repository.executeUpdate("UPDATE Table SET field = ? WHERE id = ?", newVal, id);
```

---

## 4. Lop Configuration & Database

### DbContext

Quản lý kết nối database sử dụng HikariCP connection pool:

```java
public class DbContext {
    private static HikariDataSource dataSource;

    static {
        // Load db.properties
        // Create HikariCP pool
        // Set min/max connections
    }

    public static Connection getConnection() throws SQLException
    public static void close()
}
```

**Cấu hình từ db.properties:**
- db.url: JDBC connection string
- db.username: Database username
- db.password: Database password
- db.driver: Driver class (com.microsoft.sqlserver.jdbc.SQLServerDriver)
- db.pool.minIdle: Minimum idle connections
- db.pool.maxSize: Maximum pool size
- db.pool.timeout: Connection timeout

### VNPayConfig

Cấu hình thanh toán VNPay:

```java
public final class VNPayConfig {
    public static final String VNP_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static final String VNP_TMN_CODE = "2S78OR72";
    public static final String VNP_HASH_SECRET = "...";
    public static final String VNP_VERSION = "2.1.0";
    public static final int VNP_EXPIRE_MINUTES = 15;
}
```

Cung cấp các method:
- hmacSHA512(key, data): Tính HMAC signature
- getIpAddress(request): Lấy IP client
- getRandomNumber(len): Tạo số ngẫu nhiên

### AppContextListener

Xử lý application lifecycle:

```java
@WebListener
public class AppContextListener implements ServletContextListener {
    private BookingSchedulerService schedulerService;

    public void contextInitialized() {
        // Start scheduler: auto-cancel expired bookings
    }

    public void contextDestroyed() {
        // Stop scheduler
    }
}
```

---

## 5. Constants va Enums

### RoleConstant

```java
public static final int ADMIN = 1;
public static final int CUSTOMER = 2;
public static final int STAFF = 3;
```

### RoomStatus

```
AVAILABLE (trống)
OCCUPIED (chiếm dụng)
CLEANING (vệ sinh)
MAINTENANCE (bảo trì)
```

### BookingStatus

```
PENDING (chờ thanh toán)
CONFIRMED (đã xác nhận)
CHECKED_IN (đã check-in)
CHECKED_OUT (đã check-out)
CANCELLED (hủy)
```

### PaymentStatus

```
PENDING (chờ thanh toán)
COMPLETED (đã thanh toán)
FAILED (thất bại)
REFUNDED (hoàn tiền)
```

### PaymentType

```
CREDIT_CARD (thẻ tín dụng)
DEBIT_CARD (thẻ ghi nợ)
ONLINE_BANKING (chuyển khoản)
E_WALLET (ví điện tử)
```

### CleaningStatus

```
PENDING (chờ vệ sinh)
IN_PROGRESS (đang vệ sinh)
COMPLETED (đã vệ sinh)
```

### InvoiceType

```
BOOKING (hóa đơn đặt phòng)
EXTENSION (hóa đơn gia hạn)
SERVICE (hóa đơn dịch vụ)
```

### ServiceTypeConstant & ServiceRequestStatusConstant

Định nghĩa các loại dịch vụ và trạng thái yêu cầu dịch vụ.

### ErrorMessage

Chứa các message lỗi thống nhất cho hệ thống.

---

## 6. Entity Models - Danh sach Entity

### Account

- accountId (PK)
- email
- passwordHash
- roleId (FK to Role)
- createdAt
- updatedAt

### Customer

- customerId (PK)
- accountId (FK to Account)
- fullName
- phone
- address
- city
- identityNumber
- createdAt
- updatedAt

### Room

- roomId (PK)
- roomNumber
- roomTypeId (FK to RoomType)
- status (AVAILABLE, OCCUPIED, CLEANING, MAINTENANCE)
- createdAt
- updatedAt

### RoomType

- roomTypeId (PK)
- typeName (Single, Double, Suite, v.v.)
- basePrice
- maxOccupancy
- description

### RoomImage

- imageId (PK)
- roomId (FK to Room)
- imageUrl
- displayOrder

### Booking

- bookingId (PK)
- customerId (FK to Customer)
- roomId (FK to Room)
- checkInDate
- checkOutDate
- numberOfGuests
- totalPrice
- status (PENDING, CONFIRMED, CHECKED_IN, CHECKED_OUT, CANCELLED)
- bookingDate
- createdAt
- updatedAt

### BookingExtension

- extensionId (PK)
- bookingId (FK to Booking)
- newCheckOutDate
- additionalPrice
- status
- createdAt

### Payment

- paymentId (PK)
- bookingId (FK to Booking)
- amount
- paymentType (CREDIT_CARD, DEBIT_CARD, ONLINE_BANKING, E_WALLET)
- paymentStatus (PENDING, COMPLETED, FAILED, REFUNDED)
- transactionId (VNPay transaction ID)
- paymentDate

### Invoice

- invoiceId (PK)
- bookingId (FK to Booking)
- invoiceType (BOOKING, EXTENSION, SERVICE)
- totalAmount
- createdDate

### Promotion

- promotionId (PK)
- promotionName
- discountPercent
- startDate
- endDate
- isActive

### Voucher

- voucherId (PK)
- voucherCode (unique)
- discountAmount
- discountPercent
- usageLimit
- usedCount
- expiryDate
- isActive

### Feedback

- feedbackId (PK)
- bookingId (FK to Booking)
- rating (1-5)
- comment
- createdDate

### ServiceRequest

- requestId (PK)
- bookingId (FK to Booking)
- serviceType
- requestStatus (PENDING, IN_PROGRESS, COMPLETED, CANCELLED)
- description
- requestDate
- resolvedDate

### HotelInfo

- infoId (PK)
- hotelName
- slogan
- shortDescription
- fullDescription
- address
- city
- phone
- email
- website
- checkInTime
- checkOutTime
- cancellationPolicy
- policies
- logoUrl
- amenities (comma-separated)
- facebook
- instagram
- twitter
- updatedAt

### Amenity

- amenityId (PK)
- amenityName (Wifi, Pool, Gym, v.v.)

### Role

- roleId (PK)
- roleName (Admin, Customer, Staff)

---

## 7. Authentication & Authorization

### Flow Login:

```
POST /auth/login
    |
    v
AuthController.doPost()
    |
    v
AccountService.authenticate(email, password)
    |
    +---> Query Account by email
    +---> Verify password with PasswordHelper.verifyPassword()
    +---> Return AuthResult (success/fail)
    |
    v
SessionHelper.setLoggedInAccount(request, account)
    |
    v
Redirect to dashboard (admin/customer/staff)
```

### Session Management:

```java
// Store
SessionHelper.setLoggedInAccount(request, account);

// Retrieve
Account account = SessionHelper.getLoggedInAccount(request);

// Check login
boolean isLoggedIn = SessionHelper.isLoggedIn(request);

// Logout
SessionHelper.logout(request);
```

### Role-based Access:

- AdminAuthFilter: Kiểm tra roleId == ADMIN
- StaffAuthFilter: Kiểm tra roleId == STAFF
- AuthFilter: Chỉ kiểm tra login status

---

## 8. Payment Integration (VNPay)

### VNPay Payment Flow:

```
1. Customer click "Thanh toán"
    |
    v
2. PaymentController.doGet()
    |
    v
3. Generate VNPay request
    - Order ID, Amount, Client IP
    - Callback URL, Expire time
    - HMAC signature
    |
    v
4. Redirect to VNPay sandbox
    |
    v
5. Customer enters card details
    |
    v
6. VNPay returns to callback URL
    |
    v
7. VNPayIPNController.doGet()
    |
    +---> Verify signature
    +---> Query Payment status
    +---> Update Booking status
    |
    v
8. Redirect to success/fail page
```

---

## 9. Email Service

### EmailHelper Features:

- sendOtp(toEmail, otp): Gửi email OTP để reset password
- sendWalkInCredentials(toEmail, fullName, password): Gửi email thông tin tài khoản

### Configuration:

Lấy từ mail.properties hoặc environment variables:
- MAIL_SMTP_HOST (default: smtp.gmail.com)
- MAIL_SMTP_PORT (default: 587)
- MAIL_USERNAME
- MAIL_PASSWORD

### Email Template:

HTML email với branding Luxury Hotel, support tiếng Việt.

---

## 10. Scheduler

### BookingSchedulerService

Chạy mỗi 5 phút, tự động:
- Tìm các đơn đặt phòng PENDING quá 15 phút chưa thanh toán
- Đổi status thành CANCELLED
- Giải phóng phòng (status = AVAILABLE)

Được khởi động trong AppContextListener.contextInitialized()

---

## 11. Request Flow Example - Đặt Phòng

```
1. Customer select room, check-in/out dates
   |
   v
2. POST /booking/calculate (AJAX)
   |
   v
3. BookingController.doPost() (calculate)
   |
   +---> DateHelper.calculateNights()
   +---> RoomService.getRoom()
   +---> BookingService.calculatePrice()
   +---> Return JSON (nights, basePrice, totalPrice)
   |
   v
4. Customer review and click "Đặt phòng"
   |
   v
5. POST /booking/create
   |
   v
6. BookingController.doPost() (create)
   |
   +---> BookingService.createBooking()
   +---> Set status = PENDING
   +---> Update Room status = OCCUPIED
   +---> Return bookingId
   |
   v
7. Redirect to /payment/vnpay?bookingId=XX
   |
   v
8. PaymentController.doGet()
   |
   +---> Generate VNPay request
   +---> Redirect to VNPay sandbox
   |
   v
9. Customer completes payment on VNPay
   |
   v
10. VNPayIPNController.doGet() (callback)
    |
    +---> Verify signature
    +---> Query Payment by VNPay response
    +---> Update Booking status = CONFIRMED
    +---> Create Invoice
    |
    v
11. Redirect to success page
```

---

## Summary

- **3-Layer Architecture**: Controller → Service → Repository → Database
- **Connection Pooling**: HikariCP cho performance
- **Role-based Security**: Filter-based authentication
- **Singleton Pattern**: HotelInfo chỉ có một record
- **Generic Repository**: BaseRepository<T> cho code reuse
- **Utility Classes**: Helper methods cho date, validation, email, password
- **External Integration**: VNPay payment, Google OAuth, Email
- **Scheduler**: Auto-cancel expired bookings
- **Error Handling**: Try-catch ở Service/Controller level
