# Lich trinh Dat phong (Booking Scheduler)

## Tong quan nghiep vu

Tính năng lịch trình đặt phòng (Booking Scheduler) là một hệ thống tự động chạy nền để xử lý các đặt phòng quá hạn. Cụ thể, hệ thống tự động hủy các đơn đặt phòng loại "Standard" (không yêu cầu tiền đặt cọc) nếu khách không check-in đúng giờ (6 giờ sau thời gian expected check-in mà vẫn chưa có xác nhận từ nhân viên).

Đây là một quy trình quan trọng để:
1. Giải phóng phòng bị "block" do khách không đến check-in đúng giờ
2. Tối ưu hóa tỷ lệ lấp đầu phòng (room occupancy)
3. Giảm thiểu mất mát doanh thu do phòng bị lock không có người ở
4. Loại bỏ các đơn đặt không thực tế (ghost bookings)

## Kien truc & Code Flow

```
Web Application Start
    |
    v
AppContextListener (ServletContextListener)
    |
    ├-> Initialize BookingScheduler
    |
    ├-> Create ScheduledExecutorService (background thread)
    |
    └-> Every 1 minute:
        ├-> BookingRepository.cancelOverdueBookings()
        |   (SQL UPDATE: set status=CANCELLED where overdue)
        |
        └-> Log số booking đã cancel

    [ALTERNATE APPROACH - Not used in current codebase but available]
    BookingSchedulerService
    |
    ├-> start() - manually start scheduler
    |
    ├-> cancelOverdueStandardBookings() - periodic check
    |   (Find PENDING Standard bookings > 6 hours past check-in)
    |
    ├-> checkAndCancelIfOverdue() - lazy check on detail view
    |   (Safety net khi fetch booking details)
    |
    └-> stop() - graceful shutdown
```

### Hai component chính:
1. **BookingScheduler** (WebListener) - Tự động run khi app start, check every 1 minute
2. **BookingSchedulerService** - Manual service class, cung cấp thêm tính năng lazy check

## Chi tiet tung ham

### BookingScheduler (ServletContextListener - WebListener)

#### contextInitialized(ServletContextEvent sce)
- **Muc dich**: Khởi tạo background scheduler khi web application start
- **Input**: ServletContextEvent sce (chứa application context)
- **Output**: Không có (side effect: start background thread)
- **Logic xu ly**:
  1. Tạo BookingRepository instance mới
  2. Tạo ScheduledExecutorService với single daemon thread:
     - Thread name: "booking-auto-cancel"
     - setDaemon(true) -> thread tự tắt khi app shutdown
  3. Schedule task với fixed rate:
     - Task: gọi bookingRepository.cancelOverdueBookings()
     - Initial delay: 1 phút
     - Fixed rate: 1 phút (chạy lại cứ 1 phút)
     - TimeUnit: MINUTES
  4. Inside task:
     - Try-catch block bắt Exception
     - Gọi cancelOverdueBookings() -> return số booking hủy
     - Nếu cancelled > 0 -> print log: "[BookingScheduler] Auto-cancelled X overdue booking(s)"
     - Nếu exception -> print error: "[BookingScheduler] Error: [message]"
  5. Print startup log: "[BookingScheduler] Started - checking overdue bookings every 1 minute"
- **Xu ly loi**: Try-catch bắt tất cả Exception, print error log
- **Lien ket**: BookingRepository.cancelOverdueBookings()

#### contextDestroyed(ServletContextEvent sce)
- **Muc dich**: Graceful shutdown của scheduler khi app stop
- **Input**: ServletContextEvent sce
- **Output**: Không có (side effect: stop background thread)
- **Logic xu ly**:
  1. Kiểm tra scheduler != null
  2. Gọi scheduler.shutdownNow() -> dừng ngay
     - Hủy tất cả pending tasks
     - Interrupt current task nếu đang chạy
  3. Print log: "[BookingScheduler] Stopped"
- **Xu ly loi**: Không có (chỉ check null)
- **Lien ket**: Không

### BookingSchedulerService (Manual service)

#### start()
- **Muc dich**: Khởi động scheduler service (manual, thay thế cho WebListener nếu cần)
- **Input**: Không có
- **Output**: Không có
- **Logic xu ly**:
  1. Tạo ScheduledExecutorService với single daemon thread:
     - Thread name: "BookingAutoCancel"
     - setDaemon(true)
  2. Schedule task:
     - Task: gọi this.cancelOverdueStandardBookings()
     - Initial delay: 1 phút
     - Fixed rate: CHECK_INTERVAL_MINUTES (5 phút, constant = 5)
     - TimeUnit: MINUTES
  3. Log: LOGGER.info("BookingSchedulerService started")
- **Xu ly loi**: Không có
- **Lien ket**: cancelOverdueStandardBookings()

#### stop()
- **Muc dich**: Graceful shutdown của scheduler
- **Input**: Không có
- **Output**: Không có
- **Logic xu ly**:
  1. Kiểm tra scheduler != null && !scheduler.isShutdown()
  2. Gọi scheduler.shutdown() -> graceful shutdown (submit tasks sẽ finish)
  3. Đợi max 5 giây cho pending tasks hoàn thành:
     - scheduler.awaitTermination(5, TimeUnit.SECONDS)
  4. Nếu timeout -> gọi scheduler.shutdownNow() (force terminate)
  5. Nếu bị interrupt -> restore interrupt status, shutdown ngay
  6. Log: LOGGER.info("BookingSchedulerService stopped")
- **Xu ly loi**: Try-catch bắt InterruptedException -> restore interrupt, shutdown
- **Lien ket**: Không

#### cancelOverdueStandardBookings()
- **Muc dich**: Tìm và hủy tất cả đơn đặt phòng loại Standard quá hạn
- **Input**: Không có
- **Output**: Không có (side effect: update DB)
- **Logic xu ly**:
  1. Try-catch block:
     a. Gọi bookingRepository.findPendingStandardBookingsToCancel()
        - Return List<Booking> chứa những booking:
          - status = PENDING
          - room type = Standard (deposit_percent = 0)
          - check_in_expected < GETDATE() - 6 hours
          - check_in_actual = null (chưa confirm check-in)
     b. Iterate qua từng booking:
        - Gọi bookingRepository.updateStatus(booking.getBookingId(), BookingStatus.CANCELLED)
        - Log: "Auto-cancelled overdue Standard booking #{id}"
     c. Nếu có bookings hủy (size > 0):
        - Log: "Auto-cancelled X overdue Standard booking(s)"
  2. Exception handling:
     - Catch Exception -> log: LOGGER.log(Level.SEVERE, "Error in auto-cancel scheduler", e)
- **Xu ly loi**: Try-catch bắt Exception, log error
- **Lien ket**: BookingRepository.findPendingStandardBookingsToCancel(), updateStatus()

#### checkAndCancelIfOverdue(Booking booking)
- **Muc dich**: Lazy check - verify single booking có nên cancel không (safety net khi fetch details)
- **Input**: Booking object
- **Output**: boolean - true nếu booking vừa được cancel, false ngược lại
- **Logic xu ly**:
  1. Nếu booking == null -> return false
  2. Try-catch block:
     a. Kiểm tra 3 điều kiện:
        - booking.getStatus() == BookingStatus.PENDING
        - booking.getCheckInActual() == null (chưa check-in)
        - bookingRepository.isOverdueStandardBooking(booking.getBookingId()) == true
     b. Nếu tất cả 3 điều kiện đúng:
        - Gọi bookingRepository.updateStatus(booking.getBookingId(), BookingStatus.CANCELLED)
        - Set booking.setStatus(BookingStatus.CANCELLED) (update object in memory)
        - Log: "Lazy auto-cancelled overdue Standard booking #{id}"
        - Return true
     c. Ngược lại: return false
  3. Exception handling:
     - Catch Exception -> log Level.WARNING: "Error in lazy auto-cancel check"
     - Return false
- **Xu ly loi**: Try-catch bắt Exception, log warning
- **Lien ket**: BookingRepository.updateStatus(), isOverdueStandardBooking()

### BookingRepository Methods (Data Access)

#### cancelOverdueBookings()
- **Muc dich**: SQL batch update - hủy tất cả booking quá hạn (Pending/Confirmed)
- **Input**: Không có
- **Output**: int - số booking bị cancel
- **SQL Logic**:
  ```sql
  UPDATE Booking
  SET status = 'CANCELLED'
  WHERE (status = 'PENDING' OR status = 'CONFIRMED')
    AND check_in_expected < GETDATE()
    AND check_in_actual IS NULL
  ```
- **Ghi chú**: Cách này update tất cả loại phòng (Standard, Suite, etc.)

#### findPendingStandardBookingsToCancel()
- **Muc dich**: Tìm những booking Standard đang pending và quá 6 giờ check-in
- **Input**: Không có
- **Output**: List<Booking>
- **SQL Logic**:
  ```sql
  SELECT b.*, r.*, rt.*
  FROM Booking b
  JOIN Room r ON b.room_id = r.room_id
  JOIN RoomType rt ON r.type_id = rt.type_id
  WHERE b.status = 'PENDING'
    AND rt.deposit_percent = 0  -- Standard room (no deposit)
    AND b.check_in_expected < DATEADD(hour, -6, GETDATE())
    AND b.check_in_actual IS NULL
  ORDER BY b.booking_id
  ```
- **Ghi chú**: Chỉ filter Standard rooms (deposit_percent = 0)

#### updateStatus(int bookingId, String status)
- **Muc dich**: Update status của booking
- **Input**: bookingId, status (ví dụ: "CANCELLED")
- **Output**: int - số rows affected
- **SQL**: `UPDATE Booking SET status = ? WHERE booking_id = ?`

#### isOverdueStandardBooking(int bookingId)
- **Muc dich**: Check xem booking có phải Standard quá hạn không
- **Input**: bookingId
- **Output**: boolean
- **SQL**:
  ```sql
  SELECT COUNT(*)
  FROM Booking b
  JOIN Room r ON b.room_id = r.room_id
  JOIN RoomType rt ON r.type_id = rt.type_id
  WHERE b.booking_id = ?
    AND rt.deposit_percent = 0
    AND b.check_in_expected < DATEADD(hour, -6, GETDATE())
    AND b.check_in_actual IS NULL
  ```

## Luong du lieu (Data Flow)

### Startup Process:
```
1. Web application start (Tomcat, etc.)
2. AppContextListener.contextInitialized() được call
3. Create BookingRepository instance
4. Create ScheduledExecutorService với 1 daemon thread
5. Schedule task: every 1 minute
   - bookingRepository.cancelOverdueBookings()
   - UPDATE Booking SET status='CANCELLED' WHERE overdue
   - Log: "[BookingScheduler] Auto-cancelled X booking(s)"
6. Print: "[BookingScheduler] Started - checking every 1 minute"
7. App fully started
```

### Auto-Cancel Periodic Check (Every 1 minute):
```
1. Scheduler thread wake up
2. Execute task:
   try {
     int cancelled = bookingRepository.cancelOverdueBookings();
     if (cancelled > 0)
       log "Auto-cancelled X booking(s)"
   } catch (Exception e) {
     log error
   }
3. Sleep lại 1 phút
4. Repeat
```

### Lazy Check (On demand - when viewing booking details):
```
1. Admin/Staff view booking details page
2. Controller fetch booking dari DB
3. Controller gọi bookingSchedulerService.checkAndCancelIfOverdue(booking)
4. Service check:
   - status = PENDING?
   - checkInActual = null?
   - isOverdueStandardBooking?
5. Nếu all 3 true:
   - Update DB: status = CANCELLED
   - Return true
   - Log: "Lazy auto-cancelled booking #123"
6. Page display updated status (CANCELLED)
7. User thấy booking đã hủy tự động
```

### Shutdown Process:
```
1. App shutdown request (Ctrl+C, deploy new version, etc.)
2. AppContextListener.contextDestroyed() được call
3. scheduler.shutdownNow()
   - Hủy pending tasks
   - Interrupt current task
4. Log: "[BookingScheduler] Stopped"
5. App fully stopped
```

## Business Rules & Logic

### Booking được auto-cancel khi:
1. Status = PENDING hoặc CONFIRMED
2. Check-in expected time < GETDATE() - 6 hours (quá 6 giờ so với expected check-in)
3. Check-in actual = null (nhân viên chưa xác nhận check-in thực tế)
4. (Optional) Room type = Standard (deposit_percent = 0)

### Booking KHÔNG được auto-cancel nếu:
1. Status = CONFIRMED + đã payment xong (có tiền đặt cọc)
2. Status = CHECKED_IN (khách đã check-in)
3. Status = COMPLETED (đặt phòng đã kết thúc)
4. Status = CANCELLED (đã hủy rồi)
5. check_in_actual != null (nhân viên đã xác nhận check-in)

### Tại sao 6 giờ?
- Nếu khách có booking check-in lúc 14:00 nhưng không đến
- Sau 6 giờ (20:00 tối hôm đó), hệ thống tự động hủy
- Giả định: nếu quá 6 giờ mà khách chưa đến, khách có thể không đến
- Thời gian này có thể cấu hình (hiện là hardcode trong code)

## Bao mat & Phan quyen

- Scheduler chạy tự động, không cần user authentication
- Chỉ auto-cancel booking quá hạn (objective criteria: time-based)
- Không có manual override (admin không thể disable auto-cancel)
- Không có audit log chi tiết (không track ai hủy)
- Có thể thêm: admin notification khi booking bị cancel
- SQL queries sử dụng PreparedStatement (tránh SQL injection)

## Performance & Optimization

- **Frequency**: Kiểm tra every 1 phút (có thể tăng/giảm tùy cơ sở dữ liệu load)
- **Scale**: Để handle lớn, có thể:
  - Tăng interval check (2, 5, 10 phút)
  - Implement pagination (cancel 100 bookings một lần, không tất cả)
  - Add index trên: status, check_in_expected, check_in_actual
- **Current approach**: Simple single UPDATE query (efficient)

## Lien ket doi tuong

- BookingScheduler: start/stop bởi AppContextListener
- BookingSchedulerService: alternative service (optional)
- BookingRepository: execute SQL cancel & queries
- Booking entity: contains status, check_in_expected, check_in_actual
- RoomType entity: contains deposit_percent (để identify Standard rooms)

## Configuration & Constants

```java
// BookingScheduler
- Interval: 1 minute (hardcode)
- Thread name: "booking-auto-cancel"
- Daemon: true

// BookingSchedulerService
- CHECK_INTERVAL_MINUTES: 5 minutes
- Thread name: "BookingAutoCancel"
- Daemon: true
- Shutdown timeout: 5 seconds

// Business rules
- Overdue threshold: 6 hours past check-in expected
- Cancellation criteria: PENDING/CONFIRMED + no actual check-in
```

## Enum BookingStatus

```
PENDING, CONFIRMED, CHECKED_IN, CHECKED_OUT, COMPLETED, CANCELLED
```

## Summary

Tính năng lịch trình đặt phòng là một công cụ quan trọng để tự động giải phóng phòng bị block do khách không check-in đúng giờ. Hệ thống chạy nền theo đúng giờ (periodic check every 1 minute) hoặc lazy check khi admin view chi tiết booking. Kiến trúc sử dụng ScheduledExecutorService (background thread) tách biệt khỏi main application thread. Cách tiếp cận "set and forget" giảm thiểu manual intervention, tối ưu hóa tỷ lệ lấp đầu phòng khách sạn. Có thể mở rộng: thêm audit log, admin notification, configurable thresholds.
