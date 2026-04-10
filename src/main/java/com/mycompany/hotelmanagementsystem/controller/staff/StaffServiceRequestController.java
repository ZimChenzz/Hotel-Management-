package com.mycompany.hotelmanagementsystem.controller.staff;

import com.mycompany.hotelmanagementsystem.constant.ServiceTypeConstant;
import com.mycompany.hotelmanagementsystem.entity.Account;
import com.mycompany.hotelmanagementsystem.entity.ServiceRequest;
import com.mycompany.hotelmanagementsystem.service.ServiceRequestService;
import com.mycompany.hotelmanagementsystem.util.ServiceResult;
import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {
    "/staff/service-requests",
    "/staff/service-requests/assign",
    "/staff/service-requests/complete",
    "/staff/service-requests/reject"
})
public class StaffServiceRequestController extends HttpServlet {
    private ServiceRequestService serviceRequestService;

    @Override
    public void init() {
        serviceRequestService = new ServiceRequestService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/staff/service-requests".equals(path)) {
            handleListGet(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/staff/service-requests/assign" -> handleAssignPost(request, response);
            case "/staff/service-requests/complete" -> handleCompletePost(request, response);
            case "/staff/service-requests/reject" -> handleRejectPost(request, response);
        }
    }

    private void handleListGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        String tab = request.getParameter("tab");
        String typeFilter = request.getParameter("type");

        List<ServiceRequest> serviceRequests;

        if ("my".equals(tab)) {
            // "Của tôi" tab: show staff's assigned requests (all statuses)
            serviceRequests = serviceRequestService.getStaffRequests(account.getAccountId());
        } else {
            // "Chờ xử lý" tab: show only PENDING requests
            serviceRequests = serviceRequestService.getRequestsByStatus("Pending");
        }

        // Filter by service type if specified
        if (typeFilter != null && !typeFilter.isEmpty()) {
            serviceRequests = serviceRequests.stream()
                    .filter(sr -> typeFilter.equals(sr.getServiceType()))
                    .toList();
        }

        var stats = serviceRequestService.getRequestStats();

        request.setAttribute("serviceRequests", serviceRequests);
        request.setAttribute("currentTab", tab != null ? tab : "all");
        request.setAttribute("typeFilter", typeFilter);
        request.setAttribute("stats", stats);
        request.setAttribute("activePage", "service-requests");
        request.setAttribute("pageTitle", "Yêu cầu dịch vụ");
        request.getRequestDispatcher("/WEB-INF/views/staff/service-requests/list.jsp")
               .forward(request, response);
    }

    private void handleAssignPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        Integer requestId = parseIntParam(request, "requestId");

        if (requestId == null) {
            response.sendRedirect(request.getContextPath() + "/staff/service-requests");
            return;
        }

        ServiceResult result = serviceRequestService.assignToStaff(requestId, account.getAccountId());
        setFlashMessage(request, result);
        response.sendRedirect(request.getContextPath() + "/staff/service-requests");
    }

    private void handleCompletePost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        Integer requestId = parseIntParam(request, "requestId");
        String notes = request.getParameter("notes");

        if (requestId == null) {
            response.sendRedirect(request.getContextPath() + "/staff/service-requests");
            return;
        }

        ServiceResult result = serviceRequestService.completeRequest(requestId, account.getAccountId(), notes);
        setFlashMessage(request, result);
        response.sendRedirect(request.getContextPath() + "/staff/service-requests?tab=my");
    }

    private void handleRejectPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        Integer requestId = parseIntParam(request, "requestId");
        String notes = request.getParameter("notes");

        if (requestId == null) {
            response.sendRedirect(request.getContextPath() + "/staff/service-requests");
            return;
        }

        ServiceResult result = serviceRequestService.rejectRequest(requestId, account.getAccountId(), notes);
        setFlashMessage(request, result);
        response.sendRedirect(request.getContextPath() + "/staff/service-requests?tab=my");
    }

    private void setFlashMessage(HttpServletRequest request, ServiceResult result) {
        String key = result.isSuccess() ? "successMessage" : "errorMessage";
        request.getSession().setAttribute(key, result.getMessage());
    }

    private Integer parseIntParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value != null && !value.isEmpty()) {
            try { return Integer.parseInt(value); } catch (NumberFormatException e) { return null; }
        }
        return null;
    }
}
