package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.RoomImage;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class RoomImageRepository extends BaseRepository<RoomImage> {

    @Override
    protected RoomImage mapRow(ResultSet rs) throws SQLException {
        RoomImage img = new RoomImage();
        img.setImageId(rs.getInt("image_id"));
        img.setTypeId(rs.getInt("type_id"));
        int roomId = rs.getInt("room_id");
        img.setRoomId(rs.wasNull() ? null : roomId);
        img.setImageUrl(rs.getString("image_url"));
        return img;
    }

    public List<RoomImage> findByTypeId(int typeId) {
        String sql = "SELECT * FROM RoomImage WHERE type_id = ? ORDER BY image_id";
        return queryList(sql, typeId);
    }

    public RoomImage findFirstByTypeId(int typeId) {
        String sql = "SELECT TOP 1 * FROM RoomImage WHERE type_id = ? ORDER BY image_id";
        return queryOne(sql, typeId);
    }

    public int insert(int typeId, String imageUrl) {
        String sql = "INSERT INTO RoomImage (type_id, image_url) VALUES (?, ?)";
        return executeInsert(sql, typeId, imageUrl);
    }

    public int deleteById(int imageId) {
        String sql = "DELETE FROM RoomImage WHERE image_id = ?";
        return executeUpdate(sql, imageId);
    }

    public List<RoomImage> findByRoomId(int roomId) {
        String sql = "SELECT * FROM RoomImage WHERE room_id = ? ORDER BY image_id";
        return queryList(sql, roomId);
    }

    public int insertForRoom(int roomId, String imageUrl) {
        String sql = "INSERT INTO RoomImage (type_id, room_id, image_url) SELECT type_id, ?, ? FROM Room WHERE room_id = ?";
        return executeInsert(sql, roomId, imageUrl, roomId);
    }
}
