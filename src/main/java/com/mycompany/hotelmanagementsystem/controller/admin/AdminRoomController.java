package com.mycompany.hotelmanagementsystem.controller.admin;

import com.mycompany.hotelmanagementsystem.constant.RoomStatus;
import com.mycompany.hotelmanagementsystem.service.AdminRoomService;
import com.mycompany.hotelmanagementsystem.entity.Booking;
import com.mycompany.hotelmanagementsystem.entity.Room;
import com.mycompany.hotelmanagementsystem.entity.RoomImage;
import com.mycompany.hotelmanagementsystem.entity.RoomType;
import com.mycompany.hotelmanagementsystem.dal.RoomImageRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {
    "/admin/rooms",
    "/admin/rooms/map",
    "/admin/rooms/create",
    "/admin/rooms/edit",
    "/admin/rooms/delete",
    "/admin/rooms/history",
    "/admin/rooms/upload-image",
    "/admin/rooms/delete-image",
    "/admin/room-types",
    "/admin/room-types/create",
    "/admin/room-types/edit",
    "/admin/room-types/delete",
    "/admin/room-types/upload-image",
    "/admin/room-types/delete-image"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 5 * 1024 * 1024,         // 5 MB
    maxRequestSize = 25 * 1024 * 1024      // 25 MB
)
public class AdminRoomController extends HttpServlet {
    private AdminRoomService adminRoomService;
    private RoomImageRepository roomImageRepository;

    @Override
    public void init() {
        adminRoomService = new AdminRoomService();
        roomImageRepository = new RoomImageRepository();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/admin/rooms" -> handleRoomList(request, response);
            case "/admin/rooms/map" -> handleRoomMap(request, response);
            case "/admin/rooms/create" -> showRoomForm(request, response, 0);
            case "/admin/rooms/edit" -> showRoomEditForm(request, response);
            case "/admin/rooms/history" -> handleRoomHistory(request, response);
            case "/admin/room-types" -> handleRoomTypeList(request, response);
            case "/admin/room-types/create" -> showRoomTypeForm(request, response, 0);
            case "/admin/room-types/edit" -> showRoomTypeEditForm(request, response);
            default -> response.sendError(404);
        }    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/admin/rooms/create" -> handleRoomCreate(request, response);
            case "/admin/rooms/edit" -> handleRoomUpdate(request, response);
            case "/admin/rooms/delete" -> handleRoomDelete(request, response);
            case "/admin/rooms/upload-image" -> handleRoomImageUpload(request, response);
            case "/admin/rooms/delete-image" -> handleRoomImageDelete(request, response);
            case "/admin/room-types/create" -> handleRoomTypeCreate(request, response);
            case "/admin/room-types/edit" -> handleRoomTypeUpdate(request, response);
            case "/admin/room-types/delete" -> handleRoomTypeDelete(request, response);
            case "/admin/room-types/upload-image" -> handleRoomTypeImageUpload(request, response);
            case "/admin/room-types/delete-image" -> handleRoomTypeDeleteImage(request, response);
            default -> response.sendError(404);
        }
    }

    // --- Room handlers ---

    private void handleRoomMap(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Room> rooms = adminRoomService.getAllRooms();
        Map<String, List<Room>> roomsByFloor = rooms.stream()
            .collect(Collectors.groupingBy(room -> {
                String roomNumber = room.getRoomNumber();
                if (roomNumber != null && !roomNumber.isEmpty()) {
                    return "Tầng " + roomNumber.charAt(0);
                }
                return "Khác";
            }));
        request.setAttribute("roomsByFloor", roomsByFloor);
        request.setAttribute("activePage", "rooms");
        request.setAttribute("pageTitle", "Sơ đồ phòng");
        request.getRequestDispatcher("/WEB-INF/views/admin/rooms/map.jsp").forward(request, response);
    }

    private void handleRoomList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("rooms", adminRoomService.getAllRooms());
        request.setAttribute("roomTypes", adminRoomService.getAllRoomTypes());
        request.setAttribute("activePage", "rooms");
        request.setAttribute("pageTitle", "Quản lý phòng");
        request.getRequestDispatcher("/WEB-INF/views/admin/rooms/list.jsp").forward(request, response);
    }

    private void showRoomForm(HttpServletRequest request, HttpServletResponse response, int roomId)
            throws ServletException, IOException {
        List<RoomType> roomTypes = adminRoomService.getAllRoomTypes();
        request.setAttribute("roomTypes", roomTypes);
        request.setAttribute("statuses", new String[]{
            RoomStatus.AVAILABLE, RoomStatus.OCCUPIED, RoomStatus.CLEANING, RoomStatus.MAINTENANCE
        });
        request.setAttribute("roomTypeImages", buildRoomTypeImagesMap(roomTypes));
        request.setAttribute("activePage", "rooms");
        request.setAttribute("pageTitle", "Thêm phòng mới");
        request.getRequestDispatcher("/WEB-INF/views/admin/rooms/form.jsp").forward(request, response);
    }

    private void showRoomEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/rooms");
            return;
        }
        int roomId;
        try {
            roomId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/rooms");
            return;
        }
        Room room = adminRoomService.getRoomById(roomId);
        if (room == null) {
            response.sendError(404, "Phòng không tồn tại");
            return;
        }
        List<RoomType> roomTypes = adminRoomService.getAllRoomTypes();
        request.setAttribute("room", room);
        request.setAttribute("roomTypes", roomTypes);
        request.setAttribute("statuses", new String[]{
            RoomStatus.AVAILABLE, RoomStatus.OCCUPIED, RoomStatus.CLEANING, RoomStatus.MAINTENANCE
        });
        request.setAttribute("roomTypeImages", buildRoomTypeImagesMap(roomTypes));
        // Current occupant and room history for edit page
        Booking currentBooking = adminRoomService.getCurrentBookingForRoom(roomId);
        request.setAttribute("currentBooking", currentBooking);
        request.setAttribute("bookings", adminRoomService.getRoomHistory(roomId));
        request.setAttribute("roomImages", room.getImages());
        request.setAttribute("activePage", "rooms");
        request.setAttribute("pageTitle", "Chỉnh sửa phòng");
        request.getRequestDispatcher("/WEB-INF/views/admin/rooms/form.jsp").forward(request, response);
    }

    private void handleRoomCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Room room = buildRoomFromRequest(request);
            // Kiểm tra trùng số phòng
            Room existing = adminRoomService.findRoomByNumber(room.getRoomNumber());
            if (existing != null) {
                request.setAttribute("error", "Số phòng \"" + room.getRoomNumber() + "\" đã tồn tại. Vui lòng chọn số khác.");
                showRoomForm(request, response, 0);
                return;
            }
            boolean success = adminRoomService.createRoom(room);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/rooms?success=created");
            } else {
                request.setAttribute("error", "Không thể tạo phòng. Vui lòng thử lại.");
                showRoomForm(request, response, 0);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ: " + e.getMessage());
            showRoomForm(request, response, 0);
        }
    }

    private void handleRoomUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Room room = buildRoomFromRequest(request);
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            room.setRoomId(roomId);
            // Kiểm tra trùng số phòng (trừ chính phòng đang sửa)
            Room existing = adminRoomService.findRoomByNumber(room.getRoomNumber());
            if (existing != null && existing.getRoomId() != roomId) {
                request.setAttribute("error", "Số phòng \"" + room.getRoomNumber() + "\" đã tồn tại. Vui lòng chọn số khác.");
                showRoomEditForm(request, response);
                return;
            }
            boolean success = adminRoomService.updateRoom(room);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/rooms?success=updated");
            } else {
                request.setAttribute("error", "Không thể cập nhật phòng. Vui lòng thử lại.");
                showRoomEditForm(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ: " + e.getMessage());
            showRoomEditForm(request, response);
        }
    }

    private void handleRoomDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int roomId = Integer.parseInt(request.getParameter("id"));
            adminRoomService.deleteRoom(roomId);
            response.sendRedirect(request.getContextPath() + "/admin/rooms?success=deleted");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/rooms?error=deleteFailed");
        }
    }

    private void handleRoomHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/rooms");
            return;
        }
        try {
            int roomId = Integer.parseInt(idParam);
            Room room = adminRoomService.getRoomById(roomId);
            if (room == null) {
                response.sendError(404, "Phòng không tồn tại");
                return;
            }
            request.setAttribute("room", room);
            request.setAttribute("bookings", adminRoomService.getRoomHistory(roomId));
            request.setAttribute("activePage", "rooms");
            request.setAttribute("pageTitle", "Lịch sử phòng " + room.getRoomNumber());
            request.getRequestDispatcher("/WEB-INF/views/admin/rooms/history.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/rooms");
        }
    }

    private void handleRoomImageUpload(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            Part filePart = request.getPart("roomImage");
            if (filePart == null || filePart.getSize() == 0) {
                response.sendRedirect(request.getContextPath() + "/admin/rooms/edit?id=" + roomId + "&error=noFile");
                return;
            }
            // Validate file type
            String contentType = filePart.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                response.sendRedirect(request.getContextPath() + "/admin/rooms/edit?id=" + roomId + "&error=invalidType");
                return;
            }
            // Create upload directory
            String uploadDir = getServletContext().getRealPath("/uploads/rooms");
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            // Generate unique filename
            String originalName = getFileName(filePart);
            String extension = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf('.')) : ".jpg";
            String fileName = "room-" + roomId + "-" + UUID.randomUUID().toString().substring(0, 8) + extension;
            // Save file
            Path filePath = Path.of(uploadDir, fileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
            }
            // Save to database
            String imageUrl = "/uploads/rooms/" + fileName;
            adminRoomService.addRoomImage(roomId, imageUrl);
            response.sendRedirect(request.getContextPath() + "/admin/rooms/edit?id=" + roomId + "&success=imageUploaded#images");
        } catch (Exception e) {
            String roomId = request.getParameter("roomId");
            response.sendRedirect(request.getContextPath() + "/admin/rooms/edit?id=" + roomId + "&error=uploadFailed");
        }
    }

    private void handleRoomImageDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int imageId = Integer.parseInt(request.getParameter("imageId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            adminRoomService.deleteRoomImage(imageId);
            response.sendRedirect(request.getContextPath() + "/admin/rooms/edit?id=" + roomId + "&success=imageDeleted#images");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/rooms");
        }
    }

    private String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header != null) {
            for (String token : header.split(";")) {
                if (token.trim().startsWith("filename")) {
                    return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                }
            }
        }
        return "unknown.jpg";
    }

    private Room buildRoomFromRequest(HttpServletRequest request) {
        Room room = new Room();
        room.setRoomNumber(request.getParameter("roomNumber").trim());
        room.setTypeId(Integer.parseInt(request.getParameter("typeId")));
        room.setStatus(request.getParameter("status"));
        return room;
    }

    // --- RoomType handlers ---

    private void handleRoomTypeList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("roomTypes", adminRoomService.getAllRoomTypes());
        request.setAttribute("activePage", "room-types");
        request.setAttribute("pageTitle", "Quản lý loại phòng");
        request.getRequestDispatcher("/WEB-INF/views/admin/room-types/list.jsp").forward(request, response);
    }

    private void showRoomTypeForm(HttpServletRequest request, HttpServletResponse response, int typeId)
            throws ServletException, IOException {
        request.setAttribute("activePage", "room-types");
        request.setAttribute("pageTitle", "Thêm loại phòng mới");
        request.getRequestDispatcher("/WEB-INF/views/admin/room-types/form.jsp").forward(request, response);
    }

    private void showRoomTypeEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/room-types");
            return;
        }
        int typeId;
        try {
            typeId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/room-types");
            return;
        }
        RoomType roomType = adminRoomService.getRoomTypeById(typeId);
        if (roomType == null) {
            response.sendError(404, "Loại phòng không tồn tại");
            return;
        }
        request.setAttribute("roomType", roomType);
        request.setAttribute("existingImages", roomImageRepository.findByTypeId(typeId));
        request.setAttribute("activePage", "room-types");
        request.setAttribute("pageTitle", "Chỉnh sửa loại phòng");
        request.getRequestDispatcher("/WEB-INF/views/admin/room-types/form.jsp").forward(request, response);
    }

    private void handleRoomTypeCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            RoomType roomType = buildRoomTypeFromRequest(request);
            int newTypeId = adminRoomService.createRoomTypeGetId(roomType);
            if (newTypeId > 0) {
                String imageUrl = request.getParameter("imageUrl");
                if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                    roomImageRepository.insert(newTypeId, imageUrl.trim());
                }
                response.sendRedirect(request.getContextPath() + "/admin/room-types?success=created");
            } else {
                request.setAttribute("error", "Không thể tạo loại phòng. Vui lòng thử lại.");
                showRoomTypeForm(request, response, 0);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ: " + e.getMessage());
            showRoomTypeForm(request, response, 0);
        }
    }

    private void handleRoomTypeUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            RoomType roomType = buildRoomTypeFromRequest(request);
            int typeId = Integer.parseInt(request.getParameter("typeId"));
            roomType.setTypeId(typeId);
            boolean success = adminRoomService.updateRoomType(roomType);
            if (success) {
                String imageUrl = request.getParameter("imageUrl");
                if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                    roomImageRepository.insert(typeId, imageUrl.trim());
                }
                response.sendRedirect(request.getContextPath() + "/admin/room-types?success=updated");
            } else {
                request.setAttribute("error", "Không thể cập nhật loại phòng. Vui lòng thử lại.");
                showRoomTypeEditForm(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ: " + e.getMessage());
            showRoomTypeEditForm(request, response);
        }
    }

    private void handleRoomTypeDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int typeId = Integer.parseInt(request.getParameter("id"));
            adminRoomService.deleteRoomType(typeId);
            response.sendRedirect(request.getContextPath() + "/admin/room-types?success=deleted");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/room-types?error=deleteFailed");
        }
    }

    private RoomType buildRoomTypeFromRequest(HttpServletRequest request) {
        RoomType roomType = new RoomType();
        roomType.setTypeName(request.getParameter("typeName").trim());
        roomType.setBasePrice(new BigDecimal(request.getParameter("basePrice")));
        roomType.setCapacity(Integer.parseInt(request.getParameter("capacity")));

        String pricePerHour = request.getParameter("pricePerHour");
        roomType.setPricePerHour(pricePerHour != null && !pricePerHour.isEmpty()
            ? new BigDecimal(pricePerHour) : BigDecimal.ZERO);

        String depositPercent = request.getParameter("depositPercent");
        roomType.setDepositPercent(depositPercent != null && !depositPercent.isEmpty()
            ? new BigDecimal(depositPercent) : BigDecimal.ZERO);

        String description = request.getParameter("description");
        roomType.setDescription(description != null ? description.trim() : "");
        return roomType;
    }

    private void handleRoomTypeDeleteImage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int imageId = Integer.parseInt(request.getParameter("imageId"));
            int typeId = Integer.parseInt(request.getParameter("typeId"));
            roomImageRepository.deleteById(imageId);
            response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?id=" + typeId);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/room-types");
        }
    }

    private void handleRoomTypeImageUpload(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int typeId = Integer.parseInt(request.getParameter("typeId"));
            Part filePart = request.getPart("roomTypeImage");
            if (filePart == null || filePart.getSize() == 0) {
                response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?id=" + typeId + "&error=noFile");
                return;
            }
            // Validate file type
            String contentType = filePart.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?id=" + typeId + "&error=invalidType");
                return;
            }
            // Create upload directory
            String uploadDir = getServletContext().getRealPath("/uploads/room-types");
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            // Generate unique filename
            String originalName = getFileName(filePart);
            String extension = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf('.')) : ".jpg";
            String fileName = "rtype-" + typeId + "-" + UUID.randomUUID().toString().substring(0, 8) + extension;
            // Save file
            Path filePath = Path.of(uploadDir, fileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
            }
            // Save to database
            String imageUrl = "/uploads/room-types/" + fileName;
            roomImageRepository.insert(typeId, imageUrl);
            response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?id=" + typeId + "&success=imageUploaded#images");
        } catch (Exception e) {
            String typeId = request.getParameter("typeId");
            response.sendRedirect(request.getContextPath() + "/admin/room-types/edit?id=" + typeId + "&error=uploadFailed");
        }
    }

    private Map<Integer, RoomImage> buildRoomTypeImagesMap(List<RoomType> roomTypes) {
        Map<Integer, RoomImage> map = new HashMap<>();
        for (RoomType rt : roomTypes) {
            RoomImage img = roomImageRepository.findFirstByTypeId(rt.getTypeId());
            if (img != null) {
                map.put(rt.getTypeId(), img);
            }
        }
        return map;
    }
}
