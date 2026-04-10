<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý người dùng - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="users" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý người dùng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Breadcrumb -->
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Người dùng</li>
                    </ol>
                </nav>

                <!-- Alerts -->
                <c:if test="${param.success == 'created'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Tạo người dùng thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.success == 'updated'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Cập nhật người dùng thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Quản lý người dùng</h1>
                        <p class="page-header-subtitle">Quản lý tài khoản và phân quyền</p>
                    </div>
                    <div class="page-header-actions">
                        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#userModal">
                            <i class="bi bi-plus-lg me-1"></i> Thêm người dùng
                        </button>
                    </div>
                </div>

                <!-- Filter/Search -->
                <div class="card mb-4">
                    <div class="card-body py-3">
                        <form method="get" class="row g-3 align-items-end">
                            <div class="col-md-4">
                                <label class="form-label">Tìm kiếm</label>
                                <input type="text" class="form-control" name="search" placeholder="Tên, email..." value="${param.search}">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Vai trò</label>
                                <select class="form-select" name="role">
                                    <option value="">Tất cả</option>
                                    <option value="1" ${param.role == '1' ? 'selected' : ''}>Quản trị viên</option>
                                    <option value="2" ${param.role == '2' ? 'selected' : ''}>Khách hàng</option>
                                    <option value="3" ${param.role == '3' ? 'selected' : ''}>Nhân viên</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Trạng thái</label>
                                <select class="form-select" name="status">
                                    <option value="">Tất cả</option>
                                    <option value="active" ${param.status == 'active' ? 'selected' : ''}>Hoạt động</option>
                                    <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Ngừng hoạt động</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <button type="submit" class="btn btn-secondary w-100">
                                    <i class="bi bi-search me-1"></i> Lọc
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Users Table -->
                <div class="table-responsive">
                    <table class="table-modern table-striped table-hover">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Họ tên</th>
                                <th>Email</th>
                                <th>Vai trò</th>
                                <th>Trạng thái</th>
                                <th>Ngày tạo</th>
                                <th class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty users}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <div class="empty-state-icon">
                                                    <i class="bi bi-people"></i>
                                                </div>
                                                <h3 class="empty-state-title">Chưa có người dùng</h3>
                                                <p class="empty-state-text">Thêm người dùng mới để bắt đầu.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="user" items="${users}">
                                        <tr>
                                            <td>${user.accountId}</td>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="topbar-user-avatar" style="width: 32px; height: 32px; font-size: 0.75rem;">
                                                        ${user.fullName.substring(0, 1)}
                                                    </div>
                                                    <span class="fw-medium">${user.fullName}</span>
                                                </div>
                                            </td>
                                            <td>${user.email}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${user.roleId == 1}">
                                                        <span class="badge badge-primary">Quản trị viên</span>
                                                    </c:when>
                                                    <c:when test="${user.roleId == 2}">
                                                        <span class="badge badge-secondary">Khách hàng</span>
                                                    </c:when>
                                                    <c:when test="${user.roleId == 3}">
                                                        <span class="badge badge-info">Nhân viên</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${user.roleId}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${user.active}">
                                                        <span class="badge badge-active">Hoạt động</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-inactive">Ngừng hoạt động</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${user.createdAt}</td>
                                            <td class="text-end">
                                                <div class="dropdown">
                                                    <button class="btn btn-sm btn-light" data-bs-toggle="dropdown">
                                                        <i class="bi bi-three-dots"></i>
                                                    </button>
                                                    <ul class="dropdown-menu dropdown-menu-end">
                                                        <li><a class="dropdown-item" href="#" onclick="editUser(${user.accountId})">
                                                            <i class="bi bi-pencil me-2"></i>Chỉnh sửa</a></li>
                                                        <li><a class="dropdown-item" href="#" onclick="resetPassword(${user.accountId})">
                                                            <i class="bi bi-key me-2"></i>Reset mật khẩu</a></li>
                                                        <li><hr class="dropdown-divider"></li>
                                                        <c:choose>
                                                            <c:when test="${user.active}">
                                                                <li><a class="dropdown-item text-warning" href="#" onclick="toggleStatus(${user.accountId}, false)">
                                                                    <i class="bi bi-pause-circle me-2"></i>Vô hiệu hóa</a></li>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <li><a class="dropdown-item text-success" href="#" onclick="toggleStatus(${user.accountId}, true)">
                                                                    <i class="bi bi-play-circle me-2"></i>Kích hoạt</a></li>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav class="mt-4">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}"><i class="bi bi-chevron-left"></i></a>
                            </li>
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}"><i class="bi bi-chevron-right"></i></a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </div>
        </main>
    </div>

    <!-- Mobile Toggle -->
    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <!-- User Modal (Create/Edit) -->
    <div class="modal fade" id="userModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="userModalTitle">Thêm người dùng</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="userForm" method="post" action="${pageContext.request.contextPath}/admin/users/save">
                    <div class="modal-body">
                        <input type="hidden" name="id" id="userId">
                        <div class="mb-3">
                            <label class="form-label">Họ tên <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="fullName" id="userFullName" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" name="email" id="userEmail" required>
                        </div>
                        <div class="mb-3" id="passwordField">
                            <label class="form-label">Mật khẩu <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" name="password" id="userPassword">
                            <div class="form-text">Để trống nếu không muốn thay đổi (khi chỉnh sửa)</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Số điện thoại</label>
                            <input type="tel" class="form-control" name="phone" id="userPhone">
                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Vai trò <span class="text-danger">*</span></label>
                                            <select class="form-select" name="roleId" id="userRole" required>
                                                <option value="1">Quản trị viên</option>
                                                <option value="2">Khách hàng</option>
                                                <option value="3">Nhân viên</option>
                                            </select>
                                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary">Lưu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Reset Password Modal -->
    <div class="modal fade" id="resetPasswordModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content modal-confirm">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-key me-2"></i>Reset mật khẩu</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Bạn có chắc muốn reset mật khẩu cho người dùng này?</p>
                    <p class="text-muted mb-0">Mật khẩu mới sẽ được gửi qua email.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                    <form method="post" action="${pageContext.request.contextPath}/admin/users/reset-password">
                        <input type="hidden" name="id" id="resetPasswordUserId">
                        <button type="submit" class="btn btn-warning">Reset mật khẩu</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Toggle Status Modal -->
    <div class="modal fade" id="toggleStatusModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content modal-confirm">
                <div class="modal-header">
                    <h5 class="modal-title" id="toggleStatusTitle">Xác nhận</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p id="toggleStatusMessage"></p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                    <form method="post" action="${pageContext.request.contextPath}/admin/users/toggle-status">
                        <input type="hidden" name="id" id="toggleStatusUserId">
                        <input type="hidden" name="active" id="toggleStatusValue">
                        <button type="submit" class="btn" id="toggleStatusBtn">Xác nhận</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <script>
        function editUser(id) {
            document.getElementById('userModalTitle').textContent = 'Chỉnh sửa người dùng';
            document.getElementById('userId').value = id;
            // Load user data via AJAX here
            new bootstrap.Modal(document.getElementById('userModal')).show();
        }

        function resetPassword(id) {
            document.getElementById('resetPasswordUserId').value = id;
            new bootstrap.Modal(document.getElementById('resetPasswordModal')).show();
        }

        function toggleStatus(id, activate) {
            document.getElementById('toggleStatusUserId').value = id;
            document.getElementById('toggleStatusValue').value = activate;
            if (activate) {
                document.getElementById('toggleStatusTitle').textContent = 'Kích hoạt tài khoản';
                document.getElementById('toggleStatusMessage').textContent = 'Bạn có chắc muốn kích hoạt tài khoản này?';
                document.getElementById('toggleStatusBtn').className = 'btn btn-success';
                document.getElementById('toggleStatusBtn').textContent = 'Kích hoạt';
            } else {
                document.getElementById('toggleStatusTitle').textContent = 'Vô hiệu hóa tài khoản';
                document.getElementById('toggleStatusMessage').textContent = 'Bạn có chắc muốn vô hiệu hóa tài khoản này? Người dùng sẽ không thể đăng nhập.';
                document.getElementById('toggleStatusBtn').className = 'btn btn-warning';
                document.getElementById('toggleStatusBtn').textContent = 'Vô hiệu hóa';
            }
            new bootstrap.Modal(document.getElementById('toggleStatusModal')).show();
        }

        // Reset modal when creating new user
        document.getElementById('userModal').addEventListener('show.bs.modal', function (event) {
            if (!event.relatedTarget) return; // Skip if triggered programmatically
            document.getElementById('userModalTitle').textContent = 'Thêm người dùng';
            document.getElementById('userForm').reset();
            document.getElementById('userId').value = '';
        });
    </script>
</body>
</html>
