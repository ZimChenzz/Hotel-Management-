package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Account;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class AccountRepository extends BaseRepository<Account> {

    @Override
    protected Account mapRow(ResultSet rs) throws SQLException {
        Account account = new Account();
        account.setAccountId(rs.getInt("account_id"));
        account.setEmail(rs.getString("email"));
        account.setPassword(rs.getString("password"));
        account.setFullName(rs.getString("full_name"));
        account.setPhone(rs.getString("phone"));
        account.setAddress(rs.getString("address"));
        account.setRoleId(rs.getInt("role_id"));
        account.setActive(rs.getBoolean("is_active"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            account.setCreatedAt(ts.toLocalDateTime());
        }
        return account;
    }

    public Account findByEmail(String email) {
        String sql = "SELECT * FROM Account WHERE email = ?";
        return queryOne(sql, email);
    }

    public Account findByPhone(String phone) {
        String sql = "SELECT * FROM Account WHERE phone = ?";
        return queryOne(sql, phone);
    }

    public Account findById(int accountId) {
        String sql = "SELECT * FROM Account WHERE account_id = ?";
        return queryOne(sql, accountId);
    }

    public boolean existsByEmail(String email) {
        String sql = "SELECT COUNT(*) FROM Account WHERE email = ?";
        try (var conn = getConnection();
             var ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Check email failed", e);
        }
        return false;
    }

    public int insert(Account account) {
        String sql = """
            INSERT INTO Account (email, password, full_name, phone, address, role_id, is_active)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;
        return executeInsert(sql,
            account.getEmail(),
            account.getPassword(),
            account.getFullName(),
            account.getPhone(),
            account.getAddress(),
            account.getRoleId(),
            account.isActive() ? 1 : 0);
    }

    public int updatePassword(int accountId, String newPasswordHash) {
        String sql = "UPDATE Account SET password = ? WHERE account_id = ?";
        return executeUpdate(sql, newPasswordHash, accountId);
    }

    public int update(Account account) {
        String sql = """
            UPDATE Account SET full_name = ?, phone = ?, address = ?
            WHERE account_id = ?
            """;
        return executeUpdate(sql,
            account.getFullName(),
            account.getPhone(),
            account.getAddress(),
            account.getAccountId());
    }

    public java.util.List<Account> findAll() {
        String sql = "SELECT * FROM Account ORDER BY created_at DESC";
        return queryList(sql);
    }

    public java.util.List<Account> findAllByRoleId(int roleId) {
        String sql = "SELECT * FROM Account WHERE role_id = ? ORDER BY created_at DESC";
        return queryList(sql, roleId);
    }

    public int updateIsActive(int accountId, boolean isActive) {
        String sql = "UPDATE Account SET is_active = ? WHERE account_id = ?";
        return executeUpdate(sql, isActive ? 1 : 0, accountId);
    }

    public int updateRoleId(int accountId, int roleId) {
        String sql = "UPDATE Account SET role_id = ? WHERE account_id = ?";
        return executeUpdate(sql, roleId, accountId);
    }

    public int delete(int accountId) {
        String sql = "DELETE FROM Account WHERE account_id = ?";
        return executeUpdate(sql, accountId);
    }
}
