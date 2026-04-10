package com.mycompany.hotelmanagementsystem.util;

/**
 * Result of walk-in customer lookup/creation.
 * Status: FOUND_BY_PHONE, FOUND_BY_EMAIL, CREATED
 */
public class WalkInCustomerResult {
    private int accountId;
    private String status;          // FOUND_BY_PHONE | FOUND_BY_EMAIL | CREATED
    private String existingName;    // name of existing account (for confirmation)
    private String existingPhone;   // phone of existing account (for confirmation)
    private String generatedPassword; // only set when CREATED
    private String email;

    public WalkInCustomerResult(int accountId, String status, String existingName, String existingPhone) {
        this.accountId = accountId;
        this.status = status;
        this.existingName = existingName;
        this.existingPhone = existingPhone;
    }

    public int getAccountId() { return accountId; }
    public String getStatus() { return status; }
    public String getExistingName() { return existingName; }
    public String getExistingPhone() { return existingPhone; }
    public String getGeneratedPassword() { return generatedPassword; }
    public void setGeneratedPassword(String generatedPassword) { this.generatedPassword = generatedPassword; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public boolean isFoundByEmail() { return "FOUND_BY_EMAIL".equals(status); }
    public boolean isCreated() { return "CREATED".equals(status); }
}
