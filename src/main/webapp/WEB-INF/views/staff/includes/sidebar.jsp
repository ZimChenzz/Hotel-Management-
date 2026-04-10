<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="app-sidebar">
    <div class="sidebar-header">
        <a href="${pageContext.request.contextPath}/staff/dashboard" class="sidebar-logo">
            Luxury<span>Hotel</span>
        </a>
        <span class="sidebar-badge">Nhân viên</span>
    </div>

    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/staff/dashboard"
           class="sidebar-nav-item ${activePage == 'dashboard' ? 'active' : ''}">
            <i class="bi bi-speedometer2"></i>
            <span>Bảng điều khiển</span>
        </a>

        <div class="sidebar-section">Quản lý phòng</div>
        <a href="${pageContext.request.contextPath}/staff/rooms"
           class="sidebar-nav-item ${activePage == 'rooms' ? 'active' : ''}">
            <i class="bi bi-door-open"></i>
            <span>Sơ đồ phòng</span>
        </a>

        <div class="sidebar-section">Đặt phòng</div>
        <a href="${pageContext.request.contextPath}/staff/bookings/walkin"
           class="sidebar-nav-item ${activePage == 'walkin' ? 'active' : ''}">
            <i class="bi bi-person-plus"></i>
            <span>Đặt phòng tại quầy</span>
        </a>
        <a href="${pageContext.request.contextPath}/staff/bookings"
           class="sidebar-nav-item ${activePage == 'bookings' ? 'active' : ''}">
            <i class="bi bi-calendar-check"></i>
            <span>Danh sách đặt phòng</span>
        </a>
        <a href="${pageContext.request.contextPath}/staff/bookings?status=Confirmed"
           class="sidebar-nav-item ${activePage == 'checkin' ? 'active' : ''}">
            <i class="bi bi-box-arrow-in-right"></i>
            <span>Chờ check-in</span>
        </a>
        <a href="${pageContext.request.contextPath}/staff/bookings?status=CheckedIn"
           class="sidebar-nav-item ${activePage == 'checkout' ? 'active' : ''}">
            <i class="bi bi-box-arrow-right"></i>
            <span>Chờ check-out</span>
        </a>

        <div class="sidebar-section">Dịch vụ</div>
        <a href="${pageContext.request.contextPath}/staff/cleaning"
           class="sidebar-nav-item ${activePage == 'cleaning' ? 'active' : ''}">
            <i class="bi bi-stars"></i>
            <span>Dọn phòng</span>
        </a>
        <a href="${pageContext.request.contextPath}/staff/service-requests"
           class="sidebar-nav-item ${activePage == 'service-requests' ? 'active' : ''}">
            <i class="bi bi-bell"></i>
            <span>Yêu cầu dịch vụ</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="sidebar-user">
            <div class="sidebar-user-avatar">
                <c:choose>
                    <c:when test="${not empty sessionScope.loggedInAccount.fullName}">
                        ${sessionScope.loggedInAccount.fullName.substring(0, 1)}
                    </c:when>
                    <c:otherwise>S</c:otherwise>
                </c:choose>
            </div>
            <div class="sidebar-user-info">
                <div class="sidebar-user-name">${sessionScope.loggedInAccount.fullName}</div>
                <div class="sidebar-user-role">Nhân viên</div>
            </div>
        </div>
    </div>
</aside>
