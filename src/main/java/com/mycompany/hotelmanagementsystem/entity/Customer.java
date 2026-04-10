package com.mycompany.hotelmanagementsystem.entity;

public class Customer {
    private int accountId;
    private int loyaltyPoints;
    private String membershipLevel;
    private Account account;

    public Customer() {}

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
    public int getLoyaltyPoints() { return loyaltyPoints; }
    public void setLoyaltyPoints(int loyaltyPoints) { this.loyaltyPoints = loyaltyPoints; }
    public String getMembershipLevel() { return membershipLevel; }
    public void setMembershipLevel(String level) { this.membershipLevel = level; }
    public Account getAccount() { return account; }
    public void setAccount(Account account) { this.account = account; }
}
