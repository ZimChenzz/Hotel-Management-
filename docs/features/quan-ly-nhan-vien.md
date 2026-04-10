# Quản lý Nhân viên

## Tổng quan nghiệp vụ

Tính năng quản lý nhân viên cung cấp:

- Admin quản lý danh sách nhân viên (xem, tạo, sửa, toggle trạng thái)
- Nhân viên đăng nhập vào portal riêng
- Nhân viên xem dashboard với thống kê phòng, booking, service requests
- Quản lý vai trò (Staff hoặc Admin)
- Kích hoạt/vô hiệu hóa tài khoản nhân viên

## Kiến trúc & Code Flow

```
[Admin] → [AdminAuthFilter]
    ↓
    [AdminStaffController]
    ↓
    [AdminStaffService]
    ↓
    [AccountRepository]
    ↓
    [Database: Account]

[Staff] → [StaffAuthFilter]
    ↓
    [StaffLoginController / StaffDashboardController]
    ↓
    [AuthService / RoomRepository / BookingRepository / ServiceRequestRepository]
    ↓
    [Database]
```

Luồng chính:
1. Admin GET /admin/staff → danh sách nhân viên
2. Admin POST /admin/staff/create → tạo nhân viên
3. Admin POST /admin/staff/edit → sửa thông tin nhân viên
4. Admin POST /admin/staff/toggle-status → bật/tắt trạng thái
5. Staff POST /staff/login → đăng nhập
6. Staff GET /staff/dashboard → xem thống kê

## Chi tiết từng hàm

### AdminStaffController

#### handleList
- **Mục đích**: Hiển thị danh sách nhân viên
- **Input**: success (query param, optional)
- **Output**: Forward tới /WEB-INF/views/admin/staff/list.jsp
- **Logic xử lý**:
  1. Lấy danh sách staff từ adminStaffService.getAllStaff()
  2. Kiểm tra success parameter:
     - "created" → set success message "Tạo nhân viên thành công!"
     - "updated" → set success message "Cập nhật nhân viên thành công!"
     - "toggled" → set success message "Cập nhật trạng thái thành công!"
  3. Set attributes: staffList, activePage="staff", pageTitle="Quản lý nhân viên"
  4. Forward tới list.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: AdminStaffService.getAllStaff()

#### handleCreateForm
- **Mục đích**: Hiển thị form tạo nhân viên mới
- **Input**: Không có
- **Output**: Forward tới form.jsp
- **Logic xử lý**:
  1. Set attributes: activePage="staff", pageTitle="Thêm nhân viên", isEdit=false
  2. Forward tới form.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

#### handleEditForm
- **Mục đích**: Hiển thị form sửa nhân viên
- **Input**: id (accountId)
- **Output**: Forward tới form.jsp hoặc redirect với error
- **Logic xử lý**:
  1. Parse id từ request
  2. Lấy staff từ adminStaffService.getStaffById()
  3. Nếu null: redirect tới /admin/staff?error=notfound
  4. Set attributes: staff, activePage="staff", pageTitle="Sửa nhân viên", isEdit=true
  5. Forward tới form.jsp
- **Xử lý lỗi**: Staff not found
- **Liên kết**: AdminStaffService.getStaffById()

#### handleCreate
- **Mục đích**: Tạo nhân viên mới
- **Input**: email, password, fullName, phone, address
- **Output**: Redirect tới list với success hoặc forward form với error
- **Logic xử lý**:
  1. Lấy dữ liệu từ request
  2. Gọi adminStaffService.createStaff(email, password, fullName, phone, address)
  3. Nếu result == -1 (email exists):
     - Set error message "Email đã tồn tại!"
     - Set isEdit=false
     - Forward tới form.jsp
  4. Nếu result > 0 (success):
     - Redirect tới /admin/staff?success=created
  5. Nếu result <= 0 (fail):
     - Set error message "Không thể tạo nhân viên!"
     - Forward tới form.jsp
- **Xử lý lỗi**: Email already exists, creation failed
- **Liên kết**: AdminStaffService.createStaff()

#### handleEdit
- **Mục đích**: Cập nhật thông tin nhân viên
- **Input**: id, fullName, phone, address, roleId (optional)
- **Output**: Redirect tới list với success hoặc back tới form với error
- **Logic xử lý**:
  1. Parse id, fullName, phone, address
  2. Parse roleId (try-catch NumberFormatException, default = STAFF)
  3. Gọi adminStaffService.updateStaff(id, fullName, phone, address, roleId)
  4. Nếu true (success):
     - Redirect tới /admin/staff?success=updated
  5. Nếu false (fail):
     - Set error message "Không thể cập nhật nhân viên!"
     - Call handleEditForm() lại
- **Xử lý lỗi**: Update failed, staff not found, invalid roleId
- **Liên kết**: AdminStaffService.updateStaff()

#### handleToggleStatus
- **Mục đích**: Bật/tắt trạng thái hoạt động của nhân viên
- **Input**: id (accountId)
- **Output**: Redirect tới list với success message
- **Logic xử lý**:
  1. Parse id
  2. Gọi adminStaffService.toggleStaffStatus(id)
  3. Redirect tới /admin/staff?success=toggled
- **Xử lý lỗi**: Không có explicit error handling (async action)
- **Liên kết**: AdminStaffService.toggleStaffStatus()

### AdminStaffService

#### getAllStaff
- **Mục đích**: Lấy danh sách tất cả nhân viên
- **Input**: Không có
- **Output**: List<Account> (chỉ có role = STAFF)
- **Logic xử lý**:
  1. Gọi accountRepository.findAllByRoleId(RoleConstant.STAFF)
  2. Return list, sắp xếp theo created_at DESC
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: AccountRepository.findAllByRoleId()

#### getStaffById
- **Mục đích**: Lấy chi tiết nhân viên theo ID
- **Input**: accountId
- **Output**: Account object hoặc null
- **Logic xử lý**:
  1. Gọi accountRepository.findById(accountId)
  2. Kiểm tra: account != null và (roleId = STAFF hoặc ADMIN)
  3. Return account nếu hợp lệ, null nếu không
- **Xử lý lỗi**: Không có
- **Liên kết**: AccountRepository.findById()

#### createStaff
- **Mục đích**: Tạo nhân viên mới
- **Input**: email, password, fullName, phone, address
- **Output**: int (accountId nếu thành công, -1 nếu email exists)
- **Logic xử lý**:
  1. Kiểm tra email đã tồn tại bằng accountRepository.existsByEmail()
  2. Nếu tồn tại: return -1
  3. Tạo Account object:
     - email
     - password được hash bằng BCrypt.hashpw() với gensalt()
     - fullName, phone, address
     - roleId = STAFF
     - isActive = true
  4. Insert account: accountRepository.insert() → return accountId
  5. Return accountId
- **Xử lý lỗi**: Email exists (-1), insert failed (return <= 0)
- **Liên kết**: AccountRepository.existsByEmail(), AccountRepository.insert(), BCrypt

#### updateStaff
- **Mục đích**: Cập nhật thông tin nhân viên
- **Input**: accountId, fullName, phone, address, roleId
- **Output**: boolean (true = success, false = fail)
- **Logic xử lý**:
  1. Lấy account từ accountRepository.findById()
  2. Nếu null: return false
  3. Kiểm tra account role:
     - Nếu không phải STAFF hoặc ADMIN: return false
  4. Validate roleId:
     - Nếu không phải STAFF hoặc ADMIN: set default = STAFF
  5. Update account: fullName, phone, address
  6. Gọi accountRepository.update(account)
  7. Nếu roleId khác với current role:
     - Gọi accountRepository.updateRoleId(accountId, roleId)
  8. Return true
- **Xử lý lỗi**: Account not found, account not staff, update failed
- **Liên kết**: AccountRepository.findById(), AccountRepository.update(), AccountRepository.updateRoleId()

#### toggleStaffStatus
- **Mục đích**: Bật/tắt trạng thái hoạt động (is_active)
- **Input**: accountId
- **Output**: boolean (true = success, false = fail)
- **Logic xử lý**:
  1. Lấy account từ accountRepository.findById()
  2. Nếu null: return false
  3. Kiểm tra account role == STAFF
  4. Nếu không: return false
  5. Gọi accountRepository.updateIsActive(accountId, !account.isActive())
     - Đảo lại trạng thái (active ↔ inactive)
  6. Return result > 0
- **Xử lý lỗi**: Account not found, not staff, update failed
- **Liên kết**: AccountRepository.findById(), AccountRepository.updateIsActive()

### StaffLoginController

#### doGet
- **Mục đích**: Hiển thị trang đăng nhập staff
- **Input**: Không có
- **Output**: Forward tới /WEB-INF/views/staff/login.jsp hoặc redirect
- **Logic xử lý**:
  1. Kiểm tra user đã đăng nhập bằng SessionHelper.isLoggedIn()
  2. Nếu đã login:
     - Lấy account từ session
     - Kiểm tra roleId == STAFF
     - Nếu là staff: redirect tới /staff/dashboard
  3. Nếu chưa login: forward tới login.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: SessionHelper.isLoggedIn(), SessionHelper.getLoggedInAccount()

#### doPost
- **Mục đích**: Xác thực staff login
- **Input**: email, password, returnUrl (optional)
- **Output**: Redirect hoặc forward login.jsp với error
- **Logic xử lý**:
  1. Lấy email, password, returnUrl từ request
  2. Gọi authService.login(email, password)
  3. Nếu lỗi:
     - Set error attribute
     - Set email, returnUrl attributes
     - Forward tới login.jsp
     - Return
  4. Lấy account từ result
  5. Kiểm tra: account.roleId == STAFF
  6. Nếu không phải staff:
     - Set error message "Tài khoản này không có quyền truy cập cổng nhân viên"
     - Forward tới login.jsp
     - Return
  7. Invalidate session cũ (session fixation prevention)
  8. Tạo session mới: SessionHelper.setLoggedInAccount()
  9. Kiểm tra returnUrl:
     - Nếu tồn tại và hợp lệ (startsWith contextPath): redirect tới returnUrl
     - Nếu không: redirect tới /staff/dashboard
- **Xử lý lỗi**: Invalid credentials, account inactive, not staff role
- **Liên kết**: AuthService.login(), SessionHelper

### StaffDashboardController

#### doGet
- **Mục đích**: Hiển thị dashboard với thống kê cho staff
- **Input**: Không có
- **Output**: Forward tới /WEB-INF/views/staff/dashboard.jsp
- **Logic xử lý**:
  1. Lấy thống kê phòng:
     - roomsAvailable = roomRepository.countByStatus(RoomStatus.AVAILABLE)
     - roomsOccupied = roomRepository.countByStatus(RoomStatus.OCCUPIED)
     - roomsCleaning = roomRepository.countByStatus(RoomStatus.CLEANING)
  2. Lấy thống kê booking:
     - pendingCheckins = bookingRepository.countByStatus(BookingStatus.CONFIRMED)
     - pendingCheckouts = bookingRepository.countByStatus(BookingStatus.CHECKED_IN)
  3. Lấy thống kê service request:
     - pendingServiceRequests = serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.PENDING)
  4. Set attributes cho các thống kê trên
  5. Set attributes: activePage="dashboard", pageTitle="Dashboard"
  6. Forward tới dashboard.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: RoomRepository.countByStatus(), BookingRepository.countByStatus(), ServiceRequestRepository.countByStatus()

## Luồng dữ liệu (Data Flow)

### Luồng 1: Admin quản lý nhân viên
```
Admin → /admin/staff → handleList()
  → AdminStaffService.getAllStaff()
    → AccountRepository.findAllByRoleId(STAFF)
    → Database (Account WHERE role_id = 2)
  → Display list.jsp

Admin → /admin/staff/create (GET) → handleCreateForm()
  → Display form.jsp with isEdit=false

Admin → /admin/staff/create (POST) → handleCreate()
  → AdminStaffService.createStaff(email, password, fullName, phone, address)
    → Check email exists: AccountRepository.existsByEmail()
    → Hash password: BCrypt.hashpw()
    → Create Account object (roleId=STAFF, isActive=true)
    → Insert: AccountRepository.insert() → Database
  → Redirect to /admin/staff?success=created

Admin → /admin/staff/edit?id=X (GET) → handleEditForm()
  → AdminStaffService.getStaffById(id)
    → AccountRepository.findById(id)
    → Check role = STAFF or ADMIN
  → Display form.jsp with staff data, isEdit=true

Admin → /admin/staff/edit (POST) → handleEdit()
  → AdminStaffService.updateStaff(id, fullName, phone, address, roleId)
    → AccountRepository.findById()
    → Update object
    → AccountRepository.update() → Database
    → If roleId changed: AccountRepository.updateRoleId() → Database
  → Redirect to /admin/staff?success=updated

Admin → /admin/staff/toggle-status (POST) → handleToggleStatus()
  → AdminStaffService.toggleStaffStatus(id)
    → AccountRepository.findById()
    → Check role = STAFF
    → AccountRepository.updateIsActive(id, !isActive) → Database
  → Redirect to /admin/staff?success=toggled
```

### Luồng 2: Staff đăng nhập
```
Staff → /staff/login (GET) → StaffLoginController.doGet()
  → Check if already logged in and role = STAFF
  → If yes: redirect to /staff/dashboard
  → If no: display login.jsp

Staff → /staff/login (POST) → StaffLoginController.doPost()
  → Parse email, password, returnUrl
  → AuthService.login(email, password)
    → AccountRepository.findByEmail()
    → Check is_active = true
    → PasswordHelper.verify(password, hash)
  → Check account.roleId = STAFF
  → If not staff: error "Tài khoản này không có quyền truy cập cổng nhân viên"
  → Invalidate old session
  → SessionHelper.setLoggedInAccount() (new session)
  → Check returnUrl (valid and within context)
  → Redirect to returnUrl or /staff/dashboard
```

### Luồng 3: Staff xem dashboard
```
Staff → /staff/dashboard → StaffDashboardController.doGet()
  → [Protected by StaffAuthFilter: check login + role=STAFF]
  → RoomRepository.countByStatus(AVAILABLE) → Database (Room WHERE status='Available')
  → RoomRepository.countByStatus(OCCUPIED) → Database (Room WHERE status='Occupied')
  → RoomRepository.countByStatus(CLEANING) → Database (Room WHERE status='Cleaning')
  → BookingRepository.countByStatus(CONFIRMED) → Database
  → BookingRepository.countByStatus(CHECKED_IN) → Database
  → ServiceRequestRepository.countByStatus(PENDING) → Database
  → Set all attributes
  → Forward to dashboard.jsp
  → Display statistics and charts
```

## Bảo mật & Phân quyền

### Admin Authorization
- AdminAuthFilter yêu cầu login + role = ADMIN
- Admin có thể:
  - Xem danh sách nhân viên
  - Tạo nhân viên mới
  - Sửa thông tin nhân viên (không password)
  - Toggle trạng thái (active/inactive)
  - Gán vai trò (STAFF hoặc ADMIN)

### Staff Authorization
- StaffAuthFilter yêu cầu login + role = STAFF
- StaffLoginController kiểm tra role kỹ lưỡng
- Staff chỉ có thể truy cập /staff/* endpoints
- Inactive staff (is_active=false) không thể login

### Data Protection
- Password được hash (BCrypt) khi tạo nhân viên
- Không hiển thị password ở UI
- Email là unique (kiểm tra trước insert)
- Role assignment kiểm tra chặt chẽ (chỉ STAFF hoặc ADMIN)

### Input Validation
- Email format validation (via AuthService.login)
- Required fields: email, password, fullName
- Phone, address có thể blank
- RoleId validation (default = STAFF nếu invalid)

## Entity Relationships

```
Account (account_id, email, password, full_name, phone, address, role_id, is_active, created_at)
    ↓ (roleId = STAFF)
Room (room_id, status, ...)
Booking (booking_id, status, ...)
ServiceRequest (request_id, status, ...)
```

## Các Role và Quyền

### Admin
- Tạo nhân viên mới
- Sửa thông tin nhân viên (fullName, phone, address, role)
- Bật/tắt status (is_active)
- Xem danh sách nhân viên
- Chỉ admin mới có thể tạo/sửa nhân viên

### Staff
- Đăng nhập vào portal
- Xem dashboard (thống kê phòng, booking, service requests)
- Truy cập các staff-specific functions
- Không thể sửa hồ sơ của chính mình (trong scope này)

## Status Management

### Account Status
- **is_active = true**: Nhân viên hoạt động, có thể login
- **is_active = false**: Nhân viên bị vô hiệu hóa, không thể login

### Room Status (từ StaffDashboardController)
- **AVAILABLE**: Phòng sẵn sàng cho khách
- **OCCUPIED**: Phòng đang có khách ở
- **CLEANING**: Phòng đang được vệ sinh

### Booking Status (từ StaffDashboardController)
- **CONFIRMED**: Booking đã xác nhận, chờ check-in
- **CHECKED_IN**: Khách đã check-in, chờ check-out

### Service Request Status
- **PENDING**: Yêu cầu chưa xử lý

## Constants & Configuration

- **RoleConstant.ADMIN**: 1
- **RoleConstant.STAFF**: 2
- **RoomStatus.AVAILABLE**: "Available"
- **RoomStatus.OCCUPIED**: "Occupied"
- **RoomStatus.CLEANING**: "Cleaning"
- **BookingStatus.CONFIRMED**: "Confirmed"
- **BookingStatus.CHECKED_IN**: "CheckedIn"
- **ServiceRequestStatusConstant.PENDING**: "Pending"

## Repository Methods

### AccountRepository
- `findById(accountId)` - Lấy account theo ID
- `existsByEmail(email)` - Kiểm tra email đã tồn tại
- `insert(account)` - Tạo account mới
- `update(account)` - Cập nhật account (không password)
- `updateRoleId(accountId, roleId)` - Cập nhật vai trò
- `updateIsActive(accountId, isActive)` - Cập nhật trạng thái
- `findAllByRoleId(roleId)` - Lấy danh sách account theo role

### RoomRepository
- `countByStatus(status)` - Đếm phòng theo trạng thái

### BookingRepository
- `countByStatus(status)` - Đếm booking theo trạng thái

### ServiceRequestRepository
- `countByStatus(status)` - Đếm service request theo trạng thái

## Các Error Messages

- "Email đã tồn tại!"
- "Không thể tạo nhân viên!"
- "Không thể cập nhật nhân viên!"
- "Nhân viên không tìm thấy" (error=notfound)
- "Email hoặc mật khẩu không đúng"
- "Tài khoản không hoạt động"
- "Tài khoản này không có quyền truy cập cổng nhân viên"
- "Tài khoản này không có quyền admin"

## Thống kê Dashboard

### Phòng (Rooms)
- Số phòng sẵn sàng (Available)
- Số phòng đang sử dụng (Occupied)
- Số phòng đang vệ sinh (Cleaning)

### Booking
- Số booking chờ check-in (Confirmed)
- Số booking đang ở (Checked In)

### Service Request
- Số yêu cầu dịch vụ chờ xử lý (Pending)

## Các Câu Hỏi Chưa Giải Quyết

1. Admin có thể xóa nhân viên không?
2. Nếu xóa nhân viên, ai xử lý service requests của họ?
3. Có audit trail khi admin sửa staff không?
4. Nhân viên có thể thay đổi password không?
5. Có sự kiện logging khi staff login/logout không?
6. Staff có thể xem doanh thu/payment không?
7. Dashboard có thể refresh real-time không (websocket)?
8. Có phân quyền chi tiết hơn giữa STAFF và ADMIN không?
9. Admin tạo staff với password tạm thời, có mail gửi password không?
10. Có role khác ngoài STAFF và ADMIN không (e.g., Manager)?
