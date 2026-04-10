package com.mycompany.hotelmanagementsystem.util;

import com.mycompany.hotelmanagementsystem.entity.Account;

public class AuthResult {
    private boolean success;
    private String message;
    private Account account;

    public AuthResult(boolean success, String message, Account account) {
        this.success = success;
        this.message = message;
        this.account = account;
    }

    public static AuthResult success(String message, Account account) {
        return new AuthResult(true, message, account);
    }

    public static AuthResult failure(String message) {
        return new AuthResult(false, message, null);
    }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public Account getAccount() { return account; }
}
