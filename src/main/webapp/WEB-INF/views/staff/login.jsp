<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập Nhân viên - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/auth-styles.css" rel="stylesheet">
    <style>
        .staff-badge {
            background: linear-gradient(135deg, var(--hotel-navy) 0%, #2a2a4e 100%);
            color: var(--hotel-gold);
            padding: 0.5rem 1rem;
            border-radius: 4px;
            font-size: 0.85rem;
            font-weight: 600;
            letter-spacing: 1px;
            text-transform: uppercase;
            display: inline-block;
            margin-bottom: 1rem;
        }
        .auth-hero-content h1 {
            font-size: 2.5rem;
        }
    </style>
</head>
<body style="font-family: 'Lato', sans-serif;">
    <div class="auth-container">
        <!-- Hero Section - Left -->
        <div class="auth-hero d-none d-lg-flex">
            <img src="https://images.unsplash.com/photo-1582719508461-905c673771eb?w=1200&q=80" alt="Hotel Staff"
                 style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; opacity: 0.25;">
            <div class="auth-hero-overlay"></div>
            <div class="auth-hero-content">
                <h1>Cổng Nhân Viên</h1>
                <p>Hệ thống quản lý dành cho nhân viên Luxury Hotel</p>
            </div>
        </div>

        <!-- Form Section - Right -->
        <div class="auth-form-section">
            <div class="auth-form-container">
                <div class="auth-logo">
                    <div class="auth-logo-text">Luxury<span>Hotel</span></div>
                </div>

                <div class="auth-card">
                    <div class="staff-badge">Cổng Nhân Viên</div>
                    <h2>Đăng nhập Nhân viên</h2>
                    <p class="auth-subtitle">Đăng nhập để truy cập hệ thống quản lý</p>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/staff/login" class="auth-form">
                        <input type="hidden" name="returnUrl" value="${returnUrl}">

                        <div class="mb-4">
                            <label for="email" class="form-label fw-bold">Email nhân viên</label>
                            <input type="email" class="form-control form-control-lg" id="email" name="email"
                                   value="${email}" placeholder="nhanvien@luxuryhotel.com" required>
                        </div>

                        <div class="mb-4">
                            <label for="password" class="form-label fw-bold">Mật khẩu</label>
                            <input type="password" class="form-control form-control-lg" id="password"
                                   name="password" placeholder="Nhập mật khẩu" required>
                        </div>

                        <button type="submit" class="btn btn-hotel-primary btn-lg w-100 py-3">Đăng nhập</button>
                    </form>

                    <div class="auth-footer mt-4">
                        <a href="${pageContext.request.contextPath}/" class="auth-link">← Về trang chủ</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
