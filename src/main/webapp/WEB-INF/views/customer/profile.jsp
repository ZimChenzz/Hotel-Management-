<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thông tin cá nhân - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Page Header -->
    <section class="public-hero public-hero-small">
        <div class="container">
            <h1 class="public-hero-title"><i class="bi bi-person-circle me-2"></i>Tài khoản của tôi</h1>
        </div>
    </section>

    <div class="container py-5">
        <div class="row g-4">
            <!-- Sidebar -->
            <div class="col-lg-3">
                <div class="card">
                    <div class="card-header text-center py-4" style="background: var(--secondary-gradient); color: white;">
                        <div class="topbar-user-avatar mx-auto mb-2" style="width: 64px; height: 64px; font-size: 1.5rem; background: rgba(255,255,255,0.2);">
                            <c:choose>
                                <c:when test="${not empty account.fullName}">
                                    ${account.fullName.substring(0,1).toUpperCase()}
                                </c:when>
                                <c:otherwise>U</c:otherwise>
                            </c:choose>
                        </div>
                        <h6 class="mb-1">${account.fullName}</h6>
                        <small style="opacity: 0.9;">${account.email}</small>
                    </div>
                    <div class="card-body p-0">
                        <nav class="customer-sidebar-nav">
                            <a href="${pageContext.request.contextPath}/customer/profile" class="customer-nav-item active">
                                <i class="bi bi-person-gear"></i>Thông tin cá nhân
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/bookings" class="customer-nav-item">
                                <i class="bi bi-calendar-check"></i>Lịch sử đặt phòng
                            </a>
                            <a href="${pageContext.request.contextPath}/auth/change-password" class="customer-nav-item">
                                <i class="bi bi-key"></i>Đổi mật khẩu
                            </a>
                            <a href="${pageContext.request.contextPath}/auth/logout" class="customer-nav-item text-danger">
                                <i class="bi bi-box-arrow-right"></i>Đăng xuất
                            </a>
                        </nav>
                    </div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-lg-9">
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-person-gear me-2"></i>Thông tin cá nhân
                    </div>
                    <div class="card-body">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-triangle me-2"></i>${error}
                            </div>
                        </c:if>
                        <c:if test="${not empty success}">
                            <div class="alert alert-success">
                                <i class="bi bi-check-circle me-2"></i>${success}
                            </div>
                        </c:if>

                        <form method="post">
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label class="form-label">Email</label>
                                    <input type="email" class="form-control bg-light" value="${account.email}" disabled>
                                    <div class="form-text">Email không thể thay đổi</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="fullName" value="${account.fullName}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Số điện thoại</label>
                                    <input type="tel" class="form-control" name="phone" value="${account.phone}" placeholder="0912345678">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Ngày tạo tài khoản</label>
                                    <input type="text" class="form-control bg-light" value="${account.createdAt}" disabled>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Địa chỉ</label>
                                    <textarea class="form-control" name="address" rows="2" placeholder="Nhập địa chỉ của bạn">${account.address}</textarea>
                                </div>
                            </div>
                            <hr class="my-4">
                            <div class="d-flex justify-content-end">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check-lg me-2"></i>Cập nhật thông tin
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
