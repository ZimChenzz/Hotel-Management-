package com.mycompany.hotelmanagementsystem.config;

import com.mycompany.hotelmanagementsystem.dal.BookingRepository;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Background scheduler that auto-cancels overdue bookings every minute.
 * Runs a single SQL UPDATE to cancel Pending/Confirmed bookings past check-in time.
 */
@WebListener
public class BookingScheduler implements ServletContextListener {
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        BookingRepository bookingRepository = new BookingRepository();
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "booking-auto-cancel");
            t.setDaemon(true);
            return t;
        });

        scheduler.scheduleAtFixedRate(() -> {
            try {
                int cancelled = bookingRepository.cancelOverdueBookings();
                if (cancelled > 0) {
                    System.out.println("[BookingScheduler] Auto-cancelled " + cancelled + " overdue booking(s)");
                }
            } catch (Exception e) {
                System.err.println("[BookingScheduler] Error: " + e.getMessage());
            }
        }, 1, 1, TimeUnit.MINUTES);

        System.out.println("[BookingScheduler] Started - checking overdue bookings every 1 minute");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
            System.out.println("[BookingScheduler] Stopped");
        }
    }
}
