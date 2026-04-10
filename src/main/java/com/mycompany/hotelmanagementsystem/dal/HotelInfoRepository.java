package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.HotelInfo;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

/**
 * Repository for HotelInfo table.
 * Singleton row pattern - findFirst() returns the only row.
 */
public class HotelInfoRepository extends BaseRepository<HotelInfo> {

    @Override
    protected HotelInfo mapRow(ResultSet rs) throws SQLException {
        HotelInfo info = new HotelInfo();
        info.setInfoId(rs.getInt("info_id"));
        info.setName(rs.getString("hotel_name"));
        info.setSlogan(rs.getString("slogan"));
        info.setShortDescription(rs.getString("short_description"));
        info.setFullDescription(rs.getString("full_description"));
        info.setAddress(rs.getString("address"));
        info.setCity(rs.getString("city"));
        info.setPhone(rs.getString("phone"));
        info.setEmail(rs.getString("email"));
        info.setWebsite(rs.getString("website"));
        info.setCheckInTime(rs.getString("check_in_time"));
        info.setCheckOutTime(rs.getString("check_out_time"));
        info.setCancellationPolicy(rs.getString("cancellation_policy"));
        info.setPolicies(rs.getString("policies"));
        info.setLogoUrl(rs.getString("logo_url"));
        info.setFacebook(rs.getString("facebook"));
        info.setInstagram(rs.getString("instagram"));
        info.setTwitter(rs.getString("twitter"));
        info.setAmenities(rs.getString("amenities"));
        Timestamp ts = rs.getTimestamp("updated_at");
        if (ts != null) {
            info.setUpdatedAt(ts.toLocalDateTime());
        }
        return info;
    }

    /** Get the singleton hotel info row (first row) */
    public HotelInfo findFirst() {
        String sql = "SELECT TOP 1 * FROM HotelInfo";
        return queryOne(sql);
    }

    /** Update all hotel info fields */
    public int update(HotelInfo info) {
        String sql = """
            UPDATE HotelInfo SET
                hotel_name = ?, slogan = ?, short_description = ?, full_description = ?,
                address = ?, city = ?, phone = ?, email = ?, website = ?,
                check_in_time = ?, check_out_time = ?,
                cancellation_policy = ?, policies = ?,
                logo_url = ?, facebook = ?, instagram = ?, twitter = ?,
                amenities = ?, updated_at = GETDATE()
            WHERE info_id = ?
            """;
        return executeUpdate(sql,
            info.getName(), info.getSlogan(), info.getShortDescription(), info.getFullDescription(),
            info.getAddress(), info.getCity(), info.getPhone(), info.getEmail(), info.getWebsite(),
            info.getCheckInTime(), info.getCheckOutTime(),
            info.getCancellationPolicy(), info.getPolicies(),
            info.getLogoUrl(), info.getFacebook(), info.getInstagram(), info.getTwitter(),
            info.getAmenities(), info.getInfoId());
    }

    /** Insert default row if table is empty */
    public int insertDefault() {
        String sql = """
            INSERT INTO HotelInfo (hotel_name, check_in_time, check_out_time)
            VALUES (N'Luxury Hotel', '14:00', '12:00')
            """;
        return executeInsert(sql);
    }
}
