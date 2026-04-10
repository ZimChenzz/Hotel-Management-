<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách đặt phòng - Cổng Nhân Viên</title>
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
            <c:set var="pageTitle" value="Danh sách đặt phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Filter -->
                <div class="card mb-4">
                    <div class="card-body py-2">
                        <div class="d-flex flex-wrap gap-2 align-items-center">
                            <span class="fw-bold me-2">Lọc theo:</span>
                            <a href="${pageContext.request.contextPath}/staff/bookings"
                               class="btn btn-sm ${empty filterStatus ? 'btn-primary' : 'btn-outline-primary'}">Tất cả</a>
                            <a href="${pageContext.request.contextPath}/staff/bookings?status=Pending"
                               class="btn btn-sm ${filterStatus == 'Pending' ? 'btn-warning' : 'btn-outline-warning'}">Chờ xử lý</a>
                            <a href="${pageContext.request.contextPath}/staff/bookings?status=Confirmed"
                               class="btn btn-sm ${filterStatus == 'Confirmed' ? 'btn-success' : 'btn-outline-success'}">Chờ check-in</a>
                            <a href="${pageContext.request.contextPath}/staff/bookings?status=CheckedIn"
                               class="btn btn-sm ${filterStatus == 'CheckedIn' ? 'btn-info' : 'btn-outline-info'}">Đang ở</a>
                            <a href="${pageContext.request.contextPath}/staff/bookings?status=CheckedOut"
                               class="btn btn-sm ${filterStatus == 'CheckedOut' ? 'btn-secondary' : 'btn-outline-secondary'}">Đã check-out</a>
                        </div>
                    </div>
                </div>

                <!-- Bookings Table -->
                <div class="staff-table">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Khách hàng</th>
                                <th>Phòng</th>
                                <th>Check-in</th>
                                <th>Check-out</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="booking" items="${bookings}">
                                <tr>
                                    <td><strong>#${booking.bookingId}</strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty booking.customer and not empty booking.customer.account}">
                                                ${booking.customer.account.fullName}
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty bookingRoomsMap[booking.bookingId]}">
                                                <span class="badge bg-purple">Nhiều phòng</span>
                                                <small class="text-muted d-block">${bookingRoomsMap[booking.bookingId].size()} phòng</small>
                                            </c:when>
                                            <c:when test="${not empty booking.room}">
                                                <strong>${booking.room.roomNumber}</strong>
                                                <small class="text-muted d-block">${booking.room.roomType.typeName}</small>
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${booking.checkInExpectedDateOnly}</td>
                                    <td>${booking.checkOutExpectedDateOnly}</td>
                                    <td>
                                        <fmt:formatNumber value="${booking.totalPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${booking.status == 'Pending'}">
                                                <span class="badge bg-warning text-dark">Chờ xác nhận</span>
                                            </c:when>
                                            <c:when test="${booking.status == 'Confirmed'}">
                                                <span class="badge bg-success">Chờ check-in</span>
                                            </c:when>
                                            <c:when test="${booking.status == 'CheckedIn'}">
                                                <span class="badge bg-info">Đang ở</span>
                                            </c:when>
                                            <c:when test="${booking.status == 'CheckedOut'}">
                                                <span class="badge bg-secondary">Đã check-out</span>
                                            </c:when>
                                            <c:when test="${booking.status == 'Cancelled'}">
                                                <span class="badge bg-danger">Đã hủy</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <c:if test="${booking.status == 'Confirmed'}">
                                                <a href="${pageContext.request.contextPath}/staff/bookings/assign?bookingId=${booking.bookingId}"
                                                   class="btn btn-success" title="Check-in">
                                                    <i class="bi bi-box-arrow-in-right"></i>
                                                </a>
                                            </c:if>
                                            <c:if test="${booking.status == 'CheckedIn'}">
                                                <a href="${pageContext.request.contextPath}/staff/bookings/occupants?bookingId=${booking.bookingId}"
                                                   class="btn btn-primary" title="Quản lý khách">
                                                    <i class="bi bi-people"></i>
                                                </a>
                                                <c:choose>
                                                    <c:when test="${not empty bookingRoomsMap[booking.bookingId]}">
                                                        <a href="${pageContext.request.contextPath}/staff/bookings/detail?id=${booking.bookingId}"
                                                           class="btn btn-warning" title="Check-out">
                                                            <i class="bi bi-box-arrow-right"></i>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/staff/bookings/checkout?bookingId=${booking.bookingId}"
                                                           class="btn btn-warning" title="Check-out">
                                                            <i class="bi bi-box-arrow-right"></i>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>
                                            <a href="${pageContext.request.contextPath}/staff/bookings/detail?id=${booking.bookingId}"
                                               class="btn btn-outline-secondary" title="Chi tiết">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty bookings}">
                                <tr>
                                    <td colspan="8" class="text-center text-muted py-4">
                                        <i class="bi bi-inbox fs-1 d-block mb-2"></i>
                                        Không có booking nào
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
