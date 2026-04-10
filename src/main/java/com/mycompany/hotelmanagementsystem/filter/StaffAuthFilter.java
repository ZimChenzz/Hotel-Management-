package com.mycompany.hotelmanagementsystem.filter;

import com.mycompany.hotelmanagementsystem.constant.RoleConstant;
import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import com.mycompany.hotelmanagementsystem.entity.Account;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(urlPatterns = {"/staff/*"})
public class StaffAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String servletPath = httpRequest.getServletPath();
        // Check if logged in
        if (!SessionHelper.isLoggedIn(httpRequest)) {
            redirectToLogin(httpRequest, httpResponse);
            return;
        }

        // Check if user is staff
        Account account = SessionHelper.getLoggedInAccount(httpRequest);
        if (account == null || account.getRoleId() != RoleConstant.STAFF) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/auth/login?error=staff_required");
            return;
        }

        chain.doFilter(request, response);
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String loginUrl = request.getContextPath() + "/auth/login";
        String returnUrl = request.getRequestURI();
        if (request.getQueryString() != null) {
            returnUrl += "?" + request.getQueryString();
        }
        response.sendRedirect(loginUrl + "?returnUrl=" +
            URLEncoder.encode(returnUrl, StandardCharsets.UTF_8));
    }
}
