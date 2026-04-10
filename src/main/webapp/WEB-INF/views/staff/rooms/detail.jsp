<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết phòng ${room.roomNumber} - Cổng Nhân Viên</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="rooms" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Chi tiết phòng ${room.roomNumber}" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <div class="mb-3">
                    <a href="${pageContext.request.contextPath}/staff/rooms" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại sơ đồ
                    </a>
                </div>

                <div class="row">
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">
                                    <i class="bi bi-door-open me-2"></i>Phòng ${room.roomNumber}
                                </h5>
                                <c:choose>
                                    <c:when test="${room.status == 'Available'}">
                                        <span class="badge bg-success">Trống</span>
                                    </c:when>
                                    <c:when test="${room.status == 'Occupied'}">
                                        <span class="badge bg-danger">Đang sử dụng</span>
                                    </c:when>
                                    <c:when test="${room.status == 'Cleaning'}">
                                        <span class="badge bg-warning text-dark">Đang dọn</span>
                                    </c:when>
                                    <c:when test="${room.status == 'Maintenance'}">
                                        <span class="badge bg-secondary">Bảo trì</span>
                                    </c:when>
                                </c:choose>
                            </div>
                            <c:if test="${not empty room.roomType.images}">
                                <div style="height:220px;overflow:hidden;">
                                    <img src="${pageContext.request.contextPath}${room.roomType.images[0].imageUrl}"
                                         alt="${room.roomType.typeName}"
                                         style="width:100%;height:100%;object-fit:cover;">
                                </div>
                            </c:if>
                            <div class="card-body">
                                <table class="table table-borderless mb-0">
                                    <tr>
                                        <th style="width: 40%">Số phòng:</th>
                                        <td>${room.roomNumber}</td>
                                    </tr>
                                    <tr>
                                        <th>Loại phòng:</th>
                                        <td>${room.roomType.typeName}</td>
                                    </tr>
                                    <tr>
                                        <th>Sức chứa:</th>
                                        <td>${room.roomType.capacity} người</td>
                                    </tr>
                                    <tr>
                                        <th>Giá cơ bản:</th>
                                        <td><fmt:formatNumber value="${room.roomType.basePrice}" type="currency" currencySymbol="" maxFractionDigits="0"/> VNĐ/đêm</td>
                                    </tr>
                                    <tr>
                                        <th>Trạng thái:</th>
                                        <td>
                                            <c:choose>
                                                <c:when test="${room.status == 'Available'}">Trống - Sẵn sàng đón khách</c:when>
                                                <c:when test="${room.status == 'Occupied'}">Đang có khách</c:when>
                                                <c:when test="${room.status == 'Cleaning'}">Đang dọn dẹp</c:when>
                                                <c:when test="${room.status == 'Maintenance'}">Đang bảo trì</c:when>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-6">
                        <div class="card mb-3">
                            <div class="card-body">
                                <a href="${pageContext.request.contextPath}/staff/rooms/history?id=${room.roomId}"
                                   class="btn btn-outline-primary w-100">
                                    <i class="bi bi-clock-history me-1"></i>Lịch sử sử dụng
                                </a>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="bi bi-gear me-2"></i>Thao tác</h5>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${room.status == 'Cleaning'}">
                                        <p class="text-muted mb-3">Phòng đang được dọn dẹp. Bạn có thể đánh dấu hoàn thành khi đã dọn xong.</p>
                                        <form action="${pageContext.request.contextPath}/staff/cleaning/update" method="post">
                                            <input type="hidden" name="roomId" value="${room.roomId}">
                                            <input type="hidden" name="status" value="Available">
                                            <button type="submit" class="btn btn-success">
                                                <i class="bi bi-check-circle me-1"></i>Đánh dấu đã dọn xong
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:when test="${room.status == 'Available'}">
                                        <p class="text-muted mb-3">Phòng đang trống và sẵn sàng đón khách.</p>
                                        <a href="${pageContext.request.contextPath}/staff/bookings?status=Confirmed" class="btn btn-staff-primary">
                                            <i class="bi bi-calendar-check me-1"></i>Xem booking chờ check-in
                                        </a>
                                    </c:when>
                                    <c:when test="${room.status == 'Occupied'}">
                                        <p class="text-muted mb-3">Phòng đang có khách sử dụng.</p>
                                        <a href="${pageContext.request.contextPath}/staff/bookings?status=CheckedIn" class="btn btn-staff-outline">
                                            <i class="bi bi-box-arrow-right me-1"></i>Xem booking đang ở
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted">Không có thao tác khả dụng cho trạng thái hiện tại.</p>
                                    </c:otherwise>
                                </c:choose>
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
