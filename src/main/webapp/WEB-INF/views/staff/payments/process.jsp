<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán - Cổng Nhân Viên</title>
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
            <c:set var="pageTitle" value="Thanh toán" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <div class="mb-3">
                    <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại
                    </a>
                </div>

                <c:if test="${isPaid}">
                    <div class="alert alert-success">
                        <i class="bi bi-check-circle me-2"></i>Booking này đã được thanh toán!
                        <a href="${pageContext.request.contextPath}/staff/payments/success?invoiceId=${invoice.invoiceId}" class="alert-link">Xem chi tiết</a>
                    </div>
                </c:if>

                <div class="row">
                    <!-- Invoice Summary -->
                    <div class="col-lg-5">
                        <div class="card mb-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="bi bi-receipt me-2"></i>Hóa đơn #${invoice.invoiceId}</h5>
                                <c:if test="${invoice.invoiceType == 'Remaining'}">
                                    <span class="badge bg-warning text-dark ms-2">Thanh toán còn lại</span>
                                </c:if>
                                <c:if test="${invoice.invoiceType == 'Booking'}">
                                    <span class="badge bg-info ms-2">Tiền cọc</span>
                                </c:if>
                            </div>
                            <div class="card-body">
                                <table class="table table-borderless mb-0">
                                    <tr>
                                        <td>Mã booking:</td>
                                        <td class="text-end"><strong>#${booking.bookingId}</strong></td>
                                    </tr>
                                    <tr>
                                        <td>Phòng:</td>
                                        <td class="text-end">
                                            <c:choose>
                                                <c:when test="${not empty booking.room}">
                                                    ${booking.room.roomNumber} - ${booking.room.roomType.typeName}
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">Nhiều phòng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Ngày lập:</td>
                                        <td class="text-end">
                                            <fmt:parseDate value="${invoice.issuedDate}" pattern="yyyy-MM-dd'T'HH:mm" var="issuedDate"/>
                                            <fmt:formatDate value="${issuedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                    </tr>

                                    <c:choose>
                                        <c:when test="${invoice.invoiceType == 'Booking' && booking.paymentType == 'Deposit'}">
                                            <%-- Deposit invoice: show full breakdown --%>
                                            <tr>
                                                <td>Tiền phòng:</td>
                                                <td class="text-end">
                                                    <fmt:formatNumber value="${booking.totalPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                </td>
                                            </tr>
                                            <c:if test="${surcharge != null && surcharge.surchargeTotal > 0}">
                                                <tr class="text-muted">
                                                    <td><i class="bi bi-clock me-1"></i>Phí check-in sớm/check-out muộn:</td>
                                                    <td class="text-end">
                                                        + <fmt:formatNumber value="${surcharge.surchargeTotal}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                    </td>
                                                </tr>
                                            </c:if>
                                            <c:if test="${booking.depositAmount != null}">
                                                <tr>
                                                    <td>Tiền cọc:</td>
                                                    <td class="text-end text-success">
                                                        - <fmt:formatNumber value="${booking.depositAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                    </td>
                                                </tr>
                                            </c:if>
                                            <tr class="border-top">
                                                <td><strong>Tổng cộng:</strong></td>
                                                <td class="text-end">
                                                    <span class="fs-4 fw-bold text-success">
                                                        <fmt:formatNumber value="${invoice.totalAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                    </span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" class="text-muted small">
                                                    <i class="bi bi-info-circle me-1"></i>
                                                    Đây là số tiền cọc. Số tiền còn lại sẽ được thu khi check-out.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <%-- Remaining or other invoices: show full breakdown --%>
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
                                                <tr>
                                                    <td>Đã cọc trước:</td>
                                                    <td class="text-end text-success">
                                                        - <fmt:formatNumber value="${booking.depositAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                    </td>
                                                </tr>
                                            </c:if>
                                            <tr class="border-top">
                                                <td><strong>Tổng cộng:</strong></td>
                                                <td class="text-end">
                                                    <span class="fs-4 fw-bold text-success">
                                                        <fmt:formatNumber value="${invoice.totalAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Methods -->
                    <div class="col-lg-7">
                        <div class="card">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="bi bi-credit-card me-2"></i>Chọn phương thức thanh toán</h5>
                            </div>
                            <div class="card-body">
                                <c:if test="${not isPaid}">
                                    <div class="row g-4">
                                        <div class="col-md-6">
                                            <a href="${pageContext.request.contextPath}/staff/payments/cash?invoiceId=${invoice.invoiceId}"
                                               class="card h-100 text-decoration-none border-2 payment-method-card">
                                                <div class="card-body text-center py-4">
                                                    <i class="bi bi-cash-stack fs-1 text-success mb-3 d-block"></i>
                                                    <h5 class="card-title">Tiền mặt</h5>
                                                    <p class="card-text text-muted small">Nhận tiền mặt trực tiếp từ khách</p>
                                                </div>
                                            </a>
                                        </div>
                                        <div class="col-md-6">
                                            <a href="${pageContext.request.contextPath}/staff/payments/vnpay?invoiceId=${invoice.invoiceId}"
                                               class="card h-100 text-decoration-none border-2 payment-method-card">
                                                <div class="card-body text-center py-4">
                                                    <img src="https://vnpay.vn/s1/statics.vnpay.vn/2023/6/0oxhzjmxbksr1686814746087.png"
                                                         alt="VNPay" style="height: 48px;" class="mb-3">
                                                    <h5 class="card-title">VNPay</h5>
                                                    <p class="card-text text-muted small">Thanh toán qua cổng VNPay - ATM/Visa/QR</p>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </c:if>
                                <c:if test="${isPaid}">
                                    <div class="text-center py-4">
                                        <i class="bi bi-check-circle fs-1 text-success mb-3 d-block"></i>
                                        <h5>Đã thanh toán thành công</h5>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <style>
        .payment-method-card {
            transition: all 0.2s ease;
        }
        .payment-method-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            border-color: var(--hotel-gold) !important;
        }
    </style>
</body>
</html>
