package com.mycompany.hotelmanagementsystem.dal;

import com.mycompany.hotelmanagementsystem.entity.Account;
import com.mycompany.hotelmanagementsystem.entity.Customer;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CustomerRepository extends BaseRepository<Customer> {

    @Override
    protected Customer mapRow(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setAccountId(rs.getInt("account_id"));
        customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
        customer.setMembershipLevel(rs.getString("membership_level"));
        return customer;
    }

    public Customer findById(int accountId) {
        String sql = "SELECT * FROM Customer WHERE account_id = ?";
        return queryOne(sql, accountId);
    }

    public Customer findByIdWithAccount(int accountId) {
        String sql = """
            SELECT c.*, a.email, a.password, a.full_name, a.phone, a.address,
                   a.role_id, a.is_active, a.created_at
            FROM Customer c
            JOIN Account a ON c.account_id = a.account_id
            WHERE c.account_id = ?
            """;
        try (var conn = getConnection();
             var ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer customer = mapRow(rs);
                    Account account = new Account();
                    account.setAccountId(rs.getInt("account_id"));
                    account.setEmail(rs.getString("email"));
                    account.setFullName(rs.getString("full_name"));
                    account.setPhone(rs.getString("phone"));
                    account.setAddress(rs.getString("address"));
                    account.setRoleId(rs.getInt("role_id"));
                    account.setActive(rs.getBoolean("is_active"));
                    customer.setAccount(account);
                    return customer;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Find customer failed", e);
        }
        return null;
    }

    public int insert(int accountId) {
        String sql = """
            INSERT INTO Customer (account_id, loyalty_points, membership_level)
            VALUES (?, 0, 'Standard')
            """;
        return executeUpdate(sql, accountId);
    }

    public int updatePoints(int accountId, int points) {
        String sql = "UPDATE Customer SET loyalty_points = ? WHERE account_id = ?";
        return executeUpdate(sql, points, accountId);
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM Customer";
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            try (var rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (java.sql.SQLException e) {
            throw new RuntimeException("Count customers failed", e);
        }
        return 0;
    }

    public java.util.List<Customer> findAllWithAccount() {
        String sql = """
            SELECT c.*, a.email, a.full_name, a.phone, a.address, a.is_active, a.created_at
            FROM Customer c
            JOIN Account a ON c.account_id = a.account_id
            ORDER BY a.created_at DESC
            """;
        try (var conn = getConnection(); var ps = conn.prepareStatement(sql)) {
            try (var rs = ps.executeQuery()) {
                java.util.List<Customer> list = new java.util.ArrayList<>();
                while (rs.next()) {
                    Customer customer = mapRow(rs);
                    Account account = new Account();
                    account.setAccountId(rs.getInt("account_id"));
                    account.setEmail(rs.getString("email"));
                    account.setFullName(rs.getString("full_name"));
                    account.setPhone(rs.getString("phone"));
                    account.setAddress(rs.getString("address"));
                    account.setActive(rs.getBoolean("is_active"));
                    customer.setAccount(account);
                    list.add(customer);
                }
                return list;
            }
        } catch (java.sql.SQLException e) {
            throw new RuntimeException("Find all customers failed", e);
        }
    }
}
