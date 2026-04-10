<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý phòng - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="rooms" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Breadcrumb -->
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Phòng</li>
                    </ol>
                </nav>

                <!-- Alerts -->
                <c:if test="${param.success == 'created'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Tạo phòng thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.success == 'updated'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Cập nhật phòng thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.success == 'deleted'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Xóa phòng thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'deleteFailed'}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-x-circle me-2"></i>Không thể xóa phòng. Phòng có thể đang có đặt phòng liên quan.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Danh sách phòng</h1>
                        <p class="page-header-subtitle">Tổng: ${rooms.size()} phòng</p>
                    </div>
                    <div class="page-header-actions">
                        <a href="${pageContext.request.contextPath}/admin/rooms/create" class="btn btn-primary">
                            <i class="bi bi-plus-lg me-1"></i> Thêm phòng
                        </a>
                    </div>
                </div>

                <!-- Filter/Search -->
                <div class="filter-card">
                    <form id="filterForm" class="row g-3 align-items-end">
                        <div class="col-md-4">
                            <label class="form-label">Tìm kiếm</label>
                            <input type="text" class="form-control" name="search" placeholder="Số phòng...">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="">Tất cả</option>
                                <option value="Available">Sẵn sàng</option>
                                <option value="Occupied">Đang sử dụng</option>
                                <option value="Cleaning">Đang dọn</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Loại phòng</label>
                            <select class="form-select" name="typeId">
                                <option value="">Tất cả</option>
                                <c:forEach var="type" items="${roomTypes}">
                                    <option value="${type.typeName}">${type.typeName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="reset" class="btn btn-outline-secondary w-100" onclick="AdminTable.filter('roomsTable', {})">
                                <i class="bi bi-x-lg me-1"></i> Xóa lọc
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Table -->
                <div class="card">
                    <div class="table-responsive">
                        <table class="table-modern table-striped table-hover" id="roomsTable">
                            <thead>
                                <tr>
                                    <th style="width:70px;">Ảnh</th>
                                    <th>Số phòng</th>
                                    <th>Loại phòng</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty rooms}">
                                        <tr>
                                            <td colspan="5">
                                                <div class="empty-state">
                                                    <div class="empty-state-icon">
                                                        <i class="bi bi-door-open"></i>
                                                    </div>
                                                    <h3 class="empty-state-title">Chưa có phòng nào</h3>
                                                    <p class="empty-state-text">Bắt đầu bằng cách thêm phòng mới vào hệ thống.</p>
                                                    <a href="${pageContext.request.contextPath}/admin/rooms/create" class="btn btn-primary">
                                                        <i class="bi bi-plus-lg me-1"></i> Thêm phòng
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="room" items="${rooms}">
                                            <tr data-row>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty room.roomType.images}">
                                                            <img src="${pageContext.request.contextPath}${room.roomType.images[0].imageUrl}"
                                                                 alt="${room.roomType.typeName}"
                                                                 style="width:60px;height:45px;object-fit:cover;border-radius:6px;">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div style="width:60px;height:45px;background:var(--surface-hover);border-radius:6px;display:flex;align-items:center;justify-content:center;color:var(--text-muted);">
                                                                <i class="bi bi-image"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td data-field="search" class="fw-semibold">${room.roomNumber}</td>
                                                <td data-field="typeId">${room.roomType != null ? room.roomType.typeName : '-'}</td>
                                                <td data-field="status" data-value="${room.status}">
                                                    <c:choose>
                                                        <c:when test="${room.status == 'Available'}">
                                                            <span class="badge badge-available">Sẵn sàng</span>
                                                        </c:when>
                                                        <c:when test="${room.status == 'Occupied'}">
                                                            <span class="badge badge-occupied">Đang sử dụng</span>
                                                        </c:when>
                                                        <c:when test="${room.status == 'Cleaning'}">
                                                            <span class="badge badge-cleaning">Đang dọn</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-secondary">${room.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end">
                                                    <a href="${pageContext.request.contextPath}/admin/rooms/history?id=${room.roomId}"
                                                       class="btn btn-sm btn-outline-info me-1" title="Lịch sử">
                                                        <i class="bi bi-clock-history"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/admin/rooms/edit?id=${room.roomId}"
                                                       class="btn btn-sm btn-outline-secondary me-1">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-outline-danger"
                                                            onclick="confirmDelete(${room.roomId}, '${room.roomNumber}')">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                    <div id="roomsTable-pagination"></div>
                </div>
            </div>
        </main>
    </div>

    <!-- Mobile Toggle -->
    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content modal-confirm">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-exclamation-triangle me-2"></i>Xác nhận xóa</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Bạn có chắc muốn xóa phòng <strong id="deleteRoomNumber"></strong>?</p>
                    <p class="text-muted mb-0">Hành động này không thể hoàn tác.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                    <form method="post" action="${pageContext.request.contextPath}/admin/rooms/delete" id="deleteForm">
                        <input type="hidden" name="id" id="deleteRoomId">
                        <button type="submit" class="btn btn-danger">Xóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <script src="${pageContext.request.contextPath}/assets/js/admin-table.js"></script>
    <script>
        function confirmDelete(id, roomNumber) {
            document.getElementById('deleteRoomId').value = id;
            document.getElementById('deleteRoomNumber').textContent = roomNumber;
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }

        document.addEventListener('DOMContentLoaded', function() {
            AdminTable.init('roomsTable');
            AdminTable.bindFilters('roomsTable', 'filterForm');
        });
    </script>
</body>
</html>
