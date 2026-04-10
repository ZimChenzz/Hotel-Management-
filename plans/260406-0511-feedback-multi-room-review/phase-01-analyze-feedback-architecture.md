# Phase 1: Phân tích Feedback Architecture

## Current Design

### Feedback flow hiện tại
```
Customer -> booking-detail.jsp -> POST /customer/feedback
    -> FeedbackService.submitFeedback()
        -> Booking must be CHECKED_IN
        -> FeedbackRepository.existsByBookingId(bookingId) -> blocks if exists
        -> Insert Feedback(bookingId, rating, comment)
```

### Single-room (hoạt động đúng)
- Booking có 1 phòng
- 1 feedback duy nhất cho booking đó
- isBlocked check hoạt động đúng

### Multi-room (vấn đề tiềm ẩn)
- Booking có nhiều phòng (VD: 3 phòng)
- Customer checkout tất cả phòng -> booking CHECKED_OUT
- Customer muốn feedback cho từng phòng
- Feedback đầu tiên sẽ blocked các feedback còn lại

---

## Key Questions

### Q1: Feedback nên là per-booking hay per-room?

**Option A: Per-booking** (thiết kế hiện tại)
- 1 booking = 1 feedback (rating tổng hợp)
- Phù hợp nếu feedback đánh giá trải nghiệm tổng thể

**Option B: Per-room** (cần thay đổi)
- 1 booking có thể có nhiều feedback (1 cho mỗi phòng)
- Phù hợp nếu mỗi phòng có trải nghiệm khác nhau

### Q2: Staff có cần biết feedback thuộc phòng nào?

Nếu Option B: Staff cần biết feedback để cải thiện từng phòng

---

## Verification Checklist

- [ ] Xác định business requirement: feedback per-booking hay per-room?
- [ ] Kiểm tra database schema: Feedback table có room_id column không?
- [ ] Test thực tế: tạo multi-room booking -> checkout -> feedback
- [ ] Kiểm tra frontend: có hiển thị đúng phòng trong feedback list không?

---

## Related Code to Verify

### CustomerController.handleFeedbackPost()
```
- bookingId được truyền vào
- booking.getStatus() phải là CHECKED_IN hoặc CHECKED_OUT
- hasFeedback() check
```

### booking-detail.jsp
```
- Form feedback gửi bookingId nào?
- Hiển thị feedback của phòng nào?
```
