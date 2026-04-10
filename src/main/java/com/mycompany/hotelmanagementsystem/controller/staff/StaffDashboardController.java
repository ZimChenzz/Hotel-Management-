package com.mycompany.hotelmanagementsystem.controller.staff;

import com.mycompany.hotelmanagementsystem.constant.BookingStatus;
import com.mycompany.hotelmanagementsystem.constant.RoomStatus;
import com.mycompany.hotelmanagementsystem.constant.ServiceRequestStatusConstant;
import com.mycompany.hotelmanagementsystem.dal.BookingRepository;
import com.mycompany.hotelmanagementsystem.dal.RoomRepository;
import com.mycompany.hotelmanagementsystem.dal.ServiceRequestRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = {"/staff/dashboard"})
public class StaffDashboardController extends HttpServlet {
    private RoomRepository roomRepository;
    private BookingRepository bookingRepository;
    private ServiceRequestRepository serviceRequestRepository;

    @Override
    public void init() {
        roomRepository = new RoomRepository();
        bookingRepository = new BookingRepository();
        serviceRequestRepository = new ServiceRequestRepository();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Dashboard statistics
        int roomsAvailable = roomRepository.countByStatus(RoomStatus.AVAILABLE);
        int roomsOccupied = roomRepository.countByStatus(RoomStatus.OCCUPIED);
        int roomsCleaning = roomRepository.countByStatus(RoomStatus.CLEANING);

        int pendingCheckins = bookingRepository.countByStatus(BookingStatus.CONFIRMED);
        int pendingCheckouts = bookingRepository.countByStatus(BookingStatus.CHECKED_IN);

        request.setAttribute("roomsAvailable", roomsAvailable);
        request.setAttribute("roomsOccupied", roomsOccupied);
        request.setAttribute("roomsCleaning", roomsCleaning);
        request.setAttribute("pendingCheckins", pendingCheckins);
        request.setAttribute("pendingCheckouts", pendingCheckouts);

        // Service request stats
        int pendingServiceRequests = serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.PENDING);
        request.setAttribute("pendingServiceRequests", pendingServiceRequests);

        request.setAttribute("activePage", "dashboard");
        request.setAttribute("pageTitle", "Dashboard");
        request.getRequestDispatcher("/WEB-INF/views/staff/dashboard.jsp").forward(request, response);
    }
}
