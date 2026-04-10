package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.BookingStatus;
import com.mycompany.hotelmanagementsystem.constant.InvoiceType;
import com.mycompany.hotelmanagementsystem.entity.*;
import com.mycompany.hotelmanagementsystem.dal.*;
import com.mycompany.hotelmanagementsystem.dal.BookingRoomRepository;
import com.mycompany.hotelmanagementsystem.entity.BookingRoom;
import com.mycompany.hotelmanagementsystem.util.ExtensionCalcResponse;
import com.mycompany.hotelmanagementsystem.util.ServiceResult;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

public class BookingExtensionService {
    private static final int HOURLY_THRESHOLD = 12;
    private static final BigDecimal TAX_RATE = new BigDecimal("0.10");

    private final BookingRepository bookingRepository;
    private final BookingExtensionRepository extensionRepository;
    private final RoomTypeRepository roomTypeRepository;
    private final InvoiceRepository invoiceRepository;
    private final BookingRoomRepository bookingRoomRepository;

    public BookingExtensionService() {
        this.bookingRepository = new BookingRepository();
        this.extensionRepository = new BookingExtensionRepository();
        this.roomTypeRepository = new RoomTypeRepository();
        this.invoiceRepository = new InvoiceRepository();
        this.bookingRoomRepository = new BookingRoomRepository();
    }

    /**
     * Check if a booking can be extended.
     * Conditions: status = CHECKED_IN, no future bookings on same room.
     */
    public ServiceResult canExtend(int bookingId) {
        Booking booking = bookingRepository.findByIdWithDetails(bookingId);
        if (booking == null) {
            return ServiceResult.failure("Khong tim thay dat phong");
        }
        if (!BookingStatus.CHECKED_IN.equals(booking.getStatus())) {
            return ServiceResult.failure("Chi co the gia han khi da check-in");
        }
        boolean hasConflict = bookingRepository.hasConflictAfterDate(
            booking.getRoomId(), booking.getCheckOutExpected());
        if (hasConflict) {
            return ServiceResult.failure("Phong da co nguoi dat sau thoi gian tra phong, khong the gia han");
        }
        return ServiceResult.success("Co the gia han");
    }

    /**
     * Calculate extension pricing.
     * <= 12h: charge per hour (price_per_hour * hours)
     * > 12h: charge per night (ceil(hours/24) * base_price)
     */
    public ExtensionCalcResponse calculateExtension(int bookingId, int extraHours) {
        if (extraHours <= 0) return null;

        Booking booking = bookingRepository.findByIdWithDetails(bookingId);
        if (booking == null) return null;

        RoomType roomType = getRoomTypeFromBooking(booking);
        if (roomType == null) return null;

        BigDecimal price;
        boolean isHourly;

        if (extraHours <= HOURLY_THRESHOLD) {
            // Hourly rate
            price = roomType.getPricePerHour().multiply(BigDecimal.valueOf(extraHours));
            isHourly = true;
        } else {
            // Nightly rate: ceil(hours / 24) * base_price
            int nights = (int) Math.ceil(extraHours / 24.0);
            price = roomType.getBasePrice().multiply(BigDecimal.valueOf(nights));
            isHourly = false;
        }

        LocalDateTime originalCheckOut = booking.getCheckOutExpected();
        LocalDateTime newCheckOut = originalCheckOut.plusHours(extraHours);

        ExtensionCalcResponse response = new ExtensionCalcResponse();
        response.setBookingId(bookingId);
        response.setOriginalCheckOut(originalCheckOut);
        response.setNewCheckOut(newCheckOut);
        response.setExtraHours(extraHours);
        response.setExtensionPrice(price);
        response.setPricePerHour(roomType.getPricePerHour());
        response.setBasePrice(roomType.getBasePrice());
        response.setHourlyRate(isHourly);
        return response;
    }

    /**
     * Request a booking extension: validate, create extension record + invoice.
     * Returns extensionId in ServiceResult message for payment redirect.
     */
    public ServiceResult requestExtension(int bookingId, int extraHours) {
        // Validate
        ServiceResult canExtendResult = canExtend(bookingId);
        if (!canExtendResult.isSuccess()) {
            return canExtendResult;
        }

        // Calculate price
        ExtensionCalcResponse calc = calculateExtension(bookingId, extraHours);
        if (calc == null) {
            return ServiceResult.failure("Khong the tinh gia gia han");
        }

        // Create BookingExtension record
        BookingExtension ext = new BookingExtension();
        ext.setBookingId(bookingId);
        ext.setOriginalCheckOut(calc.getOriginalCheckOut());
        ext.setNewCheckOut(calc.getNewCheckOut());
        ext.setExtensionHours(extraHours);
        ext.setExtensionPrice(calc.getExtensionPrice());
        ext.setStatus("Pending");

        int extensionId = extensionRepository.insert(ext);
        if (extensionId <= 0) {
            return ServiceResult.failure("Khong the tao yeu cau gia han");
        }

        // Create extension invoice
        BigDecimal taxAmount = calc.getExtensionPrice()
            .multiply(TAX_RATE).setScale(0, RoundingMode.HALF_UP);
        BigDecimal totalAmount = calc.getExtensionPrice().add(taxAmount);

        Invoice invoice = new Invoice();
        invoice.setBookingId(bookingId);
        invoice.setTotalAmount(totalAmount);
        invoice.setTaxAmount(taxAmount);
        invoice.setInvoiceType(InvoiceType.EXTENSION);

        int invoiceId = invoiceRepository.insert(invoice);
        if (invoiceId <= 0) {
            return ServiceResult.failure("Khong the tao hoa don gia han");
        }

        // Return extensionId + invoiceId separated by comma for controller to use
        return ServiceResult.success(extensionId + "," + invoiceId);
    }

    /**
     * Confirm extension after payment: update extension status, update booking checkout.
     */
    public boolean confirmExtension(int extensionId) {
        BookingExtension ext = extensionRepository.findById(extensionId);
        if (ext == null) return false;

        // Update extension status
        extensionRepository.updateStatus(extensionId, "Confirmed");

        // Update booking check_out_expected
        bookingRepository.updateCheckOutExpected(ext.getBookingId(), ext.getNewCheckOut());

        return true;
    }

    /**
     * Get all extensions for a booking.
     */
    public List<BookingExtension> getExtensionsByBooking(int bookingId) {
        return extensionRepository.findByBookingId(bookingId);
    }

    public BookingExtension getExtensionById(int extensionId) {
        return extensionRepository.findById(extensionId);
    }

    private RoomType getRoomTypeFromBooking(Booking booking) {
        // Direct roomType from findByIdWithDetails
        if (booking.getRoomType() != null) {
            return booking.getRoomType();
        }
        if (booking.getRoom() != null && booking.getRoom().getRoomType() != null) {
            return booking.getRoom().getRoomType();
        }
        // Fallback: lookup by typeId
        return roomTypeRepository.findById(booking.getTypeId());
    }

    /**
     * Check if a specific BookingRoom can be extended.
     * Used for multi-room bookings where each room extends independently.
     */
    public ServiceResult canExtendRoom(int bookingRoomId) {
        BookingRoom br = bookingRoomRepository.findById(bookingRoomId);
        if (br == null) {
            return ServiceResult.failure("Khong tim thay phong dat");
        }
        if (!BookingStatus.CHECKED_IN.equals(br.getStatus())) {
            return ServiceResult.failure("Chi co the gia han khi da check-in");
        }
        if (br.getRoomId() == null) {
            return ServiceResult.failure("Phong chua duoc gan, khong the gia han");
        }

        Booking booking = bookingRepository.findById(br.getBookingId());
        if (booking == null) {
            return ServiceResult.failure("Khong tim thay don dat phong");
        }

        boolean hasConflict = bookingRepository.hasConflictAfterDate(
            br.getRoomId(), booking.getCheckOutExpected());
        if (hasConflict) {
            return ServiceResult.failure("Phong da co nguoi dat sau thoi gian tra phong, khong the gia han");
        }
        return ServiceResult.success("Co the gia han phong");
    }

    /**
     * Calculate extension pricing for a specific BookingRoom.
     */
    public ExtensionCalcResponse calculateRoomExtension(int bookingRoomId, int extraHours) {
        if (extraHours <= 0) return null;

        BookingRoom br = bookingRoomRepository.findById(bookingRoomId);
        if (br == null) return null;

        Booking booking = bookingRepository.findByIdWithDetails(br.getBookingId());
        if (booking == null) return null;

        RoomType roomType = roomTypeRepository.findById(br.getTypeId());
        if (roomType == null) return null;

        BigDecimal price;
        boolean isHourly;

        if (extraHours <= HOURLY_THRESHOLD) {
            price = roomType.getPricePerHour().multiply(BigDecimal.valueOf(extraHours));
            isHourly = true;
        } else {
            int nights = (int) Math.ceil(extraHours / 24.0);
            price = roomType.getBasePrice().multiply(BigDecimal.valueOf(nights));
            isHourly = false;
        }

        LocalDateTime originalCheckOut = booking.getCheckOutExpected();
        LocalDateTime newCheckOut = originalCheckOut.plusHours(extraHours);

        ExtensionCalcResponse response = new ExtensionCalcResponse();
        response.setBookingId(br.getBookingId());
        response.setOriginalCheckOut(originalCheckOut);
        response.setNewCheckOut(newCheckOut);
        response.setExtraHours(extraHours);
        response.setExtensionPrice(price);
        response.setPricePerHour(roomType.getPricePerHour());
        response.setBasePrice(roomType.getBasePrice());
        response.setHourlyRate(isHourly);
        return response;
    }

    /**
     * Request extension for a specific BookingRoom.
     * Creates BookingExtension with booking_room_id.
     */
    public ServiceResult requestRoomExtension(int bookingRoomId, int extraHours) {
        ServiceResult canExtendResult = canExtendRoom(bookingRoomId);
        if (!canExtendResult.isSuccess()) {
            return canExtendResult;
        }

        ExtensionCalcResponse calc = calculateRoomExtension(bookingRoomId, extraHours);
        if (calc == null) {
            return ServiceResult.failure("Khong the tinh gia gia han");
        }

        BookingRoom br = bookingRoomRepository.findById(bookingRoomId);

        BookingExtension ext = new BookingExtension();
        ext.setBookingId(br.getBookingId());
        ext.setBookingRoomId(bookingRoomId);
        ext.setOriginalCheckOut(calc.getOriginalCheckOut());
        ext.setNewCheckOut(calc.getNewCheckOut());
        ext.setExtensionHours(extraHours);
        ext.setExtensionPrice(calc.getExtensionPrice());
        ext.setStatus("Pending");

        int extensionId = extensionRepository.insertForRoom(ext);
        if (extensionId <= 0) {
            return ServiceResult.failure("Khong the tao yeu cau gia han");
        }

        // Create extension invoice
        BigDecimal taxAmount = calc.getExtensionPrice()
            .multiply(TAX_RATE).setScale(0, RoundingMode.HALF_UP);
        BigDecimal totalAmount = calc.getExtensionPrice().add(taxAmount);

        Invoice invoice = new Invoice();
        invoice.setBookingId(br.getBookingId());
        invoice.setTotalAmount(totalAmount);
        invoice.setTaxAmount(taxAmount);
        invoice.setInvoiceType(InvoiceType.EXTENSION);

        int invoiceId = invoiceRepository.insert(invoice);
        if (invoiceId <= 0) {
            return ServiceResult.failure("Khong the tao hoa don gia han");
        }

        return ServiceResult.success(extensionId + "," + invoiceId);
    }

    /**
     * Get extensions for a specific BookingRoom.
     */
    public List<BookingExtension> getExtensionsByBookingRoom(int bookingRoomId) {
        return extensionRepository.findByBookingRoomId(bookingRoomId);
    }
}
