package com.mycompany.hotelmanagementsystem.controller.common;

import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import com.mycompany.hotelmanagementsystem.util.EmailHelper;
import com.mycompany.hotelmanagementsystem.service.BookingService;
import com.mycompany.hotelmanagementsystem.service.PaymentService;
import com.mycompany.hotelmanagementsystem.entity.*;
import com.mycompany.hotelmanagementsystem.service.VNPayService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/payment/process", "/payment/vnpay", "/payment/vnpay-return", "/payment/result"})
public class PaymentController extends HttpServlet {
    private PaymentService paymentService;
    private BookingService bookingService;

    @Override
    public void init() {
        paymentService = new PaymentService();
        bookingService = new BookingService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/payment/process" -> handleProcessGet(request, response);
            case "/payment/vnpay-return" -> handleVNPayReturn(request, response);
            case "/payment/result" -> handleResult(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/payment/vnpay" -> handleVNPayPost(request, response);
        }
    }

    private void handleProcessGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer bookingId = parseIntParam(request, "bookingId");
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

        // Check invoice type: Booking (default), Extension, Remaining
        String invoiceType = request.getParameter("invoiceType");
        Integer invoiceId = parseIntParam(request, "invoiceId");
        Invoice invoice;

        if (invoiceId != null) {
            // Direct invoice ID provided (e.g., from staff or extension flow)
            invoice = paymentService.getInvoice(invoiceId);
        } else if ("Extension".equals(invoiceType)) {
            // Find the latest unpaid extension invoice for this booking
            invoice = paymentService.findLatestInvoiceByType(bookingId, "Extension");
        } else if ("Remaining".equals(invoiceType)) {
            // Find the remaining balance invoice for checkout
            invoice = paymentService.findLatestInvoiceByType(bookingId, "Remaining");
        } else {
            // Default booking invoice
            if ("Confirmed".equals(booking.getStatus()) && !"Deposit".equals(booking.getPaymentType())) {
                response.sendRedirect(request.getContextPath() + "/booking/status?bookingId=" + bookingId);
                return;
            }
            invoice = paymentService.getOrCreateInvoice(bookingId);
        }

        if (invoice == null) {
            response.sendRedirect(request.getContextPath() + "/booking/status?bookingId=" + bookingId + "&error=invoice");
            return;
        }

        request.setAttribute("booking", booking);
        request.setAttribute("invoice", invoice);
        request.getRequestDispatcher("/WEB-INF/views/payment/process.jsp").forward(request, response);
    }

    private void handleVNPayPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Integer invoiceId = parseIntParam(request, "invoiceId");
            if (invoiceId == null) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings");
                return;
            }

            Account account = SessionHelper.getLoggedInAccount(request);
            if (account == null) {
                response.sendRedirect(request.getContextPath() + "/auth/login");
                return;
            }

            String baseUrl = request.getScheme() + "://" + request.getServerName() + ":"
                           + request.getServerPort() + request.getContextPath();
            String ipAddress = VNPayService.getIpAddress(request);

            var result = paymentService.initiateVNPayPayment(invoiceId, account.getAccountId(), baseUrl, ipAddress);

            if (!result.isSuccess()) {
                Invoice invoice = paymentService.getInvoice(invoiceId);
                request.getSession().setAttribute("paymentError", result.getMessage());
                response.sendRedirect(request.getContextPath() + "/payment/process?bookingId=" +
                    (invoice != null ? invoice.getBookingId() : ""));
                return;
            }

            // Store txnRef in session for verification
            request.getSession().setAttribute("pendingPaymentTxn", result.getPayment().getTransactionCode());

            // Redirect to VNPay
            response.sendRedirect(result.getPaymentUrl());
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("paymentError", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
        }
    }

    private void handleVNPayReturn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // Extract all VNPay parameters
        Map<String, String> params = new HashMap<>();
        request.getParameterMap().forEach((key, values) -> {
            if (values != null && values.length > 0) {
                params.put(key, values[0]);
            }
        });

        // Verify signature
        if (!VNPayService.verifySignature(params)) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=invalid_signature");
            return;
        }

        String txnRef = params.get("vnp_TxnRef");
        String responseCode = params.get("vnp_ResponseCode");

        // Verify session
        String sessionTxn = (String) request.getSession().getAttribute("pendingPaymentTxn");
        if (sessionTxn == null || !sessionTxn.equals(txnRef)) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=session_mismatch");
            return;
        }

        request.getSession().removeAttribute("pendingPaymentTxn");

        // Process callback
        paymentService.processVNPayCallback(txnRef, responseCode);

        response.sendRedirect(request.getContextPath() + "/payment/result?txnCode=" + txnRef);
    }

    private void handleResult(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String txnCode = request.getParameter("txnCode");
        if (txnCode == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Payment payment = paymentService.getPaymentByTransaction(txnCode);
        if (payment == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        Booking booking = paymentService.getBookingFromPayment(payment);

        request.setAttribute("payment", payment);
        request.setAttribute("booking", booking);

        // Send confirmation email after successful payment
        if ("Success".equals(payment.getStatus()) && booking != null) {
            sendBookingConfirmationEmail(booking);
        }

        String viewPath = "Success".equals(payment.getStatus())
            ? "/WEB-INF/views/payment/success.jsp"
            : "/WEB-INF/views/payment/failed.jsp";

        request.getRequestDispatcher(viewPath).forward(request, response);
    }

    private void sendBookingConfirmationEmail(Booking booking) {
        try {
            // Get customer account for email
            Account account = null;
            com.mycompany.hotelmanagementsystem.dal.AccountRepository accountRepo = new com.mycompany.hotelmanagementsystem.dal.AccountRepository();
            if (booking.getCustomerId() > 0) {
                account = accountRepo.findById(booking.getCustomerId());
            }

            if (account == null || account.getEmail() == null || account.getEmail().isEmpty()) {
                System.out.println("Cannot send booking email: no account or email");
                return;
            }

            // Get booking rooms for multi-room info
            Booking bookingWithRooms = bookingService.getBookingWithRooms(booking.getBookingId());
            List<String> roomDetails = new ArrayList<>();
            BigDecimal totalSurcharge = BigDecimal.ZERO;
            BigDecimal totalPromotion = BigDecimal.ZERO;

            if (bookingWithRooms != null && bookingWithRooms.getBookingRooms() != null && !bookingWithRooms.getBookingRooms().isEmpty()) {
                // Multi-room booking
                for (var br : bookingWithRooms.getBookingRooms()) {
                    String detail = br.getRoomType() != null
                        ? br.getRoomType().getTypeName()
                        : "Phong #" + br.getBookingRoomId();
                    if (br.getUnitPrice() != null) {
                        detail += " - " + formatCurrency(br.getUnitPrice());
                    }
                    roomDetails.add(detail);

                    if (br.getEarlySurcharge() != null) totalSurcharge = totalSurcharge.add(br.getEarlySurcharge());
                    if (br.getLateSurcharge() != null) totalSurcharge = totalSurcharge.add(br.getLateSurcharge());
                    if (br.getPromotionDiscount() != null) totalPromotion = totalPromotion.add(br.getPromotionDiscount());
                }
            } else {
                // Single-room booking
                String detail = booking.getRoom() != null && booking.getRoom().getRoomType() != null
                    ? booking.getRoom().getRoomType().getTypeName()
                    : "Phong";
                if (booking.getTotalPrice() != null) {
                    detail += " - " + formatCurrency(booking.getTotalPrice());
                }
                roomDetails.add(detail);
            }

            String checkInFormatted = booking.getCheckInExpected() != null
                ? booking.getCheckInExpected().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";
            String checkOutFormatted = booking.getCheckOutExpected() != null
                ? booking.getCheckOutExpected().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";

            EmailHelper.sendBookingConfirmation(
                account.getEmail(),
                booking.getBookingId(),
                account.getFullName(),
                checkInFormatted,
                checkOutFormatted,
                roomDetails,
                booking.getTotalPrice() != null ? booking.getTotalPrice() : BigDecimal.ZERO,
                booking.getDepositAmount(),
                "Da thanh toan",
                booking.getEarlySurcharge() != null ? booking.getEarlySurcharge() : BigDecimal.ZERO,
                booking.getLateSurcharge() != null ? booking.getLateSurcharge() : BigDecimal.ZERO,
                totalPromotion,
                null // voucher discount not stored on booking
            );
        } catch (Exception e) {
            System.out.println("Failed to send booking confirmation email: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private String formatCurrency(BigDecimal amount) {
        if (amount == null) return "0d";
        return String.format("%,.0fd", amount);
    }

    private Integer parseIntParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value != null && !value.isEmpty()) {
            try { return Integer.parseInt(value); } catch (NumberFormatException e) { return null; }
        }
        return null;
    }
}
