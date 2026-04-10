<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sơ đồ phòng - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin-styles.css" rel="stylesheet">
    <style>
        .room-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
            gap: 1rem;
        }
        .room-map-card {
            aspect-ratio: 1;
            background: #fff;
            border-radius: 10px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: var(--hotel-navy, #1a1a2e);
            transition: all 0.2s ease;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border: 2px solid transparent;
        }
        .room-map-card:hover { transform: scale(1.05); box-shadow: 0 8px 20px rgba(0,0,0,0.1); }
        .room-map-card.available { border-color: #28a745; background: rgba(40,167,69,0.1); }
        .room-map-card.occupied { border-color: #dc3545; background: rgba(220,53,69,0.1); }
        .room-map-card.cleaning { border-color: #ffc107; background: rgba(255,193,7,0.1); }
        .room-map-card.maintenance { border-color: #6c757d; background: rgba(108,117,125,0.1); }
        .room-map-number { font-size: 1.25rem; font-weight: 700; }
        .room-map-status { font-size: 0.7rem; margin-top: 0.25rem; text-transform: uppercase; letter-spacing: 0.5px; }
    </style>
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="rooms-map" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Sơ đồ phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Breadcrumb -->
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rooms">Phòng</a></li>
                        <li class="breadcrumb-item active">Sơ đồ phòng</li>
                    </ol>
                </nav>

                <!-- Legend -->
                <div class="card mb-4">
                    <div class="card-body py-2">
                        <div class="d-flex flex-wrap gap-4 align-items-center">
                            <span class="fw-bold">Chú thích:</span>
                            <span><span class="badge bg-success me-1">&nbsp;</span> Trống</span>
                            <span><span class="badge bg-danger me-1">&nbsp;</span> Đang sử dụng</span>
                            <span><span class="badge bg-warning me-1">&nbsp;</span> Đang dọn</span>
                            <span><span class="badge bg-secondary me-1">&nbsp;</span> Bảo trì</span>
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
                                    <a href="${pageContext.request.contextPath}/admin/rooms/edit?id=${room.roomId}"
                                       class="room-map-card ${fn:toLowerCase(room.status)}"
                                       data-bs-toggle="tooltip"
                                       title="${room.roomType != null ? room.roomType.typeName : ''} - ${room.status}">
                                        <span class="room-map-number">${room.roomNumber}</span>
                                        <span class="room-map-status">
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

    <!-- Mobile Toggle -->
    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
    <script>
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function(el) { return new bootstrap.Tooltip(el); });
    </script>
</body>
</html>
