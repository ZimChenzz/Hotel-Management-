package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Payment;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

public class PaymentRepository extends BaseRepository<Payment> {

    @Override
    protected Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPaymentId(rs.getInt("payment_id"));
        p.setInvoiceId(rs.getInt("invoice_id"));
        p.setCustomerId(rs.getInt("customer_id"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setTransactionCode(rs.getString("transaction_code"));
        p.setAmount(rs.getBigDecimal("amount"));
        Timestamp ts = rs.getTimestamp("payment_time");
        if (ts != null) p.setPaymentTime(ts.toLocalDateTime());
        p.setStatus(rs.getString("status"));
        return p;
    }

    public int insert(Payment payment) {
        String sql = """
            INSERT INTO Payment (invoice_id, customer_id, payment_method, transaction_code, amount, status)
            VALUES (?, ?, ?, ?, ?, ?)
            """;
        return executeInsert(sql, payment.getInvoiceId(), payment.getCustomerId(),
            payment.getPaymentMethod(), payment.getTransactionCode(),
            payment.getAmount(), payment.getStatus());
    }

    public Payment findById(int paymentId) {
        return queryOne("SELECT * FROM Payment WHERE payment_id = ?", paymentId);
    }

    public Payment findByTransactionCode(String transactionCode) {
        return queryOne("SELECT * FROM Payment WHERE transaction_code = ?", transactionCode);
    }

    public Payment findByInvoiceId(int invoiceId) {
        List<Payment> payments = queryList("SELECT * FROM Payment WHERE invoice_id = ? ORDER BY payment_id DESC", invoiceId);
        return payments.isEmpty() ? null : payments.get(0);
    }

    public int updateStatus(int paymentId, String status) {
        return executeUpdate("UPDATE Payment SET status = ? WHERE payment_id = ?", status, paymentId);
    }

    public boolean hasSuccessfulPayment(int invoiceId) {
        String sql = "SELECT COUNT(*) FROM Payment WHERE invoice_id = ? AND status = 'Success'";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Check payment failed", e);
        }
        return false;
    }

    public java.math.BigDecimal sumByDateRange(java.time.LocalDateTime start, java.time.LocalDateTime end) {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM Payment WHERE status = 'Success' AND payment_time BETWEEN ? AND ?";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(start));
            ps.setTimestamp(2, Timestamp.valueOf(end));
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Sum payment failed", e);
        }
        return java.math.BigDecimal.ZERO;
    }
}
