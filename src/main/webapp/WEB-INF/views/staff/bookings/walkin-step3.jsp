<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Xac nhan dat phong - Cong Nhan Vien</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="walkin" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="Xac nhan dat phong tai quay" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Stepper -->
                <div class="d-flex justify-content-center mb-4">
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-success rounded-pill px-3 py-2"><i class="bi bi-check"></i> Thong tin khach</span>
                        <i class="bi bi-chevron-right text-muted"></i>
                        <span class="badge bg-success rounded-pill px-3 py-2"><i class="bi bi-check"></i> Chon phong</span>
                        <i class="bi bi-chevron-right text-muted"></i>
                        <span class="badge bg-primary rounded-pill px-3 py-2">3. Xac nhan</span>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/staff/bookings/walkin-confirm" method="post">
                    <div class="row">
                        <!-- Summary -->
                        <div class="col-lg-5">
                            <div class="card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0"><i class="bi bi-clipboard-check me-2"></i>Tom tat dat phong</h5>
                                </div>
                                <div class="card-body">
                                    <h6 class="text-muted mb-2">Thong tin khach</h6>
                                    <p class="mb-1"><strong>Ho ten:</strong> ${walkin_fullName}</p>
                                    <p class="mb-1"><strong>SDT:</strong> ${walkin_phone}</p>
                                    <c:if test="${not empty walkin_email}">
                                        <p class="mb-1"><strong>Email:</strong> ${walkin_email}</p>
                                    </c:if>
                                    <c:if test="${not empty walkin_idCard}">
                                        <p class="mb-1"><strong>CCCD:</strong> ${walkin_idCard}</p>
                                    </c:if>

                                    <hr>

                                    <h6 class="text-muted mb-2">Thong tin phong</h6>
                                    <c:choose>
                                        <c:when test="${isMultiRoom}">
                                            <p class="mb-1"><strong>So loai phong:</strong> ${multiCalc.roomCalcs.size()}</p>
                                            <p class="mb-1"><strong>Tong so phong:</strong> ${multiCalc.totalRoomCount} phong</p>
                                            <c:forEach var="roomCalc" items="${multiCalc.roomCalcs}" varStatus="loop">
                                                <div class="border rounded p-2 mb-2 bg-light">
                                                    <strong>Loai ${loop.index + 1}:</strong> ${roomCalc.roomType.typeName} (${roomCalc.roomType.capacity} nguoi)
                                                    <br><span class="text-muted small">Gia/dem: <fmt:formatNumber value="${roomCalc.roomType.basePrice}" type="number"/> VND x ${roomCalc.nights} dem = <fmt:formatNumber value="${roomCalc.subtotal}" type="number"/> VND</span>
                                                </div>
                                            </c:forEach>
                                            <p class="mb-1">
                                                <strong>Nhan phong:</strong> ${multiCalc.checkInFormatted}
                                            </p>
                                            <p class="mb-1">
                                                <strong>Tra phong:</strong> ${multiCalc.checkOutFormatted}
                                            </p>
                                            <p class="mb-1"><strong>So dem:</strong> ${multiCalc.nights}</p>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="mb-1"><strong>Loai phong:</strong> ${calc.roomType.typeName}</p>
                                            <p class="mb-1"><strong>Phong:</strong> ${calc.room.roomNumber}</p>
                                            <p class="mb-1"><strong>Suc chua:</strong> ${calc.roomType.capacity} nguoi</p>
                                            <p class="mb-1">
                                                <strong>Nhan phong:</strong> ${calc.checkInFormatted}
                                            </p>
                                            <p class="mb-1">
                                                <strong>Tra phong:</strong> ${calc.checkOutFormatted}
                                            </p>
                                            <p class="mb-1"><strong>So dem:</strong> ${calc.nights}</p>
                                        </c:otherwise>
                                    </c:choose>

                                    <hr>

                                    <h6 class="text-muted mb-2">Chi tiet gia</h6>
                                    <c:choose>
                                        <c:when test="${isMultiRoom}">
                                            <div class="d-flex justify-content-between mb-1">
                                                <span>Gia phong (${multiCalc.nights} dem)</span>
                                                <span><fmt:formatNumber value="${multiCalc.subtotal}" type="number" groupingUsed="true"/> VND</span>
                                            </div>
                                            <c:if test="${multiCalc.totalPromotionDiscount > 0}">
                                                <div class="d-flex justify-content-between mb-1 text-success">
                                                    <span>Khuyen mai</span>
                                                    <span>-<fmt:formatNumber value="${multiCalc.totalPromotionDiscount}" type="number" groupingUsed="true"/> VND</span>
                                                </div>
                                            </c:if>
                                            <c:if test="${multiCalc.voucherDiscount > 0}">
                                                <div class="d-flex justify-content-between mb-1 text-success">
                                                    <span>Voucher (${multiCalc.voucher.code})</span>
                                                    <span>-<fmt:formatNumber value="${multiCalc.voucherDiscount}" type="number" groupingUsed="true"/> VND</span>
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="d-flex justify-content-between mb-1">
                                                <span>Gia phong (${calc.nights} dem)</span>
                                                <span><fmt:formatNumber value="${calc.subtotal}" type="number" groupingUsed="true"/> VND</span>
                                            </div>

                                            <c:if test="${calc.promotion != null && calc.promotionDiscount > 0}">
                                                <div class="d-flex justify-content-between mb-1 text-success">
                                                    <span>Khuyen mai (${calc.promotion.discountPercent}%)</span>
                                                    <span>-<fmt:formatNumber value="${calc.promotionDiscount}" type="number" groupingUsed="true"/> VND</span>
                                                </div>
                                            </c:if>

                                            <c:if test="${calc.voucher != null && calc.discount > 0}">
                                                <div class="d-flex justify-content-between mb-1 text-success">
                                                    <span>Voucher</span>
                                                    <span>-<fmt:formatNumber value="${calc.discount}" type="number" groupingUsed="true"/> VND</span>
                                                </div>
                                            </c:if>
                                        </c:otherwise>
                                    </c:choose>

                                    <hr>
                                    <div class="d-flex justify-content-between">
                                        <strong class="fs-5">Tong cong</strong>
                                        <strong class="fs-5 text-primary">
                                            <fmt:formatNumber value="${isMultiRoom ? multiCalc.total : calc.total}" type="number" groupingUsed="true"/> VND
                                        </strong>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Occupants + Note -->
                        <div class="col-lg-7">
                            <div class="card mb-4">
                                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0"><i class="bi bi-people me-2"></i>Khach luu tru (tuy chon)</h5>
                                    <button type="button" class="btn btn-sm btn-outline-primary" onclick="addOccupant()">
                                        <i class="bi bi-plus"></i> Them khach
                                    </button>
                                </div>
                                <div class="card-body">
                                    <div id="occupantList">
                                        <div class="occupant-row border rounded p-3 mb-3">
                                            <div class="d-flex justify-content-between mb-2">
                                                <strong>Khach 1</strong>
                                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeOccupant(this)">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                            <div class="row g-2">
                                                <div class="col-md-4">
                                                    <label class="form-label">Ho ten</label>
                                                    <input type="text" class="form-control" name="occFullName" placeholder="Ho ten">
                                                </div>
                                                <div class="col-md-4">
                                                    <label class="form-label">CCCD/Passport</label>
                                                    <input type="text" class="form-control" name="occIdCard" placeholder="So CCCD">
                                                </div>
                                                <div class="col-md-4">
                                                    <label class="form-label">So dien thoai</label>
                                                    <input type="text" class="form-control" name="occPhone" placeholder="SDT">
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <p class="text-muted small">
                                        <i class="bi bi-info-circle me-1"></i>
                                        <c:choose>
                                            <c:when test="${isMultiRoom}">Tong suc chua: ${multiCalc.totalRoomCount} phong</c:when>
                                            <c:otherwise>Suc chua toi da: ${calc.roomType.capacity} nguoi. De trong neu khong co khach di cung.</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>

                            <div class="card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0"><i class="bi bi-pencil me-2"></i>Ghi chu</h5>
                                </div>
                                <div class="card-body">
                                    <textarea class="form-control" name="note" rows="3"
                                              placeholder="Ghi chu them (tuy chon)..."></textarea>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between">
                                <a href="${pageContext.request.contextPath}/staff/bookings/walkin-room"
                                   class="btn btn-outline-secondary">
                                    <i class="bi bi-arrow-left me-1"></i>Quay lai
                                </a>
                                <button type="submit" class="btn btn-success btn-lg">
                                    <i class="bi bi-check-circle me-1"></i>Xac nhan va thu tien
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
    <script>
        let occupantCount = document.querySelectorAll('.occupant-row').length;

        function addOccupant() {
            occupantCount++;
            const html =
                '<div class="occupant-row border rounded p-3 mb-3">' +
                    '<div class="d-flex justify-content-between mb-2">' +
                        '<strong>Khach ' + occupantCount + '</strong>' +
                        '<button type="button" class="btn btn-sm btn-outline-danger" onclick="removeOccupant(this)">' +
                            '<i class="bi bi-trash"></i>' +
                        '</button>' +
                    '</div>' +
                    '<div class="row g-2">' +
                        '<div class="col-md-4">' +
                            '<label class="form-label">Ho ten</label>' +
                            '<input type="text" class="form-control" name="occFullName" placeholder="Ho ten">' +
                        '</div>' +
                        '<div class="col-md-4">' +
                            '<label class="form-label">CCCD/Passport</label>' +
                            '<input type="text" class="form-control" name="occIdCard" placeholder="So CCCD">' +
                        '</div>' +
                        '<div class="col-md-4">' +
                            '<label class="form-label">So dien thoai</label>' +
                            '<input type="text" class="form-control" name="occPhone" placeholder="SDT">' +
                        '</div>' +
                    '</div>' +
                '</div>';
            document.getElementById('occupantList').insertAdjacentHTML('beforeend', html);
        }

        function removeOccupant(btn) {
            const rows = document.querySelectorAll('.occupant-row');
            if (rows.length > 1) {
                btn.closest('.occupant-row').remove();
            }
        }
    </script>
</body>
</html>
