package com.mycompany.hotelmanagementsystem.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Database connection manager using HikariCP connection pool.
 * Provides thread-safe access to SQL Server database connections.
 */
public class DbContext {

    private static final Logger logger = LoggerFactory.getLogger(DbContext.class);
    private static HikariDataSource dataSource;

    static {
        try {
            Properties props = new Properties();
            InputStream is = DbContext.class.getClassLoader()
                .getResourceAsStream("db.properties");

            if (is == null) {
                throw new RuntimeException("db.properties not found in classpath");
            }

            props.load(is);
            is.close();

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.username"));
            config.setPassword(props.getProperty("db.password"));
            config.setDriverClassName(props.getProperty("db.driver"));
            config.setMinimumIdle(Integer.parseInt(props.getProperty("db.pool.minIdle")));
            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("db.pool.maxSize")));
            config.setConnectionTimeout(Long.parseLong(props.getProperty("db.pool.timeout")));

            config.setPoolName("HotelDBPool");
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

            dataSource = new HikariDataSource(config);
            logger.info("Database connection pool initialized successfully");

        } catch (Exception e) {
            logger.error("Failed to initialize database connection pool", e);
            throw new RuntimeException("Failed to init database", e);
        }
    }

    /**
     * Get a connection from the pool.
     * Caller is responsible for closing the connection.
     */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    /**
     * Close the connection pool. Call on application shutdown.
     */
    public static void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            logger.info("Database connection pool closed");
        }
    }
}
