package com.mycompany.hotelmanagementsystem.util;

public class ServiceResult {
    private boolean success;
    private String message;

    public ServiceResult(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public static ServiceResult success(String message) {
        return new ServiceResult(true, message);
    }

    public static ServiceResult failure(String message) {
        return new ServiceResult(false, message);
    }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
}
