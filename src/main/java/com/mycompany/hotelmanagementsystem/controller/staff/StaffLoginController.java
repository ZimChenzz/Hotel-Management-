package com.mycompany.hotelmanagementsystem.controller.staff;

import com.mycompany.hotelmanagementsystem.constant.RoleConstant;
import com.mycompany.hotelmanagementsystem.util.AuthResult;
import com.mycompany.hotelmanagementsystem.util.SessionHelper;
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

@WebServlet(urlPatterns = {"/staff/login"})
public class StaffLoginController extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (SessionHelper.isLoggedIn(request)) {
            Account account = SessionHelper.getLoggedInAccount(request);
            if (account != null && account.getRoleId() == RoleConstant.STAFF) {
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                return;
            }
        }
        request.getRequestDispatcher("/WEB-INF/views/staff/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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
            request.getRequestDispatcher("/WEB-INF/views/staff/login.jsp").forward(request, response);
            return;
        }

        Account account = result.getAccount();

        if (account.getRoleId() != RoleConstant.STAFF) {
            request.setAttribute("error", "Tài khoản này không có quyền truy cập cổng nhân viên");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/staff/login.jsp").forward(request, response);
            return;
        }

        request.getSession().invalidate();
        SessionHelper.setLoggedInAccount(request, account);

        if (returnUrl != null && !returnUrl.isEmpty()) {
            returnUrl = URLDecoder.decode(returnUrl, StandardCharsets.UTF_8);
            if (returnUrl.startsWith(request.getContextPath())) {
                response.sendRedirect(returnUrl);
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/staff/dashboard");
    }
}
