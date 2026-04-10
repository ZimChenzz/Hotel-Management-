package com.mycompany.hotelmanagementsystem.controller.common;

import com.mycompany.hotelmanagementsystem.util.AuthResult;
import com.mycompany.hotelmanagementsystem.constant.RoleConstant;
import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import com.mycompany.hotelmanagementsystem.util.OtpHelper;
import com.mycompany.hotelmanagementsystem.util.GoogleOAuthHelper;
import com.mycompany.hotelmanagementsystem.service.AuthService;
import com.mycompany.hotelmanagementsystem.entity.Account;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

@WebServlet(urlPatterns = {"/auth/register", "/auth/login", "/auth/logout", "/auth/change-password", "/auth/forgot-password", "/auth/verify-otp", "/auth/reset-password", "/auth/google", "/auth/google-callback", "/auth/complete-profile"})
public class AuthController extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/auth/register" -> handleRegisterGet(request, response);
            case "/auth/login" -> handleLoginGet(request, response);
            case "/auth/logout" -> handleLogout(request, response);
            case "/auth/change-password" -> handleChangePasswordGet(request, response);
            case "/auth/forgot-password" -> handleForgotPasswordGet(request, response);
            case "/auth/verify-otp" -> handleVerifyOtpGet(request, response);
            case "/auth/reset-password" -> handleResetPasswordGet(request, response);
            case "/auth/google" -> handleGoogleLogin(request, response);
            case "/auth/google-callback" -> handleGoogleCallback(request, response);
            case "/auth/complete-profile" -> handleCompleteProfileGet(request, response);
            default -> response.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/auth/register" -> handleRegisterPost(request, response);
            case "/auth/login" -> handleLoginPost(request, response);
            case "/auth/change-password" -> handleChangePasswordPost(request, response);
            case "/auth/forgot-password" -> handleForgotPasswordPost(request, response);
            case "/auth/verify-otp" -> handleVerifyOtpPost(request, response);
            case "/auth/reset-password" -> handleResetPasswordPost(request, response);
            case "/auth/complete-profile" -> handleCompleteProfilePost(request, response);
            default -> response.sendError(404);
        }
    }

    private void handleRegisterGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (SessionHelper.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    }

    private void handleRegisterPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Dùng Account entity thay cho RegisterRequest
        Account account = new Account();
        account.setEmail(request.getParameter("email"));
        account.setPassword(request.getParameter("password"));
        account.setFullName(request.getParameter("fullName"));
        account.setPhone(request.getParameter("phone"));
        account.setAddress(request.getParameter("address"));
        String confirmPassword = request.getParameter("confirmPassword");

        AuthResult result = authService.register(account, confirmPassword);

        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("email", account.getEmail());
            request.setAttribute("fullName", account.getFullName());
            request.setAttribute("phone", account.getPhone());
            request.setAttribute("address", account.getAddress());
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        // Auto-login after registration
        SessionHelper.setLoggedInAccount(request, result.getAccount());
        response.sendRedirect(request.getContextPath() + "/");
    }

    private void handleLoginGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (SessionHelper.isLoggedIn(request)) {
            Account account = SessionHelper.getLoggedInAccount(request);
            if (account != null) {
                redirectByRole(request, response, account.getRoleId());
                return;
            }
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    private void handleLoginPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Dùng inline params thay cho LoginRequest
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String returnUrl = request.getParameter("returnUrl");

        AuthResult result = authService.login(email, password);

        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("email", email);
            request.setAttribute("returnUrl", returnUrl);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        Account account = result.getAccount();

        // Regenerate session to prevent fixation
        request.getSession().invalidate();
        SessionHelper.setLoggedInAccount(request, account);

        // Redirect to return URL if valid
        if (returnUrl != null && !returnUrl.isEmpty()) {
            returnUrl = URLDecoder.decode(returnUrl, StandardCharsets.UTF_8);
            if (returnUrl.startsWith(request.getContextPath())) {
                response.sendRedirect(returnUrl);
                return;
            }
        }

        // Role-based redirect
        redirectByRole(request, response, account.getRoleId());
    }

    private void redirectByRole(HttpServletRequest request, HttpServletResponse response, int roleId)
            throws IOException {
        String contextPath = request.getContextPath();
        switch (roleId) {
            case RoleConstant.ADMIN:
                response.sendRedirect(contextPath + "/admin/dashboard");
                break;
            case RoleConstant.STAFF:
                response.sendRedirect(contextPath + "/staff/dashboard");
                break;
            default:
                response.sendRedirect(contextPath + "/");
                break;
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        SessionHelper.logout(request);
        response.sendRedirect(request.getContextPath() + "/auth/login");
    }

    private void handleChangePasswordGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SessionHelper.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(request, response);
    }

    private void handleChangePasswordPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        // Dùng inline params thay cho ChangePasswordRequest
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        AuthResult result = authService.changePassword(account.getAccountId(), currentPassword, newPassword, confirmPassword);

        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
        } else {
            request.setAttribute("success", result.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(request, response);
    }

    // ==================== FORGOT PASSWORD ====================

    private void handleForgotPasswordGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (SessionHelper.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
    }

    private void handleForgotPasswordPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");

        AuthResult result = authService.sendOtp(email);

        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // Store OTP in session
        if (result.getAccount() != null) {
            var session = request.getSession();
            session.setAttribute("forgot_otp", result.getAccount().getPassword()); // OTP stored temporarily
            session.setAttribute("forgot_email", result.getAccount().getEmail());
            session.setAttribute("forgot_expiry", OtpHelper.getExpiryTime());
        }

        request.setAttribute("success", result.getMessage());
        response.sendRedirect(request.getContextPath() + "/auth/verify-otp");
    }

    // ==================== VERIFY OTP ====================

    private void handleVerifyOtpGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        var session = request.getSession(false);
        if (session == null || session.getAttribute("forgot_email") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/forgot-password");
            return;
        }
        request.setAttribute("email", session.getAttribute("forgot_email"));
        request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
    }

    private void handleVerifyOtpPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        var session = request.getSession(false);
        if (session == null || session.getAttribute("forgot_email") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/forgot-password");
            return;
        }

        String inputOtp = request.getParameter("otp");
        String sessionOtp = (String) session.getAttribute("forgot_otp");
        Long expiryTime = (Long) session.getAttribute("forgot_expiry");

        if (expiryTime == null || !authService.verifyOtp(inputOtp, sessionOtp, expiryTime)) {
            request.setAttribute("error", "Ma OTP khong hop le hoac da het han");
            request.setAttribute("email", session.getAttribute("forgot_email"));
            request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        // Mark OTP as verified
        session.setAttribute("otp_verified", true);
        response.sendRedirect(request.getContextPath() + "/auth/reset-password");
    }

    // ==================== RESET PASSWORD ====================

    private void handleResetPasswordGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        var session = request.getSession(false);
        if (session == null || session.getAttribute("otp_verified") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/forgot-password");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
    }

    private void handleResetPasswordPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        var session = request.getSession(false);
        if (session == null || session.getAttribute("otp_verified") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/forgot-password");
            return;
        }

        String email = (String) session.getAttribute("forgot_email");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        AuthResult result = authService.resetPassword(email, newPassword, confirmPassword);

        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Clear all forgot password session attributes
        session.removeAttribute("forgot_otp");
        session.removeAttribute("forgot_email");
        session.removeAttribute("forgot_expiry");
        session.removeAttribute("otp_verified");

        response.sendRedirect(request.getContextPath() + "/auth/login?reset=success");
    }

    // ==================== GOOGLE OAUTH ====================

    private void handleGoogleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!GoogleOAuthHelper.isConfigured()) {
            response.sendRedirect(request.getContextPath() + "/auth/login?error=google_not_configured");
            return;
        }

        // Generate state token for CSRF protection
        String state = UUID.randomUUID().toString();
        request.getSession().setAttribute("oauth_state", state);

        String authUrl = GoogleOAuthHelper.getAuthorizationUrl(state);
        response.sendRedirect(authUrl);
    }

    private void handleGoogleCallback(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        String state = request.getParameter("state");
        String error = request.getParameter("error");

        // Check for error from Google
        if (error != null) {
            response.sendRedirect(request.getContextPath() + "/auth/login?error=google_denied");
            return;
        }

        // Verify state token
        var session = request.getSession();
        String savedState = (String) session.getAttribute("oauth_state");
        session.removeAttribute("oauth_state");

        if (state == null || !state.equals(savedState)) {
            response.sendRedirect(request.getContextPath() + "/auth/login?error=invalid_state");
            return;
        }

        if (code == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login?error=no_code");
            return;
        }

        AuthResult result = authService.loginWithGoogle(code);

        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        Account account = result.getAccount();

        // Regenerate session to prevent fixation
        session.invalidate();
        SessionHelper.setLoggedInAccount(request, account);

        // Check if new user needs to complete profile
        if ("NEW_USER".equals(result.getMessage())) {
            response.sendRedirect(request.getContextPath() + "/auth/complete-profile");
            return;
        }

        // Role-based redirect
        redirectByRole(request, response, account.getRoleId());
    }

    // ==================== COMPLETE PROFILE ====================

    private void handleCompleteProfileGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SessionHelper.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        Account account = SessionHelper.getLoggedInAccount(request);
        request.setAttribute("account", account);
        request.getRequestDispatcher("/WEB-INF/views/auth/complete-profile.jsp").forward(request, response);
    }

    private void handleCompleteProfilePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account account = SessionHelper.getLoggedInAccount(request);
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        AuthResult result = authService.completeProfile(account.getAccountId(), phone, address);

        if (!result.isSuccess()) {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("account", account);
            request.getRequestDispatcher("/WEB-INF/views/auth/complete-profile.jsp").forward(request, response);
            return;
        }

        // Update session with new account info
        SessionHelper.setLoggedInAccount(request, result.getAccount());

        // Redirect to home
        response.sendRedirect(request.getContextPath() + "/");
    }
}
