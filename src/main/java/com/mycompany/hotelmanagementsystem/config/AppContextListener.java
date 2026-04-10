package com.mycompany.hotelmanagementsystem.config;

import com.mycompany.hotelmanagementsystem.service.BookingSchedulerService;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppContextListener implements ServletContextListener {
    private BookingSchedulerService schedulerService;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        schedulerService = new BookingSchedulerService();
        schedulerService.start();
        sce.getServletContext().log("BookingSchedulerService started - auto-cancel check every 5 minutes");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (schedulerService != null) {
            schedulerService.stop();
            sce.getServletContext().log("BookingSchedulerService stopped");
        }
    }
}
