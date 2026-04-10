<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chon phong - Dat phong tai quay</title>
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
        .room-card { transition: all 0.2s; cursor: pointer; }
        .room-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .room-card.selected { border-color: #198754 !important; background: #f0fdf4; }
        .room-card .room-number { font-size: 1.5rem; font-weight: 700; }
    </style>
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="walkin" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Chon phong - Dat phong tai quay" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Stepper -->
                <div class="d-flex justify-content-center mb-4">
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-success rounded-pill px-3 py-2"><i class="bi bi-check"></i> Thong tin khach</span>
                        <i class="bi bi-chevron-right text-muted"></i>
                        <span class="badge bg-primary rounded-pill px-3 py-2">2. Chon phong</span>
                        <i class="bi bi-chevron-right text-muted"></i>
                        <span class="badge bg-secondary rounded-pill px-3 py-2">3. Xac nhan</span>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="card mb-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="bi bi-door-open me-2"></i>Chon loai phong va ngay</h5>
                            </div>
                            <div class="card-body">
                                <%-- Form: search available rooms --%>
                                <form action="${pageContext.request.contextPath}/staff/bookings/walkin-room" method="post" id="searchForm">
                                    <div class="mb-3">
                                        <label for="typeId" class="form-label">Loai phong <span class="text-danger">*</span></label>
                                        <select class="form-select" id="typeId" name="typeId" required onchange="onTypeChange()">
                                            <option value="">-- Chon loai phong --</option>
                                            <c:forEach var="rt" items="${roomTypes}">
                                                <option value="${rt.typeId}"
                                                        data-price="${rt.basePrice}"
                                                        data-capacity="${rt.capacity}"
                                                        ${rt.typeId == selectedTypeId ? 'selected' : ''}>
                                                    ${rt.typeName} - <fmt:formatNumber value="${rt.basePrice}" type="number" groupingUsed="true"/> VND/dem - Suc chua: ${rt.capacity} nguoi
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <!-- Availability Calendar -->
                                    <div id="calendarSection" class="mb-3 d-none">
                                        <label class="form-label">Lich trong phong</label>
                                        <div id="availabilityCalendar"></div>
                                        <div class="calendar-legend">
                                            <span><span class="legend-dot" style="background:#fff;border:1px solid #ddd;"></span>Trong</span>
                                            <span><span class="legend-dot" style="background:rgba(220,53,69,0.18);"></span>Da dat</span>
                                        </div>
                                    </div>

                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label for="checkIn" class="form-label">Ngay nhan phong <span class="text-danger">*</span></label>
                                            <input type="datetime-local" class="form-control" id="checkIn" name="checkIn"
                                                   value="${selectedCheckIn}" required onchange="updatePrice()">
                                        </div>
                                        <div class="col-md-6">
                                            <label for="checkOut" class="form-label">Ngay tra phong <span class="text-danger">*</span></label>
                                            <input type="datetime-local" class="form-control" id="checkOut" name="checkOut"
                                                   value="${selectedCheckOut}" required onchange="updatePrice()">
                                        </div>
                                    </div>

                                    <!-- Price estimate -->
                                    <div id="priceEstimate" class="alert alert-info d-none">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <strong>Gia du kien:</strong>
                                                <span id="nightCount">0</span> dem x
                                                <span id="pricePerNight">0</span> VND
                                            </div>
                                            <div>
                                                <strong class="fs-5 text-primary" id="totalEstimate">0 VND</strong>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Only show search button if rooms not yet shown --%>
                                    <c:if test="${empty availableRooms}">
                                        <div class="d-flex justify-content-between">
                                            <a href="${pageContext.request.contextPath}/staff/bookings/walkin"
                                               class="btn btn-outline-secondary">
                                                <i class="bi bi-arrow-left me-1"></i>Quay lai
                                            </a>
                                            <button type="submit" class="btn btn-staff-primary">
                                                <i class="bi bi-search me-1"></i>Tim phong trong
                                            </button>
                                        </div>
                                    </c:if>

                                    <c:if test="${not empty availableRooms}">
                                        <div class="text-end">
                                            <button type="submit" class="btn btn-outline-primary btn-sm">
                                                <i class="bi bi-arrow-clockwise me-1"></i>Tim lai
                                            </button>
                                        </div>
                                    </c:if>
                                </form>
                            </div>
                        </div>

                        <%-- Room selection section: shown after searching --%>
                        <c:if test="${not empty availableRooms}">
                            <div class="card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0">
                                        <i class="bi bi-grid me-2"></i>Chon phong
                                        <span class="badge bg-success ms-2">${availableRooms.size()} phong trong</span>
                                    </h5>
                                    <small class="text-muted">
                                        ${selectedType.typeName} -
                                        Suc chua: ${selectedType.capacity} nguoi
                                    </small>
                                </div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/staff/bookings/walkin-room" method="post" id="roomSelectForm">
                                        <input type="hidden" name="roomId" id="selectedRoomId" value="">

                                        <div class="row g-3 mb-4">
                                            <c:forEach var="room" items="${availableRooms}">
                                                <div class="col-md-3 col-sm-4 col-6">
                                                    <div class="room-card border rounded p-3 text-center"
                                                         data-room-id="${room.roomId}"
                                                         onclick="selectRoom(this, ${room.roomId})">
                                                        <div class="room-number text-success">${room.roomNumber}</div>
                                                        <small class="text-muted">${room.roomType.typeName}</small>
                                                        <div class="mt-1">
                                                            <span class="badge bg-success bg-opacity-10 text-success">
                                                                <i class="bi bi-check-circle"></i> Trong
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <div class="d-flex justify-content-between">
                                            <a href="${pageContext.request.contextPath}/staff/bookings/walkin"
                                               class="btn btn-outline-secondary">
                                                <i class="bi bi-arrow-left me-1"></i>Quay lai
                                            </a>
                                            <button type="submit" class="btn btn-staff-primary" id="btnContinue" disabled>
                                                Tiep tuc <i class="bi bi-arrow-right ms-1"></i>
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </c:if>

                    </div>
                </div>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
    <script>
        var ctx = '${pageContext.request.contextPath}';
        var calendar = null;
        var occupiedDates = new Set();

        // Set default check-in/out if not already set by server
        (function() {
            var checkInEl = document.getElementById('checkIn');
            var checkOutEl = document.getElementById('checkOut');

            if (!checkInEl.value) {
                var now = new Date();
                now.setMinutes(0, 0, 0);
                var tomorrow = new Date(now);
                tomorrow.setDate(tomorrow.getDate() + 1);
                checkInEl.value = toLocal(now);
                checkOutEl.value = toLocal(tomorrow);
            }
            updatePrice();

            // Auto-load calendar if type is selected (e.g. after search)
            var typeId = document.getElementById('typeId').value;
            if (typeId) {
                loadCalendar();
            }
        })();

        function toLocal(d) {
            var y = d.getFullYear();
            var m = String(d.getMonth() + 1).padStart(2, '0');
            var day = String(d.getDate()).padStart(2, '0');
            var h = String(d.getHours()).padStart(2, '0');
            var min = String(d.getMinutes()).padStart(2, '0');
            return y + '-' + m + '-' + day + 'T' + h + ':' + min;
        }

        function onTypeChange() {
            updatePrice();
            loadCalendar();
        }

        async function loadCalendar() {
            var typeId = document.getElementById('typeId').value;
            var section = document.getElementById('calendarSection');

            if (!typeId) {
                section.classList.add('d-none');
                return;
            }

            var occupiedRanges = [];
            try {
                var res = await fetch(ctx + '/booking/availability?typeId=' + typeId);
                occupiedRanges = await res.json();
            } catch (e) {
                console.error('Failed to load availability', e);
            }

            occupiedDates = new Set();
            occupiedRanges.forEach(function(r) {
                var d = new Date(r.start + 'T00:00:00');
                var end = new Date(r.end + 'T00:00:00');
                while (d < end) {
                    occupiedDates.add(d.toISOString().split('T')[0]);
                    d.setDate(d.getDate() + 1);
                }
            });

            section.classList.remove('d-none');
            var calendarEl = document.getElementById('availabilityCalendar');

            if (calendar) {
                calendar.destroy();
            }

            calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                locale: 'vi',
                height: 'auto',
                headerToolbar: { left: 'prev', center: 'title', right: 'next' },
                dayCellClassNames: function(arg) {
                    var dateStr = arg.date.toISOString().split('T')[0];
                    return occupiedDates.has(dateStr) ? ['fc-day-occupied'] : [];
                },
                dateClick: function(info) {
                    var dateStr = info.dateStr;
                    if (occupiedDates.has(dateStr)) return;

                    var checkIn = document.getElementById('checkIn');
                    var checkOut = document.getElementById('checkOut');
                    var now = new Date();
                    var currentTime = String(now.getHours()).padStart(2,'0') + ':' + String(now.getMinutes()).padStart(2,'0');

                    if (!checkIn.value || checkIn.value.split('T')[0] >= dateStr) {
                        checkIn.value = dateStr + 'T' + currentTime;
                        checkOut.value = '';
                    } else if (!checkOut.value || checkOut.value.split('T')[0] <= checkIn.value.split('T')[0]) {
                        if (dateStr > checkIn.value.split('T')[0]) {
                            checkOut.value = dateStr + 'T12:00';
                        }
                    }
                    updatePrice();
                }
            });
            calendar.render();
        }

        function updatePrice() {
            var select = document.getElementById('typeId');
            var checkIn = document.getElementById('checkIn').value;
            var checkOut = document.getElementById('checkOut').value;
            var estimateDiv = document.getElementById('priceEstimate');

            if (!select.value || !checkIn || !checkOut) {
                estimateDiv.classList.add('d-none');
                return;
            }

            var option = select.options[select.selectedIndex];
            var price = parseFloat(option.getAttribute('data-price'));
            var d1 = new Date(checkIn);
            var d2 = new Date(checkOut);
            var diffMs = d2 - d1;
            var nights = Math.ceil(diffMs / (1000 * 60 * 60 * 24));

            if (nights <= 0) {
                estimateDiv.classList.add('d-none');
                return;
            }

            var total = price * nights;
            document.getElementById('nightCount').textContent = nights;
            document.getElementById('pricePerNight').textContent = price.toLocaleString('vi-VN');
            document.getElementById('totalEstimate').textContent = total.toLocaleString('vi-VN') + ' VND';
            estimateDiv.classList.remove('d-none');
        }

        // Room selection
        function selectRoom(el, roomId) {
            // Remove selected from all
            document.querySelectorAll('.room-card').forEach(function(c) {
                c.classList.remove('selected');
            });
            // Select this
            el.classList.add('selected');
            document.getElementById('selectedRoomId').value = roomId;
            document.getElementById('btnContinue').disabled = false;
        }
    </script>
</body>
</html>
