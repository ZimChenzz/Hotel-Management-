package com.mycompany.hotelmanagementsystem.controller.customer;

import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import com.mycompany.hotelmanagementsystem.util.ValidationHelper;
import com.mycompany.hotelmanagementsystem.service.*;
import com.mycompany.hotelmanagementsystem.entity.*;
import com.mycompany.hotelmanagementsystem.dal.AccountRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/customer/profile", "/customer/bookings", "/customer/booking",
    "/customer/service-request", "/customer/feedback",
    "/customer/booking/cancel", "/customer/feedback/update", "/customer/feedback/delete",
    "/customer/request/cancel", "/customer/reviews", "/customer/requests",
    "/customer/requests/create"})
public class CustomerController extends HttpServlet {
    private AccountRepository accountRepository;
    private BookingService bookingService;
    private ServiceRequestService serviceRequestService;
    private FeedbackService feedbackService;

    @Override
    public void init() {
        accountRepository = new AccountRepository();
        bookingService = new BookingService();
        serviceRequestService = new ServiceRequestService();
        feedbackService = new FeedbackService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/customer/profile" -> handleProfileGet(request, response);
            case "/customer/bookings" -> handleBookingsGet(request, response);
            case "/customer/booking" -> handleBookingDetailGet(request, response);
            case "/customer/reviews" -> handleReviewsGet(request, response);
            case "/customer/requests" -> handleRequestsGet(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/customer/profile" -> handleProfilePost(request, response);
            case "/customer/service-request" -> handleServiceRequestPost(request, response);
            case "/customer/requests/create" -> handleCreateRequestPost(request, response);
            case "/customer/feedback" -> handleFeedbackPost(request, response);
            case "/customer/booking/cancel" -> handleCancelBookingPost(request, response);
            case "/customer/feedback/update" -> handleFeedbackUpdatePost(request, response);
            case "/customer/feedback/delete" -> handleFeedbackDeletePost(request, response);
            case "/customer/request/cancel" -> handleCancelRequestPost(request, response);
        }
    }

    private void handleProfileGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        account = accountRepository.findById(account.getAccountId());
        request.setAttribute("account", account);
        request.getRequestDispatcher("/WEB-INF/views/customer/profile.jsp").forward(request, response);
    }

    private void handleProfilePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);

        // Dùng inline params thay cho ProfileUpdateRequest
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        if (!ValidationHelper.isNotEmpty(fullName)) {
            request.setAttribute("error", "Họ tên không được để trống");
            handleProfileGet(request, response);
            return;
        }

        account = accountRepository.findById(account.getAccountId());
        account.setFullName(ValidationHelper.sanitize(fullName));
        account.setPhone(phone);
        account.setAddress(ValidationHelper.sanitize(address));

        int updated = accountRepository.update(account);
        if (updated > 0) {
            SessionHelper.setLoggedInAccount(request, account);
            request.setAttribute("success", "Cập nhật thông tin thành công");
        } else {
            request.setAttribute("error", "Cập nhật thất bại");
        }

        request.setAttribute("account", account);
        request.getRequestDispatcher("/WEB-INF/views/customer/profile.jsp").forward(request, response);
    }

    private void handleBookingsGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        String statusFilter = request.getParameter("status");

        List<Booking> bookings = bookingService.getCustomerBookings(account.getAccountId());
        if (statusFilter != null && !statusFilter.isEmpty()) {
            bookings = bookings.stream().filter(b -> statusFilter.equals(b.getStatus())).toList();
        }

        request.setAttribute("bookings", bookings);
        request.setAttribute("statusFilter", statusFilter);
        request.getRequestDispatcher("/WEB-INF/views/customer/bookings.jsp").forward(request, response);
    }

    private void handleBookingDetailGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer bookingId = parseIntParam(request, "id");
        if (bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);
        Booking booking = bookingService.getBookingById(bookingId);

        if (booking == null || booking.getCustomerId() != account.getAccountId()) {
            response.sendError(403);
            return;
        }

        List<ServiceRequest> serviceRequests = serviceRequestService.getBookingRequests(bookingId);
        Feedback feedback = feedbackService.getBookingFeedback(bookingId);
        boolean canLeaveFeedback = !feedbackService.hasFeedback(bookingId) &&
            ("CheckedOut".equals(booking.getStatus()) || "Confirmed".equals(booking.getStatus()));

        // Multi-room support
        Booking bookingWithRooms = bookingService.getBookingWithRooms(bookingId);
        var bookingRooms = bookingWithRooms != null ? bookingWithRooms.getBookingRooms() : null;
        boolean isMultiRoom = bookingRooms != null && !bookingRooms.isEmpty();

        // Flash messages
        String successMsg = (String) request.getSession().getAttribute("successMessage");
        String errorMsg = (String) request.getSession().getAttribute("errorMessage");
        request.getSession().removeAttribute("successMessage");
        request.getSession().removeAttribute("errorMessage");

        request.setAttribute("booking", booking);
        request.setAttribute("serviceRequests", serviceRequests);
        request.setAttribute("feedback", feedback);
        request.setAttribute("canLeaveFeedback", canLeaveFeedback);
        request.setAttribute("successMessage", successMsg);
        request.setAttribute("errorMessage", errorMsg);
        request.setAttribute("isMultiRoom", isMultiRoom);
        request.setAttribute("bookingRooms", bookingRooms);
        request.setAttribute("earlySurcharge", booking.getEarlySurcharge());
        request.setAttribute("lateSurcharge", booking.getLateSurcharge());

        request.getRequestDispatcher("/WEB-INF/views/customer/booking-detail.jsp").forward(request, response);
    }

    private void handleServiceRequestPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer bookingId = parseIntParam(request, "bookingId");
        String serviceType = request.getParameter("serviceType");

        if (bookingId == null || serviceType == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);

        if ("Cleaning".equals(serviceType)) {
            var result = serviceRequestService.createCleaningRequest(bookingId, account.getAccountId());
            request.getSession().setAttribute(result.isSuccess() ? "successMessage" : "errorMessage", result.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/customer/booking?id=" + bookingId);
    }

    private void handleCreateRequestPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer bookingId = parseIntParam(request, "bookingId");
        String serviceType = request.getParameter("serviceType");
        String description = request.getParameter("description");
        String priority = request.getParameter("priority");

        if (bookingId == null || serviceType == null || serviceType.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/requests");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);
        var result = serviceRequestService.createRequest(
                bookingId, account.getAccountId(), serviceType, description,
                priority != null && !priority.isEmpty() ? priority : "Normal");

        request.getSession().setAttribute(
                result.isSuccess() ? "successMessage" : "errorMessage", result.getMessage());
        response.sendRedirect(request.getContextPath() + "/customer/requests");
    }

    private void handleFeedbackPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer bookingId = parseIntParam(request, "bookingId");
        Integer rating = parseIntParam(request, "rating");

        if (bookingId == null || rating == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);

        // Dùng Feedback entity thay cho FeedbackRequest
        Feedback feedback = new Feedback();
        feedback.setBookingId(bookingId);
        feedback.setRating(rating);
        feedback.setComment(request.getParameter("comment"));

        var result = feedbackService.submitFeedback(account.getAccountId(), feedback);
        request.getSession().setAttribute(result.isSuccess() ? "successMessage" : "errorMessage", result.getMessage());

        response.sendRedirect(request.getContextPath() + "/customer/booking?id=" + bookingId);
    }

    private void handleCancelBookingPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer bookingId = parseIntParam(request, "bookingId");
        if (bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }
        Account account = SessionHelper.getLoggedInAccount(request);
        var result = bookingService.cancelBooking(bookingId, account.getAccountId());
        request.getSession().setAttribute(result.isSuccess() ? "successMessage" : "errorMessage", result.getMessage());
        response.sendRedirect(request.getContextPath() + "/customer/booking?id=" + bookingId);
    }

    private void handleFeedbackUpdatePost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer feedbackId = parseIntParam(request, "feedbackId");
        Integer bookingId = parseIntParam(request, "bookingId");
        Integer rating = parseIntParam(request, "rating");

        if (feedbackId == null || bookingId == null || rating == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);

        // Dùng Feedback entity thay cho FeedbackRequest
        Feedback newFeedback = new Feedback();
        newFeedback.setBookingId(bookingId);
        newFeedback.setRating(rating);
        newFeedback.setComment(request.getParameter("comment"));

        var result = feedbackService.updateFeedback(feedbackId, account.getAccountId(), newFeedback);
        request.getSession().setAttribute(result.isSuccess() ? "successMessage" : "errorMessage", result.getMessage());
        response.sendRedirect(request.getContextPath() + "/customer/booking?id=" + bookingId);
    }

    private void handleFeedbackDeletePost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer feedbackId = parseIntParam(request, "feedbackId");
        Integer bookingId = parseIntParam(request, "bookingId");

        if (feedbackId == null || bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);
        var result = feedbackService.deleteFeedback(feedbackId, account.getAccountId());
        request.getSession().setAttribute(result.isSuccess() ? "successMessage" : "errorMessage", result.getMessage());
        response.sendRedirect(request.getContextPath() + "/customer/booking?id=" + bookingId);
    }

    private void handleCancelRequestPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Integer requestId = parseIntParam(request, "requestId");
        Integer bookingId = parseIntParam(request, "bookingId");

        if (requestId == null || bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);
        var result = serviceRequestService.cancelRequest(requestId, account.getAccountId());
        request.getSession().setAttribute(result.isSuccess() ? "successMessage" : "errorMessage", result.getMessage());
        response.sendRedirect(request.getContextPath() + "/customer/booking?id=" + bookingId);
    }

    private void handleReviewsGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        List<Booking> bookings = bookingService.getCustomerBookings(account.getAccountId());

        List<Feedback> feedbacks = bookings.stream()
            .map(b -> feedbackService.getBookingFeedback(b.getBookingId()))
            .filter(f -> f != null)
            .toList();

        request.setAttribute("feedbacks", feedbacks);
        request.setAttribute("bookings", bookings);
        request.getRequestDispatcher("/WEB-INF/views/customer/reviews.jsp").forward(request, response);
    }

    private void handleRequestsGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        List<Booking> bookings = bookingService.getCustomerBookings(account.getAccountId());

        // Bookings that are checked-in (eligible for service requests)
        List<Booking> checkedInBookings = bookings.stream()
                .filter(b -> "CheckedIn".equals(b.getStatus()))
                .toList();

        List<ServiceRequest> allRequests = new ArrayList<>();
        for (Booking booking : bookings) {
            List<ServiceRequest> requests = serviceRequestService.getBookingRequests(booking.getBookingId());
            for (ServiceRequest sr : requests) {
                sr.setBooking(booking);
                allRequests.add(sr);
            }
        }
        allRequests.sort((a, b) -> {
            if (a.getRequestTime() == null) return 1;
            if (b.getRequestTime() == null) return -1;
            return b.getRequestTime().compareTo(a.getRequestTime());
        });

        // Flash messages
        String successMsg = (String) request.getSession().getAttribute("successMessage");
        String errorMsg = (String) request.getSession().getAttribute("errorMessage");
        request.getSession().removeAttribute("successMessage");
        request.getSession().removeAttribute("errorMessage");

        request.setAttribute("serviceRequests", allRequests);
        request.setAttribute("checkedInBookings", checkedInBookings);
        request.setAttribute("successMessage", successMsg);
        request.setAttribute("errorMessage", errorMsg);
        request.getRequestDispatcher("/WEB-INF/views/customer/requests.jsp").forward(request, response);
    }

    private Integer parseIntParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value != null && !value.isEmpty()) {
            try { return Integer.parseInt(value); } catch (NumberFormatException e) { return null; }
        }
        return null;
    }
}
