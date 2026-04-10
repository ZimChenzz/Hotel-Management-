<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Xác nhận đặt phòng - Luxury Hotel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <div class="container py-5">
        <div class="page-header mb-4">
            <h1 class="page-header-title">Xác nhận đặt phòng</h1>
            <p class="page-header-subtitle">Kiểm tra thông tin và hoàn tất đặt phòng</p>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>${error}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/booking/confirm">
            <c:choose>
                <c:when test="${isMultiRoom}">
                    <!-- Multi-Room Layout -->
                    <div class="row g-4">
                        <!-- Occupant Info for Multi-Room -->
                        <div class="col-lg-7">
                            <div class="card">
                                <div class="card-header">
                                    <i class="bi bi-people me-2"></i>Thông tin khách lưu trú
                                </div>
                                <div class="card-body">
                                    <div id="occupants">
                                        <div class="p-3 mb-3 rounded" style="background: var(--surface-hover);">
                                            <h6 class="mb-3">Khách 1 (Chính)</h6>
                                            <div class="row g-3">
                                                <div class="col-12">
                                                    <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                                                    <input type="text" name="occupantName" class="form-control"
                                                           value="${account.fullName}" required>
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label">Số CMND/CCCD</label>
                                                    <input type="text" name="occupantIdCard" class="form-control"
                                                           placeholder="Nhập số CMND/CCCD">
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label">Số điện thoại</label>
                                                    <input type="text" name="occupantPhone" class="form-control"
                                                           value="${account.phone}" placeholder="Nhập số điện thoại">
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="d-flex align-items-center gap-3 mb-4">
                                        <button type="button" id="btnAddOccupant" class="btn btn-outline-secondary btn-sm" onclick="addOccupant()">
                                            <i class="bi bi-plus-circle me-1"></i> Thêm khách
                                        </button>
                                        <small class="text-muted">
                                            <span id="occupantCounter">1</span> / <span id="maxCapacityDisplay">${totalCapacity}</span> khách (tối đa)
                                        </small>
                                    </div>

                                    <h6 class="mb-3"><i class="bi bi-chat-left-text me-2"></i>Ghi chú</h6>
                                    <textarea name="note" class="form-control mb-4" rows="3"
                                              placeholder="Yêu cầu đặc biệt, giờ nhận phòng dự kiến..."></textarea>

                                    <div class="d-flex gap-3">
                                        <a href="${pageContext.request.contextPath}/booking/select-rooms"
                                           class="btn btn-outline-secondary">
                                            <i class="bi bi-arrow-left me-1"></i> Quay lại
                                        </a>
                                        <button type="submit" class="btn btn-primary flex-grow-1">
                                            <i class="bi bi-credit-card me-2"></i>Tiến hành thanh toán
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Multi-Room Booking Summary -->
                        <div class="col-lg-5">
                            <div class="card" style="background: var(--primary-gradient); color: white;">
                                <div class="card-header" style="background: transparent; border-bottom: 1px solid rgba(255,255,255,0.1);">
                                    <i class="bi bi-receipt me-2"></i>Chi tiet dat phong
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <h5 style="font-family: var(--font-display);">
                                            <i class="bi bi-door-open me-2"></i>${multiBooking.totalRoomCount} Phong
                                        </h5>
                                        <p style="opacity: 0.75;" class="mb-0">
                                            <c:forEach var="rc" items="${multiBooking.roomCalcs}" varStatus="loop">
                                                ${rc.roomType.typeName}${loop.last ? '' : ', '}
                                            </c:forEach>
                                        </p>
                                    </div>

                                    <div class="mb-3 pb-3" style="border-bottom: 1px solid rgba(255,255,255,0.2);">
                                        <div class="row">
                                            <div class="col-6">
                                                <small style="opacity: 0.75;">Nhan phong</small>
                                                <p class="mb-0 fw-semibold">
                                                    ${multiBooking.checkInFormatted}
                                                </p>
                                            </div>
                                            <div class="col-6">
                                                <small style="opacity: 0.75;">Tra phong</small>
                                                <p class="mb-0 fw-semibold">
                                                    ${multiBooking.checkOutFormatted}
                                                </p>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Per-Room Breakdown Table -->
                                    <div class="mb-3">
                                        <h6 class="mb-2" style="opacity: 0.9;">Chi tiet tung phong:</h6>
                                        <c:forEach var="rc" items="${multiBooking.roomCalcs}">
                                            <div class="d-flex justify-content-between py-1 small" style="border-bottom: 1px solid rgba(255,255,255,0.1);">
                                                <span>${rc.roomType.typeName} x ${multiBooking.nights} dem</span>
                                                <span><fmt:formatNumber value="${rc.subtotal}" type="number" groupingUsed="true"/>d</span>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <div class="d-flex justify-content-between py-2">
                                        <span>Tam tinh</span>
                                        <span><fmt:formatNumber value="${multiBooking.subtotal}" type="number" groupingUsed="true"/>d</span>
                                    </div>

                                    <c:if test="${multiBooking.totalEarlySurcharge > 0}">
                                        <div class="d-flex justify-content-between py-2" style="color: #ffcc00;">
                                            <span><i class="bi bi-alarm me-1"></i>Phu thu check-in som</span>
                                            <span><fmt:formatNumber value="${multiBooking.totalEarlySurcharge}" type="number" groupingUsed="true"/>d</span>
                                        </div>
                                    </c:if>
                                    <c:if test="${multiBooking.totalLateSurcharge > 0}">
                                        <div class="d-flex justify-content-between py-2" style="color: #ffcc00;">
                                            <span><i class="bi bi-alarm-fill me-1"></i>Phu thu check-out muon</span>
                                            <span><fmt:formatNumber value="${multiBooking.totalLateSurcharge}" type="number" groupingUsed="true"/>d</span>
                                        </div>
                                    </c:if>

                                    <c:if test="${multiBooking.totalPromotionDiscount > 0}">
                                        <div class="d-flex justify-content-between py-2" style="color: var(--success-light);">
                                            <span>Khuyen mai</span>
                                            <span>-<fmt:formatNumber value="${multiBooking.totalPromotionDiscount}" type="number" groupingUsed="true"/>d</span>
                                        </div>
                                    </c:if>
                                    <c:if test="${multiBooking.voucherDiscount > 0}">
                                        <div class="d-flex justify-content-between py-2" style="color: var(--success-light);">
                                            <span>Voucher (${multiBooking.voucherCode})</span>
                                            <span>-<fmt:formatNumber value="${multiBooking.voucherDiscount}" type="number" groupingUsed="true"/>d</span>
                                        </div>
                                    </c:if>

                                    <div class="d-flex justify-content-between pt-3 mt-2" style="border-top: 1px solid rgba(255,255,255,0.2);">
                                        <span class="h5 mb-0" style="color: #fff;">Tong cong</span>
                                        <span class="h4 mb-0" style="color: #d4af37;">
                                            <fmt:formatNumber value="${multiBooking.total}" type="number" groupingUsed="true"/>d
                                        </span>
                                    </div>

                                    <!-- Payment options for multi-room -->
                                    <c:if test="${multiBooking.allStandardRooms}">
                                        <div class="mt-3 pt-3" style="border-top: 1px solid rgba(255,255,255,0.2);">
                                            <small style="opacity: 0.85;">
                                                <i class="bi bi-info-circle me-1"></i>
                                                Tat ca phong deu la Standard - khong can dat coc.
                                            </small>
                                            <input type="hidden" name="paymentType" value="Full">
                                        </div>
                                    </c:if>
                                    <c:if test="${!multiBooking.allStandardRooms && multiBooking.depositAmount > 0}">
                                        <div class="mt-3 pt-3" style="border-top: 1px solid rgba(255,255,255,0.2);">
                                            <p class="mb-2 fw-semibold">Hinh thuc thanh toan:</p>
                                            <div class="form-check mb-2">
                                                <input class="form-check-input" type="radio" name="paymentType"
                                                       id="payFullMulti" value="Full" checked>
                                                <label class="form-check-label" for="payFullMulti">
                                                    Thanh toan toan bo -
                                                    <fmt:formatNumber value="${multiBooking.total}" type="number" groupingUsed="true"/>d
                                                </label>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="paymentType"
                                                       id="payDepositMulti" value="Deposit">
                                                <label class="form-check-label" for="payDepositMulti">
                                                    Dat coc ${multiBooking.depositAmount > 0 ? '30' : '0'}% -
                                                    <fmt:formatNumber value="${multiBooking.depositAmount}" type="number" groupingUsed="true"/>d
                                                </label>
                                            </div>
                                        </div>
                                    </c:if>
                                    <c:if test="${!multiBooking.allStandardRooms && (multiBooking.depositAmount == null || multiBooking.depositAmount == 0)}">
                                        <input type="hidden" name="paymentType" value="Full">
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Single-Room Layout (existing code) -->
                    <div class="row g-4">
                <!-- Occupant Info -->
                <div class="col-lg-7">
                    <div class="card">
                        <div class="card-header">
                            <i class="bi bi-people me-2"></i>Thông tin khách lưu trú
                        </div>
                        <div class="card-body">
                            <div id="occupants">
                                <div class="p-3 mb-3 rounded" style="background: var(--surface-hover);">
                                    <h6 class="mb-3">Khách 1 (Chính)</h6>
                                    <div class="row g-3">
                                        <div class="col-12">
                                            <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                                            <input type="text" name="occupantName" class="form-control"
                                                   value="${account.fullName}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Số CMND/CCCD</label>
                                            <input type="text" name="occupantIdCard" class="form-control"
                                                   placeholder="Nhập số CMND/CCCD">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Số điện thoại</label>
                                            <input type="text" name="occupantPhone" class="form-control"
                                                   value="${account.phone}" placeholder="Nhập số điện thoại">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex align-items-center gap-3 mb-4">
                                <button type="button" id="btnAddOccupant" class="btn btn-outline-secondary btn-sm" onclick="addOccupant()">
                                    <i class="bi bi-plus-circle me-1"></i> Thêm khách
                                </button>
                                <small class="text-muted">
                                    <span id="occupantCounter">1</span> / <span id="maxCapacityDisplay">${booking.roomType.capacity}</span> khách (tối đa)
                                </small>
                            </div>

                            <h6 class="mb-3"><i class="bi bi-chat-left-text me-2"></i>Ghi chú</h6>
                            <textarea name="note" class="form-control mb-4" rows="3"
                                      placeholder="Yêu cầu đặc biệt, giờ nhận phòng dự kiến..."></textarea>

                            <div class="d-flex gap-3">
                                <a href="${pageContext.request.contextPath}/booking/create?typeId=${booking.roomType.typeId}"
                                   class="btn btn-outline-secondary">
                                    <i class="bi bi-arrow-left me-1"></i> Quay lại
                                </a>
                                <button type="submit" class="btn btn-primary flex-grow-1">
                                    <i class="bi bi-credit-card me-2"></i>Tiến hành thanh toán
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Booking Summary -->
                <div class="col-lg-5">
                    <div class="card" style="background: var(--primary-gradient); color: white;">
                        <div class="card-header" style="background: transparent; border-bottom: 1px solid rgba(255,255,255,0.1);">
                            <i class="bi bi-receipt me-2"></i>Chi tiết đặt phòng
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <h5 style="font-family: var(--font-display);">${booking.roomType.typeName}</h5>
                                <p style="opacity: 0.75;" class="mb-0">Phòng ${booking.room.roomNumber}</p>
                            </div>

                            <div class="mb-3 pb-3" style="border-bottom: 1px solid rgba(255,255,255,0.2);">
                                <div class="row">
                                    <div class="col-6">
                                        <small style="opacity: 0.75;">Nhận phòng</small>
                                        <p class="mb-0 fw-semibold">
                                            ${booking.checkInFormatted}
                                            <br><small>14:00</small>
                                        </p>
                                    </div>
                                    <div class="col-6">
                                        <small style="opacity: 0.75;">Trả phòng</small>
                                        <p class="mb-0 fw-semibold">
                                            ${booking.checkOutFormatted}
                                            <br><small>12:00</small>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between py-2">
                                <span>Số đêm</span>
                                <span>${booking.nights} đêm</span>
                            </div>
                            <div class="d-flex justify-content-between py-2">
                                <span>Giá phòng</span>
                                <span><fmt:formatNumber value="${booking.roomType.basePrice}" type="number" groupingUsed="true"/>đ/đêm</span>
                            </div>
                            <div class="d-flex justify-content-between py-2">
                                <span>Tạm tính</span>
                                <span><fmt:formatNumber value="${booking.subtotal}" type="number" groupingUsed="true"/>đ</span>
                            </div>
                            <c:if test="${booking.promotionDiscount != null && booking.promotionDiscount > 0}">
                                <div class="d-flex justify-content-between py-2" style="color: var(--success-light);">
                                    <span>KM ${booking.promotion.promoCode} (-${booking.promotion.discountPercent}%)</span>
                                    <span>-<fmt:formatNumber value="${booking.promotionDiscount}" type="number" groupingUsed="true"/>đ</span>
                                </div>
                            </c:if>
                            <c:if test="${booking.discount != null && booking.discount > 0}">
                                <div class="d-flex justify-content-between py-2" style="color: var(--success-light);">
                                    <span>Giảm giá (${booking.voucher.code})</span>
                                    <span>-<fmt:formatNumber value="${booking.discount}" type="number" groupingUsed="true"/>đ</span>
                                </div>
                            </c:if>
                            <div class="d-flex justify-content-between pt-3 mt-2" style="border-top: 1px solid rgba(255,255,255,0.2);">
                                <span class="h5 mb-0" style="color: #fff;">Tổng cộng</span>
                                <span class="h4 mb-0" style="color: #d4af37;">
                                    <fmt:formatNumber value="${booking.total}" type="number" groupingUsed="true"/>đ
                                </span>
                            </div>

                            <!-- Deposit / Full payment option -->
                            <c:if test="${!booking.standardRoom && booking.depositPercent > 0}">
                                <div class="mt-3 pt-3" style="border-top: 1px solid rgba(255,255,255,0.2);">
                                    <p class="mb-2 fw-semibold">Hình thức thanh toán:</p>
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="radio" name="paymentType"
                                               id="payFull" value="Full" checked>
                                        <label class="form-check-label" for="payFull">
                                            Thanh toán toàn bộ -
                                            <fmt:formatNumber value="${booking.total}" type="number" groupingUsed="true"/>đ
                                        </label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="paymentType"
                                               id="payDeposit" value="Deposit">
                                        <label class="form-check-label" for="payDeposit">
                                            Đặt cọc <fmt:formatNumber value="${booking.depositPercent}" type="number"/>% -
                                            <fmt:formatNumber value="${booking.depositAmount}" type="number" groupingUsed="true"/>đ
                                        </label>
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${booking.standardRoom}">
                                <div class="mt-3 pt-3" style="border-top: 1px solid rgba(255,255,255,0.2);">
                                    <small style="opacity: 0.85;">
                                        <i class="bi bi-info-circle me-1"></i>
                                        Phòng Standard không cần đặt cọc. Lưu ý: nếu sau 6 tiếng kể từ giờ nhận phòng
                                        mà chưa được xác nhận, đơn đặt phòng sẽ tự động bị hủy.
                                    </small>
                                    <input type="hidden" name="paymentType" value="Full">
                                </div>
                            </c:if>
                            <c:if test="${!booking.standardRoom && (booking.depositPercent == null || booking.depositPercent == 0)}">
                                <input type="hidden" name="paymentType" value="Full">
                            </c:if>

                            <!-- Price per hour info -->
                            <c:if test="${booking.pricePerHour != null && booking.pricePerHour > 0}">
                                <div class="mt-2">
                                    <small style="opacity: 0.75;">
                                        Giá theo giờ (gia hạn): <fmt:formatNumber value="${booking.pricePerHour}" type="number" groupingUsed="true"/>đ/h
                                    </small>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
                </c:otherwise>
            </c:choose>
        </form>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Dynamic max capacity based on single room or multi-room
        let maxCapacity = ${isMultiRoom ? totalCapacity : booking.roomType.capacity};
        let occupantCount = 1;

        function updateOccupantUI() {
            const currentCount = document.querySelectorAll('#occupants > div').length;
            document.getElementById('occupantCounter').textContent = currentCount;
            const btn = document.getElementById('btnAddOccupant');
            if (currentCount >= maxCapacity) {
                btn.disabled = true;
                btn.title = 'Đã đạt số lượng khách tối đa';
            } else {
                btn.disabled = false;
                btn.title = '';
            }
        }

        function removeOccupant(el) {
            el.closest('.p-3').remove();
            updateOccupantUI();
        }

        function addOccupant() {
            const currentCount = document.querySelectorAll('#occupants > div').length;
            if (currentCount >= maxCapacity) {
                alert('Số lượng khách đã đạt tối đa (' + maxCapacity + ' người) cho loại phòng này.');
                return;
            }
            occupantCount++;
            const html = `
                <div class="p-3 mb-3 rounded" style="background: var(--surface-hover);">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="mb-0">Khách ${occupantCount}</h6>
                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeOccupant(this)">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" name="occupantName" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số CMND/CCCD</label>
                            <input type="text" name="occupantIdCard" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" name="occupantPhone" class="form-control">
                        </div>
                    </div>
                </div>
            `;
            document.getElementById('occupants').insertAdjacentHTML('beforeend', html);
            updateOccupantUI();
        }

        // Init on page load
        updateOccupantUI();
    </script>
</body>
</html>
