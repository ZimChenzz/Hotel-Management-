package com.mycompany.hotelmanagementsystem.controller.common;

import com.mycompany.hotelmanagementsystem.util.BookingCalcResponse;
import com.mycompany.hotelmanagementsystem.util.MultiRoomCalcResponse;
import com.mycompany.hotelmanagementsystem.util.RoomSelectionItem;
import com.mycompany.hotelmanagementsystem.util.DateHelper;
import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import com.mycompany.hotelmanagementsystem.util.EmailHelper;
import com.mycompany.hotelmanagementsystem.constant.PaymentType;
import com.mycompany.hotelmanagementsystem.service.BookingService;
import com.mycompany.hotelmanagementsystem.service.RoomService;
import com.mycompany.hotelmanagementsystem.dal.RoomRepository;
import com.mycompany.hotelmanagementsystem.entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {
    "/booking/start",         // Step 1: date selection (NEW)
    "/booking/select-rooms",  // Step 2: room type selection (NEW)
    "/booking/confirm",       // Step 3: confirm & pay
    "/booking/create",        // DEPRECATED: redirects to new flow
    "/booking/status",
    "/booking/availability",
    "/booking/cancel"
})
public class BookingController extends HttpServlet {
    private RoomService roomService;
    private BookingService bookingService;
    private RoomRepository roomRepository;

    @Override
    public void init() {
        roomService = new RoomService();
        bookingService = new BookingService();
        roomRepository = new RoomRepository();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/booking/start" -> handleStartGet(request, response);
            case "/booking/select-rooms" -> handleSelectRoomsGet(request, response);
            case "/booking/create" -> handleCreateGet(request, response);
            case "/booking/confirm" -> handleConfirmGet(request, response);
            case "/booking/status" -> handleStatusGet(request, response);
            case "/booking/availability" -> handleAvailabilityApi(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/booking/start" -> handleStartPost(request, response);
            case "/booking/select-rooms" -> handleSelectRoomsPost(request, response);
            case "/booking/create" -> handleCreatePost(request, response);
            case "/booking/confirm" -> handleConfirmPost(request, response);
        }
    }

    private void handleStartGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If dates already in session, skip to step 2
        HttpSession session = request.getSession();
        if (session.getAttribute("bookingCheckIn") != null) {
            response.sendRedirect(request.getContextPath() + "/booking/select-rooms");
            return;
        }
        request.setAttribute("minDate", LocalDate.now());
        request.setAttribute("maxDate", LocalDate.now().plusMonths(6));
        request.getRequestDispatcher("/WEB-INF/views/booking/start.jsp").forward(request, response);
    }

    private void handleStartPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String checkInDate = request.getParameter("checkInDate");
        String checkInTime = request.getParameter("checkInTime");
        String checkOutDate = request.getParameter("checkOutDate");
        String checkOutTime = request.getParameter("checkOutTime");

        if (checkInDate == null || checkOutDate == null || checkInDate.isEmpty() || checkOutDate.isEmpty()) {
            request.setAttribute("error", "Vui long chon ngay nhan va tra phong");
            handleStartGet(request, response);
            return;
        }

        LocalDateTime checkIn = DateHelper.toCheckInTime(
            DateHelper.parseDate(checkInDate), checkInTime);
        LocalDateTime checkOut = DateHelper.toCheckOutTime(
            DateHelper.parseDate(checkOutDate), checkOutTime);

        System.out.println("[DEBUG] handleStartPost - checkInDate: " + checkInDate + ", checkInTime: " + checkInTime);
        System.out.println("[DEBUG] handleStartPost - checkOutDate: " + checkOutDate + ", checkOutTime: " + checkOutTime);
        System.out.println("[DEBUG] handleStartPost - checkIn: " + checkIn);
        System.out.println("[DEBUG] handleStartPost - checkOut: " + checkOut);

        if (checkIn == null || checkOut == null) {
            request.setAttribute("error", "Ngay khong hop le");
            handleStartGet(request, response);
            return;
        }

        if (!checkOut.isAfter(checkIn)) {
            request.setAttribute("error", "Ngay tra phong phai sau ngay nhan phong");
            handleStartGet(request, response);
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        if (checkIn.isBefore(now)) {
            request.setAttribute("error", "Ngay nhan phong khong duoc trong qua khu");
            handleStartGet(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("bookingCheckIn", checkIn);
        session.setAttribute("bookingCheckOut", checkOut);
        response.sendRedirect(request.getContextPath() + "/booking/select-rooms");
    }

    private void handleSelectRoomsGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        LocalDateTime checkIn = (LocalDateTime) session.getAttribute("bookingCheckIn");
        LocalDateTime checkOut = (LocalDateTime) session.getAttribute("bookingCheckOut");

        if (checkIn == null || checkOut == null) {
            response.sendRedirect(request.getContextPath() + "/booking/start");
            return;
        }

        List<RoomType> allTypes = roomService.getAllRoomTypes();
        Map<Integer, Integer> availability = new LinkedHashMap<>();
        for (RoomType rt : allTypes) {
            int count = roomRepository.countAvailableForDates(rt.getTypeId(), checkIn, checkOut);
            availability.put(rt.getTypeId(), count);
        }

        long nights = DateHelper.calculateNights(checkIn, checkOut);
        Integer preSelectedTypeId = parseIntParam(request, "typeId");
        DateTimeFormatter displayFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        request.setAttribute("allRoomTypes", allTypes);
        request.setAttribute("availability", availability);
        request.setAttribute("nights", nights);
        request.setAttribute("checkIn", checkIn);
        request.setAttribute("checkOut", checkOut);
        request.setAttribute("checkInFormatted", checkIn.format(displayFmt));
        request.setAttribute("checkOutFormatted", checkOut.format(displayFmt));
        request.setAttribute("preSelectedTypeId", preSelectedTypeId);
        request.getRequestDispatcher("/WEB-INF/views/booking/select-rooms.jsp").forward(request, response);
    }

    private void handleSelectRoomsPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        LocalDateTime checkIn = (LocalDateTime) session.getAttribute("bookingCheckIn");
        LocalDateTime checkOut = (LocalDateTime) session.getAttribute("bookingCheckOut");
        System.out.println("[DEBUG] handleSelectRoomsPost - checkIn from session: " + checkIn);
        System.out.println("[DEBUG] handleSelectRoomsPost - checkOut from session: " + checkOut);
        Account account = SessionHelper.getLoggedInAccount(request);

        String[] typeIds = request.getParameterValues("typeId");
        String[] quantities = request.getParameterValues("quantity");
        String voucherCode = request.getParameter("voucherCode");

        if (typeIds == null || typeIds.length == 0) {
            request.setAttribute("error", "Vui long chon it nhat 1 phong");
            handleSelectRoomsGet(request, response);
            return;
        }

        List<RoomSelectionItem> selections = new ArrayList<>();
        for (int i = 0; i < typeIds.length; i++) {
            int typeId = Integer.parseInt(typeIds[i]);
            int qty = Integer.parseInt(quantities[i]);
            if (qty > 0) {
                RoomSelectionItem item = new RoomSelectionItem();
                item.setTypeId(typeId);
                item.setQuantity(qty);
                selections.add(item);
            }
        }

        if (selections.isEmpty()) {
            request.setAttribute("error", "Vui long chon it nhat 1 phong");
            handleSelectRoomsGet(request, response);
            return;
        }

        var multiCalc = bookingService.calculateMultiRoomBooking(selections, checkIn, checkOut, voucherCode);
        if (multiCalc == null) {
            request.setAttribute("error", "Khong du phong trong cho yeu cau cua ban");
            handleSelectRoomsGet(request, response);
            return;
        }

        session.setAttribute("pendingMultiBooking", multiCalc);
        session.setAttribute("pendingSelections", selections);
        session.setAttribute("bookingCustomerId", account.getAccountId());
        response.sendRedirect(request.getContextPath() + "/booking/confirm");
    }

    private void handleCreateGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer typeId = parseIntParam(request, "typeId");
        HttpSession session = request.getSession();

        // If dates already in session and typeId provided, go to step 2
        if (session.getAttribute("bookingCheckIn") != null && typeId != null) {
            response.sendRedirect(request.getContextPath() + "/booking/select-rooms?typeId=" + typeId);
            return;
        }

        // Redirect to step 1
        response.sendRedirect(request.getContextPath() + "/booking/start");
    }

    private void handleCreatePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        int typeId = Integer.parseInt(request.getParameter("typeId"));
        LocalDateTime checkIn = DateHelper.toCheckInTime(
            DateHelper.parseDate(request.getParameter("checkIn")),
            request.getParameter("checkInTime"));
        LocalDateTime checkOut = DateHelper.toCheckOutTime(
            DateHelper.parseDate(request.getParameter("checkOut")),
            request.getParameter("checkOutTime"));
        String voucherCode = request.getParameter("voucherCode");

        List<Room> availableRooms = bookingService.getAvailableRooms(typeId, checkIn, checkOut);
        if (availableRooms.isEmpty()) {
            request.setAttribute("error", "Không có phòng trống trong thời gian này");
            handleCreateGet(request, response);
            return;
        }

        // Auto-assign: hệ thống tự chọn phòng trống đầu tiên, customer không được chọn phòng
        Room autoRoom = availableRooms.get(0);
        var calc = bookingService.calculateBooking(typeId, autoRoom.getRoomId(), checkIn, checkOut, voucherCode);

        request.getSession().setAttribute("pendingBooking", calc);
        request.getSession().setAttribute("bookingCustomerId", account.getAccountId());
        response.sendRedirect(request.getContextPath() + "/booking/confirm");
    }

    private void handleConfirmGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Multi-room flow
        MultiRoomCalcResponse multiCalc = (MultiRoomCalcResponse) session.getAttribute("pendingMultiBooking");
        if (multiCalc != null) {
            // Calculate total capacity from all room types
            int totalCapacity = 0;
            if (multiCalc.getRoomCalcs() != null) {
                for (var rc : multiCalc.getRoomCalcs()) {
                    if (rc.getRoomType() != null) {
                        totalCapacity += rc.getRoomType().getCapacity();
                    }
                }
            }

            request.setAttribute("multiBooking", multiCalc);
            request.setAttribute("totalCapacity", totalCapacity);
            request.setAttribute("isMultiRoom", true);
            Account account = SessionHelper.getLoggedInAccount(request);
            if (account != null) {
                request.setAttribute("account", account);
            }
            request.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp").forward(request, response);
            return;
        }

        // Single-room backward compat
        BookingCalcResponse calc = (BookingCalcResponse) session.getAttribute("pendingBooking");
        if (calc == null) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }
        request.setAttribute("booking", calc);
        request.setAttribute("isMultiRoom", false);
        Account account = SessionHelper.getLoggedInAccount(request);
        if (account != null) {
            request.setAttribute("account", account);
        }
        request.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp").forward(request, response);
    }

    private void handleConfirmPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("bookingCustomerId");

        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        // Multi-room flow
        MultiRoomCalcResponse multiCalc = (MultiRoomCalcResponse) session.getAttribute("pendingMultiBooking");
        if (multiCalc != null) {
            List<RoomSelectionItem> selections = (List<RoomSelectionItem>) session.getAttribute("pendingSelections");

            // Parse occupants for multi-room
            List<Occupant> occupants = new ArrayList<>();
            String[] names = request.getParameterValues("occupantName");
            String[] ids = request.getParameterValues("occupantIdCard");
            String[] phones = request.getParameterValues("occupantPhone");
            if (names != null) {
                for (int i = 0; i < names.length; i++) {
                    if (names[i] != null && !names[i].trim().isEmpty()) {
                        Occupant o = new Occupant();
                        o.setFullName(names[i].trim());
                        if (ids != null && i < ids.length) o.setIdCardNumber(ids[i]);
                        if (phones != null && i < phones.length) o.setPhoneNumber(phones[i]);
                        occupants.add(o);
                    }
                }
            }

            String paymentType = request.getParameter("paymentType");
            BigDecimal depositAmount;
            if (PaymentType.DEPOSIT.equals(paymentType) && !multiCalc.isAllStandardRooms()) {
                depositAmount = multiCalc.getDepositAmount();
            } else {
                paymentType = PaymentType.FULL;
                depositAmount = multiCalc.getTotal();
            }

            System.out.println("[DEBUG] handleConfirmPost - creating multi-room booking with checkIn: " + multiCalc.getCheckIn() + ", checkOut: " + multiCalc.getCheckOut());
            var result = bookingService.createMultiRoomBooking(
                customerId, selections, multiCalc.getCheckIn(), multiCalc.getCheckOut(),
                multiCalc.getTotal(), multiCalc.getTotalEarlySurcharge(),
                multiCalc.getTotalLateSurcharge(),
                multiCalc.getVoucher() != null ? multiCalc.getVoucher().getVoucherId() : null,
                request.getParameter("note"), occupants, paymentType, depositAmount);

            session.removeAttribute("pendingMultiBooking");
            session.removeAttribute("pendingSelections");
            session.removeAttribute("bookingCustomerId");
            session.removeAttribute("bookingCheckIn");
            session.removeAttribute("bookingCheckOut");

            if (!result.isSuccess()) {
                request.setAttribute("error", result.getMessage());
                request.setAttribute("multiBooking", multiCalc);
                request.setAttribute("isMultiRoom", true);
                request.setAttribute("account", SessionHelper.getLoggedInAccount(request));
                request.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp").forward(request, response);
                return;
            }

            int bookingId = result.getBooking().getBookingId();
            if (multiCalc.isAllStandardRooms()) {
                bookingService.updateBookingStatus(bookingId, "Confirmed");
                // Send confirmation email for standard rooms
                sendBookingConfirmationEmail(result.getBooking(), multiCalc, null);
                response.sendRedirect(request.getContextPath() + "/booking/status?bookingId=" + bookingId);
            } else {
                response.sendRedirect(request.getContextPath() + "/payment/process?bookingId=" + bookingId);
            }
            return;
        }

        // Single-room path (existing code, keep unchanged)
        BookingCalcResponse calc = (BookingCalcResponse) session.getAttribute("pendingBooking");
        if (calc == null) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        String[] names = request.getParameterValues("occupantName");
        String[] ids = request.getParameterValues("occupantIdCard");
        String[] phones = request.getParameterValues("occupantPhone");

        List<Occupant> occupants = new ArrayList<>();
        if (names != null) {
            for (int i = 0; i < names.length; i++) {
                Occupant occ = new Occupant();
                occ.setFullName(names[i]);
                if (ids != null && i < ids.length) occ.setIdCardNumber(ids[i]);
                if (phones != null && i < phones.length) occ.setPhoneNumber(phones[i]);
                occupants.add(occ);
            }
        }

        // Validate: số khách không được vượt quá sức chứa của loại phòng
        int maxCapacity = calc.getRoomType().getCapacity();
        if (occupants.size() > maxCapacity) {
            request.setAttribute("error", "Số lượng khách (" + occupants.size()
                + ") vượt quá sức chứa tối đa của phòng (" + maxCapacity + " người).");
            request.setAttribute("booking", calc);
            request.setAttribute("account", SessionHelper.getLoggedInAccount(request));
            request.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp").forward(request, response);
            return;
        }

        Integer voucherId = calc.getVoucher() != null ? calc.getVoucher().getVoucherId() : null;

        // Get payment type choice from form
        String paymentType = request.getParameter("paymentType");
        BigDecimal depositAmount;
        if (PaymentType.DEPOSIT.equals(paymentType) && !calc.isStandardRoom()) {
            depositAmount = calc.getDepositAmount();
        } else {
            paymentType = PaymentType.FULL;
            depositAmount = calc.getTotal();
        }

        var result = bookingService.createBooking(customerId, calc.getRoom().getRoomId(),
            calc.getCheckIn(), calc.getCheckOut(), calc.getTotal(), voucherId,
            request.getParameter("note"), occupants, paymentType, depositAmount);

        session.removeAttribute("pendingBooking");
        session.removeAttribute("bookingCustomerId");

        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("booking", calc);
            request.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp").forward(request, response);
            return;
        }

        int newBookingId = result.getBooking().getBookingId();

        // Standard room with no deposit: skip payment, go to booking status
        if (calc.isStandardRoom()) {
            // Auto-confirm since no payment needed (will auto-cancel if not verified in 6h)
            bookingService.updateBookingStatus(newBookingId, "Confirmed");
            // Send confirmation email for standard room
            Booking confirmedBooking = bookingService.getBookingById(newBookingId);
            Account account = SessionHelper.getLoggedInAccount(request);
            sendSingleRoomConfirmationEmail(confirmedBooking, calc, account);
            response.sendRedirect(request.getContextPath() + "/booking/status?bookingId=" + newBookingId);
        } else {
            response.sendRedirect(request.getContextPath() + "/payment/process?bookingId=" + newBookingId);
        }
    }

    private void handleStatusGet(HttpServletRequest request, HttpServletResponse response)
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

        // Load booking rooms if available (multi-room)
        Booking bookingWithRooms = bookingService.getBookingWithRooms(bookingId);
        var bookingRooms = bookingWithRooms != null ? bookingWithRooms.getBookingRooms() : null;

        var occupants = bookingService.getBookingOccupants(bookingId);
        request.setAttribute("booking", booking);
        request.setAttribute("occupants", occupants);
        request.setAttribute("isMultiRoom", bookingRooms != null && !bookingRooms.isEmpty());
        request.setAttribute("bookingRooms", bookingRooms);
        request.setAttribute("earlySurcharge", booking.getEarlySurcharge());
        request.setAttribute("lateSurcharge", booking.getLateSurcharge());
        request.getRequestDispatcher("/WEB-INF/views/booking/status.jsp").forward(request, response);
    }

    /**
     * API endpoint trả về JSON danh sách ngày bận theo loại phòng.
     * Dùng cho calendar trên trang đặt phòng của customer.
     * GET /booking/availability?typeId=1
     * Response: [{"start":"2026-03-20","end":"2026-03-22"}, ...]
     */
    private void handleAvailabilityApi(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        Integer typeId = parseIntParam(request, "typeId");
        if (typeId == null) {
            out.print("[]");
            return;
        }

        List<LocalDateTime[]> ranges = bookingService.getOccupiedDateRanges(typeId);
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < ranges.size(); i++) {
            LocalDateTime[] range = ranges.get(i);
            if (range[0] == null || range[1] == null) continue;
            if (i > 0) json.append(",");
            json.append("{\"start\":\"").append(range[0].toLocalDate().format(fmt)).append("\"")
                .append(",\"end\":\"").append(range[1].toLocalDate().format(fmt)).append("\"}");
        }
        json.append("]");
        out.print(json.toString());
    }

    private Integer parseIntParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value != null && !value.isEmpty()) {
            try { return Integer.parseInt(value); } catch (NumberFormatException e) { return null; }
        }
        return null;
    }

    private void sendBookingConfirmationEmail(Booking booking, MultiRoomCalcResponse multiCalc, Account account) {
        try {
            if (account == null || account.getEmail() == null || account.getEmail().isEmpty()) {
                System.out.println("Cannot send booking email: no account or email");
                return;
            }

            List<String> roomDetails = new ArrayList<>();
            for (var rc : multiCalc.getRoomCalcs()) {
                String detail = String.format("%s - %d dem - %s",
                    rc.getRoomType().getTypeName(),
                    multiCalc.getNights(),
                    formatCurrency(rc.getSubtotal()));
                roomDetails.add(detail);
            }

            String checkInFormatted = multiCalc.getCheckIn() != null
                ? multiCalc.getCheckIn().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";
            String checkOutFormatted = multiCalc.getCheckOut() != null
                ? multiCalc.getCheckOut().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";

            String paymentStatus = "Da thanh toan";
            if (!"Confirmed".equals(booking.getStatus())) {
                paymentStatus = booking.getDepositAmount() != null && booking.getDepositAmount().compareTo(BigDecimal.ZERO) > 0
                    ? "Dat coc " + formatCurrency(booking.getDepositAmount())
                    : "Cho thanh toan";
            }

            EmailHelper.sendBookingConfirmation(
                account.getEmail(),
                booking.getBookingId(),
                account.getFullName(),
                checkInFormatted,
                checkOutFormatted,
                roomDetails,
                multiCalc.getTotal(),
                booking.getDepositAmount(),
                paymentStatus,
                multiCalc.getTotalEarlySurcharge(),
                multiCalc.getTotalLateSurcharge(),
                multiCalc.getTotalPromotionDiscount(),
                multiCalc.getVoucherDiscount()
            );
        } catch (Exception e) {
            System.out.println("Failed to send booking confirmation email: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void sendSingleRoomConfirmationEmail(Booking booking, BookingCalcResponse calc, Account account) {
        try {
            if (account == null || account.getEmail() == null || account.getEmail().isEmpty()) {
                System.out.println("Cannot send booking email: no account or email");
                return;
            }

            List<String> roomDetails = new ArrayList<>();
            String detail = String.format("%s - %d dem - %s",
                calc.getRoomType().getTypeName(),
                calc.getNights(),
                formatCurrency(calc.getSubtotal()));
            roomDetails.add(detail);

            String checkInFormatted = calc.getCheckIn() != null
                ? calc.getCheckIn().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";
            String checkOutFormatted = calc.getCheckOut() != null
                ? calc.getCheckOut().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";

            String paymentStatus = "Da thanh toan";

            EmailHelper.sendBookingConfirmation(
                account.getEmail(),
                booking.getBookingId(),
                account.getFullName(),
                checkInFormatted,
                checkOutFormatted,
                roomDetails,
                calc.getTotal(),
                booking.getDepositAmount(),
                paymentStatus,
                calc.getEarlySurcharge(),
                calc.getLateSurcharge(),
                calc.getPromotionDiscount(),
                calc.getDiscount()
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
}
