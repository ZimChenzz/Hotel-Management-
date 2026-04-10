<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đánh giá của tôi - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .star-rating { color: var(--secondary); }
        .star-rating .bi-star { color: #ddd; }
        .review-card { transition: transform 0.2s; }
        .review-card:hover { transform: translateY(-2px); }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <section class="public-hero public-hero-small">
        <div class="container">
            <h1 class="public-hero-title"><i class="bi bi-star me-2"></i>Đánh giá của tôi</h1>
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
                            <a href="${pageContext.request.contextPath}/customer/reviews" class="customer-nav-item active">
                                <i class="bi bi-star"></i>Đánh giá của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/requests" class="customer-nav-item">
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
                        <h4 class="mb-1" style="font-family: var(--font-display); color: var(--primary);">Đánh giá của tôi</h4>
                        <p class="text-muted mb-0">Quản lý tất cả đánh giá bạn đã gửi</p>
                    </div>
                    <span class="badge bg-secondary fs-6">${feedbacks.size()} đánh giá</span>
                </div>

                <c:if test="${not empty param.success}">
                    <div class="alert alert-success alert-dismissible fade show mb-4">
                        <i class="bi bi-check-circle me-2"></i>${param.success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <c:if test="${empty feedbacks}">
                    <div class="card">
                        <div class="card-body">
                            <div class="empty-state">
                                <div class="empty-state-icon"><i class="bi bi-star"></i></div>
                                <h3 class="empty-state-title">Chưa có đánh giá nào</h3>
                                <p class="empty-state-text">Bạn chưa gửi đánh giá nào. Hãy trải nghiệm dịch vụ và chia sẻ cảm nhận!</p>
                                <a href="${pageContext.request.contextPath}/customer/bookings" class="btn btn-primary">
                                    <i class="bi bi-calendar-check me-1"></i>Xem đặt phòng
                                </a>
                            </div>
                        </div>
                    </div>
                </c:if>

                <c:forEach var="feedback" items="${feedbacks}">
                    <div class="card mb-3 review-card" id="review-${feedback.feedbackId}">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div>
                                    <div class="star-rating mb-1">
                                        <c:forEach begin="1" end="5" var="i">
                                            <i class="bi ${i <= feedback.rating ? 'bi-star-fill' : 'bi-star'} fs-5"></i>
                                        </c:forEach>
                                        <span class="ms-2 fw-semibold">${feedback.rating}/5</span>
                                    </div>
                                    <small class="text-muted">
                                        <i class="bi bi-clock me-1"></i>${feedback.createdAt}
                                        &nbsp;·&nbsp;
                                        <a href="${pageContext.request.contextPath}/customer/booking?id=${feedback.bookingId}"
                                           class="text-decoration-none">
                                            <i class="bi bi-receipt me-1"></i>Đặt phòng #${feedback.bookingId}
                                        </a>
                                    </small>
                                </div>
                                <c:if test="${not feedback.hidden}">
                                    <div class="d-flex gap-2">
                                        <button class="btn btn-outline-secondary btn-sm"
                                                onclick="showEditForm(${feedback.feedbackId}, ${feedback.rating}, '${feedback.comment}')">
                                            <i class="bi bi-pencil me-1"></i>Sửa
                                        </button>
                                        <form method="post" action="${pageContext.request.contextPath}/customer/feedback/delete"
                                              onsubmit="return confirm('Bạn có chắc muốn xóa đánh giá này?')">
                                            <input type="hidden" name="feedbackId" value="${feedback.feedbackId}">
                                            <input type="hidden" name="bookingId" value="${feedback.bookingId}">
                                            <button type="submit" class="btn btn-outline-danger btn-sm">
                                                <i class="bi bi-trash me-1"></i>Xóa
                                            </button>
                                        </form>
                                    </div>
                                </c:if>
                                <c:if test="${feedback.hidden}">
                                    <span class="badge bg-secondary">Đã ẩn</span>
                                </c:if>
                            </div>

                            <c:if test="${not empty feedback.comment}">
                                <p class="mb-2">${feedback.comment}</p>
                            </c:if>

                            <c:if test="${not empty feedback.adminReply}">
                                <div class="p-3 rounded mt-2" style="background: var(--surface-hover); border-left: 3px solid var(--secondary);">
                                    <small class="text-muted fw-semibold"><i class="bi bi-reply me-1"></i>Phản hồi từ khách sạn:</small>
                                    <p class="mb-0 mt-1">${feedback.adminReply}</p>
                                </div>
                            </c:if>

                            <!-- Edit Form (hidden by default) -->
                            <div class="edit-form mt-3 d-none" id="edit-form-${feedback.feedbackId}">
                                <hr>
                                <form method="post" action="${pageContext.request.contextPath}/customer/feedback/update">
                                    <input type="hidden" name="feedbackId" value="${feedback.feedbackId}">
                                    <input type="hidden" name="bookingId" value="${feedback.bookingId}">
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Đánh giá <span class="text-danger">*</span></label>
                                        <select name="rating" class="form-select" id="rating-select-${feedback.feedbackId}" required>
                                            <option value="5" ${feedback.rating == 5 ? 'selected' : ''}>⭐⭐⭐⭐⭐ Tuyệt vời</option>
                                            <option value="4" ${feedback.rating == 4 ? 'selected' : ''}>⭐⭐⭐⭐ Rất tốt</option>
                                            <option value="3" ${feedback.rating == 3 ? 'selected' : ''}>⭐⭐⭐ Tốt</option>
                                            <option value="2" ${feedback.rating == 2 ? 'selected' : ''}>⭐⭐ Tạm được</option>
                                            <option value="1" ${feedback.rating == 1 ? 'selected' : ''}>⭐ Không hài lòng</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Nhận xét</label>
                                        <textarea class="form-control" name="comment" rows="3" maxlength="1000"
                                                  id="comment-${feedback.feedbackId}">${feedback.comment}</textarea>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <button type="submit" class="btn btn-primary btn-sm">
                                            <i class="bi bi-check me-1"></i>Lưu thay đổi
                                        </button>
                                        <button type="button" class="btn btn-secondary btn-sm"
                                                onclick="hideEditForm(${feedback.feedbackId})">Hủy</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function showEditForm(feedbackId, rating, comment) {
            document.getElementById('edit-form-' + feedbackId).classList.remove('d-none');
        }
        function hideEditForm(feedbackId) {
            document.getElementById('edit-form-' + feedbackId).classList.add('d-none');
        }
    </script>
</body>
</html>
