package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.BookingStatus;
import com.mycompany.hotelmanagementsystem.constant.RoomStatus;
import com.mycompany.hotelmanagementsystem.constant.ServiceRequestStatusConstant;
import com.mycompany.hotelmanagementsystem.constant.ServiceTypeConstant;
import com.mycompany.hotelmanagementsystem.util.ServiceResult;
import com.mycompany.hotelmanagementsystem.entity.Booking;
import com.mycompany.hotelmanagementsystem.entity.Room;
import com.mycompany.hotelmanagementsystem.entity.ServiceRequest;
import com.mycompany.hotelmanagementsystem.dal.BookingRepository;
import com.mycompany.hotelmanagementsystem.dal.RoomRepository;
import com.mycompany.hotelmanagementsystem.dal.ServiceRequestRepository;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ServiceRequestService {
    private final ServiceRequestRepository serviceRequestRepository;
    private final BookingRepository bookingRepository;
    private final RoomRepository roomRepository;

    public ServiceRequestService() {
        this.serviceRequestRepository = new ServiceRequestRepository();
        this.bookingRepository = new BookingRepository();
        this.roomRepository = new RoomRepository();
    }

    /**
     * Create a service request for any service type.
     */
    public ServiceResult createRequest(int bookingId, int customerId,
                                       String serviceType, String description, String priority) {
        try {
            Booking booking = bookingRepository.findById(bookingId);
            if (booking == null || booking.getCustomerId() != customerId) {
                return ServiceResult.failure("Không tìm thấy đặt phòng");
            }

            if (!BookingStatus.CHECKED_IN.equals(booking.getStatus())) {
                return ServiceResult.failure("Chỉ có thể yêu cầu dịch vụ khi đã nhận phòng");
            }

            if (!ServiceTypeConstant.isValid(serviceType)) {
                return ServiceResult.failure("Loại dịch vụ không hợp lệ");
            }

            if (serviceRequestRepository.hasPendingRequest(bookingId, serviceType)) {
                return ServiceResult.failure("Bạn đã có yêu cầu " + serviceType + " đang chờ xử lý");
            }

            // Resolve room number for display
            String roomNumber = null;
            if (booking.getRoomId() != null) {
                Room room = roomRepository.findById(booking.getRoomId());
                if (room != null) {
                    roomNumber = room.getRoomNumber();
                }
            }

            ServiceRequest request = new ServiceRequest();
            request.setBookingId(bookingId);
            request.setServiceType(serviceType);
            request.setStatus(ServiceRequestStatusConstant.PENDING);
            request.setDescription(description);
            request.setPriority(priority != null ? priority : "Normal");
            request.setRoomNumber(roomNumber);

            int requestId = serviceRequestRepository.insert(request);
            if (requestId <= 0) {
                return ServiceResult.failure("Không thể tạo yêu cầu");
            }

            return ServiceResult.success("Yêu cầu dịch vụ đã được gửi thành công");
        } catch (Exception e) {
            return ServiceResult.failure("Lỗi hệ thống: " + e.getMessage());
        }
    }

    /**
     * Backward-compatible: create cleaning request (used by existing code).
     */
    public ServiceResult createCleaningRequest(int bookingId, int customerId) {
        return createRequest(bookingId, customerId, ServiceTypeConstant.CLEANING, null, "Normal");
    }

    public List<ServiceRequest> getBookingRequests(int bookingId) {
        return serviceRequestRepository.findByBookingId(bookingId);
    }

    public ServiceResult cancelRequest(int requestId, int customerId) {
        try {
            ServiceRequest serviceRequest = serviceRequestRepository.findById(requestId);
            if (serviceRequest == null) {
                return ServiceResult.failure("Không tìm thấy yêu cầu dịch vụ");
            }
            Booking booking = bookingRepository.findById(serviceRequest.getBookingId());
            if (booking == null || booking.getCustomerId() != customerId) {
                return ServiceResult.failure("Bạn không có quyền hủy yêu cầu này");
            }
            if (!ServiceRequestStatusConstant.PENDING.equals(serviceRequest.getStatus())) {
                return ServiceResult.failure("Chỉ có thể hủy yêu cầu đang ở trạng thái chờ xử lý");
            }
            if (serviceRequestRepository.updateStatus(requestId, ServiceRequestStatusConstant.CANCELLED) > 0) {
                return ServiceResult.success("Yêu cầu dịch vụ đã được hủy");
            }
            return ServiceResult.failure("Không thể hủy yêu cầu");
        } catch (Exception e) {
            return ServiceResult.failure("Lỗi hệ thống: " + e.getMessage());
        }
    }

    // --- Methods for staff/admin ---

    /**
     * Get all service requests (for admin).
     */
    public List<ServiceRequest> getAllRequests() {
        return serviceRequestRepository.findAll();
    }

    /**
     * Get pending and in-progress requests (for staff dashboard).
     */
    public List<ServiceRequest> getPendingRequests() {
        return serviceRequestRepository.findPendingAndInProgress();
    }

    /**
     * Get requests assigned to a specific staff member.
     */
    public List<ServiceRequest> getStaffRequests(int staffId) {
        return serviceRequestRepository.findByStaffId(staffId);
    }

    /**
     * Get requests filtered by status.
     */
    public List<ServiceRequest> getRequestsByStatus(String status) {
        return serviceRequestRepository.findByStatus(status);
    }

    /**
     * Staff assigns themselves to a pending request.
     */
    public ServiceResult assignToStaff(int requestId, int staffId) {
        try {
            ServiceRequest request = serviceRequestRepository.findById(requestId);
            if (request == null) {
                return ServiceResult.failure("Không tìm thấy yêu cầu");
            }
            if (!ServiceRequestStatusConstant.PENDING.equals(request.getStatus())) {
                return ServiceResult.failure("Chỉ có thể nhận yêu cầu đang ở trạng thái chờ xử lý");
            }
            if (serviceRequestRepository.assignStaff(requestId, staffId) > 0) {
                return ServiceResult.success("Đã nhận xử lý yêu cầu thành công");
            }
            return ServiceResult.failure("Không thể nhận yêu cầu");
        } catch (Exception e) {
            return ServiceResult.failure("Lỗi hệ thống: " + e.getMessage());
        }
    }

    /**
     * Staff marks a request as completed.
     */
    public ServiceResult completeRequest(int requestId, int staffId, String notes) {
        try {
            ServiceRequest request = serviceRequestRepository.findById(requestId);
            if (request == null) {
                return ServiceResult.failure("Không tìm thấy yêu cầu");
            }
            if (!ServiceRequestStatusConstant.IN_PROGRESS.equals(request.getStatus())) {
                return ServiceResult.failure("Chỉ có thể hoàn thành yêu cầu đang xử lý");
            }
            if (request.getStaffId() == null || request.getStaffId() != staffId) {
                return ServiceResult.failure("Bạn không được phân công xử lý yêu cầu này");
            }
            if (serviceRequestRepository.complete(requestId, notes) > 0) {
                // If this is a CLEANING request, also update room status to AVAILABLE
                System.out.println("[DEBUG] completeRequest: serviceType=" + request.getServiceType()
                    + ", roomNumber=" + request.getRoomNumber());
                if (ServiceTypeConstant.CLEANING.equals(request.getServiceType())
                        && request.getRoomNumber() != null) {
                    Room room = roomRepository.findByRoomNumber(request.getRoomNumber());
                    System.out.println("[DEBUG] Found room: " + (room != null ? room.getRoomNumber() : "null"));
                    if (room != null) {
                        int updated = roomRepository.updateStatus(room.getRoomId(), RoomStatus.AVAILABLE);
                        System.out.println("[DEBUG] Room status update result: " + updated);
                    }
                }
                return ServiceResult.success("Yêu cầu đã được hoàn thành");
            }
            return ServiceResult.failure("Không thể hoàn thành yêu cầu");
        } catch (Exception e) {
            return ServiceResult.failure("Lỗi hệ thống: " + e.getMessage());
        }
    }

    /**
     * Staff rejects a request.
     */
    public ServiceResult rejectRequest(int requestId, int staffId, String notes) {
        try {
            ServiceRequest request = serviceRequestRepository.findById(requestId);
            if (request == null) {
                return ServiceResult.failure("Không tìm thấy yêu cầu");
            }
            if (!ServiceRequestStatusConstant.IN_PROGRESS.equals(request.getStatus())) {
                return ServiceResult.failure("Chỉ có thể từ chối yêu cầu đang xử lý");
            }
            if (request.getStaffId() == null || request.getStaffId() != staffId) {
                return ServiceResult.failure("Bạn không được phân công xử lý yêu cầu này");
            }
            if (serviceRequestRepository.reject(requestId, notes) > 0) {
                return ServiceResult.success("Yêu cầu đã bị từ chối");
            }
            return ServiceResult.failure("Không thể từ chối yêu cầu");
        } catch (Exception e) {
            return ServiceResult.failure("Lỗi hệ thống: " + e.getMessage());
        }
    }

    /**
     * Get request statistics for dashboard widgets.
     */
    public Map<String, Integer> getRequestStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("totalToday", serviceRequestRepository.countToday());
        stats.put("pending", serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.PENDING));
        stats.put("inProgress", serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.IN_PROGRESS));
        stats.put("completedToday", serviceRequestRepository.countTodayByStatus(ServiceRequestStatusConstant.COMPLETED));
        stats.put("total", serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.PENDING)
                + serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.IN_PROGRESS)
                + serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.COMPLETED)
                + serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.CANCELLED)
                + serviceRequestRepository.countByStatus(ServiceRequestStatusConstant.REJECTED));
        return stats;
    }
}
