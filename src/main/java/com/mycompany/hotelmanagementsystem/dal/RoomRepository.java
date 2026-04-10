package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Room;
import com.mycompany.hotelmanagementsystem.entity.RoomType;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

public class RoomRepository extends BaseRepository<Room> {

    @Override
    protected Room mapRow(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setRoomId(rs.getInt("room_id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setTypeId(rs.getInt("type_id"));
        room.setStatus(rs.getString("status"));
        return room;
    }

    public Room findById(int roomId) {
        String sql = "SELECT * FROM Room WHERE room_id = ?";
        return queryOne(sql, roomId);
    }

    public Room findWithRoomType(int roomId) {
        String sql = """
            SELECT r.*, rt.type_name, rt.base_price, rt.price_per_hour, rt.capacity, rt.description
            FROM Room r
            JOIN RoomType rt ON r.type_id = rt.type_id
            WHERE r.room_id = ?
            """;
        try (var conn = getConnection();
             var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    Room room = mapRow(rs);
                    RoomType rt = new RoomType();
                    rt.setTypeId(rs.getInt("type_id"));
                    rt.setTypeName(rs.getString("type_name"));
                    rt.setBasePrice(rs.getBigDecimal("base_price"));
                    rt.setPricePerHour(rs.getBigDecimal("price_per_hour"));
                    rt.setCapacity(rs.getInt("capacity"));
                    rt.setDescription(rs.getString("description"));
                    room.setRoomType(rt);
                    return room;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find room failed", e);
        }
        return null;
    }

    public List<Room> findByTypeId(int typeId) {
        String sql = "SELECT * FROM Room WHERE type_id = ? ORDER BY room_number";
        return queryList(sql, typeId);
    }

    public List<Room> findAvailableByTypeId(int typeId) {
        String sql = "SELECT * FROM Room WHERE type_id = ? AND status = 'Available'";
        return queryList(sql, typeId);
    }

    public List<Room> findAvailableForDates(int typeId, LocalDateTime checkIn, LocalDateTime checkOut) {
        return findAvailableForDates(typeId, checkIn, checkOut, 0);
    }

    /**
     * Find available rooms for a date range, optionally excluding a specific booking
     * from the conflict check (to prevent a booking from blocking its own pre-assigned room).
     */
    public List<Room> findAvailableForDates(int typeId, LocalDateTime checkIn, LocalDateTime checkOut, int excludeBookingId) {
        String sql = """
            SELECT r.* FROM Room r
            WHERE r.type_id = ?
            AND r.status = 'Available'
            AND r.room_id NOT IN (
                -- Single-room bookings
                SELECT b.room_id FROM Booking b
                WHERE b.booking_id != ?
                AND b.room_id IS NOT NULL
                AND b.status IN ('Pending', 'Confirmed', 'CheckedIn')
                AND NOT (b.check_out_expected <= ? OR b.check_in_expected >= ?)
            )
            AND r.room_id NOT IN (
                -- Multi-room bookings (BookingRoom table)
                SELECT br.room_id FROM BookingRoom br
                JOIN Booking b ON br.booking_id = b.booking_id
                WHERE br.room_id IS NOT NULL
                AND br.booking_id != ?
                AND br.status IN ('Pending', 'Assigned', 'CheckedIn')
                AND NOT (b.check_out_expected <= ? OR b.check_in_expected >= ?)
            )
            ORDER BY r.room_number
            """;
        return queryList(sql, typeId, excludeBookingId, Timestamp.valueOf(checkIn), Timestamp.valueOf(checkOut),
                excludeBookingId, Timestamp.valueOf(checkIn), Timestamp.valueOf(checkOut));
    }

    public int countAvailableByTypeId(int typeId) {
        String sql = "SELECT COUNT(*) FROM Room WHERE type_id = ? AND status = 'Available'";
        try (var conn = getConnection();
             var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count rooms failed", e);
        }
        return 0;
    }

    /**
     * Count available rooms for a specific type within a date range.
     * Used by multi-room booking to check if enough rooms are available.
     */
    public int countAvailableForDates(int typeId, LocalDateTime checkIn, LocalDateTime checkOut) {
        String sql = """
            SELECT COUNT(*) FROM Room r
            WHERE r.type_id = ?
            AND r.status = 'Available'
            AND r.room_id NOT IN (
                -- Single-room bookings
                SELECT b.room_id FROM Booking b
                WHERE b.status IN ('Pending', 'Confirmed', 'CheckedIn')
                AND b.room_id IS NOT NULL
                AND NOT (b.check_out_expected <= ? OR b.check_in_expected >= ?)
            )
            AND r.room_id NOT IN (
                -- Multi-room bookings (BookingRoom table)
                SELECT br.room_id FROM BookingRoom br
                JOIN Booking b ON br.booking_id = b.booking_id
                WHERE br.room_id IS NOT NULL
                AND br.status IN ('Pending', 'Assigned', 'CheckedIn')
                AND NOT (b.check_out_expected <= ? OR b.check_in_expected >= ?)
            )
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            ps.setTimestamp(2, Timestamp.valueOf(checkIn));
            ps.setTimestamp(3, Timestamp.valueOf(checkOut));
            ps.setTimestamp(4, Timestamp.valueOf(checkIn));
            ps.setTimestamp(5, Timestamp.valueOf(checkOut));
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count available rooms for dates failed", e);
        }
        return 0;
    }

    /**
     * Find available rooms for dates, sorted by room_number for floor grouping.
     */
    public List<Room> findAvailableForDatesSorted(int typeId, LocalDateTime checkIn, LocalDateTime checkOut) {
        String sql = """
            SELECT r.* FROM Room r
            WHERE r.type_id = ?
            AND r.status = 'Available'
            AND r.room_id NOT IN (
                -- Single-room bookings
                SELECT b.room_id FROM Booking b
                WHERE b.status IN ('Pending', 'Confirmed', 'CheckedIn')
                AND b.room_id IS NOT NULL
                AND NOT (b.check_out_expected <= ? OR b.check_in_expected >= ?)
            )
            AND r.room_id NOT IN (
                -- Multi-room bookings (BookingRoom table)
                SELECT br.room_id FROM BookingRoom br
                JOIN Booking b ON br.booking_id = b.booking_id
                WHERE br.room_id IS NOT NULL
                AND br.status IN ('Pending', 'Assigned', 'CheckedIn')
                AND NOT (b.check_out_expected <= ? OR b.check_in_expected >= ?)
            )
            ORDER BY r.room_number ASC
            """;
        return queryList(sql, typeId, Timestamp.valueOf(checkIn), Timestamp.valueOf(checkOut),
                Timestamp.valueOf(checkIn), Timestamp.valueOf(checkOut));
    }

    public int updateStatus(int roomId, String status) {
        String sql = "UPDATE Room SET status = ? WHERE room_id = ?";
        return executeUpdate(sql, status, roomId);
    }

    public List<Room> findAll() {
        return queryList("SELECT * FROM Room ORDER BY room_number");
    }

    public List<Room> findAllWithRoomType() {
        String sql = """
            SELECT r.*, rt.type_name, rt.base_price, rt.capacity
            FROM Room r
            JOIN RoomType rt ON r.type_id = rt.type_id
            ORDER BY r.room_number
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            try (var rs = ps.executeQuery()) {
                java.util.ArrayList<Room> list = new java.util.ArrayList<>();
                while (rs.next()) {
                    Room room = mapRow(rs);
                    RoomType rt = new RoomType();
                    rt.setTypeId(rs.getInt("type_id"));
                    rt.setTypeName(rs.getString("type_name"));
                    rt.setBasePrice(rs.getBigDecimal("base_price"));
                    rt.setCapacity(rs.getInt("capacity"));
                    room.setRoomType(rt);
                    list.add(room);
                }
                return list;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find all rooms failed", e);
        }
    }

    public List<Room> findByStatus(String status) {
        return queryList("SELECT * FROM Room WHERE status = ? ORDER BY room_number", status);
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Room WHERE status = ?";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count rooms failed", e);
        }
        return 0;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM Room";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count rooms failed", e);
        }
        return 0;
    }

    public Room findByRoomNumber(String roomNumber) {
        String sql = "SELECT * FROM Room WHERE room_number = ?";
        return queryOne(sql, roomNumber);
    }

    public int insert(Room room) {
        String sql = "INSERT INTO Room (room_number, type_id, status) VALUES (?, ?, ?)";
        return executeInsert(sql, room.getRoomNumber(), room.getTypeId(), room.getStatus());
    }

    public int update(Room room) {
        String sql = "UPDATE Room SET room_number = ?, type_id = ?, status = ? WHERE room_id = ?";
        return executeUpdate(sql, room.getRoomNumber(), room.getTypeId(), room.getStatus(), room.getRoomId());
    }

    public int delete(int roomId) {
        String sql = "DELETE FROM Room WHERE room_id = ?";
        return executeUpdate(sql, roomId);
    }
}
