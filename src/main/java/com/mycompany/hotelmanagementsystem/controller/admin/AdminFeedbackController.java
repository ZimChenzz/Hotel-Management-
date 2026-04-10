package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import com.mycompany.hotelmanagementsystem.service.AdminFeedbackService;
import com.mycompany.hotelmanagementsystem.entity.Account;
import com.mycompany.hotelmanagementsystem.entity.Feedback;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/admin/feedback", "/admin/feedback/toggle-visibility", "/admin/feedback/reply"})
public class AdminFeedbackController extends HttpServlet {
    private AdminFeedbackService adminFeedbackService;

    @Override
    public void init() {
        adminFeedbackService = new AdminFeedbackService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/admin/feedback".equals(path)) {
            handleList(request, response);
        } else {
            response.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/admin/feedback/toggle-visibility" -> handleToggleVisibility(request, response);
            case "/admin/feedback/reply" -> handleReply(request, response);
            default -> response.sendError(404);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Feedback> feedbackList = adminFeedbackService.getAllFeedback();

        String success = request.getParameter("success");
        if ("toggled".equals(success)) {
            request.setAttribute("success", "Cập nhật trạng thái hiển thị thành công!");
        } else if ("replied".equals(success)) {
            request.setAttribute("success", "Phản hồi đã được gửi!");
        }

        request.setAttribute("feedbackList", feedbackList);
        request.setAttribute("activePage", "feedback");
        request.setAttribute("pageTitle", "Quản lý phản hồi");
        request.getRequestDispatcher("/WEB-INF/views/admin/feedback/list.jsp").forward(request, response);
    }

    private void handleToggleVisibility(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        adminFeedbackService.toggleVisibility(id);
        response.sendRedirect(request.getContextPath() + "/admin/feedback?success=toggled");
    }

    private void handleReply(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int feedbackId = Integer.parseInt(request.getParameter("id"));
        String reply = request.getParameter("reply");
        Account admin = SessionHelper.getLoggedInAccount(request);
        int adminId = admin != null ? admin.getAccountId() : 1;
        adminFeedbackService.replyToFeedback(feedbackId, adminId, reply);
        response.sendRedirect(request.getContextPath() + "/admin/feedback?success=replied");
    }
}
