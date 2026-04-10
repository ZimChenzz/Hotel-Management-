package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.service.AdminVoucherService;
import com.mycompany.hotelmanagementsystem.entity.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(urlPatterns = {"/admin/vouchers", "/admin/vouchers/create", "/admin/vouchers/edit", "/admin/vouchers/delete"})
public class AdminVoucherController extends HttpServlet {
    private AdminVoucherService adminVoucherService;

    @Override
    public void init() {
        adminVoucherService = new AdminVoucherService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/admin/vouchers" -> handleList(request, response);
            case "/admin/vouchers/create" -> handleCreateForm(request, response);
            case "/admin/vouchers/edit" -> handleEditForm(request, response);
            default -> response.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/admin/vouchers/create" -> handleCreate(request, response);
            case "/admin/vouchers/edit" -> handleEdit(request, response);
            case "/admin/vouchers/delete" -> handleDelete(request, response);
            default -> response.sendError(404);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Voucher> vouchers = adminVoucherService.getAllVouchers();

        String success = request.getParameter("success");
        if ("created".equals(success)) {
            request.setAttribute("success", "Tạo voucher thành công!");
        } else if ("updated".equals(success)) {
            request.setAttribute("success", "Cập nhật voucher thành công!");
        } else if ("deleted".equals(success)) {
            request.setAttribute("success", "Xóa voucher thành công!");
        }

        request.setAttribute("vouchers", vouchers);
        request.setAttribute("activePage", "vouchers");
        request.setAttribute("pageTitle", "Quản lý Voucher");
        request.getRequestDispatcher("/WEB-INF/views/admin/vouchers/list.jsp").forward(request, response);
    }

    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activePage", "vouchers");
        request.setAttribute("pageTitle", "Thêm Voucher");
        request.setAttribute("isEdit", false);
        request.getRequestDispatcher("/WEB-INF/views/admin/vouchers/form.jsp").forward(request, response);
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Voucher voucher = adminVoucherService.getVoucherById(id);

        if (voucher == null) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?error=notfound");
            return;
        }

        request.setAttribute("voucher", voucher);
        request.setAttribute("activePage", "vouchers");
        request.setAttribute("pageTitle", "Sửa Voucher");
        request.setAttribute("isEdit", true);
        request.getRequestDispatcher("/WEB-INF/views/admin/vouchers/form.jsp").forward(request, response);
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        BigDecimal discountAmount = new BigDecimal(request.getParameter("discountAmount"));
        BigDecimal minOrderValue = new BigDecimal(request.getParameter("minOrderValue"));
        boolean isActive = "on".equals(request.getParameter("isActive"));

        int result = adminVoucherService.createVoucher(code, discountAmount, minOrderValue, isActive);

        if (result > 0) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?success=created");
        } else {
            request.setAttribute("error", "Không thể tạo voucher!");
            request.getRequestDispatcher("/WEB-INF/views/admin/vouchers/form.jsp").forward(request, response);
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String code = request.getParameter("code");
        BigDecimal discountAmount = new BigDecimal(request.getParameter("discountAmount"));
        BigDecimal minOrderValue = new BigDecimal(request.getParameter("minOrderValue"));
        boolean isActive = "on".equals(request.getParameter("isActive"));

        boolean success = adminVoucherService.updateVoucher(id, code, discountAmount, minOrderValue, isActive);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?success=updated");
        } else {
            request.setAttribute("error", "Không thể cập nhật voucher!");
            handleEditForm(request, response);
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        adminVoucherService.deleteVoucher(id);
        response.sendRedirect(request.getContextPath() + "/admin/vouchers?success=deleted");
    }
}
