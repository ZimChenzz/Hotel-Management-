<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chọn phòng - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <style>
        .booking-hero {
            background: var(--primary-gradient);
            padding: 3rem 0;
            margin-bottom: 2rem;
        }
        .step-indicator {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 2rem;
        }
        .step-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .step-number {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 0.875rem;
        }
        .step-active .step-number {
            background: var(--primary);
            color: white;
        }
        .step-completed .step-number {
            background: var(--success);
            color: white;
        }
        .step-inactive .step-number {
            background: var(--border-color);
            color: var(--text-muted);
        }
        .step-line {
            width: 60px;
            height: 2px;
            background: var(--border-color);
        }
        .room-type-card {
            border: 1px solid var(--border-color);
            border-radius: 0.75rem;
            overflow: visible;
            transition: all 0.3s ease;
        }
        .room-type-card:hover {
            border-color: var(--primary);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .room-type-card.selected {
            border-color: var(--primary);
            background: rgba(25, 135, 84, 0.05);
        }
        .room-image-container {
            position: relative;
            z-index: 0;
        }
        .room-image {
            height: 180px;
            object-fit: cover;
            width: 100%;
            display: block;
        }
        .qty-control {
            display: inline-flex !important;
            align-items: center;
            gap: 0.5rem;
            position: relative;
            z-index: 2;
        }
        .qty-control input {
            width: 60px !important;
            min-width: 60px;
            display: inline-block;
        }
        .qty-btn {
            width: 32px;
            height: 32px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }
        .summary-bar {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: white;
            box-shadow: 0 -4px 12px rgba(0,0,0,0.1);
            padding: 1rem 0;
            z-index: 100;
        }
        .amenity-badge {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            background: var(--surface-hover);
            border-radius: 0.25rem;
            font-size: 0.75rem;
            margin-right: 0.25rem;
            margin-bottom: 0.25rem;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Hero Section -->
    <section class="booking-hero">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-2" style="--bs-breadcrumb-divider-color: rgba(255,255,255,0.5);">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/" style="color: rgba(255,255,255,0.7);">Trang chủ</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/booking/start" style="color: rgba(255,255,255,0.7);">Đặt phòng</a></li>
                    <li class="breadcrumb-item text-white">Chọn phòng</li>
                </ol>
            </nav>
            <h1 class="public-hero-title"><i class="bi bi-door-open me-2"></i>Chọn loại phòng</h1>
        </div>
    </section>

    <div class="container pb-5">
        <!-- Step Indicator -->
        <div class="step-indicator">
            <div class="step-item step-completed">
                <span class="step-number"><i class="bi bi-check"></i></span>
                <span>Chọn ngày</span>
            </div>
            <div class="step-line" style="background: var(--success);"></div>
            <div class="step-item step-active">
                <span class="step-number">2</span>
                <span>Chọn phòng</span>
            </div>
            <div class="step-line"></div>
            <div class="step-item step-inactive">
                <span class="step-number">3</span>
                <span>Xác nhận</span>
            </div>
        </div>

        <!-- Date Info Banner -->
        <div class="alert alert-info mb-4" style="background: var(--surface-hover); border: 1px solid var(--border-color); color: var(--text);">
            <div class="d-flex justify-content-center gap-5 flex-wrap">
                <span>
                    <i class="bi bi-calendar-check text-success me-2"></i>
                    <strong>Nhận phòng:</strong> ${checkInFormatted}
                </span>
                <span>
                    <i class="bi bi-calendar-x text-danger me-2"></i>
                    <strong>Trả phòng:</strong> ${checkOutFormatted}
                </span>
                <span>
                    <i class="bi bi-moon-stars text-primary me-2"></i>
                    <strong>Số đêm:</strong> ${nights} đêm
                </span>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>${error}
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/booking/select-rooms" id="roomForm">
            <!-- Voucher Input -->
            <div class="card mb-4">
                <div class="card-body">
                    <div class="row align-items-center">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold mb-md-0">
                                <i class="bi bi-ticket-perforated me-2 text-secondary"></i>Mã voucher (nếu có)
                            </label>
                        </div>
                        <div class="col-md-6">
                            <div class="input-group">
                                <input type="text" name="voucherCode" class="form-control"
                                       placeholder="Nhập mã voucher" value="${voucherCode}">
                                <button type="button" class="btn btn-outline-secondary" onclick="checkVoucher()">
                                    <i class="bi bi-check-circle"></i> Áp dụng
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Room Types Grid -->
            <div class="row g-4 mb-5">
                <c:forEach var="roomType" items="${allRoomTypes}">
                    <div class="col-md-6 col-lg-4">
                        <div class="room-type-card h-100" id="card-${roomType.typeId}">
                            <div class="room-image-container">
                                <c:choose>
                                    <c:when test="${not empty roomType.images and not empty roomType.images[0].imageUrl}">
                                        <c:choose>
                                            <c:when test="${roomType.images[0].imageUrl.startsWith('http')}">
                                                <img src="${roomType.images[0].imageUrl}" alt="${roomType.typeName}" class="room-image">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}${roomType.images[0].imageUrl}" alt="${roomType.typeName}" class="room-image">
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="room-image d-flex align-items-center justify-content-center bg-secondary">
                                            <span class="text-white">No Image</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="p-3">
                                <h5 class="mb-2" style="font-family: var(--font-display); color: var(--primary);">
                                    ${roomType.typeName}
                                </h5>
                                <p class="text-muted small mb-2">
                                    <i class="bi bi-people me-1"></i>Sức chứa: ${roomType.capacity} người
                                </p>
                                <p class="text-muted small mb-2">
                                    <i class="bi bi-currency-dollar me-1"></i>
                                    <fmt:formatNumber value="${roomType.basePrice}" type="number" groupingUsed="true"/>đ/đêm
                                </p>
                                <c:if test="${roomType.pricePerHour > 0}">
                                    <p class="text-muted small mb-2">
                                        <i class="bi bi-clock me-1"></i>
                                        <fmt:formatNumber value="${roomType.pricePerHour}" type="number" groupingUsed="true"/>đ/giờ (gia hạn)
                                    </p>
                                </c:if>

                                <!-- Amenities -->
                                <div class="mb-3">
                                    <c:forEach var="amenity" items="${roomType.amenities}" end="2">
                                        <span class="amenity-badge">${amenity.name}</span>
                                    </c:forEach>
                                </div>

                                <!-- Availability -->
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <span class="small">
                                        <i class="bi bi-check-circle text-success me-1"></i>
                                        Còn trống: <strong id="avail-${roomType.typeId}">${availability[roomType.typeId]}</strong> phòng
                                    </span>
                                </div>

                                <!-- Quantity Selector -->
                                <div class="d-flex align-items-center justify-content-between">
                                    <span class="small fw-semibold">Số lượng:</span>
                                    <div class="qty-control">
                                        <button type="button" class="btn btn-outline-secondary qty-btn"
                                                onclick="updateQty('${roomType.typeId}', -1, ${availability[roomType.typeId]})">
                                            <i class="bi bi-dash"></i>
                                        </button>
                                        <input type="number" name="quantity_${roomType.typeId}"
                                               id="qty-${roomType.typeId}" value="0" min="0"
                                               max="${availability[roomType.typeId]}"
                                               class="form-control text-center" readonly>
                                        <button type="button" class="btn btn-outline-secondary qty-btn"
                                                onclick="updateQty('${roomType.typeId}', 1, ${availability[roomType.typeId]})">
                                            <i class="bi bi-plus"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Hidden inputs for quantities -->
            <div id="selectedRooms"></div>
        </form>
    </div>

    <!-- Fixed Summary Bar -->
    <div class="summary-bar">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <span class="text-muted me-3">
                        <i class="bi bi-door-open me-1"></i>
                        <span id="totalRooms">0</span> phòng được chọn
                    </span>
                    <span class="text-muted">
                        <i class="bi bi-currency-dollar me-1"></i>
                        Tổng: <strong id="totalPrice">0</strong>đ
                    </span>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/booking/start" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại
                    </a>
                    <button type="button" class="btn btn-primary" onclick="submitForm()" id="continueBtn" disabled>
                        Tiếp tục <i class="bi bi-arrow-right ms-1"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Add padding at bottom to account for fixed bar -->
    <div style="height: 120px;"></div>

    <style>
        body {
            padding-bottom: 120px !important;
        }
    </style>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Store room type prices for calculation
        const roomPrices = {
            <c:forEach var="roomType" items="${allRoomTypes}" varStatus="loop">
                '${roomType.typeId}': ${roomType.basePrice}${loop.last ? '' : ','}
            </c:forEach>
        };
        const nights = ${nights};

        function updateQty(typeId, delta, maxAvail) {
            const input = document.getElementById('qty-' + typeId);
            const card = document.getElementById('card-' + typeId);
            let current = parseInt(input.value) || 0;
            let newVal = current + delta;

            if (newVal < 0) newVal = 0;
            if (newVal > maxAvail) newVal = maxAvail;

            input.value = newVal;

            if (newVal > 0) {
                card.classList.add('selected');
            } else {
                card.classList.remove('selected');
            }

            updateSummary();
        }

        function updateSummary() {
            let totalRooms = 0;
            let totalPrice = 0;

            <c:forEach var="roomType" items="${allRoomTypes}">
                var qty = parseInt(document.getElementById('qty-${roomType.typeId}').value) || 0;
                totalRooms += qty;
                totalPrice += qty * roomPrices['${roomType.typeId}'] * nights;
            </c:forEach>

            document.getElementById('totalRooms').textContent = totalRooms;
            document.getElementById('totalPrice').textContent = totalPrice.toLocaleString('vi-VN');

            const continueBtn = document.getElementById('continueBtn');
            if (totalRooms > 0) {
                continueBtn.disabled = false;
            } else {
                continueBtn.disabled = true;
            }
        }

        function submitForm() {
            const form = document.getElementById('roomForm');
            const selectedDiv = document.getElementById('selectedRooms');
            selectedDiv.innerHTML = '';

            <c:forEach var="roomType" items="${allRoomTypes}">
                var qty = parseInt(document.getElementById('qty-${roomType.typeId}').value) || 0;
                if (qty > 0) {
                    selectedDiv.innerHTML += '<input type="hidden" name="typeId" value="${roomType.typeId}">';
                    selectedDiv.innerHTML += '<input type="hidden" name="quantity" value="' + qty + '">';
                }
            </c:forEach>

            form.submit();
        }

        function checkVoucher() {
            const code = document.querySelector('input[name="voucherCode"]').value;
            if (code.trim()) {
                // Voucher will be validated on submit
                alert('Mã voucher "' + code + '" sẽ được kiểm tra khi xác nhận đặt phòng.');
            }
        }

        // Initialize summary on page load
        updateSummary();
    </script>
</body>
</html>
