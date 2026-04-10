package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Voucher;
import java.sql.ResultSet;
import java.sql.SQLException;

public class VoucherRepository extends BaseRepository<Voucher> {

    @Override
    protected Voucher mapRow(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setVoucherId(rs.getInt("voucher_id"));
        v.setCode(rs.getString("code"));
        v.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        v.setMinOrderValue(rs.getBigDecimal("min_order_value"));
        v.setActive(rs.getBoolean("is_active"));
        return v;
    }

    public Voucher findByCode(String code) {
        return queryOne("SELECT * FROM Voucher WHERE code = ? AND is_active = 1", code);
    }

    public Voucher findById(int voucherId) {
        return queryOne("SELECT * FROM Voucher WHERE voucher_id = ?", voucherId);
    }

    public java.util.List<Voucher> findAll() {
        return queryList("SELECT * FROM Voucher ORDER BY voucher_id DESC");
    }

    public int insert(Voucher voucher) {
        String sql = "INSERT INTO Voucher (code, discount_amount, min_order_value, is_active) VALUES (?, ?, ?, ?)";
        return executeInsert(sql, voucher.getCode(), voucher.getDiscountAmount(),
            voucher.getMinOrderValue(), voucher.isActive() ? 1 : 0);
    }

    public int update(Voucher voucher) {
        String sql = "UPDATE Voucher SET code = ?, discount_amount = ?, min_order_value = ?, is_active = ? WHERE voucher_id = ?";
        return executeUpdate(sql, voucher.getCode(), voucher.getDiscountAmount(),
            voucher.getMinOrderValue(), voucher.isActive() ? 1 : 0, voucher.getVoucherId());
    }

    public int delete(int voucherId) {
        return executeUpdate("DELETE FROM Voucher WHERE voucher_id = ?", voucherId);
    }
}
