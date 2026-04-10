# He thong Danh gia (Feedback System)

## Tong quan nghiep vu

Tinh nang nay cho phep khach hang danh gia phong va dich vu khach san sau khi checkout:
- Danh gia theo diem (1-5 sao)
- Them binh luan chi tiet
- Admin co the an danh gia hoac hien thi cong khai
- Admin phan hoi danh gia cua khach hang
- Chinh sua va xoa danh gia cua chinh minh (customer)
- Xem danh gia cua booking
- Xem lich su danh gia (admin)

## Kien truc & Code Flow

### Customer Feedback Flow
```
Customer (JSP)
    |
    v
FeedbackController (customer/) - KHONG DUOC DEFINED
    |
    v
FeedbackService
    |
    +-> submitFeedback: Gui danh gia moi
    +-> getBookingFeedback: Lay danh gia cua booking
    +-> hasFeedback: Kiem tra da danh gia chua
    +-> updateFeedback: Chinh sua danh gia
    +-> deleteFeedback: Xoa danh gia
    |
    v
FeedbackRepository
    |
    v
Database (feedback table)
```

### Admin Feedback Flow
```
Admin (JSP)
    |
    v
AdminFeedbackController (/admin/feedback/*)
    |
    +-> handleList: Hien thi danh sach danh gia
    +-> handleToggleVisibility: An/hien thi danh gia
    +-> handleReply: Them/chinh sua phan hoi
    |
    v
AdminFeedbackService
    |
    +-> getAllFeedback: Lay tat ca danh gia voi chi tiet
    +-> getVisibleFeedback: Lay danh gia dang hien thi
    +-> toggleVisibility: Chuyen trang thai hien/an
    +-> replyToFeedback: Them phan hoi tu admin
    |
    v
FeedbackRepository
    |
    v
Database (feedback table)
```

## Chi tiet tung ham

### Feedback Entity

#### Fields
- feedbackId (int): ID danh gia
- bookingId (int): ID dat phong lien quan
- rating (int): Diem danh gia (1-5)
- comment (String): Binh luan chi tiet (max 1000 ky tu)
- createdAt (LocalDateTime): Thoi gian tao danh gia
- isHidden (boolean): True = danh gia duoc an, false = hien thi cong khai
- adminReply (String): Phan hoi tu admin
- booking (Booking - transient): Du lieu booking hien thi

### FeedbackService

#### submitFeedback(int customerId, Feedback feedback)
- Muc dich: Khach hang gui danh gia moi cho booking
- Input: customerId, Feedback object (chua bookingId, rating, comment)
- Output: ServiceResult object (success/failure message)
- Logic xu ly:
  1. Lay Booking theo feedback.bookingId
  2. Kiem tra booking ton tai va soan chinh cua customer nay
  3. Kiem tra trang thai booking: phai CHECKED_OUT hoac CONFIRMED
     (Chi duoc danh gia sau khi checkout hoac co the danh gia khi confirmed)
  4. Kiem tra xem khach hang da danh gia booking nay chua
     (Chi duoc 1 danh gia cho moi booking)
  5. Kiem tra rating: phai trong khoang 1-5
  6. Sanitize comment (loai bo HTML tags, script, v.v.)
  7. Neu comment > 1000 ky tu thi cat lai
  8. Set comment da sanitize vao feedback
  9. Insert Feedback vao DB
  10. Tra ve ServiceResult.success("Cam on ban da danh gia!")
- Xu ly loi:
  - Booking khong ton tai hoac khong phai cua customer -> "Khong tim thay dat phong"
  - Booking chua completed -> "Chi co the danh gia sau khi hoan thanh dat phong"
  - Da danh gia -> "Ban da danh gia dat phong nay roi"
  - Rating khong hop le -> "Danh gia phai tu 1 den 5 sao"
  - Insert that bai -> "Khong the gui danh gia"
- Lien ket: BookingRepository, FeedbackRepository, ValidationHelper.sanitize()

#### getBookingFeedback(int bookingId)
- Muc dich: Lay danh gia cua booking
- Input: bookingId
- Output: Feedback object hoac null
- Lien ket: FeedbackRepository.findByBookingId()

#### hasFeedback(int bookingId)
- Muc dich: Kiem tra xem booking da co danh gia chua
- Input: bookingId
- Output: boolean
- Lien ket: FeedbackRepository.existsByBookingId()

#### updateFeedback(int feedbackId, int customerId, Feedback newFeedback)
- Muc dich: Khach hang chinh sua danh gia cua chinh minh
- Input: feedbackId, customerId, newFeedback object (rating, comment)
- Output: ServiceResult object
- Logic xu ly:
  1. Lay Feedback cu theo feedbackId
  2. Kiem tra Feedback ton tai
  3. Lay Booking cua feedback
  4. Kiem tra booking soan chinh cua customer nay
  5. Kiem tra rating hop le (1-5)
  6. Sanitize va cat comment neu can
  7. Update rating va comment cua Feedback cu
  8. Luu vao DB
  9. Tra ve ServiceResult.success()
- Xu ly loi: Tuong tu submitFeedback
- Lien ket: FeedbackRepository, BookingRepository

#### deleteFeedback(int feedbackId, int customerId)
- Muc dich: Khach hang xoa danh gia cua chinh minh
- Input: feedbackId, customerId
- Output: ServiceResult object
- Logic xu ly:
  1. Lay Feedback theo feedbackId
  2. Kiem tra Feedback ton tai
  3. Lay Booking
  4. Kiem tra booking soan chinh cua customer nay
  5. Xoa Feedback khoi DB
  6. Tra ve ServiceResult.success("Danh gia da duoc xoa thanh cong")
- Xu ly loi:
  - Feedback khong ton tai -> "Khong tim thay danh gia"
  - Booking khong soan chinh -> "Ban khong co quyen xoa danh gia nay"
  - Delete that bai -> "Khong the xoa danh gia"
- Lien ket: FeedbackRepository, BookingRepository

### AdminFeedbackService

#### getAllFeedback()
- Muc dich: Admin xem danh sach tat ca danh gia (ke ca danh gia da an)
- Output: List<Feedback> voi booking details
- Logic xu ly: Goi FeedbackRepository.findAllWithDetails() de lay danh gia va chi tiet booking
- Lien ket: FeedbackRepository.findAllWithDetails()

#### getVisibleFeedback(int limit)
- Muc dich: Lay danh gia dang hien thi (khong an) voi limit
- Input: limit (so luong danh gia)
- Output: List<Feedback>
- Logic xu ly: Goi FeedbackRepository.findVisibleWithDetails(limit)
- Lien ket: FeedbackRepository.findVisibleWithDetails()

#### toggleVisibility(int feedbackId)
- Muc dich: Admin an/hien thi danh gia cong khai
- Input: feedbackId
- Output: boolean - true neu cap nhat thanh cong
- Logic xu ly:
  1. Lay Feedback theo feedbackId
  2. Kiem tra ton tai
  3. Lay trang thai hien tai cua isHidden
  4. Cap nhat isHidden = !isHidden (dao nguoc)
  5. Luu vao DB
  6. Tra ve ket qua update
- Lien ket: FeedbackRepository.updateIsHidden()

#### replyToFeedback(int feedbackId, int adminId, String reply)
- Muc dich: Admin phan hoi danh gia cua khach hang
- Input: feedbackId, adminId (admin thuc hien hanh dong), reply (noi dung phan hoi)
- Output: boolean - true neu upsert thanh cong
- Logic xu ly:
  1. Them hoac cap nhat phan hoi (upsert)
  2. Luu adminId va reply vao feedback
  3. Luu vao DB
- Lien ket: FeedbackRepository.upsertReply()

### AdminFeedbackController

#### doGet (path=/admin/feedback)
- Muc dich: Admin xem danh sach danh gia
- Output: Forward den /WEB-INF/views/admin/feedback/list.jsp
- Logic xu ly:
  1. Goi AdminFeedbackService.getAllFeedback()
  2. Kiem tra success parameter:
     - "toggled" -> hien thi "Cap nhat trang thai hien thi thanh cong!"
     - "replied" -> hien thi "Phan hoi da duoc gui!"
  3. Set attributes:
     - feedbackList: danh sach danh gia
     - success: thong bao
     - activePage: "feedback"
     - pageTitle: "Quan ly phan hoi"
  4. Forward den list.jsp
- Lien ket: AdminFeedbackService.getAllFeedback()

#### doPost (path=/admin/feedback/toggle-visibility)
- Muc dich: Admin an/hien thi danh gia
- Input: id (feedbackId)
- Output: Redirect ve /admin/feedback?success=toggled
- Logic xu ly:
  1. Parse feedback ID
  2. Goi AdminFeedbackService.toggleVisibility(id)
  3. Redirect ve trang danh sach voi success message
- Lien ket: AdminFeedbackService.toggleVisibility()

#### doPost (path=/admin/feedback/reply)
- Muc dich: Admin gui phan hoi cho danh gia
- Input: id (feedbackId), reply (noi dung phan hoi)
- Output: Redirect ve /admin/feedback?success=replied
- Logic xu ly:
  1. Parse feedbackId va reply text
  2. Lay admin ID tu session (account da dang nhap)
  3. Goi AdminFeedbackService.replyToFeedback()
  4. Redirect ve trang danh sach voi success message
- Lien ket: AdminFeedbackService.replyToFeedback(), SessionHelper.getLoggedInAccount()

## Luong du lieu (Data Flow)

### Customer Submit Feedback Flow
```
1. Customer xem booking details sau checkout
   - Hien thi form danh gia voi rating va comment

2. POST /feedback/submit
   - FeedbackService.submitFeedback(customerId, feedback)
   - Validate rating (1-5), booking status, duplicate check
   - Sanitize comment (max 1000 characters)
   - Insert Feedback record
   - Return success message

3. Update page hien thi "Danh gia da duoc luu"
   - Danh gia xuat hien trong danh sach feedback cong khai
```

### Admin View & Manage Feedback
```
1. GET /admin/feedback
   - AdminFeedbackService.getAllFeedback()
   - Hien thi danh sach tat ca danh gia
   - Moi danh gia co thong tin:
     - Customer name (tu booking)
     - Room info (tu booking)
     - Rating (1-5 stars)
     - Comment
     - Created date
     - isHidden status
     - Admin reply (neu co)

2. POST /admin/feedback/toggle-visibility?id=X
   - Cap nhat isHidden = !isHidden
   - Danh gia bao gom/khai thao khoi danh sach cong khai

3. POST /admin/feedback/reply?id=X&reply=...
   - Them admin phan hoi
   - Cap nhat adminReply field
   - Danh gia co the hien thi phan hoi trong view cong khai
```

### Feedback Display in Frontend
```
1. Homepage / Testimonials page
   - Hien thi danh gia visible (isHidden = false)
   - Order by createdAt DESC
   - Limit 5-10 danh gia gan day
   - Hien thi:
     * Customer name
     * Rating (stars)
     * Comment
     * Admin reply (neu co)
     * Date

2. Booking details page
   - Hien thi danh gia cua booking nay (neu customer la owner)
   - Cho phep customer chinh sua / xoa danh gia cua chinh minh
```

## Bao mat & Phan quyen

### Authentication & Authorization
- Customer chi co the danh gia booking cua chinh minh (kiem tra customer ID trong Booking)
- Customer chi co the chinh sua / xoa danh gia cua chinh minh (kiem tra feedbackId va bookingId)
- Chi customer co the GUI danh gia, khong phai staff hay anonymous

### Input Validation & Sanitization
- Rating phai trong khoang 1-5 (validate on both client va server)
- Comment phai <= 1000 ky tu
- Comment phai duoc sanitize de loai bo XSS attack:
  - Loai bo HTML tags (<script>, <img onerror>, etc.)
  - Loai bo SQL injection attempts (thong qua prepared statements)

### Business Rules
- Chi co the danh gia neu booking da CHECKED_OUT hoac CONFIRMED
- Moi booking chi duoc 1 danh gia (prevent duplicate ratings)
- Danh gia khong the bi delete sau khi admin da phan hoi (optional business rule)

### Admin-Only Operations
- An/hien thi danh gia cong khai (toggleVisibility)
- Phan hoi danh gia (reply)
- Xem toan bo danh gia (bao gom da an)

## Hang so & Quy tac (Constants & Rules)

### Rating Scale
- 1 sao: Rat that vong
- 2 sao: Khong tot
- 3 sao: Binh thuong
- 4 sao: Tot
- 5 sao: Rat tot

### Comment Length
- Min: 0 (co the chi danh gia diem ma khong co binh luan)
- Max: 1000 ky tu (tu dong cat neu qua)

### Booking Status cho Feedback
- Cho phep danh gia: CHECKED_OUT, CONFIRMED
- Cam danh gia: PENDING, CANCELLED

### Visibility Status
- isHidden = true: Danh gia bi an, khong hien thi ngoai view admin
- isHidden = false: Danh gia hien thi cong khai (homepage, testimonials, etc.)

## Phuong phap Query & Performance

### Queries su dung
- findByBookingId(bookingId): Tim danh gia theo booking
- existsByBookingId(bookingId): Kiem tra danh gia ton tai (efficient COUNT query)
- findAllWithDetails(): Lay tat ca danh gia + chi tiet booking (JOIN query)
- findVisibleWithDetails(limit): Lay danh gia hien thi + chi tiet
- findById(feedbackId): Tim danh gia theo ID
- updateIsHidden(feedbackId, isHidden): Cap nhat visibility
- upsertReply(feedbackId, adminId, reply): Them/cap nhat phan hoi

### Performance Optimization
- Su dung prepared statements de tranh SQL injection
- Index on bookingId va isHidden fields
- Cache danh sach visible feedback (homepage)
- Pagination cho danh sach admin (limit 20-50 feedback/page)

## Next Steps & Dependencies

- Implement feedback rating aggregation (average stars, count by rating)
- Add search / filter feedback by customer, date range, rating
- Implement feedback moderation workflow (pending -> approved -> published)
- Add email notification khi admin phan hoi
- Integrate with homepage / testimonials widget
- Add feedback analytics dashboard
