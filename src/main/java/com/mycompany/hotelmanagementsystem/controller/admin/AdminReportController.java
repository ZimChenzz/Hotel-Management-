package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.service.AdminReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;

@WebServlet(urlPatterns = {"/admin/reports/utilization", "/admin/reports/revenue"})
public class AdminReportController extends HttpServlet {
    private AdminReportService adminReportService;

    @Override
    public void init() {
        adminReportService = new AdminReportService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/admin/reports/utilization" -> handleUtilizationReport(request, response);
            case "/admin/reports/revenue" -> handleRevenueReport(request, response);
            default -> response.sendError(404);
        }
    }

    // UC-25.1: Room Utilization Report
    private void handleUtilizationReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, Object> stats = adminReportService.getRoomUtilizationStats();

        request.setAttribute("stats", stats);
        request.setAttribute("activePage", "utilization");
        request.setAttribute("pageTitle", "Báo cáo công suất phòng");
        request.getRequestDispatcher("/WEB-INF/views/admin/reports/utilization.jsp").forward(request, response);
    }

    // UC-25.2: Revenue Report
    private void handleRevenueReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Parse date range
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        LocalDateTime startDate;
        LocalDateTime endDate;

        if (startDateStr != null && endDateStr != null) {
            startDate = LocalDate.parse(startDateStr).atStartOfDay();
            endDate = LocalDate.parse(endDateStr).atTime(23, 59, 59);
        } else {
            // Default to current month
            LocalDate now = LocalDate.now();
            startDate = now.withDayOfMonth(1).atStartOfDay();
            endDate = now.atTime(23, 59, 59);
        }

        Map<String, Object> report = adminReportService.getRevenueReport(startDate, endDate);

        request.setAttribute("report", report);
        request.setAttribute("startDate", startDate.toLocalDate());
        request.setAttribute("endDate", endDate.toLocalDate());
        request.setAttribute("activePage", "revenue");
        request.setAttribute("pageTitle", "Báo cáo doanh thu");
        request.getRequestDispatcher("/WEB-INF/views/admin/reports/revenue.jsp").forward(request, response);
    }
}
