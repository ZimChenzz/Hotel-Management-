<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bảng điều khiển - Cổng Nhân Viên</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="dashboard" scope="request"/>
        <jsp:include page="includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Bảng điều khiển" scope="request"/>
            <jsp:include page="includes/header.jsp" />

            <div class="app-content">
                <!-- Breadcrumb -->
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item active">Bảng điều khiển</li>
                    </ol>
                </nav>

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Xin chào, ${sessionScope.loggedInAccount.fullName}!</h1>
                        <p class="page-header-subtitle">Tổng quan hoạt động khách sạn hôm nay.</p>
                    </div>
                </div>

                <!-- Stats Row -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6 col-lg-3">
                        <div class="card-stat">
                            <div class="card-stat-icon rooms">
                                <i class="bi bi-door-open"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${roomsAvailable}</div>
                                <div class="card-stat-label">Phòng trống</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <div class="card-stat">
                            <div class="card-stat-icon bookings">
                                <i class="bi bi-calendar-check"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${roomsOccupied}</div>
                                <div class="card-stat-label">Phòng đang sử dụng</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <div class="card-stat">
                            <div class="card-stat-icon cleaning">
                                <i class="bi bi-stars"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${roomsCleaning}</div>
                                <div class="card-stat-label">Phòng cần dọn</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <div class="card-stat">
                            <div class="card-stat-icon revenue">
                                <i class="bi bi-box-arrow-in-right"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${pendingCheckins}</div>
                                <div class="card-stat-label">Chờ check-in</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions & Info -->
                <div class="row g-4">
                    <div class="col-lg-6">
                        <div class="card h-100">
                            <div class="card-header">
                                <i class="bi bi-lightning me-2"></i>Thao tác nhanh
                            </div>
                            <div class="card-body">
                                <div class="d-flex flex-column gap-3">
                                    <a href="${pageContext.request.contextPath}/staff/rooms" class="d-flex align-items-center gap-3 p-3 rounded text-decoration-none" style="background: var(--surface-hover);">
                                        <div class="card-stat-icon rooms" style="width: 48px; height: 48px; font-size: 1.25rem;">
                                            <i class="bi bi-door-open"></i>
                                        </div>
                                        <div>
                                            <strong class="d-block text-primary">Sơ đồ phòng</strong>
                                            <small class="text-muted">Xem trạng thái tất cả phòng</small>
                                        </div>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/bookings?status=Confirmed" class="d-flex align-items-center gap-3 p-3 rounded text-decoration-none" style="background: var(--surface-hover);">
                                        <div class="card-stat-icon bookings" style="width: 48px; height: 48px; font-size: 1.25rem;">
                                            <i class="bi bi-box-arrow-in-right"></i>
                                        </div>
                                        <div>
                                            <strong class="d-block text-primary">Check-in khách</strong>
                                            <small class="text-muted">${pendingCheckins} booking chờ check-in</small>
                                        </div>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/bookings?status=CheckedIn" class="d-flex align-items-center gap-3 p-3 rounded text-decoration-none" style="background: var(--surface-hover);">
                                        <div class="card-stat-icon revenue" style="width: 48px; height: 48px; font-size: 1.25rem;">
                                            <i class="bi bi-box-arrow-right"></i>
                                        </div>
                                        <div>
                                            <strong class="d-block text-primary">Check-out khách</strong>
                                            <small class="text-muted">${pendingCheckouts} booking chờ check-out</small>
                                        </div>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/cleaning" class="d-flex align-items-center gap-3 p-3 rounded text-decoration-none" style="background: var(--surface-hover);">
                                        <div class="card-stat-icon cleaning" style="width: 48px; height: 48px; font-size: 1.25rem;">
                                            <i class="bi bi-stars"></i>
                                        </div>
                                        <div>
                                            <strong class="d-block text-primary">Dọn phòng</strong>
                                            <small class="text-muted">${roomsCleaning} phòng cần dọn</small>
                                        </div>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/staff/service-requests" class="d-flex align-items-center gap-3 p-3 rounded text-decoration-none" style="background: var(--surface-hover);">
                                        <div class="card-stat-icon" style="width: 48px; height: 48px; font-size: 1.25rem; background: linear-gradient(135deg, #ffc107, #ff9800);">
                                            <i class="bi bi-bell"></i>
                                        </div>
                                        <div>
                                            <strong class="d-block text-primary">Yêu cầu dịch vụ</strong>
                                            <small class="text-muted">${pendingServiceRequests} yêu cầu chờ xử lý</small>
                                        </div>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-6">
                        <div class="card h-100">
                            <div class="card-header">
                                <i class="bi bi-pie-chart me-2"></i>Thống kê phòng
                            </div>
                            <div class="card-body">
                                <ul class="list-unstyled mb-0">
                                    <li class="d-flex justify-content-between align-items-center py-3 border-bottom">
                                        <span>Tổng số phòng</span>
                                        <strong class="fs-5">${roomsAvailable + roomsOccupied + roomsCleaning}</strong>
                                    </li>
                                    <li class="d-flex justify-content-between align-items-center py-3 border-bottom">
                                        <span><i class="bi bi-circle-fill me-2" style="color: var(--success);"></i>Phòng trống</span>
                                        <span class="badge badge-available">${roomsAvailable}</span>
                                    </li>
                                    <li class="d-flex justify-content-between align-items-center py-3 border-bottom">
                                        <span><i class="bi bi-circle-fill me-2" style="color: var(--danger);"></i>Phòng đang sử dụng</span>
                                        <span class="badge badge-occupied">${roomsOccupied}</span>
                                    </li>
                                    <li class="d-flex justify-content-between align-items-center py-3 border-bottom">
                                        <span><i class="bi bi-circle-fill me-2" style="color: var(--warning);"></i>Phòng đang dọn</span>
                                        <span class="badge badge-cleaning">${roomsCleaning}</span>
                                    </li>
                                    <li class="d-flex justify-content-between align-items-center py-3">
                                        <span><i class="bi bi-circle-fill me-2" style="color: var(--info);"></i>Booking chờ xử lý</span>
                                        <span class="badge badge-info">${pendingCheckins + pendingCheckouts}</span>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Mobile Toggle -->
    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
