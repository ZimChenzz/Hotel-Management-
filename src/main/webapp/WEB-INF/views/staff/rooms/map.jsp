<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sơ đồ phòng - Cổng Nhân Viên</title>
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
            <c:set var="pageTitle" value="Sơ đồ phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Flash Messages -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="bi bi-check-circle me-2"></i>${sessionScope.successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="bi bi-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <!-- Legend -->
                <div class="card mb-4">
                    <div class="card-body py-2">
                        <div class="d-flex flex-wrap gap-4 align-items-center justify-content-between">
                            <div class="d-flex flex-wrap gap-4 align-items-center">
                                <span class="fw-bold">Chú thích:</span>
                                <span><span class="badge bg-success me-1">&nbsp;</span> Trống</span>
                                <span><span class="badge bg-danger me-1">&nbsp;</span> Đang sử dụng</span>
                                <span><span class="badge bg-warning me-1">&nbsp;</span> Đang dọn</span>
                                <span><span class="badge bg-secondary me-1">&nbsp;</span> Bảo trì</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/staff/rooms/reconcile"
                               class="btn btn-sm btn-outline-primary"
                               onclick="return confirm('Đồng bộ trạng thái phòng? Phòng nào đang ở nhưng không có khách sẽ được chuyển sang trạng thái dọn dẹp.')">
                                <i class="bi bi-arrow-repeat me-1"></i>Đồng bộ trạng thái
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Room Map by Floor -->
                <c:forEach var="floorEntry" items="${roomsByFloor}">
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0"><i class="bi bi-building me-2"></i>${floorEntry.key}</h5>
                        </div>
                        <div class="card-body">
                            <div class="room-grid">
                                <c:forEach var="room" items="${floorEntry.value}">
                                    <a href="${pageContext.request.contextPath}/staff/rooms/detail?id=${room.roomId}"
                                       class="room-card ${fn:toLowerCase(room.status)}"
                                       data-bs-toggle="tooltip"
                                       title="${room.roomType.typeName} - ${room.status}">
                                        <span class="room-number">${room.roomNumber}</span>
                                        <span class="room-status">
                                            <c:choose>
                                                <c:when test="${room.status == 'Available'}">Trống</c:when>
                                                <c:when test="${room.status == 'Occupied'}">Đang ở</c:when>
                                                <c:when test="${room.status == 'Cleaning'}">Dọn dẹp</c:when>
                                                <c:when test="${room.status == 'Maintenance'}">Bảo trì</c:when>
                                                <c:otherwise>${room.status}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </a>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty roomsByFloor}">
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle me-2"></i>Không có dữ liệu phòng.
                    </div>
                </c:if>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <script>
        // Initialize tooltips
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    </script>
</body>
</html>
