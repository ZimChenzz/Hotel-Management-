<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gán phòng - Cổng Nhân Viên</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="bookings" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Gán phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <div class="mb-3">
                    <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Danh sách booking
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/bookings/detail?id=${booking.bookingId}"
                       class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i> Quay lại chi tiết
                    </a>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <!-- Booking Summary -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-info-circle me-2"></i>Booking #${booking.bookingId}
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3">
                                <p class="mb-1 text-muted small">Khách hàng</p>
                                <p class="mb-0 fw-semibold">
                                    <c:choose>
                                        <c:when test="${not empty booking.customer and not empty booking.customer.account}">
                                            ${booking.customer.account.fullName}
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                            <div class="col-md-3">
                                <p class="mb-1 text-muted small">Check-in dự kiến</p>
                                <p class="mb-0 fw-semibold">${booking.checkInExpectedFormatted}</p>
                            </div>
                            <div class="col-md-3">
                                <p class="mb-1 text-muted small">Check-out dự kiến</p>
                                <p class="mb-0 fw-semibold">${booking.checkOutExpectedFormatted}</p>
                            </div>
                            <div class="col-md-3">
                                <p class="mb-1 text-muted small">Tổng tiền</p>
                                <p class="mb-0 fw-semibold text-success">
                                    <fmt:formatNumber value="${booking.totalPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty unassignedRooms}">
                        <div class="alert alert-success">
                            <i class="bi bi-check-circle me-2"></i>Tất cả các phòng đã được gán cho booking này!
                        </div>
                        <a href="${pageContext.request.contextPath}/staff/bookings/detail?id=${booking.bookingId}"
                           class="btn btn-primary">
                            <i class="bi bi-eye me-1"></i>Xem chi tiết booking
                        </a>
                    </c:when>
                    <c:otherwise>
                        <form method="post" action="${pageContext.request.contextPath}/staff/bookings/bulk-assign" id="assignForm">
                            <input type="hidden" name="bookingId" value="${booking.bookingId}">

                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h4 class="mb-0">
                                    <i class="bi bi-door-open me-2"></i>Phòng cần gán (${unassignedRooms.size()})
                                </h4>
                            </div>

                            <div class="row g-3 mb-4">
                                <c:forEach var="roomInfo" items="${unassignedRooms}" varStatus="status">
                                    <div class="col-lg-6">
                                        <div class="card h-100">
                                            <div class="card-header text-white bg-${status.index == 0 ? 'primary' : status.index == 1 ? 'success' : status.index == 2 ? 'info' : status.index == 3 ? 'warning' : status.index == 4 ? 'danger' : 'secondary'}">
                                                <h6 class="mb-0">
                                                    <i class="bi bi-hash me-1"></i>Phòng #${roomInfo.bookingRoom.bookingRoomId}
                                                    - ${roomInfo.bookingRoom.roomType.typeName}
                                                </h6>
                                            </div>
                                            <div class="card-body">
                                                <c:choose>
                                                    <c:when test="${roomInfo.hasSuggestions()}">
                                                        <div class="alert alert-light mb-3">
                                                            <i class="bi bi-lightbulb me-1 text-warning"></i>
                                                            <strong>Gợi ý:</strong>
                                                            <c:forEach var="sug" items="${roomInfo.suggestions}" end="2">
                                                                <span class="badge bg-warning text-dark ms-1">${sug.suggestedRoomNumber}</span>
                                                            </c:forEach>
                                                            <c:if test="${roomInfo.suggestions.size() > 3}">
                                                                <span class="text-muted">+${roomInfo.suggestions.size() - 3} khác</span>
                                                            </c:if>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="alert alert-secondary mb-3">
                                                            <i class="bi bi-info-circle me-1"></i>
                                                            Không có gợi ý cho loại phòng này
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>

                                                <div class="mb-3">
                                                    <label class="form-label">Chọn phòng:</label>
                                                    <select class="form-select" name="roomId_${roomInfo.bookingRoom.bookingRoomId}" required>
                                                        <option value="">-- Chọn phòng --</option>
                                                        <c:forEach var="room" items="${roomInfo.availableRooms}">
                                                            <option value="${room.roomId}">${room.roomNumber}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>

                                                <input type="hidden" name="bookingRoomId" value="${roomInfo.bookingRoom.bookingRoomId}">
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="card">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <span class="text-muted">
                                                <i class="bi bi-info-circle me-1"></i>
                                                Đã gán: <span id="assignedCount">0</span> / ${unassignedRooms.size()} phòng
                                            </span>
                                        </div>
                                        <div class="d-flex gap-2">
                                            <a href="${pageContext.request.contextPath}/staff/bookings/detail?id=${booking.bookingId}"
                                               class="btn btn-outline-secondary">
                                                Hủy
                                            </a>
                                            <button type="submit" class="btn btn-success" id="checkinAllBtn" disabled>
                                                <i class="bi bi-check-circle me-1"></i>Gán & Check-in tất cả
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>

                        <script>
                            // Update assigned count and button state
                            function updateAssignState() {
                                let assigned = 0;
                                const total = ${unassignedRooms.size()};

                                <c:forEach var="roomInfo" items="${unassignedRooms}">
                                const select_${roomInfo.bookingRoom.bookingRoomId} = document.querySelector('select[name="roomId_${roomInfo.bookingRoom.bookingRoomId}"]');
                                if (select_${roomInfo.bookingRoom.bookingRoomId} && select_${roomInfo.bookingRoom.bookingRoomId}.value) {
                                    assigned++;
                                }
                                </c:forEach>

                                document.getElementById('assignedCount').textContent = assigned;
                                document.getElementById('checkinAllBtn').disabled = (assigned < total);
                            }

                            // Listen for changes on all selects
                            <c:forEach var="roomInfo" items="${unassignedRooms}">
                            document.querySelector('select[name="roomId_${roomInfo.bookingRoom.bookingRoomId}"]')
                                .addEventListener('change', updateAssignState);
                            </c:forEach>

                            // Form validation before submit
                            document.getElementById('assignForm').addEventListener('submit', function(e) {
                                const total = ${unassignedRooms.size()};
                                let assigned = 0;

                                <c:forEach var="roomInfo" items="${unassignedRooms}">
                                if (document.querySelector('select[name="roomId_${roomInfo.bookingRoom.bookingRoomId}"]').value) {
                                    assigned++;
                                }
                                </c:forEach>

                                if (assigned < total) {
                                    e.preventDefault();
                                    alert('Vui lòng gán phòng cho tất cả các BookingRoom!');
                                }
                            });
                        </script>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
