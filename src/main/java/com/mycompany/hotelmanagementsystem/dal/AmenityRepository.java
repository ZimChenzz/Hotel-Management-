package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Amenity;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class AmenityRepository extends BaseRepository<Amenity> {

    @Override
    protected Amenity mapRow(ResultSet rs) throws SQLException {
        Amenity a = new Amenity();
        a.setAmenityId(rs.getInt("amenity_id"));
        a.setName(rs.getString("name"));
        a.setIconUrl(rs.getString("icon_url"));
        return a;
    }

    public List<Amenity> findByTypeId(int typeId) {
        String sql = """
            SELECT a.* FROM Amenity a
            JOIN RoomType_Amenity rta ON a.amenity_id = rta.amenity_id
            WHERE rta.type_id = ?
            ORDER BY a.name
            """;
        return queryList(sql, typeId);
    }

    public List<Amenity> findAll() {
        String sql = "SELECT * FROM Amenity ORDER BY name";
        return queryList(sql);
    }
}
