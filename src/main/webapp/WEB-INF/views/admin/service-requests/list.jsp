<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý yêu cầu dịch vụ - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý yêu cầu dịch vụ" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Breadcrumb -->
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Trang chủ</a></li>
                        <li class="breadcrumb-item active">Yêu cầu dịch vụ</li>
                    </ol>
                </nav>

                <!-- Stats Cards -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6 col-lg-3">
                        <div class="card-stat">
                            <div class="card-stat-icon" style="background: linear-gradient(135deg, #9c27b0, #7b1fa2);">
                                <i class="bi bi-list-check"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${stats.totalToday}</div>
                                <div class="card-stat-label">Tổng hôm nay</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <div class="card-stat">
                            <div class="card-stat-icon" style="background: linear-gradient(135deg, #ffc107, #ff9800);">
                                <i class="bi bi-hourglass-split"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${stats.pending}</div>
                                <div class="card-stat-label">Chờ xử lý</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <div class="card-stat">
                            <div class="card-stat-icon" style="background: linear-gradient(135deg, #2196f3, #1976d2);">
                                <i class="bi bi-arrow-repeat"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${stats.inProgress}</div>
                                <div class="card-stat-label">Đang xử lý</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <div class="card-stat">
                            <div class="card-stat-icon" style="background: linear-gradient(135deg, #4caf50, #388e3c);">
                                <i class="bi bi-check-circle"></i>
                            </div>
                            <div>
                                <div class="card-stat-value">${stats.completedToday}</div>
                                <div class="card-stat-label">Hoàn thành hôm nay</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filters -->
                <div class="card mb-3">
                    <div class="card-body py-2">
                        <form class="d-flex gap-3 align-items-center flex-wrap" method="get">
                            <div class="d-flex align-items-center gap-2">
                                <label class="form-label mb-0">Trạng thái:</label>
                                <select name="status" class="form-select form-select-sm" style="width: auto;" onchange="this.form.submit()">
                                    <option value="">Tất cả</option>
                                    <option value="Pending" ${statusFilter == 'Pending' ? 'selected' : ''}>Chờ xử lý</option>
                                    <option value="In Progress" ${statusFilter == 'In Progress' ? 'selected' : ''}>Đang xử lý</option>
                                    <option value="Completed" ${statusFilter == 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                                    <option value="Cancelled" ${statusFilter == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                                    <option value="Rejected" ${statusFilter == 'Rejected' ? 'selected' : ''}>Từ chối</option>
                                </select>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <label class="form-label mb-0">Loại:</label>
                                <select name="type" class="form-select form-select-sm" style="width: auto;" onchange="this.form.submit()">
                                    <option value="">Tất cả</option>
                                    <option value="Cleaning" ${typeFilter == 'Cleaning' ? 'selected' : ''}>Dọn phòng</option>
                                    <option value="Maintenance" ${typeFilter == 'Maintenance' ? 'selected' : ''}>Bảo trì</option>
                                    <option value="Food & Beverage" ${typeFilter == 'Food & Beverage' ? 'selected' : ''}>Đồ ăn & Nước uống</option>
                                    <option value="Supplies" ${typeFilter == 'Supplies' ? 'selected' : ''}>Vật dụng</option>
                                </select>
                            </div>
                            <span class="text-muted ms-auto">${serviceRequests.size()} yêu cầu</span>
                        </form>
                    </div>
                </div>

                <!-- Request Table -->
                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="bi bi-table me-2"></i>Danh sách yêu cầu dịch vụ</h5>
                    </div>
                    <div class="card-body p-0">
                        <c:choose>
                            <c:when test="${not empty serviceRequests}">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th class="ps-4">#</th>
                                                <th>Phòng</th>
                                                <th>Loại</th>
                                                <th>Mô tả</th>
                                                <th>Ưu tiên</th>
                                                <th>Trạng thái</th>
                                                <th>Nhân viên</th>
                                                <th>Thời gian gửi</th>
                                                <th>Hoàn thành</th>
                                                <th>Ghi chú</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="sr" items="${serviceRequests}">
                                                <tr>
                                                    <td class="ps-4">${sr.requestId}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty sr.roomNumber}">
                                                                <span class="badge bg-light text-dark">${sr.roomNumber}</span>
                                                            </c:when>
                                                            <c:otherwise><span class="text-muted">--</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${sr.serviceType == 'Cleaning'}">
                                                                <i class="bi bi-stars text-warning me-1"></i>
                                                            </c:when>
                                                            <c:when test="${sr.serviceType == 'Maintenance'}">
                                                                <i class="bi bi-wrench text-info me-1"></i>
                                                            </c:when>
                                                            <c:when test="${sr.serviceType == 'Food & Beverage'}">
                                                                <i class="bi bi-cup-hot text-danger me-1"></i>
                                                            </c:when>
                                                            <c:when test="${sr.serviceType == 'Supplies'}">
                                                                <i class="bi bi-box-seam text-success me-1"></i>
                                                            </c:when>
                                                        </c:choose>
                                                        ${sr.serviceType}
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty sr.description}">
                                                                <small title="${sr.description}">
                                                                    ${sr.description.length() > 40
                                                                        ? sr.description.substring(0, 40).concat('...')
                                                                        : sr.description}
                                                                </small>
                                                            </c:when>
                                                            <c:otherwise><small class="text-muted">--</small></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${sr.priority == 'Urgent'}">
                                                                <span class="badge bg-danger">Khẩn cấp</span>
                                                            </c:when>
                                                            <c:when test="${sr.priority == 'High'}">
                                                                <span class="badge bg-warning text-dark">Cao</span>
                                                            </c:when>
                                                            <c:when test="${sr.priority == 'Normal'}">
                                                                <span class="badge bg-info">Bình thường</span>
                                                            </c:when>
                                                            <c:when test="${sr.priority == 'Low'}">
                                                                <span class="badge bg-secondary">Thấp</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-info">Bình thường</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${sr.status == 'Pending'}">
                                                                <span class="badge badge-pending">Chờ xử lý</span>
                                                            </c:when>
                                                            <c:when test="${sr.status == 'In Progress'}">
                                                                <span class="badge badge-occupied">Đang xử lý</span>
                                                            </c:when>
                                                            <c:when test="${sr.status == 'Completed'}">
                                                                <span class="badge badge-completed">Hoàn thành</span>
                                                            </c:when>
                                                            <c:when test="${sr.status == 'Cancelled'}">
                                                                <span class="badge badge-cancelled">Đã hủy</span>
                                                            </c:when>
                                                            <c:when test="${sr.status == 'Rejected'}">
                                                                <span class="badge bg-dark">Từ chối</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">${sr.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty sr.staffName}">
                                                                <small>${sr.staffName}</small>
                                                            </c:when>
                                                            <c:otherwise><small class="text-muted">Chưa phân công</small></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><small>${sr.requestTimeFormatted}</small></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty sr.completedTimeFormatted}">
                                                                <small>${sr.completedTimeFormatted}</small>
                                                            </c:when>
                                                            <c:otherwise><small class="text-muted">--</small></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty sr.notes}">
                                                                <small title="${sr.notes}">
                                                                    ${sr.notes.length() > 30
                                                                        ? sr.notes.substring(0, 30).concat('...')
                                                                        : sr.notes}
                                                                </small>
                                                            </c:when>
                                                            <c:otherwise><small class="text-muted">--</small></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="bi bi-clipboard-check fs-1 text-muted mb-3 d-block"></i>
                                    <h5 class="text-muted">Không có yêu cầu nào</h5>
                                    <p class="text-muted">Không tìm thấy yêu cầu dịch vụ nào phù hợp với bộ lọc.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Mobile Toggle -->
    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
