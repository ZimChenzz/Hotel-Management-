package com.mycompany.hotelmanagementsystem.controller.common;

import com.mycompany.hotelmanagementsystem.service.PaymentService;
import com.mycompany.hotelmanagementsystem.service.VNPayService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * VNPay IPN (Instant Payment Notification) endpoint.
 * Server-to-server callback from VNPay to confirm payment status.
 */
@WebServlet(urlPatterns = {"/payment/vnpay-ipn"})
public class VNPayIPNController extends HttpServlet {
    private PaymentService paymentService;

    @Override
    public void init() {
        paymentService = new PaymentService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // Extract all VNPay parameters
        Map<String, String> params = new HashMap<>();
        request.getParameterMap().forEach((key, values) -> {
            if (values != null && values.length > 0) {
                params.put(key, values[0]);
            }
        });

        // Verify HMAC signature
        if (!VNPayService.verifySignature(params)) {
            sendIPNResponse(response, "97", "Invalid Checksum");
            return;
        }

        String txnRef = params.get("vnp_TxnRef");
        String responseCode = params.get("vnp_ResponseCode");
        String amountStr = params.get("vnp_Amount");

        if (txnRef == null || responseCode == null || amountStr == null) {
            sendIPNResponse(response, "99", "Invalid request");
            return;
        }

        try {
            long vnpAmount = Long.parseLong(amountStr);
            String[] result = paymentService.processVNPayIPN(txnRef, responseCode, vnpAmount);
            sendIPNResponse(response, result[0], result[1]);
        } catch (NumberFormatException e) {
            sendIPNResponse(response, "99", "Invalid amount format");
        }
    }

    private void sendIPNResponse(HttpServletResponse response, String rspCode, String message)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"RspCode\":\"" + rspCode + "\",\"Message\":\"" + message + "\"}");
            out.flush();
        }
    }
}
