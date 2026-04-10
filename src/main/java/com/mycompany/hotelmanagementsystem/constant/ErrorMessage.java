package com.mycompany.hotelmanagementsystem.constant;

public final class ErrorMessage {
    public static final String INVALID_EMAIL = "Email không hợp lệ";
    public static final String INVALID_PASSWORD = "Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt";
    public static final String EMAIL_EXISTS = "Email đã được đăng ký";
    public static final String INVALID_CREDENTIALS = "Email hoặc mật khẩu không đúng";
    public static final String ACCOUNT_INACTIVE = "Tài khoản đã bị vô hiệu hóa";
    public static final String PASSWORDS_NOT_MATCH = "Mật khẩu xác nhận không khớp";
    public static final String ROOM_NOT_AVAILABLE = "Phòng không khả dụng trong thời gian đã chọn";
    public static final String BOOKING_NOT_FOUND = "Không tìm thấy thông tin đặt phòng";
    public static final String UNAUTHORIZED = "Vui lòng đăng nhập để tiếp tục";
    public static final String INVALID_PHONE = "Số điện thoại không hợp lệ (phải bắt đầu bằng 0, 10-11 số)";

    private ErrorMessage() {}
}
