package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.*;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class BookingRoomRepository extends BaseRepository<BookingRoom> {

    @Override
    protected BookingRoom mapRow(ResultSet rs) throws SQLException {
        BookingRoom br = new BookingRoom();
        br.setBookingRoomId(rs.getInt("booking_room_id"));
        br.setBookingId(rs.getInt("booking_id"));
        int roomId = rs.getInt("room_id");
        br.setRoomId(rs.wasNull() ? null : roomId);
        br.setTypeId(rs.getInt("type_id"));
        br.setUnitPrice(rs.getBigDecimal("unit_price"));
        br.setEarlySurcharge(rs.getBigDecimal("early_surcharge"));
        br.setLateSurcharge(rs.getBigDecimal("late_surcharge"));
        br.setPromotionDiscount(rs.getBigDecimal("promotion_discount"));
        br.setStatus(rs.getString("status"));
        Timestamp ts = rs.getTimestamp("check_in_actual");
        if (ts != null) br.setCheckInActual(ts.toLocalDateTime());
        ts = rs.getTimestamp("check_out_actual");
        if (ts != null) br.setCheckOutActual(ts.toLocalDateTime());
        ts = rs.getTimestamp("created_at");
        if (ts != null) br.setCreatedAt(ts.toLocalDateTime());
        return br;
    }

    public int insert(BookingRoom br) {
        String sql = """
            INSERT INTO BookingRoom (booking_id, room_id, type_id, unit_price,
                early_surcharge, late_surcharge, promotion_discount, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;
        return executeInsert(sql,
            br.getBookingId(), br.getRoomId(), br.getTypeId(), br.getUnitPrice(),
            br.getEarlySurcharge(), br.getLateSurcharge(), br.getPromotionDiscount(),
            br.getStatus());
    }

    public BookingRoom findById(int bookingRoomId) {
        return queryOne("SELECT * FROM BookingRoom WHERE booking_room_id = ?", bookingRoomId);
    }

    public List<BookingRoom> findByBookingId(int bookingId) {
        return queryList(
            "SELECT * FROM BookingRoom WHERE booking_id = ? ORDER BY booking_room_id",
            bookingId);
    }

    public List<BookingRoom> findByBookingIdWithDetails(int bookingId) {
        String sql = """
            SELECT br.*, r.room_number, r.status AS room_status,
                   rt.type_name, rt.base_price, rt.price_per_hour, rt.deposit_percent, rt.capacity
            FROM BookingRoom br
            LEFT JOIN Room r ON br.room_id = r.room_id
            JOIN RoomType rt ON br.type_id = rt.type_id
            WHERE br.booking_id = ?
            ORDER BY br.booking_room_id
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (var rs = ps.executeQuery()) {
                List<BookingRoom> list = new ArrayList<>();
                while (rs.next()) {
                    BookingRoom br = mapRow(rs);
                    RoomType rt = new RoomType();
                    rt.setTypeName(rs.getString("type_name"));
                    rt.setBasePrice(rs.getBigDecimal("base_price"));
                    rt.setPricePerHour(rs.getBigDecimal("price_per_hour"));
                    rt.setDepositPercent(rs.getBigDecimal("deposit_percent"));
                    rt.setCapacity(rs.getInt("capacity"));
                    br.setRoomType(rt);
                    String roomNumber = rs.getString("room_number");
                    if (roomNumber != null) {
                        Room room = new Room();
                        room.setRoomId(br.getRoomId() != null ? br.getRoomId() : 0);
                        room.setRoomNumber(roomNumber);
                        room.setStatus(rs.getString("room_status"));
                        room.setRoomType(rt);
                        br.setRoom(room);
                    }
                    list.add(br);
                }
                return list;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find booking rooms with details failed", e);
        }
    }

    public int updateStatus(int bookingRoomId, String status) {
        return executeUpdate(
            "UPDATE BookingRoom SET status = ? WHERE booking_room_id = ?",
            status, bookingRoomId);
    }

    public int updateRoomId(int bookingRoomId, int roomId) {
        return executeUpdate(
            "UPDATE BookingRoom SET room_id = ? WHERE booking_room_id = ?",
            roomId, bookingRoomId);
    }

    public int updateCheckInActual(int bookingRoomId, LocalDateTime checkInActual) {
        return executeUpdate(
            "UPDATE BookingRoom SET check_in_actual = ? WHERE booking_room_id = ?",
            Timestamp.valueOf(checkInActual), bookingRoomId);
    }

    public int updateCheckOutActual(int bookingRoomId, LocalDateTime checkOutActual) {
        return executeUpdate(
            "UPDATE BookingRoom SET check_out_actual = ? WHERE booking_room_id = ?",
            Timestamp.valueOf(checkOutActual), bookingRoomId);
    }

    public int updateEarlySurcharge(int bookingRoomId, java.math.BigDecimal earlySurcharge) {
        return executeUpdate(
            "UPDATE BookingRoom SET early_surcharge = ? WHERE booking_room_id = ?",
            earlySurcharge, bookingRoomId);
    }

    public int updateLateSurcharge(int bookingRoomId, java.math.BigDecimal lateSurcharge) {
        return executeUpdate(
            "UPDATE BookingRoom SET late_surcharge = ? WHERE booking_room_id = ?",
            lateSurcharge, bookingRoomId);
    }

    public int countByBookingIdAndStatus(int bookingId, String status) {
        String sql = "SELECT COUNT(*) FROM BookingRoom WHERE booking_id = ? AND status = ?";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.setString(2, status);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count booking rooms failed", e);
        }
        return 0;
    }

    // Returns true if ALL rooms in the booking match the given status
    public boolean allRoomsInStatus(int bookingId, String status) {
        String sql = """
            SELECT COUNT(*) FROM BookingRoom WHERE booking_id = ?
            AND status != ?
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.setString(2, status);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) == 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Check all rooms status failed", e);
        }
        return false;
    }
}
