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
                            <form method="post" action="${pageContext.request.contextPath}/booking/extend">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                <div class="mb-3">
                                    <label class="form-label fw-semibold">Số giờ gia hạn</label>
                                    <select name="extraHours" class="form-select" required>
                                        <option value="">-- Chọn số giờ --</option>
                                        <c:forEach var="h" begin="1" end="24">
                                            <option value="${h}">${h} giờ</option>
                                        </c:forEach>
                                        <option value="36">36 giờ (1.5 ngày)</option>
                                        <option value="48">48 giờ (2 ngày)</option>
                                        <option value="72">72 giờ (3 ngày)</option>
                                    </select>
                                    <div class="form-text">
                                        &lt;= 12 giờ: tính giá theo giờ | &gt; 12 giờ: tính giá theo đêm
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-calculator me-1"></i>Tính giá và tiếp tục
                                </button>
                            </form>
                        </c:if>
                        <c:if test="${!canExtend}">
                            <div class="alert alert-warning mb-0">
                                <i class="bi bi-exclamation-triangle me-2"></i>${canExtendMessage}
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Extension History -->
                <c:if test="${not empty extensions}">
                    <div class="card mt-4">
                        <div class="card-header">
                            <i class="bi bi-list-check me-2"></i>Lịch sử gia hạn
                        </div>
                        <div class="card-body p-0">
                            <table class="table table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>Thời gian</th>
                                        <th>Số giờ</th>
                                        <th>Giá</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="ext" items="${extensions}">
                                        <tr>
                                            <td>${ext.createdAtFormatted}</td>
                                            <td>${ext.extensionHours} giờ</td>
                                            <td><fmt:formatNumber value="${ext.extensionPrice}" type="number" groupingUsed="true"/>đ</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${ext.status == 'Confirmed'}">
                                                        <span class="badge bg-success">Đã xác nhận</span>
                                                    </c:when>
                                                    <c:when test="${ext.status == 'Pending'}">
                                                        <span class="badge bg-warning text-dark">Chờ thanh toán</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${ext.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:if>
            </div>

            <!-- Sidebar Info -->
            <div class="col-lg-5">
                <div class="card mb-3">
                    <div class="card-body text-center text-muted py-5">
                        <i class="bi bi-calculator" style="font-size: 3rem;"></i>
                        <p class="mt-3 mb-0">Chọn số giờ gia hạn và nhấn "Tính giá và tiếp tục" để xem chi tiết.</p>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/booking/status?bookingId=${booking.bookingId}"
                   class="btn btn-outline-secondary w-100">
                    <i class="bi bi-arrow-left me-2"></i>Quay lại
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
