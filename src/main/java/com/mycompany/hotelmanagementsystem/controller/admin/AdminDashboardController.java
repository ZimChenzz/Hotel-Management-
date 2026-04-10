package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.service.AdminReportService;
import com.mycompany.hotelmanagementsystem.service.ServiceRequestService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {
    private AdminReportService adminReportService;
    private ServiceRequestService serviceRequestService;

    @Override
    public void init() {
        adminReportService = new AdminReportService();
        serviceRequestService = new ServiceRequestService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get filter parameters
        String period = request.getParameter("period");
        if (period == null || period.isEmpty()) period = "month";

        LocalDateTime startDate;
        LocalDateTime endDate;
        int[] monthlyCounts;
        String[] monthlyLabels;
        Map<String, Object> stats;

        switch (period) {
            case "today":
                startDate = LocalDate.now().atStartOfDay();
                endDate = LocalDate.now().atTime(LocalTime.MAX);
                stats = adminReportService.getStatsByDateRange(startDate, endDate);
                monthlyLabels = adminReportService.getHourlyLabels();
                monthlyCounts = adminReportService.getHourlyBookingCounts();
                break;
            case "week":
                startDate = LocalDate.now().with(java.time.DayOfWeek.MONDAY).atStartOfDay();
                endDate = LocalDate.now().atTime(LocalTime.MAX);
                stats = adminReportService.getStatsByDateRange(startDate, endDate);
                monthlyLabels = adminReportService.getDailyLabelsWeek();
                monthlyCounts = adminReportService.getDailyBookingCountsWeek();
                break;
            case "month":
                startDate = LocalDate.now().withDayOfMonth(1).atStartOfDay();
                endDate = LocalDate.now().atTime(LocalTime.MAX);
                stats = adminReportService.getStatsByDateRange(startDate, endDate);
                monthlyLabels = adminReportService.getDailyLabelsMonth();
                monthlyCounts = adminReportService.getDailyBookingCountsMonth();
                break;
            case "quarter":
                LocalDate nowQ = LocalDate.now();
                int currentQuarter = (nowQ.getMonthValue() - 1) / 3;
                LocalDate quarterStart = LocalDate.of(nowQ.getYear(), currentQuarter * 3 + 1, 1);
                startDate = quarterStart.atStartOfDay();
                endDate = nowQ.atTime(LocalTime.MAX);
                stats = adminReportService.getStatsByDateRange(startDate, endDate);
                monthlyLabels = adminReportService.getMonthlyLabelsQuarter();
                monthlyCounts = adminReportService.getMonthlyBookingCountsQuarter();
                break;
            case "year":
                startDate = LocalDate.of(LocalDate.now().getYear(), 1, 1).atStartOfDay();
                endDate = LocalDate.now().atTime(LocalTime.MAX);
                stats = adminReportService.getStatsByDateRange(startDate, endDate);
                monthlyLabels = adminReportService.getMonthlyLabels();
                monthlyCounts = adminReportService.getMonthlyBookingCounts();
                break;
            case "custom":
                String startStr = request.getParameter("startDate");
                String endStr = request.getParameter("endDate");
                if (startStr != null && !startStr.isEmpty() && endStr != null && !endStr.isEmpty()) {
                    startDate = LocalDate.parse(startStr).atStartOfDay();
                    endDate = LocalDate.parse(endStr).atTime(LocalTime.MAX);
                } else {
                    startDate = LocalDate.now().withDayOfMonth(1).atStartOfDay();
                    endDate = LocalDate.now().atTime(LocalTime.MAX);
                }
                stats = adminReportService.getStatsByDateRange(startDate, endDate);
                monthlyLabels = adminReportService.getDailyLabelsForRange(startDate, endDate);
                monthlyCounts = adminReportService.getDailyBookingCountsForRange(startDate, endDate);
                break;
            default:
                period = "month";
                startDate = LocalDate.now().withDayOfMonth(1).atStartOfDay();
                endDate = LocalDate.now().atTime(LocalTime.MAX);
                stats = adminReportService.getStatsByDateRange(startDate, endDate);
                monthlyLabels = adminReportService.getMonthlyLabels();
                monthlyCounts = adminReportService.getMonthlyBookingCounts();
        }

        // Revenue chart data
        double[] revenueData = adminReportService.getRevenueData(startDate, endDate, period);
        String[] revenueLabels = adminReportService.getRevenueLabels(startDate, endDate, period);

        // Stats (always include room stats from overall count)
        Map<String, Object> roomStats = adminReportService.getRoomUtilizationStats();
        for (String key : roomStats.keySet()) {
            stats.put(key, roomStats.get(key));
        }

        String labelsJson = "[" + Arrays.stream(monthlyLabels)
            .map(l -> "\"" + l + "\"").collect(Collectors.joining(",")) + "]";
        String countsJson = "[" + Arrays.stream(monthlyCounts)
            .mapToObj(String::valueOf).collect(Collectors.joining(",")) + "]";
        String revenueLabelsJson = "[" + Arrays.stream(revenueLabels)
            .map(l -> "\"" + l + "\"").collect(Collectors.joining(",")) + "]";
        String revenueValuesJson = "[" + Arrays.stream(revenueData)
            .mapToObj(String::valueOf).collect(Collectors.joining(",")) + "]";

        request.setAttribute("stats", stats);
        request.setAttribute("monthlyLabels", labelsJson);
        request.setAttribute("monthlyCounts", countsJson);
        request.setAttribute("revenueLabels", revenueLabelsJson);
        request.setAttribute("revenueValues", revenueValuesJson);
        request.setAttribute("selectedPeriod", period);
        request.setAttribute("startDate", startDate != null ? startDate.toLocalDate().toString() : "");
        request.setAttribute("endDate", endDate != null ? endDate.toLocalDate().toString() : "");

        // Service request stats for dashboard widget
        Map<String, Integer> serviceRequestStats = serviceRequestService.getRequestStats();
        request.setAttribute("serviceRequestStats", serviceRequestStats);

        request.setAttribute("activePage", "dashboard");
        request.setAttribute("pageTitle", "Dashboard");
        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }
}
