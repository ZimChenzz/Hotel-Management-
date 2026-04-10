package com.mycompany.hotelmanagementsystem.controller.staff;

import com.mycompany.hotelmanagementsystem.service.StaffCleaningService;
import com.mycompany.hotelmanagementsystem.entity.RoomCleaningInfo;
import com.mycompany.hotelmanagementsystem.entity.Account;
import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/staff/cleaning", "/staff/cleaning/update", "/staff/cleaning/accept"})
public class StaffCleaningController extends HttpServlet {
    private StaffCleaningService staffCleaningService;

    @Override
    public void init() {
        staffCleaningService = new StaffCleaningService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/staff/cleaning".equals(path)) {
            handleCleaningList(request, response);
        } else {
            response.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/staff/cleaning/update".equals(path)) {
            handleUpdateCleaning(request, response);
        } else if ("/staff/cleaning/accept".equals(path)) {
            handleAcceptCleaning(request, response);
        } else {
            response.sendError(404);
        }
    }

    // UC-20.1: View Cleaning Requests
    private void handleCleaningList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<RoomCleaningInfo> rooms = staffCleaningService.getRoomsNeedingCleaning();

        String success = request.getParameter("success");
        if ("cleaned".equals(success)) {
            request.setAttribute("success", "�ã đánh dấu phòng hoàn thành dọn dẹp!");
        } else if ("accepted".equals(success)) {
            request.setAttribute("success", "Đã nhận yêu cầu dọn phòng!");
        }

        request.setAttribute("rooms", rooms);
        request.setAttribute("activePage", "cleaning");
        request.setAttribute("pageTitle", "Quản lý dọn phòng");
        request.getRequestDispatcher("/WEB-INF/views/staff/cleaning/list.jsp").forward(request, response);
    }

    // UC-20.2: Accept cleaning request
    private void handleAcceptCleaning(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String roomIdParam = request.getParameter("roomId");
        if (roomIdParam == null || roomIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/cleaning");
            return;
        }

        try {
            int roomId = Integer.parseInt(roomIdParam);
            Account account = SessionHelper.getLoggedInAccount(request);
            boolean success = staffCleaningService.acceptCleaningRequest(roomId, account.getAccountId());
            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/cleaning?success=accepted");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/cleaning");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/staff/cleaning");
        }
    }

    // UC-20.3: Update Cleaning Status
    private void handleUpdateCleaning(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomIdParam = request.getParameter("roomId");
        String status = request.getParameter("status");

        if (roomIdParam == null || roomIdParam.isEmpty()) {
            response.sendError(400, "Missing room ID");
            return;
        }

        try {
            int roomId = Integer.parseInt(roomIdParam);

            // Mark as available if status is "Available"
            if ("Available".equals(status)) {
                boolean success = staffCleaningService.markRoomAsClean(roomId);
                if (success) {
                    // Check if came from room detail page
                    String referer = request.getHeader("Referer");
                    if (referer != null && referer.contains("/staff/rooms/detail")) {
                        response.sendRedirect(request.getContextPath() + "/staff/rooms/detail?id=" + roomId);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/staff/cleaning?success=cleaned");
                    }
                    return;
                }
            }

            request.setAttribute("error", "Không thể cập nhật trạng thái phòng");
            handleCleaningList(request, response);
        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid room ID");
        }
    }
}
