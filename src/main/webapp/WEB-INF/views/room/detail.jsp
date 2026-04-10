<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${roomType.typeName} - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .carousel-item img { height: 450px; object-fit: cover; }
        .amenity-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: var(--surface-hover);
            border-radius: var(--radius-sm);
            margin: 0.25rem;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Page Header -->
    <section class="public-hero public-hero-small">
        <div class="container text-center">
            <h1 class="public-hero-title">${roomType.typeName}</h1>
            <p class="public-hero-subtitle">Chi tiết phòng</p>
        </div>
    </section>

    <div class="container py-5">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/"><i class="bi bi-house"></i> Trang chủ</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
                <li class="breadcrumb-item active">${roomType.typeName}</li>
            </ol>
        </nav>

        <div class="row g-4">
            <!-- Image Carousel -->
            <div class="col-lg-7">
                <div class="card">
                    <c:choose>
                        <c:when test="${not empty roomType.images}">
                            <div id="roomCarousel" class="carousel slide" data-bs-ride="carousel">
                                <div class="carousel-indicators">
                                    <c:forEach var="img" items="${roomType.images}" varStatus="status">
                                        <button type="button" data-bs-target="#roomCarousel" data-bs-slide-to="${status.index}"
                                                class="${status.first ? 'active' : ''}" aria-current="${status.first ? 'true' : 'false'}"></button>
                                    </c:forEach>
                                </div>
                                <div class="carousel-inner">
                                    <c:forEach var="img" items="${roomType.images}" varStatus="status">
                                        <div class="carousel-item ${status.first ? 'active' : ''}">
                                            <img src="${pageContext.request.contextPath}${img.imageUrl}" class="d-block w-100" alt="${roomType.typeName}">
                                        </div>
                                    </c:forEach>
                                </div>
                                <c:if test="${fn:length(roomType.images) > 1}">
                                    <button class="carousel-control-prev" type="button" data-bs-target="#roomCarousel" data-bs-slide="prev">
                                        <span class="carousel-control-prev-icon"></span>
                                    </button>
                                    <button class="carousel-control-next" type="button" data-bs-target="#roomCarousel" data-bs-slide="next">
                                        <span class="carousel-control-next-icon"></span>
                                    </button>
                                </c:if>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="d-flex align-items-center justify-content-center bg-secondary text-white" style="height: 450px;">
                                <div class="text-center">
                                    <i class="bi bi-image fs-1 mb-2"></i>
                                    <p class="mb-0">Chưa có hình ảnh</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Room Info -->
            <div class="col-lg-5">
                <div class="card">
                    <div class="card-body p-4">
                        <h1 class="mb-3" style="font-family: var(--font-display); font-size: 2rem; color: var(--primary);">
                            ${roomType.typeName}
                        </h1>

                        <c:choose>
                            <c:when test="${not empty activePromo}">
                                <div class="mb-1">
                                    <span style="text-decoration:line-through;color:var(--text-muted);font-size:1.2rem;">
                                        <fmt:formatNumber value="${roomType.basePrice}" type="number" groupingUsed="true"/>đ
                                    </span>
                                </div>
                                <div class="h2 mb-2" style="color:var(--danger);font-family:var(--font-display);">
                                    <fmt:formatNumber value="${discountedPrice}" type="number" groupingUsed="true"/>đ
                                    <span class="fs-6 text-muted fw-normal">/đêm</span>
                                </div>
                                <div class="alert alert-success py-2 px-3 mb-4" style="font-size:0.9rem;">
                                    <i class="bi bi-tag me-1"></i>
                                    Khuyến mãi <strong>${activePromo.promoCode}</strong>:
                                    Giảm <strong>${activePromo.discountPercent}%</strong>
                                    - Đến ${activePromo.endDate}
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="h2 mb-4" style="color:var(--secondary-dark);font-family:var(--font-display);">
                                    <fmt:formatNumber value="${roomType.basePrice}" type="number" groupingUsed="true"/>đ
                                    <span class="fs-6 text-muted fw-normal">/đêm</span>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <div class="d-flex gap-2 mb-4">
                            <span class="badge bg-secondary fs-6 px-3 py-2">
                                <i class="bi bi-people me-1"></i> Tối đa ${roomType.capacity} khách
                            </span>
                            <c:choose>
                                <c:when test="${availableCount > 0}">
                                    <span class="badge badge-available fs-6 px-3 py-2">
                                        <i class="bi bi-check-circle me-1"></i> Còn ${availableCount} phòng
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-cancelled fs-6 px-3 py-2">
                                        <i class="bi bi-x-circle me-1"></i> Hết phòng
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <h5 class="fw-bold mb-2">Mô tả</h5>
                        <p class="text-muted mb-4">${roomType.description}</p>

                        <c:if test="${not empty roomType.amenities}">
                            <h5 class="fw-bold mb-3">Tiện nghi</h5>
                            <div class="mb-4">
                                <c:forEach var="amenity" items="${roomType.amenities}">
                                    <span class="amenity-badge">
                                        <c:choose>
                                            <c:when test="${not empty amenity.iconUrl}">
                                                <img src="${amenity.iconUrl}" alt="" width="18">
                                            </c:when>
                                            <c:otherwise>
                                                <i class="bi bi-check-circle-fill text-success"></i>
                                            </c:otherwise>
                                        </c:choose>
                                        ${amenity.name}
                                    </span>
                                </c:forEach>
                            </div>
                        </c:if>

                        <c:choose>
                            <c:when test="${availableCount > 0}">
                                <a href="${pageContext.request.contextPath}/booking/create?typeId=${roomType.typeId}"
                                   class="btn btn-primary btn-lg w-100">
                                    <i class="bi bi-calendar-check me-2"></i>Đặt phòng ngay
                                </a>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-secondary btn-lg w-100" disabled>
                                    <i class="bi bi-x-circle me-2"></i>Hết phòng
                                </button>
                            </c:otherwise>
                        </c:choose>

                        <div class="text-center mt-3">
                            <a href="${pageContext.request.contextPath}/rooms" class="text-decoration-none" style="color: var(--secondary-dark);">
                                <i class="bi bi-arrow-left me-1"></i> Quay lại danh sách phòng
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
