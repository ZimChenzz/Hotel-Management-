<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dat phong tai quay - Cong Nhan Vien</title>
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
            <c:set var="pageTitle" value="Dat phong tai quay" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <!-- Stepper -->
                <div class="d-flex justify-content-center mb-4">
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-primary rounded-pill px-3 py-2">1. Thong tin khach</span>
                        <i class="bi bi-chevron-right text-muted"></i>
                        <span class="badge bg-secondary rounded-pill px-3 py-2">2. Chon phong</span>
                        <i class="bi bi-chevron-right text-muted"></i>
                        <span class="badge bg-secondary rounded-pill px-3 py-2">3. Xac nhan</span>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <div class="row justify-content-center">
                    <div class="col-lg-6">

                        <%-- Email conflict confirmation dialog --%>
                        <c:if test="${emailConflict}">
                            <div class="alert alert-warning">
                                <h6 class="alert-heading">
                                    <i class="bi bi-exclamation-triangle me-1"></i>Email da ton tai
                                </h6>
                                <p class="mb-2">
                                    Email <strong>${email}</strong> da duoc su dung boi tai khoan:
                                </p>
                                <p class="mb-3">
                                    <strong>${conflictName}</strong> - SDT: ${conflictPhone}
                                </p>
                                <p class="mb-3">Day co phai cung mot khach hang khong?</p>
                                <div class="d-flex gap-2">
                                    <form action="${pageContext.request.contextPath}/staff/bookings/walkin" method="post" class="d-inline">
                                        <input type="hidden" name="fullName" value="${fullName}">
                                        <input type="hidden" name="phone" value="${phone}">
                                        <input type="hidden" name="email" value="${email}">
                                        <input type="hidden" name="idCard" value="${idCard}">
                                        <input type="hidden" name="confirmEmailLink" value="true">
                                        <button type="submit" class="btn btn-success btn-sm">
                                            <i class="bi bi-check-circle me-1"></i>Dung, lien ket tai khoan cu
                                        </button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/staff/bookings/walkin" method="post" class="d-inline">
                                        <input type="hidden" name="fullName" value="${fullName}">
                                        <input type="hidden" name="phone" value="${phone}">
                                        <input type="hidden" name="email" value="">
                                        <input type="hidden" name="idCard" value="${idCard}">
                                        <input type="hidden" name="skipEmail" value="true">
                                        <button type="submit" class="btn btn-outline-secondary btn-sm">
                                            <i class="bi bi-x-circle me-1"></i>Khong, tao tai khoan moi (bo qua email)
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:if>

                        <div class="card">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="bi bi-person me-2"></i>Thong tin khach hang</h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/staff/bookings/walkin" method="post">
                                    <div class="mb-3">
                                        <label for="fullName" class="form-label">Ho va ten <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="fullName" name="fullName"
                                               value="${fullName}" required placeholder="Nhap ho ten khach hang">
                                    </div>
                                    <div class="mb-3">
                                        <label for="phone" class="form-label">So dien thoai <span class="text-danger">*</span></label>
                                        <input type="tel" class="form-control" id="phone" name="phone"
                                               value="${phone}" required placeholder="VD: 0901234567">
                                    </div>
                                    <div class="mb-3">
                                        <label for="email" class="form-label">Email</label>
                                        <input type="email" class="form-control" id="email" name="email"
                                               value="${email}" placeholder="(Tuy chon - dung de gui thong tin dat phong)">
                                    </div>
                                    <div class="mb-3">
                                        <label for="idCard" class="form-label">So CCCD/Passport</label>
                                        <input type="text" class="form-control" id="idCard" name="idCard"
                                               value="${idCard}" placeholder="(Tuy chon)">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Loai dat phong <span class="text-danger">*</span></label>
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="bookingType" id="singleRoom" value="single" checked>
                                            <label class="form-check-label" for="singleRoom">
                                                <i class="bi bi-door-open me-1"></i>Dat 1 phong
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="bookingType" id="multiRoom" value="multi">
                                            <label class="form-check-label" for="multiRoom">
                                                <i class="bi bi-collection me-1"></i>Dat nhieu phong
                                            </label>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <a href="${pageContext.request.contextPath}/staff/bookings"
                                           class="btn btn-outline-secondary">
                                            <i class="bi bi-arrow-left me-1"></i>Quay lai
                                        </a>
                                        <button type="submit" class="btn btn-staff-primary">
                                            Tiep tuc <i class="bi bi-arrow-right ms-1"></i>
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
