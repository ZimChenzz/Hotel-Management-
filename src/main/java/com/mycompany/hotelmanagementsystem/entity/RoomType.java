package com.mycompany.hotelmanagementsystem.entity;

import java.math.BigDecimal;
import java.util.List;

public class RoomType {
    private int typeId;
    private String typeName;
    private BigDecimal basePrice;
    private int capacity;
    private BigDecimal pricePerHour;
    private BigDecimal depositPercent;
    private String description;
    private List<RoomImage> images;
    private List<Amenity> amenities;

    public RoomType() {}

    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }
    public BigDecimal getPricePerHour() { return pricePerHour; }
    public void setPricePerHour(BigDecimal pricePerHour) { this.pricePerHour = pricePerHour; }
    public BigDecimal getDepositPercent() { return depositPercent; }
    public void setDepositPercent(BigDecimal depositPercent) { this.depositPercent = depositPercent; }
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public List<RoomImage> getImages() { return images; }
    public void setImages(List<RoomImage> images) { this.images = images; }
    public List<Amenity> getAmenities() { return amenities; }
    public void setAmenities(List<Amenity> amenities) { this.amenities = amenities; }

    // Standard room = no deposit required (deposit_percent = 0)
    public boolean isStandardRoom() {
        return depositPercent == null || depositPercent.compareTo(BigDecimal.ZERO) == 0;
    }
}
