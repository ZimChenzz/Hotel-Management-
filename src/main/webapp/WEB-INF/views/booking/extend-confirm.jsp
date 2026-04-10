<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Xác nhận gia hạn - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <section class="public-hero public-hero-small">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-2" style="--bs-breadcrumb-divider-color: rgba(255,255,255,0.5);">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/" style="color: rgba(255,255,255,0.7);">Trang chủ</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/bookings" style="color: rgba(255,255,255,0.7);">Đặt phòng của tôi</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/booking/status?bookingId=${booking.bookingId}" style="color: rgba(255,255,255,0.7);">Đơn #${booking.bookingId}</a></li>
                    <li class="breadcrumb-item text-white">Xác nhận gia hạn</li>
                </ol>
            </nav>
            <h1 class="public-hero-title"><i class="bi bi-check-circle me-2"></i>Xác nhận gia hạn</h1>
        </div>
    </section>

    <div class="container py-5">
        <c:if test="${not empty error}">
            <div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>${error}</div>
        </c:if>

        <div class="row g-4 justify-content-center">
            <div class="col-lg-6">
                <div class="card" style="background: var(--primary-gradient); color: white;">
                    <div class="card-header" style="background: transparent; border-bottom: 1px solid rgba(255,255,255,0.1);">
                        <i class="bi bi-receipt me-2"></i>Chi tiết gia hạn
                    </div>
                    <div class="card-body">
                        <!-- Room info -->
                        <div class="mb-3 pb-3" style="border-bottom: 1px solid rgba(255,255,255,0.2);">
                            <small style="opacity: 0.75;">Phòng</small>
                            <p class="mb-0 fw-semibold">${booking.room.roomType.typeName} - ${booking.room.roomNumber}</p>
                        </div>

                        <!-- Time details -->
                        <div class="row mb-3 pb-3" style="border-bottom: 1px solid rgba(255,255,255,0.2);">
                            <div class="col-6">
                                <small style="opacity: 0.75;">Trả phòng cũ</small>
                                <p class="mb-0 fw-semibold">${extensionCalc.originalCheckOutFormatted}</p>
                            </div>
                            <div class="col-6">
                                <small style="opacity: 0.75;">Trả phòng mới</small>
                                <p class="mb-0 fw-semibold" style="color: var(--secondary-light);">${extensionCalc.newCheckOutFormatted}</p>
                            </div>
                        </div>

                        <!-- Pricing -->
                        <div class="d-flex justify-content-between py-2">
                            <span>Thời gian gia hạn</span>
                            <span>${extensionCalc.extraHours} giờ</span>
                        </div>
                        <div class="d-flex justify-content-between py-2">
                            <span>Cách tính</span>
                            <c:choose>
                                <c:when test="${extensionCalc.hourlyRate}">
                                    <span>Theo giờ (<fmt:formatNumber value="${extensionCalc.pricePerHour}" type="number" groupingUsed="true"/>đ/h)</span>
                                </c:when>
                                <c:otherwise>
                                    <span>Theo đêm (<fmt:formatNumber value="${extensionCalc.basePrice}" type="number" groupingUsed="true"/>đ/đêm)</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="d-flex justify-content-between pt-3 mt-2" style="border-top: 1px solid rgba(255,255,255,0.2);">
                            <span class="h5 mb-0">Phí gia hạn</span>
                            <span class="h4 mb-0" style="color: var(--secondary);">
                                <fmt:formatNumber value="${extensionCalc.extensionPrice}" type="number" groupingUsed="true"/>đ
                            </span>
                        </div>
                        <div class="d-flex justify-content-between py-1" style="opacity: 0.8;">
                            <small>+ VAT 10%</small>
                            <small>
                                <fmt:formatNumber value="${extensionCalc.extensionPrice * 0.1}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            </small>
                        </div>

                        <!-- Confirm form -->
                        <form method="post" action="${pageContext.request.contextPath}/booking/extend/confirm" class="mt-4">
                            <button type="submit" class="btn btn-warning w-100 btn-lg">
                                <i class="bi bi-credit-card me-2"></i>Xác nhận và thanh toán
                            </button>
                        </form>

                        <a href="${pageContext.request.contextPath}/booking/extend?bookingId=${booking.bookingId}"
                           class="btn btn-outline-light w-100 mt-2">
                            <i class="bi bi-arrow-left me-2"></i>Quay lại chọn lại
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
