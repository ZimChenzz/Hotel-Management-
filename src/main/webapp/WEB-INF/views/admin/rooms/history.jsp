<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch sử phòng ${room.roomNumber} - Cổng Quản Trị</title>
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
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rooms">Phòng</a></li>
                        <li class="breadcrumb-item active">Lịch sử phòng ${room.roomNumber}</li>
                    </ol>
                </nav>

                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Lịch sử sử dụng - Phòng ${room.roomNumber}</h1>
                        <p class="page-header-subtitle">Loại phòng: ${room.roomType != null ? room.roomType.typeName : '-'}</p>
                    </div>
                    <div class="page-header-actions">
                        <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left me-1"></i> Quay lại
                        </a>
                    </div>
                </div>

                <div class="card">
                    <div class="table-responsive">
                        <table class="table-modern table-striped table-hover">
                            <thead>
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
                                            <td colspan="6">
                                                <div class="empty-state">
                                                    <div class="empty-state-icon">
                                                        <i class="bi bi-clock-history"></i>
                                                    </div>
                                                    <h3 class="empty-state-title">Chưa có lịch sử</h3>
                                                    <p class="empty-state-text">Phòng này chưa có đặt phòng nào.</p>
                                                </div>
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
                                                            <span class="badge badge-available">Đã trả phòng</span>
                                                        </c:when>
                                                        <c:when test="${b.status == 'CheckedIn'}">
                                                            <span class="badge badge-occupied">Đang ở</span>
                                                        </c:when>
                                                        <c:when test="${b.status == 'Confirmed'}">
                                                            <span class="badge bg-info text-dark">Đã xác nhận</span>
                                                        </c:when>
                                                        <c:when test="${b.status == 'Cancelled'}">
                                                            <span class="badge badge-cancelled">Đã hủy</span>
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
