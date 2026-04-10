<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bảng điều khiển - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
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
                        <p class="page-header-subtitle">Dưới đây là tổng quan hệ thống khách sạn.</p>
                    </div>
                </div>

                <!-- Time Filter -->
                <div class="card mb-4">
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/admin/dashboard" id="filterForm" class="row g-3 align-items-end">
                            <div class="col-auto">
                                <label class="form-label mb-0"><strong>Thời gian:</strong></label>
                            </div>
                            <div class="col-auto">
                                <select name="period" class="form-select" onchange="document.getElementById('filterForm').submit();">
                                    <option value="today" ${selectedPeriod == 'today' ? 'selected' : ''}>Hôm nay</option>
                                    <option value="week" ${selectedPeriod == 'week' ? 'selected' : ''}>Tuần này</option>
                                    <option value="month" ${(selectedPeriod == 'month' || empty selectedPeriod) ? 'selected' : ''}>Tháng này</option>
                                    <option value="quarter" ${selectedPeriod == 'quarter' ? 'selected' : ''}>Quý này</option>
                                    <option value="year" ${selectedPeriod == 'year' ? 'selected' : ''}>Năm nay</option>
                                    <option value="custom" ${selectedPeriod == 'custom' ? 'selected' : ''}>Tùy chỉnh</option>
                                </select>
                            </div>
                            <div class="col-auto" id="customDateRange" style="${selectedPeriod == 'custom' ? '' : 'display:none;'}">
                                <div class="row g-2">
                                    <div class="col-auto">
                                        <label class="form-label mb-0">Từ:</label>
                                        <input type="date" class="form-control form-control-sm" name="startDate" value="${startDate}">
                                    </div>
                                    <div class="col-auto">
                                        <label class="form-label mb-0">Đến:</label>
                                        <input type="date" class="form-control form-control-sm" name="endDate" value="${endDate}">
                                    </div>
                                </div>
                            </div>
                            <div class="col-auto">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-filter"></i> Lọc
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6 col-lg-3 animate-in">
                        <div class="card-stat">
                            <div class="card-stat-icon rooms">
                                <i class="bi bi-door-open"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${stats.totalRooms}</div>
                                <div class="card-stat-label">Tổng số phòng</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3 animate-in">
                        <div class="card-stat">
                            <div class="card-stat-icon bookings">
                                <i class="bi bi-calendar-check"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${stats.totalBookings}</div>
                                <div class="card-stat-label">Booking</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3 animate-in">
                        <div class="card-stat">
                            <div class="card-stat-icon revenue">
                                <i class="bi bi-currency-dollar"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">
                                    <fmt:formatNumber value="${stats.totalRevenue}" type="currency" currencySymbol="" maxFractionDigits="0"/>
                                </div>
                                <div class="card-stat-label">Doanh thu (VNĐ)</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3 animate-in">
                        <div class="card-stat">
                            <div class="card-stat-icon customers">
                                <i class="bi bi-people"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${stats.totalCustomers}</div>
                                <div class="card-stat-label">Khách hàng</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Charts Row -->
                <div class="row g-4 mb-4">
                    <!-- Donut: Room Status -->
                    <div class="col-lg-4">
                        <div class="card h-100">
                            <div class="card-header">
                                <i class="bi bi-pie-chart me-2"></i>Trạng thái phòng
                            </div>
                            <div class="card-body d-flex align-items-center justify-content-center">
                                <canvas id="roomStatusChart" style="max-height:220px;"></canvas>
                            </div>
                        </div>
                    </div>
                    <!-- Line: Revenue Chart -->
                    <div class="col-lg-8">
                        <div class="card h-100">
                            <div class="card-header">
                                <i class="bi bi-graph-up me-2"></i>Doanh thu theo thời gian
                            </div>
                            <div class="card-body">
                                <canvas id="revenueChart" style="max-height:220px;"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Booking Trend Chart -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-12">
                        <div class="card">
                            <div class="card-header">
                                <i class="bi bi-bar-chart me-2"></i>Số lượng booking
                            </div>
                            <div class="card-body">
                                <canvas id="bookingTrendChart" style="max-height:220px;"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Service Requests -->
                <div class="row g-4 mb-4">
                    <div class="col-lg-12">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <span><i class="bi bi-bell me-2"></i>Yêu cầu dịch vụ hôm nay</span>
                                <a href="${pageContext.request.contextPath}/admin/service-requests" class="btn btn-sm btn-outline-primary">Xem tất cả</a>
                            </div>
                            <div class="card-body">
                                <div class="row text-center">
                                    <div class="col-3">
                                        <div class="fs-3 fw-bold text-primary">${serviceRequestStats.totalToday}</div>
                                        <small class="text-muted">Tổng</small>
                                    </div>
                                    <div class="col-3">
                                        <div class="fs-3 fw-bold text-warning">${serviceRequestStats.pending}</div>
                                        <small class="text-muted">Chờ xử lý</small>
                                    </div>
                                    <div class="col-3">
                                        <div class="fs-3 fw-bold" style="color: #2196f3;">${serviceRequestStats.inProgress}</div>
                                        <small class="text-muted">Đang xử lý</small>
                                    </div>
                                    <div class="col-3">
                                        <div class="fs-3 fw-bold text-success">${serviceRequestStats.completedToday}</div>
                                        <small class="text-muted">Hoàn thành</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Links -->
                <div class="row g-4">
                    <div class="col-lg-12">
                        <div class="card">
                            <div class="card-header">
                                <i class="bi bi-lightning me-2"></i>Truy cập nhanh
                            </div>
                            <div class="card-body">
                                <div class="row g-3">
                                    <div class="col-6 col-md-3">
                                        <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-outline-secondary w-100 py-3">
                                            <i class="bi bi-door-open d-block fs-3 mb-2"></i>
                                            Quản lý phòng
                                        </a>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <a href="${pageContext.request.contextPath}/admin/rooms/map" class="btn btn-outline-secondary w-100 py-3">
                                            <i class="bi bi-grid-3x3-gap d-block fs-3 mb-2"></i>
                                            Sơ đồ phòng
                                        </a>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-outline-secondary w-100 py-3">
                                            <i class="bi bi-people d-block fs-3 mb-2"></i>
                                            Khách hàng
                                        </a>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-outline-secondary w-100 py-3">
                                            <i class="bi bi-person-badge d-block fs-3 mb-2"></i>
                                            Nhân viên
                                        </a>
                                    </div>
                                </div>
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
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <script>
        // Room Status Donut Chart
        (function() {
            var available = parseInt('${stats.availableRooms}') || 0;
            var occupied = parseInt('${stats.occupiedRooms}') || 0;
            var cleaning = parseInt('${stats.cleaningRooms}') || 0;
            var maintenance = parseInt('${stats.maintenanceRooms}') || 0;
            new Chart(document.getElementById('roomStatusChart'), {
                type: 'doughnut',
                data: {
                    labels: ['Trống', 'Đang ở', 'Đang dọn', 'Bảo trì'],
                    datasets: [{
                        data: [available, occupied, cleaning, maintenance],
                        backgroundColor: ['#10b981','#ef4444','#f59e0b','#8b5cf6'],
                        borderWidth: 0,
                        hoverBorderWidth: 2,
                        hoverBorderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true,
                    cutout: '72%',
                    plugins: {
                        legend: { position: 'bottom', labels: { padding: 16, font: { size: 12, family: 'Lato' }, usePointStyle: true, pointStyle: 'circle' } }
                    }
                }
            });
        })();

        // Revenue Line Chart
        (function() {
            var labels = ${revenueLabels};
            var values = ${revenueValues};
            if (!labels || labels.length === 0) {
                labels = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'];
            }
            if (!values || values.length === 0) {
                values = [0, 0, 0, 0, 0, 0];
            }
            new Chart(document.getElementById('revenueChart'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Doanh thu (VNĐ)',
                        data: values,
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 3,
                        pointBackgroundColor: '#10b981'
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return context.parsed.y.toLocaleString('vi-VN') + ' VNĐ';
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return (value / 1000000).toFixed(0) + 'M';
                                }
                            },
                            grid: { color: 'rgba(0,0,0,0.04)' }
                        },
                        x: { grid: { display: false } }
                    }
                }
            });
        })();

        // Booking Trend Bar Chart
        (function() {
            var labels = ${monthlyLabels};
            var counts = ${monthlyCounts};
            if (!labels || labels.length === 0) {
                labels = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'];
            }
            if (!counts || counts.length === 0) {
                counts = [0, 0, 0, 0, 0, 0];
            }
            new Chart(document.getElementById('bookingTrendChart'), {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Số booking',
                        data: counts,
                        backgroundColor: 'rgba(212,175,55,0.2)',
                        borderColor: '#d4af37',
                        borderWidth: 2,
                        borderRadius: 8,
                        borderSkipped: false,
                        hoverBackgroundColor: 'rgba(212,175,55,0.4)'
                    }]
                },
                options: {
                    responsive: true,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, ticks: { stepSize: 1 }, grid: { color: 'rgba(0,0,0,0.04)' } },
                        x: { grid: { display: false } }
                    }
                }
            });
        })();
    </script>
</body>
</html>
