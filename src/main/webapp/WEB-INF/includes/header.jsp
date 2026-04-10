<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="public-navbar navbar navbar-expand-lg" id="mainNav">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">
            Luxury<span>Hotel</span>
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <i class="bi bi-list fs-4" style="color: var(--text-inverse);"></i>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/">Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/rooms">Phòng</a>
                </li>
            </ul>
            <ul class="navbar-nav">
                <c:choose>
                    <c:when test="${not empty sessionScope.loggedInAccount}">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                                <i class="bi bi-person-circle me-1"></i>
                                ${sessionScope.loggedInAccount.fullName}
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/profile">
                                    <i class="bi bi-person me-2"></i>Hồ sơ
                                </a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/bookings">
                                    <i class="bi bi-calendar-check me-2"></i>Đặt phòng của tôi
                                </a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/auth/change-password">
                                    <i class="bi bi-key me-2"></i>Đổi mật khẩu
                                </a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth/logout">
                                    <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
                                </a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/auth/login">Đăng nhập</a>
                        </li>
                        <li class="nav-item ms-2">
                            <a class="btn btn-primary btn-sm px-3" href="${pageContext.request.contextPath}/auth/register">
                                Đăng ký
                            </a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>
<script>
// Navbar scroll effect
window.addEventListener('scroll', function() {
    const nav = document.getElementById('mainNav');
    if (window.scrollY > 50) {
        nav.classList.add('scrolled');
    } else {
        nav.classList.remove('scrolled');
    }
});
</script>
