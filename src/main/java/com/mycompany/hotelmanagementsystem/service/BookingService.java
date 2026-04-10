package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.BookingStatus;
import com.mycompany.hotelmanagementsystem.constant.PaymentType;
import com.mycompany.hotelmanagementsystem.util.BookingCalcResponse;
import com.mycompany.hotelmanagementsystem.util.BookingResult;
import com.mycompany.hotelmanagementsystem.util.ServiceResult;
import com.mycompany.hotelmanagementsystem.util.DateHelper;
import com.mycompany.hotelmanagementsystem.entity.*;
import com.mycompany.hotelmanagementsystem.dal.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import com.mycompany.hotelmanagementsystem.dal.BookingRoomRepository;
import com.mycompany.hotelmanagementsystem.entity.BookingRoom;
import com.mycompany.hotelmanagementsystem.util.MultiRoomCalcResponse;
import com.mycompany.hotelmanagementsystem.util.RoomSelectionItem;
import com.mycompany.hotelmanagementsystem.util.SurchargeResult;
import java.util.ArrayList;

public class BookingService {
    private final BookingRepository bookingRepository;
    private final RoomRepository roomRepository;
    private final RoomTypeRepository roomTypeRepository;
    private final VoucherRepository voucherRepository;
    private final OccupantRepository occupantRepository;
    private final PromotionRepository promotionRepository;
    private final BookingRoomRepository bookingRoomRepository;

    public BookingService() {
        this.bookingRepository = new BookingRepository();
        this.roomRepository = new RoomRepository();
        this.roomTypeRepository = new RoomTypeRepository();
        this.voucherRepository = new VoucherRepository();
        this.occupantRepository = new OccupantRepository();
        this.promotionRepository = new PromotionRepository();
        this.bookingRoomRepository = new BookingRoomRepository();
    }

    public BookingCalcResponse calculateBooking(int typeId, int roomId,
            LocalDateTime checkIn, LocalDateTime checkOut, String voucherCode) {

        RoomType roomType = roomTypeRepository.findById(typeId);
        if (roomType == null) return null;

        Room room = roomRepository.findById(roomId);
        if (room == null || room.getTypeId() != typeId) return null;

        long nights = DateHelper.calculateNights(checkIn, checkOut);
        BigDecimal subtotal = roomType.getBasePrice().multiply(BigDecimal.valueOf(nights));

        // Promotion discount (percentage-based, auto-applied from active promotion)
        BigDecimal promotionDiscount = BigDecimal.ZERO;
        Promotion promotion = promotionRepository.findActiveByTypeId(typeId);
        if (promotion != null) {
            promotionDiscount = roomType.getBasePrice()
                .multiply(promotion.getDiscountPercent())
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(nights));
            if (promotionDiscount.compareTo(subtotal) > 0) {
                promotionDiscount = subtotal;
            }
        }

        // Voucher discount (fixed amount, capped at remaining after promotion)
        BigDecimal voucherDiscount = BigDecimal.ZERO;
        Voucher voucher = null;

        if (voucherCode != null && !voucherCode.isEmpty()) {
            voucher = voucherRepository.findByCode(voucherCode);
            if (voucher != null && voucher.isActive()) {
                if (voucher.getMinOrderValue() == null || subtotal.compareTo(voucher.getMinOrderValue()) >= 0) {
                    voucherDiscount = voucher.getDiscountAmount();
                    BigDecimal remaining = subtotal.subtract(promotionDiscount);
                    if (voucherDiscount.compareTo(remaining) > 0) {
                        voucherDiscount = remaining;
                    }
                }
            }
        }

        BigDecimal total = subtotal.subtract(promotionDiscount).subtract(voucherDiscount);
        if (total.compareTo(BigDecimal.ZERO) < 0) {
            total = BigDecimal.ZERO;
        }

        // Calculate deposit info
        BigDecimal depositPercent = roomType.getDepositPercent() != null
            ? roomType.getDepositPercent() : BigDecimal.ZERO;
        BigDecimal depositAmount = total.multiply(depositPercent)
            .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
        boolean isStandard = roomType.isStandardRoom();

        BookingCalcResponse response = new BookingCalcResponse();
        response.setRoomType(roomType);
        response.setRoom(room);
        response.setCheckIn(checkIn);
        response.setCheckOut(checkOut);
        response.setNights(nights);
        response.setSubtotal(subtotal);
        response.setPromotion(promotion);
        response.setPromotionDiscount(promotionDiscount);
        response.setDiscount(voucherDiscount);
        response.setTotal(total);
        response.setVoucher(voucher);
        response.setDepositPercent(depositPercent);
        response.setDepositAmount(depositAmount);
        response.setStandardRoom(isStandard);
        response.setPricePerHour(roomType.getPricePerHour());
        return response;
    }

    public List<Room> getAvailableRooms(int typeId, LocalDateTime checkIn, LocalDateTime checkOut) {
        return roomRepository.findAvailableForDates(typeId, checkIn, checkOut);
    }

    /**
     * Lấy danh sách khoảng ngày đã bị đặt (active) cho loại phòng,
     * để hiển thị lịch "ngày bận" cho customer khi đặt phòng.
     */
    public List<LocalDateTime[]> getOccupiedDateRanges(int typeId) {
        return bookingRepository.findOccupiedDateRangesByTypeId(typeId);
    }

    public BookingResult createBooking(int customerId, int roomId, LocalDateTime checkIn,
            LocalDateTime checkOut, BigDecimal totalPrice, Integer voucherId,
            String note, List<Occupant> occupants, String paymentType, BigDecimal depositAmount) {

        if (!DateHelper.isFutureDate(checkIn)) {
            return BookingResult.failure("Ngày nhận phòng phải là ngày trong tương lai");
        }
        if (!checkOut.isAfter(checkIn)) {
            return BookingResult.failure("Ngày trả phòng phải sau ngày nhận phòng");
        }
        if (ChronoUnit.DAYS.between(checkIn.toLocalDate(), checkOut.toLocalDate()) > 30) {
            return BookingResult.failure("Đặt phòng tối đa 30 ngày");
        }
        if (!bookingRepository.isRoomAvailable(roomId, checkIn, checkOut)) {
            return BookingResult.failure("Phòng không còn trống trong thời gian này");
        }

        // Get room to determine typeId
        Room room = roomRepository.findById(roomId);
        if (room == null) {
            return BookingResult.failure("Phòng không tồn tại");
        }

        Booking booking = new Booking();
        booking.setCustomerId(customerId);
        booking.setRoomId(roomId);
        booking.setTypeId(room.getTypeId());
        booking.setCheckInExpected(checkIn);
        booking.setCheckOutExpected(checkOut);
        booking.setTotalPrice(totalPrice);
        booking.setVoucherId(voucherId);
        booking.setNote(note);
        booking.setStatus(BookingStatus.PENDING);

        // Set payment type and deposit amount
        if (paymentType != null) {
            booking.setPaymentType(paymentType);
        } else {
            booking.setPaymentType(PaymentType.FULL);
        }
        if (depositAmount != null) {
            booking.setDepositAmount(depositAmount);
        } else {
            booking.setDepositAmount(totalPrice);
        }

        int bookingId = bookingRepository.insert(booking);
        if (bookingId <= 0) return BookingResult.failure("Không thể tạo đơn đặt phòng");

        booking.setBookingId(bookingId);

        if (occupants != null) {
            for (Occupant occ : occupants) {
                if (occ.getFullName() != null && !occ.getFullName().trim().isEmpty()) {
                    occ.setBookingId(bookingId);
                    occ.setFullName(occ.getFullName().trim());
                    occupantRepository.insert(occ);
                }
            }
        }

        return BookingResult.success("Đặt phòng thành công", booking);
    }

    // Backward-compatible overload for existing callers
    public BookingResult createBooking(int customerId, int roomId, LocalDateTime checkIn,
            LocalDateTime checkOut, BigDecimal totalPrice, Integer voucherId,
            String note, List<Occupant> occupants) {
        return createBooking(customerId, roomId, checkIn, checkOut, totalPrice,
            voucherId, note, occupants, PaymentType.FULL, totalPrice);
    }

    public Booking getBookingById(int bookingId) {
        Booking booking = bookingRepository.findByIdWithDetails(bookingId);
        // Lazy check: auto-cancel overdue bookings (Pending or Confirmed, all room types)
        if (booking != null && (BookingStatus.PENDING.equals(booking.getStatus())
                || BookingStatus.CONFIRMED.equals(booking.getStatus()))) {
            try {
                if (isOverdueBooking(booking)) {
                    bookingRepository.updateStatus(bookingId, BookingStatus.CANCELLED);
                    booking.setStatus(BookingStatus.CANCELLED);
                }
            } catch (Exception e) {
                // Don't break the flow if lazy check fails
            }
        }
        return booking;
    }

    public List<Booking> getCustomerBookings(int customerId) {
        return bookingRepository.findByCustomerId(customerId);
    }

    public boolean updateBookingStatus(int bookingId, String status) {
        return bookingRepository.updateStatus(bookingId, status) > 0;
    }

    public List<Occupant> getBookingOccupants(int bookingId) {
        return occupantRepository.findByBookingId(bookingId);
    }

    public ServiceResult cancelBooking(int bookingId, int customerId) {
        Booking booking = bookingRepository.findById(bookingId);
        if (booking == null || booking.getCustomerId() != customerId) {
            return ServiceResult.failure("Khong tim thay dat phong");
        }
        if (!BookingStatus.PENDING.equals(booking.getStatus()) &&
            !BookingStatus.CONFIRMED.equals(booking.getStatus())) {
            return ServiceResult.failure("Chi co the huy don o trang thai cho thanh toan hoac da xac nhan");
        }
        if (bookingRepository.updateStatus(bookingId, BookingStatus.CANCELLED) > 0) {
            return ServiceResult.success("Dat phong da duoc huy thanh cong");
        }
        return ServiceResult.failure("Khong the huy dat phong, vui long thu lai");
    }

    // Check if booking is overdue (1 minute past check-in expected, all room types)
    private boolean isOverdueBooking(Booking booking) {
        if (booking.getCheckInExpected() == null) return false;
        LocalDateTime deadline = booking.getCheckInExpected().plusMinutes(1);
        return LocalDateTime.now().isAfter(deadline);
    }

    /**
     * Calculate pricing for a single room by TYPE (no specific room needed).
     * Used by multi-room flow where specific rooms aren't assigned yet.
     */
    private BookingCalcResponse calculateBookingByType(int typeId, LocalDateTime checkIn, LocalDateTime checkOut) {
        RoomType roomType = roomTypeRepository.findById(typeId);
        if (roomType == null) return null;

        long nights = DateHelper.calculateNights(checkIn, checkOut);
        BigDecimal pricePerHour = roomType.getPricePerHour() != null ? roomType.getPricePerHour() : BigDecimal.ZERO;

        // Calculate surcharges
        SurchargeResult surcharge = DateHelper.calculateSurcharges(checkIn, checkOut, pricePerHour);

        BigDecimal subtotal;
        if (surcharge.isSameDayBooking()) {
            subtotal = surcharge.getHourlyTotal();
        } else {
            subtotal = roomType.getBasePrice().multiply(BigDecimal.valueOf(nights));
        }

        // Promotion discount
        BigDecimal promotionDiscount = BigDecimal.ZERO;
        Promotion promotion = promotionRepository.findActiveByTypeId(typeId);
        if (promotion != null && !surcharge.isSameDayBooking()) {
            promotionDiscount = roomType.getBasePrice()
                .multiply(promotion.getDiscountPercent())
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(nights));
            if (promotionDiscount.compareTo(subtotal) > 0) {
                promotionDiscount = subtotal;
            }
        }

        BigDecimal total = subtotal.subtract(promotionDiscount)
            .add(surcharge.getEarlySurcharge())
            .add(surcharge.getLateSurcharge());
        if (total.compareTo(BigDecimal.ZERO) < 0) total = BigDecimal.ZERO;

        // Deposit
        BigDecimal depositPercent = roomType.getDepositPercent() != null ? roomType.getDepositPercent() : BigDecimal.ZERO;
        BigDecimal depositAmount = total.multiply(depositPercent).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);

        BookingCalcResponse response = new BookingCalcResponse();
        response.setRoomType(roomType);
        response.setCheckIn(checkIn);
        response.setCheckOut(checkOut);
        response.setNights(nights);
        response.setSubtotal(subtotal);
        response.setPromotion(promotion);
        response.setPromotionDiscount(promotionDiscount);
        response.setDiscount(BigDecimal.ZERO); // voucher applied at aggregate level
        response.setTotal(total);
        response.setDepositPercent(depositPercent);
        response.setDepositAmount(depositAmount);
        response.setStandardRoom(roomType.isStandardRoom());
        response.setPricePerHour(pricePerHour);
        response.setEarlySurcharge(surcharge.getEarlySurcharge());
        response.setLateSurcharge(surcharge.getLateSurcharge());
        response.setEarlyHours(surcharge.getEarlyHours());
        response.setLateHours(surcharge.getLateHours());
        response.setSameDayBooking(surcharge.isSameDayBooking());
        response.setTotalHours(surcharge.getTotalHours());
        response.setSurchargeTotal(surcharge.getSurchargeTotal());
        return response;
    }

    /**
     * Calculate pricing for multi-room booking.
     * Each room gets its own pricing (with promotion). Voucher applied once to total.
     */
    public MultiRoomCalcResponse calculateMultiRoomBooking(
            List<RoomSelectionItem> selections,
            LocalDateTime checkIn, LocalDateTime checkOut, String voucherCode) {

        long nights = DateHelper.calculateNights(checkIn, checkOut);
        List<BookingCalcResponse> roomCalcs = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal totalPromotionDiscount = BigDecimal.ZERO;
        BigDecimal totalDeposit = BigDecimal.ZERO;
        BigDecimal totalEarlySurcharge = BigDecimal.ZERO;
        BigDecimal totalLateSurcharge = BigDecimal.ZERO;
        boolean allStandard = true;

        for (RoomSelectionItem sel : selections) {
            // Check availability
            int available = roomRepository.countAvailableForDates(sel.getTypeId(), checkIn, checkOut);
            if (available < sel.getQuantity()) return null; // not enough rooms

            for (int i = 0; i < sel.getQuantity(); i++) {
                BookingCalcResponse calc = calculateBookingByType(sel.getTypeId(), checkIn, checkOut);
                if (calc == null) return null;
                roomCalcs.add(calc);

                subtotal = subtotal.add(calc.getSubtotal());
                totalPromotionDiscount = totalPromotionDiscount.add(calc.getPromotionDiscount());
                totalDeposit = totalDeposit.add(calc.getDepositAmount());
                totalEarlySurcharge = totalEarlySurcharge.add(calc.getEarlySurcharge());
                totalLateSurcharge = totalLateSurcharge.add(calc.getLateSurcharge());
                if (!calc.isStandardRoom()) allStandard = false;
            }
        }

        // Apply voucher ONCE to total (after promotions + surcharges)
        BigDecimal afterPromotion = subtotal.subtract(totalPromotionDiscount)
            .add(totalEarlySurcharge).add(totalLateSurcharge);
        BigDecimal voucherDiscount = BigDecimal.ZERO;
        Voucher voucher = null;

        if (voucherCode != null && !voucherCode.isEmpty()) {
            voucher = voucherRepository.findByCode(voucherCode);
            if (voucher != null && voucher.isActive()) {
                if (voucher.getMinOrderValue() == null || afterPromotion.compareTo(voucher.getMinOrderValue()) >= 0) {
                    voucherDiscount = voucher.getDiscountAmount();
                    if (voucherDiscount.compareTo(afterPromotion) > 0) {
                        voucherDiscount = afterPromotion;
                    }
                }
            }
        }

        BigDecimal total = afterPromotion.subtract(voucherDiscount);
        if (total.compareTo(BigDecimal.ZERO) < 0) total = BigDecimal.ZERO;

        MultiRoomCalcResponse resp = new MultiRoomCalcResponse();
        resp.setCheckIn(checkIn);
        resp.setCheckOut(checkOut);
        resp.setNights(nights);
        resp.setRoomCalcs(roomCalcs);
        resp.setSubtotal(subtotal);
        resp.setTotalPromotionDiscount(totalPromotionDiscount);
        resp.setVoucherDiscount(voucherDiscount);
        resp.setVoucher(voucher);
        resp.setTotal(total);
        resp.setDepositAmount(allStandard ? BigDecimal.ZERO : totalDeposit);
        resp.setAllStandardRooms(allStandard);
        resp.setTotalEarlySurcharge(totalEarlySurcharge);
        resp.setTotalLateSurcharge(totalLateSurcharge);
        resp.setTotalSurcharges(totalEarlySurcharge.add(totalLateSurcharge));
        resp.setSameDayBooking(roomCalcs.isEmpty() ? false : roomCalcs.get(0).isSameDayBooking());
        return resp;
    }

    /**
     * Create a multi-room booking: 1 Booking parent + N BookingRoom records.
     * Room assignment is NULL (staff assigns later).
     */
    public BookingResult createMultiRoomBooking(int customerId, List<RoomSelectionItem> selections,
            LocalDateTime checkIn, LocalDateTime checkOut,
            BigDecimal totalPrice, BigDecimal earlySurcharge, BigDecimal lateSurcharge,
            Integer voucherId, String note,
            List<Occupant> occupants, String paymentType, BigDecimal depositAmount) {

        // Validate dates
        if (!DateHelper.isFutureDate(checkIn)) {
            return BookingResult.failure("Ngay nhan phong phai la ngay trong tuong lai");
        }
        if (!checkOut.isAfter(checkIn)) {
            return BookingResult.failure("Ngay tra phong phai sau ngay nhan phong");
        }

        // Create parent Booking (room_id=NULL for multi-room)
        System.out.println("[DEBUG] createMultiRoomBooking - checkIn: " + checkIn);
        System.out.println("[DEBUG] createMultiRoomBooking - checkOut: " + checkOut);
        Booking booking = new Booking();
        booking.setCustomerId(customerId);
        booking.setRoomId(null); // multi-room: no single room
        booking.setTypeId(selections.get(0).getTypeId()); // backward compat
        booking.setCheckInExpected(checkIn);
        booking.setCheckOutExpected(checkOut);
        booking.setTotalPrice(totalPrice);
        booking.setEarlySurcharge(earlySurcharge != null ? earlySurcharge : BigDecimal.ZERO);
        booking.setLateSurcharge(lateSurcharge != null ? lateSurcharge : BigDecimal.ZERO);
        booking.setVoucherId(voucherId);
        booking.setNote(note);
        booking.setStatus(BookingStatus.PENDING);
        booking.setPaymentType(paymentType != null ? paymentType : PaymentType.FULL);
        booking.setDepositAmount(depositAmount != null ? depositAmount : totalPrice);

        int bookingId = bookingRepository.insert(booking);
        if (bookingId <= 0) return BookingResult.failure("Khong the tao don dat phong");
        booking.setBookingId(bookingId);

        // Create BookingRoom records (room_id = NULL, staff assigns later)
        try {
            for (RoomSelectionItem sel : selections) {
                RoomType rt = roomTypeRepository.findById(sel.getTypeId());
                BigDecimal pricePerHour = (rt != null && rt.getPricePerHour() != null) ? rt.getPricePerHour() : BigDecimal.ZERO;
                SurchargeResult surcharge = DateHelper.calculateSurcharges(checkIn, checkOut, pricePerHour);

                long nights = DateHelper.calculateNights(checkIn, checkOut);
                BigDecimal roomPrice = surcharge.isSameDayBooking()
                    ? surcharge.getHourlyTotal()
                    : rt.getBasePrice().multiply(BigDecimal.valueOf(nights));

                // Promotion discount per room
                BigDecimal promoDiscount = BigDecimal.ZERO;
                Promotion promotion = promotionRepository.findActiveByTypeId(sel.getTypeId());
                if (promotion != null && !surcharge.isSameDayBooking()) {
                    promoDiscount = rt.getBasePrice()
                        .multiply(promotion.getDiscountPercent())
                        .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP)
                        .multiply(BigDecimal.valueOf(nights));
                }

                for (int i = 0; i < sel.getQuantity(); i++) {
                    BookingRoom br = new BookingRoom();
                    br.setBookingId(bookingId);
                    br.setRoomId(null);
                    br.setTypeId(sel.getTypeId());
                    br.setUnitPrice(roomPrice);
                    br.setEarlySurcharge(surcharge.getEarlySurcharge());
                    br.setLateSurcharge(surcharge.getLateSurcharge());
                    br.setPromotionDiscount(promoDiscount);
                    br.setStatus(BookingStatus.PENDING);
                    bookingRoomRepository.insert(br);
                }
            }
        } catch (Exception e) {
            // Rollback: cancel the booking if BookingRoom creation fails
            bookingRepository.updateStatus(bookingId, BookingStatus.CANCELLED);
            return BookingResult.failure("Loi khi tao phong: " + e.getMessage());
        }

        // Save occupants
        if (occupants != null) {
            for (Occupant occ : occupants) {
                if (occ.getFullName() != null && !occ.getFullName().trim().isEmpty()) {
                    occ.setBookingId(bookingId);
                    occ.setFullName(occ.getFullName().trim());
                    occupantRepository.insert(occ);
                }
            }
        }

        return BookingResult.success("Dat phong thanh cong", booking);
    }

    /**
     * Get booking with all BookingRoom details loaded.
     */
    public Booking getBookingWithRooms(int bookingId) {
        Booking booking = bookingRepository.findByIdWithDetails(bookingId);
        if (booking != null) {
            booking.setBookingRooms(bookingRoomRepository.findByBookingIdWithDetails(bookingId));
        }
        return booking;
    }
}
