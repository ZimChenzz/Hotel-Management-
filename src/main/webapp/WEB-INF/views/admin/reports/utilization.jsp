<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Báo cáo công suất phòng - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="reports" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Báo cáo công suất phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Công suất phòng</li>
                    </ol>
                </nav>

                <!-- Utilization Rate -->
                <div class="row mb-4">
                    <div class="col-lg-4">
                        <div class="card text-center">
                            <div class="card-body py-5">
                                <h2 class="display-3 fw-bold text-primary">${stats.utilizationRate}%</h2>
                                <p class="text-muted mb-0">Tỷ lệ sử dụng phòng</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-8">
                        <div class="card h-100">
                            <div class="card-header">
                                <i class="bi bi-pie-chart me-2"></i>Phân bố trạng thái phòng
                            </div>
                            <div class="card-body">
                                <div class="chart-container" style="height: 200px;">
                                    <canvas id="roomStatusChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="row g-4">
                    <div class="col-md-3">
                        <div class="card stat-card">
                            <div class="card-body d-flex align-items-center">
                                <div class="stat-icon bg-primary text-white me-3">
                                    <i class="bi bi-door-open"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${stats.totalRooms}</div>
                                    <div class="stat-label text-muted">Tổng số phòng</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card">
                            <div class="card-body d-flex align-items-center">
                                <div class="stat-icon bg-danger text-white me-3">
                                    <i class="bi bi-person-check"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${stats.occupied}</div>
                                    <div class="stat-label text-muted">Đang sử dụng</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card">
                            <div class="card-body d-flex align-items-center">
                                <div class="stat-icon bg-success text-white me-3">
                                    <i class="bi bi-check-circle"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${stats.available}</div>
                                    <div class="stat-label text-muted">Sẵn sàng</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card">
                            <div class="card-body d-flex align-items-center">
                                <div class="stat-icon bg-warning text-white me-3">
                                    <i class="bi bi-stars"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${stats.cleaning}</div>
                                    <div class="stat-label text-muted">Đang dọn</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const ctx = document.getElementById('roomStatusChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Đang sử dụng', 'Sẵn sàng', 'Đang dọn', 'Bảo trì'],
                datasets: [{
                    data: [${stats.occupied}, ${stats.available}, ${stats.cleaning}, ${stats.maintenance}],
                    backgroundColor: ['#dc3545', '#28a745', '#ffc107', '#6c757d'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right'
                    }
                }
            }
        });
    </script>
</body>
</html>
