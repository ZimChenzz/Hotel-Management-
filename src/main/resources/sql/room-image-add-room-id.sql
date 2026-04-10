-- Add room_id column to RoomImage table for per-room images
-- Run this script on your SQL Server database before using the room image upload feature

ALTER TABLE RoomImage ADD room_id INT NULL;

ALTER TABLE RoomImage ADD CONSTRAINT FK_RoomImage_Room
    FOREIGN KEY (room_id) REFERENCES Room(room_id) ON DELETE SET NULL;

-- Create index for faster lookup by room_id
CREATE INDEX IX_RoomImage_RoomId ON RoomImage(room_id);
