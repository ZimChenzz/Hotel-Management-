<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.mycompany.hotelmanagementsystem.constant.RoleConstant" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${isEdit ? 'Sửa' : 'Thêm'} nhân viên - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="staff" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="${isEdit ? 'Sửa nhân viên' : 'Thêm nhân viên'}" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/staff">Nhân viên</a></li>
                        <li class="breadcrumb-item active">${isEdit ? 'Sửa' : 'Thêm'}</li>
                    </ol>
                </nav>

                <div class="card" style="max-width: 700px;">
                    <div class="card-header">
                        <i class="bi bi-person-badge me-2"></i>${isEdit ? 'Sửa thông tin' : 'Thêm'} nhân viên
                    </div>
                    <div class="card-body">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-circle me-2"></i>${error}
                            </div>
                        </c:if>

                        <form method="post">
                            <c:if test="${isEdit}">
                                <input type="hidden" name="id" value="${staff.accountId}">
                            </c:if>

                            <c:if test="${not isEdit}">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Email <span class="text-danger">*</span></label>
                                        <input type="email" class="form-control" name="email"
                                               value="${staff.email}" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Mật khẩu <span class="text-danger">*</span></label>
                                        <input type="password" class="form-control" name="password" required>
                                    </div>
                                </div>
                            </c:if>

                            <div class="mb-3">
                                <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" name="fullName"
                                       value="${staff.fullName}" required>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Số điện thoại</label>
                                    <input type="tel" class="form-control" name="phone"
                                           value="${staff.phone}">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Địa chỉ</label>
                                    <input type="text" class="form-control" name="address"
                                           value="${staff.address}">
                                </div>
                            </div>

                            <c:if test="${isEdit}">
                                <div class="mb-3">
                                    <label class="form-label">Vai trò <span class="text-danger">*</span></label>
                                    <select name="roleId" class="form-select" required>
                                        <option value="3" ${staff.roleId == 3 ? 'selected' : ''}>Nhân viên</option>
                                        <option value="1" ${staff.roleId == 1 ? 'selected' : ''}>Quản trị viên</option>
                                    </select>
                                    <div class="form-text text-warning">
                                        <i class="bi bi-exclamation-triangle me-1"></i>
                                        Thay đổi vai trò thành Admin sẽ cho phép truy cập toàn bộ hệ thống.
                                    </div>
                                </div>
                            </c:if>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check-lg me-1"></i>${isEdit ? 'Cập nhật' : 'Tạo mới'}
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-secondary">
                                    Hủy
                                </a>
                            </div>
                        </form>
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
