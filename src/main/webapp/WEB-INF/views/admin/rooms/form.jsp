<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${not empty room ? 'Sửa phòng' : 'Thêm phòng'} - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .room-image-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 1rem;
        }
        .room-image-card {
            position: relative;
            border-radius: var(--radius-lg, 12px);
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.08);
            transition: box-shadow 0.2s;
        }
        .room-image-card:hover {
            box-shadow: 0 4px 16px rgba(0,0,0,0.12);
        }
        .room-image-card img {
            width: 100%;
            height: 140px;
            object-fit: cover;
            display: block;
        }
        .room-image-card .delete-overlay {
            position: absolute;
            top: 6px;
            right: 6px;
            opacity: 0;
            transition: opacity 0.2s;
        }
        .room-image-card:hover .delete-overlay {
            opacity: 1;
        }
        .upload-zone {
            border: 2px dashed rgba(0,0,0,0.15);
            border-radius: var(--radius-lg, 12px);
            padding: 2rem;
            text-align: center;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
            background: rgba(0,0,0,0.01);
        }
        .upload-zone:hover {
            border-color: var(--accent, #d4af37);
            background: rgba(212,175,55,0.04);
        }
        .upload-zone i {
            font-size: 2.5rem;
            color: var(--accent, #d4af37);
            display: block;
            margin-bottom: 0.5rem;
        }
        .occupant-card {
            background: linear-gradient(135deg, rgba(16,185,129,0.06), rgba(16,185,129,0.02));
            border-left: 4px solid #10b981;
            border-radius: var(--radius-lg, 12px);
            padding: 1.5rem;
        }
        .occupant-avatar {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: linear-gradient(135deg, #10b981, #059669);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 1.25rem;
            font-weight: 600;
            flex-shrink: 0;
        }
        .nav-tabs .nav-link {
            font-weight: 500;
            color: var(--text-secondary, #64748b);
            border: none;
            padding: 0.75rem 1.25rem;
            border-bottom: 2px solid transparent;
        }
        .nav-tabs .nav-link.active {
            color: var(--accent, #d4af37);
            border-bottom-color: var(--accent, #d4af37);
            background: transparent;
        }
        .nav-tabs .nav-link:hover:not(.active) {
            color: var(--text-primary, #1e293b);
            border-bottom-color: rgba(0,0,0,0.1);
        }
        .tab-badge {
            font-size: 0.7rem;
            padding: 0.2em 0.55em;
            vertical-align: middle;
            margin-left: 0.35rem;
        }
    </style>
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="rooms" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="${not empty room ? 'Sửa phòng' : 'Thêm phòng'}" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rooms">Phòng</a></li>
                        <li class="breadcrumb-item active">${not empty room ? 'Sửa phòng '.concat(room.roomNumber) : 'Thêm phòng'}</li>
                    </ol>
                </nav>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="bi bi-exclamation-circle me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty param.success}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="bi bi-check-circle me-2"></i>
                        <c:choose>
                            <c:when test="${param.success == 'imageUploaded'}">Tải ảnh lên thành công!</c:when>
                            <c:when test="${param.success == 'imageDeleted'}">Xóa ảnh thành công!</c:when>
                            <c:otherwise>Thao tác thành công!</c:otherwise>
                        </c:choose>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="bi bi-exclamation-circle me-2"></i>
                        <c:choose>
                            <c:when test="${param.error == 'noFile'}">Vui lòng chọn file ảnh.</c:when>
                            <c:when test="${param.error == 'invalidType'}">Chỉ chấp nhận file ảnh (JPG, PNG, GIF).</c:when>
                            <c:when test="${param.error == 'uploadFailed'}">Tải ảnh thất bại. Vui lòng thử lại.</c:when>
                            <c:otherwise>Có lỗi xảy ra.</c:otherwise>
                        </c:choose>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Page Header for Edit mode -->
                <c:if test="${not empty room}">
                    <div class="page-header mb-3">
                        <div>
                            <h1 class="page-header-title">
                                <i class="bi bi-door-open me-2"></i>Phòng ${room.roomNumber}
                            </h1>
                            <p class="page-header-subtitle">
                                ${room.roomType != null ? room.roomType.typeName : ''} -
                                <c:choose>
                                    <c:when test="${room.status == 'Available'}"><span class="text-success">Sẵn sàng</span></c:when>
                                    <c:when test="${room.status == 'Occupied'}"><span class="text-danger">Đang sử dụng</span></c:when>
                                    <c:when test="${room.status == 'Cleaning'}"><span class="text-warning">Đang dọn</span></c:when>
                                    <c:when test="${room.status == 'Maintenance'}"><span class="text-secondary">Bảo trì</span></c:when>
                                </c:choose>
                            </p>
                        </div>
                        <div class="page-header-actions">
                            <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-1"></i>Quay lại
                            </a>
                        </div>
                    </div>
                </c:if>

                <!-- Tabs Navigation (only show tabs in edit mode) -->
                <c:choose>
                    <c:when test="${not empty room}">
                        <ul class="nav nav-tabs mb-4" role="tablist">
                            <li class="nav-item">
                                <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-details" type="button">
                                    <i class="bi bi-pencil-square me-1"></i>Thông tin phòng
                                </button>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" data-bs-toggle="tab" href="#tab-images" role="tab" id="images-tab">
                                    <i class="bi bi-images me-1"></i>Hình ảnh
                                    <c:if test="${not empty roomImages}">
                                        <span class="badge bg-primary tab-badge">${roomImages.size()}</span>
                                    </c:if>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" data-bs-toggle="tab" href="#tab-occupant" role="tab">
                                    <i class="bi bi-person-check me-1"></i>Khách đang ở
                                    <c:if test="${not empty currentBooking}">
                                        <span class="badge bg-success tab-badge">1</span>
                                    </c:if>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" data-bs-toggle="tab" href="#tab-history" role="tab">
                                    <i class="bi bi-clock-history me-1"></i>Lịch sử
                                    <c:if test="${not empty bookings}">
                                        <span class="badge bg-secondary tab-badge">${bookings.size()}</span>
                                    </c:if>
                                </a>
                            </li>
                        </ul>

                        <div class="tab-content">
                            <!-- Tab 1: Room Details -->
                            <div class="tab-pane fade show active" id="tab-details">
                                <div class="row g-4" style="max-width: 900px;">
                                    <div class="col-md-6">
                                        <div class="card h-100">
                                            <div class="card-header">
                                                <i class="bi bi-door-open me-2"></i>Sửa phòng
                                            </div>
                                            <div class="card-body">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/rooms/edit">
                                                    <input type="hidden" name="roomId" value="${room.roomId}">
                                                    <input type="hidden" name="id" value="${room.roomId}">

                                                    <div class="mb-3">
                                                        <label for="roomNumber" class="form-label">Số phòng <span class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="roomNumber" name="roomNumber"
                                                               value="${room.roomNumber}"
                                                               placeholder="VD: 101, 202A" required maxlength="10">
                                                    </div>

                                                    <div class="mb-3">
                                                        <label for="typeId" class="form-label">Loại phòng <span class="text-danger">*</span></label>
                                                        <select class="form-select" id="typeId" name="typeId" required onchange="updateRoomTypePreview(this.value)">
                                                            <option value="">-- Chọn loại phòng --</option>
                                                            <c:forEach var="rt" items="${roomTypes}">
                                                                <option value="${rt.typeId}"
                                                                    <c:if test="${room.typeId == rt.typeId}">selected</c:if>>
                                                                    ${rt.typeName}
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>

                                                    <div class="mb-4">
                                                        <label for="status" class="form-label">Trạng thái <span class="text-danger">*</span></label>
                                                        <select class="form-select" id="status" name="status" required>
                                                            <c:forEach var="s" items="${statuses}">
                                                                <option value="${s}"
                                                                    <c:if test="${room.status == s}">selected</c:if>>
                                                                    <c:choose>
                                                                        <c:when test="${s == 'Available'}">Sẵn sàng</c:when>
                                                                        <c:when test="${s == 'Occupied'}">Đang sử dụng</c:when>
                                                                        <c:when test="${s == 'Cleaning'}">Đang dọn</c:when>
                                                                        <c:when test="${s == 'Maintenance'}">Bảo trì</c:when>
                                                                        <c:otherwise>${s}</c:otherwise>
                                                                    </c:choose>
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>

                                                    <div class="d-flex gap-2">
                                                        <button type="submit" class="btn btn-primary">
                                                            <i class="bi bi-check-lg me-1"></i>Cập nhật
                                                        </button>
                                                        <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-secondary">Hủy</a>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="card h-100" id="roomTypeInfoPanel">
                                            <div class="card-header">
                                                <i class="bi bi-info-circle me-2"></i>Thông tin loại phòng
                                            </div>
                                            <div class="card-body">
                                                <div id="roomTypeInfoContent" class="text-muted">
                                                    <p>Chọn loại phòng để xem thông tin.</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Tab 2: Room Images -->
                            <div class="tab-pane fade" id="tab-images">
                                <div class="card">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <span><i class="bi bi-images me-2"></i>Hình ảnh phòng ${room.roomNumber}</span>
                                        <span class="text-muted small">${not empty roomImages ? roomImages.size() : 0} ảnh</span>
                                    </div>
                                    <div class="card-body">
                                        <!-- Upload Zone -->
                                        <form method="post" action="${pageContext.request.contextPath}/admin/rooms/upload-image"
                                              enctype="multipart/form-data" id="uploadForm">
                                            <input type="hidden" name="roomId" value="${room.roomId}">
                                            <div class="upload-zone mb-4" onclick="document.getElementById('roomImageInput').click()">
                                                <i class="bi bi-cloud-arrow-up"></i>
                                                <p class="mb-1 fw-semibold">Nhấn để chọn ảnh hoặc kéo thả vào đây</p>
                                                <small class="text-muted">JPG, PNG, GIF - Tối đa 5MB</small>
                                                <input type="file" id="roomImageInput" name="roomImage"
                                                       accept="image/*" class="d-none" onchange="handleFileSelect(this)">
                                            </div>
                                            <!-- Preview before upload -->
                                            <div id="uploadPreview" class="d-none mb-3">
                                                <div class="d-flex align-items-center gap-3 p-3 border rounded">
                                                    <img id="previewImg" src="" alt="Preview" style="width:80px;height:60px;object-fit:cover;border-radius:8px;">
                                                    <div class="flex-grow-1">
                                                        <div id="previewName" class="fw-semibold small"></div>
                                                        <div id="previewSize" class="text-muted small"></div>
                                                    </div>
                                                    <button type="submit" class="btn btn-primary btn-sm">
                                                        <i class="bi bi-upload me-1"></i>Tải lên
                                                    </button>
                                                    <button type="button" class="btn btn-outline-secondary btn-sm" onclick="cancelUpload()">
                                                        <i class="bi bi-x"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </form>

                                        <!-- Existing Images Gallery -->
                                        <c:choose>
                                            <c:when test="${not empty roomImages}">
                                                <div class="room-image-grid">
                                                    <c:forEach var="img" items="${roomImages}">
                                                        <div class="room-image-card">
                                                            <img src="${pageContext.request.contextPath}${img.imageUrl}"
                                                                 alt="Phòng ${room.roomNumber}">
                                                            <div class="delete-overlay">
                                                                <form method="post" action="${pageContext.request.contextPath}/admin/rooms/delete-image"
                                                                      style="display:inline;" onsubmit="return confirm('Xóa ảnh này?')">
                                                                    <input type="hidden" name="imageId" value="${img.imageId}">
                                                                    <input type="hidden" name="roomId" value="${room.roomId}">
                                                                    <button type="submit" class="btn btn-danger btn-sm rounded-circle"
                                                                            title="Xóa ảnh">
                                                                        <i class="bi bi-trash"></i>
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="text-center py-4 text-muted">
                                                    <i class="bi bi-image" style="font-size:3rem;opacity:0.3;"></i>
                                                    <p class="mt-2 mb-0">Chưa có hình ảnh cho phòng này.</p>
                                                    <small>Tải ảnh lên bằng nút phía trên.</small>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>

                            <!-- Tab 3: Current Occupant -->
                            <div class="tab-pane fade" id="tab-occupant">
                                <div class="card">
                                    <div class="card-header">
                                        <i class="bi bi-person-check me-2"></i>Khách đang ở phòng ${room.roomNumber}
                                    </div>
                                    <div class="card-body">
                                        <c:choose>
                                            <c:when test="${not empty currentBooking}">
                                                <div class="occupant-card">
                                                    <div class="d-flex align-items-start gap-3">
                                                        <div class="occupant-avatar">
                                                            <c:choose>
                                                                <c:when test="${not empty currentBooking.customer.account.fullName}">
                                                                    ${currentBooking.customer.account.fullName.substring(0,1).toUpperCase()}
                                                                </c:when>
                                                                <c:otherwise>?</c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <div class="flex-grow-1">
                                                            <h5 class="mb-1 fw-bold">
                                                                ${currentBooking.customer.account.fullName}
                                                            </h5>
                                                            <div class="row g-3 mt-1">
                                                                <div class="col-md-6">
                                                                    <div class="text-muted small mb-1">
                                                                        <i class="bi bi-envelope me-1"></i>Email
                                                                    </div>
                                                                    <div>${currentBooking.customer.account.email}</div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="text-muted small mb-1">
                                                                        <i class="bi bi-phone me-1"></i>Điện thoại
                                                                    </div>
                                                                    <div>${not empty currentBooking.customer.account.phone ? currentBooking.customer.account.phone : 'Chưa cập nhật'}</div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="text-muted small mb-1">
                                                                        <i class="bi bi-calendar-check me-1"></i>Nhận phòng (dự kiến)
                                                                    </div>
                                                                    <div class="fw-semibold">${currentBooking.checkInExpectedFormatted}</div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="text-muted small mb-1">
                                                                        <i class="bi bi-calendar-x me-1"></i>Trả phòng (dự kiến)
                                                                    </div>
                                                                    <div class="fw-semibold">${currentBooking.checkOutExpectedFormatted}</div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="text-muted small mb-1">
                                                                        <i class="bi bi-cash me-1"></i>Tổng tiền
                                                                    </div>
                                                                    <div class="fw-bold text-primary">
                                                                        <fmt:formatNumber value="${currentBooking.totalPrice}" type="number" groupingUsed="true"/> VND
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="text-muted small mb-1">
                                                                        <i class="bi bi-bookmark me-1"></i>Mã booking
                                                                    </div>
                                                                    <div>#${currentBooking.bookingId}</div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="text-center py-5 text-muted">
                                                    <i class="bi bi-person-x" style="font-size:3rem;opacity:0.3;"></i>
                                                    <p class="mt-2 mb-0">Hiện không có khách nào ở phòng này.</p>
                                                    <small>Phòng sẽ hiển thị thông tin khách khi có người check-in.</small>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>

                            <!-- Tab 4: Room History -->
                            <div class="tab-pane fade" id="tab-history">
                                <div class="card">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <span><i class="bi bi-clock-history me-2"></i>Lịch sử phòng ${room.roomNumber}</span>
                                        <span class="text-muted small">${not empty bookings ? bookings.size() : 0} lượt đặt</span>
                                    </div>
                                    <div class="table-responsive">
                                        <table class="table-modern table-striped table-hover">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Tên khách</th>
                                                    <th>Nhận phòng (DK)</th>
                                                    <th>Trả phòng (DK)</th>
                                                    <th>Tổng tiền</th>
                                                    <th>Trạng thái</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${empty bookings}">
                                                        <tr>
                                                            <td colspan="6">
                                                                <div class="text-center py-4 text-muted">
                                                                    <i class="bi bi-clock-history" style="font-size:2rem;opacity:0.3;"></i>
                                                                    <p class="mt-2 mb-0">Chưa có lịch sử đặt phòng.</p>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:forEach var="b" items="${bookings}" varStatus="s">
                                                            <tr>
                                                                <td>${s.index + 1}</td>
                                                                <td>
                                                                    <div class="d-flex align-items-center gap-2">
                                                                        <div class="occupant-avatar" style="width:32px;height:32px;font-size:0.75rem;">
                                                                            <c:choose>
                                                                                <c:when test="${not empty b.customer && not empty b.customer.account}">
                                                                                    ${b.customer.account.fullName.substring(0,1).toUpperCase()}
                                                                                </c:when>
                                                                                <c:otherwise>?</c:otherwise>
                                                                            </c:choose>
                                                                        </div>
                                                                        ${b.customer != null && b.customer.account != null ? b.customer.account.fullName : '-'}
                                                                    </div>
                                                                </td>
                                                                <td>${b.checkInExpectedFormatted}</td>
                                                                <td>${b.checkOutExpectedFormatted}</td>
                                                                <td>
                                                                    <fmt:formatNumber value="${b.totalPrice}" type="number" groupingUsed="true"/> VND
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${b.status == 'CheckedOut'}">
                                                                            <span class="badge badge-available">Đã trả phòng</span>
                                                                        </c:when>
                                                                        <c:when test="${b.status == 'CheckedIn'}">
                                                                            <span class="badge badge-occupied">Đang ở</span>
                                                                        </c:when>
                                                                        <c:when test="${b.status == 'Confirmed'}">
                                                                            <span class="badge bg-info text-dark">Đã xác nhận</span>
                                                                        </c:when>
                                                                        <c:when test="${b.status == 'Pending'}">
                                                                            <span class="badge bg-warning text-dark">Chờ xác nhận</span>
                                                                        </c:when>
                                                                        <c:when test="${b.status == 'Cancelled'}">
                                                                            <span class="badge badge-cancelled">Đã hủy</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="badge bg-secondary">${b.status}</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="row g-4" style="max-width: 900px;">
                            <div class="col-md-6">
                                <div class="card h-100">
                                    <div class="card-header">
                                        <i class="bi bi-door-open me-2"></i>Thêm phòng
                                    </div>
                                    <div class="card-body">
                                        <form method="post" action="${pageContext.request.contextPath}/admin/rooms/create">
                                            <div class="mb-3">
                                                <label for="roomNumber" class="form-label">Số phòng <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="roomNumber" name="roomNumber"
                                                       placeholder="VD: 101, 202A" required maxlength="10">
                                            </div>

                                            <div class="mb-3">
                                                <label for="typeId" class="form-label">Loại phòng <span class="text-danger">*</span></label>
                                                <select class="form-select" id="typeId" name="typeId" required onchange="updateRoomTypePreview(this.value)">
                                                    <option value="">-- Chọn loại phòng --</option>
                                                    <c:forEach var="rt" items="${roomTypes}">
                                                        <option value="${rt.typeId}">${rt.typeName}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>

                                            <div class="mb-4">
                                                <label for="status" class="form-label">Trạng thái <span class="text-danger">*</span></label>
                                                <select class="form-select" id="status" name="status" required>
                                                    <c:forEach var="s" items="${statuses}">
                                                        <option value="${s}" <c:if test="${s == 'Available'}">selected</c:if>>
                                                            <c:choose>
                                                                <c:when test="${s == 'Available'}">Sẵn sàng</c:when>
                                                                <c:when test="${s == 'Occupied'}">Đang sử dụng</c:when>
                                                                <c:when test="${s == 'Cleaning'}">Đang dọn</c:when>
                                                                <c:when test="${s == 'Maintenance'}">Bảo trì</c:when>
                                                                <c:otherwise>${s}</c:otherwise>
                                                            </c:choose>
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>

                                            <div class="d-flex gap-2">
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="bi bi-check-lg me-1"></i>Tạo phòng
                                                </button>
                                                <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-secondary">Hủy</a>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card h-100" id="roomTypeInfoPanel">
                                    <div class="card-header">
                                        <i class="bi bi-info-circle me-2"></i>Thông tin loại phòng
                                    </div>
                                    <div class="card-body">
                                        <div id="roomTypeInfoContent" class="text-muted">
                                            <p>Chọn loại phòng để xem thông tin.</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>

    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // Room type preview data
        var roomTypeData = {
            <c:forEach var="rt" items="${roomTypes}" varStatus="loop">
                "${rt.typeId}": {
                    typeName: "${rt.typeName}",
                    basePrice: "${rt.basePrice}",
                    depositPercent: "${rt.depositPercent}",
                    capacity: "${rt.capacity}",
                    imageUrl: "<c:if test="${not empty roomTypeImages[rt.typeId]}">${pageContext.request.contextPath}${roomTypeImages[rt.typeId].imageUrl}</c:if>"
                }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        };

        function updateRoomTypePreview(typeId) {
            var content = document.getElementById('roomTypeInfoContent');
            if (!typeId || !roomTypeData[typeId]) {
                content.innerHTML = '<p class="text-muted">Chọn loại phòng để xem thông tin.</p>';
                return;
            }
            var rt = roomTypeData[typeId];
            var imgHtml = '';
            if (rt.imageUrl) {
                imgHtml = '<img src="' + rt.imageUrl + '" alt="' + rt.typeName + '" style="width:100%;height:160px;object-fit:cover;border-radius:8px;margin-bottom:1rem;">';
            }
            content.innerHTML = imgHtml +
                '<table class="table table-sm table-borderless mb-0">' +
                '<tr><td class="text-muted">Tên loại</td><td><strong>' + rt.typeName + '</strong></td></tr>' +
                '<tr><td class="text-muted">Giá/đêm</td><td><strong>' + Number(rt.basePrice).toLocaleString('vi-VN') + ' đ</strong></td></tr>' +
                '<tr><td class="text-muted">Đặt cọc</td><td>' + rt.depositPercent + '%</td></tr>' +
                '<tr><td class="text-muted">Sức chứa</td><td>' + rt.capacity + ' người</td></tr>' +
                '</table>';
        }

        // Auto-trigger on page load if editing
        window.addEventListener('DOMContentLoaded', function() {
            var sel = document.getElementById('typeId');
            if (sel && sel.value) {
                updateRoomTypePreview(sel.value);
            }
        });

        // Image upload preview
        function handleFileSelect(input) {
            if (input.files && input.files[0]) {
                var file = input.files[0];
                // Validate size (5MB)
                if (file.size > 5 * 1024 * 1024) {
                    alert('File quá lớn. Tối đa 5MB.');
                    input.value = '';
                    return;
                }
                // Validate type
                if (!file.type.startsWith('image/')) {
                    alert('Chỉ chấp nhận file ảnh.');
                    input.value = '';
                    return;
                }
                // Show preview
                var reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById('previewImg').src = e.target.result;
                    document.getElementById('previewName').textContent = file.name;
                    document.getElementById('previewSize').textContent = (file.size / 1024).toFixed(1) + ' KB';
                    document.getElementById('uploadPreview').classList.remove('d-none');
                };
                reader.readAsDataURL(file);
            }
        }

        function cancelUpload() {
            document.getElementById('roomImageInput').value = '';
            document.getElementById('uploadPreview').classList.add('d-none');
        }

        // Activate tab from URL hash
        (function() {
            var hash = window.location.hash;
            if (hash === '#images') {
                var tab = document.getElementById('images-tab');
                if (tab) {
                    var bsTab = new bootstrap.Tab(tab);
                    bsTab.show();
                }
            }
        })();

        // Drag and drop support
        (function() {
            var zone = document.querySelector('.upload-zone');
            if (!zone) return;
            ['dragenter','dragover','dragleave','drop'].forEach(function(evt) {
                zone.addEventListener(evt, function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                });
            });
            zone.addEventListener('dragover', function() { zone.style.borderColor = 'var(--accent, #d4af37)'; });
            zone.addEventListener('dragleave', function() { zone.style.borderColor = ''; });
            zone.addEventListener('drop', function(e) {
                zone.style.borderColor = '';
                var files = e.dataTransfer.files;
                if (files.length > 0) {
                    var input = document.getElementById('roomImageInput');
                    input.files = files;
                    handleFileSelect(input);
                }
            });
        })();
    </script>
</body>
</html>
