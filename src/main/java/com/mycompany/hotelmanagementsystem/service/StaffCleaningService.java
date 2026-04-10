package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.RoomStatus;
import com.mycompany.hotelmanagementsystem.entity.Room;
import com.mycompany.hotelmanagementsystem.entity.RoomCleaningInfo;
import com.mycompany.hotelmanagementsystem.entity.ServiceRequest;
import com.mycompany.hotelmanagementsystem.dal.RoomRepository;
import com.mycompany.hotelmanagementsystem.dal.ServiceRequestRepository;
import java.util.List;

public class StaffCleaningService {
    private final RoomRepository roomRepository;
    private final ServiceRequestRepository serviceRequestRepository;

    public StaffCleaningService() {
        this.roomRepository = new RoomRepository();
        this.serviceRequestRepository = new ServiceRequestRepository();
    }

    // UC-20.1: Get rooms that need cleaning with their cleaning request info
    public List<RoomCleaningInfo> getRoomsNeedingCleaning() {
        List<Room> rooms = roomRepository.findByStatus(RoomStatus.CLEANING);
        System.out.println("[DEBUG] getRoomsNeedingCleaning: found " + rooms.size() + " rooms with CLEANING status");
        for (Room r : rooms) {
            System.out.println("[DEBUG]   Room: " + r.getRoomNumber() + ", status=" + r.getStatus());
        }
        return rooms.stream()
                .map(room -> {
                    ServiceRequest cleaningRequest = serviceRequestRepository.findPendingCleaningByRoomNumber(room.getRoomNumber());
                    return new RoomCleaningInfo(room, cleaningRequest);
                })
                .toList();
    }

    public int countRoomsNeedingCleaning() {
        return roomRepository.countByStatus(RoomStatus.CLEANING);
    }

    // UC-20.2: Staff accepts cleaning request
    public boolean acceptCleaningRequest(int roomId, int staffId) {
        Room room = roomRepository.findById(roomId);
        if (room == null) return false;

        ServiceRequest cleaningRequest = serviceRequestRepository.findPendingCleaningByRoomNumber(room.getRoomNumber());
        if (cleaningRequest == null) return false;

        return serviceRequestRepository.assignStaff(cleaningRequest.getRequestId(), staffId) > 0;
    }

    // UC-20.3: Mark room as cleaned and complete the associated cleaning request
    public boolean markRoomAsClean(int roomId) {
        // First update room status to Available
        boolean roomUpdated = roomRepository.updateStatus(roomId, RoomStatus.AVAILABLE) > 0;

        // Find the room to get room number
        Room room = roomRepository.findById(roomId);
        if (room != null) {
            // Find and complete the pending/in-progress cleaning request for this room
            ServiceRequest cleaningRequest = serviceRequestRepository.findPendingCleaningByRoomNumber(room.getRoomNumber());
            if (cleaningRequest != null) {
                // If request is Pending, assign to current staff before completing
                if (cleaningRequest.getStaffId() == null) {
                    serviceRequestRepository.assignStaff(cleaningRequest.getRequestId(), 0); // system
                }
                serviceRequestRepository.complete(cleaningRequest.getRequestId(), "Da duoc don phong");
            }
        }

        return roomUpdated;
    }

    public Room getRoomDetail(int roomId) {
        return roomRepository.findWithRoomType(roomId);
    }
}
