<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${isEdit ? 'Sửa' : 'Thêm'} Voucher - Cổng Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Lato:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/ui-kit.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/layout.css" rel="stylesheet">
</head>
<body>
    <input type="checkbox" id="sidebar-toggle">
    <div class="app-layout">
        <c:set var="activePage" value="vouchers" scope="request"/>
        <jsp:include page="../includes/sidebar.jsp" />

        <main class="app-main">
            <c:set var="pageTitle" value="${isEdit ? 'Sửa Voucher' : 'Thêm Voucher'}" scope="request"/>
            <jsp:include page="../includes/header.jsp" />

            <div class="app-content">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/vouchers">Voucher</a></li>
                        <li class="breadcrumb-item active">${isEdit ? 'Sửa' : 'Thêm'}</li>
                    </ol>
                </nav>

                <div class="card" style="max-width: 600px;">
                    <div class="card-header">
                        <i class="bi bi-ticket-perforated me-2"></i>${isEdit ? 'Sửa' : 'Thêm'} Voucher
                    </div>
                    <div class="card-body">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-circle me-2"></i>${error}
                            </div>
                        </c:if>

                        <form method="post">
                            <c:if test="${isEdit}">
                                <input type="hidden" name="id" value="${voucher.voucherId}">
                            </c:if>

                            <div class="mb-3">
                                <label class="form-label">Mã code <span class="text-danger">*</span></label>
                                <input type="text" class="form-control text-uppercase" name="code"
                                       value="${voucher.code}" required maxlength="20"
                                       placeholder="VD: SUMMER2024">
                                <small class="text-muted">Mã sẽ tự động chuyển thành chữ in hoa</small>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Số tiền giảm (VNĐ) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" name="discountAmount"
                                           value="${voucher.discountAmount}" required min="0" step="1000">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Đơn tối thiểu (VNĐ) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" name="minOrderValue"
                                           value="${voucher.minOrderValue}" required min="0" step="1000">
                                </div>
                            </div>

                            <div class="mb-4">
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" name="isActive" id="isActive"
                                           ${voucher.active || !isEdit ? 'checked' : ''}>
                                    <label class="form-check-label" for="isActive">Kích hoạt voucher</label>
                                </div>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check-lg me-1"></i>${isEdit ? 'Cập nhật' : 'Tạo mới'}
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/vouchers" class="btn btn-secondary">
                                    Hủy
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <label for="sidebar-toggle" class="mobile-toggle">
        <i class="bi bi-list"></i>
    </label>

    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
