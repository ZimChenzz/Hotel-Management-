<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Phòng nghỉ - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        /* Room List Page Styles */
        .rooms-page { background: #f8f5f0; min-height: 100vh; }

        .rooms-hero {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            padding: 120px 0 60px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .rooms-hero::before {
            content: '';
            position: absolute; inset: 0;
            background: url('https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1920&q=60') center/cover;
            opacity: 0.15;
        }
        .rooms-hero-content { position: relative; z-index: 1; }
        .rooms-hero h1 {
            font-family: 'Playfair Display', serif;
            font-size: 3rem; font-weight: 700; color: #fff; margin-bottom: 0.5rem;
        }
        .rooms-hero h1 span { color: #e8d48a; }
        .rooms-hero p { color: rgba(255,255,255,0.8); font-size: 1.15rem; }

        /* Filter Bar */
        .filter-bar {
            background: #fff;
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: 0 4px 24px rgba(0,0,0,0.08);
            margin-top: -40px;
            position: relative; z-index: 2;
        }

        .filter-bar .form-label {
            font-size: 0.8rem; font-weight: 600; color: #6c757d;
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 0.35rem;
        }

        .filter-bar .form-select,
        .filter-bar .form-control {
            border: 1px solid #e0ddd8; border-radius: 10px;
            padding: 0.6rem 0.75rem; font-size: 0.95rem;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .filter-bar .form-select:focus,
        .filter-bar .form-control:focus {
            border-color: #c9a227;
            box-shadow: 0 0 0 3px rgba(201,162,39,0.12);
        }

        .btn-filter {
            background: linear-gradient(135deg, #c9a227 0%, #a68419 100%);
            color: #fff; border: none; border-radius: 10px;
            padding: 0.6rem 1.5rem; font-weight: 600;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-filter:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(201,162,39,0.3);
            color: #fff;
        }
        .btn-filter-clear {
            background: transparent; border: 1px solid #d0cdc7;
            color: #6c757d; border-radius: 10px; padding: 0.6rem 1.25rem;
            font-weight: 500; transition: all 0.2s;
        }
        .btn-filter-clear:hover { border-color: #1a1a2e; color: #1a1a2e; }

        /* Results Info */
        .results-info {
            display: flex; justify-content: space-between;
            align-items: center; margin-bottom: 1.5rem;
        }
        .results-count {
            font-size: 0.95rem; color: #6c757d;
        }
        .results-count strong { color: #1a1a2e; }

        /* Room Cards - Public */
        .pub-room-card {
            background: #fff;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 2px 16px rgba(0,0,0,0.06);
            transition: transform 0.35s ease, box-shadow 0.35s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .pub-room-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 16px 48px rgba(0,0,0,0.12);
        }

        .pub-room-img {
            position: relative;
            height: 240px;
            overflow: hidden;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
        }
        .pub-room-img img {
            width: 100%; height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }
        .pub-room-card:hover .pub-room-img img { transform: scale(1.08); }

        .pub-room-img-placeholder {
            height: 100%;
            display: flex; align-items: center; justify-content: center;
            color: rgba(255,255,255,0.3); font-size: 3rem;
        }

        .pub-room-badge {
            position: absolute; top: 14px; left: 14px;
            display: flex; gap: 0.5rem;
        }
        .pub-room-badge span {
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.78rem; font-weight: 600;
            backdrop-filter: blur(10px);
        }
        .badge-capacity {
            background: rgba(26,26,46,0.75); color: #fff;
        }
        .badge-discount {
            background: rgba(220,53,69,0.9); color: #fff;
        }

        .pub-room-body {
            padding: 1.5rem;
            flex: 1;
            display: flex; flex-direction: column;
        }

        .pub-room-type-tag {
            display: inline-block;
            font-size: 0.72rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: 1px;
            color: #c9a227; margin-bottom: 0.5rem;
        }

        .pub-room-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.4rem; font-weight: 600;
            color: #1a1a2e; margin-bottom: 0.5rem;
        }

        .pub-room-desc {
            font-size: 0.9rem; color: #6c757d;
            line-height: 1.6; margin-bottom: 1rem;
            flex: 1;
            display: -webkit-box; -webkit-line-clamp: 2;
            -webkit-box-orient: vertical; overflow: hidden;
        }

        .pub-room-amenities {
            display: flex; flex-wrap: wrap; gap: 0.4rem;
            margin-bottom: 1rem;
        }
        .pub-room-amenity {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 0.25rem 0.6rem;
            background: #f8f5f0; border-radius: 6px;
            font-size: 0.78rem; color: #555;
        }
        .pub-room-amenity i { color: #c9a227; font-size: 0.7rem; }

        .pub-room-footer {
            display: flex; align-items: center;
            justify-content: space-between;
            padding-top: 1rem;
            border-top: 1px solid #f0ede8;
        }

        .pub-room-price .price-original {
            text-decoration: line-through;
            font-size: 0.8rem; color: #aaa;
        }
        .pub-room-price .price-current {
            font-family: 'Playfair Display', serif;
            font-size: 1.35rem; font-weight: 700; color: #a68419;
        }
        .pub-room-price .price-period {
            font-size: 0.8rem; color: #999;
        }

        .btn-room-detail {
            background: #1a1a2e; color: #fff;
            border: none; border-radius: 12px;
            padding: 0.6rem 1.25rem;
            font-size: 0.9rem; font-weight: 500;
            transition: all 0.25s;
            text-decoration: none;
        }
        .btn-room-detail:hover {
            background: #c9a227; color: #fff;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(201,162,39,0.3);
        }

        /* Empty State */
        .empty-state {
            text-align: center; padding: 4rem 2rem;
            background: #fff; border-radius: 20px;
            box-shadow: 0 2px 16px rgba(0,0,0,0.06);
        }
        .empty-state i { font-size: 3rem; color: #d0cdc7; margin-bottom: 1rem; }
        .empty-state h5 { color: #1a1a2e; font-weight: 600; }
        .empty-state p { color: #6c757d; }

        /* Responsive */
        @media (max-width: 991.98px) {
            .rooms-hero { padding: 100px 0 50px; }
            .rooms-hero h1 { font-size: 2.25rem; }
            .pub-room-img { height: 200px; }
        }
        @media (max-width: 767.98px) {
            .rooms-hero { padding: 90px 0 40px; }
            .rooms-hero h1 { font-size: 1.75rem; }
            .filter-bar { margin-top: -30px; padding: 1rem; }
            .pub-room-img { height: 180px; }
            .pub-room-title { font-size: 1.2rem; }
            .pub-room-footer { flex-direction: column; gap: 0.75rem; align-items: stretch; }
            .btn-room-detail { text-align: center; }
        }
    </style>
</head>
<body class="rooms-page">
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Hero -->
    <section class="rooms-hero">
        <div class="container rooms-hero-content">
            <h1>Phòng nghỉ <span>sang trọng</span></h1>
            <p>Đa dạng loại phòng phù hợp với mọi nhu cầu của quý khách</p>
        </div>
    </section>

    <div class="container pb-5">
        <!-- Filter Bar -->
        <div class="filter-bar">
            <form method="get" action="${pageContext.request.contextPath}/rooms">
                <div class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label">Loại phòng</label>
                        <select name="typeId" class="form-select">
                            <option value="">Tất cả loại phòng</option>
                            <c:forEach var="type" items="${allTypes}">
                                <option value="${type.typeId}" ${selectedTypeId == type.typeId ? 'selected' : ''}>
                                    ${type.typeName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Giá tối thiểu</label>
                        <input type="number" name="minPrice" class="form-control"
                               value="${minPrice}" placeholder="0 VNĐ">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Giá tối đa</label>
                        <input type="number" name="maxPrice" class="form-control"
                               value="${maxPrice}" placeholder="Không giới hạn">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Số khách</label>
                        <select name="capacity" class="form-select">
                            <option value="">Tất cả</option>
                            <option value="1" ${capacity == 1 ? 'selected' : ''}>1+ khách</option>
                            <option value="2" ${capacity == 2 ? 'selected' : ''}>2+ khách</option>
                            <option value="3" ${capacity == 3 ? 'selected' : ''}>3+ khách</option>
                            <option value="4" ${capacity == 4 ? 'selected' : ''}>4+ khách</option>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex gap-2">
                        <button type="submit" class="btn btn-filter flex-fill">
                            <i class="bi bi-search me-1"></i>Tìm kiếm
                        </button>
                        <a href="${pageContext.request.contextPath}/rooms" class="btn btn-filter-clear">
                            <i class="bi bi-x-lg"></i>
                        </a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Results -->
        <div class="mt-4">
            <c:choose>
                <c:when test="${empty roomTypes}">
                    <div class="empty-state">
                        <i class="bi bi-search"></i>
                        <h5>Không tìm thấy phòng phù hợp</h5>
                        <p>Hãy thử thay đổi bộ lọc để tìm phòng khác</p>
                        <a href="${pageContext.request.contextPath}/rooms" class="btn btn-filter mt-2">
                            Xem tất cả phòng
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="results-info">
                        <span class="results-count">
                            Tìm thấy <strong>${roomTypes.size()}</strong> loại phòng
                        </span>
                    </div>

                    <div class="row g-4">
                        <c:forEach var="room" items="${roomTypes}">
                            <div class="col-md-6 col-lg-4">
                                <div class="pub-room-card">
                                    <!-- Image -->
                                    <div class="pub-room-img">
                                        <c:choose>
                                            <c:when test="${not empty room.images}">
                                                <img src="${pageContext.request.contextPath}${room.images[0].imageUrl}"
                                                     alt="${room.typeName}" loading="lazy">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="pub-room-img-placeholder">
                                                    <i class="bi bi-image"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="pub-room-badge">
                                            <span class="badge-capacity">
                                                <i class="bi bi-people me-1"></i>${room.capacity} khách
                                            </span>
                                            <c:if test="${not empty promotionMap[room.typeId]}">
                                                <span class="badge-discount">
                                                    -${promotionMap[room.typeId].discountPercent}%
                                                </span>
                                            </c:if>
                                        </div>
                                    </div>

                                    <!-- Body -->
                                    <div class="pub-room-body">
                                        <span class="pub-room-type-tag">
                                            <i class="bi bi-star-fill me-1"></i>Luxury Hotel
                                        </span>
                                        <h3 class="pub-room-title">${room.typeName}</h3>
                                        <p class="pub-room-desc">${room.description}</p>

                                        <c:if test="${not empty room.amenities}">
                                            <div class="pub-room-amenities">
                                                <c:forEach var="amenity" items="${room.amenities}" end="3">
                                                    <span class="pub-room-amenity">
                                                        <i class="bi bi-check-circle-fill"></i> ${amenity.name}
                                                    </span>
                                                </c:forEach>
                                                <c:if test="${room.amenities.size() > 4}">
                                                    <span class="pub-room-amenity">
                                                        +${room.amenities.size() - 4}
                                                    </span>
                                                </c:if>
                                            </div>
                                        </c:if>

                                        <!-- Footer: Price + Button -->
                                        <div class="pub-room-footer">
                                            <div class="pub-room-price">
                                                <c:choose>
                                                    <c:when test="${not empty discountedPriceMap[room.typeId]}">
                                                        <span class="price-original">
                                                            <fmt:formatNumber value="${room.basePrice}" type="number" groupingUsed="true"/>đ
                                                        </span><br>
                                                        <span class="price-current">
                                                            <fmt:formatNumber value="${discountedPriceMap[room.typeId]}" type="number" groupingUsed="true"/>đ
                                                        </span>
                                                        <span class="price-period">/đêm</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="price-current">
                                                            <fmt:formatNumber value="${room.basePrice}" type="number" groupingUsed="true"/>đ
                                                        </span>
                                                        <span class="price-period">/đêm</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/rooms/detail?typeId=${room.typeId}"
                                               class="btn-room-detail">
                                                Chi tiết <i class="bi bi-arrow-right ms-1"></i>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Footer -->
    <jsp:include page="/WEB-INF/includes/footer.jsp"/>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Scroll reveal animation
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, { threshold: 0.1 });

        document.querySelectorAll('.pub-room-card').forEach((card, i) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(30px)';
            card.style.transition = `opacity 0.6s ease ${i * 0.1}s, transform 0.6s ease ${i * 0.1}s`;
            observer.observe(card);
        });
    </script>
</body>
</html>
