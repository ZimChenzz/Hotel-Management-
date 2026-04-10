package com.mycompany.hotelmanagementsystem.constant;

public final class ServiceTypeConstant {
    public static final String CLEANING = "Cleaning";
    public static final String MAINTENANCE = "Maintenance";
    public static final String FOOD_BEVERAGE = "Food & Beverage";
    public static final String SUPPLIES = "Supplies";

    private ServiceTypeConstant() {}

    public static boolean isValid(String type) {
        return CLEANING.equals(type) || MAINTENANCE.equals(type)
                || FOOD_BEVERAGE.equals(type) || SUPPLIES.equals(type);
    }

    public static String getDisplayName(String type) {
        if (type == null) return "";
        return switch (type) {
            case CLEANING -> "Dọn phòng";
            case MAINTENANCE -> "Bảo trì";
            case FOOD_BEVERAGE -> "Đồ ăn & Nước uống";
            case SUPPLIES -> "Vật dụng";
            default -> type;
        };
    }
}
