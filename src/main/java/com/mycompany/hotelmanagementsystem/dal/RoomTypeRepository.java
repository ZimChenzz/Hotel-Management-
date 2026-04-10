package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.RoomType;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class RoomTypeRepository extends BaseRepository<RoomType> {

    @Override
    protected RoomType mapRow(ResultSet rs) throws SQLException {
        RoomType rt = new RoomType();
        rt.setTypeId(rs.getInt("type_id"));
        rt.setTypeName(rs.getString("type_name"));
        rt.setBasePrice(rs.getBigDecimal("base_price"));
        rt.setPricePerHour(rs.getBigDecimal("price_per_hour"));
        rt.setDepositPercent(rs.getBigDecimal("deposit_percent"));
        rt.setCapacity(rs.getInt("capacity"));
        rt.setDescription(rs.getString("description"));
        return rt;
    }

    public List<RoomType> findAll() {
        String sql = "SELECT * FROM RoomType ORDER BY base_price";
        return queryList(sql);
    }

    public RoomType findById(int typeId) {
        String sql = "SELECT * FROM RoomType WHERE type_id = ?";
        return queryOne(sql, typeId);
    }

    public List<RoomType> findByFilters(Integer minPrice, Integer maxPrice,
            Integer minCapacity, Integer typeId) {
        StringBuilder sql = new StringBuilder("SELECT * FROM RoomType WHERE 1=1");

        if (minPrice != null) {
            sql.append(" AND base_price >= ").append(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND base_price <= ").append(maxPrice);
        }
        if (minCapacity != null) {
            sql.append(" AND capacity >= ").append(minCapacity);
        }
        if (typeId != null) {
            sql.append(" AND type_id = ").append(typeId);
        }
        sql.append(" ORDER BY base_price");

        return queryList(sql.toString());
    }

    public int insert(RoomType roomType) {
        String sql = "INSERT INTO RoomType (type_name, base_price, price_per_hour, deposit_percent, capacity, description) VALUES (?, ?, ?, ?, ?, ?)";
        return executeInsert(sql, roomType.getTypeName(), roomType.getBasePrice(),
            roomType.getPricePerHour(), roomType.getDepositPercent(),
            roomType.getCapacity(), roomType.getDescription());
    }

    public int update(RoomType roomType) {
        String sql = "UPDATE RoomType SET type_name = ?, base_price = ?, price_per_hour = ?, deposit_percent = ?, capacity = ?, description = ? WHERE type_id = ?";
        return executeUpdate(sql, roomType.getTypeName(), roomType.getBasePrice(),
            roomType.getPricePerHour(), roomType.getDepositPercent(),
            roomType.getCapacity(), roomType.getDescription(), roomType.getTypeId());
    }

    public int delete(int typeId) {
        String sql = "DELETE FROM RoomType WHERE type_id = ?";
        return executeUpdate(sql, typeId);
    }
}
