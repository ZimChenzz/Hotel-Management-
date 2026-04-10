<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý khách - Cổng Nhân Viên</title>
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
            <c:set var="pageTitle" value="Quản lý khách" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <div class="mb-3 d-flex justify-content-between align-items-center">
                    <a href="${pageContext.request.contextPath}/staff/bookings" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/bookings/checkout?bookingId=${booking.bookingId}"
                       class="btn btn-warning">
                        <i class="bi bi-box-arrow-right me-1"></i>Tiến hành Check-out
                    </a>
                </div>

                <c:if test="${not empty success}">
                    <div class="alert alert-success">${success}</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <div class="row">
                    <!-- Booking Info -->
                    <div class="col-lg-4">
                        <div class="card mb-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>Thông tin booking</h5>
                            </div>
                            <div class="card-body">
                                <p><strong>Mã:</strong> #${booking.bookingId}</p>
                                <p><strong>Phòng:</strong> ${booking.room.roomNumber}</p>
                                <p><strong>Loại:</strong> ${booking.room.roomType.typeName}</p>
                                <p class="mb-0">
                                    <strong>Check-in:</strong>
                                    ${booking.checkInExpectedDateOnly}
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Occupants Form -->
                    <div class="col-lg-8">
                        <div class="card">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="bi bi-people me-2"></i>Danh sách khách lưu trú</h5>
                                <button type="button" class="btn btn-sm btn-outline-primary" onclick="addOccupant()">
                                    <i class="bi bi-plus"></i> Thêm khách
                                </button>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/staff/bookings/occupants" method="post">
                                    <input type="hidden" name="bookingId" value="${booking.bookingId}">

                                    <div id="occupantList">
                                        <c:choose>
                                            <c:when test="${not empty occupants}">
                                                <c:forEach var="occ" items="${occupants}" varStatus="status">
                                                    <div class="occupant-row border rounded p-3 mb-3">
                                                        <div class="d-flex justify-content-between mb-2">
                                                            <strong>Khách ${status.index + 1}</strong>
                                                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeOccupant(this)">
                                                                <i class="bi bi-trash"></i>
                                                            </button>
                                                        </div>
                                                        <div class="row g-2">
                                                            <div class="col-md-4">
                                                                <label class="form-label">Họ tên</label>
                                                                <input type="text" class="form-control" name="fullName" value="${occ.fullName}" required>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label">CCCD/Passport</label>
                                                                <input type="text" class="form-control" name="idCardNumber" value="${occ.idCardNumber}">
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="form-label">Số điện thoại</label>
                                                                <input type="text" class="form-control" name="phoneNumber" value="${occ.phoneNumber}">
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="occupant-row border rounded p-3 mb-3">
                                                    <div class="d-flex justify-content-between mb-2">
                                                        <strong>Khách 1</strong>
                                                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeOccupant(this)">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </div>
                                                    <div class="row g-2">
                                                        <div class="col-md-4">
                                                            <label class="form-label">Họ tên</label>
                                                            <input type="text" class="form-control" name="fullName" required>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label class="form-label">CCCD/Passport</label>
                                                            <input type="text" class="form-control" name="idCardNumber">
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label class="form-label">Số điện thoại</label>
                                                            <input type="text" class="form-control" name="phoneNumber">
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <button type="submit" class="btn btn-staff-primary">
                                        <i class="bi bi-save me-1"></i>Lưu thông tin khách
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <script>
        let occupantCount = document.querySelectorAll('.occupant-row').length;

        function addOccupant() {
            occupantCount++;
            const html = `
                <div class="occupant-row border rounded p-3 mb-3">
                    <div class="d-flex justify-content-between mb-2">
                        <strong>Khách ${occupantCount}</strong>
                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeOccupant(this)">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                    <div class="row g-2">
                        <div class="col-md-4">
                            <label class="form-label">Họ tên</label>
                            <input type="text" class="form-control" name="fullName" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">CCCD/Passport</label>
                            <input type="text" class="form-control" name="idCardNumber">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" class="form-control" name="phoneNumber">
                        </div>
                    </div>
                </div>`;
            document.getElementById('occupantList').insertAdjacentHTML('beforeend', html);
        }

        function removeOccupant(btn) {
            const rows = document.querySelectorAll('.occupant-row');
            if (rows.length > 1) {
                btn.closest('.occupant-row').remove();
            }
        }
    </script>
</body>
</html>
