package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.entity.HotelInfo;
import com.mycompany.hotelmanagementsystem.service.HotelInfoService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Controller for managing hotel information (admin side).
 * Handles display and update of the singleton hotel info record.
 */
@WebServlet(urlPatterns = {"/admin/content/hotel-info", "/admin/content/hotel-info/save"})
public class AdminHotelInfoController extends HttpServlet {
    private HotelInfoService hotelInfoService;

    @Override
    public void init() {
        hotelInfoService = new HotelInfoService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HotelInfo hotelInfo = hotelInfoService.getHotelInfo();

        request.setAttribute("hotelInfo", hotelInfo);
        request.setAttribute("activePage", "hotel-info");
        request.setAttribute("pageTitle", "Thông tin khách sạn");
        request.getRequestDispatcher("/WEB-INF/views/admin/content/hotel-info.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            HotelInfo info = new HotelInfo();
            info.setName(request.getParameter("hotelName"));
            info.setSlogan(request.getParameter("slogan"));
            info.setShortDescription(request.getParameter("shortDescription"));
            info.setFullDescription(request.getParameter("fullDescription"));
            info.setAddress(request.getParameter("address"));
            info.setCity(request.getParameter("city"));
            info.setPhone(request.getParameter("phone"));
            info.setEmail(request.getParameter("email"));
            info.setWebsite(request.getParameter("website"));
            info.setCheckInTime(request.getParameter("checkInTime"));
            info.setCheckOutTime(request.getParameter("checkOutTime"));
            info.setCancellationPolicy(request.getParameter("cancellationPolicy"));
            info.setPolicies(request.getParameter("policies"));
            info.setFacebook(request.getParameter("facebook"));
            info.setInstagram(request.getParameter("instagram"));
            info.setTwitter(request.getParameter("twitter"));

            // Amenities checkboxes -> comma-separated string
            String[] amenitiesArr = request.getParameterValues("amenities");
            if (amenitiesArr != null) {
                info.setAmenities(String.join(",", amenitiesArr));
            }

            // Keep existing logo if no new upload (file upload not handled here)
            HotelInfo existing = hotelInfoService.getHotelInfo();
            info.setLogoUrl(existing.getLogoUrl());

            boolean success = hotelInfoService.updateHotelInfo(info);

            if (success) {
                response.sendRedirect(request.getContextPath()
                    + "/admin/content/hotel-info?success=saved");
            } else {
                request.setAttribute("error", "Không thể lưu thông tin. Vui lòng thử lại.");
                request.setAttribute("hotelInfo", info);
                request.setAttribute("activePage", "hotel-info");
                request.setAttribute("pageTitle", "Thông tin khách sạn");
                request.getRequestDispatcher("/WEB-INF/views/admin/content/hotel-info.jsp")
                       .forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            doGet(request, response);
        }
    }
}
