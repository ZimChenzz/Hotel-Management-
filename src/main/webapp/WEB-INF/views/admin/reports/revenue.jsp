<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Báo cáo doanh thu - Cổng Quản Trị</title>
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
            <c:set var="pageTitle" value="Báo cáo doanh thu" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Báo cáo doanh thu</li>
                    </ol>
                </nav>

                <!-- Date Filter -->
                <div class="card mb-4">
                    <div class="card-body">
                        <form method="get" class="row g-3 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label">Từ ngày</label>
                                <input type="date" class="form-control" name="startDate" value="${startDate}">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Đến ngày</label>
                                <input type="date" class="form-control" name="endDate" value="${endDate}">
                            </div>
                            <div class="col-md-3">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-filter me-1"></i>Lọc
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Revenue Stats -->
                <div class="row g-4 mb-4">
                    <div class="col-md-4">
                        <div class="card stat-card">
                            <div class="card-body d-flex align-items-center">
                                <div class="stat-icon bg-success text-white me-3">
                                    <i class="bi bi-currency-dollar"></i>
                                </div>
                                <div>
                                    <div class="stat-value">
                                        <fmt:formatNumber value="${report.totalRevenue}" type="currency" currencySymbol="" maxFractionDigits="0"/>
                                    </div>
                                    <div class="stat-label text-muted">Tổng doanh thu (VNĐ)</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card stat-card">
                            <div class="card-body d-flex align-items-center">
                                <div class="stat-icon bg-primary text-white me-3">
                                    <i class="bi bi-calendar-check"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${report.bookingCount}</div>
                                    <div class="stat-label text-muted">Số booking</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card stat-card">
                            <div class="card-body d-flex align-items-center">
                                <div class="stat-icon bg-info text-white me-3">
                                    <i class="bi bi-graph-up-arrow"></i>
                                </div>
                                <div>
                                    <div class="stat-value">
                                        <fmt:formatNumber value="${report.averageBookingValue}" type="currency" currencySymbol="" maxFractionDigits="0"/>
                                    </div>
                                    <div class="stat-label text-muted">Giá trị TB/booking (VNĐ)</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Summary Card -->
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-file-earmark-bar-graph me-2"></i>Tóm tắt báo cáo
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <table class="table table-borderless">
                                    <tr>
                                        <th>Kỳ báo cáo:</th>
                                        <td>${startDate} - ${endDate}</td>
                                    </tr>
                                    <tr>
                                        <th>Tổng doanh thu:</th>
                                        <td class="text-success fw-bold">
                                            <fmt:formatNumber value="${report.totalRevenue}" type="currency" currencySymbol="" maxFractionDigits="0"/> VNĐ
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Số lượng booking:</th>
                                        <td>${report.bookingCount}</td>
                                    </tr>
                                    <tr>
                                        <th>Giá trị trung bình:</th>
                                        <td>
                                            <fmt:formatNumber value="${report.averageBookingValue}" type="currency" currencySymbol="" maxFractionDigits="0"/> VNĐ
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <div class="alert alert-info">
                                    <h6><i class="bi bi-lightbulb me-2"></i>Ghi chú</h6>
                                    <ul class="mb-0 small">
                                        <li>Doanh thu chỉ tính các booking đã check-in hoặc check-out</li>
                                        <li>Chọn khoảng thời gian để xem báo cáo chi tiết</li>
                                    </ul>
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
</body>
</html>
