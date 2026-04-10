<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết đặt phòng #${booking.bookingId} - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .timeline {
            position: relative;
            padding-left: 2rem;
        }
        .timeline::before {
            content: '';
            position: absolute;
            left: 0.5rem;
            top: 0;
            bottom: 0;
            width: 2px;
            background: var(--border-color);
        }
        .timeline-item {
            position: relative;
            padding-bottom: 1.5rem;
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -1.65rem;
            top: 0.25rem;
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background: var(--border-color);
            border: 3px solid #fff;
            box-shadow: 0 0 0 2px var(--border-color);
        }
        .timeline-item.active::before {
            background: var(--secondary);
            box-shadow: 0 0 0 2px var(--secondary);
        }
        .timeline-item.completed::before {
            background: var(--success);
            box-shadow: 0 0 0 2px var(--success);
        }
        .star-rating { color: var(--secondary); }
        .star-rating .bi-star { color: #ddd; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Page Header -->
    <section class="public-hero public-hero-small">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-2" style="--bs-breadcrumb-divider-color: rgba(255,255,255,0.5);">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/bookings" style="color: rgba(255,255,255,0.7);">Đặt phòng của tôi</a></li>
                    <li class="breadcrumb-item text-white">Đơn #${booking.bookingId}</li>
                </ol>
            </nav>
            <h1 class="public-hero-title"><i class="bi bi-receipt me-2"></i>Chi tiết đặt phòng</h1>
        </div>
    </section>

    <div class="container py-5">
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

        <div class="row g-4">
            <!-- Main Content -->
            <div class="col-lg-8">
                <!-- Booking Details -->
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-calendar-check me-2"></i>Thông tin đặt phòng</span>
                        <c:choose>
                            <c:when test="${booking.status == 'Pending'}">
                                <span class="badge badge-pending">Chờ thanh toán</span>
                            </c:when>
                            <c:when test="${booking.status == 'Confirmed'}">
                                <span class="badge badge-confirmed">Đã xác nhận</span>
                            </c:when>
                            <c:when test="${booking.status == 'CheckedIn'}">
                                <span class="badge badge-occupied">Đang ở</span>
                            </c:when>
                            <c:when test="${booking.status == 'CheckedOut'}">
                                <span class="badge badge-completed">Hoàn thành</span>
                            </c:when>
                            <c:when test="${booking.status == 'Cancelled'}">
                                <span class="badge badge-cancelled">Đã hủy</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-secondary">${booking.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="card-body">
                        <div class="row mb-4">
                            <div class="col-md-8">
                                <c:choose>
                                    <c:when test="${isMultiRoom && not empty bookingRooms}">
                                        <h3 style="font-family: var(--font-display); color: var(--primary);">
                                            <i class="bi bi-door-open me-2"></i>${bookingRooms.size()} Phòng
                                        </h3>
                                        <p class="text-muted mb-0">
                                            <c:forEach var="br" items="${bookingRooms}" varStatus="loop">
                                                ${br.roomType.typeName}${loop.last ? '' : ', '}
                                            </c:forEach>
                                        </p>
                                    </c:when>
                                    <c:otherwise>
                                        <h3 style="font-family: var(--font-display); color: var(--primary);">${booking.room.roomType.typeName}</h3>
                                        <p class="text-muted mb-0">
                                            <i class="bi bi-door-open me-1"></i>Phòng ${booking.room.roomNumber}
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="col-md-4 text-md-end">
                                <small class="text-muted">Mã đặt phòng</small>
                                <p class="h3 mb-0" style="font-family: var(--font-display); color: var(--secondary-dark);">#${booking.bookingId}</p>
                            </div>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <div class="p-3 rounded" style="background: var(--surface-hover);">
                                    <div class="d-flex align-items-center">
                                        <div class="p-2 rounded me-3" style="background: rgba(25,135,84,0.1);">
                                            <i class="bi bi-calendar-check fs-4 text-success"></i>
                                        </div>
                                        <div>
                                            <small class="text-muted">Nhận phòng</small>
                                            <p class="mb-0 fw-semibold">${booking.checkInExpectedFormatted}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-3 rounded" style="background: var(--surface-hover);">
                                    <div class="d-flex align-items-center">
                                        <div class="p-2 rounded me-3" style="background: rgba(220,53,69,0.1);">
                                            <i class="bi bi-calendar-x fs-4 text-danger"></i>
                                        </div>
                                        <div>
                                            <small class="text-muted">Trả phòng</small>
                                            <p class="mb-0 fw-semibold">${booking.checkOutExpectedFormatted}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Multi-Room BookingRoom List -->
                        <c:if test="${isMultiRoom && not empty bookingRooms}">
                            <h5 class="mb-3" style="font-family: var(--font-display); color: var(--primary);">
                                <i class="bi bi-list-ul me-2"></i>Danh sách phòng
                            </h5>
                            <div class="table-responsive mb-4">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Loại phòng</th>
                                            <th>Phòng được gán</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="br" items="${bookingRooms}" varStatus="loop">
                                            <tr>
                                                <td><span class="badge bg-secondary">#${loop.index + 1}</span></td>
                                                <td>${br.roomType.typeName}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty br.room}">
                                                            <strong>${br.room.roomNumber}</strong>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">Chưa gán</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${br.status == 'Pending'}">
                                                            <span class="badge bg-warning text-dark">Chờ</span>
                                                        </c:when>
                                                        <c:when test="${br.status == 'Assigned'}">
                                                            <span class="badge bg-info">Đã gán</span>
                                                        </c:when>
                                                        <c:when test="${br.status == 'CheckedIn'}">
                                                            <span class="badge bg-success">Đã nhận</span>
                                                        </c:when>
                                                        <c:when test="${br.status == 'CheckedOut'}">
                                                            <span class="badge bg-secondary">Đã trả</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>

                        <table class="table table-borderless mb-0">
                            <tr>
                                <td class="text-muted ps-0">Ngày đặt:</td>
                                <td>${booking.bookingDateFormatted}</td>
                            </tr>
                            <tr>
                                <td class="text-muted ps-0">Tổng tiền:</td>
                                <td class="fs-4 fw-bold" style="color: var(--secondary-dark);">
                                    <fmt:formatNumber value="${booking.totalPrice}" type="number" groupingUsed="true"/>đ
                                </td>
                            </tr>
                            <c:if test="${earlySurcharge != null && earlySurcharge > 0}">
                                <tr>
                                    <td class="text-muted ps-0"><i class="bi bi-alarm me-1"></i>Phu thu check-in som:</td>
                                    <td><fmt:formatNumber value="${earlySurcharge}" type="number" groupingUsed="true"/>d</td>
                                </tr>
                            </c:if>
                            <c:if test="${lateSurcharge != null && lateSurcharge > 0}">
                                <tr>
                                    <td class="text-muted ps-0"><i class="bi bi-alarm-fill me-1"></i>Phu thu check-out muon:</td>
                                    <td><fmt:formatNumber value="${lateSurcharge}" type="number" groupingUsed="true"/>d</td>
                                </tr>
                            </c:if>
                            <c:if test="${not empty booking.note}">
                                <tr>
                                    <td class="text-muted ps-0">Ghi chú:</td>
                                    <td>${booking.note}</td>
                                </tr>
                            </c:if>
                        </table>

                        <c:if test="${booking.status == 'Pending' || booking.status == 'Confirmed'}">
                            <hr class="my-4">
                            <div class="d-flex gap-2 flex-wrap">
                                <c:if test="${booking.status == 'Pending'}">
                                    <a href="${pageContext.request.contextPath}/payment/process?bookingId=${booking.bookingId}"
                                       class="btn btn-primary">
                                        <i class="bi bi-credit-card me-2"></i>Thanh toán ngay
                                    </a>
                                </c:if>
                                <form method="post" action="${pageContext.request.contextPath}/customer/booking/cancel"
                                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy đặt phòng này không?')">
                                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                    <button type="submit" class="btn btn-outline-danger">
                                        <i class="bi bi-x-circle me-2"></i>Hủy đặt phòng
                                    </button>
                                </form>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Service Request (only for CheckedIn) -->
                <c:if test="${booking.status == 'CheckedIn'}">
                    <div class="card mb-4">
                        <div class="card-header">
                            <i class="bi bi-bell me-2"></i>Yêu cầu dịch vụ
                        </div>
                        <div class="card-body">
                            <form method="post" action="${pageContext.request.contextPath}/customer/service-request">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                <input type="hidden" name="serviceType" value="Cleaning">
                                <p class="text-muted">Bạn cần hỗ trợ dịch vụ phòng?</p>
                                <button type="submit" class="btn btn-outline-secondary">
                                    <i class="bi bi-brush me-2"></i>Yêu cầu dọn phòng
                                </button>
                            </form>
                        </div>
                    </div>
                </c:if>

                <!-- Service Requests History -->
                <c:if test="${not empty serviceRequests}">
                    <div class="card mb-4">
                        <div class="card-header">
                            <i class="bi bi-list-check me-2"></i>Lịch sử yêu cầu dịch vụ
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Loại dịch vụ</th>
                                            <th>Thời gian</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="sr" items="${serviceRequests}">
                                            <tr>
                                                <td>${sr.serviceType}</td>
                                                <td>${sr.requestTime}</td>
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
                                                        <c:otherwise>
                                                            <span class="badge badge-secondary">${sr.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:if test="${sr.status == 'Pending'}">
                                                        <form method="post"
                                                              action="${pageContext.request.contextPath}/customer/request/cancel"
                                                              class="d-inline"
                                                              onsubmit="return confirm('Hủy yêu cầu dịch vụ này?')">
                                                            <input type="hidden" name="requestId" value="${sr.requestId}">
                                                            <input type="hidden" name="bookingId" value="${booking.bookingId}">
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

                <!-- Feedback Form -->
                <c:if test="${canLeaveFeedback}">
                    <div class="card mb-4">
                        <div class="card-header">
                            <i class="bi bi-star me-2"></i>Đánh giá trải nghiệm
                        </div>
                        <div class="card-body">
                            <form method="post" action="${pageContext.request.contextPath}/customer/feedback">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                <div class="mb-3">
                                    <label class="form-label">Đánh giá của bạn <span class="text-danger">*</span></label>
                                    <select name="rating" class="form-select" required>
                                        <option value="5">⭐⭐⭐⭐⭐ Tuyệt vời</option>
                                        <option value="4">⭐⭐⭐⭐ Rất tốt</option>
                                        <option value="3">⭐⭐⭐ Tốt</option>
                                        <option value="2">⭐⭐ Tạm được</option>
                                        <option value="1">⭐ Không hài lòng</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Nhận xét</label>
                                    <textarea class="form-control" name="comment" rows="3" maxlength="1000"
                                              placeholder="Chia sẻ trải nghiệm của bạn..."></textarea>
                                    <div class="form-text">Tối đa 1000 ký tự</div>
                                </div>
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-send me-2"></i>Gửi đánh giá
                                </button>
                            </form>
                        </div>
                    </div>
                </c:if>

                <!-- Existing Feedback -->
                <c:if test="${not empty feedback}">
                    <div class="card mb-4" id="feedback-card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-chat-quote me-2"></i>Đánh giá của bạn</span>
                            <c:if test="${not feedback.hidden}">
                                <div class="d-flex gap-2">
                                    <button class="btn btn-outline-secondary btn-sm" onclick="toggleFeedbackEdit()">
                                        <i class="bi bi-pencil me-1"></i>Sửa
                                    </button>
                                    <form method="post" action="${pageContext.request.contextPath}/customer/feedback/delete"
                                          class="d-inline"
                                          onsubmit="return confirm('Bạn có chắc muốn xóa đánh giá này?')">
                                        <input type="hidden" name="feedbackId" value="${feedback.feedbackId}">
                                        <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                        <button type="submit" class="btn btn-outline-danger btn-sm">
                                            <i class="bi bi-trash me-1"></i>Xóa
                                        </button>
                                    </form>
                                </div>
                            </c:if>
                        </div>
                        <div class="card-body">
                            <div id="feedback-view" class="p-3 rounded" style="background: var(--surface-hover);">
                                <div class="star-rating mb-2">
                                    <c:forEach begin="1" end="5" var="i">
                                        <i class="bi ${i <= feedback.rating ? 'bi-star-fill' : 'bi-star'} fs-5"></i>
                                    </c:forEach>
                                    <span class="ms-2 text-muted">${feedback.rating}/5</span>
                                </div>
                                <c:if test="${not empty feedback.comment}">
                                    <p class="mb-2">${feedback.comment}</p>
                                </c:if>
                                <small class="text-muted"><i class="bi bi-clock me-1"></i>${feedback.createdAt}</small>
                                <c:if test="${not empty feedback.adminReply}">
                                    <div class="mt-3 p-2 rounded" style="border-left: 3px solid var(--secondary); background: rgba(255,255,255,0.6);">
                                        <small class="fw-semibold text-muted"><i class="bi bi-reply me-1"></i>Phản hồi từ khách sạn:</small>
                                        <p class="mb-0 mt-1 small">${feedback.adminReply}</p>
                                    </div>
                                </c:if>
                            </div>

                            <div id="feedback-edit" class="d-none">
                                <form method="post" action="${pageContext.request.contextPath}/customer/feedback/update">
                                    <input type="hidden" name="feedbackId" value="${feedback.feedbackId}">
                                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                    <div class="mb-3">
                                        <label class="form-label">Đánh giá <span class="text-danger">*</span></label>
                                        <select name="rating" class="form-select" required>
                                            <option value="5" ${feedback.rating == 5 ? 'selected' : ''}>⭐⭐⭐⭐⭐ Tuyệt vời</option>
                                            <option value="4" ${feedback.rating == 4 ? 'selected' : ''}>⭐⭐⭐⭐ Rất tốt</option>
                                            <option value="3" ${feedback.rating == 3 ? 'selected' : ''}>⭐⭐⭐ Tốt</option>
                                            <option value="2" ${feedback.rating == 2 ? 'selected' : ''}>⭐⭐ Tạm được</option>
                                            <option value="1" ${feedback.rating == 1 ? 'selected' : ''}>⭐ Không hài lòng</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Nhận xét</label>
                                        <textarea class="form-control" name="comment" rows="3" maxlength="1000"
                                                  placeholder="Chia sẻ trải nghiệm của bạn...">${feedback.comment}</textarea>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <button type="submit" class="btn btn-primary btn-sm">
                                            <i class="bi bi-check me-1"></i>Lưu thay đổi
                                        </button>
                                        <button type="button" class="btn btn-secondary btn-sm" onclick="toggleFeedbackEdit()">Hủy</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>

            <!-- Sidebar -->
            <div class="col-lg-4">
                <!-- Status Timeline -->
                <div class="card mb-4">
                    <div class="card-header" style="background: var(--primary-gradient); color: white;">
                        <i class="bi bi-clock-history me-2"></i>Trạng thái đơn hàng
                    </div>
                    <div class="card-body">
                        <div class="timeline">
                            <div class="timeline-item ${booking.status == 'Pending' ? 'active' : (booking.status != 'Cancelled' ? 'completed' : '')}">
                                <strong>Chờ xác nhận</strong>
                                <p class="text-muted small mb-0">Đơn đặt phòng đã được tạo</p>
                            </div>
                            <div class="timeline-item ${booking.status == 'Confirmed' ? 'active' : (booking.status == 'CheckedIn' || booking.status == 'CheckedOut' ? 'completed' : '')}">
                                <strong>Đã xác nhận</strong>
                                <p class="text-muted small mb-0">Thanh toán thành công</p>
                            </div>
                            <div class="timeline-item ${booking.status == 'CheckedIn' ? 'active' : (booking.status == 'CheckedOut' ? 'completed' : '')}">
                                <strong>Đã nhận phòng</strong>
                                <p class="text-muted small mb-0">Khách đã check-in</p>
                            </div>
                            <div class="timeline-item ${booking.status == 'CheckedOut' ? 'completed' : ''}">
                                <strong>Hoàn thành</strong>
                                <p class="text-muted small mb-0">Khách đã trả phòng</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Support -->
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="bi bi-headset me-2"></i>Hỗ trợ khách hàng
                    </div>
                    <div class="card-body">
                        <p class="text-muted small mb-3">Nếu bạn cần hỗ trợ về đặt phòng, vui lòng liên hệ:</p>
                        <p class="mb-2"><i class="bi bi-telephone me-2" style="color: var(--secondary);"></i><strong>1900 1234</strong></p>
                        <p class="mb-0"><i class="bi bi-envelope me-2" style="color: var(--secondary);"></i>support@hotel.com</p>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/customer/bookings" class="btn btn-outline-secondary w-100">
                    <i class="bi bi-arrow-left me-2"></i>Quay lại danh sách
                </a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleFeedbackEdit() {
            const view = document.getElementById('feedback-view');
            const edit = document.getElementById('feedback-edit');
            if (view && edit) {
                view.classList.toggle('d-none');
                edit.classList.toggle('d-none');
            }
        }
    </script>
</body>
</html>
