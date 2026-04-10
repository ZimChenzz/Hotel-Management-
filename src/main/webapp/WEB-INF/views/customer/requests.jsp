<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Yêu cầu dịch vụ - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <section class="public-hero public-hero-small">
        <div class="container">
            <h1 class="public-hero-title"><i class="bi bi-bell me-2"></i>Yêu cầu dịch vụ</h1>
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
                                <c:when test="${not empty sessionScope.loggedInAccount.fullName}">
                                    ${sessionScope.loggedInAccount.fullName.substring(0,1).toUpperCase()}
                                </c:when>
                                <c:otherwise>U</c:otherwise>
                            </c:choose>
                        </div>
                        <h6 class="mb-1">${sessionScope.loggedInAccount.fullName}</h6>
                        <small style="opacity: 0.9;">${sessionScope.loggedInAccount.email}</small>
                    </div>
                    <div class="card-body p-0">
                        <nav class="customer-sidebar-nav">
                            <a href="${pageContext.request.contextPath}/customer/profile" class="customer-nav-item">
                                <i class="bi bi-person-gear"></i>Thông tin cá nhân
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/bookings" class="customer-nav-item">
                                <i class="bi bi-calendar-check"></i>Lịch sử đặt phòng
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/reviews" class="customer-nav-item">
                                <i class="bi bi-star"></i>Đánh giá của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/requests" class="customer-nav-item active">
                                <i class="bi bi-bell"></i>Yêu cầu dịch vụ
                            </a>
                            <a href="${pageContext.request.contextPath}/auth/change-password" class="customer-nav-item">
                                <i class="bi bi-key"></i>Đổi mật khẩu
                            </a>
                        </nav>
                    </div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-lg-9">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h4 class="mb-1" style="font-family: var(--font-display); color: var(--primary);">Yêu cầu dịch vụ</h4>
                        <p class="text-muted mb-0">Tất cả yêu cầu dịch vụ của bạn</p>
                    </div>
                    <span class="badge bg-secondary fs-6">${serviceRequests.size()} yêu cầu</span>
                </div>

                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success alert-dismissible fade show mb-4">
                        <i class="bi bi-check-circle me-2"></i>${successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show mb-4">
                        <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Create Request Form -->
                <c:if test="${not empty checkedInBookings}">
                    <div class="card mb-4">
                        <div class="card-header">
                            <i class="bi bi-plus-circle me-2"></i>Tạo yêu cầu mới
                        </div>
                        <div class="card-body">
                            <form method="post" action="${pageContext.request.contextPath}/customer/requests/create">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Đặt phòng</label>
                                        <select name="bookingId" class="form-select" required>
                                            <option value="">-- Chọn đặt phòng --</option>
                                            <c:forEach var="b" items="${checkedInBookings}">
                                                <option value="${b.bookingId}">
                                                    #${b.bookingId}
                                                    <c:if test="${not empty b.room}"> - Phòng ${b.room.roomNumber}</c:if>
                                                    <c:if test="${not empty b.roomType}"> (${b.roomType.typeName})</c:if>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Loại dịch vụ</label>
                                        <select name="serviceType" class="form-select" required>
                                            <option value="">-- Chọn loại --</option>
                                            <option value="Cleaning">Dọn phòng</option>
                                            <option value="Maintenance">Bảo trì</option>
                                            <option value="Food & Beverage">Đồ ăn & Nước uống</option>
                                            <option value="Supplies">Vật dụng</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Mức độ</label>
                                        <select name="priority" class="form-select">
                                            <option value="Normal">Bình thường</option>
                                            <option value="Low">Thấp</option>
                                            <option value="High">Cao</option>
                                            <option value="Urgent">Khẩn cấp</option>
                                        </select>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">Mô tả (không bắt buộc)</label>
                                        <textarea name="description" class="form-control" rows="2"
                                                  placeholder="Mô tả chi tiết yêu cầu của bạn..." maxlength="500"></textarea>
                                    </div>
                                    <div class="col-12">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-send me-1"></i>Gửi yêu cầu
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:if>

                <c:if test="${empty serviceRequests}">
                    <div class="card">
                        <div class="card-body">
                            <div class="empty-state">
                                <div class="empty-state-icon"><i class="bi bi-bell-slash"></i></div>
                                <h3 class="empty-state-title">Chưa có yêu cầu nào</h3>
                                <p class="empty-state-text">Bạn chưa gửi yêu cầu dịch vụ nào.</p>
                            </div>
                        </div>
                    </div>
                </c:if>

                <c:if test="${not empty serviceRequests}">
                    <div class="card">
                        <div class="card-header">
                            <i class="bi bi-list-check me-2"></i>Danh sách yêu cầu
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th class="ps-4">Đặt phòng</th>
                                            <th>Loại dịch vụ</th>
                                            <th>Mô tả</th>
                                            <th>Ưu tiên</th>
                                            <th>Thời gian gửi</th>
                                            <th>Trạng thái</th>
                                            <th class="text-end pe-4">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="sr" items="${serviceRequests}">
                                            <tr>
                                                <td class="ps-4">
                                                    <a href="${pageContext.request.contextPath}/customer/booking?id=${sr.bookingId}"
                                                       class="text-decoration-none fw-semibold">
                                                        #${sr.bookingId}
                                                    </a>
                                                    <c:if test="${not empty sr.roomNumber}">
                                                        <br><small class="text-muted">Phòng ${sr.roomNumber}</small>
                                                    </c:if>
                                                    <c:if test="${empty sr.roomNumber && not empty sr.booking}">
                                                        <br><small class="text-muted">${sr.booking.room.roomType.typeName}</small>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${sr.serviceType == 'Cleaning'}">
                                                            <i class="bi bi-stars text-warning me-1"></i>
                                                        </c:when>
                                                        <c:when test="${sr.serviceType == 'Maintenance'}">
                                                            <i class="bi bi-wrench text-info me-1"></i>
                                                        </c:when>
                                                        <c:when test="${sr.serviceType == 'Food & Beverage'}">
                                                            <i class="bi bi-cup-hot text-danger me-1"></i>
                                                        </c:when>
                                                        <c:when test="${sr.serviceType == 'Supplies'}">
                                                            <i class="bi bi-box-seam text-success me-1"></i>
                                                        </c:when>
                                                    </c:choose>
                                                    ${sr.serviceType}
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty sr.description}">
                                                            <small>${sr.description}</small>
                                                        </c:when>
                                                        <c:otherwise><small class="text-muted">--</small></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${sr.priority == 'Urgent'}">
                                                            <span class="badge bg-danger">Khẩn cấp</span>
                                                        </c:when>
                                                        <c:when test="${sr.priority == 'High'}">
                                                            <span class="badge bg-warning text-dark">Cao</span>
                                                        </c:when>
                                                        <c:when test="${sr.priority == 'Normal'}">
                                                            <span class="badge bg-info">Bình thường</span>
                                                        </c:when>
                                                        <c:when test="${sr.priority == 'Low'}">
                                                            <span class="badge bg-secondary">Thấp</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-info">Bình thường</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <small>${sr.requestTimeFormatted}</small>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${sr.status == 'Pending'}">
                                                            <span class="badge badge-pending">Đang chờ</span>
                                                        </c:when>
                                                        <c:when test="${sr.status == 'In Progress'}">
                                                            <span class="badge badge-occupied">Đang xử lý</span>
                                                        </c:when>
                                                        <c:when test="${sr.status == 'Completed'}">
                                                            <span class="badge badge-completed">Hoàn thành</span>
                                                        </c:when>
                                                        <c:when test="${sr.status == 'Cancelled'}">
                                                            <span class="badge badge-cancelled">Đã hủy</span>
                                                        </c:when>
                                                        <c:when test="${sr.status == 'Rejected'}">
                                                            <span class="badge bg-dark">Từ chối</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">${sr.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <c:if test="${not empty sr.notes && (sr.status == 'Completed' || sr.status == 'Rejected')}">
                                                        <br><small class="text-muted" title="${sr.notes}">
                                                            <i class="bi bi-chat-left-text me-1"></i>${sr.notes}
                                                        </small>
                                                    </c:if>
                                                </td>
                                                <td class="text-end pe-4">
                                                    <c:if test="${sr.status == 'Pending'}">
                                                        <form method="post"
                                                              action="${pageContext.request.contextPath}/customer/request/cancel"
                                                              class="d-inline"
                                                              onsubmit="return confirm('Bạn có chắc muốn hủy yêu cầu này?')">
                                                            <input type="hidden" name="requestId" value="${sr.requestId}">
                                                            <input type="hidden" name="bookingId" value="${sr.bookingId}">
                                                            <button type="submit" class="btn btn-outline-danger btn-sm">
                                                                <i class="bi bi-x-circle me-1"></i>Hủy
                                                            </button>
                                                        </form>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
