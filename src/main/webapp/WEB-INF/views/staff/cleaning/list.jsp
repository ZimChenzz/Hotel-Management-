<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý dọn phòng - Cổng Nhân Viên</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="cleaning" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý dọn phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="bi bi-check-circle me-2"></i>${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="bi bi-exclamation-circle me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Summary Card -->
                <div class="row mb-4">
                    <div class="col-md-4">
                        <div class="stat-card">
                            <div class="stat-icon cleaning">
                                <i class="bi bi-stars"></i>
                            </div>
                            <div class="stat-value">${rooms.size()}</div>
                            <div class="stat-label">Phòng cần dọn</div>
                        </div>
                    </div>
                </div>

                <!-- Cleaning List -->
                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="bi bi-stars me-2"></i>Danh sách phòng cần dọn</h5>
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${not empty rooms}">
                                <div class="row g-4">
                                    <c:forEach var="room" items="${rooms}">
                                        <div class="col-md-6 col-lg-4">
                                            <div class="card h-100 border-warning">
                                                <div class="card-body">
                                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                                        <div>
                                                            <h4 class="mb-1">${room.roomNumber}</h4>
                                                            <c:choose>
                                                                <c:when test="${room.isAssigned()}">
                                                                    <span class="badge bg-info">Đã nhận</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-warning text-dark">Chưa nhận</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <i class="bi bi-door-open fs-2 text-warning"></i>
                                                    </div>

                                                    <c:if test="${not empty room.room.roomType}">
                                                        <p class="text-muted mb-1">
                                                            <i class="bi bi-building me-1"></i>${room.room.roomType.typeName}
                                                        </p>
                                                    </c:if>

                                                    <c:if test="${not empty room.bookingId}">
                                                        <p class="text-muted mb-1">
                                                            <i class="bi bi-hash me-1"></i>Booking #${room.bookingId}
                                                        </p>
                                                    </c:if>

                                                    <c:if test="${room.isAssigned()}">
                                                        <p class="text-muted mb-1">
                                                            <i class="bi bi-person me-1"></i>Nhân viên: ${room.staffName}
                                                        </p>
                                                    </c:if>

                                                    <c:if test="${not empty room.cleaningDescription}">
                                                        <div class="alert alert-light border mb-3">
                                                            <small class="text-muted d-block mb-1">
                                                                <i class="bi bi-info-circle me-1"></i>Mô tả:
                                                            </small>
                                                            <span>${room.cleaningDescription}</span>
                                                        </div>
                                                    </c:if>

                                                    <c:choose>
                                                        <c:when test="${room.isAssigned()}">
                                                            <form action="${pageContext.request.contextPath}/staff/cleaning/update" method="post">
                                                                <input type="hidden" name="roomId" value="${room.room.roomId}">
                                                                <input type="hidden" name="status" value="Available">
                                                                <button type="submit" class="btn btn-success w-100">
                                                                    <i class="bi bi-check-circle me-1"></i>Đánh dấu đã dọn xong
                                                                </button>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form action="${pageContext.request.contextPath}/staff/cleaning/accept" method="post">
                                                                <input type="hidden" name="roomId" value="${room.room.roomId}">
                                                                <button type="submit" class="btn btn-primary w-100">
                                                                    <i class="bi bi-hand-index me-1"></i>Nhận yêu cầu
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="bi bi-emoji-smile fs-1 text-success mb-3 d-block"></i>
                                    <h5 class="text-muted">Không có phòng nào cần dọn!</h5>
                                    <p class="text-muted">Tất cả các phòng đã được dọn dẹp sạch sẽ.</p>
                                    <a href="${pageContext.request.contextPath}/staff/rooms" class="btn btn-outline-primary mt-2">
                                        <i class="bi bi-door-open me-1"></i>Xem sơ đồ phòng
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
