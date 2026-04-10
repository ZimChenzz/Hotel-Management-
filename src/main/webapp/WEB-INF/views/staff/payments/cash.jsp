<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán tiền mặt - Cổng Nhân Viên</title>
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
            <c:set var="pageTitle" value="Thanh toán tiền mặt" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <div class="mb-3">
                    <a href="${pageContext.request.contextPath}/staff/payments/process?bookingId=${booking.bookingId}" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại
                    </a>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <div class="row justify-content-center">
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="bi bi-cash-stack me-2"></i>Thanh toán tiền mặt</h5>
                            </div>
                            <div class="card-body">
                                <div class="text-center mb-4">
                                    <p class="text-muted mb-1">Số tiền cần thu</p>
                                    <p class="fs-1 fw-bold text-success mb-0">
                                        <fmt:formatNumber value="${invoice.totalAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                    </p>
                                </div>

                                <form action="${pageContext.request.contextPath}/staff/payments/cash" method="post">
                                    <input type="hidden" name="invoiceId" value="${invoice.invoiceId}">
                                    <input type="hidden" name="customerId" value="${booking.customerId}">
                                    <input type="hidden" name="amount" value="${invoice.totalAmount}">

                                    <div class="mb-3">
                                        <label class="form-label">Hóa đơn</label>
                                        <input type="text" class="form-control" value="#${invoice.invoiceId}" readonly>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Booking</label>
                                        <input type="text" class="form-control" value="#${booking.bookingId} - Phòng ${booking.room.roomNumber}" readonly>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label">Số tiền nhận</label>
                                        <div class="input-group">
                                            <input type="text" class="form-control form-control-lg"
                                                   value="<fmt:formatNumber value="${invoice.totalAmount}" type="number" maxFractionDigits="0"/>"
                                                   readonly>
                                            <span class="input-group-text">VNĐ</span>
                                        </div>
                                    </div>

                                    <div class="alert alert-info">
                                        <i class="bi bi-info-circle me-2"></i>
                                        Vui lòng kiểm tra lại số tiền trước khi xác nhận thanh toán.
                                    </div>

                                    <button type="submit" class="btn btn-success btn-lg w-100">
                                        <i class="bi bi-check-circle me-2"></i>Xác nhận đã nhận tiền
                                    </button>
                                </form>
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
