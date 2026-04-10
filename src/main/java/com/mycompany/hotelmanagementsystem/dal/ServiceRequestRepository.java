package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.ServiceRequest;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

public class ServiceRequestRepository extends BaseRepository<ServiceRequest> {

    @Override
    protected ServiceRequest mapRow(ResultSet rs) throws SQLException {
        ServiceRequest sr = new ServiceRequest();
        sr.setRequestId(rs.getInt("request_id"));
        sr.setBookingId(rs.getInt("booking_id"));
        int staffId = rs.getInt("staff_id");
        sr.setStaffId(rs.wasNull() ? null : staffId);
        sr.setServiceType(rs.getString("service_type"));
        Timestamp ts = rs.getTimestamp("request_time");
        if (ts != null) sr.setRequestTime(ts.toLocalDateTime());
        sr.setStatus(rs.getString("status"));
        sr.setDescription(rs.getString("description"));
        sr.setPriority(rs.getString("priority"));
        sr.setNotes(rs.getString("notes"));
        Timestamp ct = rs.getTimestamp("completed_time");
        if (ct != null) sr.setCompletedTime(ct.toLocalDateTime());
        sr.setRoomNumber(rs.getString("room_number"));
        // Try to read staff_name from JOIN queries
        try {
            sr.setStaffName(rs.getString("staff_name"));
        } catch (SQLException ignored) {
            // staff_name column not present in simple queries
        }
        return sr;
    }

    public int insert(ServiceRequest request) {
        String sql = "INSERT INTO ServiceRequest (booking_id, service_type, status, description, priority, room_number) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        return executeInsert(sql,
                request.getBookingId(),
                request.getServiceType(),
                request.getStatus(),
                request.getDescription(),
                request.getPriority() != null ? request.getPriority() : "Normal",
                request.getRoomNumber());
    }

    public List<ServiceRequest> findByBookingId(int bookingId) {
        return queryList("SELECT * FROM ServiceRequest WHERE booking_id = ? ORDER BY request_time DESC", bookingId);
    }

    public ServiceRequest findById(int requestId) {
        return queryOne("SELECT * FROM ServiceRequest WHERE request_id = ?", requestId);
    }

    public boolean hasPendingRequest(int bookingId, String serviceType) {
        String sql = "SELECT COUNT(*) FROM ServiceRequest WHERE booking_id = ? AND service_type = ? AND status = 'Pending'";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.setString(2, serviceType);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Check pending request failed", e);
        }
        return false;
    }

    public int updateStatus(int requestId, String status) {
        return executeUpdate("UPDATE ServiceRequest SET status = ? WHERE request_id = ?", status, requestId);
    }

    // --- New methods for expanded service request flow ---

    public List<ServiceRequest> findAll() {
        return queryList("SELECT sr.*, a.full_name AS staff_name FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.staff_id = a.account_id "
                + "ORDER BY sr.request_time DESC");
    }

    public List<ServiceRequest> findByStatus(String status) {
        return queryList("SELECT sr.*, a.full_name AS staff_name FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.staff_id = a.account_id "
                + "WHERE sr.status = ? ORDER BY sr.request_time DESC", status);
    }

    public List<ServiceRequest> findPendingAndInProgress() {
        return queryList("SELECT sr.*, a.full_name AS staff_name FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.staff_id = a.account_id "
                + "WHERE sr.status IN ('Pending', 'In Progress') "
                + "ORDER BY CASE sr.priority "
                + "  WHEN 'Urgent' THEN 1 WHEN 'High' THEN 2 "
                + "  WHEN 'Normal' THEN 3 WHEN 'Low' THEN 4 ELSE 5 END, "
                + "sr.request_time ASC");
    }

    public List<ServiceRequest> findByStaffId(int staffId) {
        return queryList("SELECT sr.*, a.full_name AS staff_name FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.staff_id = a.account_id "
                + "WHERE sr.staff_id = ? ORDER BY sr.request_time DESC", staffId);
    }

    public int assignStaff(int requestId, int staffId) {
        return executeUpdate(
                "UPDATE ServiceRequest SET staff_id = ?, status = 'In Progress' WHERE request_id = ?",
                staffId, requestId);
    }

    public int complete(int requestId, String notes) {
        return executeUpdate(
                "UPDATE ServiceRequest SET status = 'Completed', notes = ?, completed_time = GETDATE() WHERE request_id = ?",
                notes, requestId);
    }

    public int reject(int requestId, String notes) {
        return executeUpdate(
                "UPDATE ServiceRequest SET status = 'Rejected', notes = ? WHERE request_id = ?",
                notes, requestId);
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM ServiceRequest WHERE status = ?";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count by status failed", e);
        }
        return 0;
    }

    public int countTodayByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM ServiceRequest WHERE status = ? "
                   + "AND CAST(request_time AS DATE) = CAST(GETDATE() AS DATE)";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count today by status failed", e);
        }
        return 0;
    }

    public int countToday() {
        String sql = "SELECT COUNT(*) FROM ServiceRequest "
                   + "WHERE CAST(request_time AS DATE) = CAST(GETDATE() AS DATE)";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Count today failed", e);
        }
        return 0;
    }

    public ServiceRequest findPendingCleaningByRoomNumber(String roomNumber) {
        String sql = "SELECT sr.*, a.full_name AS staff_name FROM ServiceRequest sr "
                + "LEFT JOIN Account a ON sr.staff_id = a.account_id "
                + "WHERE sr.room_number = ? AND sr.service_type = 'Cleaning' "
                + "AND sr.status IN ('Pending', 'In Progress') "
                + "ORDER BY sr.request_time DESC";
        return queryOne(sql, roomNumber);
    }
}
