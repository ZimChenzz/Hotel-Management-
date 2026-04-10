package com.mycompany.hotelmanagementsystem.util;

import com.mycompany.hotelmanagementsystem.entity.Payment;

public class PaymentResult {
    private boolean success;
    private String message;
    private Payment payment;
    private String paymentUrl;

    public PaymentResult(boolean success, String message, Payment payment, String paymentUrl) {
        this.success = success;
        this.message = message;
        this.payment = payment;
        this.paymentUrl = paymentUrl;
    }

    public static PaymentResult success(String message, Payment payment) {
        return new PaymentResult(true, message, payment, null);
    }

    public static PaymentResult successWithUrl(Payment payment, String paymentUrl) {
        return new PaymentResult(true, "Success", payment, paymentUrl);
    }

    public static PaymentResult failure(String message) {
        return new PaymentResult(false, message, null, null);
    }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public Payment getPayment() { return payment; }
    public String getPaymentUrl() { return paymentUrl; }
}
