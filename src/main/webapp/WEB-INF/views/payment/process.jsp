<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán - Luxury Hotel</title>
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
            <h1 class="public-hero-title"><i class="bi bi-credit-card me-2"></i>Thanh toán</h1>
        </div>
    </section>

    <div class="container py-5">
        <c:if test="${not empty error}">
            <div class="alert alert-danger mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>${error}
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.paymentError}">
            <div class="alert alert-danger mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>${sessionScope.paymentError}
            </div>
            <c:remove var="paymentError" scope="session"/>
        </c:if>

        <div class="row g-4">
            <div class="col-lg-7">
                <!-- Invoice Details -->
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="bi bi-receipt me-2"></i>Hóa đơn #${invoice.invoiceId}
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-borderless mb-0">
                            <tbody>
                                <tr>
                                    <td class="text-muted">Phòng</td>
                                    <td class="text-end fw-semibold">${booking.room.roomType.typeName}</td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Số phòng</td>
                                    <td class="text-end">${booking.room.roomNumber}</td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Tiền phòng</td>
                                    <td class="text-end"><fmt:formatNumber value="${booking.totalPrice}" type="number" groupingUsed="true"/>đ</td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Thuế VAT (10%)</td>
                                    <td class="text-end"><fmt:formatNumber value="${invoice.taxAmount}" type="number" groupingUsed="true"/>đ</td>
                                </tr>
                                <tr class="border-top">
                                    <td class="fw-bold fs-5 pt-3">Tổng cộng</td>
                                    <td class="text-end pt-3">
                                        <span class="fs-4 fw-bold" style="color: var(--secondary-dark);">
                                            <fmt:formatNumber value="${invoice.totalAmount}" type="number" groupingUsed="true"/>đ
                                        </span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Payment Method -->
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-wallet2 me-2"></i>Phương thức thanh toán
                    </div>
                    <div class="card-body">
                        <!-- Payment Method: VNPay -->
                        <form method="post" action="${pageContext.request.contextPath}/payment/vnpay">
                            <input type="hidden" name="invoiceId" value="${invoice.invoiceId}">

                            <div class="p-3 mb-3 rounded" style="border: 2px solid var(--secondary); background: var(--surface-hover);">
                                <div class="d-flex align-items-center">
                                    <input class="form-check-input me-3" type="radio" name="method" value="vnpay" checked>
                                    <img src="https://vnpay.vn/s1/statics.vnpay.vn/2023/6/0oxhzjmxbksr1686814746087.png"
                                         alt="VNPay" style="height: 40px;" class="me-3">
                                    <div>
                                        <strong>VNPay</strong>
                                        <p class="text-muted mb-0 small">Thanh toán qua cổng VNPay - Hỗ trợ ATM/Visa/Master/QR</p>
                                    </div>
                                </div>
                            </div>

                            <div class="alert alert-info mb-4">
                                <p class="mb-2"><i class="bi bi-info-circle me-2"></i><strong>Sandbox Mode:</strong> Sử dụng thẻ test NCB:</p>
                                <p class="mb-1 small">Số thẻ: <code>9704198526191432198</code></p>
                                <p class="mb-0 small">Tên: <code>NGUYEN VAN A</code> | Ngày: <code>07/15</code> | OTP: <code>123456</code></p>
                            </div>

                            <button type="submit" class="btn btn-primary btn-lg w-100">
                                <i class="bi bi-shield-lock me-2"></i>
                                Thanh toán VNPay <fmt:formatNumber value="${invoice.totalAmount}" type="number" groupingUsed="true"/>đ
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Booking Summary -->
            <div class="col-lg-5">
                <div class="card mb-4" style="background: var(--primary-gradient); color: white;">
                    <div class="card-header" style="border-bottom: 1px solid rgba(255,255,255,0.1); background: transparent;">
                        <i class="bi bi-calendar-check me-2"></i>Chi tiết đặt phòng
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <small style="opacity: 0.7;">Mã đặt phòng</small>
                            <p class="h5 mb-0" style="color: var(--secondary-light);">#${booking.bookingId}</p>
                        </div>
                        <div class="mb-3">
                            <small style="opacity: 0.7;">Ngày nhận phòng</small>
                            <p class="mb-0 fw-medium">${booking.checkInExpectedFormatted}</p>
                        </div>
                        <div class="mb-3">
                            <small style="opacity: 0.7;">Ngày trả phòng</small>
                            <p class="mb-0 fw-medium">${booking.checkOutExpectedFormatted}</p>
                        </div>
                        <hr style="border-color: rgba(255,255,255,0.2);">
                        <div class="d-flex justify-content-between align-items-center">
                            <span>Trạng thái</span>
                            <span class="badge badge-pending">Chờ thanh toán</span>
                        </div>
                    </div>
                </div>

                <div class="card" style="background: rgba(25, 135, 84, 0.1); border: 1px solid rgba(25, 135, 84, 0.2);">
                    <div class="card-body">
                        <h6 class="mb-2"><i class="bi bi-shield-check me-2 text-success"></i>Thanh toán an toàn</h6>
                        <p class="small text-muted mb-0">Giao dịch được bảo mật bởi VNPay với tiêu chuẩn PCI DSS.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
