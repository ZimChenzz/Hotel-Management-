package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Invoice;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

public class InvoiceRepository extends BaseRepository<Invoice> {

    @Override
    protected Invoice mapRow(ResultSet rs) throws SQLException {
        Invoice inv = new Invoice();
        inv.setInvoiceId(rs.getInt("invoice_id"));
        inv.setBookingId(rs.getInt("booking_id"));
        Timestamp ts = rs.getTimestamp("issued_date");
        if (ts != null) inv.setIssuedDate(ts.toLocalDateTime());
        inv.setTotalAmount(rs.getBigDecimal("total_amount"));
        inv.setTaxAmount(rs.getBigDecimal("tax_amount"));
        inv.setInvoiceType(rs.getString("invoice_type"));
        return inv;
    }

    public int insert(Invoice invoice) {
        String sql = "INSERT INTO Invoice (booking_id, total_amount, tax_amount, invoice_type) VALUES (?, ?, ?, ?)";
        return executeInsert(sql, invoice.getBookingId(), invoice.getTotalAmount(),
            invoice.getTaxAmount(), invoice.getInvoiceType());
    }

    public Invoice findById(int invoiceId) {
        return queryOne("SELECT * FROM Invoice WHERE invoice_id = ?", invoiceId);
    }

    public Invoice findByBookingId(int bookingId) {
        return queryOne("SELECT * FROM Invoice WHERE booking_id = ? AND invoice_type = 'Booking'", bookingId);
    }

    public Invoice findByBookingIdAndType(int bookingId, String invoiceType) {
        return queryOne(
            "SELECT TOP 1 * FROM Invoice WHERE booking_id = ? AND invoice_type = ? ORDER BY invoice_id DESC",
            bookingId, invoiceType);
    }

    public List<Invoice> findAllByBookingId(int bookingId) {
        return queryList("SELECT * FROM Invoice WHERE booking_id = ? ORDER BY issued_date", bookingId);
    }
}
