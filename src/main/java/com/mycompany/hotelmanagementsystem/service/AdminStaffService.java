package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.RoleConstant;
import com.mycompany.hotelmanagementsystem.entity.Account;
import com.mycompany.hotelmanagementsystem.dal.AccountRepository;
import org.mindrot.jbcrypt.BCrypt;
import java.util.List;

public class AdminStaffService {
    private final AccountRepository accountRepository;

    public AdminStaffService() {
        this.accountRepository = new AccountRepository();
    }

    public List<Account> getAllStaff() {
        return accountRepository.findAllByRoleId(RoleConstant.STAFF);
    }

    public Account getStaffById(int accountId) {
        Account account = accountRepository.findById(accountId);
        if (account != null && (account.getRoleId() == RoleConstant.STAFF || account.getRoleId() == RoleConstant.ADMIN)) {
            return account;
        }
        return null;
    }

    public int createStaff(String email, String password, String fullName, String phone, String address) {
        if (accountRepository.existsByEmail(email)) {
            return -1;
        }

        Account account = new Account();
        account.setEmail(email);
        account.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
        account.setFullName(fullName);
        account.setPhone(phone);
        account.setAddress(address);
        account.setRoleId(RoleConstant.STAFF);
        account.setActive(true);

        return accountRepository.insert(account);
    }

    public boolean updateStaff(int accountId, String fullName, String phone, String address, int roleId) {
        Account account = accountRepository.findById(accountId);
        if (account == null || (account.getRoleId() != RoleConstant.STAFF && account.getRoleId() != RoleConstant.ADMIN)) {
            return false;
        }
        if (roleId != RoleConstant.STAFF && roleId != RoleConstant.ADMIN) {
            roleId = RoleConstant.STAFF;
        }
        account.setFullName(fullName);
        account.setPhone(phone);
        account.setAddress(address);
        accountRepository.update(account);
        if (account.getRoleId() != roleId) {
            accountRepository.updateRoleId(accountId, roleId);
        }
        return true;
    }

    public boolean toggleStaffStatus(int accountId) {
        Account account = accountRepository.findById(accountId);
        if (account == null || account.getRoleId() != RoleConstant.STAFF) {
            return false;
        }
        return accountRepository.updateIsActive(accountId, !account.isActive()) > 0;
    }
}
