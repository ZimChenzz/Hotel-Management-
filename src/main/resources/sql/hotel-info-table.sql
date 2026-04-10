-- Hotel Info table - stores hotel information as key-value pairs
-- Only one row needed (singleton config pattern)
CREATE TABLE HotelInfo (
    info_id         INT IDENTITY(1,1) PRIMARY KEY,
    hotel_name      NVARCHAR(200)   NOT NULL DEFAULT N'Luxury Hotel',
    slogan          NVARCHAR(500)   NULL,
    short_description NVARCHAR(1000) NULL,
    full_description NVARCHAR(MAX)  NULL,
    address         NVARCHAR(500)   NULL,
    city            NVARCHAR(100)   NULL,
    phone           VARCHAR(20)     NULL,
    email           VARCHAR(100)    NULL,
    website         VARCHAR(200)    NULL,
    check_in_time   VARCHAR(5)      NOT NULL DEFAULT '14:00',
    check_out_time  VARCHAR(5)      NOT NULL DEFAULT '12:00',
    cancellation_policy NVARCHAR(MAX) NULL,
    policies        NVARCHAR(MAX)   NULL,
    logo_url        VARCHAR(500)    NULL,
    facebook        VARCHAR(300)    NULL,
    instagram       VARCHAR(300)    NULL,
    twitter         VARCHAR(300)    NULL,
    amenities       VARCHAR(500)    NULL,  -- comma-separated: wifi,pool,spa,gym
    updated_at      DATETIME        NOT NULL DEFAULT GETDATE()
);

-- Insert default row
INSERT INTO HotelInfo (hotel_name, check_in_time, check_out_time)
VALUES (N'Luxury Hotel', '14:00', '12:00');
