<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt phòng - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .booking-hero {
            background: var(--primary-gradient);
            padding: 3rem 0;
            margin-bottom: 2rem;
        }
        .step-indicator {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 2rem;
        }
        .step-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .step-number {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 0.875rem;
        }
        .step-active .step-number {
            background: var(--primary);
            color: white;
        }
        .step-inactive .step-number {
            background: var(--border-color);
            color: var(--text-muted);
        }
        .step-line {
            width: 60px;
            height: 2px;
            background: var(--border-color);
        }
        .step-active + .step-line,
        .step-active ~ .step-inactive .step-line {
            background: var(--primary);
        }
        .info-card {
            background: var(--surface-hover);
            border-radius: 0.75rem;
            padding: 1.25rem;
            margin-bottom: 1.5rem;
        }
        .info-card i {
            color: var(--secondary);
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Hero Section -->
    <section class="booking-hero">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-2" style="--bs-breadcrumb-divider-color: rgba(255,255,255,0.5);">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/" style="color: rgba(255,255,255,0.7);">Trang chủ</a></li>
                    <li class="breadcrumb-item text-white">Đặt phòng</li>
                </ol>
            </nav>
            <h1 class="public-hero-title"><i class="bi bi-calendar-plus me-2"></i>Đặt phòng mới</h1>
        </div>
    </section>

    <div class="container py-4">
        <!-- Step Indicator -->
        <div class="step-indicator">
            <div class="step-item step-active">
                <span class="step-number">1</span>
                <span>Chọn ngày</span>
            </div>
            <div class="step-line"></div>
            <div class="step-item step-inactive">
                <span class="step-number">2</span>
                <span>Chọn phòng</span>
            </div>
            <div class="step-line"></div>
            <div class="step-item step-inactive">
                <span class="step-number">3</span>
                <span>Xác nhận</span>
            </div>
        </div>

        <div class="row justify-content-center">
            <div class="col-lg-8">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger mb-4">
                        <i class="bi bi-exclamation-triangle me-2"></i>${error}
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/booking/start" class="card">
                    <div class="card-body p-4">
                        <h5 class="card-title mb-4" style="font-family: var(--font-display); color: var(--primary);">
                            <i class="bi bi-calendar-event me-2"></i>Thông tin thời gian
                        </h5>

                        <div class="row g-4">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Ngày nhận phòng <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-calendar-check"></i></span>
                                    <input type="date" name="checkInDate" class="form-control"
                                           value="${checkInDate}" min="${minDate}" max="${maxDate}" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Giờ nhận phòng <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-clock"></i></span>
                                    <input type="time" name="checkInTime" class="form-control" value="${checkInTime != null ? checkInTime : '14:00'}" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Ngày trả phòng <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-calendar-x"></i></span>
                                    <input type="date" name="checkOutDate" class="form-control"
                                           value="${checkOutDate}" min="${minDate}" max="${maxDate}" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Giờ trả phòng <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-clock-fill"></i></span>
                                    <input type="time" name="checkOutTime" class="form-control" value="${checkOutTime != null ? checkOutTime : '12:00'}" required>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card-body pt-0">
                        <!-- Surcharge Info -->
                        <div class="info-card">
                            <div class="d-flex align-items-start">
                                <i class="bi bi-info-circle fs-4 me-3 mt-1"></i>
                                <div>
                                    <h6 class="mb-2">Thông tin về giờ nhận/trả phòng</h6>
                                    <ul class="mb-0 ps-3 text-muted small">
                                        <li><strong>Giờ nhận phòng tiêu chuẩn:</strong> 14:00</li>
                                        <li><strong>Giờ trả phòng tiêu chuẩn:</strong> 12:00</li>
                                        <li><strong>Phụ thu sớm check-in:</strong> 50% giá phòng/giờ (trước 14:00)</li>
                                        <li><strong>Phụ thu trả muộn:</strong> 50% giá phòng/giờ (sau 12:00)</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end gap-3 mt-4">
                            <a href="${pageContext.request.contextPath}/" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-1"></i>Quay lại
                            </a>
                            <button type="submit" class="btn btn-primary">
                                Tiếp tục <i class="bi bi-arrow-right ms-1"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
