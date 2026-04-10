# Huong dan Doc Tai lieu

## Gioi thieu

Tài liệu này cung cấp hướng dẫn toàn diện về hệ thống Hotel Management System. Các tài liệu được tổ chức theo chức năng và vai trò người dùng để giúp bạn nhanh chóng tìm thấy thông tin cần thiết.

## Cau truc Tai lieu

Dự án có 14 tệp tài liệu chi tiết trong thư mục `docs/features/`:

### Tệp Tài liệu

1. **tong-quan-kien-truc.md** - Tổng quan kiến trúc hệ thống
2. **xac-thuc-va-quan-ly-tai-khoan.md** - Xác thực và quản lý tài khoản
3. **quan-ly-khach-hang.md** - Quản lý khách hàng
4. **quan-ly-nhan-vien.md** - Quản lý nhân viên
5. **quan-ly-phong.md** - Quản lý phòng
6. **dat-phong-va-quan-ly-dat-phong.md** - Đặt phòng và quản lý
7. **gia-han-dat-phong.md** - Gia hạn đặt phòng
8. **thanh-toan-va-tich-hop-vnpay.md** - Thanh toán và VNPay
9. **khuyen-mai-va-voucher.md** - Khuyến mại và voucher
10. **phan-hoi-va-danh-gia.md** - Phản hồi và đánh giá
11. **yeu-cau-dich-vu.md** - Yêu cầu dịch vụ
12. **ve-sinh-phong-va-sched.md** - Vệ sinh phòng và scheduler
13. **bao-cao-va-thong-ke.md** - Báo cáo và thống kê
14. **thong-tin-khach-san.md** - Thông tin khách sạn

---

## Thi tu Doc Tran truyen - Reading Order (Khuyến nghị)

### Phase 1: Hiểu kiến trúc (30 phút)

**Bắt đầu bằng:**
1. **tong-quan-kien-truc.md** - Hiểu cấu trúc 3-layer, các component chính, flow request
2. **xac-thuc-va-quan-ly-tai-khoan.md** - Hiểu cơ chế login, role-based access

**Tại sao:**
- Nên hiểu tổng thể trước khi đi vào chi tiết
- Authentication là nền tảng của hệ thống

### Phase 2: Hiểu core features (1.5 giờ)

**Đọc tiếp:**
3. **quan-ly-phong.md** - Quản lý phòng, trạng thái phòng
4. **dat-phong-va-quan-ly-dat-phong.md** - Luồng đặt phòng chính
5. **thanh-toan-va-tich-hop-vnpay.md** - Cách thanh toán hoạt động

**Tại sao:**
- 3 feature này tạo nên luồng chính của hệ thống
- Yêu cầu hiểu database relationships

### Phase 3: Tính năng phụ (1 giờ)

**Đọc tiếp:**
6. **gia-han-dat-phong.md** - Gia hạn là use case phổ biến
7. **khuyen-mai-va-voucher.md** - Khuyến mại/voucher cho pricing
8. **yeu-cau-dich-vu.md** - Dịch vụ thêm của khách hàng

### Phase 4: Quản lý & Báo cáo (45 phút)

**Đọc tiếp:**
9. **quan-ly-khach-hang.md** - Admin quản lý khách hàng
10. **quan-ly-nhan-vien.md** - Admin quản lý nhân viên
11. **bao-cao-va-thong-ke.md** - Dashboard và báo cáo
12. **thong-tin-khach-san.md** - Cấu hình khách sạn

### Phase 5: Tính năng khác (30 phút)

**Đọc tiếp:**
13. **phan-hoi-va-danh-gia.md** - Feedback system
14. **ve-sinh-phong-va-sched.md** - Vệ sinh phòng, scheduler

---

## Danh sach Tai lieu theo Vai tro

### Role: Admin (Quản trị viên)

Admin có quyền truy cập tất cả module. Tài liệu liên quan:

1. **bao-cao-va-thong-ke.md** - Xem dashboard, báo cáo doanh thu, công suất phòng
2. **thong-tin-khach-san.md** - Cấu hình thông tin khách sạn, slogan, chính sách
3. **quan-ly-phong.md** - Tạo/sửa/xóa phòng, cập nhật giá
4. **quan-ly-khach-hang.md** - Xem danh sách khách hàng, chi tiết đặt phòng
5. **quan-ly-nhan-vien.md** - Tuyển dụng, quản lý nhân viên, cập nhật thông tin
6. **dat-phong-va-quan-ly-dat-phong.md** - Quản lý tất cả đơn đặt phòng
7. **thanh-toan-va-tich-hop-vnpay.md** - Kiểm tra thanh toán
8. **khuyen-mai-va-voucher.md** - Tạo khuyến mại, voucher, quản lý
9. **phan-hoi-va-danh-gia.md** - Xem phản hồi khách hàng
10. **yeu-cau-dich-vu.md** - Quản lý yêu cầu dịch vụ

**Gợi ý:**
- Bắt đầu từ Dashboard: **bao-cao-va-thong-ke.md**
- Cấu hình: **thong-tin-khach-san.md**
- Quản lý nội dung: **quan-ly-phong.md**, **quan-ly-khach-hang.md**, **quan-ly-nhan-vien.md**
- Kiểm toán: **dat-phong-va-quan-ly-dat-phong.md**, **thanh-toan-va-tich-hop-vnpay.md**

---

### Role: Staff (Nhân viên)

Staff quản lý vận hành hàng ngày:

1. **dat-phong-va-quan-ly-dat-phong.md** - Check-in/out, quản lý đặt phòng của ngày
2. **thanh-toan-va-tich-hop-vnpay.md** - Xử lý thanh toán tại quầy
3. **ve-sinh-phong-va-sched.md** - Ghi nhận vệ sinh phòng, trạng thái
4. **yeu-cau-dich-vu.md** - Xử lý yêu cầu dịch vụ của khách hàng
5. **gia-han-dat-phong.md** - Xử lý gia hạn phòng
6. **phan-hoi-va-danh-gia.md** - Xem phản hồi khách hàng (read-only)

**Gợi ý:**
- Bắt đầu từ ngày làm việc: **dat-phong-va-quan-ly-dat-phong.md** + **ve-sinh-phong-va-sched.md**
- Xử lý yêu cầu: **yeh-cau-dich-vu.md**, **thanh-toan-va-tich-hop-vnpay.md**

---

### Role: Customer (Khách hàng)

Khách hàng tương tác qua website:

1. **dat-phong-va-quan-ly-dat-phong.md** - Tìm kiếm phòng, đặt phòng, quản lý đơn
2. **thanh-toan-va-tich-hop-vnpay.md** - Thanh toán qua VNPay
3. **gia-han-dat-phong.md** - Gia hạn đặt phòng nếu cần
4. **khuyen-mai-va-voucher.md** - Sử dụng voucher khi đặt phòng
5. **yeu-cau-dich-vu.md** - Gọi dịch vụ thêm trong phòng
6. **phan-hoi-va-danh-gia.md** - Để lại đánh giá và phản hồi

**Gợi ý:**
- Bắt đầu từ: **dat-phong-va-quan-ly-dat-phong.md**
- Thanh toán: **thanh-toan-va-tich-hop-vnpay.md**
- Sau check-out: **phan-hoi-va-danh-gia.md**

---

### Role: Developer (Lập trình viên)

Developer cần hiểu toàn bộ hệ thống:

**Bắt buộc:**
1. **tong-quan-kien-truc.md** - Hiểu kiến trúc 3-layer
2. **xac-thuc-va-quan-ly-tai-khoan.md** - Security, authentication flow

**Core business logic:**
3. **dat-phong-va-quan-ly-dat-phong.md**
4. **thanh-toan-va-tich-hop-vnpay.md**
5. **quan-ly-phong.md**

**Toàn bộ module (đọc nếu có time):**
- Tất cả 14 file để hiểu toàn hệ thống

**Gợi ý:**
- Đọc theo đúng order: **tong-quan-kien-truc.md** → **xac-thuc-va-quan-ly-tai-khoan.md** → core features
- Dùng Architecture Diagram trong **tong-quan-kien-truc.md** làm reference

---

## Dinh dang & Cau truc Tai lieu

Mỗi file tài liệu (ngoài file này) tuân theo cấu trúc:

### 1. Tong quan nghiep vu (Overview)
- Giải thích business purpose
- Liệt kê các use case chính

### 2. Kien truc & Code Flow
- Diagram showing flow: Controller → Service → DAL → DB
- Mô tả các step chính

### 3. Chi tiet tung ham (Method Details)
Cho mỗi class/method:
- **Muc dich** (Purpose): Mục đích của method
- **Input** (Parameters): Tham số đầu vào
- **Output** (Return): Giá trị trả về
- **Logic xu ly** (Implementation Steps): Chi tiết từng bước logic
- **Xu ly loi** (Error Handling): Cách xử lý lỗi
- **Lien ket** (Dependencies): Class/method khác liên quan

### 4. Summary
- Tóm tắt flow chung
- Key concepts

---

## Danh sach Controller theo vai tro

### Admin Controllers
```
/admin/dashboard - AdminDashboardController
/admin/reports/* - AdminReportController
/admin/content/hotel-info - AdminHotelInfoController
/admin/settings - AdminSettingsController
/admin/customers/* - AdminCustomerController
/admin/rooms/* - AdminRoomController
/admin/staff/* - AdminStaffController
/admin/users/* - AdminUsersController
/admin/promotions/* - AdminPromotionController
/admin/vouchers/* - AdminVoucherController
/admin/service-requests/* - AdminServiceRequestController
/admin/feedback/* - AdminFeedbackController
```

### Staff Controllers
```
/staff/dashboard - StaffDashboardController
/staff/login - StaffLoginController
/staff/bookings/* - StaffBookingController
/staff/payments/* - StaffPaymentController
/staff/rooms/* - StaffRoomController
/staff/cleaning/* - StaffCleaningController
/staff/service-requests/* - StaffServiceRequestController
```

### Customer/Common Controllers
```
/auth/login - AuthController
/auth/logout - AuthController
/customer/* - CustomerController
/booking/* - BookingController
/booking-extension/* - BookingExtensionController
/payment/* - PaymentController
/rooms/* - RoomController
/vnpay-ipn - VNPayIPNController
/home - HomeController
```

---

## Key Concepts - Khai niem Quan trong

### 1. 3-Layer Architecture
```
Presentation Layer (Controller, Filter, JSP)
         ↓
Business Logic Layer (Service, Util)
         ↓
Data Access Layer (Repository)
         ↓
Database Layer (SQL Server)
```

### 2. Role-Based Access Control (RBAC)
- 3 roles: Admin, Staff, Customer
- Filters: AdminAuthFilter, StaffAuthFilter, AuthFilter
- Check roleId in session

### 3. Session Management
- SessionHelper: store/retrieve account từ session
- Key: "loggedInAccount"
- Logout: session.invalidate()

### 4. Generic Repository Pattern
```java
public abstract class BaseRepository<T> {
    protected T queryOne(String sql, Object... params)
    protected List<T> queryList(String sql, Object... params)
    protected int executeUpdate(String sql, Object... params)
    protected int executeInsert(String sql, Object... params)
}
```

### 5. Service Layer Pattern
- Business logic nằm ở Service class
- Repository chỉ làm CRUD
- Controller gọi Service, không trực tiếp Repository

### 6. HikariCP Connection Pooling
- DbContext.getConnection() lấy connection từ pool
- Tự động quản lý connection
- Cấu hình trong db.properties

### 7. VNPay Integration
- Generate request với HMAC signature
- Redirect to VNPay sandbox
- Handle callback tại VNPayIPNController

### 8. Email Service
- EmailHelper: sendOtp, sendWalkInCredentials
- Config từ mail.properties hoặc environment variables
- HTML template support

### 9. Utility Classes
- DateHelper: xử lý date/time
- ValidationHelper: kiểm tra email, phone, password
- PasswordHelper: mã hóa password
- SessionHelper: quản lý session
- OtpHelper: tạo/kiểm tra OTP

### 10. Singleton Pattern (HotelInfo)
- Chỉ một dòng duy nhất trong table HotelInfo
- insertDefault() nếu chưa tồn tại
- findFirst() lấy dữ liệu

---

## Common Database Operations

### Query Single Row
```java
HotelInfo info = hotelInfoRepository.findFirst();
Account account = accountRepository.findByEmail(email);
```

### Query Multiple Rows
```java
List<Room> rooms = roomRepository.findByStatus(RoomStatus.AVAILABLE);
List<Booking> bookings = bookingRepository.findByCustomer(customerId);
```

### Insert
```java
int newId = accountRepository.insert(account);
```

### Update
```java
int rowsAffected = roomRepository.update(room);
```

### Count
```java
int total = roomRepository.countAll();
int occupied = roomRepository.countByStatus(RoomStatus.OCCUPIED);
```

### Aggregate Functions
```java
BigDecimal totalRevenue = bookingRepository.sumTotalPrice();
BigDecimal periodRevenue = bookingRepository.sumTotalPriceByDateRange(start, end);
```

---

## Tips for Reading

1. **Bắt đầu từ Architecture**: Luôn bắt đầu từ **tong-quan-kien-truc.md** để hiểu tổng thể

2. **Theo dõi Flow**: Khi đọc chi tiết hàm, theo dõi flow từ Controller → Service → Repository

3. **Cross-reference**: Dùng "Lien ket" section để truy cập file tài liệu liên quan

4. **Database First**: Hiểu entity models trước khi đọc logic

5. **Use Case Focus**: Mỗi file focus vào một use case chính hoặc role

6. **Code Reading**: Mở file `.java` cùng lúc khi đọc tài liệu

---

## Lien ket Nhanh - Quick Links

- **Architecture**: tong-quan-kien-truc.md
- **Login/Security**: xac-thuc-va-quan-ly-tai-khoan.md
- **Main Use Case (Booking)**: dat-phong-va-quan-ly-dat-phong.md
- **Payment**: thanh-toan-va-tich-hop-vnpay.md
- **Admin Dashboard**: bao-cao-va-thong-ke.md
- **Hotel Config**: thong-tin-khach-san.md

---

## Gia tri Tai lieu nay

File này cung cấp:
- Danh sách tất cả 14 tài liệu
- Thứ tự đọc khuyến nghị (dựa trên dependencies)
- Phân loại theo vai trò (Admin, Staff, Customer, Developer)
- Giải thích từng section format
- Key concepts và common operations
- Tips để đọc hiệu quả

**Sử dụng file này làm entry point vào documentation.**
