package com.mycompany.hotelmanagementsystem.controller.common;

import com.mycompany.hotelmanagementsystem.entity.Feedback;
import com.mycompany.hotelmanagementsystem.entity.RoomType;
import com.mycompany.hotelmanagementsystem.service.AdminFeedbackService;
import com.mycompany.hotelmanagementsystem.service.RoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/home"})
public class HomeController extends HttpServlet {
    private AdminFeedbackService feedbackService;
    private RoomService roomService;

    @Override
    public void init() {
        feedbackService = new AdminFeedbackService();
        roomService = new RoomService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Load reviews
        try {
            List<Feedback> reviews = feedbackService.getVisibleFeedback(6);
            request.setAttribute("reviews", reviews);
        } catch (Exception e) {
            request.setAttribute("reviews", List.of());
        }

        // Load room types from DB for rooms section
        try {
            List<RoomType> roomTypes = roomService.getAllRoomTypes();
            request.setAttribute("roomTypes", roomTypes);
        } catch (Exception e) {
            request.setAttribute("roomTypes", List.of());
        }

        request.getRequestDispatcher("/WEB-INF/views/home/index.jsp").forward(request, response);
    }
}
