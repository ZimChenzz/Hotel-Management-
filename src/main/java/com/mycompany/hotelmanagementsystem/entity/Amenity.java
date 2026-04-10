package com.mycompany.hotelmanagementsystem.entity;

public class Amenity {
    private int amenityId;
    private String name;
    private String iconUrl;

    public Amenity() {}

    public int getAmenityId() { return amenityId; }
    public void setAmenityId(int amenityId) { this.amenityId = amenityId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }
}
