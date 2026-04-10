package com.mycompany.hotelmanagementsystem.filter;

import com.mycompany.hotelmanagementsystem.util.SessionHelper;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(urlPatterns = {"/customer/*", "/booking/*", "/payment/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        if (!SessionHelper.isLoggedIn(httpRequest)) {
            String loginUrl = httpRequest.getContextPath() + "/auth/login";
            String returnUrl = httpRequest.getRequestURI();
            if (httpRequest.getQueryString() != null) {
                returnUrl += "?" + httpRequest.getQueryString();
            }
            httpResponse.sendRedirect(loginUrl + "?returnUrl=" +
                URLEncoder.encode(returnUrl, StandardCharsets.UTF_8));
            return;
        }

        chain.doFilter(request, response);
    }
}
