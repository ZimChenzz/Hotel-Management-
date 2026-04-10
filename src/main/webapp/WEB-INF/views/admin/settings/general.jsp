<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cài đặt hệ thống - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="settings" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Cài đặt hệ thống" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Breadcrumb -->
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Cài đặt</li>
                    </ol>
                </nav>

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Cài đặt hệ thống</h1>
                        <p class="page-header-subtitle">Cấu hình và quản lý hệ thống</p>
                    </div>
                </div>

                <!-- Alerts -->
                <c:if test="${param.success == 'saved'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Cài đặt đã được lưu thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Settings Tabs -->
                <ul class="nav nav-tabs mb-4" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active" data-bs-toggle="tab" href="#general">
                            <i class="bi bi-gear me-2"></i>Chung
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-bs-toggle="tab" href="#security">
                            <i class="bi bi-shield-lock me-2"></i>Bảo mật
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-bs-toggle="tab" href="#audit">
                            <i class="bi bi-clock-history me-2"></i>Nhật ký hoạt động
                        </a>
                    </li>
                </ul>

                <div class="tab-content">
                    <!-- General Settings -->
                    <div class="tab-pane fade show active" id="general">
                        <div class="card">
                            <div class="card-header">
                                <i class="bi bi-building me-2"></i>Thông tin hệ thống
                            </div>
                            <div class="card-body">
                                <form method="post" action="${pageContext.request.contextPath}/admin/settings/save">
                                    <input type="hidden" name="section" value="general">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label class="form-label">Tên hệ thống</label>
                                                <input type="text" class="form-control" name="systemName"
                                                       value="${settings.systemName != null ? settings.systemName : 'Luxury Hotel'}">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Email liên hệ</label>
                                                <input type="email" class="form-control" name="contactEmail"
                                                       value="${settings.contactEmail}">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Số điện thoại</label>
                                                <input type="tel" class="form-control" name="contactPhone"
                                                       value="${settings.contactPhone}">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label class="form-label">Địa chỉ</label>
                                                <textarea class="form-control" name="address" rows="3">${settings.address}</textarea>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Múi giờ</label>
                                                <select class="form-select" name="timezone">
                                                    <option value="Asia/Ho_Chi_Minh" selected>Việt Nam (GMT+7)</option>
                                                    <option value="Asia/Bangkok">Bangkok (GMT+7)</option>
                                                    <option value="Asia/Singapore">Singapore (GMT+8)</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Đơn vị tiền tệ</label>
                                                <select class="form-select" name="currency">
                                                    <option value="VND" selected>VNĐ - Việt Nam Đồng</option>
                                                    <option value="USD">USD - US Dollar</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-check-lg me-1"></i>Lưu cài đặt
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Security Settings -->
                    <div class="tab-pane fade" id="security">
                        <div class="card">
                            <div class="card-header">
                                <i class="bi bi-shield-lock me-2"></i>Cài đặt bảo mật
                            </div>
                            <div class="card-body">
                                <form method="post" action="${pageContext.request.contextPath}/admin/settings/save">
                                    <input type="hidden" name="section" value="security">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <h6 class="text-muted mb-3">Chính sách mật khẩu</h6>
                                            <div class="mb-3">
                                                <label class="form-label">Độ dài mật khẩu tối thiểu</label>
                                                <input type="number" class="form-control" name="minPasswordLength"
                                                       value="${settings.minPasswordLength != null ? settings.minPasswordLength : 8}" min="6" max="20">
                                            </div>
                                            <div class="mb-3">
                                                <div class="form-check">
                                                    <input class="form-check-input" type="checkbox" name="requireUppercase"
                                                           id="requireUppercase" ${settings.requireUppercase ? 'checked' : ''}>
                                                    <label class="form-check-label" for="requireUppercase">
                                                        Yêu cầu chữ in hoa
                                                    </label>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <div class="form-check">
                                                    <input class="form-check-input" type="checkbox" name="requireNumber"
                                                           id="requireNumber" ${settings.requireNumber ? 'checked' : ''}>
                                                    <label class="form-check-label" for="requireNumber">
                                                        Yêu cầu chữ số
                                                    </label>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <div class="form-check">
                                                    <input class="form-check-input" type="checkbox" name="requireSpecial"
                                                           id="requireSpecial" ${settings.requireSpecial ? 'checked' : ''}>
                                                    <label class="form-check-label" for="requireSpecial">
                                                        Yêu cầu ký tự đặc biệt
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <h6 class="text-muted mb-3">Phiên làm việc</h6>
                                            <div class="mb-3">
                                                <label class="form-label">Thời gian timeout (phút)</label>
                                                <input type="number" class="form-control" name="sessionTimeout"
                                                       value="${settings.sessionTimeout != null ? settings.sessionTimeout : 30}" min="5" max="480">
                                                <div class="form-text">Tự động đăng xuất sau thời gian không hoạt động</div>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Số lần đăng nhập thất bại tối đa</label>
                                                <input type="number" class="form-control" name="maxLoginAttempts"
                                                       value="${settings.maxLoginAttempts != null ? settings.maxLoginAttempts : 5}" min="3" max="10">
                                                <div class="form-text">Khóa tài khoản sau số lần đăng nhập thất bại</div>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Thời gian khóa (phút)</label>
                                                <input type="number" class="form-control" name="lockoutDuration"
                                                       value="${settings.lockoutDuration != null ? settings.lockoutDuration : 15}" min="5" max="60">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-check-lg me-1"></i>Lưu cài đặt
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Audit Log -->
                    <div class="tab-pane fade" id="audit">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <span><i class="bi bi-clock-history me-2"></i>Nhật ký hoạt động</span>
                                <button class="btn btn-sm btn-outline-secondary">
                                    <i class="bi bi-download me-1"></i>Xuất file
                                </button>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table-modern">
                                        <thead>
                                            <tr>
                                                <th>Thời gian</th>
                                                <th>Người dùng</th>
                                                <th>Hành động</th>
                                                <th>Chi tiết</th>
                                                <th>IP</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty auditLogs}">
                                                    <tr>
                                                        <td colspan="5">
                                                            <div class="empty-state py-5">
                                                                <div class="empty-state-icon">
                                                                    <i class="bi bi-clock-history"></i>
                                                                </div>
                                                                <h3 class="empty-state-title">Chưa có nhật ký</h3>
                                                                <p class="empty-state-text">Các hoạt động sẽ được ghi lại tại đây.</p>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="log" items="${auditLogs}">
                                                        <tr>
                                                            <td class="text-nowrap">${log.timestamp}</td>
                                                            <td>${log.userName}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${log.action == 'LOGIN'}">
                                                                        <span class="badge badge-success">Đăng nhập</span>
                                                                    </c:when>
                                                                    <c:when test="${log.action == 'LOGOUT'}">
                                                                        <span class="badge badge-secondary">Đăng xuất</span>
                                                                    </c:when>
                                                                    <c:when test="${log.action == 'CREATE'}">
                                                                        <span class="badge badge-info">Tạo mới</span>
                                                                    </c:when>
                                                                    <c:when test="${log.action == 'UPDATE'}">
                                                                        <span class="badge badge-warning">Cập nhật</span>
                                                                    </c:when>
                                                                    <c:when test="${log.action == 'DELETE'}">
                                                                        <span class="badge badge-danger">Xóa</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge badge-secondary">${log.action}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>${log.details}</td>
                                                            <td class="text-muted">${log.ipAddress}</td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
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

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
