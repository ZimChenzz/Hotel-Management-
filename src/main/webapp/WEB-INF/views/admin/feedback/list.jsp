<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý phản hồi - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="feedback" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý phản hồi" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Phản hồi</li>
                    </ol>
                </nav>

                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="bi bi-check-circle me-2"></i>${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <div class="page-header mb-4">
                    <h1 class="page-header-title">Danh sách phản hồi (${feedbackList.size()})</h1>
                </div>

                <div class="row g-4">
                    <c:forEach var="feedback" items="${feedbackList}">
                        <div class="col-md-6">
                            <div class="card ${feedback.hidden ? 'border-secondary opacity-50' : ''}">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <div>
                                        <strong>${feedback.booking.customer.account.fullName}</strong>
                                        <span class="text-muted ms-2">
                                            Phòng ${feedback.booking.room.roomNumber} - ${feedback.booking.room.roomType.typeName}
                                        </span>
                                    </div>
                                    <div>
                                        <c:forEach begin="1" end="5" var="i">
                                            <i class="bi bi-star${i <= feedback.rating ? '-fill text-warning' : ''}"></i>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <p class="mb-2">${feedback.comment}</p>
                                    <small class="text-muted">
                                        <fmt:parseDate value="${feedback.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both"/>
                                        <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </small>

                                    <c:if test="${not empty feedback.adminReply}">
                                        <div class="mt-3 p-2 bg-light rounded">
                                            <small class="text-muted"><i class="bi bi-reply me-1"></i>Phản hồi từ Admin:</small>
                                            <p class="mb-0 mt-1">${feedback.adminReply}</p>
                                        </div>
                                    </c:if>
                                </div>
                                <div class="card-footer">
                                    <div class="btn-group btn-group-sm">
                                        <form action="${pageContext.request.contextPath}/admin/feedback/toggle-visibility"
                                              method="post" style="display:inline;">
                                            <input type="hidden" name="id" value="${feedback.feedbackId}">
                                            <button type="submit" class="btn btn-outline-${feedback.hidden ? 'success' : 'warning'}"
                                                    title="${feedback.hidden ? 'Hiện' : 'Ẩn'}">
                                                <i class="bi bi-${feedback.hidden ? 'eye' : 'eye-slash'}"></i>
                                                ${feedback.hidden ? 'Hiện' : 'Ẩn'}
                                            </button>
                                        </form>
                                        <button type="button" class="btn btn-outline-primary"
                                                data-bs-toggle="modal" data-bs-target="#replyModal${feedback.feedbackId}">
                                            <i class="bi bi-reply"></i> Phản hồi
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Reply Modal -->
                        <div class="modal fade" id="replyModal${feedback.feedbackId}" tabindex="-1">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form action="${pageContext.request.contextPath}/admin/feedback/reply" method="post">
                                        <input type="hidden" name="id" value="${feedback.feedbackId}">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Phản hồi khách hàng</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-3">
                                                <label class="form-label">Nội dung phản hồi</label>
                                                <textarea class="form-control" name="reply" rows="4" required>${feedback.adminReply}</textarea>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                            <button type="submit" class="btn btn-primary">Gửi phản hồi</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty feedbackList}">
                        <div class="col-12">
                            <div class="text-center py-5 text-muted">
                                <i class="bi bi-chat-dots fs-1 mb-3 d-block"></i>
                                Chưa có phản hồi nào
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </main>
    </div>

    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
