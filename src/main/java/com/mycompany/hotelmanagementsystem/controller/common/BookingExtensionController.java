package com.mycompany.hotelmanagementsystem.controller.common;

import com.mycompany.hotelmanagementsystem.util.ExtensionCalcResponse;
import com.mycompany.hotelmanagementsystem.util.ServiceResult;
import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import com.mycompany.hotelmanagementsystem.service.BookingExtensionService;
import com.mycompany.hotelmanagementsystem.service.BookingService;
import com.mycompany.hotelmanagementsystem.entity.*;
import com.mycompany.hotelmanagementsystem.dal.BookingRoomRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/booking/extend", "/booking/extend/confirm"})
public class BookingExtensionController extends HttpServlet {
    private BookingExtensionService extensionService;
    private BookingService bookingService;

    @Override
    public void init() {
        extensionService = new BookingExtensionService();
        bookingService = new BookingService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/booking/extend" -> handleExtendGet(request, response);
            case "/booking/extend/confirm" -> handleConfirmGet(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/booking/extend" -> handleExtendPost(request, response);
            case "/booking/extend/confirm" -> handleConfirmPost(request, response);
        }
    }

    // GET: Show extension form
    private void handleExtendGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer bookingId = parseIntParam(request, "bookingId");
        Integer bookingRoomId = parseIntParam(request, "bookingRoomId");

        // Per-room extension flow
        if (bookingRoomId != null) {
            BookingRoomRepository brRepo = new BookingRoomRepository();
            BookingRoom br = brRepo.findById(bookingRoomId);
            if (br == null) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings");
                return;
            }

            Account account = SessionHelper.getLoggedInAccount(request);
            Booking booking = bookingService.getBookingById(br.getBookingId());
            if (booking == null || booking.getCustomerId() != account.getAccountId()) {
                response.sendError(403);
                return;
            }

            ServiceResult canExtend = extensionService.canExtendRoom(bookingRoomId);
            request.setAttribute("bookingRoomId", bookingRoomId);
            request.setAttribute("bookingRoom", br);
            request.setAttribute("booking", booking);
            var extensions = extensionService.getExtensionsByBookingRoom(bookingRoomId);
            request.setAttribute("extensions", extensions);
            request.setAttribute("canExtend", canExtend.isSuccess());
            request.setAttribute("canExtendMessage", canExtend.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/booking/extend.jsp").forward(request, response);
            return;
        }

        // Booking-level extension flow
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

        // Check if extension is possible
        ServiceResult canExtend = extensionService.canExtend(bookingId);
        request.setAttribute("booking", booking);
        request.setAttribute("canExtend", canExtend.isSuccess());
        request.setAttribute("canExtendMessage", canExtend.getMessage());

        // Get extension history
        var extensions = extensionService.getExtensionsByBooking(bookingId);
        request.setAttribute("extensions", extensions);

        request.getRequestDispatcher("/WEB-INF/views/booking/extend.jsp").forward(request, response);
    }

    // POST: Calculate extension and show confirmation
    private void handleExtendPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer bookingId = parseIntParam(request, "bookingId");
        Integer bookingRoomId = parseIntParam(request, "bookingRoomId");
        String extraHoursStr = request.getParameter("extraHours");

        // Per-room extension flow
        if (bookingRoomId != null) {
            if (extraHoursStr == null) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings");
                return;
            }

            BookingRoomRepository brRepo = new BookingRoomRepository();
            BookingRoom br = brRepo.findById(bookingRoomId);
            if (br == null) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings");
                return;
            }

            Account account = SessionHelper.getLoggedInAccount(request);
            Booking booking = bookingService.getBookingById(br.getBookingId());
            if (booking == null || booking.getCustomerId() != account.getAccountId()) {
                response.sendError(403);
                return;
            }

            try {
                int extraHours = Integer.parseInt(extraHoursStr);
                if (extraHours <= 0 || extraHours > 720) {
                    request.setAttribute("error", "So gio gia han khong hop le (1-720)");
                    handleExtendGet(request, response);
                    return;
                }

                ExtensionCalcResponse calc = extensionService.calculateRoomExtension(bookingRoomId, extraHours);
                if (calc == null) {
                    request.setAttribute("error", "Khong the tinh gia gia han");
                    handleExtendGet(request, response);
                    return;
                }

                request.getSession().setAttribute("pendingExtension", calc);
                request.getSession().setAttribute("extensionBookingRoomId", bookingRoomId);
                response.sendRedirect(request.getContextPath() + "/booking/extend/confirm");
            } catch (NumberFormatException e) {
                request.setAttribute("error", "So gio khong hop le");
                handleExtendGet(request, response);
            }
            return;
        }

        // Booking-level extension flow
        if (bookingId == null || extraHoursStr == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);
        Booking booking = bookingService.getBookingById(bookingId);
        if (booking == null || booking.getCustomerId() != account.getAccountId()) {
            response.sendError(403);
            return;
        }

        try {
            int extraHours = Integer.parseInt(extraHoursStr);
            if (extraHours <= 0 || extraHours > 720) {
                request.setAttribute("error", "Số giờ gia hạn không hợp lệ (1-720)");
                handleExtendGet(request, response);
                return;
            }

            ExtensionCalcResponse calc = extensionService.calculateExtension(bookingId, extraHours);
            if (calc == null) {
                request.setAttribute("error", "Không thể tính giá gia hạn");
                handleExtendGet(request, response);
                return;
            }

            // Store in session for confirmation
            request.getSession().setAttribute("pendingExtension", calc);
            request.getSession().setAttribute("extensionBookingId", bookingId);
            response.sendRedirect(request.getContextPath() + "/booking/extend/confirm");
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Số giờ không hợp lệ");
            handleExtendGet(request, response);
        }
    }

    // GET: Show extension confirmation page
    private void handleConfirmGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ExtensionCalcResponse calc = (ExtensionCalcResponse) request.getSession().getAttribute("pendingExtension");
        Integer bookingId = (Integer) request.getSession().getAttribute("extensionBookingId");
        if (calc == null || bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Booking booking = bookingService.getBookingById(bookingId);
        request.setAttribute("booking", booking);
        request.setAttribute("extensionCalc", calc);
        request.getRequestDispatcher("/WEB-INF/views/booking/extend-confirm.jsp").forward(request, response);
    }

    // POST: Create extension and redirect to payment
    private void handleConfirmPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        ExtensionCalcResponse calc = (ExtensionCalcResponse) session.getAttribute("pendingExtension");
        Integer bookingRoomId = (Integer) session.getAttribute("extensionBookingRoomId");

        // Per-room extension flow
        if (bookingRoomId != null && calc != null) {
            session.removeAttribute("pendingExtension");
            session.removeAttribute("extensionBookingRoomId");

            ServiceResult result = extensionService.requestRoomExtension(bookingRoomId, calc.getExtraHours());
            if (!result.isSuccess()) {
                request.setAttribute("error", result.getMessage());
                handleConfirmGet(request, response);
                return;
            }

            // Parse extensionId and invoiceId from result message (format: "extensionId,invoiceId")
            String[] ids = result.getMessage().split(",");
            if (ids.length < 2) {
                request.setAttribute("error", "Loi tao hoa don gia han. Vui long thu lai.");
                handleConfirmGet(request, response);
                return;
            }

            BookingRoomRepository brRepo = new BookingRoomRepository();
            BookingRoom br = brRepo.findById(bookingRoomId);
            int invoiceId;
            try {
                invoiceId = Integer.parseInt(ids[1].trim());
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Loi xu ly hoa don gia han.");
                handleConfirmGet(request, response);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/payment/process?bookingId=" + br.getBookingId()
                    + "&invoiceId=" + invoiceId);
            return;
        }

        // Booking-level extension flow
        Integer bookingId = (Integer) session.getAttribute("extensionBookingId");
        if (calc == null || bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        session.removeAttribute("pendingExtension");
        session.removeAttribute("extensionBookingId");

        ServiceResult result = extensionService.requestExtension(bookingId, calc.getExtraHours());
        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            Booking booking = bookingService.getBookingById(bookingId);
            request.setAttribute("booking", booking);
            request.setAttribute("extensionCalc", calc);
            request.getRequestDispatcher("/WEB-INF/views/booking/extend-confirm.jsp").forward(request, response);
            return;
        }

        // Parse extensionId and invoiceId from result message (format: "extensionId,invoiceId")
        String[] ids = result.getMessage().split(",");
        if (ids.length < 2) {
            request.setAttribute("error", "Lỗi tạo hóa đơn gia hạn. Vui lòng thử lại.");
            Booking booking = bookingService.getBookingById(bookingId);
            request.setAttribute("booking", booking);
            request.setAttribute("extensionCalc", calc);
            request.getRequestDispatcher("/WEB-INF/views/booking/extend-confirm.jsp").forward(request, response);
            return;
        }
        int invoiceId;
        try {
            invoiceId = Integer.parseInt(ids[1].trim());
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Lỗi xử lý hóa đơn gia hạn.");
            Booking booking = bookingService.getBookingById(bookingId);
            request.setAttribute("booking", booking);
            request.setAttribute("extensionCalc", calc);
            request.getRequestDispatcher("/WEB-INF/views/booking/extend-confirm.jsp").forward(request, response);
            return;
        }

        // Redirect to payment with specific invoiceId
        response.sendRedirect(request.getContextPath() + "/payment/process?bookingId=" + bookingId
                + "&invoiceId=" + invoiceId);
    }

    private Integer parseIntParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value != null && !value.isEmpty()) {
            try { return Integer.parseInt(value); } catch (NumberFormatException e) { return null; }
        }
        return null;
    }
}
