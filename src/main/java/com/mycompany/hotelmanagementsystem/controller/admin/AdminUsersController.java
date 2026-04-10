package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.entity.Account;
import com.mycompany.hotelmanagementsystem.dal.AccountRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/admin/users", "/admin/users/save", "/admin/users/toggle-status", "/admin/users/reset-password"})
public class AdminUsersController extends HttpServlet {
    private AccountRepository accountRepository;

    @Override
    public void init() {
        accountRepository = new AccountRepository();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/users".equals(path)) {
            handleList(request, response);
        } else {
            response.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/admin/users/save" -> handleSave(request, response);
            case "/admin/users/toggle-status" -> handleToggleStatus(request, response);
            case "/admin/users/reset-password" -> handleResetPassword(request, response);
            default -> response.sendError(404);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Account> users = accountRepository.findAll();

        String search = request.getParameter("search");
        String roleFilter = request.getParameter("role");
        String statusFilter = request.getParameter("status");

        if (search != null && !search.isBlank()) {
            final String q = search.toLowerCase();
            users = users.stream()
                .filter(u -> (u.getFullName() != null && u.getFullName().toLowerCase().contains(q))
                    || (u.getEmail() != null && u.getEmail().toLowerCase().contains(q)))
                .collect(Collectors.toList());
        }
        if (roleFilter != null && !roleFilter.isBlank()) {
            try {
                int roleId = Integer.parseInt(roleFilter);
                users = users.stream().filter(u -> u.getRoleId() == roleId).collect(Collectors.toList());
            } catch (NumberFormatException ignored) {}
        }
        if ("active".equals(statusFilter)) {
            users = users.stream().filter(Account::isActive).collect(Collectors.toList());
        } else if ("inactive".equals(statusFilter)) {
            users = users.stream().filter(u -> !u.isActive()).collect(Collectors.toList());
        }

        request.setAttribute("users", users);
        request.setAttribute("activePage", "users");
        request.setAttribute("pageTitle", "Quản lý người dùng");
        request.getRequestDispatcher("/WEB-INF/views/admin/users/list.jsp").forward(request, response);
    }

    private void handleSave(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("id");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String roleIdStr = request.getParameter("roleId");
        String password = request.getParameter("password");

        if (idStr == null || idStr.isBlank()) {
            // Create new user
            if (accountRepository.existsByEmail(email)) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=email_exists");
                return;
            }
            Account account = new Account();
            account.setEmail(email);
            account.setFullName(fullName);
            account.setPhone(phone);
            account.setActive(true);
            try { account.setRoleId(Integer.parseInt(roleIdStr)); } catch (NumberFormatException e) { account.setRoleId(3); }
            if (password != null && !password.isBlank()) {
                account.setPassword(org.mindrot.jbcrypt.BCrypt.hashpw(password, org.mindrot.jbcrypt.BCrypt.gensalt()));
            }
            accountRepository.insert(account);
            response.sendRedirect(request.getContextPath() + "/admin/users?success=created");
        } else {
            // Update existing user
            int id = Integer.parseInt(idStr);
            Account account = accountRepository.findById(id);
            if (account != null) {
                account.setFullName(fullName);
                account.setPhone(phone);
                try { accountRepository.updateRoleId(id, Integer.parseInt(roleIdStr)); } catch (NumberFormatException ignored) {}
                accountRepository.update(account);
                if (password != null && !password.isBlank()) {
                    accountRepository.updatePassword(id, org.mindrot.jbcrypt.BCrypt.hashpw(password, org.mindrot.jbcrypt.BCrypt.gensalt()));
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/users?success=updated");
        }
    }

    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean active = Boolean.parseBoolean(request.getParameter("active"));
            accountRepository.updateIsActive(id, active);
        } catch (NumberFormatException ignored) {}
        response.sendRedirect(request.getContextPath() + "/admin/users?success=toggled");
    }

    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/users?info=reset_not_implemented");
    }
}
