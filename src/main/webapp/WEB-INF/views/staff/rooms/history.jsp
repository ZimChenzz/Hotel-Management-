<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch sử phòng ${room.roomNumber} - Cổng Nhân Viên</title>
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
            <c:set var="pageTitle" value="Lịch sử phòng ${room.roomNumber}" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <div class="mb-3">
                    <a href="${pageContext.request.contextPath}/staff/rooms/detail?id=${room.roomId}"
                       class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại chi tiết phòng
                    </a>
                </div>

                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-clock-history me-2"></i>
                            Lịch sử sử dụng - Phòng ${room.roomNumber}
                            <span class="text-muted fw-normal fs-6 ms-2">
                                (${room.roomType != null ? room.roomType.typeName : ''})
                            </span>
                        </h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>#</th>
                                    <th>Tên khách</th>
                                    <th>Nhận phòng (DK)</th>
                                    <th>Trả phòng (DK)</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty bookings}">
                                        <tr>
                                            <td colspan="6" class="text-center py-5 text-muted">
                                                <i class="bi bi-clock-history fs-1 d-block mb-2"></i>
                                                Phòng này chưa có lịch sử đặt phòng.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="b" items="${bookings}" varStatus="s">
                                            <tr>
                                                <td>${s.index + 1}</td>
                                                <td>${b.customer != null ? b.customer.account.fullName : '-'}</td>
                                                <td>${b.checkInExpectedFormatted}</td>
                                                <td>${b.checkOutExpectedFormatted}</td>
                                                <td>
                                                    <fmt:formatNumber value="${b.totalPrice}" type="number" groupingUsed="true"/> VND
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${b.status == 'CheckedOut'}">
                                                            <span class="badge bg-success">Đã trả phòng</span>
                                                        </c:when>
                                                        <c:when test="${b.status == 'CheckedIn'}">
                                                            <span class="badge bg-danger">Đang ở</span>
                                                        </c:when>
                                                        <c:when test="${b.status == 'Confirmed'}">
                                                            <span class="badge bg-info text-dark">Đã xác nhận</span>
                                                        </c:when>
                                                        <c:when test="${b.status == 'Cancelled'}">
                                                            <span class="badge bg-secondary">Đã hủy</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">${b.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
