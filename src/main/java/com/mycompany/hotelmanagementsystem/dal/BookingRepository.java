package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.*;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class BookingRepository extends BaseRepository<Booking> {

    @Override
    protected Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getInt("booking_id"));
        b.setCustomerId(rs.getInt("customer_id"));
        int roomId = rs.getInt("room_id");
        b.setRoomId(rs.wasNull() ? null : roomId);
        int typeId = rs.getInt("type_id");
        b.setTypeId(rs.wasNull() ? 0 : typeId);
        int voucherId = rs.getInt("voucher_id");
        b.setVoucherId(rs.wasNull() ? null : voucherId);
        Timestamp ts = rs.getTimestamp("booking_date");
        if (ts != null) b.setBookingDate(ts.toLocalDateTime());
        ts = rs.getTimestamp("check_in_expected");
        if (ts != null) b.setCheckInExpected(ts.toLocalDateTime());
        ts = rs.getTimestamp("check_out_expected");
        if (ts != null) b.setCheckOutExpected(ts.toLocalDateTime());
        b.setTotalPrice(rs.getBigDecimal("total_price"));
        b.setPaymentType(rs.getString("payment_type"));
        b.setDepositAmount(rs.getBigDecimal("deposit_amount"));
        b.setStatus(rs.getString("status"));
        b.setNote(rs.getString("note"));
        // Read surcharge columns (may not exist in all queries, use try-catch)
        try {
            b.setEarlySurcharge(rs.getBigDecimal("early_surcharge"));
            b.setLateSurcharge(rs.getBigDecimal("late_surcharge"));
        } catch (SQLException ignored) {
            // Columns may not exist in some older queries
        }
        ts = rs.getTimestamp("check_in_actual");
        if (ts != null) b.setCheckInActual(ts.toLocalDateTime());
        ts = rs.getTimestamp("check_out_actual");
        if (ts != null) b.setCheckOutActual(ts.toLocalDateTime());
        return b;
    }

    public int insert(Booking booking) {
        String sql = """
            INSERT INTO Booking (customer_id, room_id, type_id, voucher_id,
                check_in_expected, check_out_expected, total_price,
                payment_type, deposit_amount, status, note)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        return executeInsert(sql,
            booking.getCustomerId(), booking.getRoomId(), booking.getTypeId(),
            booking.getVoucherId(),
            Timestamp.valueOf(booking.getCheckInExpected()),
            Timestamp.valueOf(booking.getCheckOutExpected()),
            booking.getTotalPrice(), booking.getPaymentType(),
            booking.getDepositAmount(), booking.getStatus(), booking.getNote());
    }

    public Booking findById(int bookingId) {
        return queryOne("SELECT * FROM Booking WHERE booking_id = ?", bookingId);
    }

    public Booking findByIdWithDetails(int bookingId) {
        String sql = """
            SELECT b.*, r.room_number,
                   rt.type_id AS rt_type_id, rt.type_name, rt.base_price,
                   rt.price_per_hour, rt.deposit_percent
            FROM Booking b
            LEFT JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON b.type_id = rt.type_id
            WHERE b.booking_id = ?
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    Booking b = mapRow(rs);
                    RoomType rt = new RoomType();
                    rt.setTypeId(rs.getInt("rt_type_id"));
                    rt.setTypeName(rs.getString("type_name"));
                    rt.setBasePrice(rs.getBigDecimal("base_price"));
                    rt.setPricePerHour(rs.getBigDecimal("price_per_hour"));
                    rt.setDepositPercent(rs.getBigDecimal("deposit_percent"));
                    b.setRoomType(rt);
                    // Room may be null if not yet assigned
                    String roomNumber = rs.getString("room_number");
                    if (roomNumber != null) {
                        Room room = new Room();
                        room.setRoomId(b.getRoomId());
                        room.setRoomNumber(roomNumber);
                        room.setRoomType(rt);
                        b.setRoom(room);
                    }
                    return b;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find booking failed", e);
        }
        return null;
    }

    public List<Booking> findByCustomerId(int customerId) {
        String sql = """
            SELECT b.*, r.room_number, rt.type_name
            FROM Booking b
            LEFT JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON b.type_id = rt.type_id
            WHERE b.customer_id = ?
            ORDER BY b.booking_date DESC
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (var rs = ps.executeQuery()) {
                List<Booking> list = new ArrayList<>();
                while (rs.next()) {
                    Booking b = mapRow(rs);
                    RoomType rt = new RoomType();
                    rt.setTypeName(rs.getString("type_name"));
                    b.setRoomType(rt);
                    String roomNumber = rs.getString("room_number");
                    if (roomNumber != null) {
                        Room room = new Room();
                        room.setRoomNumber(roomNumber);
                        room.setRoomType(rt);
                        b.setRoom(room);
                    }
                    list.add(b);
                }
                return list;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find bookings failed", e);
        }
    }

    public int updateStatus(int bookingId, String status) {
        return executeUpdate("UPDATE Booking SET status = ? WHERE booking_id = ?", status, bookingId);
    }

    /**
     * Cancel all Pending/Confirmed bookings where check-in time + 1 minute has passed.
     * Returns number of cancelled bookings.
     */
    public int cancelOverdueBookings() {
        String sql = """
            UPDATE Booking SET status = 'Cancelled'
            WHERE status IN ('Pending', 'Confirmed')
            AND DATEADD(MINUTE, 1, check_in_expected) < GETDATE()
            """;
        return executeUpdate(sql);
    }

    public boolean isRoomAvailable(int roomId, LocalDateTime checkIn, LocalDateTime checkOut) {
        String sql = """
            SELECT COUNT(*) FROM Booking
            WHERE room_id = ? AND status IN ('Pending', 'Confirmed', 'CheckedIn')
            AND NOT (check_out_expected <= ? OR check_in_expected >= ?)
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setTimestamp(2, Timestamp.valueOf(checkIn));
            ps.setTimestamp(3, Timestamp.valueOf(checkOut));
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) == 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Check availability failed", e);
        }
        return false;
    }

    public List<Booking> findByStatus(String status) {
        String sql = """
            SELECT b.*, r.room_number, rt.type_name, a.full_name as customer_name
            FROM Booking b
            LEFT JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON b.type_id = rt.type_id
            JOIN Account a ON b.customer_id = a.account_id
            WHERE b.status = ?
            ORDER BY b.check_in_expected ASC
            """;
        return findBookingsWithDetails(sql, status);
    }

    public List<Booking> findByStatuses(List<String> statuses) {
        if (statuses == null || statuses.isEmpty()) return new ArrayList<>();
        String placeholders = String.join(",", statuses.stream().map(s -> "?").toList());
        String sql = """
            SELECT b.*, r.room_number, rt.type_name, a.full_name as customer_name
            FROM Booking b
            LEFT JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON b.type_id = rt.type_id
            JOIN Account a ON b.customer_id = a.account_id
            WHERE b.status IN (%s)
            ORDER BY b.check_in_expected ASC
            """.formatted(placeholders);
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < statuses.size(); i++) {
                ps.setString(i + 1, statuses.get(i));
            }
            try (var rs = ps.executeQuery()) {
                return mapBookingsWithDetails(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find bookings failed", e);
        }
    }

    public List<Booking> findAll() {
        String sql = """
            SELECT b.*, r.room_number, rt.type_name, a.full_name as customer_name
            FROM Booking b
            LEFT JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON b.type_id = rt.type_id
            JOIN Account a ON b.customer_id = a.account_id
            ORDER BY b.booking_date DESC
            """;
        return findBookingsWithDetails(sql);
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Booking WHERE status = ?";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count bookings failed", e);
        }
        return 0;
    }

    public int updateRoomId(int bookingId, int roomId) {
        return executeUpdate("UPDATE Booking SET room_id = ? WHERE booking_id = ?", roomId, bookingId);
    }

    public int updateCheckInActual(int bookingId, LocalDateTime checkInActual) {
        return executeUpdate("UPDATE Booking SET check_in_actual = ? WHERE booking_id = ?",
            Timestamp.valueOf(checkInActual), bookingId);
    }

    public int updateCheckOutActual(int bookingId, LocalDateTime checkOutActual) {
        return executeUpdate("UPDATE Booking SET check_out_actual = ? WHERE booking_id = ?",
            Timestamp.valueOf(checkOutActual), bookingId);
    }

    public int updateCheckOutExpected(int bookingId, LocalDateTime newCheckOut) {
        return executeUpdate("UPDATE Booking SET check_out_expected = ? WHERE booking_id = ?",
            Timestamp.valueOf(newCheckOut), bookingId);
    }

    public int updateDepositAmount(int bookingId, java.math.BigDecimal amount) {
        return executeUpdate("UPDATE Booking SET deposit_amount = ? WHERE booking_id = ?",
            amount, bookingId);
    }

    public int updateEarlySurcharge(int bookingId, java.math.BigDecimal earlySurcharge) {
        return executeUpdate("UPDATE Booking SET early_surcharge = ? WHERE booking_id = ?",
            earlySurcharge, bookingId);
    }

    public int updateLateSurcharge(int bookingId, java.math.BigDecimal lateSurcharge) {
        return executeUpdate("UPDATE Booking SET late_surcharge = ? WHERE booking_id = ?",
            lateSurcharge, bookingId);
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM Booking";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count bookings failed", e);
        }
        return 0;
    }

    // Revenue = sum of actual payments received (not full booking price)
    public java.math.BigDecimal sumTotalPrice() {
        String sql = "SELECT COALESCE(SUM(p.amount), 0) "
                   + "FROM Payment p "
                   + "JOIN Invoice i ON p.invoice_id = i.invoice_id "
                   + "JOIN Booking b ON i.booking_id = b.booking_id "
                   + "WHERE p.status = 'Success' "
                   + "  AND b.status IN ('CheckedIn', 'CheckedOut')";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Sum total price failed", e);
        }
        return java.math.BigDecimal.ZERO;
    }

    // Revenue by date range = sum of actual payments received
    public java.math.BigDecimal sumTotalPriceByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT COALESCE(SUM(p.amount), 0) "
                   + "FROM Payment p "
                   + "JOIN Invoice i ON p.invoice_id = i.invoice_id "
                   + "JOIN Booking b ON i.booking_id = b.booking_id "
                   + "WHERE p.status = 'Success' "
                   + "  AND b.status IN ('CheckedIn', 'CheckedOut') "
                   + "  AND b.booking_date BETWEEN ? AND ?";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(startDate));
            ps.setTimestamp(2, Timestamp.valueOf(endDate));
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Sum total price failed", e);
        }
        return java.math.BigDecimal.ZERO;
    }

    public int countByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT COUNT(*) FROM Booking WHERE booking_date BETWEEN ? AND ?";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(startDate));
            ps.setTimestamp(2, Timestamp.valueOf(endDate));
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count bookings failed", e);
        }
        return 0;
    }

    private List<Booking> findBookingsWithDetails(String sql, Object... params) {
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (var rs = ps.executeQuery()) {
                return mapBookingsWithDetails(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find bookings failed", e);
        }
    }

    private List<Booking> mapBookingsWithDetails(ResultSet rs) throws SQLException {
        List<Booking> list = new ArrayList<>();
        while (rs.next()) {
            Booking b = mapRow(rs);
            RoomType rt = new RoomType();
            rt.setTypeName(rs.getString("type_name"));
            b.setRoomType(rt);
            String roomNumber = rs.getString("room_number");
            if (roomNumber != null) {
                Room room = new Room();
                room.setRoomNumber(roomNumber);
                room.setRoomType(rt);
                b.setRoom(room);
            }
            try {
                String customerName = rs.getString("customer_name");
                if (customerName != null) {
                    Customer c = new Customer();
                    Account a = new Account();
                    a.setFullName(customerName);
                    c.setAccount(a);
                    b.setCustomer(c);
                }
            } catch (SQLException ignored) {}
            list.add(b);
        }
        return list;
    }

    public Booking findCurrentBookingForRoom(int roomId) {
        String sql = """
            SELECT b.*, r.room_number, rt.type_name, a.full_name as customer_name,
                   a.email as customer_email, a.phone as customer_phone
            FROM Booking b
            LEFT JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON b.type_id = rt.type_id
            JOIN Account a ON b.customer_id = a.account_id
            WHERE b.room_id = ? AND b.status = 'CheckedIn'
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    Booking b = mapRow(rs);
                    RoomType rt = new RoomType();
                    rt.setTypeName(rs.getString("type_name"));
                    b.setRoomType(rt);
                    String roomNumber = rs.getString("room_number");
                    if (roomNumber != null) {
                        Room room = new Room();
                        room.setRoomNumber(roomNumber);
                        b.setRoom(room);
                    }
                    Customer c = new Customer();
                    Account a = new Account();
                    a.setFullName(rs.getString("customer_name"));
                    a.setEmail(rs.getString("customer_email"));
                    a.setPhone(rs.getString("customer_phone"));
                    c.setAccount(a);
                    b.setCustomer(c);
                    return b;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find current booking failed", e);
        }
        return null;
    }

    public List<Booking> findByRoomId(int roomId) {
        String sql = """
            SELECT b.*, r.room_number, rt.type_name, a.full_name as customer_name
            FROM Booking b
            LEFT JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON b.type_id = rt.type_id
            JOIN Account a ON b.customer_id = a.account_id
            WHERE b.room_id = ?
            ORDER BY b.check_in_expected DESC
            """;
        return findBookingsWithDetails(sql, roomId);
    }

    // Find standard room bookings that should be auto-cancelled
    // (Pending + deposit_percent=0 + 6h past check_in_expected + no actual check-in)
    public List<Booking> findPendingStandardBookingsToCancel() {
        String sql = """
            SELECT b.*, r.room_number, rt.type_name
            FROM Booking b
            LEFT JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON b.type_id = rt.type_id
            WHERE b.status = 'Pending'
              AND rt.deposit_percent = 0
              AND b.check_in_actual IS NULL
              AND DATEADD(HOUR, 6, b.check_in_expected) < GETDATE()
            """;
        return findBookingsWithDetails(sql);
    }

    // Check if any active booking exists for room after given date (for extension eligibility)
    public boolean hasConflictAfterDate(int roomId, LocalDateTime afterDate) {
        String sql = """
            SELECT COUNT(*) FROM Booking
            WHERE room_id = ? AND status IN ('Pending', 'Confirmed', 'CheckedIn')
            AND check_in_expected >= ?
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setTimestamp(2, Timestamp.valueOf(afterDate));
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Check conflict failed", e);
        }
        return true;
    }

    /**
     * Lấy tất cả khoảng ngày đã đặt (active) theo loại phòng để hiển thị lịch cho customer.
     * Trả về list gồm các cặp [checkInExpected, checkOutExpected].
     */
    public List<LocalDateTime[]> findOccupiedDateRangesByTypeId(int typeId) {
        String sql = """
            SELECT b.check_in_expected, b.check_out_expected
            FROM Booking b
            JOIN Room r ON b.room_id = r.room_id
            WHERE r.type_id = ?
              AND b.status IN ('Pending', 'Confirmed', 'CheckedIn')
            ORDER BY b.check_in_expected
            """;
        List<LocalDateTime[]> result = new ArrayList<>();
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            try (var rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDateTime[] range = new LocalDateTime[2];
                    Timestamp tsIn = rs.getTimestamp("check_in_expected");
                    Timestamp tsOut = rs.getTimestamp("check_out_expected");
                    range[0] = tsIn != null ? tsIn.toLocalDateTime() : null;
                    range[1] = tsOut != null ? tsOut.toLocalDateTime() : null;
                    result.add(range);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find occupied dates failed", e);
        }
        return result;
    }

    // Check if a specific booking is overdue for auto-cancel (lazy check)
    public boolean isOverdueStandardBooking(int bookingId) {
        String sql = """
            SELECT COUNT(*) FROM Booking b
            JOIN RoomType rt ON b.type_id = rt.type_id
            WHERE b.booking_id = ?
              AND b.status = 'Pending'
              AND rt.deposit_percent = 0
              AND b.check_in_actual IS NULL
              AND DATEADD(HOUR, 6, b.check_in_expected) < GETDATE()
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Check overdue failed", e);
        }
        return false;
    }

    public Booking findByIdWithRooms(int bookingId) {
        Booking b = findByIdWithDetails(bookingId);
        if (b != null) {
            BookingRoomRepository brRepo = new BookingRoomRepository();
            b.setBookingRooms(brRepo.findByBookingIdWithDetails(bookingId));
        }
        return b;
    }
}
