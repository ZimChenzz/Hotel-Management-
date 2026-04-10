<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt lại mật khẩu - Luxury Hotel</title>
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
                <h2 class="mb-4" style="font-family: var(--font-display);">Đặt mật khẩu mới</h2>
                <p class="auth-hero-text">Tạo mật khẩu mới cho tài khoản của bạn. Mật khẩu phải có ít nhất 8 ký tự.</p>
                <div class="mt-5">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <i class="bi bi-check-circle-fill" style="color: var(--secondary);"></i>
                        <span>Nhập email của bạn</span>
                    </div>
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <i class="bi bi-check-circle-fill" style="color: var(--secondary);"></i>
                        <span>Xác thực mã OTP</span>
                    </div>
                    <div class="d-flex align-items-center gap-3">
                        <i class="bi bi-3-circle-fill" style="color: var(--secondary);"></i>
                        <span>Đặt mật khẩu mới</span>
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

                <h2 class="auth-form-title">Đặt mật khẩu mới</h2>
                <p class="auth-form-subtitle">Nhập mật khẩu mới cho tài khoản của bạn</p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-circle me-2"></i>${error}
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/auth/reset-password">
                    <div class="mb-3">
                        <label for="newPassword" class="form-label">Mật khẩu mới</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock"></i></span>
                            <input type="password" class="form-control" id="newPassword"
                                   name="newPassword" placeholder="Nhập mật khẩu mới" required minlength="8">
                        </div>
                        <div class="form-text">Mật khẩu phải có ít nhất 8 ký tự</div>
                    </div>

                    <div class="mb-4">
                        <label for="confirmPassword" class="form-label">Xác nhận mật khẩu</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                            <input type="password" class="form-control" id="confirmPassword"
                                   name="confirmPassword" placeholder="Nhập lại mật khẩu" required minlength="8">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 btn-lg mb-3">
                        <i class="bi bi-check-lg me-2"></i>Đặt lại mật khẩu
                    </button>
                </form>

                <div class="text-center mt-4">
                    <a href="${pageContext.request.contextPath}/auth/login" class="text-muted small">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại đăng nhập
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.querySelector('form').addEventListener('submit', function(e) {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('Mật khẩu xác nhận không khớp');
            }
        });
    </script>
</body>
</html>
