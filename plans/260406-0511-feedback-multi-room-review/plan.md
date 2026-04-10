# Plan: Kiểm tra chức năng Feedback với Đơn phòng và Đa phòng

## Vấn đề đã xác định

### 1. Feedback Entity thiếu Room Reference

**Feedback.java**:
```java
private int bookingId;
private int rating;
private String comment;
```

**Thiếu**: `roomId` - không biết feedback thuộc phòng nào trong multi-room booking.

### 2. hasFeedback() kiểm tra theo Booking

**FeedbackService.java:hasFeedback()**:
```java
public boolean hasFeedback(int bookingId) {
    return feedbackRepository.existsByBookingId(bookingId);
}
```

**Vấn đề**: Với multi-room:
- Nếu booking có 3 phòng, feedback đầu tiên sẽ khóa không cho feedback các phòng còn lại
- Customer không thể feedback riêng cho từng phòng

### 3. Frontend không hiển thị Room info

**booking-detail.jsp** hiển thị feedback nhưng không chỉ rõ phòng nào.

---

## Analysis

### Single-room Booking
- 1 booking = 1 phòng
- Feedback theo bookingId là OK
- Feedback hiển thị đúng phòng

### Multi-room Booking
- 1 booking = nhiều phòng (BookingRoom)
- Feedback chỉ có bookingId, không có roomId
- Customer không thể feedback riêng cho từng phòng
- Staff không biết feedback đó thuộc phòng nào

---

## Questions cần verify

1. **Thiết kế có cố ý không?** - Feedback đánh giá tổng thể booking, không phải từng phòng?
2. **Multi-room feedback có được phép không?** - Có nên tạo nhiều feedback (1 cho mỗi phòng)?
3. **Hoặc chỉ 1 feedback cho booking?** - Dù là 1 hay nhiều phòng?

---

## Files liên quan

### Backend
- `Feedback.java` - entity thiếu roomId
- `FeedbackRepository.java` - findByBookingId, existsByBookingId
- `FeedbackService.java` - hasFeedback, submitFeedback

### Frontend
- `customer/booking-detail.jsp` - form feedback, hiển thị feedback
- `admin/feedback/list.jsp` - admin xem feedback

### Database
- `Feedback` table - không có room_id column
