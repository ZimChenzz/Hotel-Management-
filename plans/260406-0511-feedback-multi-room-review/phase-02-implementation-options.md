# Phase 2: Implementation Options

## Option A: Giữ nguyên Per-Booking Feedback (Current)

**Nếu business requirement là feedback tổng thể cho booking:**

### Ưu điểm
- Không cần thay đổi database schema
- Đơn giản, không có breaking change

### Nhược điểm
- Multi-room: không feedback riêng cho từng phòng

### Changes cần thiết
1. Frontend: Hiển thị rõ "Feedback cho đặt phòng #ID" thay vì "Feedback cho phòng X"
2. Admin: Filter/display theo bookingId

---

## Option B: Hỗ trợ Per-Room Feedback

**Nếu business requirement là feedback riêng cho từng phòng:**

### Database Changes
```sql
ALTER TABLE Feedback ADD COLUMN room_id INT NULL;
```

### Entity Changes
```java
public class Feedback {
    private int bookingId;
    private Integer roomId;  // nullable - null = booking-level feedback
    ...
}
```

### Repository Changes
```java
public boolean existsByBookingIdAndRoomId(int bookingId, Integer roomId);
public Feedback findByBookingIdAndRoomId(int bookingId, Integer roomId);
```

### Service Changes
```java
public boolean hasFeedback(int bookingId, Integer roomId) {
    return roomId == null
        ? feedbackRepository.existsByBookingId(bookingId)
        : feedbackRepository.existsByBookingIdAndRoomId(bookingId, roomId);
}
```

### Frontend Changes
- booking-detail.jsp: Thêm dropdown chọn phòng cho multi-room
- Hiển thị feedback kèm room number

---

## Recommendation

**Chọn Option A** nếu:
- Feedback là đánh giá tổng thể trải nghiệm
- Không cần distinguish per-room

**Chọn Option B** nếu:
- Mỗi phòng có trải nghiệm khác nhau (VD: phòng số 1 view đẹp, phòng số 2 ồn)
- Staff cần biết feedback để cải thiện từng phòng cụ thể

---

## Success Criteria

1. Xác định rõ business requirement
2. Nếu Option A: verify không có bug với multi-room
3. Nếu Option B: implement đầy đủ với roomId
