package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.config.VNPayConfig;
import jakarta.servlet.http.HttpServletRequest;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * VNPay Sandbox Integration Service
 */
public class VNPayService {

    /**
     * Generate VNPay payment URL (default return URL)
     */
    public static String createPaymentUrl(String baseUrl, String txnRef, long amount,
            String orderInfo, String ipAddress) {
        return createPaymentUrl(baseUrl, txnRef, amount, orderInfo, ipAddress,
                baseUrl + "/payment/vnpay-return");
    }

    /**
     * Generate VNPay payment URL with custom return URL
     */
    public static String createPaymentUrl(String baseUrl, String txnRef, long amount,
            String orderInfo, String ipAddress, String returnUrl) {

        Map<String, String> vnp_Params = new HashMap<>();

        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnp_CreateDate = formatter.format(cld.getTime());
        cld.add(Calendar.MINUTE, VNPayConfig.VNP_EXPIRE_MINUTES);
        String vnp_ExpireDate = formatter.format(cld.getTime());

        vnp_Params.put("vnp_Version", VNPayConfig.VNP_VERSION);
        vnp_Params.put("vnp_Command", VNPayConfig.VNP_COMMAND);
        vnp_Params.put("vnp_TmnCode", VNPayConfig.VNP_TMN_CODE);
        vnp_Params.put("vnp_Amount", String.valueOf(amount * 100));
        vnp_Params.put("vnp_CurrCode", VNPayConfig.VNP_CURR_CODE);
        vnp_Params.put("vnp_TxnRef", txnRef);
        vnp_Params.put("vnp_OrderInfo", orderInfo);
        vnp_Params.put("vnp_OrderType", VNPayConfig.VNP_ORDER_TYPE);
        vnp_Params.put("vnp_Locale", VNPayConfig.VNP_LOCALE);
        vnp_Params.put("vnp_ReturnUrl", returnUrl);
        vnp_Params.put("vnp_IpAddr", ipAddress);
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

        // Sort fields
        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);

        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();

        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = vnp_Params.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                // Build hash data - encode VALUE only (key không encode)
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                // Build query - encode cả key và value
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII));
                query.append('=');
                query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }

        String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashData.toString());
        query.append("&vnp_SecureHash=").append(vnp_SecureHash);

        return VNPayConfig.VNP_PAY_URL + "?" + query;
    }

    /**
     * Verify VNPay callback signature
     */
    public static boolean verifySignature(Map<String, String> params) {
        String receivedHash = params.get("vnp_SecureHash");
        if (receivedHash == null) return false;

        Map<String, String> sortedParams = new TreeMap<>(params);
        sortedParams.remove("vnp_SecureHash");
        sortedParams.remove("vnp_SecureHashType");

        StringBuilder hashData = new StringBuilder();
        Iterator<Map.Entry<String, String>> itr = sortedParams.entrySet().iterator();
        while (itr.hasNext()) {
            Map.Entry<String, String> entry = itr.next();
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                hashData.append(entry.getKey());
                hashData.append('=');
                hashData.append(URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII));
                if (itr.hasNext()) {
                    hashData.append('&');
                }
            }
        }

        String calculatedHash = VNPayConfig.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashData.toString());
        return calculatedHash.equalsIgnoreCase(receivedHash);
    }

    /**
     * Check if payment is successful
     */
    public static boolean isPaymentSuccess(String responseCode) {
        return "00".equals(responseCode);
    }

    /**
     * Generate transaction reference
     */
    public static String generateTxnRef() {
        return VNPayConfig.getRandomNumber(8);
    }

    /**
     * Get client IP address
     */
    public static String getIpAddress(HttpServletRequest request) {
        return VNPayConfig.getIpAddress(request);
    }
}
