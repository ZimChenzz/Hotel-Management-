package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.BookingStatus;
import com.mycompany.hotelmanagementsystem.constant.InvoiceType;
import com.mycompany.hotelmanagementsystem.constant.PaymentStatus;
import com.mycompany.hotelmanagementsystem.constant.PaymentType;
import com.mycompany.hotelmanagementsystem.util.PaymentResult;
import com.mycompany.hotelmanagementsystem.util.SurchargeResult;
import com.mycompany.hotelmanagementsystem.entity.Booking;
import com.mycompany.hotelmanagementsystem.entity.Invoice;
import com.mycompany.hotelmanagementsystem.entity.Payment;
import com.mycompany.hotelmanagementsystem.dal.BookingRepository;
import com.mycompany.hotelmanagementsystem.dal.InvoiceRepository;
import com.mycompany.hotelmanagementsystem.dal.PaymentRepository;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;
import com.mycompany.hotelmanagementsystem.service.VNPayService;

public class StaffPaymentService {
    private final PaymentRepository paymentRepository;
    private final InvoiceRepository invoiceRepository;
    private final BookingRepository bookingRepository;

    public StaffPaymentService() {
        this.paymentRepository = new PaymentRepository();
        this.invoiceRepository = new InvoiceRepository();
        this.bookingRepository = new BookingRepository();
    }

    public Invoice getOrCreateInvoice(int bookingId) {
        return getOrCreateInvoice(bookingId, InvoiceType.BOOKING);
    }

    public Invoice getOrCreateInvoice(int bookingId, String invoiceType) {
        // Check existing invoice of this type
        Invoice existing = invoiceRepository.findByBookingIdAndType(bookingId, invoiceType);
        if (existing != null) return existing;

        Booking booking = bookingRepository.findByIdWithDetails(bookingId);
        if (booking == null) return null;

        // Get surcharge from BookingRooms
        StaffBookingService bookingService = new StaffBookingService();
        SurchargeResult surcharge = bookingService.getActualSurcharge(bookingId);
        BigDecimal surchargeAmount = surcharge.getSurchargeTotal();

        BigDecimal subtotal;
        if (InvoiceType.REMAINING.equals(invoiceType)) {
            BigDecimal deposit = booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO;
            subtotal = booking.getTotalPrice().subtract(deposit).add(surchargeAmount);
            if (subtotal.compareTo(BigDecimal.ZERO) <= 0) return null;
        } else if (PaymentType.DEPOSIT.equals(booking.getPaymentType())
                   && InvoiceType.BOOKING.equals(invoiceType)) {
            subtotal = booking.getDepositAmount() != null ? booking.getDepositAmount() : booking.getTotalPrice();
        } else {
            subtotal = booking.getTotalPrice().add(surchargeAmount);
        }

        Invoice invoice = new Invoice();
        invoice.setBookingId(bookingId);
        invoice.setIssuedDate(LocalDateTime.now());
        invoice.setTotalAmount(subtotal);
        invoice.setTaxAmount(BigDecimal.ZERO);
        invoice.setInvoiceType(invoiceType);

        int invoiceId = invoiceRepository.insert(invoice);
        if (invoiceId > 0) {
            invoice.setInvoiceId(invoiceId);
            invoice.setBooking(booking);
            return invoice;
        }
        return null;
    }

    // Create remaining balance invoice for checkout
    public Invoice createRemainingInvoice(int bookingId) {
        return getOrCreateInvoice(bookingId, InvoiceType.REMAINING);
    }

    // Check if remaining balance exists and is unpaid
    public boolean hasUnpaidRemainingBalance(int bookingId) {
        Booking booking = bookingRepository.findById(bookingId);
        if (booking == null || !PaymentType.DEPOSIT.equals(booking.getPaymentType())) {
            return false;
        }
        BigDecimal deposit = booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO;
        BigDecimal remaining = booking.getTotalPrice().subtract(deposit);
        if (remaining.compareTo(BigDecimal.ZERO) <= 0) return false;

        Invoice remainingInvoice = invoiceRepository.findByBookingIdAndType(bookingId, InvoiceType.REMAINING);
        if (remainingInvoice == null) return true; // No invoice = unpaid
        return !paymentRepository.hasSuccessfulPayment(remainingInvoice.getInvoiceId());
    }

    public Invoice getInvoiceByBookingId(int bookingId) {
        return invoiceRepository.findByBookingId(bookingId);
    }

    public Invoice getInvoiceById(int invoiceId) {
        return invoiceRepository.findById(invoiceId);
    }

    public Booking getBookingDetail(int bookingId) {
        return bookingRepository.findByIdWithDetails(bookingId);
    }

    // UC-19.7: Record Cash Payment
    public boolean recordCashPayment(int invoiceId, int customerId, BigDecimal amount) {
        Payment payment = new Payment();
        payment.setInvoiceId(invoiceId);
        payment.setCustomerId(customerId);
        payment.setPaymentMethod("Cash");
        payment.setTransactionCode(generateTransactionCode("CASH"));
        payment.setAmount(amount);
        payment.setPaymentTime(LocalDateTime.now());
        payment.setStatus(PaymentStatus.SUCCESS);

        int paymentId = paymentRepository.insert(payment);
        if (paymentId > 0) {
            // Confirm booking after successful BOOKING invoice payment (mirrors VNPay/Simulated flow)
            try {
                Invoice invoice = invoiceRepository.findById(invoiceId);
                if (invoice != null && InvoiceType.BOOKING.equals(invoice.getInvoiceType())) {
                    Booking booking = bookingRepository.findByIdWithDetails(invoice.getBookingId());
                    if (booking != null && BookingStatus.PENDING.equals(booking.getStatus())) {
                        bookingRepository.updateStatus(invoice.getBookingId(), BookingStatus.CONFIRMED);
                    }
                }
            } catch (Exception e) {
                // Payment succeeded - don't fail the whole operation for status update
                System.err.println("Warning: Cash payment recorded but booking status update failed: " + e.getMessage());
            }
            return true;
        }
        return false;
    }

    // UC-19.8: Initiate VNPay payment (staff checkout)
    public PaymentResult initiateVNPayPayment(int invoiceId, int customerId, String baseUrl, String ipAddress) {
        Invoice invoice = invoiceRepository.findById(invoiceId);
        if (invoice == null) {
            return PaymentResult.failure("Khong tim thay hoa don");
        }

        if (paymentRepository.hasSuccessfulPayment(invoiceId)) {
            return PaymentResult.failure("Hoa don da duoc thanh toan");
        }

        String txnRef = VNPayService.generateTxnRef();
        long amount = invoice.getTotalAmount().longValue();
        String orderInfo = "Thanh toan tai quay - Invoice " + invoiceId;

        Payment payment = new Payment();
        payment.setInvoiceId(invoiceId);
        payment.setCustomerId(customerId);
        payment.setPaymentMethod("VNPay");
        payment.setTransactionCode(txnRef);
        payment.setAmount(invoice.getTotalAmount());
        payment.setStatus(PaymentStatus.PENDING);

        int paymentId = paymentRepository.insert(payment);
        if (paymentId <= 0) {
            return PaymentResult.failure("Khong the tao thanh toan");
        }

        payment.setPaymentId(paymentId);

        // Use staff-specific return URL
        String paymentUrl = VNPayService.createPaymentUrl(baseUrl, txnRef, amount, orderInfo, ipAddress,
                baseUrl + "/staff/payments/vnpay-return");
        return PaymentResult.successWithUrl(payment, paymentUrl);
    }

    // Process VNPay callback for staff payment
    public PaymentResult processVNPayCallback(String txnRef, String responseCode) {
        Payment payment = paymentRepository.findByTransactionCode(txnRef);
        if (payment == null) {
            return PaymentResult.failure("Khong tim thay thanh toan");
        }

        if (!PaymentStatus.PENDING.equals(payment.getStatus())) {
            return PaymentResult.failure("Thanh toan da duoc xu ly");
        }

        boolean success = VNPayService.isPaymentSuccess(responseCode);
        String newStatus = success ? PaymentStatus.SUCCESS : PaymentStatus.FAILED;
        paymentRepository.updateStatus(payment.getPaymentId(), newStatus);
        payment.setStatus(newStatus);

        if (success) {
            Invoice invoice = invoiceRepository.findById(payment.getInvoiceId());
            if (invoice != null && InvoiceType.BOOKING.equals(invoice.getInvoiceType())) {
                Booking booking = bookingRepository.findByIdWithDetails(invoice.getBookingId());
                if (booking != null && BookingStatus.PENDING.equals(booking.getStatus())) {
                    bookingRepository.updateStatus(invoice.getBookingId(), BookingStatus.CONFIRMED);
                }
            }
        }

        return PaymentResult.success(success ? "Thanh toan thanh cong" : "Thanh toan that bai", payment);
    }

    public boolean hasSuccessfulPayment(int invoiceId) {
        return paymentRepository.hasSuccessfulPayment(invoiceId);
    }

    public Payment getPaymentByInvoiceId(int invoiceId) {
        return paymentRepository.findByInvoiceId(invoiceId);
    }

    private String generateTransactionCode(String prefix) {
        return prefix + "-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
    }

}
