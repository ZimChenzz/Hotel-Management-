package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.entity.ServiceRequest;
import com.mycompany.hotelmanagementsystem.service.ServiceRequestService;
import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/admin/service-requests"})
public class AdminServiceRequestController extends HttpServlet {
    private ServiceRequestService serviceRequestService;

    @Override
    public void init() {
        serviceRequestService = new ServiceRequestService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String statusFilter = request.getParameter("status");
        String typeFilter = request.getParameter("type");

        List<ServiceRequest> serviceRequests;
        if (statusFilter != null && !statusFilter.isEmpty()) {
            serviceRequests = serviceRequestService.getRequestsByStatus(statusFilter);
        } else {
            serviceRequests = serviceRequestService.getAllRequests();
        }

        // Filter by service type if specified
        if (typeFilter != null && !typeFilter.isEmpty()) {
            serviceRequests = serviceRequests.stream()
                    .filter(sr -> typeFilter.equals(sr.getServiceType()))
                    .toList();
        }

        Map<String, Integer> stats = serviceRequestService.getRequestStats();

        request.setAttribute("serviceRequests", serviceRequests);
        request.setAttribute("stats", stats);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("typeFilter", typeFilter);
        request.setAttribute("activePage", "service-requests");
        request.setAttribute("pageTitle", "Quản lý yêu cầu dịch vụ");
        request.getRequestDispatcher("/WEB-INF/views/admin/service-requests/list.jsp")
               .forward(request, response);
    }
}
