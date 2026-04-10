-- Migration: Multi-Room Booking Support
-- Date: 2026-03-30
--
-- This migration introduces the BookingRoom table to support multiple rooms
-- per booking (multi-room booking feature). It also:
--   - Adds surcharge columns (early_surcharge, late_surcharge) to the Booking table
--   - Links BookingExtension and Occupant records to their respective BookingRoom
--   - Migrates all existing Booking records into the new BookingRoom table
--
-- Run this script once against SQL Server 2019 before deploying the updated application.
-- All existing data is preserved via the data migration steps at the bottom.

-- ============================================================
-- 1. Create BookingRoom table
-- ============================================================

CREATE TABLE BookingRoom (
    booking_room_id    INT IDENTITY(1,1) PRIMARY KEY,
    booking_id         INT NOT NULL,
    room_id            INT NULL,
    type_id            INT NOT NULL,
    unit_price         DECIMAL(18,2) NOT NULL,
    early_surcharge    DECIMAL(18,2) NOT NULL DEFAULT 0,
    late_surcharge     DECIMAL(18,2) NOT NULL DEFAULT 0,
    promotion_discount DECIMAL(18,2) NOT NULL DEFAULT 0,
    status             VARCHAR(20) NOT NULL DEFAULT 'Pending',
    check_in_actual    DATETIME NULL,
    check_out_actual   DATETIME NULL,
    created_at         DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_BookingRoom_Booking  FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    CONSTRAINT FK_BookingRoom_Room     FOREIGN KEY (room_id)    REFERENCES Room(room_id),
    CONSTRAINT FK_BookingRoom_RoomType FOREIGN KEY (type_id)    REFERENCES RoomType(type_id)
);

GO

-- ============================================================
-- 2. Create indexes on BookingRoom
-- ============================================================

CREATE INDEX IX_BookingRoom_BookingId ON BookingRoom(booking_id);
CREATE INDEX IX_BookingRoom_RoomId    ON BookingRoom(room_id);
CREATE INDEX IX_BookingRoom_TypeId    ON BookingRoom(type_id);
CREATE INDEX IX_BookingRoom_Status    ON BookingRoom(status);

GO

-- ============================================================
-- 3. Add surcharge columns to Booking table
-- ============================================================

ALTER TABLE Booking ADD early_surcharge DECIMAL(18,2) NOT NULL DEFAULT 0;
ALTER TABLE Booking ADD late_surcharge  DECIMAL(18,2) NOT NULL DEFAULT 0;

GO

-- ============================================================
-- 4. Add booking_room_id to BookingExtension
-- ============================================================

ALTER TABLE BookingExtension ADD booking_room_id INT NULL;
ALTER TABLE BookingExtension ADD CONSTRAINT FK_BookingExtension_BookingRoom
    FOREIGN KEY (booking_room_id) REFERENCES BookingRoom(booking_room_id);

GO

-- ============================================================
-- 5. Add booking_room_id to Occupant
-- ============================================================

ALTER TABLE Occupant ADD booking_room_id INT NULL;
ALTER TABLE Occupant ADD CONSTRAINT FK_Occupant_BookingRoom
    FOREIGN KEY (booking_room_id) REFERENCES BookingRoom(booking_room_id);

GO

-- ============================================================
-- 6. Data migration - backfill existing bookings into BookingRoom
-- ============================================================

-- Migrate bookings that already have a room assigned
INSERT INTO BookingRoom (booking_id, room_id, type_id, unit_price, early_surcharge, late_surcharge, promotion_discount, status, check_in_actual, check_out_actual)
SELECT b.booking_id, b.room_id, b.type_id, b.total_price, 0, 0, 0, b.status, b.check_in_actual, b.check_out_actual
FROM Booking b
WHERE b.room_id IS NOT NULL;

-- Migrate pending bookings that do not have a room assigned yet
INSERT INTO BookingRoom (booking_id, room_id, type_id, unit_price, early_surcharge, late_surcharge, promotion_discount, status)
SELECT b.booking_id, NULL, b.type_id, b.total_price, 0, 0, 0, b.status
FROM Booking b
WHERE b.room_id IS NULL;

-- Link existing extensions to their corresponding BookingRoom record
UPDATE be
SET be.booking_room_id = br.booking_room_id
FROM BookingExtension be
JOIN BookingRoom br ON br.booking_id = be.booking_id;

-- Link existing occupants to their corresponding BookingRoom record
UPDATE o
SET o.booking_room_id = br.booking_room_id
FROM Occupant o
JOIN BookingRoom br ON br.booking_id = o.booking_id;

GO
