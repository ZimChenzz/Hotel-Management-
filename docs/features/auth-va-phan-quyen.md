# Xác thực và Phân quyền

## Tổng quan nghiệp vụ

Tính năng xác thực và phân quyền là nền tảng an niệm của hệ thống quản lý khách sạn. Nó cung cấp:

- Quản lý tài khoản người dùng (khách hàng, nhân viên, admin)
- Xác thực người dùng qua email/mật khẩu hoặc Google OAuth
- Quản lý phiên làm việc an toàn
- Phân quyền truy cập dựa trên vai trò (CUSTOMER, STAFF, ADMIN)
- Bảo vệ mật khẩu bằng hashing BCrypt
- Khôi phục mật khẩu qua OTP gửi email
- Đổi mật khẩu với xác minh mật khẩu cũ

## Kiến trúc & Code Flow

```
[Request] → [AuthFilter/AdminAuthFilter/StaffAuthFilter]
    ↓
    Check SessionHelper.isLoggedIn()
    ↓
    [AuthController hoặc StaffLoginController]
    ↓
    [AuthService] (Business logic)
    ↓
    [AccountRepository/CustomerRepository] (Data access)
    ↓
    [Database]
```

Luồng xác thực:
1. User gửi credentials (email + password)
2. AuthController nhận request
3. AuthService xác minh thông tin qua AccountRepository
4. Password được kiểm tra bằng BCrypt.checkpw()
5. Nếu hợp lệ, tạo session và lưu Account vào SessionHelper
6. Redirect dựa trên roleId

## Chi tiết từng hàm

### AuthController

#### handleRegisterPost
- **Mục đích**: Xử lý đăng ký tài khoản khách hàng mới
- **Input**: HttpServletRequest chứa email, password, confirmPassword, fullName, phone, address
- **Output**: Chuyển hướng tới trang chủ nếu thành công, hoặc hiển thị lỗi
- **Logic xử lý**:
  1. Lấy dữ liệu từ request parameters
  2. Gọi authService.register() để xác thực và tạo account
  3. Nếu lỗi: set error attribute, forward lại trang register.jsp
  4. Nếu thành công: auto-login bằng SessionHelper.setLoggedInAccount()
  5. Redirect tới trang chủ
- **Xử lý lỗi**: Hiển thị error message (email đã tồn tại, mật khẩu không hợp lệ, mật khẩu không khớp)
- **Liên kết**: AuthService.register(), SessionHelper.setLoggedInAccount()

#### handleLoginPost
- **Mục đích**: Xác thực người dùng và tạo session
- **Input**: email, password, returnUrl (optional)
- **Output**: Redirect dựa trên role hoặc returnUrl
- **Logic xử lý**:
  1. Lấy email, password, returnUrl từ request
  2. Gọi authService.login() để xác minh credentials
  3. Nếu lỗi: hiển thị error, forward lại login.jsp
  4. Nếu thành công: invalidate session cũ để tránh session fixation attack
  5. Tạo session mới bằng SessionHelper.setLoggedInAccount()
  6. Redirect tới returnUrl (nếu hợp lệ) hoặc dựa trên role
- **Xử lý lỗi**: Invalid credentials, account inactive
- **Liên kết**: AuthService.login(), SessionHelper.setLoggedInAccount(), redirectByRole()

#### handleChangePasswordPost
- **Mục đích**: Cho phép user đã đăng nhập thay đổi mật khẩu
- **Input**: currentPassword, newPassword, confirmPassword
- **Output**: Hiển thị success/error message, forward tới change-password.jsp
- **Logic xử lý**:
  1. Kiểm tra user đã đăng nhập
  2. Lấy account từ session
  3. Gọi authService.changePassword() với accountId
  4. Hiển thị message (success hoặc error)
  5. Forward tới form change-password
- **Xử lý lỗi**: Invalid password format, passwords not match, current password incorrect, new password too similar to old
- **Liên kết**: AuthService.changePassword()

#### handleForgotPasswordPost
- **Mục đích**: Gửi OTP tới email người dùng
- **Input**: email
- **Output**: Redirect tới /auth/verify-otp
- **Logic xử lý**:
  1. Gọi authService.sendOtp(email)
  2. Nếu lỗi: hiển thị error, forward lại forgot-password.jsp
  3. Nếu thành công:
     - Lưu OTP vào session với key "forgot_otp"
     - Lưu email vào session với key "forgot_email"
     - Lưu expiry time vào session
     - Redirect tới /auth/verify-otp
- **Xử lý lỗi**: Invalid email, email not found (return success message for security), email send failed
- **Liên kết**: AuthService.sendOtp(), OtpHelper.getExpiryTime()

#### handleVerifyOtpPost
- **Mục đích**: Xác minh mã OTP người dùng nhập
- **Input**: otp (6 chữ số)
- **Output**: Redirect tới reset-password hoặc hiển thị error
- **Logic xử lý**:
  1. Lấy OTP từ session
  2. Gọi authService.verifyOtp() để kiểm tra:
     - OTP có hợp lệ không
     - OTP có hết hạn không (5 phút)
  3. Nếu lỗi: hiển thị error, forward lại verify-otp.jsp
  4. Nếu thành công: set session attribute "otp_verified" = true, redirect tới reset-password
- **Xử lý lỗi**: OTP invalid, OTP expired
- **Liên kết**: AuthService.verifyOtp()

#### handleResetPasswordPost
- **Mục đích**: Đặt lại mật khẩu sau khi xác minh OTP
- **Input**: newPassword, confirmPassword
- **Output**: Redirect tới login hoặc hiển thị error
- **Logic xử lý**:
  1. Kiểm tra session có "otp_verified" = true
  2. Lấy email từ session
  3. Gọi authService.resetPassword()
  4. Nếu lỗi: hiển thị error, forward lại reset-password.jsp
  5. Nếu thành công:
     - Xóa các session attributes: forgot_otp, forgot_email, forgot_expiry, otp_verified
     - Redirect tới login?reset=success
- **Xử lý lỗi**: Invalid password format, passwords not match, account not found
- **Liên kết**: AuthService.resetPassword()

#### handleGoogleLogin
- **Mục đích**: Chuyển hướng tới Google OAuth authorization
- **Input**: Không có
- **Output**: Redirect tới Google OAuth URL
- **Logic xử lý**:
  1. Kiểm tra Google OAuth có được cấu hình không
  2. Tạo state token UUID để CSRF protection
  3. Lưu state vào session
  4. Lấy authorization URL từ GoogleOAuthHelper
  5. Redirect tới URL đó
- **Xử lý lỗi**: Google not configured
- **Liên kết**: GoogleOAuthHelper.getAuthorizationUrl()

#### handleGoogleCallback
- **Mục đích**: Xử lý callback từ Google OAuth
- **Input**: code (authorization code), state (CSRF token), error (nếu có)
- **Output**: Redirect dựa trên kết quả
- **Logic xử lý**:
  1. Kiểm tra có error từ Google
  2. Xác minh state token (CSRF protection)
  3. Gọi authService.loginWithGoogle(code) để:
     - Trao đổi code lấy user info từ Google
     - Kiểm tra account đã tồn tại không
     - Nếu không: tạo account mới (NEW_USER)
  4. Invalidate session cũ
  5. Tạo session mới
  6. Nếu NEW_USER: redirect tới complete-profile, nếu không: redirect dựa trên role
- **Xử lý lỗi**: Invalid state (CSRF attack), no code, Google authentication error
- **Liên kết**: AuthService.loginWithGoogle(), GoogleOAuthHelper.exchangeCodeAndGetUserInfo()

#### handleCompleteProfilePost
- **Mục đích**: Cho phép user Google mới hoàn thiện hồ sơ
- **Input**: phone, address
- **Output**: Redirect tới home hoặc hiển thị error
- **Logic xử lý**:
  1. Lấy account từ session
  2. Gọi authService.completeProfile() để cập nhật phone, address
  3. Nếu lỗi: hiển thị error, forward lại form
  4. Nếu thành công: cập nhật session account, redirect tới home
- **Xử lý lỗi**: Account not found, update failed
- **Liên kết**: AuthService.completeProfile()

#### redirectByRole
- **Mục đích**: Chuyển hướng user dựa trên role
- **Input**: roleId (ADMIN=1, STAFF=2, CUSTOMER=3)
- **Output**: Redirect tới trang thích hợp
- **Logic xử lý**:
  1. Switch trên roleId:
     - ADMIN → /admin/dashboard
     - STAFF → /staff/dashboard
     - Mặc định → trang chủ
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

### AuthService

#### register
- **Mục đích**: Xác thực và tạo tài khoản khách hàng mới
- **Input**: Account object (email, password, fullName, phone, address), confirmPassword
- **Output**: AuthResult (success/failure message, Account object)
- **Logic xử lý**:
  1. Xác thực email format bằng ValidationHelper.isValidEmail()
  2. Xác thực password strength (ít nhất 6 ký tự, chứa chữ/số) bằng ValidationHelper.isValidPassword()
  3. Kiểm tra fullName không trống
  4. Kiểm tra password khớp với confirmPassword
  5. Kiểm tra email chưa tồn tại bằng accountRepository.existsByEmail()
  6. Normalize email: lowercase + trim
  7. Hash password bằng PasswordHelper.hash() (BCrypt với cost factor 12)
  8. Sanitize fullName, address bằng ValidationHelper.sanitize()
  9. Set roleId = CUSTOMER, isActive = true
  10. Insert vào database bằng accountRepository.insert()
  11. Insert vào bảng Customer (loyalty_points=0, membership_level="Standard")
  12. Clear password trước khi return
- **Xử lý lỗi**: Invalid email, invalid password, passwords not match, email exists, insert failed
- **Liên kết**: AccountRepository.existsByEmail(), AccountRepository.insert(), PasswordHelper.hash(), ValidationHelper

#### login
- **Mục đích**: Xác thực người dùng qua email/password
- **Input**: email, password
- **Output**: AuthResult với Account object nếu thành công
- **Logic xử lý**:
  1. Xác thực email format
  2. Lấy account từ database bằng accountRepository.findByEmail(email.toLowerCase().trim())
  3. Kiểm tra account tồn tại
  4. Kiểm tra account có active (is_active = true)
  5. Xác minh password bằng PasswordHelper.verify(password, account.getPassword())
  6. Clear password trước khi return
- **Xử lý lỗi**: Invalid email format, account not found, account inactive, password incorrect
- **Liên kết**: AccountRepository.findByEmail(), PasswordHelper.verify()

#### changePassword
- **Mục đích**: Thay đổi mật khẩu của user đã đăng nhập
- **Input**: accountId, currentPassword, newPassword, confirmPassword
- **Output**: AuthResult
- **Logic xử lý**:
  1. Xác thực newPassword bằng ValidationHelper.isValidPassword()
  2. Kiểm tra newPassword khớp với confirmPassword
  3. Lấy account từ database bằng accountRepository.findById()
  4. Xác minh currentPassword bằng PasswordHelper.verify()
  5. Kiểm tra newPassword không quá giống currentPassword bằng PasswordHelper.isTooSimilar()
     - Sử dụng Levenshtein distance, threshold 70%
  6. Hash newPassword bằng PasswordHelper.hash()
  7. Update password bằng accountRepository.updatePassword()
- **Xử lý lỗi**: Invalid new password, passwords not match, current password incorrect, new password too similar
- **Liên kết**: AccountRepository.findById(), PasswordHelper.verify(), PasswordHelper.hash()

#### sendOtp
- **Mục đích**: Gửi OTP tới email cho forgot password
- **Input**: email
- **Output**: AuthResult với Account chứa OTP
- **Logic xử lý**:
  1. Xác thực email format
  2. Lấy account từ database
  3. Nếu account không tồn tại: return success message (vì lý do bảo mật)
  4. Nếu tồn tại:
     - Generate OTP 6 chữ số bằng OtpHelper.generateOtp()
     - Gửi email bằng EmailHelper.sendOtp(email, otp)
     - Lưu OTP tạm thời vào Account.password field và return
- **Xử lý lỗi**: Invalid email, email send failed
- **Liên kết**: OtpHelper.generateOtp(), EmailHelper.sendOtp()

#### verifyOtp
- **Mục đích**: Xác minh OTP người dùng nhập
- **Input**: inputOtp (từ user), sessionOtp (từ session), expiryTime (từ session)
- **Output**: boolean
- **Logic xử lý**:
  1. Kiểm tra inputOtp, sessionOtp không null
  2. Kiểm tra OTP không hết hạn bằng OtpHelper.isExpired()
  3. So sánh inputOtp == sessionOtp (case-sensitive)
- **Xử lý lỗi**: Không throw exception, return false nếu invalid
- **Liên kết**: OtpHelper.isExpired()

#### resetPassword
- **Mục đích**: Đặt lại mật khẩu sau xác minh OTP
- **Input**: email, newPassword, confirmPassword
- **Output**: AuthResult
- **Logic xử lý**:
  1. Xác thực newPassword
  2. Kiểm tra newPassword khớp với confirmPassword
  3. Lấy account từ database bằng email
  4. Hash newPassword bằng PasswordHelper.hash()
  5. Update password bằng accountRepository.updatePassword()
- **Xử lý lỗi**: Invalid password, passwords not match, account not found
- **Liên kết**: AccountRepository.findByEmail(), PasswordHelper.hash()

#### loginWithGoogle
- **Mục đích**: Xác thực qua Google OAuth
- **Input**: code (authorization code từ Google)
- **Output**: AuthResult (success với account hoặc failure message)
- **Logic xử lý**:
  1. Trao đổi code lấy user info từ Google bằng GoogleOAuthHelper.exchangeCodeAndGetUserInfo()
  2. Lấy account từ database qua email
  3. Nếu account đã tồn tại:
     - Kiểm tra account active
     - Return success
  4. Nếu account mới:
     - Tạo account mới với password = null (OAuth user không có password)
     - Set roleId = CUSTOMER, isActive = true
     - Insert account vào database
     - Insert vào bảng Customer
     - Return success với message = "NEW_USER"
- **Xử lý lỗi**: Exchange code failed, create account failed, account inactive
- **Liên kết**: GoogleOAuthHelper.exchangeCodeAndGetUserInfo(), AccountRepository

#### completeProfile
- **Mục đích**: Hoàn thiện hồ sơ cho user Google mới
- **Input**: accountId, phone, address
- **Output**: AuthResult
- **Logic xử lý**:
  1. Lấy account từ database
  2. Update phone, address (address được sanitize)
  3. Update database bằng accountRepository.update()
  4. Clear password trước khi return
- **Xử lý lỗi**: Account not found, update failed
- **Liên kết**: AccountRepository.findById(), AccountRepository.update()

### AuthFilter

#### doFilter
- **Mục đích**: Kiểm tra xác thực cho customer endpoints (/customer/*, /booking/*, /payment/*)
- **Input**: ServletRequest, ServletResponse, FilterChain
- **Output**: Cho phép hoặc redirect tới login
- **Logic xử lý**:
  1. Cast request, response sang HTTP versions
  2. Kiểm tra user đã đăng nhập bằng SessionHelper.isLoggedIn()
  3. Nếu chưa:
     - Lấy current request URI + query string
     - Encode thành returnUrl
     - Redirect tới /auth/login?returnUrl=<encoded>
  4. Nếu đã: cho phép request tiếp tục qua chain.doFilter()
- **Xử lý lỗi**: Không throw exception
- **Liên kết**: SessionHelper.isLoggedIn()

### AdminAuthFilter

#### doFilter
- **Mục đích**: Kiểm tra xác thực và phân quyền admin (/admin/*)
- **Input**: ServletRequest, ServletResponse, FilterChain
- **Output**: Cho phép hoặc redirect
- **Logic xử lý**:
  1. Kiểm tra user đã đăng nhập
  2. Nếu chưa: redirect tới /auth/login với returnUrl
  3. Nếu rồi: kiểm tra roleId == ADMIN
  4. Nếu không phải admin: redirect tới /auth/login?error=admin_required
  5. Nếu là admin: cho phép request tiếp tục
- **Xử lý lỗi**: Không throw exception
- **Liên kết**: SessionHelper, RoleConstant.ADMIN

### StaffAuthFilter

#### doFilter
- **Mục đích**: Kiểm tra xác thực và phân quyền staff (/staff/*)
- **Input**: ServletRequest, ServletResponse, FilterChain
- **Output**: Cho phép hoặc redirect
- **Logic xử lý**:
  1. Kiểm tra user đã đăng nhập
  2. Nếu chưa: redirect tới login
  3. Nếu rồi: kiểm tra roleId == STAFF
  4. Nếu không phải staff: redirect tới login?error=staff_required
  5. Nếu là staff: cho phép request tiếp tục
- **Xử lý lỗi**: Không throw exception
- **Liên kết**: SessionHelper, RoleConstant.STAFF

### PasswordHelper

#### hash
- **Mục đích**: Hash password bằng BCrypt
- **Input**: plain text password
- **Output**: BCrypt hash
- **Logic xử lý**:
  1. Generate salt bằng BCrypt.gensalt(12) (cost factor = 12)
  2. Hash password bằng BCrypt.hashpw(password, salt)
  3. Return hash
- **Xử lý lỗi**: Không có
- **Liên kết**: org.mindrot.jbcrypt.BCrypt

#### verify
- **Mục đích**: Xác minh plain text password với hash
- **Input**: plain text password, BCrypt hash
- **Output**: boolean
- **Logic xử lý**:
  1. Sử dụng BCrypt.checkpw(password, hash)
- **Xử lý lỗi**: Không có
- **Liên kết**: org.mindrot.jbcrypt.BCrypt

#### isTooSimilar
- **Mục đích**: Kiểm tra newPassword quá giống oldPassword không
- **Input**: oldPassword, newPassword
- **Output**: boolean (true = quá giống)
- **Logic xử lý**:
  1. Nếu null: return false
  2. Nếu giống hệt: return true
  3. Nếu giống hệt (case-insensitive): return true
  4. Tính Levenshtein distance giữa hai password (case-insensitive)
  5. Tính similarity = 1.0 - (distance / maxLen)
  6. Return similarity >= SIMILARITY_THRESHOLD (0.7)
- **Xử lý lỗi**: Không có
- **Liên kết**: levenshteinDistance()

#### levenshteinDistance
- **Mục đích**: Tính khoảng cách Levenshtein giữa 2 chuỗi
- **Input**: s1, s2
- **Output**: int (distance)
- **Logic xử lý**:
  1. Tạo DP table 2D [len1+1][len2+1]
  2. Initialize hàng đầu và cột đầu
  3. For each cell (i,j):
     - Nếu s1[i-1] == s2[j-1]: cost = 0, nếu không cost = 1
     - dp[i][j] = min(
       dp[i-1][j] + 1 (delete),
       dp[i][j-1] + 1 (insert),
       dp[i-1][j-1] + cost (replace)
     )
  4. Return dp[len1][len2]
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

### SessionHelper

#### getLoggedInAccount
- **Mục đích**: Lấy Account từ session
- **Input**: HttpServletRequest
- **Output**: Account object hoặc null
- **Logic xử lý**:
  1. Lấy session từ request (create=false)
  2. Nếu session không tồn tại: return null
  3. Nếu tồn tại: return session.getAttribute(ACCOUNT_KEY)
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

#### isLoggedIn
- **Mục đích**: Kiểm tra user đã đăng nhập hay không
- **Input**: HttpServletRequest
- **Output**: boolean
- **Logic xử lý**:
  1. Return getLoggedInAccount(request) != null
- **Xử lý lỗi**: Không có
- **Liên kết**: getLoggedInAccount()

#### setLoggedInAccount
- **Mục đích**: Lưu Account vào session
- **Input**: HttpServletRequest, Account
- **Output**: Không có
- **Logic xử lý**:
  1. Lấy session từ request (create=true nếu chưa có)
  2. Set attribute với key ACCOUNT_KEY
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

#### logout
- **Mục đích**: Đăng xuất user
- **Input**: HttpServletRequest
- **Output**: Không có
- **Logic xử lý**:
  1. Lấy session từ request (create=false)
  2. Nếu tồn tại: invalidate session
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

### OtpHelper

#### generateOtp
- **Mục đích**: Generate 6-digit OTP
- **Input**: Không có
- **Output**: String (e.g., "123456")
- **Logic xử lý**:
  1. Random 6 chữ số (100000-999999)
  2. Return dưới dạng String
- **Xử lý lỗi**: Không có
- **Liên kết**: java.security.SecureRandom

#### isExpired
- **Mục đích**: Kiểm tra OTP có hết hạn không
- **Input**: expiryTime (milliseconds)
- **Output**: boolean
- **Logic xử lý**:
  1. Return System.currentTimeMillis() > expiryTime
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

#### getExpiryTime
- **Mục đích**: Tính thời gian hết hạn cho OTP
- **Input**: Không có
- **Output**: long (milliseconds)
- **Logic xử lý**:
  1. Return System.currentTimeMillis() + OTP_EXPIRY_MILLIS (5 phút)
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

### AccountRepository

#### findByEmail
- **Mục đích**: Tìm account qua email
- **Input**: email
- **Output**: Account object hoặc null
- **Logic xử lý**:
  1. Execute query: SELECT * FROM Account WHERE email = ?
  2. MapRow: Convert ResultSet → Account object
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: queryOne(), mapRow()

#### findById
- **Mục đích**: Tìm account qua ID
- **Input**: accountId
- **Output**: Account object hoặc null
- **Logic xử lý**:
  1. Execute query: SELECT * FROM Account WHERE account_id = ?
  2. Return mapped object
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: queryOne()

#### existsByEmail
- **Mục đích**: Kiểm tra email đã tồn tại hay không
- **Input**: email
- **Output**: boolean
- **Logic xử lý**:
  1. Execute COUNT query: SELECT COUNT(*) FROM Account WHERE email = ?
  2. Return rs.getInt(1) > 0
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: Không có

#### insert
- **Mục đích**: Tạo account mới
- **Input**: Account object
- **Output**: int (accountId được auto-generated)
- **Logic xử lý**:
  1. Execute INSERT:
     ```
     INSERT INTO Account (email, password, full_name, phone, address, role_id, is_active)
     VALUES (?, ?, ?, ?, ?, ?, ?)
     ```
  2. Return generated key (accountId)
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: executeInsert()

#### updatePassword
- **Mục đích**: Cập nhật mật khẩu
- **Input**: accountId, newPasswordHash
- **Output**: int (số dòng affected)
- **Logic xử lý**:
  1. Execute UPDATE: UPDATE Account SET password = ? WHERE account_id = ?
  2. Return affected rows
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: executeUpdate()

#### update
- **Mục đích**: Cập nhật thông tin account (không password)
- **Input**: Account object
- **Output**: int (số dòng affected)
- **Logic xử lý**:
  1. Execute UPDATE full_name, phone, address WHERE account_id = ?
  2. Return affected rows
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: executeUpdate()

#### findAllByRoleId
- **Mục đích**: Lấy danh sách accounts theo role
- **Input**: roleId
- **Output**: List<Account>
- **Logic xử lý**:
  1. Execute query: SELECT * FROM Account WHERE role_id = ? ORDER BY created_at DESC
  2. Return list of mapped objects
- **Xử lý lỗi**: SQL error → RuntimeException
- **Liên kết**: queryList()

### AuthResult

#### Constructor
- **Mục đích**: Tạo object kết quả xác thực
- **Input**: success (boolean), message (String), account (Account)
- **Output**: AuthResult object
- **Logic xử lý**:
  1. Gán các thuộc tính
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

#### success (static factory)
- **Mục đích**: Factory method tạo result thành công
- **Input**: message, account
- **Output**: AuthResult(true, message, account)
- **Logic xử lý**:
  1. Return new AuthResult(true, ...)
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

#### failure (static factory)
- **Mục đích**: Factory method tạo result lỗi
- **Input**: message
- **Output**: AuthResult(false, message, null)
- **Logic xử lý**:
  1. Return new AuthResult(false, message, null)
- **Xử lý lỗi**: Không có
- **Liên kết**: Không có

## Luồng dữ liệu (Data Flow)

### Luồng 1: Đăng ký tài khoản
```
User → Register Form → AuthController.handleRegisterPost()
  → AuthService.register()
    → Validate email, password, fullName
    → Check email exists: AccountRepository.existsByEmail()
    → Normalize email (lowercase, trim)
    → Hash password: PasswordHelper.hash()
    → Sanitize inputs
    → Insert Account: AccountRepository.insert() → Database (Account table)
    → Insert Customer: CustomerRepository.insert() → Database (Customer table)
  → SessionHelper.setLoggedInAccount()
  → Redirect to home page
```

### Luồng 2: Đăng nhập
```
User → Login Form → AuthController.handleLoginPost()
  → AuthService.login(email, password)
    → Validate email format
    → Find account: AccountRepository.findByEmail()
    → Check active: account.isActive()
    → Verify password: PasswordHelper.verify()
  → SessionHelper.setLoggedInAccount()
  → AuthFilter/AdminAuthFilter/StaffAuthFilter check session
  → Redirect dựa trên role
```

### Luồng 3: Quên mật khẩu
```
User → Forgot Password Form → AuthController.handleForgotPasswordPost()
  → AuthService.sendOtp(email)
    → Generate OTP: OtpHelper.generateOtp()
    → Send email: EmailHelper.sendOtp()
    → Return OTP thạo temp account
  → Store in session (forgot_otp, forgot_email, forgot_expiry)
  → Redirect to /auth/verify-otp

User → Verify OTP Form → AuthController.handleVerifyOtpPost()
  → AuthService.verifyOtp(inputOtp, sessionOtp, expiryTime)
    → Check OTP not expired: OtpHelper.isExpired()
    → Check OTP match
  → Set session attribute: otp_verified=true
  → Redirect to /auth/reset-password

User → Reset Password Form → AuthController.handleResetPasswordPost()
  → AuthService.resetPassword(email, newPassword, confirmPassword)
    → Validate password
    → Hash password: PasswordHelper.hash()
    → Update: AccountRepository.updatePassword()
  → Clear session attributes
  → Redirect to login?reset=success
```

### Luồng 4: Google OAuth Login
```
User → Click "Login with Google" → AuthController.handleGoogleLogin()
  → Generate state UUID (CSRF protection)
  → Store state in session
  → Redirect to Google OAuth URL

User → Google → /auth/google-callback
  → AuthController.handleGoogleCallback()
    → Verify state token (CSRF check)
    → AuthService.loginWithGoogle(code)
      → Exchange code: GoogleOAuthHelper.exchangeCodeAndGetUserInfo()
      → Check account exists: AccountRepository.findByEmail()
      → If exists: check active, return account
      → If not: create new account + Customer record, return "NEW_USER"
    → SessionHelper.setLoggedInAccount()
    → If NEW_USER: redirect to /auth/complete-profile
    → Else: redirect dựa trên role
```

## Bảo mật & Phân quyền

### Bảo mật mật khẩu
- Sử dụng BCrypt với cost factor 12 (mất ~100ms để hash)
- Không lưu plain text password
- Kiểm tra password mới không quá giống mật khẩu cũ (Levenshtein distance >= 70%)

### Session Security
- Regenerate session ID sau login (tránh session fixation)
- Lưu Account object trong session, không lưu password
- Invalidate session khi logout
- Session timeout được cấu hình trong web.xml

### CSRF Protection
- State token trong Google OAuth
- HttpOnly, Secure cookies (được cấu hình container)

### Xác thực & Phân quyền
- AuthFilter: yêu cầu login cho /customer/*, /booking/*, /payment/*
- AdminAuthFilter: yêu cầu login + role=ADMIN cho /admin/*
- StaffAuthFilter: yêu cầu login + role=STAFF cho /staff/*
- RoleConstant: CUSTOMER=3, STAFF=2, ADMIN=1

### OTP Security
- 6-digit random OTP
- Hết hạn trong 5 phút
- Gửi qua email (không lưu trong database, chỉ session)
- One-time use (xóa session sau reset password)

### Input Validation
- Email format validation
- Password strength (6+ chars, alphanumeric)
- SQL injection prevention: dùng PreparedStatement
- XSS prevention: sanitize inputs, HTML escape outputs

### Email Security
- EmailHelper gửi OTP qua email (implementation riêng)
- Không log password hoặc OTP

### Google OAuth
- Verify authorization code từ Google
- HTTPS (required by Google)
- Client ID/Secret stored in config (không hardcode)
- State token (CSRF protection)

## Các Role và Quyền

- **CUSTOMER (roleId=3)**:
  - Đăng nhập/đăng ký
  - Truy cập /customer/*
  - Booking, payment, feedback, service requests

- **STAFF (roleId=2)**:
  - Đăng nhập /staff/login
  - Truy cập /staff/*
  - Quản lý phòng, check-in/out, service requests

- **ADMIN (roleId=1)**:
  - Đăng nhập /auth/login
  - Truy cập /admin/*
  - Quản lý customers, staff, vouchers, reports

## Các Error Messages

- "Invalid email format"
- "Mật khẩu phải có ít nhất 6 ký tự"
- "Mật khẩu không khớp"
- "Email đã tồn tại"
- "Tài khoản không hoạt động"
- "Email hoặc mật khẩu không đúng"
- "Mật khẩu hiện tại không đúng"
- "Mật khẩu mới phải khác biệt đáng kể so với mật khẩu cũ"
- "Mã OTP không hợp lệ hoặc đã hết hạn"
- "Tài khoản này không có quyền truy cập cổng nhân viên"
- "Tài khoản này không có quyền admin"

## Công nghệ & Thư viện

- **BCrypt**: Password hashing (org.mindrot.jbcrypt)
- **Jakarta Servlet**: HTTP request/response handling
- **SecureRandom**: OTP generation
- **Google OAuth 2.0**: Third-party authentication
- **Email**: OTP delivery (implementation riêng)

## Constants & Configuration

- **RoleConstant.ADMIN**: 1
- **RoleConstant.STAFF**: 2
- **RoleConstant.CUSTOMER**: 3
- **PasswordHelper.COST_FACTOR**: 12 (BCrypt)
- **PasswordHelper.SIMILARITY_THRESHOLD**: 0.7 (70%)
- **OtpHelper.OTP_EXPIRY_MILLIS**: 300000 (5 phút)
- **SessionHelper.ACCOUNT_KEY**: "loggedInAccount"
- **SessionHelper.CUSTOMER_KEY**: "loggedInCustomer"

## Các Câu Hỏi Chưa Giải Quyết

1. Email helper implementation chi tiết (SMTP configuration)?
2. Google OAuth client credentials được lưu ở đâu?
3. Account password column có unique constraint không?
4. Session timeout configuration?
5. Rate limiting cho login/OTP attempts?
6. Password history (prevent reusing old passwords)?
7. Account lockout sau N failed attempts?
8. Two-factor authentication ngoài email OTP?
9. Admin có thể reset password user không?
10. Password expiration policy?
