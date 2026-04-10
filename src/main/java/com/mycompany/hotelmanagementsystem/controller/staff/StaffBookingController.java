package com.mycompany.hotelmanagementsystem.controller.staff;

import com.mycompany.hotelmanagementsystem.service.StaffBookingService;
import com.mycompany.hotelmanagementsystem.service.BookingService;
import com.mycompany.hotelmanagementsystem.service.RoomSuggestionService;
import com.mycompany.hotelmanagementsystem.constant.PaymentType;
import com.mycompany.hotelmanagementsystem.entity.Booking;
import com.mycompany.hotelmanagementsystem.entity.Occupant;
import com.mycompany.hotelmanagementsystem.entity.BookingExtension;
import com.mycompany.hotelmanagementsystem.entity.BookingRoom;
import com.mycompany.hotelmanagementsystem.entity.Room;
import com.mycompany.hotelmanagementsystem.entity.RoomType;
import com.mycompany.hotelmanagementsystem.entity.RoomSuggestionItem;
import com.mycompany.hotelmanagementsystem.entity.UnassignedRoomInfo;
import com.mycompany.hotelmanagementsystem.dal.BookingRoomRepository;
import com.mycompany.hotelmanagementsystem.dal.RoomRepository;
import com.mycompany.hotelmanagementsystem.util.BookingCalcResponse;
import com.mycompany.hotelmanagementsystem.util.BookingResult;
import com.mycompany.hotelmanagementsystem.util.WalkInCustomerResult;
import com.mycompany.hotelmanagementsystem.util.EmailHelper;
import com.mycompany.hotelmanagementsystem.util.RoomSelectionItem;
import com.mycompany.hotelmanagementsystem.util.MultiRoomCalcResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {
    "/staff/bookings",
    "/staff/bookings/detail",
    "/staff/bookings/assign",
    "/staff/bookings/assign-room",
    "/staff/bookings/checkout-room",
    "/staff/bookings/complete-checkout",
    "/staff/bookings/complete-multi-checkout",
    "/staff/bookings/checkout-all",
    "/staff/bookings/suggest-rooms",
    "/staff/bookings/bulk-assign",
    "/staff/bookings/occupants",
    "/staff/bookings/checkout",
    "/staff/bookings/walkin",
    "/staff/bookings/walkin-room",
    "/staff/bookings/walkin-multi",
    "/staff/bookings/walkin-confirm"
})
public class StaffBookingController extends HttpServlet {
    private StaffBookingService staffBookingService;
    private BookingService bookingService;
    private RoomRepository roomRepository;

    @Override
    public void init() {
        staffBookingService = new StaffBookingService();
        bookingService = new BookingService();
        roomRepository = new RoomRepository();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/staff/bookings" -> handleBookingList(request, response);
            case "/staff/bookings/detail" -> handleBookingDetail(request, response);
            case "/staff/bookings/assign" -> handleAssignRoomGet(request, response);
            case "/staff/bookings/assign-room" -> handleAssignRoomGet(request, response);
            case "/staff/bookings/occupants" -> handleOccupantsGet(request, response);
            case "/staff/bookings/checkout" -> handleCheckoutGet(request, response);
            case "/staff/bookings/checkout-room" -> handleCheckoutBookingRoom(request, response);
            case "/staff/bookings/complete-checkout" -> handleCompleteCheckout(request, response);
            case "/staff/bookings/complete-multi-checkout" -> handleCompleteMultiCheckout(request, response);
            case "/staff/bookings/walkin" -> handleWalkInStep1Get(request, response);
            case "/staff/bookings/walkin-room" -> handleWalkInStep2Get(request, response);
            case "/staff/bookings/walkin-multi" -> handleWalkInMultiGet(request, response);
            case "/staff/bookings/walkin-confirm" -> handleWalkInStep3Get(request, response);
            case "/staff/bookings/suggest-rooms" -> handleSuggestRooms(request, response);
            default -> response.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/staff/bookings/assign" -> handleAssignRoomPost(request, response);
            case "/staff/bookings/assign-room" -> handleAssignBookingRoom(request, response);
            case "/staff/bookings/checkout-room" -> handleCheckoutBookingRoom(request, response);
            case "/staff/bookings/bulk-assign" -> handleBulkAssign(request, response);
            case "/staff/bookings/occupants" -> handleOccupantsPost(request, response);
            case "/staff/bookings/checkout" -> handleCheckoutPost(request, response);
            case "/staff/bookings/checkout-all" -> handleCheckoutAll(request, response);
            case "/staff/bookings/walkin" -> handleWalkInStep1Post(request, response);
            case "/staff/bookings/walkin-room" -> handleWalkInStep2Post(request, response);
            case "/staff/bookings/walkin-multi" -> handleWalkInMultiPost(request, response);
            case "/staff/bookings/walkin-confirm" -> handleWalkInStep3Post(request, response);
            default -> response.sendError(404);
        }
    }

    private void handleBookingList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        List<Booking> bookings;

        if (status != null && !status.isEmpty()) {
            bookings = staffBookingService.getBookingsByStatus(status);
            request.setAttribute("filterStatus", status);
        } else {
            bookings = staffBookingService.getActiveBookings();
        }

        // Load BookingRoom info for multi-room detection
        BookingRoomRepository brRepo = new BookingRoomRepository();
        Map<Integer, List<BookingRoom>> bookingRoomsMap = new HashMap<>();
        for (Booking booking : bookings) {
            List<BookingRoom> brs = brRepo.findByBookingId(booking.getBookingId());
            if (!brs.isEmpty()) {
                bookingRoomsMap.put(booking.getBookingId(), brs);
            }
        }

        request.setAttribute("bookings", bookings);
        request.setAttribute("bookingRoomsMap", bookingRoomsMap);
        request.setAttribute("activePage", "bookings");
        request.setAttribute("pageTitle", "Danh sách đặt phòng");
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/list.jsp").forward(request, response);
    }

    private void handleBookingDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "id");
        if (bookingId <= 0) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings");
            return;
        }

        Booking booking = staffBookingService.getBookingDetail(bookingId);
        if (booking == null) {
            response.sendError(404, "Booking not found");
            return;
        }

        List<Occupant> occupants = staffBookingService.getOccupants(bookingId);
        List<BookingExtension> extensions = staffBookingService.getExtensions(bookingId);

        // Load booking rooms for multi-room support
        Booking bookingWithRooms = staffBookingService.getBookingDetailWithRooms(bookingId);
        var bookingRooms = bookingWithRooms != null ? bookingWithRooms.getBookingRooms() : null;
        boolean isMultiRoom = bookingRooms != null && !bookingRooms.isEmpty();

        // Room suggestions for unassigned rooms
        Map<Integer, List<RoomSuggestionItem>> suggestionsByType = Collections.emptyMap();
        boolean hasUnassignedRooms = false;
        if (isMultiRoom) {
            hasUnassignedRooms = bookingRooms.stream().anyMatch(br -> br.getRoomId() == null);
            if (hasUnassignedRooms) {
                RoomSuggestionService suggestionService = new RoomSuggestionService();
                Map<Integer, Integer> needs = new LinkedHashMap<>();
                for (var br : bookingRooms) {
                    if (br.getRoomId() == null) {
                        needs.merge(br.getTypeId(), 1, Integer::sum);
                    }
                }
                Map<Integer, List<Room>> rawSuggestions = suggestionService.suggestNearbyRooms(
                    needs, booking.getCheckInExpected(), booking.getCheckOutExpected());

                // Convert Map<Integer, List<Room>> to Map<Integer, List<RoomSuggestionItem>>
                suggestionsByType = new LinkedHashMap<>();
                for (var entry : rawSuggestions.entrySet()) {
                    int typeId = entry.getKey();
                    List<RoomSuggestionItem> items = new ArrayList<>();
                    for (Room room : entry.getValue()) {
                        // Find corresponding BookingRoom for this type
                        for (var br : bookingRooms) {
                            if (br.getTypeId() == typeId && br.getRoomId() == null) {
                                items.add(new RoomSuggestionItem(
                                    br.getBookingRoomId(),
                                    room.getRoomId(),
                                    room.getRoomType() != null ? room.getRoomType().getTypeName() : "",
                                    room.getRoomNumber()
                                ));
                                break;
                            }
                        }
                    }
                    suggestionsByType.put(typeId, items);
                }
            }
        }

        // Handle success messages from checkout redirect
        if ("checkedout".equals(request.getParameter("success"))) {
            request.setAttribute("success", "Check-out thanh cong!");
        }

        // Check if payment is needed at checkout (for display in detail)
        boolean needsCheckoutPayment = staffBookingService.needsCheckoutPayment(bookingId);
        request.setAttribute("needsCheckoutPayment", needsCheckoutPayment);
        if (needsCheckoutPayment) {
            request.setAttribute("checkoutPaymentAmount", staffBookingService.getCheckoutPaymentAmount(bookingId));
        }

        // Get actual surcharge for display
        request.setAttribute("surcharge", staffBookingService.getActualSurcharge(bookingId));

        request.setAttribute("booking", booking);
        request.setAttribute("occupants", occupants);
        request.setAttribute("extensions", extensions);
        request.setAttribute("isMultiRoom", isMultiRoom);
        request.setAttribute("bookingRooms", bookingRooms);
        request.setAttribute("hasUnassignedRooms", hasUnassignedRooms);
        request.setAttribute("suggestionsByType", suggestionsByType);
        request.setAttribute("activePage", "bookings");
        request.setAttribute("pageTitle", "Chi tiết booking #" + bookingId);
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/detail.jsp").forward(request, response);
    }

    // UC-19.1: Assign Room (Multi-room optimized)
    private void handleAssignRoomGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        if (bookingId <= 0) {
            response.sendError(400, "Invalid booking ID");
            return;
        }

        Booking booking = staffBookingService.getBookingDetail(bookingId);
        if (booking == null) {
            response.sendError(404, "Booking not found");
            return;
        }

        // Get all unassigned rooms with suggestions
        List<UnassignedRoomInfo> unassignedRooms = staffBookingService.getUnassignedRoomsWithSuggestions(bookingId);
        BookingRoomRepository brRepo = new BookingRoomRepository();
        List<BookingRoom> bookingRooms = brRepo.findByBookingIdWithDetails(bookingId);

        request.setAttribute("booking", booking);
        request.setAttribute("bookingRooms", bookingRooms);
        request.setAttribute("unassignedRooms", unassignedRooms);
        request.setAttribute("activePage", "bookings");
        request.setAttribute("pageTitle", "Gán phòng cho booking #" + bookingId);
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/assign-room.jsp").forward(request, response);
    }

    private void handleAssignRoomPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        int roomId = parseIntParam(request, "roomId");

        if (bookingId <= 0 || roomId <= 0) {
            request.setAttribute("error", "Thông tin không hợp lệ");
            handleAssignRoomGet(request, response);
            return;
        }

        boolean success = staffBookingService.assignRoom(bookingId, roomId);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/occupants?bookingId=" + bookingId + "&success=assigned");
        } else {
            request.setAttribute("error", "Không thể gán phòng. Vui lòng thử lại.");
            handleAssignRoomGet(request, response);
        }
    }

    // UC-19.4: Manage Occupants
    private void handleOccupantsGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        if (bookingId <= 0) {
            response.sendError(400, "Invalid booking ID");
            return;
        }

        Booking booking = staffBookingService.getBookingDetail(bookingId);
        if (booking == null) {
            response.sendError(404, "Booking not found");
            return;
        }

        List<Occupant> occupants = staffBookingService.getOccupants(bookingId);

        if ("assigned".equals(request.getParameter("success"))) {
            request.setAttribute("success", "Đã gán phòng và check-in thành công!");
        }
        if ("saved".equals(request.getParameter("success"))) {
            request.setAttribute("success", "Đã lưu thông tin khách thành công!");
        }

        request.setAttribute("booking", booking);
        request.setAttribute("occupants", occupants);
        request.setAttribute("activePage", "bookings");
        request.setAttribute("pageTitle", "Quản lý khách - Booking #" + bookingId);
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/occupants.jsp").forward(request, response);
    }

    private void handleOccupantsPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        if (bookingId <= 0) {
            response.sendError(400, "Invalid booking ID");
            return;
        }

        // Parse occupants from form
        List<Occupant> occupants = new ArrayList<>();
        String[] names = request.getParameterValues("fullName");
        String[] idCards = request.getParameterValues("idCardNumber");
        String[] phones = request.getParameterValues("phoneNumber");

        if (names != null) {
            for (int i = 0; i < names.length; i++) {
                if (names[i] != null && !names[i].trim().isEmpty()) {
                    Occupant o = new Occupant();
                    o.setFullName(names[i].trim());
                    o.setIdCardNumber(idCards != null && i < idCards.length ? idCards[i] : "");
                    o.setPhoneNumber(phones != null && i < phones.length ? phones[i] : "");
                    occupants.add(o);
                }
            }
        }

        boolean success = staffBookingService.saveOccupants(bookingId, occupants);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/occupants?bookingId=" + bookingId + "&success=saved");
        } else {
            request.setAttribute("error", "Không thể lưu thông tin khách. Vui lòng thử lại.");
            handleOccupantsGet(request, response);
        }
    }

    // UC-19.5: Checkout
    private void handleCheckoutGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        if (bookingId <= 0) {
            response.sendError(400, "Invalid booking ID");
            return;
        }

        Booking booking = staffBookingService.getBookingDetail(bookingId);
        if (booking == null) {
            response.sendError(404, "Booking not found");
            return;
        }

        List<Occupant> occupants = staffBookingService.getOccupants(bookingId);
        List<BookingExtension> extensions = staffBookingService.getExtensions(bookingId);

        // Check if payment is needed at checkout
        boolean needsPayment = staffBookingService.needsCheckoutPayment(bookingId);
        request.setAttribute("needsCheckoutPayment", needsPayment);
        if (needsPayment) {
            request.setAttribute("checkoutPaymentAmount", staffBookingService.getCheckoutPaymentAmount(bookingId));
        }

        // Get actual surcharge for display
        request.setAttribute("surcharge", staffBookingService.getActualSurcharge(bookingId));

        request.setAttribute("booking", booking);
        request.setAttribute("occupants", occupants);
        request.setAttribute("extensions", extensions);
        request.setAttribute("activePage", "bookings");
        request.setAttribute("pageTitle", "Check-out - Booking #" + bookingId);
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/checkout.jsp").forward(request, response);
    }

    private void handleCheckoutPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        if (bookingId <= 0) {
            response.sendError(400, "Invalid booking ID");
            return;
        }

        // Check if payment is needed BEFORE marking as checked out
        boolean needsPayment = staffBookingService.needsCheckoutPayment(bookingId);

        if (needsPayment) {
            // Redirect to payment first - booking stays in current status
            Booking booking = staffBookingService.getBookingDetail(bookingId);
            String invoiceType = PaymentType.DEPOSIT.equals(booking.getPaymentType()) ? "Remaining" : "Booking";
            // Store in session to know to complete checkout after payment
            request.getSession().setAttribute("pendingCheckoutForPayment", bookingId);
            response.sendRedirect(request.getContextPath() + "/staff/payments/process?bookingId=" + bookingId + "&invoiceType=" + invoiceType);
            return;
        }

        // No payment needed - proceed with checkout
        boolean success = staffBookingService.processCheckout(bookingId);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId + "&success=checkedout");
        } else {
            request.setAttribute("error", "Không thể xử lý check-out. Vui lòng thử lại.");
            handleCheckoutGet(request, response);
        }
    }

    // Handle checkout all rooms for multi-room booking (from detail.jsp)
    private void handleCheckoutAll(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        if (bookingId <= 0) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings");
            return;
        }

        // Check if payment is needed BEFORE checkout
        boolean needsPayment = staffBookingService.needsCheckoutPayment(bookingId);

        if (needsPayment) {
            request.getSession().setAttribute("pendingCheckoutForPayment", bookingId);
            response.sendRedirect(request.getContextPath() + "/staff/payments/process?bookingId=" + bookingId + "&invoiceType=Remaining");
            return;
        }

        // No payment needed - proceed with bulk checkout
        boolean success = staffBookingService.processCheckout(bookingId);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId + "&success=checkedout");
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId);
        }
    }

    // === Walk-in Booking Flow ===

    // Step 1: Customer info form
    private void handleWalkInStep1Get(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activePage", "walkin");
        request.setAttribute("pageTitle", "Dat phong tai quay");
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/walkin-step1.jsp").forward(request, response);
    }

    // Step 1: Process customer info
    private void handleWalkInStep1Post(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String idCard = request.getParameter("idCard");
        String confirmEmailLink = request.getParameter("confirmEmailLink");
        String skipEmail = request.getParameter("skipEmail");

        // Validate required fields
        if (fullName == null || fullName.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
            request.setAttribute("error", "Vui long nhap ho ten va so dien thoai");
            setWalkInFormAttributes(request, fullName, phone, email, idCard);
            handleWalkInStep1Get(request, response);
            return;
        }

        try {
            // If staff confirmed to link existing email account
            if ("true".equals(confirmEmailLink)) {
                WalkInCustomerResult result = staffBookingService.findOrCreateWalkInCustomer(
                        fullName.trim(), phone.trim(), email, false);
                saveWalkInSession(request, result.getAccountId(), fullName, phone, email, idCard);
                response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin-room");
                return;
            }

            // If staff chose to skip email (create without email)
            boolean doSkipEmail = "true".equals(skipEmail);

            WalkInCustomerResult result = staffBookingService.findOrCreateWalkInCustomer(
                    fullName.trim(), phone.trim(), email, doSkipEmail);

            if (result.isFoundByEmail()) {
                // Email exists with different phone - ask staff to confirm
                request.setAttribute("emailConflict", true);
                request.setAttribute("conflictName", result.getExistingName());
                request.setAttribute("conflictPhone", maskPhone(result.getExistingPhone()));
                setWalkInFormAttributes(request, fullName, phone, email, idCard);
                handleWalkInStep1Get(request, response);
                return;
            }

            // FOUND_BY_PHONE or CREATED - proceed
            saveWalkInSession(request, result.getAccountId(), fullName, phone, email, idCard);

            // Send credentials email if new account was created and has real email
            if (result.isCreated() && result.getGeneratedPassword() != null
                    && result.getEmail() != null && !result.getEmail().contains("@walkin.local")) {
                System.out.println("=== WALK-IN EMAIL DEBUG ===");
                System.out.println("Sending credentials to: " + result.getEmail());
                System.out.println("FullName: " + fullName.trim());
                System.out.println("Password length: " + result.getGeneratedPassword().length());
                boolean sent = EmailHelper.sendWalkInCredentials(result.getEmail(),
                        fullName.trim(), result.getGeneratedPassword());
                System.out.println("Email sent result: " + sent);
            } else {
                System.out.println("=== WALK-IN EMAIL SKIPPED ===");
                System.out.println("Status: " + result.getStatus());
                System.out.println("isCreated: " + result.isCreated());
                System.out.println("Password: " + (result.getGeneratedPassword() != null ? "set" : "null"));
                System.out.println("Email: " + result.getEmail());
            }

            // Check booking type - single or multi room
            String bookingType = request.getParameter("bookingType");
            if ("multi".equals(bookingType)) {
                response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin-multi");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin-room");
            }

        } catch (Exception e) {
            request.setAttribute("error", "Loi khi xu ly thong tin khach: " + e.getMessage());
            setWalkInFormAttributes(request, fullName, phone, email, idCard);
            handleWalkInStep1Get(request, response);
        }
    }

    private void setWalkInFormAttributes(HttpServletRequest request,
            String fullName, String phone, String email, String idCard) {
        request.setAttribute("fullName", fullName);
        request.setAttribute("phone", phone);
        request.setAttribute("email", email);
        request.setAttribute("idCard", idCard);
    }

    private void saveWalkInSession(HttpServletRequest request, int customerId,
            String fullName, String phone, String email, String idCard) {
        HttpSession session = request.getSession();
        session.setAttribute("walkin_customerId", customerId);
        session.setAttribute("walkin_fullName", fullName.trim());
        session.setAttribute("walkin_phone", phone.trim());
        session.setAttribute("walkin_email", email != null ? email.trim() : "");
        session.setAttribute("walkin_idCard", idCard != null ? idCard.trim() : "");
    }

    // Mask phone for privacy: 0901234567 -> 090***4567
    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) return phone;
        return phone.substring(0, 3) + "***" + phone.substring(phone.length() - 4);
    }

    // Step 2: Select room type + dates
    private void handleWalkInStep2Get(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("walkin_customerId") == null) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin");
            return;
        }

        List<RoomType> roomTypes = staffBookingService.getAllRoomTypes();
        request.setAttribute("roomTypes", roomTypes);
        request.setAttribute("activePage", "walkin");
        request.setAttribute("pageTitle", "Chon phong - Dat phong tai quay");
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/walkin-step2.jsp").forward(request, response);
    }

    // Step 2: Process room selection (2 phases: search rooms, then confirm room choice)
    private void handleWalkInStep2Post(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("walkin_customerId") == null) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin");
            return;
        }

        // Phase 2: Staff has chosen a specific room -> calculate and go to step 3
        String selectedRoomId = request.getParameter("roomId");
        if (selectedRoomId != null && !selectedRoomId.isEmpty()) {
            handleWalkInRoomConfirm(request, response, session, selectedRoomId);
            return;
        }

        // Phase 1: Staff selected type + dates -> show available rooms
        int typeId = parseIntParam(request, "typeId");
        String checkInStr = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");

        if (typeId <= 0 || checkInStr == null || checkOutStr == null
                || checkInStr.isEmpty() || checkOutStr.isEmpty()) {
            request.setAttribute("error", "Vui long chon loai phong va ngay nhan/tra phong");
            handleWalkInStep2Get(request, response);
            return;
        }

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime checkIn = LocalDateTime.parse(checkInStr, formatter);
            LocalDateTime checkOut = LocalDateTime.parse(checkOutStr, formatter);

            if (!checkOut.isAfter(checkIn)) {
                request.setAttribute("error", "Ngay tra phong phai sau ngay nhan phong");
                handleWalkInStep2Get(request, response);
                return;
            }

            LocalDateTime now = LocalDateTime.now();
            if (checkIn.isBefore(now)) {
                request.setAttribute("error", "Ngay nhan phong khong duoc trong qua khu");
                handleWalkInStep2Get(request, response);
                return;
            }

            // Find available rooms
            List<Room> availableRooms = staffBookingService.findAvailableRoomsForDates(typeId, checkIn, checkOut);
            if (availableRooms.isEmpty()) {
                request.setAttribute("error", "Khong con phong trong cho loai phong nay trong khoang thoi gian da chon");
                handleWalkInStep2Get(request, response);
                return;
            }

            // Store search params in session for phase 2
            session.setAttribute("walkin_typeId", typeId);
            session.setAttribute("walkin_checkIn", checkIn);
            session.setAttribute("walkin_checkOut", checkOut);

            // Show room selection UI
            RoomType roomType = staffBookingService.getRoomTypeById(typeId);
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("selectedType", roomType);
            request.setAttribute("selectedCheckIn", checkInStr);
            request.setAttribute("selectedCheckOut", checkOutStr);
            request.setAttribute("selectedTypeId", typeId);

            // Re-populate form fields
            List<RoomType> roomTypes = staffBookingService.getAllRoomTypes();
            request.setAttribute("roomTypes", roomTypes);
            request.setAttribute("activePage", "walkin");
            request.setAttribute("pageTitle", "Chon phong - Dat phong tai quay");
            request.getRequestDispatcher("/WEB-INF/views/staff/bookings/walkin-step2.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Loi xu ly: " + e.getMessage());
            handleWalkInStep2Get(request, response);
        }
    }

    // Phase 2: Staff confirmed a specific room -> calculate price and go to step 3
    private void handleWalkInRoomConfirm(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, String selectedRoomId) throws ServletException, IOException {
        try {
            int roomId = Integer.parseInt(selectedRoomId);
            int typeId = (int) session.getAttribute("walkin_typeId");
            LocalDateTime checkIn = (LocalDateTime) session.getAttribute("walkin_checkIn");
            LocalDateTime checkOut = (LocalDateTime) session.getAttribute("walkin_checkOut");

            // Calculate booking price
            BookingCalcResponse calc = bookingService.calculateBooking(typeId, roomId, checkIn, checkOut, null);
            if (calc == null) {
                request.setAttribute("error", "Khong the tinh gia phong. Vui long thu lai.");
                handleWalkInStep2Get(request, response);
                return;
            }

            // Store in session
            session.setAttribute("walkin_roomId", roomId);
            session.setAttribute("walkin_calc", calc);

            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin-confirm");
        } catch (Exception e) {
            request.setAttribute("error", "Loi xu ly: " + e.getMessage());
            handleWalkInStep2Get(request, response);
        }
    }

    // Walk-in Multi-Room: Show room type + qty selection
    private void handleWalkInMultiGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("walkin_customerId") == null) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin");
            return;
        }

        List<RoomType> roomTypes = staffBookingService.getAllRoomTypes();

        // Calculate availability for default dates (today to tomorrow)
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime defaultCheckIn = now.plusHours(2).withMinute(0).withSecond(0);
        LocalDateTime defaultCheckOut = defaultCheckIn.plusDays(1);

        Map<Integer, Integer> availability = new HashMap<>();
        for (RoomType rt : roomTypes) {
            int count = roomRepository.countAvailableForDates(rt.getTypeId(), defaultCheckIn, defaultCheckOut);
            availability.put(rt.getTypeId(), count);
        }

        request.setAttribute("roomTypes", roomTypes);
        request.setAttribute("availability", availability);
        request.setAttribute("walkin_fullName", session.getAttribute("walkin_fullName"));
        request.setAttribute("walkin_phone", session.getAttribute("walkin_phone"));
        request.setAttribute("selectedCheckIn", session.getAttribute("walkin_checkIn") != null
            ? ((LocalDateTime) session.getAttribute("walkin_checkIn")).format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))
            : defaultCheckIn.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        request.setAttribute("selectedCheckOut", session.getAttribute("walkin_checkOut") != null
            ? ((LocalDateTime) session.getAttribute("walkin_checkOut")).format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))
            : defaultCheckOut.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        request.setAttribute("activePage", "walkin");
        request.setAttribute("pageTitle", "Chon phong - Dat phong tai quay");
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/walkin-step2-multi.jsp").forward(request, response);
    }

    // Walk-in Multi-Room: Handle form submission with selections
    private void handleWalkInMultiPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("walkin_customerId") == null) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin");
            return;
        }

        try {
            // Parse check-in/out
            String checkInStr = request.getParameter("checkIn");
            String checkOutStr = request.getParameter("checkOut");
            if (checkInStr == null || checkOutStr == null || checkInStr.isEmpty() || checkOutStr.isEmpty()) {
                request.setAttribute("error", "Vui long chon ngay nhan/tra phong");
                handleWalkInMultiGet(request, response);
                return;
            }

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime checkIn = LocalDateTime.parse(checkInStr, formatter);
            LocalDateTime checkOut = LocalDateTime.parse(checkOutStr, formatter);

            if (!checkOut.isAfter(checkIn)) {
                request.setAttribute("error", "Ngay tra phong phai sau ngay nhan phong");
                handleWalkInMultiGet(request, response);
                return;
            }

            LocalDateTime now = LocalDateTime.now();
            if (checkIn.isBefore(now)) {
                request.setAttribute("error", "Ngay nhan phong khong duoc trong qua khu");
                handleWalkInMultiGet(request, response);
                return;
            }

            // Parse room selections (typeId and qty)
            String[] typeIds = request.getParameterValues("typeId");
            String[] qtys = request.getParameterValues("qty");

            if (typeIds == null || typeIds.length == 0) {
                request.setAttribute("error", "Vui long chon it nhat 1 loai phong");
                handleWalkInMultiGet(request, response);
                return;
            }

            List<RoomSelectionItem> selections = new ArrayList<>();
            for (int i = 0; i < typeIds.length; i++) {
                if (typeIds[i] != null && !typeIds[i].isEmpty()) {
                    int typeId = Integer.parseInt(typeIds[i]);
                    int qty = 1;
                    if (qtys != null && i < qtys.length) {
                        qty = Integer.parseInt(qtys[i]);
                    }
                    selections.add(new RoomSelectionItem(typeId, qty));
                }
            }

            if (selections.isEmpty()) {
                request.setAttribute("error", "Vui long chon it nhat 1 loai phong");
                handleWalkInMultiGet(request, response);
                return;
            }

            // Calculate total price
            MultiRoomCalcResponse multiCalc = bookingService.calculateMultiRoomBooking(
                selections, checkIn, checkOut, null);

            if (multiCalc == null || multiCalc.getRoomCalcs() == null || multiCalc.getRoomCalcs().isEmpty()) {
                request.setAttribute("error", "Khong co phong trong. Vui long chon loai phong khac.");
                handleWalkInMultiGet(request, response);
                return;
            }

            // Store in session
            session.setAttribute("walkin_selections", selections);
            session.setAttribute("walkin_checkIn", checkIn);
            session.setAttribute("walkin_checkOut", checkOut);
            session.setAttribute("walkin_multiCalc", multiCalc);

            // Redirect to confirm page
            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin-confirm");

        } catch (Exception e) {
            request.setAttribute("error", "Loi xu ly: " + e.getMessage());
            handleWalkInMultiGet(request, response);
        }
    }

    // Step 3: Confirm + show summary
    private void handleWalkInStep3Get(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("walkin_customerId") == null) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin");
            return;
        }

        // Check for multi-room or single-room
        MultiRoomCalcResponse multiCalc = (MultiRoomCalcResponse) session.getAttribute("walkin_multiCalc");
        BookingCalcResponse calc = (BookingCalcResponse) session.getAttribute("walkin_calc");

        if (multiCalc != null) {
            request.setAttribute("multiCalc", multiCalc);
            request.setAttribute("isMultiRoom", true);
        } else if (calc != null) {
            request.setAttribute("calc", calc);
            request.setAttribute("isMultiRoom", false);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin");
            return;
        }

        request.setAttribute("walkin_fullName", session.getAttribute("walkin_fullName"));
        request.setAttribute("walkin_phone", session.getAttribute("walkin_phone"));
        request.setAttribute("walkin_email", session.getAttribute("walkin_email"));
        request.setAttribute("walkin_idCard", session.getAttribute("walkin_idCard"));
        request.setAttribute("activePage", "walkin");
        request.setAttribute("pageTitle", "Xac nhan dat phong tai quay");
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/walkin-step3.jsp").forward(request, response);
    }

    // Step 3: Create booking + redirect to payment
    private void handleWalkInStep3Post(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("walkin_customerId") == null) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin");
            return;
        }

        int customerId = (int) session.getAttribute("walkin_customerId");
        String note = request.getParameter("note");

        // Check for multi-room or single-room
        MultiRoomCalcResponse multiCalc = (MultiRoomCalcResponse) session.getAttribute("walkin_multiCalc");
        BookingCalcResponse calc = (BookingCalcResponse) session.getAttribute("walkin_calc");

        // Parse occupants from form
        List<Occupant> occupants = new ArrayList<>();
        String[] names = request.getParameterValues("occFullName");
        String[] idCards = request.getParameterValues("occIdCard");
        String[] phones = request.getParameterValues("occPhone");

        if (names != null) {
            for (int i = 0; i < names.length; i++) {
                if (names[i] != null && !names[i].trim().isEmpty()) {
                    Occupant o = new Occupant();
                    o.setFullName(names[i].trim());
                    o.setIdCardNumber(idCards != null && i < idCards.length ? idCards[i] : "");
                    o.setPhoneNumber(phones != null && i < phones.length ? phones[i] : "");
                    occupants.add(o);
                }
            }
        }

        try {
            BookingResult result = null;

            if (multiCalc != null) {
                // Multi-room booking
                List<RoomSelectionItem> selections = (List<RoomSelectionItem>) session.getAttribute("walkin_selections");
                LocalDateTime checkIn = (LocalDateTime) session.getAttribute("walkin_checkIn");
                LocalDateTime checkOut = (LocalDateTime) session.getAttribute("walkin_checkOut");

                result = staffBookingService.createWalkInMultiRoom(
                    customerId, selections, checkIn, checkOut,
                    multiCalc.getTotal(), note, occupants);

                if (result.isSuccess()) {
                    int bookingId = result.getBooking().getBookingId();
                    clearWalkInSession(session);

                    response.sendRedirect(request.getContextPath()
                            + "/staff/payments/process?bookingId=" + bookingId + "&invoiceType=Booking");
                }
            } else if (calc != null) {
                // Single room booking
                int typeId = (int) session.getAttribute("walkin_typeId");
                LocalDateTime checkIn = (LocalDateTime) session.getAttribute("walkin_checkIn");
                LocalDateTime checkOut = (LocalDateTime) session.getAttribute("walkin_checkOut");

                // Validate occupant count against room capacity
                if (calc.getRoomType() != null && occupants.size() > calc.getRoomType().getCapacity()) {
                    request.setAttribute("error", "So luong khach vuot qua suc chua phong (toi da "
                            + calc.getRoomType().getCapacity() + " nguoi)");
                    handleWalkInStep3Get(request, response);
                    return;
                }

                result = staffBookingService.createWalkInBooking(
                        customerId, typeId, checkIn, checkOut,
                        calc.getTotal(), note, occupants);

                if (result.isSuccess()) {
                    int bookingId = result.getBooking().getBookingId();
                    clearWalkInSession(session);

                    response.sendRedirect(request.getContextPath()
                            + "/staff/payments/process?bookingId=" + bookingId + "&invoiceType=Booking");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/bookings/walkin");
                return;
            }

            if (result != null && !result.isSuccess()) {
                request.setAttribute("error", result.getMessage());
                handleWalkInStep3Get(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Loi khi tao booking: " + e.getMessage());
            handleWalkInStep3Get(request, response);
        }
    }

    private void clearWalkInSession(HttpSession session) {
        session.removeAttribute("walkin_customerId");
        session.removeAttribute("walkin_fullName");
        session.removeAttribute("walkin_phone");
        session.removeAttribute("walkin_email");
        session.removeAttribute("walkin_idCard");
        session.removeAttribute("walkin_typeId");
        session.removeAttribute("walkin_roomId");
        session.removeAttribute("walkin_checkIn");
        session.removeAttribute("walkin_checkOut");
        session.removeAttribute("walkin_calc");
        session.removeAttribute("walkin_selections");
        session.removeAttribute("walkin_multiCalc");
    }

    private void handleSuggestRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        if (bookingId <= 0) {
            response.sendError(400, "Invalid booking ID");
            return;
        }

        Booking booking = staffBookingService.getBookingDetail(bookingId);
        if (booking == null) {
            response.sendError(404, "Booking not found");
            return;
        }

        BookingRoomRepository brRepo = new BookingRoomRepository();
        List<BookingRoom> bookingRooms = brRepo.findByBookingIdWithDetails(bookingId);

        // Build needs map: typeId -> count of unassigned BookingRooms
        Map<Integer, Integer> needs = new LinkedHashMap<>();
        for (BookingRoom br : bookingRooms) {
            if (br.getRoomId() == null) {
                needs.merge(br.getTypeId(), 1, Integer::sum);
            }
        }

        if (needs.isEmpty()) {
            request.setAttribute("suggestionsEmpty", true);
        } else {
            RoomSuggestionService suggestionService = new RoomSuggestionService();
            Map<Integer, List<Room>> rawSuggestions = suggestionService.suggestNearbyRooms(
                needs, booking.getCheckInExpected(), booking.getCheckOutExpected());

            // Convert to List<RoomSuggestionItem>
            List<RoomSuggestionItem> suggestionItems = new ArrayList<>();
            for (Map.Entry<Integer, List<Room>> entry : rawSuggestions.entrySet()) {
                for (Room room : entry.getValue()) {
                    for (BookingRoom br : bookingRooms) {
                        if (br.getTypeId() == entry.getKey() && br.getRoomId() == null) {
                            suggestionItems.add(new RoomSuggestionItem(
                                br.getBookingRoomId(),
                                room.getRoomId(),
                                room.getRoomType() != null ? room.getRoomType().getTypeName() : "",
                                room.getRoomNumber()
                            ));
                            break;
                        }
                    }
                }
            }
            request.setAttribute("suggestions", suggestionItems);
        }

        request.setAttribute("booking", booking);
        request.setAttribute("bookingRooms", bookingRooms);
        request.setAttribute("activePage", "bookings");
        request.setAttribute("pageTitle", "Go y chon phong - Booking #" + bookingId);
        request.getRequestDispatcher("/WEB-INF/views/staff/bookings/suggest-rooms.jsp").forward(request, response);
    }

    private void handleBulkAssign(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        if (bookingId <= 0) {
            response.sendError(400, "Invalid booking ID");
            return;
        }

        Map<Integer, Integer> assignments = new LinkedHashMap<>();

        // Handle acceptedSuggestions format: "bookingRoomId:roomId"
        String[] acceptedSuggestions = request.getParameterValues("acceptedSuggestions");
        if (acceptedSuggestions != null) {
            for (String suggestion : acceptedSuggestions) {
                if (suggestion != null && suggestion.contains(":")) {
                    String[] parts = suggestion.split(":");
                    if (parts.length == 2) {
                        try {
                            int brId = Integer.parseInt(parts[0]);
                            int roomId = Integer.parseInt(parts[1]);
                            if (brId > 0 && roomId > 0) {
                                assignments.put(brId, roomId);
                            }
                        } catch (NumberFormatException e) {
                            // ignore invalid format
                        }
                    }
                }
            }
        }

        // Handle bookingRoomId + roomId_${bookingRoomId} pairs (new format from assign-room.jsp)
        String[] brIds = request.getParameterValues("bookingRoomId");
        if (brIds != null) {
            for (String brIdStr : brIds) {
                if (brIdStr != null && !brIdStr.isEmpty()) {
                    try {
                        int brId = Integer.parseInt(brIdStr);
                        String roomIdParam = "roomId_" + brId;
                        String roomIdStr = request.getParameter(roomIdParam);
                        if (roomIdStr != null && !roomIdStr.isEmpty()) {
                            int roomId = Integer.parseInt(roomIdStr);
                            if (brId > 0 && roomId > 0) {
                                assignments.put(brId, roomId);
                            }
                        }
                    } catch (NumberFormatException e) {
                        // ignore invalid
                    }
                }
            }
        }

        // Also handle individual bookingRoomId + suggestedRoomId pairs (legacy format)
        String[] roomIds = request.getParameterValues("suggestedRoomId");
        if (brIds != null && roomIds != null) {
            for (int i = 0; i < brIds.length; i++) {
                if (brIds[i] != null && roomIds[i] != null && !brIds[i].isEmpty() && !roomIds[i].isEmpty()) {
                    int brId = Integer.parseInt(brIds[i]);
                    int roomId = Integer.parseInt(roomIds[i]);
                    if (brId > 0 && roomId > 0) {
                        assignments.put(brId, roomId);
                    }
                }
            }
        }

        if (!assignments.isEmpty()) {
            staffBookingService.bulkAssignRooms(bookingId, assignments);
        }

        response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId);
    }

    private void handleAssignBookingRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        int bookingRoomId = parseIntParam(request, "bookingRoomId");
        int roomId = parseIntParam(request, "roomId");

        if (bookingRoomId <= 0 || roomId <= 0) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId);
            return;
        }

        staffBookingService.assignRoomToBookingRoom(bookingRoomId, roomId);
        response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId);
    }

    private void handleCheckoutBookingRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");
        int bookingRoomId = parseIntParam(request, "bookingRoomId");

        if (bookingRoomId <= 0) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId);
            return;
        }

        BookingRoomRepository brRepo = new BookingRoomRepository();
        BookingRoom br = brRepo.findById(bookingRoomId);
        if (br == null) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId);
            return;
        }

        // Check if payment is needed BEFORE checkout
        boolean needsPayment = staffBookingService.needsCheckoutPaymentForRoom(bookingRoomId);

        if (needsPayment) {
            // Store bookingRoomId in session for checkout after payment
            request.getSession().setAttribute("pendingCheckoutBookingRoomId", bookingRoomId);
            request.getSession().setAttribute("pendingCheckoutBookingId", bookingId);
            // Payment first, checkout will happen after payment is completed
            response.sendRedirect(request.getContextPath() + "/staff/payments/process?bookingId=" + bookingId + "&invoiceType=Remaining");
            return;
        }

        // No payment needed, proceed with checkout directly
        boolean success = staffBookingService.checkoutBookingRoom(bookingRoomId);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId + "&success=checkedout");
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId);
        }
    }

    // Handle checkout after payment is completed
    private void handleCompleteCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer bookingRoomId = (Integer) request.getSession().getAttribute("pendingCheckoutBookingRoomId");
        Integer bookingId = (Integer) request.getSession().getAttribute("pendingCheckoutBookingId");

        if (bookingRoomId != null && bookingRoomId > 0 && bookingId != null && bookingId > 0) {
            // Perform checkout
            boolean success = staffBookingService.checkoutBookingRoom(bookingRoomId);

            // Clear session attributes
            request.getSession().removeAttribute("pendingCheckoutBookingRoomId");
            request.getSession().removeAttribute("pendingCheckoutBookingId");

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId + "&success=checkedout");
                return;
            }
        }

        // Fallback redirect
        int fallbackBookingId = bookingId != null ? bookingId : 0;
        response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + fallbackBookingId);
    }

    // Handle multi-room checkout completion after payment
    private void handleCompleteMultiCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = parseIntParam(request, "bookingId");

        if (bookingId > 0) {
            // Perform checkout
            boolean success = staffBookingService.processCheckout(bookingId);

            // Clear session attribute
            request.getSession().removeAttribute("pendingCheckoutForPayment");

            if (success) {
                response.sendRedirect(request.getContextPath() + "/staff/bookings/detail?id=" + bookingId + "&success=checkedout");
                return;
            }
        }

        // Fallback redirect
        response.sendRedirect(request.getContextPath() + "/staff/bookings");
    }

    private int parseIntParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.isEmpty()) return 0;
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
