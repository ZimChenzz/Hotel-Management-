package com.mycompany.hotelmanagementsystem.util;

import java.util.regex.Pattern;

public final class ValidationHelper {
    private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN =
        Pattern.compile("^(0[0-9]{9,10})$");
    private static final Pattern PASSWORD_UPPERCASE = Pattern.compile("[A-Z]");
    private static final Pattern PASSWORD_LOWERCASE = Pattern.compile("[a-z]");
    private static final Pattern PASSWORD_DIGIT = Pattern.compile("[0-9]");
    private static final Pattern PASSWORD_SPECIAL = Pattern.compile("[!@#$%^&*(),.?\":{}|<>]");

    private ValidationHelper() {}

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.isEmpty()) {
            return false; // Phone is required
        }
        return PHONE_PATTERN.matcher(phone).matches();
    }

    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        // Check at least 1 uppercase
        if (!PASSWORD_UPPERCASE.matcher(password).find()) {
            return false;
        }
        // Check at least 1 lowercase
        if (!PASSWORD_LOWERCASE.matcher(password).find()) {
            return false;
        }
        // Check at least 1 digit
        if (!PASSWORD_DIGIT.matcher(password).find()) {
            return false;
        }
        // Check at least 1 special character
        if (!PASSWORD_SPECIAL.matcher(password).find()) {
            return false;
        }
        return true;
    }

    public static String getPasswordStrengthMessage(String password) {
        if (password == null || password.isEmpty()) {
            return "Nhập mật khẩu";
        }
        if (password.length() < 8) {
            return "Mật khẩu phải có ít nhất 8 ký tự";
        }
        StringBuilder missing = new StringBuilder();
        if (!PASSWORD_UPPERCASE.matcher(password).find()) {
            missing.append("chữ hoa, ");
        }
        if (!PASSWORD_LOWERCASE.matcher(password).find()) {
            missing.append("chữ thường, ");
        }
        if (!PASSWORD_DIGIT.matcher(password).find()) {
            missing.append("số, ");
        }
        if (!PASSWORD_SPECIAL.matcher(password).find()) {
            missing.append("ký tự đặc biệt, ");
        }
        if (missing.length() > 0) {
            missing.setLength(missing.length() - 2);
            return "Cần thêm: " + missing;
        }
        return "Mật khẩu hợp lệ";
    }

    public static boolean isStrongPassword(String password) {
        return isValidPassword(password);
    }

    public static boolean isNotEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }

    public static String sanitize(String input) {
        if (input == null) return null;
        return input.trim()
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;");
    }
}
