package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.service.AdminPromotionService;
import com.mycompany.hotelmanagementsystem.entity.Promotion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@WebServlet(urlPatterns = {
    "/admin/promotions",
    "/admin/promotions/create",
    "/admin/promotions/edit",
    "/admin/promotions/delete"
})
public class AdminPromotionController extends HttpServlet {
    private AdminPromotionService adminPromotionService;

    @Override
    public void init() {
        adminPromotionService = new AdminPromotionService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/admin/promotions"        -> handleList(request, response);
            case "/admin/promotions/create" -> handleCreateForm(request, response);
            case "/admin/promotions/edit"   -> handleEditForm(request, response);
            default -> response.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/admin/promotions/create" -> handleCreate(request, response);
            case "/admin/promotions/edit"   -> handleEdit(request, response);
            case "/admin/promotions/delete" -> handleDelete(request, response);
            default -> response.sendError(404);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Promotion> promotions = adminPromotionService.getAllPromotions();

        String success = request.getParameter("success");
        if ("created".equals(success)) {
            request.setAttribute("success", "Tạo khuyến mãi thành công!");
        } else if ("updated".equals(success)) {
            request.setAttribute("success", "Cập nhật khuyến mãi thành công!");
        } else if ("deleted".equals(success)) {
            request.setAttribute("success", "Xóa khuyến mãi thành công!");
        }

        request.setAttribute("promotions", promotions);
        request.setAttribute("activePage", "promotions");
        request.setAttribute("pageTitle", "Quản lý Khuyến mãi");
        request.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp")
               .forward(request, response);
    }

    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("roomTypes", adminPromotionService.getAllRoomTypes());
        request.setAttribute("activePage", "promotions");
        request.setAttribute("pageTitle", "Thêm Khuyến mãi");
        request.setAttribute("isEdit", false);
        request.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp")
               .forward(request, response);
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Promotion promotion = adminPromotionService.getPromotionById(id);
        if (promotion == null) {
            response.sendRedirect(request.getContextPath() + "/admin/promotions?error=notfound");
            return;
        }
        request.setAttribute("promotion", promotion);
        request.setAttribute("roomTypes", adminPromotionService.getAllRoomTypes());
        request.setAttribute("activePage", "promotions");
        request.setAttribute("pageTitle", "Sửa Khuyến mãi");
        request.setAttribute("isEdit", true);
        request.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp")
               .forward(request, response);
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int typeId = Integer.parseInt(request.getParameter("typeId"));
            String promoCode = request.getParameter("promoCode");
            BigDecimal discountPercent = new BigDecimal(request.getParameter("discountPercent"));
            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));

            int result = adminPromotionService.createPromotion(
                typeId, promoCode, discountPercent, startDate, endDate);

            if (result > 0) {
                response.sendRedirect(request.getContextPath() + "/admin/promotions?success=created");
            } else {
                request.setAttribute("error", "Không thể tạo khuyến mãi! Kiểm tra lại thông tin.");
                handleCreateForm(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            handleCreateForm(request, response);
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            int typeId = Integer.parseInt(request.getParameter("typeId"));
            String promoCode = request.getParameter("promoCode");
            BigDecimal discountPercent = new BigDecimal(request.getParameter("discountPercent"));
            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));

            boolean success = adminPromotionService.updatePromotion(
                id, typeId, promoCode, discountPercent, startDate, endDate);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/promotions?success=updated");
            } else {
                request.setAttribute("error", "Không thể cập nhật khuyến mãi!");
                handleEditForm(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
            handleEditForm(request, response);
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        adminPromotionService.deletePromotion(id);
        response.sendRedirect(request.getContextPath() + "/admin/promotions?success=deleted");
    }
}
