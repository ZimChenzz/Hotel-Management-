<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đổi mật khẩu - Luxury Hotel</title>
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
            <h1 class="public-hero-title"><i class="bi bi-key me-2"></i>Đổi mật khẩu</h1>
        </div>
    </section>

    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-shield-lock me-2"></i>Cập nhật mật khẩu
                    </div>
                    <div class="card-body p-4">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-circle me-2"></i>${error}
                            </div>
                        </c:if>
                        <c:if test="${not empty success}">
                            <div class="alert alert-success">
                                <i class="bi bi-check-circle me-2"></i>${success}
                            </div>
                        </c:if>

                        <form method="post" id="changePasswordForm">
                            <div class="mb-3">
                                <label for="currentPassword" class="form-label">Mật khẩu hiện tại <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                    <input type="password" class="form-control" id="currentPassword"
                                           name="currentPassword" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="newPassword" class="form-label">Mật khẩu mới <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                                    <input type="password" class="form-control" id="newPassword"
                                           name="newPassword" minlength="8" required>
                                </div>
                                <div class="form-text">Tối thiểu 8 ký tự, phải khác biệt đáng kể so với mật khẩu cũ</div>
                                <div id="similarityWarning" class="text-danger small mt-1" style="display:none;">
                                    <i class="bi bi-exclamation-triangle me-1"></i>Mật khẩu mới quá giống mật khẩu cũ. Vui lòng chọn mật khẩu khác biệt hơn.
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="confirmPassword" class="form-label">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                                    <input type="password" class="form-control" id="confirmPassword"
                                           name="confirmPassword" required>
                                </div>
                                <div id="confirmWarning" class="text-danger small mt-1" style="display:none;">
                                    <i class="bi bi-exclamation-triangle me-1"></i>Mật khẩu xác nhận không khớp.
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100" id="submitBtn">
                                <i class="bi bi-check-lg me-2"></i>Đổi mật khẩu
                            </button>
                        </form>

                        <div class="text-center mt-4 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/customer/profile" class="text-muted">
                                <i class="bi bi-arrow-left me-1"></i>Quay về hồ sơ
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Levenshtein distance để kiểm tra độ tương đồng phía client
        function levenshtein(a, b) {
            var m = a.length, n = b.length;
            var dp = Array.from({length: m + 1}, () => new Array(n + 1).fill(0));
            for (var i = 0; i <= m; i++) dp[i][0] = i;
            for (var j = 0; j <= n; j++) dp[0][j] = j;
            for (var i = 1; i <= m; i++) {
                for (var j = 1; j <= n; j++) {
                    var cost = a[i-1] === b[j-1] ? 0 : 1;
                    dp[i][j] = Math.min(dp[i-1][j]+1, dp[i][j-1]+1, dp[i-1][j-1]+cost);
                }
            }
            return dp[m][n];
        }

        function isTooSimilar(oldPw, newPw) {
            if (!oldPw || !newPw) return false;
            if (oldPw === newPw) return true;
            if (oldPw.toLowerCase() === newPw.toLowerCase()) return true;
            var maxLen = Math.max(oldPw.length, newPw.length);
            if (maxLen === 0) return true;
            var dist = levenshtein(oldPw.toLowerCase(), newPw.toLowerCase());
            var similarity = 1.0 - (dist / maxLen);
            return similarity >= 0.7;
        }

        var currentPw = document.getElementById('currentPassword');
        var newPw = document.getElementById('newPassword');
        var confirmPw = document.getElementById('confirmPassword');
        var simWarn = document.getElementById('similarityWarning');
        var confWarn = document.getElementById('confirmWarning');
        var submitBtn = document.getElementById('submitBtn');

        function validate() {
            var similar = isTooSimilar(currentPw.value, newPw.value);
            var mismatch = confirmPw.value && newPw.value !== confirmPw.value;

            simWarn.style.display = (currentPw.value && newPw.value && similar) ? 'block' : 'none';
            newPw.classList.toggle('is-invalid', currentPw.value && newPw.value && similar);

            confWarn.style.display = mismatch ? 'block' : 'none';
            confirmPw.classList.toggle('is-invalid', mismatch);

            submitBtn.disabled = similar || mismatch;
        }

        currentPw.addEventListener('input', validate);
        newPw.addEventListener('input', validate);
        confirmPw.addEventListener('input', validate);

        document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
            validate();
            if (submitBtn.disabled) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>
