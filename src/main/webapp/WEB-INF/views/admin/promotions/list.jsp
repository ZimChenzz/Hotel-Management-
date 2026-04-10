<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý Khuyến mãi - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="promotions" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý Khuyến mãi" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
                        </li>
                        <li class="breadcrumb-item active">Khuyến mãi</li>
                    </ol>
                </nav>

                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="bi bi-check-circle me-2"></i>${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Danh sách Khuyến mãi</h1>
                        <p class="page-header-subtitle">Tổng: ${promotions.size()} khuyến mãi</p>
                    </div>
                    <div class="page-header-actions">
                        <a href="${pageContext.request.contextPath}/admin/promotions/create"
                           class="btn btn-primary">
                            <i class="bi bi-plus-lg me-1"></i> Thêm Khuyến mãi
                        </a>
                    </div>
                </div>

                <!-- Filter -->
                <div class="filter-card">
                    <form id="filterForm" class="row g-3 align-items-end">
                        <div class="col-md-5">
                            <label class="form-label">Tìm kiếm</label>
                            <input type="text" class="form-control" name="search"
                                   placeholder="Mã khuyến mãi...">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="">Tất cả</option>
                                <option value="active">Đang hoạt động</option>
                                <option value="upcoming">Sắp diễn ra</option>
                                <option value="expired">Hết hạn</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button type="reset" class="btn btn-outline-secondary w-100"
                                    onclick="AdminTable.filter('promotionsTable', {})">
                                <i class="bi bi-x-lg me-1"></i> Xóa lọc
                            </button>
                        </div>
                    </form>
                </div>

                <div class="card">
                    <div class="table-responsive">
                        <table class="table-modern table-striped table-hover" id="promotionsTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Mã KM</th>
                                    <th>Loại phòng</th>
                                    <th>Giảm giá</th>
                                    <th>Bắt đầu</th>
                                    <th>Kết thúc</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="promo" items="${promotions}">
                                    <tr data-row>
                                        <td>${promo.promotionId}</td>
                                        <td data-field="search">
                                            <code class="fs-6">${promo.promoCode}</code>
                                        </td>
                                        <td>${promo.typeName}</td>
                                        <td class="text-success fw-bold">${promo.discountPercent}%</td>
                                        <td>${promo.startDate}</td>
                                        <td>${promo.endDate}</td>
                                        <td data-field="status" data-value="${promo.status}">
                                            <c:choose>
                                                <c:when test="${promo.status == 'active'}">
                                                    <span class="badge badge-success">Đang hoạt động</span>
                                                </c:when>
                                                <c:when test="${promo.status == 'upcoming'}">
                                                    <span class="badge badge-warning">Sắp diễn ra</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">Hết hạn</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="btn-group btn-group-sm">
                                                <a href="${pageContext.request.contextPath}/admin/promotions/edit?id=${promo.promotionId}"
                                                   class="btn btn-outline-secondary">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                                <form action="${pageContext.request.contextPath}/admin/promotions/delete"
                                                      method="post" style="display:inline;"
                                                      onsubmit="return confirm('Bạn có chắc muốn xóa khuyến mãi này?');">
                                                    <input type="hidden" name="id" value="${promo.promotionId}">
                                                    <button type="submit" class="btn btn-outline-danger">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty promotions}">
                                    <tr>
                                        <td colspan="8">
                                            <div class="empty-state">
                                                <div class="empty-state-icon">
                                                    <i class="bi bi-megaphone"></i>
                                                </div>
                                                <h3 class="empty-state-title">Chưa có khuyến mãi nào</h3>
                                                <p class="empty-state-text">Bắt đầu bằng cách thêm khuyến mãi mới.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                    <div id="promotionsTable-pagination"></div>
                </div>
            </div>
        </main>
    </div>

    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
    <script src="${pageContext.request.contextPath}/assets/js/admin-table.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            AdminTable.init('promotionsTable');
            AdminTable.bindFilters('promotionsTable', 'filterForm');
        });
    </script>
</body>
</html>
