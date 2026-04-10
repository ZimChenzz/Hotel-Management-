<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gợi ý phân phòng - Cổng Nhân Viên</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="bookings" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Gợi ý phân phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <div class="mb-3">
                    <a href="${pageContext.request.contextPath}/staff/bookings/detail?id=${param.bookingId}" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i> Quay lại chi tiết
                    </a>
                </div>

                <!-- Booking Summary Card -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>Thông tin Booking #${param.bookingId}</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4">
                                <p class="mb-1 text-muted small">Check-in dự kiến</p>
                                <p class="mb-0 fw-semibold">${checkInExpected}</p>
                            </div>
                            <div class="col-md-4">
                                <p class="mb-1 text-muted small">Check-out dự kiến</p>
                                <p class="mb-0 fw-semibold">${checkOutExpected}</p>
                            </div>
                            <div class="col-md-4">
                                <p class="mb-1 text-muted small">Số phòng cần gán</p>
                                <p class="mb-0 fw-semibold text-primary">${unassignedCount} phòng</p>
                            </div>
                        </div>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${suggestionsEmpty}">
                        <div class="alert alert-success mb-4">
                            <i class="bi bi-check-circle me-2"></i>Tất cả các phòng đã được gán cho booking này!
                        </div>
                    </c:when>
                    <c:when test="${not empty suggestionsByType}">
                        <!-- Suggestions grouped by room type -->
                        <form method="post" action="${pageContext.request.contextPath}/staff/bookings/bulk-assign" id="bulkAssignForm">
                            <input type="hidden" name="bookingId" value="${param.bookingId}">

                            <div class="card mb-4">
                                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0"><i class="bi bi-lightbulb me-2"></i>Gợi ý phân phòng</h5>
                                    <button type="button" class="btn btn-success" onclick="acceptAllSuggestions()">
                                        <i class="bi bi-check-all me-1"></i>Chấp nhận tất cả
                                    </button>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead class="table-light">
                                                <tr>
                                                    <th style="width: 120px;">Mã BookingRoom</th>
                                                    <th>Loại phòng</th>
                                                    <th style="width: 120px;">Phòng đề xuất</th>
                                                    <th style="width: 150px;">Trạng thái</th>
                                                    <th style="width: 120px;">Thao tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="entry" items="${suggestionsByType}">
                                                    <c:forEach var="suggestion" items="${entry.value}">
                                                        <tr>
                                                            <td>
                                                                <span class="badge bg-secondary">#${suggestion.bookingRoomId}</span>
                                                            </td>
                                                            <td>${suggestion.roomTypeName}</td>
                                                            <td>
                                                                <strong class="text-success">${suggestion.suggestedRoomNumber}</strong>
                                                            </td>
                                                            <td>
                                                                <span class="badge bg-info">${suggestion.status}</span>
                                                            </td>
                                                            <td>
                                                                <div class="form-check">
                                                                    <input class="form-check-input suggest-check"
                                                                           type="checkbox" name="acceptedSuggestions"
                                                                           value="${suggestion.bookingRoomId}:${suggestion.suggestedRoomId}"
                                                                           id="suggest-${suggestion.bookingRoomId}">
                                                                    <label class="form-check-label" for="suggest-${suggestion.bookingRoomId}">
                                                                        Chấp nhận
                                                                    </label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-success" id="applyBtn" disabled>
                                    <i class="bi bi-check-circle me-1"></i>Áp dụng đã chọn
                                </button>
                                <a href="${pageContext.request.contextPath}/staff/bookings/assign?bookingId=${param.bookingId}"
                                   class="btn btn-outline-primary">
                                    <i class="bi bi-hand-index me-1"></i>Gán thủ công
                                </a>
                            </div>
                        </form>

                        <script>
                            // Enable/disable apply button based on selections
                            document.querySelectorAll('.suggest-check').forEach(function(checkbox) {
                                checkbox.addEventListener('change', function() {
                                    const anyChecked = document.querySelector('.suggest-check:checked');
                                    document.getElementById('applyBtn').disabled = !anyChecked;
                                });
                            });

                            function acceptAllSuggestions() {
                                document.querySelectorAll('.suggest-check').forEach(function(checkbox) {
                                    checkbox.checked = true;
                                });
                                document.getElementById('applyBtn').disabled = false;
                            }
                        </script>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-warning mb-4">
                            <i class="bi bi-exclamation-triangle me-2"></i>Không có gợi ý nào cho booking này.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
