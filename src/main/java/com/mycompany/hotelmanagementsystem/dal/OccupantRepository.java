package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Occupant;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class OccupantRepository extends BaseRepository<Occupant> {

    @Override
    protected Occupant mapRow(ResultSet rs) throws SQLException {
        Occupant o = new Occupant();
        o.setOccupantId(rs.getInt("occupant_id"));
        o.setBookingId(rs.getInt("booking_id"));
        o.setFullName(rs.getString("full_name"));
        o.setIdCardNumber(rs.getString("id_card_number"));
        o.setPhoneNumber(rs.getString("phone_number"));
        try {
            int brId = rs.getInt("booking_room_id");
            o.setBookingRoomId(rs.wasNull() ? null : brId);
        } catch (SQLException ignored) {}
        return o;
    }

    public int insert(Occupant occupant) {
        String sql = "INSERT INTO Occupant (booking_id, full_name, id_card_number, phone_number) VALUES (?, ?, ?, ?)";
        return executeInsert(sql, occupant.getBookingId(), occupant.getFullName(),
            occupant.getIdCardNumber(), occupant.getPhoneNumber());
    }

    public List<Occupant> findByBookingId(int bookingId) {
        return queryList("SELECT * FROM Occupant WHERE booking_id = ?", bookingId);
    }

    public int update(Occupant occupant) {
        String sql = "UPDATE Occupant SET full_name = ?, id_card_number = ?, phone_number = ? WHERE occupant_id = ?";
        return executeUpdate(sql, occupant.getFullName(), occupant.getIdCardNumber(),
            occupant.getPhoneNumber(), occupant.getOccupantId());
    }

    public int deleteByBookingId(int bookingId) {
        return executeUpdate("DELETE FROM Occupant WHERE booking_id = ?", bookingId);
    }

    public int insertWithRoom(Occupant occupant) {
        String sql = "INSERT INTO Occupant (booking_id, booking_room_id, full_name, id_card_number, phone_number) VALUES (?, ?, ?, ?, ?)";
        return executeInsert(sql, occupant.getBookingId(), occupant.getBookingRoomId(),
            occupant.getFullName(), occupant.getIdCardNumber(), occupant.getPhoneNumber());
    }

    public List<Occupant> findByBookingRoomId(int bookingRoomId) {
        return queryList("SELECT * FROM Occupant WHERE booking_room_id = ?", bookingRoomId);
    }
}
