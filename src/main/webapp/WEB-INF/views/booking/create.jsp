<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt phòng - ${roomType.typeName}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
    <style>
        #availabilityCalendar { background: var(--surface); border-radius: var(--radius); padding: 8px; }
        .fc-day-occupied { background-color: rgba(220, 53, 69, 0.18) !important; cursor: not-allowed; }
        .fc-day-occupied .fc-daygrid-day-number { color: #dc3545; }
        .calendar-legend { display: flex; gap: 16px; font-size: 0.82rem; margin-top: 8px; }
        .legend-dot { width: 14px; height: 14px; border-radius: 3px; display: inline-block; margin-right: 4px; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp"/>

    <!-- Page Header -->
    <section class="public-hero public-hero-small">
        <div class="container text-center">
            <h1 class="public-hero-title">Đặt phòng</h1>
            <p class="public-hero-subtitle">${roomType.typeName}</p>
        </div>
    </section>

    <div class="container py-5">
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/rooms">Phòng</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/rooms/detail?typeId=${roomType.typeId}">${roomType.typeName}</a></li>
                <li class="breadcrumb-item active">Đặt phòng</li>
            </ol>
        </nav>

        <div class="page-header mb-4">
            <h1 class="page-header-title">Đặt phòng</h1>
            <p class="page-header-subtitle">Hoàn tất thông tin đặt phòng của bạn</p>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>${error}</div>
        </c:if>

        <div class="row g-4">
            <!-- Booking Form -->
            <div class="col-lg-7">
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-calendar-check me-2"></i>Chọn ngày
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/booking/create">
                            <input type="hidden" name="typeId" value="${roomType.typeId}">

                            <div class="row g-3 mb-4">
                                <div class="col-md-4">
                                    <label class="form-label">Ngày nhận phòng <span class="text-danger">*</span></label>
                                    <input type="date" name="checkIn" class="form-control"
                                           value="${selectedCheckIn}" min="${minDate}" max="${maxDate}" required>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Giờ check-in</label>
                                    <input type="time" name="checkInTime" class="form-control" value="14:00" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Ngày trả phòng <span class="text-danger">*</span></label>
                                    <input type="date" name="checkOut" class="form-control"
                                           value="${selectedCheckOut}" min="${minDate}" max="${maxDate}" required>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Giờ check-out</label>
                                    <input type="time" name="checkOutTime" class="form-control" value="12:00" required>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label">Mã giảm giá (nếu có)</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-tag"></i></span>
                                    <input type="text" name="voucherCode" class="form-control"
                                           value="${voucherCode}" placeholder="Nhập mã voucher">
                                </div>
                            </div>

                            <div class="d-flex gap-3">
                                <a href="${pageContext.request.contextPath}/rooms/detail?typeId=${roomType.typeId}"
                                   class="btn btn-outline-secondary">
                                    <i class="bi bi-arrow-left me-1"></i>Quay lại
                                </a>
                                <button type="submit" class="btn btn-primary flex-grow-1">
                                    Tiếp tục <i class="bi bi-arrow-right ms-1"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Room Summary -->
            <div class="col-lg-5">
                <!-- Availability Calendar -->
                <div class="card mb-3">
                    <div class="card-header">
                        <i class="bi bi-calendar3 me-2"></i>Lịch phòng còn trống
                    </div>
                    <div class="card-body p-2">
                        <div id="availabilityCalendar"></div>
                        <div class="calendar-legend">
                            <span><span class="legend-dot" style="background:rgba(220,53,69,0.25);border:1px solid #dc3545;"></span>Đã có người đặt</span>
                            <span><span class="legend-dot" style="background:#198754;opacity:0.7;"></span>Còn trống</span>
                        </div>
                    </div>
                </div>
                <!-- Room Type Info -->
                <div class="card" style="background: var(--primary-gradient); color: white;">
                    <div class="card-body">
                        <c:if test="${not empty roomType.images}">
                            <img src="${roomType.images[0].imageUrl}" alt="${roomType.typeName}"
                                 class="w-100 mb-3 rounded" style="height: 200px; object-fit: cover;">
                        </c:if>
                        <h3 class="mb-2" style="font-family: var(--font-display);">${roomType.typeName}</h3>
                        <p class="mb-3" style="opacity: 0.85;">${roomType.description}</p>

                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-people me-2"></i>
                            <span>Tối đa ${roomType.capacity} khách</span>
                        </div>

                        <c:if test="${not empty roomType.amenities}">
                            <div class="mb-3">
                                <c:forEach var="amenity" items="${roomType.amenities}" end="3">
                                    <span class="badge bg-light text-dark me-1 mb-1">
                                        <i class="bi bi-check-circle text-success me-1"></i>${amenity.name}
                                    </span>
                                </c:forEach>
                            </div>
                        </c:if>

                        <hr style="opacity: 0.25;">
                        <div class="d-flex justify-content-between align-items-center">
                            <span style="opacity: 0.85;">Giá phòng/đêm</span>
                            <span class="h4 mb-0" style="color: var(--secondary);">
                                <fmt:formatNumber value="${roomType.basePrice}" type="number" groupingUsed="true"/>đ
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp"/>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
    <script>
        const typeId = '${roomType.typeId}';
        const ctx = '${pageContext.request.contextPath}';

        // Fetch occupied date ranges and render calendar
        async function initCalendar() {
            let occupiedRanges = [];
            try {
                const res = await fetch(ctx + '/booking/availability?typeId=' + typeId);
                occupiedRanges = await res.json();
            } catch (e) { console.error('Failed to load availability', e); }

            // Build set of occupied dates (day by day) for background highlighting
            const occupiedDates = new Set();
            occupiedRanges.forEach(r => {
                let d = new Date(r.start + 'T00:00:00');
                const end = new Date(r.end + 'T00:00:00');
                // Mark all nights: from checkIn date up to (but not including) checkOut date
                while (d < end) {
                    occupiedDates.add(d.toISOString().split('T')[0]);
                    d.setDate(d.getDate() + 1);
                }
            });

            const calendarEl = document.getElementById('availabilityCalendar');
            const calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                locale: 'vi',
                height: 'auto',
                headerToolbar: { left: 'prev', center: 'title', right: 'next' },
                dayCellClassNames: function(arg) {
                    const dateStr = arg.date.toISOString().split('T')[0];
                    return occupiedDates.has(dateStr) ? ['fc-day-occupied'] : [];
                },
                // Prevent click navigation (calendar is display-only)
                dateClick: function(info) {
                    const dateStr = info.dateStr;
                    if (occupiedDates.has(dateStr)) return; // skip occupied
                    // Pre-fill checkIn if not already set
                    const checkIn = document.querySelector('input[name="checkIn"]');
                    const checkOut = document.querySelector('input[name="checkOut"]');
                    if (!checkIn.value) {
                        checkIn.value = dateStr;
                        checkIn.dispatchEvent(new Event('change'));
                    } else if (!checkOut.value || checkOut.value <= checkIn.value) {
                        if (dateStr > checkIn.value) checkOut.value = dateStr;
                    }
                }
            });
            calendar.render();
        }

        initCalendar();

        document.querySelector('input[name="checkIn"]').addEventListener('change', function() {
            const checkIn = new Date(this.value);
            checkIn.setDate(checkIn.getDate() + 1);
            const checkOut = document.querySelector('input[name="checkOut"]');
            checkOut.min = this.value;
            if (!checkOut.value || new Date(checkOut.value) <= new Date(this.value)) {
                checkOut.value = checkIn.toISOString().split('T')[0];
            }
        });
    </script>
</body>
</html>
