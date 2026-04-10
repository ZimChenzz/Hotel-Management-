-- Seed default room images using Unsplash URLs
-- Run this script if RoomImage table is empty or rooms have no images
-- Adjust type_id values to match your RoomType table

-- Check existing images first
-- SELECT rt.type_id, rt.type_name, COUNT(ri.image_id) AS img_count
-- FROM RoomType rt LEFT JOIN RoomImage ri ON rt.type_id = ri.type_id
-- GROUP BY rt.type_id, rt.type_name;

-- Insert images only for room types that have NO images yet
-- Standard / Phong Thuong
INSERT INTO RoomImage (type_id, image_url)
SELECT type_id, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80'
FROM RoomType WHERE type_id NOT IN (SELECT DISTINCT type_id FROM RoomImage)
AND type_id = (SELECT MIN(type_id) FROM RoomType);

-- Deluxe / Phong Cao Cap
INSERT INTO RoomImage (type_id, image_url)
SELECT type_id, 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80'
FROM RoomType WHERE type_id NOT IN (SELECT DISTINCT type_id FROM RoomImage)
AND type_id = (SELECT MIN(type_id) FROM RoomType WHERE type_id > (SELECT MIN(type_id) FROM RoomType));

-- Suite / Phong Hang Sang
INSERT INTO RoomImage (type_id, image_url)
SELECT type_id, 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80'
FROM RoomType WHERE type_id NOT IN (SELECT DISTINCT type_id FROM RoomImage)
AND type_id = (SELECT MIN(type_id) FROM RoomType WHERE type_id > (
    SELECT MIN(type_id) FROM RoomType WHERE type_id > (SELECT MIN(type_id) FROM RoomType)
));

-- Alternative: Simple insert for ALL room types that lack images (uses same generic hotel image)
-- INSERT INTO RoomImage (type_id, image_url)
-- SELECT type_id, 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80'
-- FROM RoomType WHERE type_id NOT IN (SELECT DISTINCT type_id FROM RoomImage);
