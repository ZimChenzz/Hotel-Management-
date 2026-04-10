<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Yêu cầu dịch vụ - Cổng Nhân Viên</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="service-requests" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Yêu cầu dịch vụ" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Breadcrumb -->
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/dashboard">Trang chủ</a></li>
                        <li class="breadcrumb-item active">Yêu cầu dịch vụ</li>
                    </ol>
                </nav>

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

                <!-- Stats Cards -->
                <div class="row g-4 mb-4">
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
                </div>

                <!-- Tabs -->
                <ul class="nav nav-tabs mb-3">
                    <li class="nav-item">
                        <a class="nav-link ${currentTab == 'all' ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/staff/service-requests">
                            Chờ xử lý
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${currentTab == 'my' ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/staff/service-requests?tab=my">
                            Của tôi
                        </a>
                    </li>
                </ul>

                <!-- Filter -->
                <div class="card mb-3">
                    <div class="card-body py-2">
                        <form class="d-flex gap-2 align-items-center" method="get">
                            <c:if test="${currentTab == 'my'}">
                                <input type="hidden" name="tab" value="my">
                            </c:if>
                            <label class="form-label mb-0 me-2">Loại:</label>
                            <select name="type" class="form-select form-select-sm" style="width: auto;" onchange="this.form.submit()">
                                <option value="">Tất cả</option>
                                <option value="Cleaning" ${typeFilter == 'Cleaning' ? 'selected' : ''}>Dọn phòng</option>
                                <option value="Maintenance" ${typeFilter == 'Maintenance' ? 'selected' : ''}>Bảo trì</option>
                                <option value="Food & Beverage" ${typeFilter == 'Food & Beverage' ? 'selected' : ''}>Đồ ăn & Nước uống</option>
                                <option value="Supplies" ${typeFilter == 'Supplies' ? 'selected' : ''}>Vật dụng</option>
                            </select>
                        </form>
                    </div>
                </div>

                <!-- Request List -->
                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="bi bi-list-check me-2"></i>Danh sách yêu cầu</h5>
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
                                                <th>Thời gian</th>
                                                <th class="text-end pe-4">Thao tác</th>
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
                                                            <c:otherwise>
                                                                <span class="text-muted">--</span>
                                                            </c:otherwise>
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
                                                                <small>${sr.description}</small>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <small class="text-muted">--</small>
                                                            </c:otherwise>
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
                                                            <c:when test="${sr.status == 'Rejected'}">
                                                                <span class="badge bg-dark">Từ chối</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">${sr.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><small>${sr.requestTimeFormatted}</small></td>
                                                    <td class="text-end pe-4">
                                                        <c:if test="${sr.status == 'Pending'}">
                                                            <form method="post" class="d-inline"
                                                                  action="${pageContext.request.contextPath}/staff/service-requests/assign">
                                                                <input type="hidden" name="requestId" value="${sr.requestId}">
                                                                <button type="submit" class="btn btn-primary btn-sm"
                                                                        title="Nhận xử lý">
                                                                    <i class="bi bi-hand-index me-1"></i>Nhận
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${sr.status == 'In Progress' && sr.staffId == sessionScope.loggedInAccount.accountId}">
                                                            <button type="button" class="btn btn-success btn-sm"
                                                                    data-bs-toggle="modal"
                                                                    data-bs-target="#completeModal${sr.requestId}"
                                                                    title="Hoàn thành">
                                                                <i class="bi bi-check-lg"></i>
                                                            </button>
                                                            <button type="button" class="btn btn-outline-danger btn-sm"
                                                                    data-bs-toggle="modal"
                                                                    data-bs-target="#rejectModal${sr.requestId}"
                                                                    title="Từ chối">
                                                                <i class="bi bi-x-lg"></i>
                                                            </button>
                                                        </c:if>
                                                    </td>
                                                </tr>

                                                <!-- Complete Modal -->
                                                <c:if test="${sr.status == 'In Progress' && sr.staffId == sessionScope.loggedInAccount.accountId}">
                                                <div class="modal fade" id="completeModal${sr.requestId}" tabindex="-1">
                                                    <div class="modal-dialog">
                                                        <div class="modal-content">
                                                            <form method="post" action="${pageContext.request.contextPath}/staff/service-requests/complete">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Hoàn thành yêu cầu #${sr.requestId}</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <input type="hidden" name="requestId" value="${sr.requestId}">
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Ghi chú (không bắt buộc)</label>
                                                                        <textarea name="notes" class="form-control" rows="3"
                                                                                  placeholder="Ghi chú về quá trình xử lý..."></textarea>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                                                    <button type="submit" class="btn btn-success">
                                                                        <i class="bi bi-check-circle me-1"></i>Hoàn thành
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Reject Modal -->
                                                <div class="modal fade" id="rejectModal${sr.requestId}" tabindex="-1">
                                                    <div class="modal-dialog">
                                                        <div class="modal-content">
                                                            <form method="post" action="${pageContext.request.contextPath}/staff/service-requests/reject">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Từ chối yêu cầu #${sr.requestId}</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <input type="hidden" name="requestId" value="${sr.requestId}">
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Lý do từ chối</label>
                                                                        <textarea name="notes" class="form-control" rows="3" required
                                                                                  placeholder="Nhập lý do từ chối..."></textarea>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                                                    <button type="submit" class="btn btn-danger">
                                                                        <i class="bi bi-x-circle me-1"></i>Từ chối
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                                </c:if>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="bi bi-clipboard-check fs-1 text-muted mb-3 d-block"></i>
                                    <h5 class="text-muted">Không có yêu cầu nào</h5>
                                    <p class="text-muted">Hiện không có yêu cầu dịch vụ nào cần xử lý.</p>
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
