<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hoàn tất thông tin - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <div class="auth-layout">
        <!-- Hero Section - Left -->
        <div class="auth-hero d-none d-lg-flex">
            <div class="auth-hero-content">
                <div class="auth-hero-logo">Luxury<span>Hotel</span></div>
                <h2 class="mb-4" style="font-family: var(--font-display);">Chào mừng bạn!</h2>
                <p class="auth-hero-text">Chỉ còn một bước nữa để hoàn tất đăng ký.</p>
                <div class="mt-5">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <i class="bi bi-check-circle" style="color: var(--secondary);"></i>
                        <span>Xác thực Google thành công</span>
                    </div>
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <i class="bi bi-pencil-square" style="color: var(--secondary);"></i>
                        <span>Bổ sung thông tin liên hệ</span>
                    </div>
                    <div class="d-flex align-items-center gap-3">
                        <i class="bi bi-rocket-takeoff" style="color: var(--secondary);"></i>
                        <span>Bắt đầu trải nghiệm</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Form Section - Right -->
        <div class="auth-form-container">
            <div class="auth-form">
                <!-- Logo for mobile -->
                <div class="text-center d-lg-none mb-4">
                    <div class="auth-hero-logo" style="color: var(--primary);">Luxury<span>Hotel</span></div>
                </div>

                <h2 class="auth-form-title">Hoàn tất thông tin</h2>
                <p class="auth-form-subtitle">Vui lòng cung cấp thêm thông tin để chúng tôi phục vụ bạn tốt hơn</p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-circle me-2"></i>${error}
                    </div>
                </c:if>

                <!-- User info from Google -->
                <div class="alert alert-info mb-4">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-google"></i>
                        <span>Đăng nhập với: <strong>${account.email}</strong></span>
                    </div>
                    <div class="mt-1 small text-muted">
                        Tên: ${account.fullName}
                    </div>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/auth/complete-profile">
                    <div class="mb-3">
                        <label for="phone" class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                            <input type="tel" class="form-control" id="phone" name="phone"
                                   value="${account.phone}" placeholder="0901234567" required>
                        </div>
                        <div class="form-text">Để chúng tôi liên hệ khi cần thiết</div>
                    </div>

                    <div class="mb-4">
                        <label for="address" class="form-label">Địa chỉ</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-geo-alt"></i></span>
                            <input type="text" class="form-control" id="address" name="address"
                                   value="${account.address}" placeholder="Số nhà, đường, quận/huyện, thành phố">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2">
                        <i class="bi bi-check-lg me-2"></i>Hoàn tất đăng ký
                    </button>
                </form>

                <div class="text-center mt-4">
                    <a href="${pageContext.request.contextPath}/" class="text-decoration-none">
                        <i class="bi bi-arrow-left me-1"></i>Bỏ qua, về trang chủ
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
