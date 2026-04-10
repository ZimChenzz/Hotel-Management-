package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.dal.RoomRepository;
import com.mycompany.hotelmanagementsystem.entity.Room;
import java.time.LocalDateTime;
import java.util.*;

public class RoomSuggestionService {
    private final RoomRepository roomRepository;

    public RoomSuggestionService() {
        this.roomRepository = new RoomRepository();
    }

    /**
     * Suggest nearby rooms (same floor, consecutive numbers) for multi-room booking.
     * @param needs map of typeId -> quantity needed
     * @param checkIn booking check-in datetime
     * @param checkOut booking check-out datetime
     * @return map of typeId -> list of suggested Room objects, or empty if not enough rooms
     */
    public Map<Integer, List<Room>> suggestNearbyRooms(
            Map<Integer, Integer> needs,
            LocalDateTime checkIn, LocalDateTime checkOut) {

        // 1. Get available rooms per type
        Map<Integer, List<Room>> availableByType = new LinkedHashMap<>();
        for (Map.Entry<Integer, Integer> entry : needs.entrySet()) {
            int typeId = entry.getKey();
            int qty = entry.getValue();
            List<Room> available = roomRepository.findAvailableForDatesSorted(typeId, checkIn, checkOut);
            if (available.size() < qty) {
                return Collections.emptyMap(); // not enough rooms of this type
            }
            availableByType.put(typeId, available);
        }

        // 2. Find primary type (most rooms needed)
        int primaryTypeId = needs.entrySet().stream()
            .max(Map.Entry.comparingByValue())
            .map(Map.Entry::getKey)
            .orElse(needs.keySet().iterator().next());

        // 3. Group available rooms by floor per type
        Map<String, Map<Integer, List<Room>>> floorTypeRooms = new LinkedHashMap<>();
        for (Map.Entry<Integer, List<Room>> entry : availableByType.entrySet()) {
            int typeId = entry.getKey();
            for (Room room : entry.getValue()) {
                String floor = extractFloor(room.getRoomNumber());
                floorTypeRooms
                    .computeIfAbsent(floor, k -> new LinkedHashMap<>())
                    .computeIfAbsent(typeId, k -> new ArrayList<>())
                    .add(room);
            }
        }

        // 4. Score each floor and pick the best
        String bestFloor = null;
        int bestScore = -1;
        for (Map.Entry<String, Map<Integer, List<Room>>> floorEntry : floorTypeRooms.entrySet()) {
            int score = scoreFloor(floorEntry.getKey(), floorEntry.getValue(), needs, primaryTypeId);
            if (score > bestScore) {
                bestScore = score;
                bestFloor = floorEntry.getKey();
            }
        }

        if (bestFloor == null) return Collections.emptyMap();

        // 5. Pick rooms from best floor (fallback to other floors if not enough)
        Map<Integer, List<Room>> result = new LinkedHashMap<>();
        Map<Integer, List<Room>> bestFloorRooms = floorTypeRooms.getOrDefault(bestFloor, Collections.emptyMap());

        for (Map.Entry<Integer, Integer> entry : needs.entrySet()) {
            int typeId = entry.getKey();
            int qty = entry.getValue();
            List<Room> floorRoomsForType = bestFloorRooms.getOrDefault(typeId, Collections.emptyList());

            if (floorRoomsForType.size() >= qty) {
                // Enough on best floor -> pick consecutive if primary type
                if (typeId == primaryTypeId) {
                    result.put(typeId, pickConsecutive(floorRoomsForType, qty));
                } else {
                    result.put(typeId, new ArrayList<>(floorRoomsForType.subList(0, qty)));
                }
            } else {
                // Not enough on best floor -> pick from nearest floors
                result.put(typeId, pickFromNearestFloor(qty, bestFloor, availableByType.get(typeId)));
            }
        }

        return result;
    }

    /**
     * Extract floor number from room number.
     * Assumes last 2 digits are room-on-floor, rest is floor.
     * e.g. "301" -> "3", "1201" -> "12", "01" -> "0"
     */
    static String extractFloor(String roomNumber) {
        if (roomNumber == null || roomNumber.length() < 2) return "0";
        String floor = roomNumber.substring(0, roomNumber.length() - 2);
        return floor.isEmpty() ? "0" : floor;
    }

    /** Score a floor for room assignment quality */
    private int scoreFloor(String floor, Map<Integer, List<Room>> typeRooms,
            Map<Integer, Integer> needs, int primaryTypeId) {
        int score = 0;

        // +100 if floor has enough consecutive rooms for primary type
        List<Room> primaryRooms = typeRooms.getOrDefault(primaryTypeId, Collections.emptyList());
        int primaryNeed = needs.getOrDefault(primaryTypeId, 0);
        if (primaryRooms.size() >= primaryNeed) {
            int longestConsec = findLongestConsecutive(primaryRooms);
            score += (longestConsec >= primaryNeed) ? 100 : 50;
        }

        // +50 for each OTHER type that has enough rooms on this floor
        for (Map.Entry<Integer, Integer> entry : needs.entrySet()) {
            if (entry.getKey() == primaryTypeId) continue;
            List<Room> rooms = typeRooms.getOrDefault(entry.getKey(), Collections.emptyList());
            if (rooms.size() >= entry.getValue()) score += 50;
        }

        return score;
    }

    /** Find longest run of consecutive room numbers */
    static int findLongestConsecutive(List<Room> rooms) {
        if (rooms.isEmpty()) return 0;
        int maxRun = 1, currentRun = 1;
        for (int i = 1; i < rooms.size(); i++) {
            int prev = parseRoomNum(rooms.get(i - 1).getRoomNumber());
            int curr = parseRoomNum(rooms.get(i).getRoomNumber());
            if (curr == prev + 1) {
                currentRun++;
                maxRun = Math.max(maxRun, currentRun);
            } else {
                currentRun = 1;
            }
        }
        return maxRun;
    }

    /** Pick N consecutive rooms from sorted list, fallback to first N */
    static List<Room> pickConsecutive(List<Room> rooms, int n) {
        if (rooms.size() <= n) return new ArrayList<>(rooms);
        for (int i = 0; i <= rooms.size() - n; i++) {
            boolean consecutive = true;
            for (int j = 1; j < n; j++) {
                int prev = parseRoomNum(rooms.get(i + j - 1).getRoomNumber());
                int curr = parseRoomNum(rooms.get(i + j).getRoomNumber());
                if (curr != prev + 1) { consecutive = false; break; }
            }
            if (consecutive) return new ArrayList<>(rooms.subList(i, i + n));
        }
        return new ArrayList<>(rooms.subList(0, n)); // fallback
    }

    /** Pick rooms from nearest floor to target */
    private List<Room> pickFromNearestFloor(int qty, String targetFloor, List<Room> allAvailable) {
        int targetNum = 0;
        try { targetNum = Integer.parseInt(targetFloor); } catch (Exception e) { /* ignore */ }

        // Sort by distance from target floor
        int finalTarget = targetNum;
        List<Room> sorted = new ArrayList<>(allAvailable);
        sorted.sort((a, b) -> {
            int floorA = 0, floorB = 0;
            try { floorA = Integer.parseInt(extractFloor(a.getRoomNumber())); } catch (Exception e) { /* ignore */ }
            try { floorB = Integer.parseInt(extractFloor(b.getRoomNumber())); } catch (Exception e) { /* ignore */ }
            return Integer.compare(Math.abs(floorA - finalTarget), Math.abs(floorB - finalTarget));
        });
        return sorted.subList(0, Math.min(qty, sorted.size()));
    }

    private static int parseRoomNum(String roomNumber) {
        try { return Integer.parseInt(roomNumber); } catch (Exception e) { return 0; }
    }
}
