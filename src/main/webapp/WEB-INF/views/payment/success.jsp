<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán thành công - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .success-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, var(--success) 0%, #20c997 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 3rem;
            color: #fff;
            animation: scaleIn 0.5s ease-out, pulse 2s infinite 0.5s;
        }
        @keyframes scaleIn {
            from { transform: scale(0); }
            to { transform: scale(1); }
        }
        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 0 0 rgba(25,135,84,0.4); }
            50% { box-shadow: 0 0 0 20px rgba(25,135,84,0); }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <div class="container py-5">
        <div class="card mx-auto" style="max-width: 500px;">
            <div class="card-body text-center p-5">
                <div class="success-icon">
                    <i class="bi bi-check-lg"></i>
                </div>
                <h2 class="mb-2 text-success" style="font-family: var(--font-display);">Thanh toán thành công!</h2>
                <p class="text-muted">Cảm ơn bạn đã đặt phòng tại Luxury Hotel.</p>

                <div class="rounded p-3 my-4 text-start" style="background: var(--surface-hover);">
                    <div class="d-flex justify-content-between py-2">
                        <span class="text-muted">Mã giao dịch</span>
                        <span class="fw-semibold">${payment.transactionCode}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2">
                        <span class="text-muted">Số tiền</span>
                        <span class="fw-bold text-success">
                            <fmt:formatNumber value="${payment.amount}" type="number" groupingUsed="true"/>đ
                        </span>
                    </div>
                    <div class="d-flex justify-content-between py-2">
                        <span class="text-muted">Phương thức</span>
                        <span class="fw-semibold">${payment.paymentMethod}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2 align-items-center">
                        <span class="text-muted">Trạng thái</span>
                        <span class="badge badge-completed">Thành công</span>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/booking/status?bookingId=${booking.bookingId}"
                   class="btn btn-primary w-100 mb-2">
                    <i class="bi bi-eye me-2"></i>Xem chi tiết đặt phòng
                </a>
                <a href="${pageContext.request.contextPath}/customer/bookings" class="btn btn-outline-secondary w-100 mb-2">
                    Danh sách đặt phòng
                </a>
                <a href="${pageContext.request.contextPath}/" class="btn btn-link text-muted">
                    <i class="bi bi-house me-1"></i>Về trang chủ
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
