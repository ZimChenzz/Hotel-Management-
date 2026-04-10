package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.*;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class FeedbackRepository extends BaseRepository<Feedback> {

    @Override
    protected Feedback mapRow(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setFeedbackId(rs.getInt("feedback_id"));
        f.setBookingId(rs.getInt("booking_id"));
        f.setRating(rs.getInt("rating"));
        f.setComment(rs.getString("comment"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) f.setCreatedAt(ts.toLocalDateTime());
        f.setHidden(rs.getBoolean("is_hidden"));
        try {
            f.setAdminReply(rs.getString("admin_reply"));
        } catch (SQLException ignored) {}
        return f;
    }

    public int insert(Feedback feedback) {
        String sql = "INSERT INTO Feedback (booking_id, rating, comment) VALUES (?, ?, ?)";
        return executeInsert(sql, feedback.getBookingId(), feedback.getRating(), feedback.getComment());
    }

    public Feedback findByBookingId(int bookingId) {
        String sql = """
            SELECT f.*, fr.reply_content AS admin_reply
            FROM Feedback f
            LEFT JOIN FeedbackReply fr ON f.feedback_id = fr.feedback_id
            WHERE f.booking_id = ?
            """;
        return queryOne(sql, bookingId);
    }

    public Feedback findById(int feedbackId) {
        return queryOne("SELECT * FROM Feedback WHERE feedback_id = ?", feedbackId);
    }

    public boolean existsByBookingId(int bookingId) {
        String sql = "SELECT COUNT(*) FROM Feedback WHERE booking_id = ?";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Check feedback exists failed", e);
        }
        return false;
    }

    public List<Feedback> findAllWithDetails() {
        String sql = """
            SELECT f.*, a.full_name as customer_name, r.room_number, rt.type_name,
                   fr.reply_content AS admin_reply
            FROM Feedback f
            JOIN Booking b ON f.booking_id = b.booking_id
            JOIN Account a ON b.customer_id = a.account_id
            JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON r.type_id = rt.type_id
            LEFT JOIN FeedbackReply fr ON f.feedback_id = fr.feedback_id
            ORDER BY f.created_at DESC
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            try (var rs = ps.executeQuery()) {
                List<Feedback> list = new ArrayList<>();
                while (rs.next()) {
                    Feedback f = mapRow(rs);
                    Booking booking = new Booking();
                    booking.setBookingId(f.getBookingId());
                    Customer customer = new Customer();
                    Account account = new Account();
                    account.setFullName(rs.getString("customer_name"));
                    customer.setAccount(account);
                    booking.setCustomer(customer);
                    Room room = new Room();
                    room.setRoomNumber(rs.getString("room_number"));
                    RoomType roomType = new RoomType();
                    roomType.setTypeName(rs.getString("type_name"));
                    room.setRoomType(roomType);
                    booking.setRoom(room);
                    f.setBooking(booking);
                    list.add(f);
                }
                return list;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find all feedback failed", e);
        }
    }

    public List<Feedback> findVisibleWithDetails(int limit) {
        String sql = """
            SELECT TOP (?) f.*, a.full_name AS customer_name, r.room_number, rt.type_name,
                   fr.reply_content AS admin_reply
            FROM Feedback f
            JOIN Booking b ON f.booking_id = b.booking_id
            JOIN Account a ON b.customer_id = a.account_id
            JOIN Room r ON b.room_id = r.room_id
            JOIN RoomType rt ON r.type_id = rt.type_id
            LEFT JOIN FeedbackReply fr ON f.feedback_id = fr.feedback_id
            WHERE f.is_hidden = 0 AND f.rating >= 4
            ORDER BY f.rating DESC, f.created_at DESC
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (var rs = ps.executeQuery()) {
                List<Feedback> list = new ArrayList<>();
                while (rs.next()) {
                    Feedback f = mapRow(rs);
                    Booking booking = new Booking();
                    booking.setBookingId(f.getBookingId());
                    Customer customer = new Customer();
                    Account account = new Account();
                    account.setFullName(rs.getString("customer_name"));
                    customer.setAccount(account);
                    booking.setCustomer(customer);
                    Room room = new Room();
                    room.setRoomNumber(rs.getString("room_number"));
                    RoomType roomType = new RoomType();
                    roomType.setTypeName(rs.getString("type_name"));
                    room.setRoomType(roomType);
                    booking.setRoom(room);
                    f.setBooking(booking);
                    list.add(f);
                }
                return list;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find visible feedback failed", e);
        }
    }

    public int updateIsHidden(int feedbackId, boolean isHidden) {
        return executeUpdate("UPDATE Feedback SET is_hidden = ? WHERE feedback_id = ?",
            isHidden ? 1 : 0, feedbackId);
    }

    public int upsertReply(int feedbackId, int adminId, String reply) {
        String sql = """
            MERGE FeedbackReply WITH (HOLDLOCK) AS target
            USING (SELECT ? AS feedback_id, ? AS admin_id, ? AS reply_content) AS source
                ON target.feedback_id = source.feedback_id
            WHEN MATCHED THEN
                UPDATE SET reply_content = source.reply_content, reply_date = GETDATE()
            WHEN NOT MATCHED THEN
                INSERT (feedback_id, admin_id, reply_content)
                VALUES (source.feedback_id, source.admin_id, source.reply_content);
            """;
        return executeUpdate(sql, feedbackId, adminId, reply);
    }

    public int update(Feedback feedback) {
        return executeUpdate("UPDATE Feedback SET rating = ?, comment = ? WHERE feedback_id = ?",
            feedback.getRating(), feedback.getComment(), feedback.getFeedbackId());
    }

    public int delete(int feedbackId) {
        return executeUpdate("DELETE FROM Feedback WHERE feedback_id = ?", feedbackId);
    }
}
