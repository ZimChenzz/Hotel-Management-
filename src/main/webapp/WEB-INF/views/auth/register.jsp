<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng ký - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .auth-form {
            max-width: 600px;
            margin: 0 auto;
        }
        .auth-form .form-control,
        .auth-form .form-select {
            padding: 16px 18px;
            font-size: 16px;
            border-radius: 12px;
            border: 2px solid #e0e0e0;
            height: 56px;
        }
        .auth-form .form-control:focus,
        .auth-form .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(189, 156, 93, 0.15);
        }
        .auth-form .input-group {
            width: 100%;
        }
        .auth-form .input-group-text {
            padding: 16px 18px;
            border-radius: 12px 0 0 12px;
            border: 2px solid #e0e0e0;
            border-right: none;
            background: #f8f9fa;
            min-width: 56px;
            justify-content: center;
        }
        .auth-form .input-group .form-control {
            border-radius: 0 12px 12px 0;
        }
        .auth-form .form-control.is-invalid {
            border-color: #dc3545;
        }
        .auth-form label.form-label {
            font-size: 15px;
            margin-bottom: 8px;
        }
        .password-requirements {
            font-size: 13px;
        }
        .req-item {
            padding: 4px 0;
            color: #6c757d;
            transition: all 0.2s;
        }
        .req-item i {
            margin-right: 8px;
            font-size: 14px;
        }
        .req-item.met {
            color: #28a745;
            font-weight: 500;
        }
        .req-item.unmet {
            color: #dc3545;
        }
        #confirmPasswordMsg.match {
            color: #28a745;
        }
        #confirmPasswordMsg.mismatch {
            color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="auth-layout">
        <!-- Hero Section - Left -->
        <div class="auth-hero d-none d-lg-flex">
            <div class="auth-hero-content">
                <div class="auth-hero-logo">Luxury<span>Hotel</span></div>
                <h2 class="mb-4" style="font-family: var(--font-display);">Tham gia cùng chúng tôi</h2>
                <p class="auth-hero-text">Đăng ký để nhận ưu đãi độc quyền và đặt phòng nhanh chóng.</p>
                <div class="mt-5">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <i class="bi bi-gift" style="color: var(--secondary);"></i>
                        <span>Ưu đãi dành riêng thành viên</span>
                    </div>
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <i class="bi bi-lightning" style="color: var(--secondary);"></i>
                        <span>Đặt phòng nhanh chóng</span>
                    </div>
                    <div class="d-flex align-items-center gap-3">
                        <i class="bi bi-star" style="color: var(--secondary);"></i>
                        <span>Tích điểm thưởng mỗi lần đặt</span>
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

                <h2 class="auth-form-title">Tạo tài khoản</h2>
                <p class="auth-form-subtitle">Điền thông tin để đăng ký thành viên</p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" id="errorAlert">
                        <i class="bi bi-exclamation-circle me-2"></i>${error}
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/auth/register" id="registerForm">
                    <div class="mb-4">
                        <label for="email" class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                            <input type="email" class="form-control" id="email" name="email"
                                   value="${email}" placeholder="email@example.com" required
                                   oninput="checkFormValidity()">
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="fullName" class="form-label fw-semibold">Họ và tên <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-person"></i></span>
                            <input type="text" class="form-control" id="fullName" name="fullName"
                                   value="${fullName}" placeholder="Nguyễn Văn A" required
                                   oninput="checkFormValidity()">
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-4">
                            <label for="phone" class="form-label fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                                <input type="tel" class="form-control" id="phone" name="phone"
                                       value="${phone}" placeholder="0912345678" required
                                       pattern="0[0-9]{9,10}" oninput="checkFormValidity()">
                            </div>
                            <small class="text-muted">Bắt đầu bằng 0, 10-11 số</small>
                        </div>

                        <div class="col-md-6 mb-4">
                            <label for="address" class="form-label fw-semibold">Địa chỉ</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-geo-alt"></i></span>
                                <input type="text" class="form-control" id="address" name="address"
                                       value="${address}" placeholder="Thành phố Hồ Chí Minh">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-4">
                            <label for="password" class="form-label fw-semibold">Mật khẩu <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <input type="password" class="form-control" id="password" name="password"
                                       minlength="8" placeholder="Ít nhất 8 ký tự" required
                                       oninput="checkPasswordStrength(this.value)">
                            </div>
                            <div class="password-requirements mt-2">
                                <div class="req-item unmet" id="req-length"><i class="bi bi-circle"></i> Ít nhất 8 ký tự</div>
                                <div class="req-item unmet" id="req-upper"><i class="bi bi-circle"></i> Ít nhất 1 chữ hoa (A-Z)</div>
                                <div class="req-item unmet" id="req-lower"><i class="bi bi-circle"></i> Ít nhất 1 chữ thường (a-z)</div>
                                <div class="req-item unmet" id="req-digit"><i class="bi bi-circle"></i> Ít nhất 1 số (0-9)</div>
                                <div class="req-item unmet" id="req-special"><i class="bi bi-circle"></i> Ít nhất 1 ký tự đặc biệt (!@#$...)</div>
                            </div>
                        </div>

                        <div class="col-md-6 mb-4">
                            <label for="confirmPassword" class="form-label fw-semibold">Xác nhận mật khẩu <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                                <input type="password" class="form-control" id="confirmPassword"
                                       name="confirmPassword" placeholder="Nhập lại mật khẩu" required
                                       oninput="checkPasswordMatch()">
                            </div>
                            <small class="mt-2 fw-semibold" id="confirmPasswordMsg"></small>
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="form-check">
                            <input type="checkbox" class="form-check-input" id="terms" name="terms" required
                                   onchange="checkFormValidity()">
                            <label class="form-check-label" for="terms">
                                Tôi đồng ý với <a href="#" style="color: var(--secondary-dark);">Điều khoản dịch vụ</a>
                            </label>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 btn-lg mb-3" id="submitBtn" disabled>
                        <i class="bi bi-person-plus me-2"></i>Đăng ký
                    </button>
                </form>

                <div class="text-center mt-4">
                    <span class="text-muted">Đã có tài khoản?</span>
                    <a href="${pageContext.request.contextPath}/auth/login" style="color: var(--secondary-dark); font-weight: 500;">
                        Đăng nhập
                    </a>
                </div>

                <div class="text-center mt-4 pt-4 border-top">
                    <a href="${pageContext.request.contextPath}/" class="text-muted small">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại trang chủ
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function checkPasswordStrength(password) {
            const reqLength = document.getElementById('req-length');
            const reqUpper = document.getElementById('req-upper');
            const reqLower = document.getElementById('req-lower');
            const reqDigit = document.getElementById('req-digit');
            const reqSpecial = document.getElementById('req-special');

            // Update each requirement
            if (password.length >= 8) {
                reqLength.classList.add('met');
                reqLength.classList.remove('unmet');
                reqLength.querySelector('i').className = 'bi bi-check-circle-fill';
            } else {
                reqLength.classList.remove('met');
                reqLength.classList.add('unmet');
                reqLength.querySelector('i').className = 'bi bi-circle';
            }

            if (/[A-Z]/.test(password)) {
                reqUpper.classList.add('met');
                reqUpper.classList.remove('unmet');
                reqUpper.querySelector('i').className = 'bi bi-check-circle-fill';
            } else {
                reqUpper.classList.remove('met');
                reqUpper.classList.add('unmet');
                reqUpper.querySelector('i').className = 'bi bi-circle';
            }

            if (/[a-z]/.test(password)) {
                reqLower.classList.add('met');
                reqLower.classList.remove('unmet');
                reqLower.querySelector('i').className = 'bi bi-check-circle-fill';
            } else {
                reqLower.classList.remove('met');
                reqLower.classList.add('unmet');
                reqLower.querySelector('i').className = 'bi bi-circle';
            }

            if (/[0-9]/.test(password)) {
                reqDigit.classList.add('met');
                reqDigit.classList.remove('unmet');
                reqDigit.querySelector('i').className = 'bi bi-check-circle-fill';
            } else {
                reqDigit.classList.remove('met');
                reqDigit.classList.add('unmet');
                reqDigit.querySelector('i').className = 'bi bi-circle';
            }

            if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
                reqSpecial.classList.add('met');
                reqSpecial.classList.remove('unmet');
                reqSpecial.querySelector('i').className = 'bi bi-check-circle-fill';
            } else {
                reqSpecial.classList.remove('met');
                reqSpecial.classList.add('unmet');
                reqSpecial.querySelector('i').className = 'bi bi-circle';
            }

            checkFormValidity();
        }

        function checkPasswordMatch() {
            const password = document.getElementById('password').value;
            const confirm = document.getElementById('confirmPassword').value;
            const msg = document.getElementById('confirmPasswordMsg');

            if (confirm.length === 0) {
                msg.textContent = '';
                msg.className = '';
                return;
            }

            if (password === confirm) {
                msg.textContent = 'Mật khẩu khớp';
                msg.className = 'match';
            } else {
                msg.textContent = 'Mật khẩu không khớp';
                msg.className = 'mismatch';
            }

            checkFormValidity();
        }

        function checkFormValidity() {
            const form = document.getElementById('registerForm');
            const password = document.getElementById('password').value;
            const confirm = document.getElementById('confirmPassword').value;
            const submitBtn = document.getElementById('submitBtn');
            const errorAlert = document.getElementById('errorAlert');

            // Hide error alert when user starts typing
            if (errorAlert) {
                errorAlert.style.display = 'none';
            }

            let formValid = form.checkValidity();
            let passwordsMatch = password === confirm;
            let passwordStrong = isStrongPassword(password);

            let isValid = formValid && passwordsMatch && passwordStrong;
            submitBtn.disabled = !isValid;

            // Debug: uncomment to see validation status in console
            // console.log('formValid:', formValid, 'passwordsMatch:', passwordsMatch, 'passwordStrong:', passwordStrong, 'isValid:', isValid);
        }

        function isStrongPassword(password) {
            if (!password || password.length < 8) return false;
            const hasUpper = /[A-Z]/.test(password);
            const hasLower = /[a-z]/.test(password);
            const hasDigit = /[0-9]/.test(password);
            const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
            return hasUpper && hasLower && hasDigit && hasSpecial;
        }

        document.addEventListener('DOMContentLoaded', function() {
            checkFormValidity();
        });
    </script>
</body>
</html>
