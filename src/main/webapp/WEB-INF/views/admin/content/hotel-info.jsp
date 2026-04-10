<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thông tin khách sạn - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="hotel-info" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Thông tin khách sạn" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Breadcrumb -->
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item active">Thông tin khách sạn</li>
                    </ol>
                </nav>

                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1 class="page-header-title">Thông tin khách sạn</h1>
                        <p class="page-header-subtitle">Quản lý thông tin hiển thị trên website</p>
                    </div>
                </div>

                <!-- Alerts -->
                <c:if test="${param.success == 'saved'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle me-2"></i>Thông tin đã được cập nhật.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-circle me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/admin/content/hotel-info/save" enctype="multipart/form-data">
                    <div class="row">
                        <!-- Basic Info -->
                        <div class="col-lg-8">
                            <div class="card mb-4">
                                <div class="card-header">
                                    <i class="bi bi-building me-2"></i>Thông tin cơ bản
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label class="form-label">Tên khách sạn <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" name="hotelName"
                                               value="${hotelInfo.name != null ? hotelInfo.name : 'Luxury Hotel'}" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Slogan</label>
                                        <input type="text" class="form-control" name="slogan"
                                               value="${hotelInfo.slogan}" placeholder="Nơi nghỉ dưỡng lý tưởng...">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Mô tả ngắn</label>
                                        <textarea class="form-control" name="shortDescription" rows="3"
                                                  placeholder="Giới thiệu ngắn về khách sạn...">${hotelInfo.shortDescription}</textarea>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Mô tả chi tiết</label>
                                        <textarea class="form-control" name="fullDescription" rows="6"
                                                  placeholder="Mô tả đầy đủ về khách sạn, tiện nghi, dịch vụ...">${hotelInfo.fullDescription}</textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="card mb-4">
                                <div class="card-header">
                                    <i class="bi bi-geo-alt me-2"></i>Địa chỉ & Liên hệ
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label class="form-label">Địa chỉ</label>
                                                <textarea class="form-control" name="address" rows="2">${hotelInfo.address}</textarea>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Thành phố</label>
                                                <input type="text" class="form-control" name="city" value="${hotelInfo.city}">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label class="form-label">Số điện thoại</label>
                                                <input type="tel" class="form-control" name="phone" value="${hotelInfo.phone}">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Email</label>
                                                <input type="email" class="form-control" name="email" value="${hotelInfo.email}">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Website</label>
                                                <input type="url" class="form-control" name="website" value="${hotelInfo.website}"
                                                       placeholder="https://...">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="card mb-4">
                                <div class="card-header">
                                    <i class="bi bi-clock me-2"></i>Chính sách Check-in / Check-out
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label class="form-label">Giờ check-in</label>
                                                <input type="time" class="form-control" name="checkInTime"
                                                       value="${hotelInfo.checkInTime != null ? hotelInfo.checkInTime : '14:00'}">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label class="form-label">Giờ check-out</label>
                                                <input type="time" class="form-control" name="checkOutTime"
                                                       value="${hotelInfo.checkOutTime != null ? hotelInfo.checkOutTime : '12:00'}">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Chính sách hủy phòng</label>
                                        <textarea class="form-control" name="cancellationPolicy" rows="3"
                                                  placeholder="Mô tả chính sách hủy phòng, hoàn tiền...">${hotelInfo.cancellationPolicy}</textarea>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Quy định khác</label>
                                        <textarea class="form-control" name="policies" rows="4"
                                                  placeholder="Các quy định về thú cưng, hút thuốc, khách thêm...">${hotelInfo.policies}</textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Sidebar -->
                        <div class="col-lg-4">
                            <div class="card mb-4">
                                <div class="card-header">
                                    <i class="bi bi-image me-2"></i>Logo
                                </div>
                                <div class="card-body text-center">
                                    <c:choose>
                                        <c:when test="${hotelInfo.logo != null}">
                                            <img src="${hotelInfo.logo}" alt="Logo" class="img-fluid mb-3" style="max-height: 100px;">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="empty-state py-4">
                                                <i class="bi bi-image fs-1 text-muted"></i>
                                                <p class="text-muted mt-2 mb-0">Chưa có logo</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <input type="file" class="form-control" name="logo" accept="image/*">
                                    <div class="form-text">PNG, JPG. Tối đa 2MB.</div>
                                </div>
                            </div>

                            <div class="card mb-4">
                                <div class="card-header">
                                    <i class="bi bi-share me-2"></i>Mạng xã hội
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label class="form-label"><i class="bi bi-facebook me-2"></i>Facebook</label>
                                        <input type="url" class="form-control" name="facebook" value="${hotelInfo.facebook}"
                                               placeholder="https://facebook.com/...">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><i class="bi bi-instagram me-2"></i>Instagram</label>
                                        <input type="url" class="form-control" name="instagram" value="${hotelInfo.instagram}"
                                               placeholder="https://instagram.com/...">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><i class="bi bi-twitter-x me-2"></i>Twitter/X</label>
                                        <input type="url" class="form-control" name="twitter" value="${hotelInfo.twitter}"
                                               placeholder="https://x.com/...">
                                    </div>
                                </div>
                            </div>

                            <div class="card mb-4">
                                <div class="card-header">
                                    <i class="bi bi-star me-2"></i>Tiện nghi nổi bật
                                </div>
                                <div class="card-body">
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" name="amenities" value="wifi" id="amenityWifi"
                                               ${hotelInfo.amenities != null && hotelInfo.amenities.contains('wifi') ? 'checked' : ''}>
                                        <label class="form-check-label" for="amenityWifi"><i class="bi bi-wifi me-2"></i>WiFi miễn phí</label>
                                    </div>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" name="amenities" value="pool" id="amenityPool"
                                               ${hotelInfo.amenities != null && hotelInfo.amenities.contains('pool') ? 'checked' : ''}>
                                        <label class="form-check-label" for="amenityPool"><i class="bi bi-water me-2"></i>Hồ bơi</label>
                                    </div>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" name="amenities" value="spa" id="amenitySpa"
                                               ${hotelInfo.amenities != null && hotelInfo.amenities.contains('spa') ? 'checked' : ''}>
                                        <label class="form-check-label" for="amenitySpa"><i class="bi bi-heart me-2"></i>Spa & Massage</label>
                                    </div>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" name="amenities" value="gym" id="amenityGym"
                                               ${hotelInfo.amenities != null && hotelInfo.amenities.contains('gym') ? 'checked' : ''}>
                                        <label class="form-check-label" for="amenityGym"><i class="bi bi-activity me-2"></i>Phòng gym</label>
                                    </div>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" name="amenities" value="restaurant" id="amenityRestaurant"
                                               ${hotelInfo.amenities != null && hotelInfo.amenities.contains('restaurant') ? 'checked' : ''}>
                                        <label class="form-check-label" for="amenityRestaurant"><i class="bi bi-cup-hot me-2"></i>Nhà hàng</label>
                                    </div>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" name="amenities" value="parking" id="amenityParking"
                                               ${hotelInfo.amenities != null && hotelInfo.amenities.contains('parking') ? 'checked' : ''}>
                                        <label class="form-check-label" for="amenityParking"><i class="bi bi-p-square me-2"></i>Bãi đỗ xe</label>
                                    </div>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" name="amenities" value="bar" id="amenityBar"
                                               ${hotelInfo.amenities != null && hotelInfo.amenities.contains('bar') ? 'checked' : ''}>
                                        <label class="form-check-label" for="amenityBar"><i class="bi bi-cup-straw me-2"></i>Quầy bar</label>
                                    </div>
                                </div>
                            </div>

                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="bi bi-check-lg me-2"></i>Lưu thông tin
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <!-- Mobile Toggle -->
    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
