# Báo cáo và Thống kê

## Tong quan nghiep vu

Mô-đun Báo cáo và Thống kê cho phép quản trị viên khách sạn xem các chỉ số kinh doanh quan trọng, bao gồm:

1. **Dashboard tổng quan**: Hiển thị các thống kê tổng quát về phòng, đặt phòng, doanh thu, khách hàng
2. **Báo cáo công suất phòng**: Phân tích tỷ lệ sử dụng phòng, trạng thái phòng (chiếm dụng, trống, vệ sinh, bảo trì)
3. **Báo cáo doanh thu**: Chi tiết doanh thu theo khoảng thời gian, số đơn đặt phòng trung bình

Dữ liệu được lấy từ các bảng Room, Booking, Customer trong database.

## Kien truc & Code Flow

```
HTTP Request (GET)
    |
    v
AdminDashboardController / AdminReportController
    |
    v
AdminReportService
    |
    +---> RoomRepository (count, countByStatus)
    +---> BookingRepository (countAll, sumTotalPrice, countByDateRange)
    +---> CustomerRepository (countAll)
    |
    v
Database (HotelManagementSystem)
```

Cơ chế hoạt động:
1. Controller nhận request từ client
2. Gọi AdminReportService để lấy dữ liệu
3. Service sử dụng Repository để query database
4. Dữ liệu được xử lý, format thành Map<String, Object>
5. Controller set attributes và forward sang JSP view
6. JSP render dữ liệu thành HTML/Chart

## Chi tiet tung ham

### AdminDashboardController

#### doGet (HttpServletRequest request, HttpServletResponse response)

- **Muc dich**: Xử lý request GET đến /admin/dashboard, hiển thị trang dashboard tổng quan
- **Input**:
  - request: HttpServletRequest chứa thông tin request từ client
  - response: HttpServletResponse dùng để gửi response về client
- **Output**: Void - forward request đến view /WEB-INF/views/admin/dashboard.jsp
- **Logic xu ly**:
  1. Gọi adminReportService.getDashboardStats() lấy thống kê tổng quát (tổng phòng, đặt phòng, doanh thu, khách hàng, phòng theo từng trạng thái)
  2. Gọi adminReportService.getMonthlyLabels() lấy nhãn tháng (6 tháng gần nhất, định dạng "T1", "T2", v.v.)
  3. Gọi adminReportService.getMonthlyBookingCounts() lấy số lượng đặt phòng theo từng tháng
  4. Convert mảng tháng và số đếm thành JSON string cho biểu đồ (sử dụng Array.stream() và Collectors)
  5. Gọi serviceRequestService.getRequestStats() lấy thống kê yêu cầu dịch vụ
  6. Set các attribute vào request (stats, monthlyLabels, monthlyCounts, serviceRequestStats, activePage, pageTitle)
  7. Forward request sang view JSP
- **Xu ly loi**: Không có xử lý lỗi rõ ràng - nếu service throw exception, servlet sẽ báo lỗi
- **Lien ket**:
  - AdminReportService
  - ServiceRequestService

---

### AdminReportController

#### doGet (HttpServletRequest request, HttpServletResponse response)

- **Muc dich**: Xử lý GET request đến các endpoint báo cáo (/admin/reports/utilization, /admin/reports/revenue)
- **Input**:
  - request: HttpServletRequest chứa servlet path
  - response: HttpServletResponse
- **Output**: Void - forward hoặc redirect
- **Logic xu ly**:
  1. Lấy servlet path từ request.getServletPath()
  2. Dùng switch statement để xác định endpoint
  3. Nếu /admin/reports/utilization -> gọi handleUtilizationReport()
  4. Nếu /admin/reports/revenue -> gọi handleRevenueReport()
  5. Ngược lại -> sendError(404)
- **Xu ly loi**: Trả về 404 nếu endpoint không hợp lệ
- **Lien ket**: handleUtilizationReport, handleRevenueReport

---

#### handleUtilizationReport (HttpServletRequest request, HttpServletResponse response)

- **Muc dich**: Xử lý yêu cầu báo cáo công suất phòng
- **Input**: request, response
- **Output**: Void - forward đến /WEB-INF/views/admin/reports/utilization.jsp
- **Logic xu ly**:
  1. Gọi adminReportService.getRoomUtilizationStats() lấy dữ liệu công suất
  2. Set attribute stats vào request
  3. Set activePage = "utilization", pageTitle = "Báo cáo công suất phòng"
  4. Forward sang view utilization.jsp
- **Xu ly loi**: Nếu service throw exception, servlet báo lỗi
- **Lien ket**: AdminReportService.getRoomUtilizationStats()

---

#### handleRevenueReport (HttpServletRequest request, HttpServletResponse response)

- **Muc dich**: Xử lý yêu cầu báo cáo doanh thu theo khoảng thời gian
- **Input**: request (có thể chứa startDate, endDate parameter), response
- **Output**: Void - forward đến /WEB-INF/views/admin/reports/revenue.jsp
- **Logic xu ly**:
  1. Lấy startDate và endDate từ request parameter (định dạng yyyy-MM-dd)
  2. Nếu cả hai tồn tại:
     - Parse startDate thành LocalDate rồi convert thành LocalDateTime 00:00:00
     - Parse endDate thành LocalDate rồi convert thành LocalDateTime 23:59:59
  3. Nếu không tồn tại (hoặc NULL):
     - Lấy ngày hiện tại (LocalDate.now())
     - startDate = ngày đầu tiên của tháng hiện tại 00:00:00
     - endDate = ngày hiện tại 23:59:59
  4. Gọi adminReportService.getRevenueReport(startDate, endDate) lấy dữ liệu doanh thu
  5. Set attribute report, startDate, endDate vào request
  6. Set activePage = "revenue", pageTitle = "Báo cáo doanh thu"
  7. Forward sang view revenue.jsp
- **Xu ly loi**: Nếu parse date thất bại, sẽ throw exception (không catch)
- **Lien ket**: AdminReportService.getRevenueReport()

---

### AdminReportService

#### getDashboardStats(): Map<String, Object>

- **Muc dich**: Lấy các thống kê tổng quát cho dashboard
- **Input**: Không có
- **Output**: Map chứa 8 key-value:
  - "totalRooms": int - tổng số phòng
  - "totalBookings": int - tổng số đặt phòng
  - "totalRevenue": BigDecimal - tổng doanh thu
  - "totalCustomers": int - tổng khách hàng
  - "occupiedRooms": int - phòng đang chiếm dụng
  - "availableRooms": int - phòng trống
  - "cleaningRooms": int - phòng đang vệ sinh
  - "maintenanceRooms": int - phòng bảo trì
- **Logic xu ly**:
  1. Tạo HashMap mới
  2. Gọi roomRepository.countAll() -> totalRooms
  3. Gọi bookingRepository.countAll() -> totalBookings
  4. Gọi bookingRepository.sumTotalPrice() -> totalRevenue
  5. Gọi customerRepository.countAll() -> totalCustomers
  6. Gọi roomRepository.countByStatus(RoomStatus.OCCUPIED) -> occupiedRooms
  7. Gọi roomRepository.countByStatus(RoomStatus.AVAILABLE) -> availableRooms
  8. Gọi roomRepository.countByStatus(RoomStatus.CLEANING) -> cleaningRooms
  9. Gọi roomRepository.countByStatus(RoomStatus.MAINTENANCE) -> maintenanceRooms
  10. Put tất cả vào map và return
- **Xu ly loi**: Nếu repository throw exception, sẽ propagate lên controller
- **Lien ket**: RoomRepository, BookingRepository, CustomerRepository

---

#### getMonthlyBookingCounts(): int[]

- **Muc dich**: Lấy số lượng đặt phòng cho 6 tháng gần nhất
- **Input**: Không có
- **Output**: Mảng int có 6 phần tử, index 0 = tháng cũ nhất, index 5 = tháng hiện tại
- **Logic xu ly**:
  1. Tạo mảng int kích thước 6
  2. Lấy LocalDate.now() = ngày hôm nay
  3. Loop i từ 5 xuống 0:
     - monthDate = now.minusMonths(i) = tính ngày của tháng i tháng trước
     - start = monthDate.withDayOfMonth(1).atStartOfDay() = ngày đầu tháng 00:00:00
     - end = monthDate.withDayOfMonth(monthDate.lengthOfMonth()).atTime(23, 59, 59) = ngày cuối tháng 23:59:59
     - Gọi bookingRepository.countByDateRange(start, end) lấy số đơn đặt phòng
     - counts[5 - i] = kết quả
  4. Return mảng counts
- **Xu ly loi**: Nếu countByDateRange throw exception, propagate lên
- **Lien ket**: BookingRepository.countByDateRange()

---

#### getMonthlyLabels(): String[]

- **Muc dich**: Lấy nhãn tháng cho 6 tháng gần nhất (định dạng "T1", "T2", ...)
- **Input**: Không có
- **Output**: Mảng String có 6 phần tử, ví dụ ["T8", "T9", "T10", "T11", "T12", "T1"]
- **Logic xu ly**:
  1. Tạo mảng String kích thước 6
  2. Lấy LocalDate.now()
  3. Loop i từ 5 xuống 0:
     - monthDate = now.minusMonths(i)
     - labels[5 - i] = "T" + monthDate.getMonthValue()
  4. Return mảng labels
- **Xu ly loi**: Không có exception
- **Lien ket**: Không

---

#### getRoomUtilizationStats(): Map<String, Object>

- **Muc dich**: Lấy thống kê công suất sử dụng phòng
- **Input**: Không có
- **Output**: Map chứa 6 key-value:
  - "totalRooms": int - tổng số phòng
  - "occupied": int - phòng chiếm dụng
  - "available": int - phòng trống
  - "cleaning": int - phòng vệ sinh
  - "maintenance": int - phòng bảo trì
  - "utilizationRate": String - tỷ lệ công suất (format 1 chữ số thập phân, ví dụ "75.5")
- **Logic xu ly**:
  1. Tạo HashMap
  2. Gọi roomRepository.countAll() -> totalRooms
  3. Lấy số phòng theo từng trạng thái (occupied, available, cleaning, maintenance)
  4. Tính utilizationRate = (occupied / totalRooms) * 100
  5. Nếu totalRooms = 0 -> utilizationRate = 0
  6. Format utilizationRate thành String với 1 chữ số thập phân: String.format("%.1f", utilizationRate)
  7. Put tất cả vào map
  8. Return map
- **Xu ly loi**: Nếu countByStatus throw exception, propagate lên
- **Lien ket**: RoomRepository

---

#### getRevenueReport(LocalDateTime startDate, LocalDateTime endDate): Map<String, Object>

- **Muc dich**: Lấy báo cáo doanh thu trong khoảng thời gian
- **Input**:
  - startDate: LocalDateTime - ngày bắt đầu
  - endDate: LocalDateTime - ngày kết thúc
- **Output**: Map chứa 3 key-value:
  - "totalRevenue": BigDecimal - tổng doanh thu
  - "bookingCount": int - tổng số đơn đặt phòng
  - "averageBookingValue": BigDecimal - giá trị trung bình mỗi đơn (làm tròn lên)
- **Logic xu ly**:
  1. Tạo HashMap
  2. Gọi bookingRepository.sumTotalPriceByDateRange(startDate, endDate) -> totalRevenue
  3. Gọi bookingRepository.countByDateRange(startDate, endDate) -> bookingCount
  4. Tính averageBookingValue:
     - Nếu bookingCount > 0: averageBookingValue = totalRevenue / bookingCount (làm tròn nửa lên)
     - Ngược lại: averageBookingValue = BigDecimal.ZERO
  5. Put vào map
  6. Return map
- **Xu ly loi**: Nếu repository throw exception, propagate lên
- **Lien ket**: BookingRepository

---

## Summary

**Flow chung:**
1. Admin truy cập /admin/dashboard -> AdminDashboardController.doGet()
2. Admin truy cập /admin/reports/utilization -> AdminReportController.doGet() -> handleUtilizationReport()
3. Admin truy cập /admin/reports/revenue -> AdminReportController.doGet() -> handleRevenueReport()
4. Tất cả gọi AdminReportService để xử lý dữ liệu từ các Repository
5. Dữ liệu được format thành Map và gửi sang JSP view
6. JSP render dữ liệu thành giao diện hiển thị cho admin
