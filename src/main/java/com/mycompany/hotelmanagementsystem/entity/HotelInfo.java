package com.mycompany.hotelmanagementsystem.entity;

import java.time.LocalDateTime;

/**
 * Entity representing hotel information displayed on the website.
 * Singleton pattern - only one row in the database.
 */
public class HotelInfo {
    private int infoId;
    private String name;
    private String slogan;
    private String shortDescription;
    private String fullDescription;
    private String address;
    private String city;
    private String phone;
    private String email;
    private String website;
    private String checkInTime;
    private String checkOutTime;
    private String cancellationPolicy;
    private String policies;
    private String logoUrl;
    private String facebook;
    private String instagram;
    private String twitter;
    private String amenities;
    private LocalDateTime updatedAt;

    public HotelInfo() {}

    public int getInfoId() { return infoId; }
    public void setInfoId(int infoId) { this.infoId = infoId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSlogan() { return slogan; }
    public void setSlogan(String slogan) { this.slogan = slogan; }

    public String getShortDescription() { return shortDescription; }
    public void setShortDescription(String shortDescription) { this.shortDescription = shortDescription; }

    public String getFullDescription() { return fullDescription; }
    public void setFullDescription(String fullDescription) { this.fullDescription = fullDescription; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getWebsite() { return website; }
    public void setWebsite(String website) { this.website = website; }

    public String getCheckInTime() { return checkInTime; }
    public void setCheckInTime(String checkInTime) { this.checkInTime = checkInTime; }

    public String getCheckOutTime() { return checkOutTime; }
    public void setCheckOutTime(String checkOutTime) { this.checkOutTime = checkOutTime; }

    public String getCancellationPolicy() { return cancellationPolicy; }
    public void setCancellationPolicy(String cancellationPolicy) { this.cancellationPolicy = cancellationPolicy; }

    public String getPolicies() { return policies; }
    public void setPolicies(String policies) { this.policies = policies; }

    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }

    public String getFacebook() { return facebook; }
    public void setFacebook(String facebook) { this.facebook = facebook; }

    public String getInstagram() { return instagram; }
    public void setInstagram(String instagram) { this.instagram = instagram; }

    public String getTwitter() { return twitter; }
    public void setTwitter(String twitter) { this.twitter = twitter; }

    public String getAmenities() { return amenities; }
    public void setAmenities(String amenities) { this.amenities = amenities; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
