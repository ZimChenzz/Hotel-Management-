<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý loại phòng - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="room-types" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Quản lý loại phòng" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Loại phòng</li>
                    </ol>
                </nav>

                <c:if test="${param.success == 'created'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Tạo loại phòng thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.success == 'updated'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Cập nhật loại phòng thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.success == 'deleted'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Xóa loại phòng thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.success == 'imageUploaded'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Tải ảnh lên thành công.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'deleteFailed'}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-circle me-2"></i>Không thể xóa loại phòng. Loại phòng này có thể đang được sử dụng.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Danh sách loại phòng</h1>
                        <p class="page-header-subtitle">Tổng: ${roomTypes.size()} loại phòng</p>
                    </div>
                    <div class="page-header-actions">
                        <a href="${pageContext.request.contextPath}/admin/room-types/create" class="btn btn-primary">
                            <i class="bi bi-plus-lg me-1"></i> Thêm loại phòng
                        </a>
                    </div>
                </div>

                <!-- Filter -->
                <div class="filter-card">
                    <form id="filterForm" class="row g-3 align-items-end">
                        <div class="col-md-6">
                            <label class="form-label">Tìm kiếm</label>
                            <input type="text" class="form-control" name="search" placeholder="Tên loại phòng...">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Sức chứa</label>
                            <select class="form-select" name="capacity">
                                <option value="">Tất cả</option>
                                <option value="1">1 người</option>
                                <option value="2">2 người</option>
                                <option value="3">3 người</option>
                                <option value="4">4+ người</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button type="reset" class="btn btn-outline-secondary w-100" onclick="AdminTable.filter('roomTypesTable', {})">
                                <i class="bi bi-x-lg me-1"></i> Xóa lọc
                            </button>
                        </div>
                    </form>
                </div>

                <div class="card">
                    <div class="table-responsive">
                        <table class="table-modern table-striped table-hover" id="roomTypesTable">
                                <thead>
                                    <tr>
                                        <th>Tên loại phòng</th>
                                        <th>Giá cơ bản</th>
                                        <th>Sức chứa</th>
                                        <th>Đặt cọc (%)</th>
                                        <th>Mô tả</th>
                                        <th class="text-end">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty roomTypes}">
                                            <tr>
                                                <td colspan="6" class="text-center text-muted py-4">
                                                    Chưa có loại phòng nào.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="rt" items="${roomTypes}">
                                                <tr data-row>
                                                    <td data-field="search" class="fw-semibold">${rt.typeName}</td>
                                                    <td>
                                                        <fmt:formatNumber value="${rt.basePrice}" type="currency"
                                                            currencySymbol="" maxFractionDigits="0" />
                                                        VND
                                                    </td>
                                                    <td data-field="capacity" data-value="${rt.capacity}">${rt.capacity} người</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${rt.depositPercent != null && rt.depositPercent > 0}">
                                                                ${rt.depositPercent}%
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">0%</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-muted" style="max-width: 250px;">
                                                        <span title="${rt.description}">
                                                            <c:choose>
                                                                <c:when test="${rt.description.length() > 60}">
                                                                    ${rt.description.substring(0, 60)}...
                                                                </c:when>
                                                                <c:otherwise>${rt.description}</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </td>
                                                    <td class="text-end">
                                                        <a href="${pageContext.request.contextPath}/admin/room-types/edit?id=${rt.typeId}"
                                                           class="btn btn-sm btn-outline-secondary me-1">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>
                                                        <button type="button" class="btn btn-sm btn-outline-danger"
                                                                onclick="confirmDelete(${rt.typeId}, '${rt.typeName}')">
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
                        <div id="roomTypesTable-pagination"></div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Xác nhận xóa</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    Bạn có chắc muốn xóa loại phòng <strong id="deleteTypeName"></strong>?
                    Hành động này không thể hoàn tác.
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <form method="post" action="${pageContext.request.contextPath}/admin/room-types/delete">
                        <input type="hidden" name="id" id="deleteTypeId">
                        <button type="submit" class="btn btn-danger">Xóa</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <script src="${pageContext.request.contextPath}/assets/js/admin-table.js"></script>
    <script>
        function confirmDelete(id, typeName) {
            document.getElementById('deleteTypeId').value = id;
            document.getElementById('deleteTypeName').textContent = typeName;
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }

        document.addEventListener('DOMContentLoaded', function() {
            AdminTable.init('roomTypesTable');
            AdminTable.bindFilters('roomTypesTable', 'filterForm');
        });
    </script>
</body>
</html>
