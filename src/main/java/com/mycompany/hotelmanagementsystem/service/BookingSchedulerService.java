package com.mycompany.hotelmanagementsystem.service;

import com.mycompany.hotelmanagementsystem.constant.BookingStatus;
import com.mycompany.hotelmanagementsystem.dal.BookingRepository;
import com.mycompany.hotelmanagementsystem.entity.Booking;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Scheduled service to auto-cancel overdue Standard room bookings.
 * Standard rooms (deposit_percent = 0) that are still PENDING
 * and 6 hours past check_in_expected without staff verification
 * will be automatically cancelled.
 */
public class BookingSchedulerService {
    private static final Logger LOGGER = Logger.getLogger(BookingSchedulerService.class.getName());
    private static final int CHECK_INTERVAL_MINUTES = 5;
    private final BookingRepository bookingRepository;
    private ScheduledExecutorService scheduler;

    public BookingSchedulerService() {
        this.bookingRepository = new BookingRepository();
    }

    /** Start the periodic auto-cancel check. */
    public void start() {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "BookingAutoCancel");
            t.setDaemon(true);
            return t;
        });
        scheduler.scheduleAtFixedRate(
            this::cancelOverdueStandardBookings,
            1, CHECK_INTERVAL_MINUTES, TimeUnit.MINUTES);
        LOGGER.info("BookingSchedulerService started");
    }

    /** Stop the scheduler gracefully. */
    public void stop() {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException e) {
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
            }
            LOGGER.info("BookingSchedulerService stopped");
        }
    }

    /**
     * Find and cancel all overdue Standard room bookings.
     * Called periodically by the scheduler.
     */
    public void cancelOverdueStandardBookings() {
        try {
            List<Booking> overdueBookings = bookingRepository.findPendingStandardBookingsToCancel();
            for (Booking booking : overdueBookings) {
                bookingRepository.updateStatus(booking.getBookingId(), BookingStatus.CANCELLED);
                LOGGER.log(Level.INFO, "Auto-cancelled overdue Standard booking #{0}", booking.getBookingId());
            }
            if (!overdueBookings.isEmpty()) {
                LOGGER.log(Level.INFO, "Auto-cancelled {0} overdue Standard booking(s)", overdueBookings.size());
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in auto-cancel scheduler", e);
        }
    }

    /**
     * Lazy check: verify a single booking for auto-cancel eligibility.
     * Call this when fetching booking details as a safety net.
     * Returns true if booking was auto-cancelled.
     */
    public boolean checkAndCancelIfOverdue(Booking booking) {
        if (booking == null) return false;
        try {
            if (BookingStatus.PENDING.equals(booking.getStatus())
                    && booking.getCheckInActual() == null
                    && bookingRepository.isOverdueStandardBooking(booking.getBookingId())) {
                bookingRepository.updateStatus(booking.getBookingId(), BookingStatus.CANCELLED);
                booking.setStatus(BookingStatus.CANCELLED);
                LOGGER.log(Level.INFO, "Lazy auto-cancelled overdue Standard booking #{0}", booking.getBookingId());
                return true;
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error in lazy auto-cancel check", e);
        }
        return false;
    }
}
