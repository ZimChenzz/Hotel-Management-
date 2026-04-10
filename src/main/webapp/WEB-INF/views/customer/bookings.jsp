<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch sử đặt phòng - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Page Header -->
    <section class="public-hero public-hero-small">
        <div class="container">
            <h1 class="public-hero-title"><i class="bi bi-calendar-check me-2"></i>Đặt phòng của tôi</h1>
        </div>
    </section>

    <div class="container py-5">
        <div class="row g-4">
            <!-- Sidebar -->
            <div class="col-lg-3">
                <div class="card">
                    <div class="card-header text-center py-4" style="background: var(--secondary-gradient); color: white;">
                        <div class="topbar-user-avatar mx-auto mb-2" style="width: 64px; height: 64px; font-size: 1.5rem; background: rgba(255,255,255,0.2);">
                            <c:choose>
                                <c:when test="${not empty sessionScope.loggedInAccount.fullName}">
                                    ${sessionScope.loggedInAccount.fullName.substring(0,1).toUpperCase()}
                                </c:when>
                                <c:otherwise>U</c:otherwise>
                            </c:choose>
                        </div>
                        <h6 class="mb-1">${sessionScope.loggedInAccount.fullName}</h6>
                        <small style="opacity: 0.9;">${sessionScope.loggedInAccount.email}</small>
                    </div>
                    <div class="card-body p-0">
                        <nav class="customer-sidebar-nav">
                            <a href="${pageContext.request.contextPath}/customer/profile" class="customer-nav-item">
                                <i class="bi bi-person-gear"></i>Thông tin cá nhân
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/bookings" class="customer-nav-item active">
                                <i class="bi bi-calendar-check"></i>Lịch sử đặt phòng
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/reviews" class="customer-nav-item">
                                <i class="bi bi-star"></i>Đánh giá của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/requests" class="customer-nav-item">
                                <i class="bi bi-bell"></i>Yêu cầu dịch vụ
                            </a>
                            <a href="${pageContext.request.contextPath}/auth/change-password" class="customer-nav-item">
                                <i class="bi bi-key"></i>Đổi mật khẩu
                            </a>
                        </nav>
                    </div>
                </div>

                <!-- Filter -->
                <div class="card mt-4">
                    <div class="card-header">
                        <i class="bi bi-funnel me-2"></i>Lọc theo trạng thái
                    </div>
                    <div class="card-body p-2">
                        <a href="${pageContext.request.contextPath}/customer/bookings"
                           class="d-block px-3 py-2 rounded text-decoration-none ${empty statusFilter ? 'bg-primary text-white' : 'text-muted'}">
                            <i class="bi bi-grid me-2"></i>Tất cả
                        </a>
                        <a href="?status=Pending" class="d-block px-3 py-2 rounded text-decoration-none ${statusFilter == 'Pending' ? 'bg-primary text-white' : 'text-muted'}">
                            <i class="bi bi-clock me-2"></i>Chờ thanh toán
                        </a>
                        <a href="?status=Confirmed" class="d-block px-3 py-2 rounded text-decoration-none ${statusFilter == 'Confirmed' ? 'bg-primary text-white' : 'text-muted'}">
                            <i class="bi bi-check-circle me-2"></i>Đã xác nhận
                        </a>
                        <a href="?status=CheckedIn" class="d-block px-3 py-2 rounded text-decoration-none ${statusFilter == 'CheckedIn' ? 'bg-primary text-white' : 'text-muted'}">
                            <i class="bi bi-door-open me-2"></i>Đang ở
                        </a>
                        <a href="?status=CheckedOut" class="d-block px-3 py-2 rounded text-decoration-none ${statusFilter == 'CheckedOut' ? 'bg-primary text-white' : 'text-muted'}">
                            <i class="bi bi-check2-all me-2"></i>Hoàn thành
                        </a>
                        <a href="?status=Cancelled" class="d-block px-3 py-2 rounded text-decoration-none ${statusFilter == 'Cancelled' ? 'bg-primary text-white' : 'text-muted'}">
                            <i class="bi bi-x-circle me-2"></i>Đã hủy
                        </a>
                    </div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-lg-9">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h4 class="mb-1" style="font-family: var(--font-display); color: var(--primary);">
                            Lịch sử đặt phòng
                        </h4>
                        <p class="text-muted mb-0">Quản lý các đơn đặt phòng của bạn</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary">
                        <i class="bi bi-plus-lg me-1"></i>Đặt phòng mới
                    </a>
                </div>

                <c:if test="${empty bookings}">
                    <div class="card">
                        <div class="card-body">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="bi bi-calendar-x"></i>
                                </div>
                                <h3 class="empty-state-title">Chưa có đặt phòng nào</h3>
                                <p class="empty-state-text">Bạn chưa có đặt phòng nào. Hãy khám phá các phòng nghỉ đẳng cấp!</p>
                                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary">
                                    <i class="bi bi-search me-1"></i>Tìm phòng ngay
                                </a>
                            </div>
                        </div>
                    </div>
                </c:if>

                <c:forEach var="booking" items="${bookings}">
                    <div class="card mb-3 booking-card-hover">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-auto">
                                    <div class="text-center p-3 rounded" style="background: var(--primary-gradient); color: white; min-width: 70px;">
                                        <small style="opacity: 0.8;">MÃ</small>
                                        <div class="fs-5 fw-bold">#${booking.bookingId}</div>
                                    </div>
                                </div>
                                <div class="col">
                                    <h5 class="mb-1" style="font-family: var(--font-display); color: var(--primary);">
                                        ${booking.room.roomType.typeName}
                                    </h5>
                                    <p class="text-muted mb-1">
                                        <i class="bi bi-door-open me-1"></i>Phòng ${booking.room.roomNumber}
                                    </p>
                                    <p class="mb-0 small text-muted">
                                        <i class="bi bi-calendar me-1"></i>
                                        ${booking.checkInExpectedDateOnly} → ${booking.checkOutExpectedDateOnly}
                                    </p>
                                </div>
                                <div class="col-auto text-end">
                                    <c:choose>
                                        <c:when test="${booking.status == 'Pending'}">
                                            <span class="badge badge-pending">Chờ thanh toán</span>
                                        </c:when>
                                        <c:when test="${booking.status == 'Confirmed'}">
                                            <span class="badge badge-confirmed">Đã xác nhận</span>
                                        </c:when>
                                        <c:when test="${booking.status == 'CheckedIn'}">
                                            <span class="badge badge-occupied">Đang ở</span>
                                        </c:when>
                                        <c:when test="${booking.status == 'CheckedOut'}">
                                            <span class="badge badge-completed">Hoàn thành</span>
                                        </c:when>
                                        <c:when test="${booking.status == 'Cancelled'}">
                                            <span class="badge badge-cancelled">Đã hủy</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">${booking.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="fs-5 fw-bold mt-2" style="color: var(--secondary-dark);">
                                        <fmt:formatNumber value="${booking.totalPrice}" type="number" groupingUsed="true"/>đ
                                    </div>
                                    <div class="mt-2 d-flex gap-1 flex-wrap justify-content-end">
                                        <a href="${pageContext.request.contextPath}/customer/booking?id=${booking.bookingId}"
                                           class="btn btn-outline-secondary btn-sm">
                                            <i class="bi bi-eye me-1"></i>Chi tiết
                                        </a>
                                        <c:if test="${booking.status == 'Pending'}">
                                            <a href="${pageContext.request.contextPath}/payment/process?bookingId=${booking.bookingId}"
                                               class="btn btn-primary btn-sm">
                                                <i class="bi bi-credit-card me-1"></i>Thanh toán
                                            </a>
                                        </c:if>
                                        <c:if test="${booking.status == 'Pending' || booking.status == 'Confirmed'}">
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/customer/booking/cancel"
                                                  class="d-inline"
                                                  onsubmit="return confirm('Hủy đặt phòng #${booking.bookingId}?')">
                                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                <button type="submit" class="btn btn-outline-danger btn-sm">
                                                    <i class="bi bi-x-circle me-1"></i>Hủy
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
