package com.mycompany.hotelmanagementsystem.util;

import java.security.SecureRandom;

public final class OtpHelper {

    private static final SecureRandom random = new SecureRandom();
    public static final long OTP_EXPIRY_MILLIS = 5 * 60 * 1000; // 5 minutes

    private OtpHelper() {}

    /**
     * Generate a random 6-digit OTP
     * @return OTP string (e.g., "123456")
     */
    public static String generateOtp() {
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    /**
     * Check if OTP has expired
     * @param expiryTime the expiry timestamp
     * @return true if expired
     */
    public static boolean isExpired(long expiryTime) {
        return System.currentTimeMillis() > expiryTime;
    }

    /**
     * Get expiry time for new OTP
     * @return expiry timestamp
     */
    public static long getExpiryTime() {
        return System.currentTimeMillis() + OTP_EXPIRY_MILLIS;
    }
}
