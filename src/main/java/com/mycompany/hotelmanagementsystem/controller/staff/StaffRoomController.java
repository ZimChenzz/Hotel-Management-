package com.mycompany.hotelmanagementsystem.controller.staff;

import com.mycompany.hotelmanagementsystem.service.StaffRoomService;
import com.mycompany.hotelmanagementsystem.entity.Room;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/staff/rooms", "/staff/rooms/detail", "/staff/rooms/history", "/staff/rooms/reconcile"})
public class StaffRoomController extends HttpServlet {
    private StaffRoomService staffRoomService;

    @Override
    public void init() {
        staffRoomService = new StaffRoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/staff/rooms" -> handleRoomMap(request, response);
            case "/staff/rooms/detail" -> handleRoomDetail(request, response);
            case "/staff/rooms/history" -> handleRoomHistory(request, response);
            case "/staff/rooms/reconcile" -> handleReconcile(request, response);
            default -> response.sendError(404);
        }
    }

    private void handleReconcile(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int reconciled = staffRoomService.reconcileRoomStatuses();
        request.getSession().setAttribute("successMessage",
                "Đã đồng bộ " + reconciled + " phòng bị lỗi trạng thái");
        response.sendRedirect(request.getContextPath() + "/staff/rooms");
    }

    private void handleRoomMap(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Room> rooms = staffRoomService.getAllRoomsWithType();
        Map<String, List<Room>> roomsByFloor = staffRoomService.getRoomsGroupedByFloor();

        request.setAttribute("rooms", rooms);
        request.setAttribute("roomsByFloor", roomsByFloor);
        request.setAttribute("activePage", "rooms");
        request.setAttribute("pageTitle", "Sơ đồ phòng");
        request.getRequestDispatcher("/WEB-INF/views/staff/rooms/map.jsp").forward(request, response);
    }

    private void handleRoomDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(400, "Missing room ID");
            return;
        }

        try {
            int roomId = Integer.parseInt(idParam);
            Room room = staffRoomService.getRoomDetail(roomId);

            if (room == null) {
                response.sendError(404, "Room not found");
                return;
            }

            request.setAttribute("room", room);
            request.setAttribute("activePage", "rooms");
            request.setAttribute("pageTitle", "Chi tiết phòng " + room.getRoomNumber());
            request.getRequestDispatcher("/WEB-INF/views/staff/rooms/detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid room ID");
        }
    }

    private void handleRoomHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(400, "Missing room ID");
            return;
        }
        try {
            int roomId = Integer.parseInt(idParam);
            Room room = staffRoomService.getRoomDetail(roomId);
            if (room == null) {
                response.sendError(404, "Room not found");
                return;
            }
            request.setAttribute("room", room);
            request.setAttribute("bookings", staffRoomService.getRoomHistory(roomId));
            request.setAttribute("activePage", "rooms");
            request.setAttribute("pageTitle", "Lich su phong " + room.getRoomNumber());
            request.getRequestDispatcher("/WEB-INF/views/staff/rooms/history.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid room ID");
        }
    }
}
