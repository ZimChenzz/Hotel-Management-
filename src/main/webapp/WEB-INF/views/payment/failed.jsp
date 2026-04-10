<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán thất bại - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .failed-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, var(--danger) 0%, #c82333 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 3rem;
            color: #fff;
            animation: shake 0.5s ease-out;
        }
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            20%, 60% { transform: translateX(-8px); }
            40%, 80% { transform: translateX(8px); }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <div class="container py-5">
        <div class="card mx-auto" style="max-width: 500px;">
            <div class="card-body text-center p-5">
                <div class="failed-icon">
                    <i class="bi bi-x-lg"></i>
                </div>
                <h2 class="mb-2 text-danger" style="font-family: var(--font-display);">Thanh toán thất bại</h2>
                <p class="text-muted">Giao dịch không thành công. Vui lòng thử lại.</p>

                <div class="rounded p-3 my-4 text-start" style="background: var(--surface-hover);">
                    <div class="d-flex justify-content-between py-2">
                        <span class="text-muted">Mã giao dịch</span>
                        <span class="fw-semibold">${payment.transactionCode}</span>
                    </div>
                    <div class="d-flex justify-content-between py-2 align-items-center">
                        <span class="text-muted">Trạng thái</span>
                        <span class="badge badge-cancelled">Thất bại</span>
                    </div>
                </div>

                <div class="alert alert-warning text-start mb-4">
                    <h6 class="alert-heading"><i class="bi bi-lightbulb me-2"></i>Một số lý do có thể:</h6>
                    <ul class="mb-0 ps-3">
                        <li>Số dư tài khoản không đủ</li>
                        <li>Thẻ hết hạn hoặc bị khóa</li>
                        <li>Thông tin thẻ không chính xác</li>
                        <li>Giao dịch bị hủy bởi người dùng</li>
                    </ul>
                </div>

                <a href="${pageContext.request.contextPath}/payment/process?bookingId=${booking.bookingId}"
                   class="btn btn-primary w-100 mb-2">
                    <i class="bi bi-arrow-clockwise me-2"></i>Thử lại
                </a>
                <a href="${pageContext.request.contextPath}/customer/bookings" class="btn btn-outline-secondary w-100">
                    Xem đơn đặt phòng
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
