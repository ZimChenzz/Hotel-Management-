<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gia hạn đặt phòng #${booking.bookingId} - Luxury Hotel</title>
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
                    <li class="breadcrumb-item text-white">Gia hạn</li>
                </ol>
            </nav>
            <h1 class="public-hero-title"><i class="bi bi-clock-history me-2"></i>Gia hạn đặt phòng</h1>
        </div>
    </section>

    <div class="container py-5">
        <c:if test="${not empty error}">
            <div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>${error}</div>
        </c:if>

        <div class="row g-4">
            <!-- Extension Form -->
            <div class="col-lg-7">
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-clock me-2"></i>Chọn thời gian gia hạn
                    </div>
                    <div class="card-body">
                        <!-- Current booking info -->
                        <div class="p-3 mb-4 rounded" style="background: var(--surface-hover);">
                            <div class="row">
                                <div class="col-6">
                                    <small class="text-muted">Phòng</small>
                                    <p class="mb-0 fw-semibold">${booking.room.roomType.typeName} - ${booking.room.roomNumber}</p>
                                </div>
                                <div class="col-6">
                                    <small class="text-muted">Trả phòng hiện tại</small>
                                    <p class="mb-0 fw-semibold">${booking.checkOutExpectedFormatted}</p>
                                </div>
                            </div>
                        </div>

                        <c:if test="${canExtend}">
                            <form method="get" action="${pageContext.request.contextPath}/booking/extension/calculate">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                <div class="mb-3">
                                    <label class="form-label fw-semibold">Số giờ gia hạn</label>
                                    <select name="hours" class="form-select" required>
                                        <option value="">-- Chọn số giờ --</option>
                                        <c:forEach var="h" begin="1" end="24">
                                            <option value="${h}" ${selectedHours == h ? 'selected' : ''}>${h} giờ</option>
                                        </c:forEach>
                                        <option value="36" ${selectedHours == 36 ? 'selected' : ''}>36 giờ (1.5 ngày)</option>
                                        <option value="48" ${selectedHours == 48 ? 'selected' : ''}>48 giờ (2 ngày)</option>
                                        <option value="72" ${selectedHours == 72 ? 'selected' : ''}>72 giờ (3 ngày)</option>
                                    </select>
                                    <div class="form-text">
                                        <= 12 giờ: tính giá theo giờ | > 12 giờ: tính giá theo đêm
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-outline-primary">
                                    <i class="bi bi-calculator me-1"></i>Tính giá
                                </button>
                            </form>
                        </c:if>
                        <c:if test="${!canExtend && empty error}">
                            <div class="alert alert-warning mb-0">
                                <i class="bi bi-exclamation-triangle me-2"></i>
                                Phòng đã có người đặt sau thời gian trả phòng, không thể gia hạn.
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Price Calculation Result -->
            <div class="col-lg-5">
                <c:if test="${calc != null}">
                    <div class="card" style="background: var(--primary-gradient); color: white;">
                        <div class="card-header" style="background: transparent; border-bottom: 1px solid rgba(255,255,255,0.1);">
                            <i class="bi bi-receipt me-2"></i>Chi tiết giá gia hạn
                        </div>
                        <div class="card-body">
                            <div class="mb-3 pb-3" style="border-bottom: 1px solid rgba(255,255,255,0.2);">
                                <div class="row">
                                    <div class="col-6">
                                        <small style="opacity: 0.75;">Trả phòng cũ</small>
                                        <p class="mb-0 fw-semibold">${calc.originalCheckOutFormatted}</p>
                                    </div>
                                    <div class="col-6">
                                        <small style="opacity: 0.75;">Trả phòng mới</small>
                                        <p class="mb-0 fw-semibold">${calc.newCheckOutFormatted}</p>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between py-2">
                                <span>Thời gian gia hạn</span>
                                <span>${calc.extraHours} giờ</span>
                            </div>
                            <div class="d-flex justify-content-between py-2">
                                <span>Cách tính</span>
                                <c:choose>
                                    <c:when test="${calc.hourlyRate}">
                                        <span>Theo giờ (<fmt:formatNumber value="${calc.pricePerHour}" type="number" groupingUsed="true"/>đ/h)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span>Theo đêm (<fmt:formatNumber value="${calc.basePrice}" type="number" groupingUsed="true"/>đ/đêm)</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="d-flex justify-content-between pt-3 mt-2" style="border-top: 1px solid rgba(255,255,255,0.2);">
                                <span class="h5 mb-0">Phí gia hạn</span>
                                <span class="h4 mb-0" style="color: var(--secondary);">
                                    <fmt:formatNumber value="${calc.extensionPrice}" type="number" groupingUsed="true"/>đ
                                </span>
                            </div>

                            <form method="post" action="${pageContext.request.contextPath}/booking/extension/confirm" class="mt-4">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                <input type="hidden" name="hours" value="${calc.extraHours}">
                                <button type="submit" class="btn btn-warning w-100">
                                    <i class="bi bi-check-circle me-2"></i>Xác nhận gia hạn và thanh toán
                                </button>
                            </form>
                        </div>
                    </div>
                </c:if>
                <c:if test="${calc == null}">
                    <div class="card">
                        <div class="card-body text-center text-muted py-5">
                            <i class="bi bi-calculator" style="font-size: 3rem;"></i>
                            <p class="mt-3 mb-0">Chọn số giờ gia hạn và nhấn "Tính giá" để xem chi tiết.</p>
                        </div>
                    </div>
                </c:if>

                <a href="${pageContext.request.contextPath}/booking/status?bookingId=${booking.bookingId}"
                   class="btn btn-outline-secondary w-100 mt-3">
                    <i class="bi bi-arrow-left me-2"></i>Quay lại
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
