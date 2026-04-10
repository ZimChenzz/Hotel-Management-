<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trạng thái đặt phòng - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .timeline {
            position: relative;
            padding-left: 2rem;
        }
        .timeline::before {
            content: '';
            position: absolute;
            left: 0.5rem;
            top: 0;
            bottom: 0;
            width: 2px;
            background: var(--border-color);
        }
        .timeline-item {
            position: relative;
            padding-bottom: 1.5rem;
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -1.65rem;
            top: 0.25rem;
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background: var(--border-color);
            border: 3px solid #fff;
            box-shadow: 0 0 0 2px var(--border-color);
        }
        .timeline-item.active::before {
            background: var(--secondary);
            box-shadow: 0 0 0 2px var(--secondary);
        }
        .timeline-item.completed::before {
            background: var(--success);
            box-shadow: 0 0 0 2px var(--success);
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Page Header -->
    <section class="public-hero public-hero-small">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-2" style="--bs-breadcrumb-divider-color: rgba(255,255,255,0.5);">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/" style="color: rgba(255,255,255,0.7);">Trang chủ</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/bookings" style="color: rgba(255,255,255,0.7);">Đặt phòng của tôi</a></li>
                    <li class="breadcrumb-item text-white">Trạng thái</li>
                </ol>
            </nav>
            <h1 class="public-hero-title"><i class="bi bi-check-circle me-2"></i>Trạng thái đặt phòng</h1>
        </div>
    </section>

    <div class="container py-5">
        <div class="row g-4">
            <!-- Main Content -->
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-calendar-check me-2"></i>Thông tin đặt phòng</span>
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
                    </div>
                    <div class="card-body">
                        <div class="row mb-4">
                            <div class="col-md-8">
                                <c:choose>
                                    <c:when test="${isMultiRoom && not empty bookingRooms}">
                                        <h3 style="font-family: var(--font-display); color: var(--primary);">
                                            <i class="bi bi-door-open me-2"></i>${bookingRooms.size()} Phòng
                                        </h3>
                                        <p class="text-muted mb-0">
                                            <c:forEach var="br" items="${bookingRooms}" varStatus="loop">
                                                ${br.roomType.typeName}${loop.last ? '' : ', '}
                                            </c:forEach>
                                        </p>
                                    </c:when>
                                    <c:otherwise>
                                        <h3 style="font-family: var(--font-display); color: var(--primary);">${booking.room.roomType.typeName}</h3>
                                        <p class="text-muted mb-0">
                                            <i class="bi bi-door-open me-1"></i>Phòng ${booking.room.roomNumber}
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="col-md-4 text-md-end">
                                <small class="text-muted">Mã đặt phòng</small>
                                <p class="h3 mb-0" style="font-family: var(--font-display); color: var(--secondary-dark);">#${booking.bookingId}</p>
                            </div>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <div class="p-3 rounded" style="background: var(--surface-hover);">
                                    <div class="d-flex align-items-center">
                                        <div class="p-2 rounded me-3" style="background: rgba(25,135,84,0.1);">
                                            <i class="bi bi-calendar-check fs-4 text-success"></i>
                                        </div>
                                        <div>
                                            <small class="text-muted">Nhận phòng</small>
                                            <p class="mb-0 fw-semibold">${booking.checkInExpectedDateOnly} - 14:00</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-3 rounded" style="background: var(--surface-hover);">
                                    <div class="d-flex align-items-center">
                                        <div class="p-2 rounded me-3" style="background: rgba(220,53,69,0.1);">
                                            <i class="bi bi-calendar-x fs-4 text-danger"></i>
                                        </div>
                                        <div>
                                            <small class="text-muted">Trả phòng</small>
                                            <p class="mb-0 fw-semibold">${booking.checkOutExpectedDateOnly} - 12:00</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Multi-Room BookingRoom List -->
                        <c:if test="${isMultiRoom && not empty bookingRooms}">
                            <h5 class="mb-3" style="font-family: var(--font-display); color: var(--primary);">
                                <i class="bi bi-list-ul me-2"></i>Danh sách phòng
                            </h5>
                            <div class="table-responsive mb-4">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Loại phòng</th>
                                            <th>Phòng được gán</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="br" items="${bookingRooms}" varStatus="loop">
                                            <tr>
                                                <td><span class="badge bg-secondary">#${loop.index + 1}</span></td>
                                                <td>${br.roomType.typeName}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty br.room}">
                                                            <strong>${br.room.roomNumber}</strong>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">Chưa gán</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${br.status == 'Pending'}">
                                                            <span class="badge bg-warning text-dark">Chờ</span>
                                                        </c:when>
                                                        <c:when test="${br.status == 'Assigned'}">
                                                            <span class="badge bg-info">Đã gán</span>
                                                        </c:when>
                                                        <c:when test="${br.status == 'CheckedIn'}">
                                                            <span class="badge bg-success">Đã nhận</span>
                                                        </c:when>
                                                        <c:when test="${br.status == 'CheckedOut'}">
                                                            <span class="badge bg-secondary">Đã trả</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>

                        <c:if test="${not empty occupants}">
                            <h5 class="mb-3" style="font-family: var(--font-display); color: var(--primary);">
                                <i class="bi bi-people me-2"></i>Khách lưu trú
                            </h5>
                            <div class="table-responsive mb-4">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Họ tên</th>
                                            <th>CMND/CCCD</th>
                                            <th>Điện thoại</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="occ" items="${occupants}">
                                            <tr>
                                                <td>${occ.fullName}</td>
                                                <td>${occ.idCardNumber}</td>
                                                <td>${occ.phoneNumber}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>

                        <c:if test="${not empty booking.note}">
                            <h5 class="mb-2" style="font-family: var(--font-display); color: var(--primary);">
                                <i class="bi bi-chat-left-text me-2"></i>Ghi chú
                            </h5>
                            <p class="text-muted">${booking.note}</p>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="col-lg-4">
                <!-- Payment Summary -->
                <div class="card mb-4" style="background: var(--primary-gradient); color: white;">
                    <div class="card-header" style="background: transparent; border-bottom: 1px solid rgba(255,255,255,0.1);">
                        <i class="bi bi-credit-card me-2"></i>Thanh toán
                    </div>
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span>Tổng tiền</span>
                            <span class="h4 mb-0" style="color: var(--secondary);">
                                <fmt:formatNumber value="${booking.totalPrice}" type="number" groupingUsed="true"/>đ
                            </span>
                        </div>
                        <c:if test="${earlySurcharge != null && earlySurcharge > 0}">
                            <div class="d-flex justify-content-between py-1" style="opacity: 0.85;">
                                <span><i class="bi bi-alarm me-1"></i>Phu thu check-in som</span>
                                <span><fmt:formatNumber value="${earlySurcharge}" type="number" groupingUsed="true"/>d</span>
                            </div>
                        </c:if>
                        <c:if test="${lateSurcharge != null && lateSurcharge > 0}">
                            <div class="d-flex justify-content-between py-1" style="opacity: 0.85;">
                                <span><i class="bi bi-alarm-fill me-1"></i>Phu thu check-out muon</span>
                                <span><fmt:formatNumber value="${lateSurcharge}" type="number" groupingUsed="true"/>d</span>
                            </div>
                        </c:if>
                        <c:if test="${booking.paymentType == 'Deposit'}">
                            <div class="d-flex justify-content-between py-1" style="opacity: 0.85;">
                                <span>Đã cọc</span>
                                <span><fmt:formatNumber value="${booking.depositAmount}" type="number" groupingUsed="true"/>đ</span>
                            </div>
                            <div class="d-flex justify-content-between py-1" style="opacity: 0.85;">
                                <span>Còn lại</span>
                                <span><fmt:formatNumber value="${booking.totalPrice - booking.depositAmount}" type="number" groupingUsed="true"/>đ</span>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Extension Button (only for CheckedIn bookings) -->
                <c:if test="${booking.status == 'CheckedIn'}">
                    <a href="${pageContext.request.contextPath}/booking/extend?bookingId=${booking.bookingId}"
                       class="btn btn-warning w-100 mb-4">
                        <i class="bi bi-clock-history me-2"></i>Gia hạn thời gian
                    </a>
                </c:if>

                <!-- Status Timeline -->
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="bi bi-clock-history me-2"></i>Trạng thái
                    </div>
                    <div class="card-body">
                        <div class="timeline">
                            <div class="timeline-item ${booking.status == 'Pending' ? 'active' : (booking.status != 'Cancelled' ? 'completed' : '')}">
                                <strong>Chờ xác nhận</strong>
                                <p class="text-muted small mb-0">Đơn đặt phòng đã được tạo</p>
                            </div>
                            <div class="timeline-item ${booking.status == 'Confirmed' ? 'active' : (booking.status == 'CheckedIn' || booking.status == 'CheckedOut' ? 'completed' : '')}">
                                <strong>Đã xác nhận</strong>
                                <p class="text-muted small mb-0">Thanh toán thành công</p>
                            </div>
                            <div class="timeline-item ${booking.status == 'CheckedIn' ? 'active' : (booking.status == 'CheckedOut' ? 'completed' : '')}">
                                <strong>Đã nhận phòng</strong>
                                <p class="text-muted small mb-0">Khách đã check-in</p>
                            </div>
                            <div class="timeline-item ${booking.status == 'CheckedOut' ? 'completed' : ''}">
                                <strong>Hoàn thành</strong>
                                <p class="text-muted small mb-0">Khách đã trả phòng</p>
                            </div>
                        </div>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/customer/bookings" class="btn btn-outline-secondary w-100">
                    <i class="bi bi-arrow-left me-2"></i>Quay lại danh sách
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
