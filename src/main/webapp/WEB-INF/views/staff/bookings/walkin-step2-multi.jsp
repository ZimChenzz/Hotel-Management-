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
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
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

                <form method="post" action="${pageContext.request.contextPath}/staff/bookings/walkin-multi">
                    <div class="row">
                        <div class="col-lg-8">
                            <!-- Room Selection -->
                            <div class="card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0"><i class="bi bi-door-open me-2"></i>Chon loai phong va so luong</h5>
                                </div>
                                <div class="card-body">
                                    <div id="roomSelections">
                                        <div class="row mb-3 room-selection-row">
                                            <div class="col-md-5">
                                                <label class="form-label">Loai phong</label>
                                                <select class="form-select room-type-select" name="typeId" required onchange="updatePrice()">
                                                    <option value="">-- Chon loai phong --</option>
                                                    <c:forEach var="rt" items="${roomTypes}">
                                                        <c:set var="avail" value="${availability[rt.typeId]}" />
                                                        <option value="${rt.typeId}" data-price="${rt.basePrice}" data-capacity="${rt.capacity}" data-typename="${rt.typeName}" data-available="${avail}">
                                                            ${rt.typeName} - <fmt:formatNumber value="${rt.basePrice}" type="number"/> VND (Còn ${avail} phong)
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">So luong</label>
                                                <input type="number" class="form-control room-qty" name="qty" value="1" min="1" max="10" onchange="updatePrice()">
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Don gia/dem</label>
                                                <input type="text" class="form-control room-price-display" readonly value="-">
                                            </div>
                                            <div class="col-md-1 d-flex align-items-end">
                                                <button type="button" class="btn btn-outline-danger btn-sm remove-room" onclick="removeRoom(this)" style="display:none;">
                                                    <i class="bi bi-x"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>

                                    <button type="button" class="btn btn-outline-primary btn-sm" onclick="addRoom()">
                                        <i class="bi bi-plus me-1"></i>Them phong
                                    </button>
                                </div>
                            </div>

                            <!-- Date Selection -->
                            <div class="card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0"><i class="bi bi-calendar me-2"></i>Ngay nhan/tra phong</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <label class="form-label">Ngay nhan phong <span class="text-danger">*</span></label>
                                            <input type="datetime-local" class="form-control" id="checkIn" name="checkIn" value="${selectedCheckIn}" required onchange="updatePrice()">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Ngay tra phong <span class="text-danger">*</span></label>
                                            <input type="datetime-local" class="form-control" id="checkOut" name="checkOut" value="${selectedCheckOut}" required onchange="updatePrice()">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <!-- Summary -->
                            <div class="card">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0"><i class="bi bi-receipt me-2"></i>Tong hop</h5>
                                </div>
                                <div class="card-body">
                                    <div class="mb-2">
                                        <span class="text-muted">Khach hang:</span>
                                        <strong class="float-end">${walkin_fullName}</strong>
                                    </div>
                                    <div class="mb-2">
                                        <span class="text-muted">SDT:</span>
                                        <strong class="float-end">${walkin_phone}</strong>
                                    </div>
                                    <hr>
                                    <div class="mb-2">
                                        <span class="text-muted">So phong:</span>
                                        <strong class="float-end" id="totalRooms">0</strong>
                                    </div>
                                    <div class="mb-2">
                                        <span class="text-muted">So dem:</span>
                                        <strong class="float-end" id="totalNights">0</strong>
                                    </div>
                                    <div class="mb-2">
                                        <span class="text-muted">Tong tien:</span>
                                        <strong class="float-end text-success fs-5" id="totalPrice">0 VND</strong>
                                    </div>
                                    <hr>
                                    <div class="d-grid gap-2">
                                        <a href="${pageContext.request.contextPath}/staff/bookings/walkin" class="btn btn-outline-secondary">
                                            <i class="bi bi-arrow-left me-1"></i>Quay lai
                                        </a>
                                        <button type="submit" class="btn btn-staff-primary" id="btnContinue" disabled>
                                            <i class="bi bi-arrow-right me-1"></i>Tiep tuc
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <script>
        // Set default dates
        (function() {
            var checkIn = document.getElementById('checkIn');
            var checkOut = document.getElementById('checkOut');
            if (!checkIn.value) {
                var now = new Date();
                now.setMinutes(0, 0, 0);
                var tomorrow = new Date(now);
                tomorrow.setDate(tomorrow.getDate() + 1);
                checkIn.value = toLocal(now);
                checkOut.value = toLocal(tomorrow);
            }
            updatePrice();
        })();

        function toLocal(d) {
            var y = d.getFullYear();
            var m = String(d.getMonth() + 1).padStart(2, '0');
            var day = String(d.getDate()).padStart(2, '0');
            var h = String(d.getHours()).padStart(2, '0');
            var min = String(d.getMinutes()).padStart(2, '0');
            return y + '-' + m + '-' + day + 'T' + h + ':' + min;
        }

        function addRoom() {
            var container = document.getElementById('roomSelections');
            var rows = container.querySelectorAll('.room-selection-row');
            var newRow = rows[0].cloneNode(true);

            // Clear values
            newRow.querySelector('.room-type-select').value = '';
            newRow.querySelector('.room-qty').value = '1';
            newRow.querySelector('.room-price-display').value = '-';

            // Show remove button
            newRow.querySelector('.remove-room').style.display = 'block';

            container.appendChild(newRow);
            updateRemoveButtons();
            updatePrice();
        }

        function removeRoom(btn) {
            var row = btn.closest('.room-selection-row');
            row.remove();
            updateRemoveButtons();
            updatePrice();
        }

        function updateRemoveButtons() {
            var rows = document.querySelectorAll('.room-selection-row');
            rows.forEach(function(row, index) {
                var removeBtn = row.querySelector('.remove-room');
                if (rows.length > 1) {
                    removeBtn.style.display = 'block';
                } else {
                    removeBtn.style.display = 'none';
                }
            });
        }

        function updatePrice() {
            var rows = document.querySelectorAll('.room-selection-row');
            var checkIn = document.getElementById('checkIn').value;
            var checkOut = document.getElementById('checkOut').value;

            var totalRooms = 0;
            var totalPrice = 0;
            var nights = 0;

            if (checkIn && checkOut) {
                var d1 = new Date(checkIn);
                var d2 = new Date(checkOut);
                var diffMs = d2 - d1;
                nights = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
            }

            rows.forEach(function(row) {
                var select = row.querySelector('.room-type-select');
                var qty = parseInt(row.querySelector('.room-qty').value) || 0;
                var option = select.options[select.selectedIndex];

                if (option && option.value) {
                    var price = parseFloat(option.getAttribute('data-price')) || 0;
                    totalRooms += qty;
                    totalPrice += price * qty * Math.max(1, nights);
                    row.querySelector('.room-price-display').value = price.toLocaleString('vi-VN') + ' VND';
                }
            });

            document.getElementById('totalRooms').textContent = totalRooms;
            document.getElementById('totalNights').textContent = nights > 0 ? nights : 0;
            document.getElementById('totalPrice').textContent = totalPrice.toLocaleString('vi-VN') + ' VND';
            document.getElementById('btnContinue').disabled = totalRooms === 0 || nights <= 0;
        }

        // Listen for changes
        document.getElementById('roomSelections').addEventListener('change', updatePrice);
        updateRemoveButtons();
    </script>
</body>
</html>
