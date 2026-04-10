<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý Voucher - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="vouchers" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý Voucher" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Voucher</li>
                    </ol>
                </nav>

                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="bi bi-check-circle me-2"></i>${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Danh sách Voucher</h1>
                        <p class="page-header-subtitle">Tổng: ${vouchers.size()} voucher</p>
                    </div>
                    <div class="page-header-actions">
                        <a href="${pageContext.request.contextPath}/admin/vouchers/create" class="btn btn-primary">
                            <i class="bi bi-plus-lg me-1"></i> Thêm Voucher
                        </a>
                    </div>
                </div>

                <!-- Filter -->
                <div class="filter-card">
                    <form id="filterForm" class="row g-3 align-items-end">
                        <div class="col-md-6">
                            <label class="form-label">Tìm kiếm</label>
                            <input type="text" class="form-control" name="search" placeholder="Mã voucher...">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="">Tất cả</option>
                                <option value="active">Hoạt động</option>
                                <option value="inactive">Tắt</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button type="reset" class="btn btn-outline-secondary w-100" onclick="AdminTable.filter('vouchersTable', {})">
                                <i class="bi bi-x-lg me-1"></i> Xóa lọc
                            </button>
                        </div>
                    </form>
                </div>

                <div class="card">
                    <div class="table-responsive">
                        <table class="table-modern table-striped table-hover" id="vouchersTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Mã code</th>
                                    <th>Giảm giá</th>
                                    <th>Đơn tối thiểu</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="voucher" items="${vouchers}">
                                    <tr data-row>
                                        <td>${voucher.voucherId}</td>
                                        <td data-field="search"><code class="fs-6">${voucher.code}</code></td>
                                        <td class="text-success fw-bold">
                                            <fmt:formatNumber value="${voucher.discountAmount}" type="currency" currencySymbol="" maxFractionDigits="0"/> VNĐ
                                        </td>
                                        <td>
                                            <fmt:formatNumber value="${voucher.minOrderValue}" type="currency" currencySymbol="" maxFractionDigits="0"/> VNĐ
                                        </td>
                                        <td data-field="status" data-value="${voucher.active ? 'active' : 'inactive'}">
                                            <c:choose>
                                                <c:when test="${voucher.active}">
                                                    <span class="badge badge-success">Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">Tắt</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="btn-group btn-group-sm">
                                                <a href="${pageContext.request.contextPath}/admin/vouchers/edit?id=${voucher.voucherId}"
                                                   class="btn btn-outline-secondary">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                                <form action="${pageContext.request.contextPath}/admin/vouchers/delete"
                                                      method="post" style="display:inline;"
                                                      onsubmit="return confirm('Bạn có chắc muốn xóa voucher này?');">
                                                    <input type="hidden" name="id" value="${voucher.voucherId}">
                                                    <button type="submit" class="btn btn-outline-danger">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty vouchers}">
                                    <tr>
                                        <td colspan="6">
                                            <div class="empty-state">
                                                <div class="empty-state-icon">
                                                    <i class="bi bi-ticket-perforated"></i>
                                                </div>
                                                <h3 class="empty-state-title">Chưa có voucher nào</h3>
                                                <p class="empty-state-text">Bắt đầu bằng cách thêm voucher mới.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                    <div id="vouchersTable-pagination"></div>
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
            AdminTable.init('vouchersTable');
            AdminTable.bindFilters('vouchersTable', 'filterForm');
        });
    </script>
</body>
</html>
