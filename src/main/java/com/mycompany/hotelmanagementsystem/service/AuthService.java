package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.ErrorMessage;
import com.mycompany.hotelmanagementsystem.constant.RoleConstant;
import com.mycompany.hotelmanagementsystem.util.AuthResult;
import com.mycompany.hotelmanagementsystem.util.PasswordHelper;
import com.mycompany.hotelmanagementsystem.util.ValidationHelper;
import com.mycompany.hotelmanagementsystem.util.OtpHelper;
import com.mycompany.hotelmanagementsystem.util.EmailHelper;
import com.mycompany.hotelmanagementsystem.util.GoogleOAuthHelper;
import com.mycompany.hotelmanagementsystem.entity.Account;
import com.mycompany.hotelmanagementsystem.entity.Customer;
import com.mycompany.hotelmanagementsystem.dal.AccountRepository;
import com.mycompany.hotelmanagementsystem.dal.CustomerRepository;

public class AuthService {
    private final AccountRepository accountRepository;
    private final CustomerRepository customerRepository;

    public AuthService() {
        this.accountRepository = new AccountRepository();
        this.customerRepository = new CustomerRepository();
    }

    // Dùng Account entity thay cho RegisterRequest
    public AuthResult register(Account account, String confirmPassword) {
        // Validate input
        if (!ValidationHelper.isValidEmail(account.getEmail())) {
            return AuthResult.failure(ErrorMessage.INVALID_EMAIL);
        }
        if (!ValidationHelper.isValidPassword(account.getPassword())) {
            return AuthResult.failure(ErrorMessage.INVALID_PASSWORD);
        }
        if (!ValidationHelper.isNotEmpty(account.getFullName())) {
            return AuthResult.failure("Họ tên không được để trống");
        }
        if (!ValidationHelper.isValidPhone(account.getPhone())) {
            return AuthResult.failure(ErrorMessage.INVALID_PHONE);
        }
        if (!account.getPassword().equals(confirmPassword)) {
            return AuthResult.failure(ErrorMessage.PASSWORDS_NOT_MATCH);
        }

        // Check duplicate email
        if (accountRepository.existsByEmail(account.getEmail().toLowerCase().trim())) {
            return AuthResult.failure(ErrorMessage.EMAIL_EXISTS);
        }

        // Normalize and hash
        account.setEmail(account.getEmail().toLowerCase().trim());
        account.setPassword(PasswordHelper.hash(account.getPassword()));
        account.setFullName(ValidationHelper.sanitize(account.getFullName()));
        account.setAddress(ValidationHelper.sanitize(account.getAddress()));
        account.setRoleId(RoleConstant.CUSTOMER);
        account.setActive(true);

        int accountId = accountRepository.insert(account);
        if (accountId <= 0) {
            return AuthResult.failure("Khong the tao tai khoan");
        }

        account.setAccountId(accountId);
        int customerInserted = customerRepository.insert(accountId);
        if (customerInserted <= 0) {
            // Rollback: delete the account that was just created
            accountRepository.delete(accountId);
            return AuthResult.failure("Khong the tao thong tin khach hang");
        }

        // Clear password before returning
        account.setPassword(null);
        return AuthResult.success("Dang ky thanh cong", account);
    }

    // Dùng inline params thay cho LoginRequest
    public AuthResult login(String email, String password) {
        if (!ValidationHelper.isValidEmail(email)) {
            return AuthResult.failure(ErrorMessage.INVALID_CREDENTIALS);
        }

        Account account = accountRepository.findByEmail(email.toLowerCase().trim());

        if (account == null) {
            return AuthResult.failure(ErrorMessage.INVALID_CREDENTIALS);
        }

        if (!account.isActive()) {
            return AuthResult.failure(ErrorMessage.ACCOUNT_INACTIVE);
        }

        if (!PasswordHelper.verify(password, account.getPassword())) {
            return AuthResult.failure(ErrorMessage.INVALID_CREDENTIALS);
        }

        // Clear password before returning
        account.setPassword(null);
        return AuthResult.success("Dang nhap thanh cong", account);
    }

    // Dùng inline params thay cho ChangePasswordRequest
    public AuthResult changePassword(int accountId, String currentPassword, String newPassword, String confirmPassword) {
        if (!ValidationHelper.isValidPassword(newPassword)) {
            return AuthResult.failure(ErrorMessage.INVALID_PASSWORD);
        }

        if (!newPassword.equals(confirmPassword)) {
            return AuthResult.failure(ErrorMessage.PASSWORDS_NOT_MATCH);
        }

        Account account = accountRepository.findById(accountId);
        if (account == null) {
            return AuthResult.failure("Khong tim thay tai khoan");
        }

        if (!PasswordHelper.verify(currentPassword, account.getPassword())) {
            return AuthResult.failure("Mat khau hien tai khong dung");
        }

        // Kiểm tra mật khẩu mới không được giống hoặc gần giống mật khẩu cũ
        if (PasswordHelper.isTooSimilar(currentPassword, newPassword)) {
            return AuthResult.failure("Mat khau moi phai khac biet dang ke so voi mat khau cu (khong duoc giong hoac gan giong)");
        }

        String newHash = PasswordHelper.hash(newPassword);
        int updated = accountRepository.updatePassword(accountId, newHash);

        if (updated <= 0) {
            return AuthResult.failure("Khong the doi mat khau");
        }

        return AuthResult.success("Doi mat khau thanh cong", null);
    }

    public Customer getCustomer(int accountId) {
        return customerRepository.findByIdWithAccount(accountId);
    }

    public Account getAccount(int accountId) {
        return accountRepository.findById(accountId);
    }

    public AuthResult sendOtp(String email) {
        if (!ValidationHelper.isValidEmail(email)) {
            return AuthResult.failure(ErrorMessage.INVALID_EMAIL);
        }

        String normalizedEmail = email.toLowerCase().trim();
        Account account = accountRepository.findByEmail(normalizedEmail);

        if (account == null) {
            return AuthResult.success("OTP da duoc gui neu email ton tai", null);
        }

        String otp = OtpHelper.generateOtp();
        boolean sent = EmailHelper.sendOtp(normalizedEmail, otp);
        if (!sent) {
            return AuthResult.failure("Khong the gui email. Vui long thu lai sau.");
        }

        Account tempAccount = new Account();
        tempAccount.setEmail(normalizedEmail);
        tempAccount.setPassword(otp);
        return AuthResult.success("OTP da duoc gui den email cua ban", tempAccount);
    }

    public boolean verifyOtp(String inputOtp, String sessionOtp, long expiryTime) {
        if (inputOtp == null || sessionOtp == null) {
            return false;
        }
        if (OtpHelper.isExpired(expiryTime)) {
            return false;
        }
        return inputOtp.equals(sessionOtp);
    }

    public AuthResult resetPassword(String email, String newPassword, String confirmPassword) {
        if (!ValidationHelper.isValidPassword(newPassword)) {
            return AuthResult.failure(ErrorMessage.INVALID_PASSWORD);
        }

        if (!newPassword.equals(confirmPassword)) {
            return AuthResult.failure(ErrorMessage.PASSWORDS_NOT_MATCH);
        }

        Account account = accountRepository.findByEmail(email.toLowerCase().trim());
        if (account == null) {
            return AuthResult.failure("Khong tim thay tai khoan");
        }

        String newHash = PasswordHelper.hash(newPassword);
        int updated = accountRepository.updatePassword(account.getAccountId(), newHash);

        if (updated <= 0) {
            return AuthResult.failure("Khong the dat lai mat khau");
        }

        return AuthResult.success("Dat lai mat khau thanh cong. Vui long dang nhap.", null);
    }

    public AuthResult loginWithGoogle(String code) {
        try {
            GoogleOAuthHelper.GoogleUserInfo userInfo = GoogleOAuthHelper.exchangeCodeAndGetUserInfo(code);
            Account account = accountRepository.findByEmail(userInfo.getEmail().toLowerCase());

            if (account != null) {
                if (!account.isActive()) {
                    return AuthResult.failure(ErrorMessage.ACCOUNT_INACTIVE);
                }
                account.setPassword(null);
                return AuthResult.success("Dang nhap thanh cong", account);
            }

            account = new Account();
            account.setEmail(userInfo.getEmail().toLowerCase());
            account.setPassword(null);
            account.setFullName(userInfo.getName());
            account.setRoleId(RoleConstant.CUSTOMER);
            account.setActive(true);

            int accountId = accountRepository.insert(account);
            if (accountId <= 0) {
                return AuthResult.failure("Khong the tao tai khoan");
            }
            account.setAccountId(accountId);
            customerRepository.insert(accountId);

            return AuthResult.success("NEW_USER", account);

        } catch (Exception e) {
            return AuthResult.failure("Loi xac thuc Google: " + e.getMessage());
        }
    }

    public AuthResult completeProfile(int accountId, String phone, String address) {
        Account account = accountRepository.findById(accountId);
        if (account == null) {
            return AuthResult.failure("Khong tim thay tai khoan");
        }

        account.setPhone(phone);
        account.setAddress(ValidationHelper.sanitize(address));
        int updated = accountRepository.update(account);

        if (updated <= 0) {
            return AuthResult.failure("Khong the cap nhat thong tin");
        }

        account.setPassword(null);
        return AuthResult.success("Cap nhat thong tin thanh cong", account);
    }
}
