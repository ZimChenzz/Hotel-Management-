<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết Booking #${booking.bookingId} - Cổng Nhân Viên</title>
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
            <c:set var="pageTitle" value="Chi tiết Booking #${booking.bookingId}" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <div class="mb-3">
                    <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách
                    </a>
                </div>

                <!-- Room Suggestions Section (for multi-room bookings with unassigned rooms) -->
                <c:if test="${hasUnassignedRooms && not empty suggestionsByType}">
                    <div class="card mb-4 border-warning">
                        <div class="card-header bg-warning text-dark d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="bi bi-lightbulb me-2"></i>Gợi ý phân phòng</h5>
                            <div>
                                <a href="${pageContext.request.contextPath}/staff/bookings/suggest-rooms?bookingId=${booking.bookingId}"
                                   class="btn btn-sm btn-dark me-2">
                                    <i class="bi bi-arrow-right me-1"></i>Xem tất cả
                                </a>
                                <form method="post" action="${pageContext.request.contextPath}/staff/bookings/bulk-assign" class="d-inline">
                                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                    <c:forEach var="entry" items="${suggestionsByType}">
                                        <c:forEach var="suggestion" items="${entry.value}">
                                            <input type="hidden" name="acceptedSuggestions"
                                                   value="${suggestion.bookingRoomId}:${suggestion.suggestedRoomId}">
                                        </c:forEach>
                                    </c:forEach>
                                    <button type="submit" class="btn btn-sm btn-success">
                                        <i class="bi bi-check-all me-1"></i>Áp dụng tất cả
                                    </button>
                                </form>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Mã BookingRoom</th>
                                            <th>Loại phòng</th>
                                            <th>Phòng đề xuất</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="entry" items="${suggestionsByType}">
                                            <c:forEach var="suggestion" items="${entry.value}" end="2">
                                                <tr>
                                                    <td><span class="badge bg-secondary">#${suggestion.bookingRoomId}</span></td>
                                                    <td>${suggestion.roomTypeName}</td>
                                                    <td><strong class="text-success">${suggestion.suggestedRoomNumber}</strong></td>
                                                    <td>
                                                        <form method="post" action="${pageContext.request.contextPath}/staff/bookings/bulk-assign" class="d-inline">
                                                            <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                            <input type="hidden" name="acceptedSuggestions" value="${suggestion.bookingRoomId}:${suggestion.suggestedRoomId}">
                                                            <button type="submit" class="btn btn-success btn-sm">
                                                                <i class="bi bi-check"></i> Áp dụng
                                                            </button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </c:if>

                <div class="row">
                    <div class="col-lg-8">
                        <div class="card mb-4">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="bi bi-receipt me-2"></i>Booking #${booking.bookingId}</h5>
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
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${isMultiRoom && not empty bookingRooms}">
                                        <!-- Multi-Room Booking Room List -->
                                        <h6 class="text-muted mb-3">Danh sách phòng (${bookingRooms.size()} phòng)</h6>
                                        <div class="table-responsive">
                                            <table class="table table-sm">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Loại phòng</th>
                                                        <th>Phòng được gán</th>
                                                        <th>Trạng thái</th>
                                                        <th>Check-in thực tế</th>
                                                        <th>Check-out thực tế</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="br" items="${bookingRooms}" varStatus="loop">
                                                        <tr>
                                                            <td><span class="badge bg-secondary">#${br.bookingRoomId}</span></td>
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
                                                            <td>${br.checkInActual != null ? br.checkInActual : '-'}</td>
                                                            <td>${br.checkOutActual != null ? br.checkOutActual : '-'}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${br.status == 'Pending' or br.status == 'Assigned'}">
                                                                        <a href="${pageContext.request.contextPath}/staff/bookings/assign-room?bookingId=${booking.bookingId}&bookingRoomId=${br.bookingRoomId}"
                                                                           class="btn btn-sm btn-success">
                                                                            <i class="bi bi-box-arrow-in-right"></i> Gán phòng
                                                                        </a>
                                                                    </c:when>
                                                                    <c:when test="${br.status == 'CheckedIn'}">
                                                                        <a href="${pageContext.request.contextPath}/staff/bookings/checkout-room?bookingId=${booking.bookingId}&bookingRoomId=${br.bookingRoomId}"
                                                                           class="btn btn-sm btn-outline-warning">
                                                                            <i class="bi bi-box-arrow-right"></i>
                                                                        </a>
                                                                    </c:when>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Single Room Info (existing layout) -->
                                        <div class="row">
                                            <div class="col-md-6">
                                                <h6 class="text-muted mb-3">Thông tin phòng</h6>
                                                <p><strong>Số phòng:</strong> ${booking.room.roomNumber}</p>
                                                <p><strong>Loại phòng:</strong> ${booking.room.roomType.typeName}</p>
                                                <p><strong>Giá cơ bản:</strong>
                                                    <fmt:formatNumber value="${booking.room.roomType.basePrice}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ/đêm
                                                </p>
                                            </div>
                                            <div class="col-md-6">
                                                <h6 class="text-muted mb-3">Thời gian</h6>
                                                <p><strong>Ngày đặt:</strong>
                                                    ${booking.bookingDateFormatted}
                                                </p>
                                                <p><strong>Check-in:</strong>
                                                    ${booking.checkInExpectedFormatted}
                                                </p>
                                                <p><strong>Check-out:</strong>
                                                    ${booking.checkOutExpectedFormatted}
                                                </p>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <hr>

                                <h6 class="text-muted mb-3">Khách lưu trú</h6>
                                <c:choose>
                                    <c:when test="${not empty occupants}">
                                        <div class="table-responsive">
                                            <table class="table table-sm">
                                                <thead>
                                                    <tr>
                                                        <th>Họ tên</th>
                                                        <th>CCCD/Passport</th>
                                                        <th>SĐT</th>
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
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted">Chưa có thông tin khách</p>
                                    </c:otherwise>
                                </c:choose>

                                <c:if test="${not empty booking.note}">
                                    <hr>
                                    <h6 class="text-muted mb-2">Ghi chú</h6>
                                    <p class="mb-0">${booking.note}</p>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="card mb-4">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="bi bi-cash me-2"></i>Thanh toán</h5>
                            </div>
                            <div class="card-body">
                                <table class="table table-borderless mb-0">
                                    <tr>
                                        <td>Tiền phòng:</td>
                                        <td class="text-end">
                                            <fmt:formatNumber value="${booking.totalPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                        </td>
                                    </tr>
                                    <c:if test="${surcharge != null && surcharge.sameDayBooking}">
                                        <tr class="text-muted">
                                            <td><i class="bi bi-clock me-1"></i>Phí theo giờ (${surcharge.totalHours} giờ):</td>
                                            <td class="text-end">
                                                <fmt:formatNumber value="${surcharge.hourlyTotal}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                            </td>
                                        </tr>
                                    </c:if>
                                    <c:if test="${surcharge != null && surcharge.earlySurcharge > 0}">
                                        <tr class="text-muted">
                                            <td><i class="bi bi-arrow-up-circle me-1"></i>Phí check-in sớm (${surcharge.earlyHours} giờ):</td>
                                            <td class="text-end">
                                                + <fmt:formatNumber value="${surcharge.earlySurcharge}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                            </td>
                                        </tr>
                                    </c:if>
                                    <c:if test="${surcharge != null && surcharge.lateSurcharge > 0}">
                                        <tr class="text-muted">
                                            <td><i class="bi bi-arrow-down-circle me-1"></i>Phí check-out muộn (${surcharge.lateHours} giờ):</td>
                                            <td class="text-end">
                                                + <fmt:formatNumber value="${surcharge.lateSurcharge}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                            </td>
                                        </tr>
                                    </c:if>
                                    <c:if test="${booking.paymentType == 'Deposit' && booking.depositAmount != null}">
                                        <tr class="border-top">
                                            <td>Đã cọc trước:</td>
                                            <td class="text-end text-success">
                                                - <fmt:formatNumber value="${booking.depositAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                            </td>
                                        </tr>
                                    </c:if>
                                    <tr class="border-top">
                                        <td><strong>Cần thu:</strong></td>
                                        <td class="text-end">
                                            <c:choose>
                                                <c:when test="${needsCheckoutPayment}">
                                                    <strong class="fs-5 text-danger">
                                                        <fmt:formatNumber value="${checkoutPaymentAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                    </strong>
                                                </c:when>
                                                <c:otherwise>
                                                    <strong class="fs-5 text-success">Đã thanh toán đủ</strong>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <div class="card">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="bi bi-gear me-2"></i>Thao tác</h5>
                            </div>
                            <div class="card-body d-grid gap-2">
                                <c:if test="${booking.status == 'Confirmed'}">
                                    <c:choose>
                                        <c:when test="${isMultiRoom}">
                                            <a href="${pageContext.request.contextPath}/staff/bookings/assign?bookingId=${booking.bookingId}"
                                               class="btn btn-success">
                                                <i class="bi bi-box-arrow-in-right me-1"></i>Gán tất cả phòng
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/staff/bookings/assign?bookingId=${booking.bookingId}"
                                               class="btn btn-success">
                                                <i class="bi bi-box-arrow-in-right me-1"></i>Check-in
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                                <c:if test="${booking.status == 'CheckedIn'}">
                                    <a href="${pageContext.request.contextPath}/staff/bookings/occupants?bookingId=${booking.bookingId}"
                                       class="btn btn-primary">
                                        <i class="bi bi-people me-1"></i>Quản lý khách
                                    </a>
                                    <c:choose>
                                        <c:when test="${isMultiRoom}">
                                            <form action="${pageContext.request.contextPath}/staff/bookings/checkout-all" method="post" style="display:inline;">
                                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                <button type="submit" class="btn btn-warning">
                                                    <i class="bi bi-box-arrow-right me-1"></i>Checkout tất cả
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/staff/bookings/checkout?bookingId=${booking.bookingId}"
                                               class="btn btn-warning">
                                                <i class="bi bi-box-arrow-right me-1"></i>Check-out
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
