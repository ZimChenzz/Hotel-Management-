package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.service.AdminCustomerService;
import com.mycompany.hotelmanagementsystem.entity.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/admin/customers", "/admin/customers/create", "/admin/customers/edit"})
public class AdminCustomerController extends HttpServlet {
    private AdminCustomerService adminCustomerService;

    @Override
    public void init() {
        adminCustomerService = new AdminCustomerService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/admin/customers" -> handleList(request, response);
            case "/admin/customers/create" -> handleCreateForm(request, response);
            case "/admin/customers/edit" -> handleEditForm(request, response);
            default -> response.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/admin/customers/create" -> handleCreate(request, response);
            case "/admin/customers/edit" -> handleEdit(request, response);
            default -> response.sendError(404);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Customer> customers = adminCustomerService.getAllCustomers();

        String success = request.getParameter("success");
        if ("created".equals(success)) {
            request.setAttribute("success", "Tạo khách hàng thành công!");
        } else if ("updated".equals(success)) {
            request.setAttribute("success", "Cập nhật khách hàng thành công!");
        }

        request.setAttribute("customers", customers);
        request.setAttribute("activePage", "customers");
        request.setAttribute("pageTitle", "Quản lý khách hàng");
        request.getRequestDispatcher("/WEB-INF/views/admin/customers/list.jsp").forward(request, response);
    }

    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activePage", "customers");
        request.setAttribute("pageTitle", "Thêm khách hàng");
        request.setAttribute("isEdit", false);
        request.getRequestDispatcher("/WEB-INF/views/admin/customers/form.jsp").forward(request, response);
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Customer customer = adminCustomerService.getCustomerById(id);

        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=notfound");
            return;
        }

        request.setAttribute("customer", customer);
        request.setAttribute("activePage", "customers");
        request.setAttribute("pageTitle", "Sửa khách hàng");
        request.setAttribute("isEdit", true);
        request.getRequestDispatcher("/WEB-INF/views/admin/customers/form.jsp").forward(request, response);
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        int result = adminCustomerService.createCustomer(email, password, fullName, phone, address);

        if (result == -1) {
            request.setAttribute("error", "Email đã tồn tại!");
            request.setAttribute("isEdit", false);
            request.getRequestDispatcher("/WEB-INF/views/admin/customers/form.jsp").forward(request, response);
            return;
        }

        if (result > 0) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?success=created");
        } else {
            request.setAttribute("error", "Không thể tạo khách hàng!");
            request.getRequestDispatcher("/WEB-INF/views/admin/customers/form.jsp").forward(request, response);
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        boolean success = adminCustomerService.updateCustomer(id, fullName, phone, address);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?success=updated");
        } else {
            request.setAttribute("error", "Không thể cập nhật khách hàng!");
            handleEditForm(request, response);
        }
    }
}
