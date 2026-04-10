# Quản lý Khách hàng

## Tổng quan nghiệp vụ

Tính năng quản lý khách hàng cung cấp:

- Khách hàng tự quản lý hồ sơ (xem, chỉnh sửa thông tin cá nhân)
- Admin quản lý danh sách khách hàng (xem, tạo, sửa, xóa)
- Quản lý điểm loyalty và membership level
- Theo dõi lịch sử booking và feedback
- Quản lý service requests từ phía khách hàng

## Kiến trúc & Code Flow

```
[Customer/Admin] → [AuthFilter]
    ↓
    [CustomerController / AdminCustomerController]
    ↓
    [AdminCustomerService / AccountRepository / CustomerRepository]
    ↓
    [Database: Account, Customer]
```

Luồng chính:
1. Customer GET /customer/profile → hiển thị thông tin
2. Customer POST /customer/profile → cập nhật thông tin
3. Admin GET /admin/customers → danh sách khách hàng
4. Admin POST /admin/customers/create → tạo khách hàng
5. Admin POST /admin/customers/edit → sửa khách hàng

## Chi tiết từng hàm

### CustomerController

#### handleProfileGet
- **Mục đích**: Hiển thị trang hồ sơ của khách hàng
- **Input**: HttpServletRequest
- **Output**: Forward tới /WEB-INF/views/customer/profile.jsp
- **Logic xử lý**:
  1. Lấy account từ session bằng SessionHelper.getLoggedInAccount()
  2. Refresh data từ database bằng accountRepository.findById()
  3. Set attribute "account"
  4. Forward tới profile.jsp
- **Xử lý lỗi**: Không có (already protected by AuthFilter)
- **Liên kết**: AccountRepository.findById(), SessionHelper.getLoggedInAccount()

#### handleProfilePost
- **Mục đích**: Cập nhật thông tin hồ sơ khách hàng
- **Input**: fullName, phone, address
- **Output**: Forward tới profile.jsp với success/error message
- **Logic xử lý**:
  1. Lấy account từ session
  2. Validate fullName không trống
  3. Nếu lỗi: set error attribute, forward lại profile.jsp
  4. Refresh account từ database
  5. Update fullName (sanitize), phone, address
  6. Gọi accountRepository.update()
  7. Nếu thành công:
     - Cập nhật session: SessionHelper.setLoggedInAccount()
     - Set success message
  8. Forward lại profile.jsp
- **Xử lý lỗi**: Empty fullName, update failed
- **Liên kết**: AccountRepository.findById(), AccountRepository.update(), ValidationHelper.sanitize()

#### handleBookingsGet
- **Mục đích**: Hiển thị danh sách booking của khách hàng
- **Input**: status (optional filter)
- **Output**: Forward tới bookings.jsp
- **Logic xử lý**:
  1. Lấy account từ session
  2. Lấy danh sách booking từ bookingService.getCustomerBookings(accountId)
  3. Nếu có status filter: filter danh sách booking
  4. Set attributes: bookings, statusFilter
  5. Forward tới bookings.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: BookingService.getCustomerBookings()

#### handleBookingDetailGet
- **Mục đích**: Hiển thị chi tiết một booking
- **Input**: id (bookingId)
- **Output**: Forward tới booking-detail.jsp hoặc error 403
- **Logic xử lý**:
  1. Parse bookingId từ request
  2. Lấy account từ session
  3. Lấy booking từ bookingService.getBookingById()
  4. Kiểm tra: booking.customerId == account.accountId (authorization check)
  5. Nếu không: sendError(403)
  6. Lấy danh sách service requests từ serviceRequestService.getBookingRequests()
  7. Lấy feedback (nếu có) từ feedbackService.getBookingFeedback()
  8. Kiểm tra canLeaveFeedback:
     - Chưa có feedback
     - Booking status = "CheckedOut" hoặc "Confirmed"
  9. Lấy flash messages từ session (successMessage, errorMessage)
  10. Set attributes và forward
- **Xử lý lỗi**: Booking not found, permission denied (403)
- **Liên kết**: BookingService.getBookingById(), ServiceRequestService, FeedbackService

#### handleServiceRequestPost
- **Mục đích**: Tạo cleaning service request
- **Input**: bookingId, serviceType
- **Output**: Redirect lại /customer/booking?id=bookingId
- **Logic xử lý**:
  1. Parse bookingId, serviceType
  2. Lấy account từ session
  3. Nếu serviceType = "Cleaning":
     - Gọi serviceRequestService.createCleaningRequest()
     - Set flash message (success hoặc error)
  4. Redirect tới booking detail
- **Xử lý lỗi**: Invalid parameters, service creation failed
- **Liên kết**: ServiceRequestService.createCleaningRequest()

#### handleCreateRequestPost
- **Mục đích**: Tạo service request tổng quát
- **Input**: bookingId, serviceType, description, priority (optional)
- **Output**: Redirect tới /customer/requests
- **Logic xử lý**:
  1. Parse parameters
  2. Validate bookingId, serviceType
  3. Lấy account từ session
  4. Gọi serviceRequestService.createRequest(bookingId, accountId, serviceType, description, priority)
  5. Set flash message
  6. Redirect tới requests page
- **Xử lý lỗi**: Invalid parameters, creation failed
- **Liên kết**: ServiceRequestService.createRequest()

#### handleFeedbackPost
- **Mục đích**: Tạo feedback/review cho booking
- **Input**: bookingId, rating, comment
- **Output**: Redirect tới booking detail
- **Logic xử lý**:
  1. Parse bookingId, rating
  2. Lấy account từ session
  3. Tạo Feedback object: bookingId, rating, comment
  4. Gọi feedbackService.submitFeedback(accountId, feedback)
  5. Set flash message
  6. Redirect tới booking detail
- **Xử lý lỗi**: Invalid bookingId/rating, submission failed
- **Liên kết**: FeedbackService.submitFeedback()

#### handleCancelBookingPost
- **Mục đích**: Hủy booking
- **Input**: bookingId
- **Output**: Redirect tới booking detail
- **Logic xử lý**:
  1. Parse bookingId
  2. Lấy account từ session
  3. Gọi bookingService.cancelBooking(bookingId, accountId)
     - Kiểm tra ownership
     - Kiểm tra status có thể hủy không
     - Cập nhật status thành "Cancelled"
  4. Set flash message
  5. Redirect tới booking detail
- **Xử lý lỗi**: Booking not found, permission denied, cannot cancel (wrong status)
- **Liên kết**: BookingService.cancelBooking()

#### handleFeedbackUpdatePost
- **Mục đích**: Cập nhật feedback
- **Input**: feedbackId, bookingId, rating, comment
- **Output**: Redirect tới booking detail
- **Logic xử lý**:
  1. Parse feedbackId, bookingId, rating
  2. Lấy account từ session
  3. Tạo Feedback object mới
  4. Gọi feedbackService.updateFeedback(feedbackId, accountId, newFeedback)
  5. Set flash message
  6. Redirect tới booking detail
- **Xử lý lỗi**: Invalid parameters, permission denied, update failed
- **Liên kết**: FeedbackService.updateFeedback()

#### handleFeedbackDeletePost
- **Mục đích**: Xóa feedback
- **Input**: feedbackId, bookingId
- **Output**: Redirect tới booking detail
- **Logic xử lý**:
  1. Parse feedbackId, bookingId
  2. Lấy account từ session
  3. Gọi feedbackService.deleteFeedback(feedbackId, accountId)
  4. Set flash message
  5. Redirect tới booking detail
- **Xử lý lỗi**: Feedback not found, permission denied, delete failed
- **Liên kết**: FeedbackService.deleteFeedback()

#### handleCancelRequestPost
- **Mục đích**: Hủy service request
- **Input**: requestId, bookingId
- **Output**: Redirect tới booking detail
- **Logic xử lý**:
  1. Parse requestId, bookingId
  2. Lấy account từ session
  3. Gọi serviceRequestService.cancelRequest(requestId, accountId)
  4. Set flash message
  5. Redirect tới booking detail
- **Xử lý lỗi**: Request not found, permission denied, cancel failed
- **Liên kết**: ServiceRequestService.cancelRequest()

#### handleReviewsGet
- **Mục đích**: Hiển thị danh sách review của khách hàng
- **Input**: Không có
- **Output**: Forward tới reviews.jsp
- **Logic xử lý**:
  1. Lấy account từ session
  2. Lấy danh sách booking từ bookingService.getCustomerBookings()
  3. Lặp qua mỗi booking, lấy feedback từ feedbackService.getBookingFeedback()
  4. Filter: chỉ lấy feedback có tồn tại (not null)
  5. Set attributes: feedbacks, bookings
  6. Forward tới reviews.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: BookingService.getCustomerBookings(), FeedbackService.getBookingFeedback()

#### handleRequestsGet
- **Mục đích**: Hiển thị danh sách service requests của khách hàng
- **Input**: Không có
- **Output**: Forward tới requests.jsp
- **Logic xử lý**:
  1. Lấy account từ session
  2. Lấy danh sách booking
  3. Lọc: chỉ lấy booking có status = "CheckedIn"
  4. Lặp qua mỗi booking:
     - Lấy service requests từ serviceRequestService.getBookingRequests()
     - Set booking reference cho mỗi request
     - Thêm vào allRequests
  5. Sort allRequests theo requestTime giảm dần
  6. Lấy flash messages từ session
  7. Set attributes: serviceRequests, checkedInBookings, messages
  8. Forward tới requests.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: BookingService.getCustomerBookings(), ServiceRequestService.getBookingRequests()

#### parseIntParam
- **Mục đích**: Parse integer parameter từ request
- **Input**: request, parameterName
- **Output**: Integer hoặc null
- **Logic xử lý**:
  1. Lấy string value từ request.getParameter()
  2. Nếu null hoặc empty: return null
  3. Thử parse Integer.parseInt()
  4. Nếu NumberFormatException: return null
  5. Nếu thành công: return Integer
- **Xử lý lỗi**: NumberFormatException → return null
- **Liên kết**: Không có

### AdminCustomerController

#### handleList
- **Mục đích**: Hiển thị danh sách khách hàng
- **Input**: success (query param, optional)
- **Output**: Forward tới /WEB-INF/views/admin/customers/list.jsp
- **Logic xử lý**:
  1. Lấy danh sách customers từ adminCustomerService.getAllCustomers()
  2. Kiểm tra success parameter:
     - "created" → set success message "Tạo khách hàng thành công!"
     - "updated" → set success message "Cập nhật khách hàng thành công!"
  3. Set attributes: customers, activePage="customers", pageTitle="Quản lý khách hàng"
  4. Forward tới list.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: AdminCustomerService.getAllCustomers()

#### handleCreateForm
- **Mục đích**: Hiển thị form tạo khách hàng mới
- **Input**: Không có
- **Output**: Forward tới form.jsp
- **Logic xử lý**:
  1. Set attributes: activePage="customers", pageTitle="Thêm khách hàng", isEdit=false
  2. Forward tới form.jsp
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

#### handleEditForm
- **Mục đích**: Hiển thị form sửa khách hàng
- **Input**: id (customerId)
- **Output**: Forward tới form.jsp hoặc redirect với error
- **Logic xử lý**:
  1. Parse id từ request
  2. Lấy customer từ adminCustomerService.getCustomerById()
  3. Nếu null: redirect tới /admin/customers?error=notfound
  4. Set attributes: customer, activePage="customers", pageTitle="Sửa khách hàng", isEdit=true
  5. Forward tới form.jsp
- **Xử lý lỗi**: Customer not found
- **Liên kết**: AdminCustomerService.getCustomerById()

#### handleCreate
- **Mục đích**: Tạo khách hàng mới
- **Input**: email, password, fullName, phone, address
- **Output**: Redirect tới list với success hoặc forward form với error
- **Logic xử lý**:
  1. Lấy dữ liệu từ request
  2. Gọi adminCustomerService.createCustomer()
  3. Nếu result == -1 (email exists):
     - Set error message "Email đã tồn tại!"
     - Set isEdit=false
     - Forward tới form.jsp
  4. Nếu result > 0 (success):
     - Redirect tới /admin/customers?success=created
  5. Nếu result <= 0 (fail):
     - Set error message
     - Forward tới form.jsp
- **Xử lý lỗi**: Email already exists, creation failed
- **Liên kết**: AdminCustomerService.createCustomer()

#### handleEdit
- **Mục đích**: Cập nhật thông tin khách hàng
- **Input**: id, fullName, phone, address
- **Output**: Redirect tới list với success hoặc back tới form với error
- **Logic xử lý**:
  1. Parse id
  2. Lấy fullName, phone, address từ request
  3. Gọi adminCustomerService.updateCustomer(id, fullName, phone, address)
  4. Nếu true (success):
     - Redirect tới /admin/customers?success=updated
  5. Nếu false (fail):
     - Set error message
     - Call handleEditForm() lại
- **Xử lý lỗi**: Update failed, customer not found
- **Liên kết**: AdminCustomerService.updateCustomer()

### AdminCustomerService

#### getAllCustomers
- **Mục đích**: Lấy danh sách tất cả khách hàng
- **Input**: Không có
- **Output**: List<Customer> (có thông tin account)
- **Logic xử lý**:
  1. Gọi customerRepository.findAllWithAccount()
  2. Return list
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: CustomerRepository.findAllWithAccount()

#### getCustomerById
- **Mục đích**: Lấy chi tiết khách hàng theo ID
- **Input**: accountId
- **Output**: Customer object (có thông tin account) hoặc null
- **Logic xử lý**:
  1. Gọi customerRepository.findByIdWithAccount(accountId)
  2. Return customer
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: CustomerRepository.findByIdWithAccount()

#### createCustomer
- **Mục đích**: Tạo khách hàng mới (admin function)
- **Input**: email, password, fullName, phone, address
- **Output**: int (accountId nếu thành công, -1 nếu email exists, <= 0 nếu fail)
- **Logic xử lý**:
  1. Kiểm tra email đã tồn tại bằng accountRepository.existsByEmail()
  2. Nếu tồn tại: return -1
  3. Tạo Account object:
     - email
     - password được hash bằng BCrypt.hashpw() với gensalt()
     - fullName, phone, address
     - roleId = CUSTOMER
     - isActive = true
  4. Insert account: accountRepository.insert() → return accountId
  5. Nếu accountId > 0:
     - Insert customer: customerRepository.insert(accountId)
  6. Return accountId
- **Xử lý lỗi**: Email exists (-1), insert failed (return <= 0)
- **Liên kết**: AccountRepository.existsByEmail(), AccountRepository.insert(), CustomerRepository.insert(), BCrypt

#### updateCustomer
- **Mục đích**: Cập nhật thông tin khách hàng (không password)
- **Input**: accountId, fullName, phone, address
- **Output**: boolean (true = success, false = fail)
- **Logic xử lý**:
  1. Lấy account từ accountRepository.findById()
  2. Nếu null: return false
  3. Update: fullName, phone, address
  4. Gọi accountRepository.update(account)
  5. Return true nếu updated > 0, else false
- **Xử lý lỗi**: Account not found, update failed
- **Liên kết**: AccountRepository.findById(), AccountRepository.update()

## Luồng dữ liệu (Data Flow)

### Luồng 1: Customer cập nhật profile
```
Customer → /customer/profile (GET) → handleProfileGet()
  → AccountRepository.findById() → Database (Account)
  → Display form

Customer → /customer/profile (POST) → handleProfilePost()
  → Validate inputs
  → AccountRepository.findById()
  → Update object (fullName, phone, address)
  → AccountRepository.update() → Database
  → SessionHelper.setLoggedInAccount() (update session)
  → Forward to profile.jsp with success message
```

### Luồng 2: Customer xem booking detail
```
Customer → /customer/booking?id=X → handleBookingDetailGet()
  → BookingService.getBookingById() → Database (Booking)
  → Check ownership: booking.customerId == account.accountId
  → ServiceRequestService.getBookingRequests() → Database
  → FeedbackService.getBookingFeedback() → Database
  → Set canLeaveFeedback flag
  → Forward to booking-detail.jsp
```

### Luồng 3: Admin quản lý khách hàng
```
Admin → /admin/customers → handleList()
  → AdminCustomerService.getAllCustomers()
    → CustomerRepository.findAllWithAccount()
    → Join Account + Customer tables
  → Display list.jsp

Admin → /admin/customers/create (GET) → handleCreateForm()
  → Display form.jsp with isEdit=false

Admin → /admin/customers/create (POST) → handleCreate()
  → AdminCustomerService.createCustomer(email, password, fullName, phone, address)
    → Check email exists: AccountRepository.existsByEmail()
    → Hash password: BCrypt.hashpw()
    → Insert Account: AccountRepository.insert() → Database
    → Insert Customer: CustomerRepository.insert() → Database
  → Redirect to /admin/customers?success=created

Admin → /admin/customers/edit?id=X (GET) → handleEditForm()
  → AdminCustomerService.getCustomerById()
  → Display form.jsp with customer data, isEdit=true

Admin → /admin/customers/edit (POST) → handleEdit()
  → AdminCustomerService.updateCustomer(accountId, fullName, phone, address)
    → AccountRepository.findById()
    → Update object
    → AccountRepository.update() → Database
  → Redirect to /admin/customers?success=updated
```

### Luồng 4: Customer xem service requests
```
Customer → /customer/requests → handleRequestsGet()
  → BookingService.getCustomerBookings(accountId)
  → Filter: status = "CheckedIn" → checkedInBookings
  → For each booking:
    → ServiceRequestService.getBookingRequests(bookingId) → Database
    → Attach booking reference to each request
  → Sort by requestTime DESC
  → Get flash messages from session
  → Forward to requests.jsp
```

### Luồng 5: Customer tạo service request
```
Customer → /customer/requests/create (POST) → handleCreateRequestPost()
  → Parse bookingId, serviceType, description, priority
  → ServiceRequestService.createRequest(bookingId, accountId, serviceType, desc, priority)
    → Check booking ownership
    → Create ServiceRequest record
    → Insert into Database
  → Set flash message (success/error)
  → Redirect to /customer/requests
```

## Bảo mật & Phân quyền

### Customer Authorization
- AuthFilter yêu cầu login cho /customer/*
- Customer chỉ có thể xem/edit hồ sơ của chính mình
- Customer không thể xem/edit booking của khách khác (kiểm tra booking.customerId == account.accountId)

### Admin Authorization
- AdminAuthFilter yêu cầu login + role = ADMIN
- Admin có thể xem/tạo/sửa khách hàng

### Data Protection
- Password được hash (BCrypt) khi tạo khách hàng
- Không hiển thị password ở UI
- Email là unique (kiểm tra trước insert)
- Sanitize inputs (fullName, address) để tránh XSS

### Input Validation
- Email format validation
- Required fields: email, password, fullName
- Phone, address có thể blank

## Entity Relationships

```
Account (account_id, email, password, full_name, phone, address, role_id, is_active, created_at)
    ↓ (1:1)
Customer (account_id, loyalty_points, membership_level)
    ↓ (1:N)
Booking (booking_id, customer_id, room_id, ...)
    ↓ (1:N)
ServiceRequest (request_id, booking_id, ...)
Feedback (feedback_id, booking_id, ...)
```

## Các Role và Quyền

### Customer
- Xem hồ sơ cá nhân
- Sửa thông tin cá nhân (fullName, phone, address)
- Xem danh sách booking
- Xem chi tiết booking
- Tạo feedback/review cho booking
- Sửa/xóa feedback của chính mình
- Tạo service request
- Hủy service request của chính mình

### Admin
- Xem danh sách tất cả khách hàng
- Tạo khách hàng mới
- Sửa thông tin khách hàng (không thể sửa password)
- Xem chi tiết khách hàng

## Các Error Messages

- "Email đã tồn tại!"
- "Không thể tạo khách hàng!"
- "Không thể cập nhật khách hàng!"
- "Họ tên không được để trống"
- "Cập nhật thất bại"
- "Khách hàng không tìm thấy"

## Constants & Configuration

- **RoleConstant.CUSTOMER**: 3
- **Default membership_level**: "Standard"
- **Default loyalty_points**: 0

## Repository Methods

### AccountRepository
- `findById(accountId)` - Lấy account theo ID
- `existsByEmail(email)` - Kiểm tra email đã tồn tại
- `insert(account)` - Tạo account mới
- `update(account)` - Cập nhật account

### CustomerRepository
- `findByIdWithAccount(accountId)` - Lấy customer cùng thông tin account
- `findAllWithAccount()` - Lấy danh sách customer cùng account
- `insert(accountId)` - Tạo customer record

## Các Câu Hỏi Chưa Giải Quyết

1. Admin có thể xóa khách hàng không?
2. Nếu xóa khách hàng, booking của họ sao thế?
3. Customer có thể tự xóa tài khoản không?
4. Có audit trail (log) khi admin sửa customer không?
5. Loyalty points được cập nhật bằng cách nào?
6. Membership level được nâng cấp dựa trên tiêu chí gì?
7. Customer có thể thay đổi email không?
8. Admin tạo customer với password tạm thời, có mail gửi password không?
9. Có giới hạn số lần sửa thông tin không?
10. Customer data retention policy khi account inactive?
