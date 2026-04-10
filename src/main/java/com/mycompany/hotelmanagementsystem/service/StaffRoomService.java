package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.BookingStatus;
import com.mycompany.hotelmanagementsystem.constant.RoomStatus;
import com.mycompany.hotelmanagementsystem.entity.Booking;
import com.mycompany.hotelmanagementsystem.entity.Room;
import com.mycompany.hotelmanagementsystem.dal.BookingRepository;
import com.mycompany.hotelmanagementsystem.dal.RoomImageRepository;
import com.mycompany.hotelmanagementsystem.dal.RoomRepository;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class StaffRoomService {
    private final RoomRepository roomRepository;
    private final BookingRepository bookingRepository;
    private final RoomImageRepository roomImageRepository;

    public StaffRoomService() {
        this.roomRepository = new RoomRepository();
        this.bookingRepository = new BookingRepository();
        this.roomImageRepository = new RoomImageRepository();
    }

    public List<Room> getAllRoomsWithType() {
        return roomRepository.findAllWithRoomType();
    }

    public Map<String, List<Room>> getRoomsGroupedByFloor() {
        List<Room> rooms = roomRepository.findAllWithRoomType();
        return rooms.stream()
            .collect(Collectors.groupingBy(room -> {
                String roomNumber = room.getRoomNumber();
                if (roomNumber != null && roomNumber.length() >= 1) {
                    return "Tầng " + roomNumber.charAt(0);
                }
                return "Khác";
            }));
    }

    public Room getRoomDetail(int roomId) {
        Room room = roomRepository.findWithRoomType(roomId);
        if (room != null && room.getRoomType() != null) {
            room.getRoomType().setImages(roomImageRepository.findByTypeId(room.getRoomType().getTypeId()));
        }
        return room;
    }

    public int countByStatus(String status) {
        return roomRepository.countByStatus(status);
    }

    public boolean updateRoomStatus(int roomId, String status) {
        return roomRepository.updateStatus(roomId, status) > 0;
    }

    public boolean markAsAvailable(int roomId) {
        return updateRoomStatus(roomId, RoomStatus.AVAILABLE);
    }

    public boolean markAsOccupied(int roomId) {
        return updateRoomStatus(roomId, RoomStatus.OCCUPIED);
    }

    public boolean markAsCleaning(int roomId) {
        return updateRoomStatus(roomId, RoomStatus.CLEANING);
    }

    public List<Booking> getRoomHistory(int roomId) {
        return bookingRepository.findByRoomId(roomId);
    }

    /**
     * Reconcile room statuses based on actual booking data.
     * Finds rooms that are marked Occupied but have no active checked-in booking,
     * and updates them to Available or Cleaning status.
     */
    public int reconcileRoomStatuses() {
        List<Room> allRooms = roomRepository.findAll();
        int reconciled = 0;

        for (Room room : allRooms) {
            if (!RoomStatus.OCCUPIED.equals(room.getStatus())) {
                continue;
            }

            // Check if room has any active booking (CheckedIn status)
            List<Booking> bookings = bookingRepository.findByRoomId(room.getRoomId());
            boolean hasActiveBooking = bookings.stream()
                    .anyMatch(b -> BookingStatus.CHECKED_IN.equals(b.getStatus()));

            if (!hasActiveBooking) {
                // Room is marked Occupied but has no active booking
                // Update to Cleaning (needs cleaning before becoming available)
                roomRepository.updateStatus(room.getRoomId(), RoomStatus.CLEANING);
                System.out.println("Reconciled room " + room.getRoomNumber() + " from Occupied to Cleaning (no active booking)");
                reconciled++;
            }
        }

        return reconciled;
    }
}
