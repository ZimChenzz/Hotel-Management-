<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý khách hàng - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="customers" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý khách hàng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Khách hàng</li>
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
                        <h1 class="page-header-title">Danh sách khách hàng</h1>
                        <p class="page-header-subtitle">Tổng: ${customers.size()} khách hàng</p>
                    </div>
                    <div class="page-header-actions">
                        <a href="${pageContext.request.contextPath}/admin/customers/create" class="btn btn-primary">
                            <i class="bi bi-plus-lg me-1"></i> Thêm khách hàng
                        </a>
                    </div>
                </div>

                <!-- Filter -->
                <div class="filter-card">
                    <form id="filterForm" class="row g-3 align-items-end">
                        <div class="col-md-4">
                            <label class="form-label">Tìm kiếm</label>
                            <input type="text" class="form-control" name="search" placeholder="Tên, email, SĐT...">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="">Tất cả</option>
                                <option value="active">Hoạt động</option>
                                <option value="inactive">Đã khóa</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Hạng thành viên</label>
                            <select class="form-select" name="membership">
                                <option value="">Tất cả</option>
                                <option value="Bronze">Bronze</option>
                                <option value="Silver">Silver</option>
                                <option value="Gold">Gold</option>
                                <option value="Platinum">Platinum</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="reset" class="btn btn-outline-secondary w-100" onclick="AdminTable.filter('customersTable', {})">
                                <i class="bi bi-x-lg me-1"></i> Xóa lọc
                            </button>
                        </div>
                    </form>
                </div>

                <div class="card">
                    <div class="table-responsive">
                        <table class="table-modern table-striped table-hover" id="customersTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Họ tên</th>
                                    <th>Email</th>
                                    <th>Điện thoại</th>
                                    <th>Điểm tích lũy</th>
                                    <th>Hạng thành viên</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="customer" items="${customers}">
                                    <tr data-row>
                                        <td>${customer.accountId}</td>
                                        <td data-field="search">${customer.account.fullName}</td>
                                        <td data-field="search">${customer.account.email}</td>
                                        <td data-field="search">${customer.account.phone}</td>
                                        <td>${customer.loyaltyPoints}</td>
                                        <td data-field="membership" data-value="${customer.membershipLevel}">
                                            <span class="badge badge-info">${customer.membershipLevel}</span>
                                        </td>
                                        <td data-field="status" data-value="${customer.account.active ? 'active' : 'inactive'}">
                                            <c:choose>
                                                <c:when test="${customer.account.active}">
                                                    <span class="badge badge-success">Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">Đã khóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/customers/edit?id=${customer.accountId}"
                                               class="btn btn-sm btn-outline-secondary">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty customers}">
                                    <tr>
                                        <td colspan="8">
                                            <div class="empty-state">
                                                <div class="empty-state-icon">
                                                    <i class="bi bi-people"></i>
                                                </div>
                                                <h3 class="empty-state-title">Chưa có khách hàng nào</h3>
                                                <p class="empty-state-text">Bắt đầu bằng cách thêm khách hàng mới.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                    <div id="customersTable-pagination"></div>
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
            AdminTable.init('customersTable');
            AdminTable.bindFilters('customersTable', 'filterForm');
        });
    </script>
</body>
</html>
