package com.mycompany.hotelmanagementsystem.entity;

import java.util.List;

public class Room {
    private int roomId;
    private String roomNumber;
    private int typeId;
    private String status;
    private RoomType roomType;
    private List<RoomImage> images;

    public Room() {}

    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public RoomType getRoomType() { return roomType; }
    public void setRoomType(RoomType roomType) { this.roomType = roomType; }
    public List<RoomImage> getImages() { return images; }
    public void setImages(List<RoomImage> images) { this.images = images; }
}
