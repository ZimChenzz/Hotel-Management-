package com.mycompany.hotelmanagementsystem.util;

/**
 * Represents a customer's room type selection with quantity.
 * Used in the multi-room booking flow.
 */
public class RoomSelectionItem {
    private int typeId;
    private int quantity;

    public RoomSelectionItem() {}

    public RoomSelectionItem(int typeId, int quantity) {
        this.typeId = typeId;
        this.quantity = quantity;
    }

    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}
