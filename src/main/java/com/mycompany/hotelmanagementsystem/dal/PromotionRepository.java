package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Promotion;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class PromotionRepository extends BaseRepository<Promotion> {

    @Override
    protected Promotion mapRow(ResultSet rs) throws SQLException {
        Promotion p = new Promotion();
        p.setPromotionId(rs.getInt("promotion_id"));
        p.setTypeId(rs.getInt("type_id"));
        p.setPromoCode(rs.getString("promo_code"));
        p.setDiscountPercent(rs.getBigDecimal("discount_percent"));
        p.setStartDate(rs.getDate("start_date").toLocalDate());
        p.setEndDate(rs.getDate("end_date").toLocalDate());
        // type_name only present in JOIN queries - ignore if absent
        try { p.setTypeName(rs.getString("type_name")); } catch (SQLException ignored) {}
        return p;
    }

    public List<Promotion> findAll() {
        String sql = "SELECT p.*, rt.type_name FROM Promotion p "
                   + "JOIN RoomType rt ON p.type_id = rt.type_id "
                   + "ORDER BY p.promotion_id DESC";
        return queryList(sql);
    }

    public Promotion findById(int promotionId) {
        String sql = "SELECT p.*, rt.type_name FROM Promotion p "
                   + "JOIN RoomType rt ON p.type_id = rt.type_id "
                   + "WHERE p.promotion_id = ?";
        return queryOne(sql, promotionId);
    }

    /**
     * Find the currently active promotion for a room type.
     * If multiple overlap, returns the most recently created one.
     */
    public Promotion findActiveByTypeId(int typeId) {
        String sql = "SELECT TOP 1 p.*, rt.type_name FROM Promotion p "
                   + "JOIN RoomType rt ON p.type_id = rt.type_id "
                   + "WHERE p.type_id = ? "
                   + "AND CAST(GETDATE() AS DATE) BETWEEN p.start_date AND p.end_date "
                   + "ORDER BY p.promotion_id DESC";
        return queryOne(sql, typeId);
    }

    public int insert(Promotion p) {
        String sql = "INSERT INTO Promotion (type_id, promo_code, discount_percent, start_date, end_date) "
                   + "VALUES (?, ?, ?, ?, ?)";
        return executeInsert(sql,
            p.getTypeId(), p.getPromoCode(), p.getDiscountPercent(),
            java.sql.Date.valueOf(p.getStartDate()),
            java.sql.Date.valueOf(p.getEndDate()));
    }

    public int update(Promotion p) {
        String sql = "UPDATE Promotion SET type_id=?, promo_code=?, discount_percent=?, "
                   + "start_date=?, end_date=? WHERE promotion_id=?";
        return executeUpdate(sql,
            p.getTypeId(), p.getPromoCode(), p.getDiscountPercent(),
            java.sql.Date.valueOf(p.getStartDate()),
            java.sql.Date.valueOf(p.getEndDate()),
            p.getPromotionId());
    }

    public int delete(int promotionId) {
        return executeUpdate("DELETE FROM Promotion WHERE promotion_id = ?", promotionId);
    }
}
