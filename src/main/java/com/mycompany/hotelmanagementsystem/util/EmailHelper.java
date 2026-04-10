package com.mycompany.hotelmanagementsystem.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.InputStream;
import java.util.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class EmailHelper {

    private static final Logger logger = LoggerFactory.getLogger(EmailHelper.class);

    private static String smtpHost;
    private static String smtpPort;
    private static String username;
    private static String password;
    private static boolean configured = false;

    static {
        loadConfig();
    }

    private EmailHelper() {}

    private static void loadConfig() {
        // Try loading from properties file first
        System.out.println("=== EMAIL CONFIG DEBUG ===");
        try (InputStream input = EmailHelper.class.getClassLoader()
                .getResourceAsStream("mail.properties")) {
            System.out.println("InputStream: " + input);
            if (input != null) {
                Properties props = new Properties();
                props.load(input);
                smtpHost = props.getProperty("mail.smtp.host", "smtp.gmail.com");
                smtpPort = props.getProperty("mail.smtp.port", "587");
                username = props.getProperty("mail.username");
                password = props.getProperty("mail.password");
                System.out.println("SMTP Host: " + smtpHost);
                System.out.println("SMTP Port: " + smtpPort);
                System.out.println("Username: " + username);
                System.out.println("Password length: " + (password != null ? password.length() : "null"));
                configured = (username != null && password != null && !username.isEmpty() && !password.isEmpty());
                if (configured) {
                    logger.info("Email config loaded from mail.properties");
                    System.out.println("Email configured: TRUE");
                } else {
                    System.out.println("Email configured: FALSE - username or password is null/empty");
                }
            } else {
                System.out.println("mail.properties NOT FOUND in classpath!");
            }
        } catch (Exception e) {
            logger.warn("Could not load mail.properties: {}", e.getMessage());
            System.out.println("Exception loading mail.properties: " + e.getMessage());
            e.printStackTrace();
        }

        // Fallback to environment variables
        if (!configured) {
            System.out.println("Trying environment variables...");
            smtpHost = System.getenv("MAIL_SMTP_HOST");
            if (smtpHost == null) smtpHost = "smtp.gmail.com";

            smtpPort = System.getenv("MAIL_SMTP_PORT");
            if (smtpPort == null) smtpPort = "587";

            username = System.getenv("MAIL_USERNAME");
            password = System.getenv("MAIL_PASSWORD");
            System.out.println("ENV Username: " + username);
            System.out.println("ENV Password: " + (password != null ? "***" : "null"));
            configured = (username != null && password != null);
            if (configured) {
                logger.info("Email config loaded from environment variables");
            }
        }

        if (!configured) {
            logger.warn("Email not configured. Create mail.properties or set MAIL_USERNAME/MAIL_PASSWORD env vars.");
            System.out.println("=== EMAIL NOT CONFIGURED ===");
        }
        System.out.println("=== END EMAIL CONFIG DEBUG ===");
    }

    /**
     * Send OTP email for password reset
     * @param toEmail recipient email
     * @param otp the OTP code
     * @return true if sent successfully
     */
    public static boolean sendOtp(String toEmail, String otp) {
        System.out.println("=== SEND OTP DEBUG ===");
        System.out.println("To Email: " + toEmail);
        System.out.println("OTP: " + otp);
        System.out.println("Configured: " + configured);

        if (!configured) {
            logger.error("Email credentials not configured.");
            System.out.println("FAILED: Email credentials not configured");
            return false;
        }

        System.out.println("Using SMTP: " + smtpHost + ":" + smtpPort);
        System.out.println("From: " + username);

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", smtpHost);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        session.setDebug(true);

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username, "Luxury Hotel"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Ma xac thuc dat lai mat khau - Luxury Hotel");

            String htmlContent = buildOtpEmailContent(otp);
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            logger.info("OTP email sent to: {}", toEmail);
            System.out.println("=== EMAIL SENT SUCCESSFULLY ===");
            return true;

        } catch (Exception e) {
            logger.error("Failed to send OTP email to: {}", toEmail, e);
            System.out.println("=== EMAIL SEND FAILED ===");
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private static String buildOtpEmailContent(String otp) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
            </head>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                <div style="background: linear-gradient(135deg, #1a1a2e 0%%, #16213e 100%%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                    <h1 style="color: #d4af37; margin: 0;">Luxury Hotel</h1>
                </div>
                <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
                    <h2 style="color: #1a1a2e; margin-top: 0;">Dat lai mat khau</h2>
                    <p style="color: #666;">Ban da yeu cau dat lai mat khau cho tai khoan Luxury Hotel.</p>
                    <p style="color: #666;">Ma xac thuc OTP cua ban la:</p>
                    <div style="background: #1a1a2e; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
                        <span style="font-size: 32px; font-weight: bold; color: #d4af37; letter-spacing: 8px;">%s</span>
                    </div>
                    <p style="color: #666;">Ma nay se het han sau <strong>5 phut</strong>.</p>
                    <p style="color: #999; font-size: 12px;">Neu ban khong yeu cau dat lai mat khau, vui long bo qua email nay.</p>
                    <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                    <p style="color: #999; font-size: 12px; text-align: center;">© 2024 Luxury Hotel. All rights reserved.</p>
                </div>
            </body>
            </html>
            """.formatted(otp);
    }

    /**
     * Send walk-in account credentials to customer email.
     * @param toEmail recipient email
     * @param fullName customer name
     * @param generatedPassword the plain-text password
     * @return true if sent successfully
     */
    public static boolean sendWalkInCredentials(String toEmail, String fullName, String generatedPassword) {
        System.out.println("=== SEND WALK-IN CREDENTIALS DEBUG ===");
        System.out.println("To Email: " + toEmail);
        System.out.println("FullName: " + fullName);
        System.out.println("Configured: " + configured);

        if (!configured) {
            logger.warn("Email not configured - cannot send walk-in credentials to: {}", toEmail);
            System.out.println("FAILED: Email credentials not configured");
            return false;
        }

        System.out.println("Using SMTP: " + smtpHost + ":" + smtpPort);
        System.out.println("From: " + username);

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", smtpHost);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        session.setDebug(true);

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username, "Luxury Hotel"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Thong tin tai khoan - Luxury Hotel");

            String htmlContent = buildWalkInEmailContent(fullName, toEmail, generatedPassword);
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            logger.info("Walk-in credentials email sent to: {}", toEmail);
            System.out.println("=== WALK-IN EMAIL SENT SUCCESSFULLY ===");
            return true;
        } catch (Exception e) {
            logger.error("Failed to send walk-in credentials to: {}", toEmail, e);
            System.out.println("=== WALK-IN EMAIL SEND FAILED ===");
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private static String buildWalkInEmailContent(String fullName, String email, String password) {
        return """
            <!DOCTYPE html>
            <html>
            <head><meta charset="UTF-8"></head>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                <div style="background: linear-gradient(135deg, #1a1a2e 0%%, #16213e 100%%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                    <h1 style="color: #d4af37; margin: 0;">Luxury Hotel</h1>
                </div>
                <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
                    <h2 style="color: #1a1a2e; margin-top: 0;">Chao mung %s!</h2>
                    <p style="color: #666;">Tai khoan cua ban da duoc tao tai Luxury Hotel. Ban co the dang nhap de xem thong tin dat phong va su dung cac dich vu truc tuyen.</p>
                    <div style="background: #fff; padding: 20px; border-radius: 8px; border: 1px solid #ddd; margin: 20px 0;">
                        <p style="margin: 5px 0; color: #333;"><strong>Email dang nhap:</strong> %s</p>
                        <p style="margin: 5px 0; color: #333;"><strong>Mat khau:</strong> <code style="background: #f0f0f0; padding: 2px 8px; border-radius: 4px; font-size: 16px;">%s</code></p>
                    </div>
                    <p style="color: #e74c3c; font-size: 13px;"><strong>Luu y:</strong> Vui long doi mat khau sau khi dang nhap lan dau.</p>
                    <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                    <p style="color: #999; font-size: 12px; text-align: center;">Luxury Hotel - Cam on quy khach!</p>
                </div>
            </body>
            </html>
            """.formatted(fullName, email, password);
    }

    /**
     * Send booking confirmation email for both single-room and multi-room bookings.
     * @param toEmail recipient email
     * @param bookingId booking ID
     * @param customerName customer name
     * @param checkIn check-in datetime
     * @param checkOut check-out datetime
     * @param roomDetails list of room detail strings (e.g., "Phong Deluxe - 2 dem - 1,500,000d")
     * @param totalAmount total amount
     * @param depositAmount deposit amount (null or 0 if no deposit)
     * @param paymentStatus "Da thanh toan" or "Cho thanh toan"
     * @param earlySurcharge early check-in surcharge (null or 0 if none)
     * @param lateSurcharge late check-out surcharge (null or 0 if none)
     * @param promotionDiscount promotion discount (null or 0 if none)
     * @param voucherDiscount voucher discount (null or 0 if none)
     * @return true if sent successfully
     */
    public static boolean sendBookingConfirmation(String toEmail, int bookingId, String customerName,
            String checkIn, String checkOut, java.util.List<String> roomDetails,
            java.math.BigDecimal totalAmount, java.math.BigDecimal depositAmount,
            String paymentStatus, java.math.BigDecimal earlySurcharge,
            java.math.BigDecimal lateSurcharge, java.math.BigDecimal promotionDiscount,
            java.math.BigDecimal voucherDiscount) {

        System.out.println("=== SEND BOOKING CONFIRMATION DEBUG ===");
        System.out.println("To Email: " + toEmail);
        System.out.println("Booking ID: " + bookingId);
        System.out.println("Configured: " + configured);

        if (!configured) {
            logger.warn("Email not configured - cannot send booking confirmation to: {}", toEmail);
            System.out.println("FAILED: Email credentials not configured");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", smtpHost);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username, "Luxury Hotel"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Xac nhan dat phong #" + bookingId + " - Luxury Hotel");

            String htmlContent = buildBookingConfirmationEmail(
                bookingId, customerName, checkIn, checkOut, roomDetails,
                totalAmount, depositAmount, paymentStatus, earlySurcharge,
                lateSurcharge, promotionDiscount, voucherDiscount);
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            logger.info("Booking confirmation email sent to: {}", toEmail);
            System.out.println("=== BOOKING CONFIRMATION EMAIL SENT SUCCESSFULLY ===");
            return true;

        } catch (Exception e) {
            logger.error("Failed to send booking confirmation to: {}", toEmail, e);
            System.out.println("=== BOOKING CONFIRMATION EMAIL SEND FAILED ===");
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private static String buildBookingConfirmationEmail(int bookingId, String customerName,
            String checkIn, String checkOut, java.util.List<String> roomDetails,
            java.math.BigDecimal totalAmount, java.math.BigDecimal depositAmount,
            String paymentStatus, java.math.BigDecimal earlySurcharge,
            java.math.BigDecimal lateSurcharge, java.math.BigDecimal promotionDiscount,
            java.math.BigDecimal voucherDiscount) {

        StringBuilder roomsHtml = new StringBuilder();
        for (String detail : roomDetails) {
            roomsHtml.append("<li style=\"color: #666; margin-bottom: 8px;\">").append(detail).append("</li>");
        }

        StringBuilder surchargesHtml = new StringBuilder();
        if (earlySurcharge != null && earlySurcharge.compareTo(java.math.BigDecimal.ZERO) > 0) {
            surchargesHtml.append("<tr><td style=\"padding: 8px; color: #e67e22;\">Phu thu nhan som:</td>")
                .append("<td style=\"padding: 8px; text-align: right; color: #e67e22;\">+")
                .append(formatCurrency(earlySurcharge)).append("</td></tr>");
        }
        if (lateSurcharge != null && lateSurcharge.compareTo(java.math.BigDecimal.ZERO) > 0) {
            surchargesHtml.append("<tr><td style=\"padding: 8px; color: #e67e22;\">Phu thu tra muon:</td>")
                .append("<td style=\"padding: 8px; text-align: right; color: #e67e22;\">+")
                .append(formatCurrency(lateSurcharge)).append("</td></tr>");
        }

        String depositHtml = "";
        if (depositAmount != null && depositAmount.compareTo(java.math.BigDecimal.ZERO) > 0) {
            depositHtml = "<tr><td style=\"padding: 8px;\">Dat coc:</td>"
                + "<td style=\"padding: 8px; text-align: right;\">" + formatCurrency(depositAmount) + "</td></tr>"
                + "<tr><td style=\"padding: 8px; font-weight: bold;\">Con lai:</td>"
                + "<td style=\"padding: 8px; text-align: right; font-weight: bold;\">"
                + formatCurrency(totalAmount.subtract(depositAmount)) + "</td></tr>";
        }

        String promotionHtml = "";
        if (promotionDiscount != null && promotionDiscount.compareTo(java.math.BigDecimal.ZERO) > 0) {
            promotionHtml = "<tr><td style=\"padding: 8px; color: #27ae60;\">Khuyen mai:</td>"
                + "<td style=\"padding: 8px; text-align: right; color: #27ae60;\">-"
                + formatCurrency(promotionDiscount) + "</td></tr>";
        }

        String voucherHtml = "";
        if (voucherDiscount != null && voucherDiscount.compareTo(java.math.BigDecimal.ZERO) > 0) {
            voucherHtml = "<tr><td style=\"padding: 8px; color: #27ae60;\">Voucher:</td>"
                + "<td style=\"padding: 8px; text-align: right; color: #27ae60;\">-"
                + formatCurrency(voucherDiscount) + "</td></tr>";
        }

        return """
            <!DOCTYPE html>
            <html>
            <head><meta charset="UTF-8"></head>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                <div style="background: linear-gradient(135deg, #1a1a2e 0%%, #16213e 100%%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                    <h1 style="color: #d4af37; margin: 0;">Luxury Hotel</h1>
                </div>
                <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
                    <h2 style="color: #1a1a2e; margin-top: 0;">Xac nhan dat phong #%d</h2>
                    <p style="color: #666;">Xin chao <strong>%s</strong>,</p>
                    <p style="color: #666;">Cam on ban da dat phong tai Luxury Hotel. Day la email xac nhan chi tiet dat phong cua ban.</p>

                    <div style="background: #fff; padding: 20px; border-radius: 8px; border: 1px solid #ddd; margin: 20px 0;">
                        <h3 style="color: #1a1a2e; margin-top: 0; border-bottom: 2px solid #d4af37; padding-bottom: 10px;">Thong tin nhan/tra phong</h3>
                        <table style="width: 100%%; border-collapse: collapse;">
                            <tr>
                                <td style="padding: 8px; color: #666; width: 50%%;">Ngay nhan phong:</td>
                                <td style="padding: 8px; font-weight: bold; color: #1a1a2e;">%s</td>
                            </tr>
                            <tr>
                                <td style="padding: 8px; color: #666;">Ngay tra phong:</td>
                                <td style="padding: 8px; font-weight: bold; color: #1a1a2e;">%s</td>
                            </tr>
                            <tr>
                                <td style="padding: 8px; color: #666;">Trang thai thanh toan:</td>
                                <td style="padding: 8px; font-weight: bold; color: #27ae60;">%s</td>
                            </tr>
                        </table>
                    </div>

                    <div style="background: #fff; padding: 20px; border-radius: 8px; border: 1px solid #ddd; margin: 20px 0;">
                        <h3 style="color: #1a1a2e; margin-top: 0; border-bottom: 2px solid #d4af37; padding-bottom: 10px;">Chi tiet phong</h3>
                        <ul style="list-style: none; padding: 0; margin: 0;">
                            %s
                        </ul>
                    </div>

                    <div style="background: #fff; padding: 20px; border-radius: 8px; border: 1px solid #ddd; margin: 20px 0;">
                        <h3 style="color: #1a1a2e; margin-top: 0; border-bottom: 2px solid #d4af37; padding-bottom: 10px;">Chi tiet thanh toan</h3>
                        <table style="width: 100%%; border-collapse: collapse;">
                            %s
                            %s
                            %s
                            %s
                            <tr style="border-top: 2px solid #d4af37;">
                                <td style="padding: 12px 8px; font-weight: bold; font-size: 18px; color: #1a1a2e;">Tong cong:</td>
                                <td style="padding: 12px 8px; text-align: right; font-weight: bold; font-size: 18px; color: #d4af37;">%s</td>
                            </tr>
                        </table>
                    </div>

                    <p style="color: #666; font-size: 14px;">Neu ban co bat ky thac mac nao, vui long lien he voi chung toi qua so 1900 1234 hoac email support@hotel.com.</p>
                    <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                    <p style="color: #999; font-size: 12px; text-align: center;">Luxury Hotel - Cam on quy khach!</p>
                </div>
            </body>
            </html>
            """.formatted(
                bookingId,
                customerName != null ? customerName : "Quy khach",
                checkIn,
                checkOut,
                paymentStatus,
                roomsHtml.toString(),
                surchargesHtml.toString(),
                depositHtml,
                promotionHtml,
                voucherHtml,
                formatCurrency(totalAmount)
            );
    }

    private static String formatCurrency(java.math.BigDecimal amount) {
        if (amount == null) return "0d";
        return String.format("%,.0fd", amount);
    }
}
