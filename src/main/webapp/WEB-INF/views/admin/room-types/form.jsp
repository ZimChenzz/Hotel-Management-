<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${not empty roomType ? 'Sửa loại phòng' : 'Thêm loại phòng'} - Cổng Quản Trị</title>
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
            <c:set var="pageTitle" value="${not empty roomType ? 'Sửa loại phòng' : 'Thêm loại phòng'}" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/room-types">Loại phòng</a></li>
                        <li class="breadcrumb-item active">${not empty roomType ? 'Sửa' : 'Thêm'}</li>
                    </ol>
                </nav>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-circle me-2"></i>${error}
                    </div>
                </c:if>

                <div class="card" style="max-width: 700px;">
                    <div class="card-header">
                        <i class="bi bi-collection me-2"></i>${not empty roomType ? 'Sửa' : 'Thêm'} loại phòng
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}${not empty roomType ? '/admin/room-types/edit' : '/admin/room-types/create'}" id="roomTypeForm">
                            <c:if test="${not empty roomType}">
                                <input type="hidden" name="typeId" value="${roomType.typeId}">
                            </c:if>

                            <div class="mb-3">
                                <label for="typeName" class="form-label">Tên loại phòng <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="typeName" name="typeName"
                                       value="${roomType != null ? roomType.typeName : ''}"
                                       placeholder="VD: Deluxe, Suite, Standard" required maxlength="100">
                            </div>

                            <div class="mb-3">
                                <label for="basePrice" class="form-label">Giá cơ bản (VND/đêm) <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" id="basePrice" name="basePrice"
                                       value="${roomType != null ? roomType.basePrice : ''}"
                                       placeholder="VD: 500000" min="0" step="1000" required>
                            </div>

                            <div class="mb-3">
                                <label for="capacity" class="form-label">Sức chứa (người) <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" id="capacity" name="capacity"
                                       value="${roomType != null ? roomType.capacity : ''}"
                                       placeholder="VD: 2" min="1" max="20" required>
                            </div>

                            <div class="mb-3">
                                <label for="pricePerHour" class="form-label">Giá theo giờ (VND/giờ)</label>
                                <input type="number" class="form-control" id="pricePerHour" name="pricePerHour"
                                       value="${roomType != null ? roomType.pricePerHour : '0'}"
                                       placeholder="VD: 100000" min="0" step="1000">
                            </div>

                            <div class="mb-3">
                                <label for="depositPercent" class="form-label">Phần trăm đặt cọc (%)</label>
                                <input type="number" class="form-control" id="depositPercent" name="depositPercent"
                                       value="${roomType != null ? roomType.depositPercent : '0'}"
                                       placeholder="VD: 30" min="0" max="100" step="1">
                                <div class="form-text">Đặt 0 cho phòng tiêu chuẩn (không cần đặt cọc).</div>
                            </div>

                            <div class="mb-4">
                                <label for="description" class="form-label">Mô tả</label>
                                <textarea class="form-control" id="description" name="description"
                                          rows="4" placeholder="Mô tả về loại phòng này..."
                                          maxlength="500">${roomType != null ? roomType.description : ''}</textarea>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check-lg me-1"></i>
                                    ${not empty roomType ? 'Cập nhật' : 'Tạo loại phòng'}
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/room-types"
                                   class="btn btn-secondary">Hủy</a>
                            </div>
                        </form>

                        <!-- Image Management Section - Outside main form -->
                        <c:if test="${not empty roomType}">
                            <hr class="my-4">
                            <div class="mb-4" id="images">
                                <label class="form-label fw-semibold">Hình ảnh phòng</label>

                                <c:if test="${not empty existingImages}">
                                    <div class="d-flex flex-wrap gap-2 mb-3">
                                        <c:forEach var="img" items="${existingImages}">
                                            <div class="position-relative" style="width:100px;">
                                                <img src="${pageContext.request.contextPath}${img.imageUrl}"
                                                     alt="Room image"
                                                     style="width:100px;height:70px;object-fit:cover;border-radius:6px;border:1px solid #dee2e6;">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/room-types/delete-image" style="display:inline;">
                                                    <input type="hidden" name="imageId" value="${img.imageId}">
                                                    <input type="hidden" name="typeId" value="${roomType.typeId}">
                                                    <button type="submit" class="btn btn-danger btn-sm position-absolute"
                                                            style="top:2px;right:2px;padding:1px 5px;font-size:0.7rem;"
                                                            onclick="return confirm('Xóa ảnh này?')">
                                                        <i class="bi bi-x"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:if>

                                <!-- Upload form -->
                                <form method="post" action="${pageContext.request.contextPath}/admin/room-types/upload-image" enctype="multipart/form-data" class="mb-3">
                                    <input type="hidden" name="typeId" value="${roomType.typeId}">
                                    <div class="input-group">
                                        <input type="file" class="form-control" id="roomTypeImage" name="roomTypeImage" accept="image/*">
                                        <button type="submit" class="btn btn-success">
                                            <i class="bi bi-upload"></i> Tải lên
                                        </button>
                                    </div>
                                    <div class="form-text">Chọn file ảnh (JPG, PNG, GIF) từ máy tính. Tối đa 5MB.</div>
                                </form>

                                <div class="text-muted small mb-2">hoặc nhập URL ảnh:</div>
                                <form method="post" action="${pageContext.request.contextPath}/admin/room-types/edit" class="d-flex gap-2">
                                    <input type="hidden" name="typeId" value="${roomType.typeId}">
                                    <input type="hidden" name="typeName" value="${roomType.typeName}">
                                    <input type="hidden" name="basePrice" value="${roomType.basePrice}">
                                    <input type="hidden" name="capacity" value="${roomType.capacity}">
                                    <input type="hidden" name="pricePerHour" value="${roomType.pricePerHour}">
                                    <input type="hidden" name="depositPercent" value="${roomType.depositPercent}">
                                    <input type="hidden" name="description" value="${roomType.description}">
                                    <div class="input-group">
                                        <input type="text" class="form-control" id="imageUrl" name="imageUrl"
                                               placeholder="/images/rooms/ten-anh.jpg">
                                        <button type="submit" class="btn btn-outline-primary">
                                            <i class="bi bi-plus"></i> Thêm
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </c:if>
                    </div>
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
