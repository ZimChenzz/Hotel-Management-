package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.RoomStatus;
import com.mycompany.hotelmanagementsystem.dal.BookingRepository;
import com.mycompany.hotelmanagementsystem.dal.CustomerRepository;
import com.mycompany.hotelmanagementsystem.dal.PaymentRepository;
import com.mycompany.hotelmanagementsystem.dal.RoomRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

public class AdminReportService {
    private final RoomRepository roomRepository;
    private final BookingRepository bookingRepository;
    private final CustomerRepository customerRepository;
    private final PaymentRepository paymentRepository;

    public AdminReportService() {
        this.roomRepository = new RoomRepository();
        this.bookingRepository = new BookingRepository();
        this.customerRepository = new CustomerRepository();
        this.paymentRepository = new PaymentRepository();
    }

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRooms", roomRepository.countAll());
        stats.put("totalBookings", bookingRepository.countAll());
        stats.put("totalRevenue", bookingRepository.sumTotalPrice());
        stats.put("totalCustomers", customerRepository.countAll());
        stats.put("occupiedRooms", roomRepository.countByStatus(RoomStatus.OCCUPIED));
        stats.put("availableRooms", roomRepository.countByStatus(RoomStatus.AVAILABLE));
        stats.put("cleaningRooms", roomRepository.countByStatus(RoomStatus.CLEANING));
        stats.put("maintenanceRooms", roomRepository.countByStatus(RoomStatus.MAINTENANCE));
        return stats;
    }

    public Map<String, Object> getStatsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        Map<String, Object> stats = new HashMap<>();
        int bookings = bookingRepository.countByDateRange(startDate, endDate);
        BigDecimal revenue = bookingRepository.sumTotalPriceByDateRange(startDate, endDate);
        stats.put("totalBookings", bookings);
        stats.put("totalRevenue", revenue != null ? revenue : BigDecimal.ZERO);
        stats.put("totalCustomers", customerRepository.countAll()); // customers are overall
        stats.put("totalRooms", roomRepository.countAll());
        stats.put("occupiedRooms", roomRepository.countByStatus(RoomStatus.OCCUPIED));
        stats.put("availableRooms", roomRepository.countByStatus(RoomStatus.AVAILABLE));
        stats.put("cleaningRooms", roomRepository.countByStatus(RoomStatus.CLEANING));
        stats.put("maintenanceRooms", roomRepository.countByStatus(RoomStatus.MAINTENANCE));
        return stats;
    }

    /**
     * Returns monthly booking counts for the last 6 months.
     * Result: int[] of size 6, index 0 = oldest month, index 5 = current month.
     */
    public int[] getMonthlyBookingCounts() {
        int[] counts = new int[6];
        LocalDate now = LocalDate.now();
        for (int i = 5; i >= 0; i--) {
            LocalDate monthDate = now.minusMonths(i);
            LocalDateTime start = monthDate.withDayOfMonth(1).atStartOfDay();
            LocalDateTime end = monthDate.withDayOfMonth(monthDate.lengthOfMonth()).atTime(23, 59, 59);
            counts[5 - i] = bookingRepository.countByDateRange(start, end);
        }
        return counts;
    }

    /**
     * Returns month labels for the last 6 months (e.g. "T10", "T11", ...).
     */
    public String[] getMonthlyLabels() {
        String[] labels = new String[6];
        LocalDate now = LocalDate.now();
        for (int i = 5; i >= 0; i--) {
            LocalDate monthDate = now.minusMonths(i);
            labels[5 - i] = "T" + monthDate.getMonthValue();
        }
        return labels;
    }

    // Hourly labels for today
    public String[] getHourlyLabels() {
        String[] labels = new String[24];
        for (int i = 0; i < 24; i++) {
            labels[i] = String.format("%02d:00", i);
        }
        return labels;
    }

    public int[] getHourlyBookingCounts() {
        int[] counts = new int[24];
        LocalDate today = LocalDate.now();
        for (int hour = 0; hour < 24; hour++) {
            LocalDateTime start = today.atTime(hour, 0);
            LocalDateTime end = today.atTime(hour, 59, 59);
            counts[hour] = bookingRepository.countByDateRange(start, end);
        }
        return counts;
    }

    // Week daily labels (Mon-Sun)
    public String[] getDailyLabelsWeek() {
        String[] labels = new String[7];
        LocalDate monday = LocalDate.now().with(java.time.DayOfWeek.MONDAY);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEE");
        for (int i = 0; i < 7; i++) {
            labels[i] = monday.plusDays(i).format(formatter);
        }
        return labels;
    }

    public int[] getDailyBookingCountsWeek() {
        int[] counts = new int[7];
        LocalDate monday = LocalDate.now().with(java.time.DayOfWeek.MONDAY);
        for (int i = 0; i < 7; i++) {
            LocalDate day = monday.plusDays(i);
            LocalDateTime start = day.atStartOfDay();
            LocalDateTime end = day.atTime(23, 59, 59);
            counts[i] = bookingRepository.countByDateRange(start, end);
        }
        return counts;
    }

    // Month daily labels
    public String[] getDailyLabelsMonth() {
        int daysInMonth = LocalDate.now().lengthOfMonth();
        String[] labels = new String[daysInMonth];
        for (int i = 0; i < daysInMonth; i++) {
            labels[i] = String.valueOf(i + 1);
        }
        return labels;
    }

    public int[] getDailyBookingCountsMonth() {
        int daysInMonth = LocalDate.now().lengthOfMonth();
        int[] counts = new int[daysInMonth];
        LocalDate now = LocalDate.now();
        for (int day = 1; day <= daysInMonth; day++) {
            LocalDate date = now.withDayOfMonth(day);
            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.atTime(23, 59, 59);
            counts[day - 1] = bookingRepository.countByDateRange(start, end);
        }
        return counts;
    }

    // Quarter monthly labels
    public String[] getMonthlyLabelsQuarter() {
        LocalDate now = LocalDate.now();
        int currentQuarter = (now.getMonthValue() - 1) / 3;
        String[] labels = new String[3];
        for (int i = 0; i < 3; i++) {
            int month = currentQuarter * 3 + i + 1;
            labels[i] = "T" + month;
        }
        return labels;
    }

    public int[] getMonthlyBookingCountsQuarter() {
        LocalDate now = LocalDate.now();
        int currentQuarter = (now.getMonthValue() - 1) / 3;
        int[] counts = new int[3];
        for (int i = 0; i < 3; i++) {
            int month = currentQuarter * 3 + i + 1;
            LocalDate date = LocalDate.of(now.getYear(), month, 1);
            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.withDayOfMonth(date.lengthOfMonth()).atTime(23, 59, 59);
            counts[i] = bookingRepository.countByDateRange(start, end);
        }
        return counts;
    }

    // Custom range labels (auto-determine day/week/month based on range)
    public String[] getDailyLabelsForRange(LocalDateTime start, LocalDateTime end) {
        long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(start.toLocalDate(), end.toLocalDate());
        if (daysBetween <= 14) {
            // Daily labels for 2 weeks or less
            String[] labels = new String[(int) daysBetween + 1];
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");
            for (int i = 0; i <= daysBetween; i++) {
                labels[i] = start.toLocalDate().plusDays(i).format(formatter);
            }
            return labels;
        } else if (daysBetween <= 90) {
            // Weekly labels
            long weeks = daysBetween / 7 + 1;
            String[] labels = new String[(int) weeks];
            for (int i = 0; i < weeks; i++) {
                labels[i] = "T" + (i + 1);
            }
            return labels;
        } else {
            // Monthly labels
            long months = java.time.temporal.ChronoUnit.MONTHS.between(start.toLocalDate(), end.toLocalDate()) + 1;
            String[] labels = new String[(int) months];
            for (int i = 0; i < months; i++) {
                LocalDate month = start.toLocalDate().plusMonths(i);
                labels[i] = "T" + month.getMonthValue();
            }
            return labels;
        }
    }

    public int[] getDailyBookingCountsForRange(LocalDateTime start, LocalDateTime end) {
        long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(start.toLocalDate(), end.toLocalDate());
        if (daysBetween <= 14) {
            int[] counts = new int[(int) daysBetween + 1];
            for (int i = 0; i <= daysBetween; i++) {
                LocalDate day = start.toLocalDate().plusDays(i);
                LocalDateTime s = day.atStartOfDay();
                LocalDateTime e = day.atTime(23, 59, 59);
                counts[i] = bookingRepository.countByDateRange(s, e);
            }
            return counts;
        } else if (daysBetween <= 90) {
            long weeks = daysBetween / 7 + 1;
            int[] counts = new int[(int) weeks];
            for (int i = 0; i < weeks; i++) {
                LocalDate weekStart = start.toLocalDate().plusWeeks(i);
                LocalDate weekEnd = weekStart.plusDays(6);
                if (weekEnd.isAfter(end.toLocalDate())) weekEnd = end.toLocalDate();
                counts[i] = bookingRepository.countByDateRange(
                    weekStart.atStartOfDay(),
                    weekEnd.atTime(23, 59, 59)
                );
            }
            return counts;
        } else {
            long months = java.time.temporal.ChronoUnit.MONTHS.between(start.toLocalDate(), end.toLocalDate()) + 1;
            int[] counts = new int[(int) months];
            for (int i = 0; i < months; i++) {
                LocalDate month = start.toLocalDate().plusMonths(i);
                LocalDate firstDay = month.withDayOfMonth(1);
                LocalDate lastDay = month.withDayOfMonth(month.lengthOfMonth());
                if (firstDay.isBefore(start.toLocalDate())) firstDay = start.toLocalDate();
                if (lastDay.isAfter(end.toLocalDate())) lastDay = end.toLocalDate();
                counts[i] = bookingRepository.countByDateRange(
                    firstDay.atStartOfDay(),
                    lastDay.atTime(23, 59, 59)
                );
            }
            return counts;
        }
    }

    // Revenue data methods
    public double[] getRevenueData(LocalDateTime start, LocalDateTime end, String period) {
        switch (period) {
            case "today":
                return getHourlyRevenue();
            case "week":
                return getDailyRevenueWeek();
            case "month":
                return getDailyRevenueMonth();
            case "quarter":
                return getMonthlyRevenueQuarter();
            case "year":
                return getMonthlyRevenueYear();
            case "custom":
                return getRevenueForRange(start, end);
            default:
                return getMonthlyRevenueYear();
        }
    }

    public String[] getRevenueLabels(LocalDateTime start, LocalDateTime end, String period) {
        switch (period) {
            case "today":
                return getHourlyLabels();
            case "week":
                return getDailyLabelsWeek();
            case "month":
                return getDailyLabelsMonth();
            case "quarter":
                return getMonthlyLabelsQuarter();
            case "year":
                return getMonthlyLabels();
            case "custom":
                return getDailyLabelsForRange(start, end);
            default:
                return getMonthlyLabels();
        }
    }

    private double[] getHourlyRevenue() {
        double[] revenue = new double[24];
        LocalDate today = LocalDate.now();
        for (int hour = 0; hour < 24; hour++) {
            LocalDateTime start = today.atTime(hour, 0);
            LocalDateTime end = today.atTime(hour, 59, 59);
            BigDecimal r = paymentRepository.sumByDateRange(start, end);
            revenue[hour] = r != null ? r.doubleValue() : 0;
        }
        return revenue;
    }

    private double[] getDailyRevenueWeek() {
        double[] revenue = new double[7];
        LocalDate monday = LocalDate.now().with(java.time.DayOfWeek.MONDAY);
        for (int i = 0; i < 7; i++) {
            LocalDate day = monday.plusDays(i);
            LocalDateTime start = day.atStartOfDay();
            LocalDateTime end = day.atTime(23, 59, 59);
            BigDecimal r = paymentRepository.sumByDateRange(start, end);
            revenue[i] = r != null ? r.doubleValue() : 0;
        }
        return revenue;
    }

    private double[] getDailyRevenueMonth() {
        int daysInMonth = LocalDate.now().lengthOfMonth();
        double[] revenue = new double[daysInMonth];
        LocalDate now = LocalDate.now();
        for (int day = 1; day <= daysInMonth; day++) {
            LocalDate date = now.withDayOfMonth(day);
            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.atTime(23, 59, 59);
            BigDecimal r = paymentRepository.sumByDateRange(start, end);
            revenue[day - 1] = r != null ? r.doubleValue() : 0;
        }
        return revenue;
    }

    private double[] getMonthlyRevenueQuarter() {
        double[] revenue = new double[3];
        LocalDate now = LocalDate.now();
        int currentQuarter = (now.getMonthValue() - 1) / 3;
        for (int i = 0; i < 3; i++) {
            int month = currentQuarter * 3 + i + 1;
            LocalDate firstDay = LocalDate.of(now.getYear(), month, 1);
            LocalDate lastDay = firstDay.withDayOfMonth(firstDay.lengthOfMonth());
            BigDecimal r = paymentRepository.sumByDateRange(firstDay.atStartOfDay(), lastDay.atTime(23, 59, 59));
            revenue[i] = r != null ? r.doubleValue() : 0;
        }
        return revenue;
    }

    private double[] getMonthlyRevenueYear() {
        double[] revenue = new double[12];
        LocalDate now = LocalDate.now();
        for (int month = 1; month <= 12; month++) {
            LocalDate firstDay = LocalDate.of(now.getYear(), month, 1);
            LocalDate lastDay = firstDay.withDayOfMonth(firstDay.lengthOfMonth());
            BigDecimal r = paymentRepository.sumByDateRange(firstDay.atStartOfDay(), lastDay.atTime(23, 59, 59));
            revenue[month - 1] = r != null ? r.doubleValue() : 0;
        }
        return revenue;
    }

    private double[] getRevenueForRange(LocalDateTime start, LocalDateTime end) {
        long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(start.toLocalDate(), end.toLocalDate());
        if (daysBetween <= 14) {
            double[] revenue = new double[(int) daysBetween + 1];
            for (int i = 0; i <= daysBetween; i++) {
                LocalDate day = start.toLocalDate().plusDays(i);
                BigDecimal r = paymentRepository.sumByDateRange(day.atStartOfDay(), day.atTime(23, 59, 59));
                revenue[i] = r != null ? r.doubleValue() : 0;
            }
            return revenue;
        } else if (daysBetween <= 90) {
            long weeks = daysBetween / 7 + 1;
            double[] revenue = new double[(int) weeks];
            for (int i = 0; i < weeks; i++) {
                LocalDate weekStart = start.toLocalDate().plusWeeks(i);
                LocalDate weekEnd = weekStart.plusDays(6);
                if (weekEnd.isAfter(end.toLocalDate())) weekEnd = end.toLocalDate();
                BigDecimal r = paymentRepository.sumByDateRange(weekStart.atStartOfDay(), weekEnd.atTime(23, 59, 59));
                revenue[i] = r != null ? r.doubleValue() : 0;
            }
            return revenue;
        } else {
            long months = java.time.temporal.ChronoUnit.MONTHS.between(start.toLocalDate(), end.toLocalDate()) + 1;
            double[] revenue = new double[(int) months];
            for (int i = 0; i < months; i++) {
                LocalDate month = start.toLocalDate().plusMonths(i);
                LocalDate firstDay = month.withDayOfMonth(1);
                LocalDate lastDay = month.withDayOfMonth(month.lengthOfMonth());
                if (firstDay.isBefore(start.toLocalDate())) firstDay = start.toLocalDate();
                if (lastDay.isAfter(end.toLocalDate())) lastDay = end.toLocalDate();
                BigDecimal r = paymentRepository.sumByDateRange(firstDay.atStartOfDay(), lastDay.atTime(23, 59, 59));
                revenue[i] = r != null ? r.doubleValue() : 0;
            }
            return revenue;
        }
    }

    public Map<String, Object> getRoomUtilizationStats() {
        Map<String, Object> stats = new HashMap<>();
        int totalRooms = roomRepository.countAll();
        int occupied = roomRepository.countByStatus(RoomStatus.OCCUPIED);
        int available = roomRepository.countByStatus(RoomStatus.AVAILABLE);
        int cleaning = roomRepository.countByStatus(RoomStatus.CLEANING);
        int maintenance = roomRepository.countByStatus(RoomStatus.MAINTENANCE);

        stats.put("totalRooms", totalRooms);
        stats.put("occupied", occupied);
        stats.put("available", available);
        stats.put("cleaning", cleaning);
        stats.put("maintenance", maintenance);

        double utilizationRate = totalRooms > 0 ? (double) occupied / totalRooms * 100 : 0;
        stats.put("utilizationRate", String.format("%.1f", utilizationRate));

        return stats;
    }

    public Map<String, Object> getRevenueReport(LocalDateTime startDate, LocalDateTime endDate) {
        Map<String, Object> report = new HashMap<>();

        BigDecimal totalRevenue = bookingRepository.sumTotalPriceByDateRange(startDate, endDate);
        int bookingCount = bookingRepository.countByDateRange(startDate, endDate);

        report.put("totalRevenue", totalRevenue);
        report.put("bookingCount", bookingCount);
        report.put("averageBookingValue", bookingCount > 0
            ? totalRevenue.divide(BigDecimal.valueOf(bookingCount), 0, java.math.RoundingMode.HALF_UP)
            : BigDecimal.ZERO);

        return report;
    }
}
