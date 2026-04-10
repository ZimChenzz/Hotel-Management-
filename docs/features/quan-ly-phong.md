# Quan Ly Phong

## Tong quan nghiep vu

Chuc nang quan ly phong cho phep admin va staff quan ly thong tin phong, loai phong, amenities va hinh anh. Khach hang co the xem danh sach phong, chi tiet va khong dung duoc tuy chon phong cu the (he thong tu phan cong). Cac phong co trang thai (Available, Occupied, Cleaning, Maintenance) va moi loai phong co cau hinh gia base, gia theo gio, va ti le tien dat.

## Kien truc & Code Flow

### User Roles

- Customer: Xem danh sach phong, chi tiet, tim kiem theo gia/suc chua, authen + booking
- Staff: Xem so do phong, chi tiet, lich su dat phong theo phong
- Admin: Quan ly day du (them, sua, xoa phong, loai phong, hinh anh)

### Luong xu ly chinh

```
Customer/Staff GUI
   |
   v
RoomController (common) / StaffRoomController / AdminRoomController
   |
   v
RoomService / StaffRoomService / AdminRoomService
   |
   v
RoomRepository / RoomTypeRepository / AmenityRepository / RoomImageRepository
   |
   v
Database (Room, RoomType, Amenity, RoomImage, RoomType_Amenity)
```

## Chi tiet tung ham

### Entity Classes

#### Room
- **Muc dich**: Dai dien mot phong trong khach san
- **Thuoc tinh chinh**:
  - roomId: Khoa chinh
  - roomNumber: So phong (VD: "101", "2A05")
  - typeId: Tham chieu loai phong
  - status: Available / Occupied / Cleaning / Maintenance
  - roomType: Thong tin loai phong (lazy load)
  - images: Danh sach hinh anh (lazy load)

#### RoomType
- **Muc dich**: Dai dien loai phong voi cac thong so gia va tinh nang
- **Thuoc tinh chinh**:
  - typeId: Khoa chinh
  - typeName: Ten loai phong (VD: "Single", "Double", "Suite")
  - basePrice: Gia neu ngu (VD: 500000 dong)
  - pricePerHour: Gia theo gio (VD: 25000 dong)
  - capacity: So khach toi da
  - depositPercent: Ty le tien dat, null=0 la phong tieu chuan (khong yeu cau dat)
  - description: Mo ta chi tiet
  - images: Danh sach hinh anh
  - amenities: Danh sach tien ich
- **Nghiep vu**:
  - isStandardRoom(): Kiem tra neu phong tieu chuan (ko yeu cau tien dat)

#### RoomImage
- **Muc dich**: Luu tru duong dan hinh anh cho loai phong hoac phong cu the
- **Thuoc tinh**: imageId, typeId, roomId (nullable), imageUrl

#### Amenity
- **Muc dich**: Dai dien tien ich (Wifi, AC, TV, v.v.)
- **Thuoc tinh**: amenityId, name, iconUrl

### Service Classes

#### RoomService (Customer/Public View)

##### getAllRoomTypes()
- **Muc dich**: Lay toan bo loai phong co hinh anh va amenities
- **Output**: List<RoomType> voi chi tiet day du
- **Logic xu ly**:
  1. Goi roomTypeRepository.findAll()
  2. Voi moi RoomType, goi loadRoomTypeDetails() de load hinh anh + amenities
  3. Tra ve danh sach day du
- **Lien ket**: RoomTypeRepository, RoomImageRepository, AmenityRepository

##### searchRoomTypes(minPrice, maxPrice, capacity, typeId)
- **Muc dich**: Tim kiem loai phong theo cac tieu chi loc
- **Input**:
  - minPrice: Gia toi thieu (nullable)
  - maxPrice: Gia toi da (nullable)
  - capacity: Suc chua toi thieu (nullable)
  - typeId: Loai phong cu the (nullable)
- **Output**: List<RoomType> thoa dieu kien
- **Logic xu ly**:
  1. Goi roomTypeRepository.findByFilters() voi cac dieu kien
  2. Voi moi RoomType tra ve, goi loadRoomTypeDetails()
  3. Tra ve danh sach loc
- **Lien ket**: RoomTypeRepository

##### getRoomTypeById(typeId)
- **Muc dich**: Lay chi tiet mot loai phong theo ID
- **Input**: typeId (int)
- **Output**: RoomType voi day du hinh anh va amenities, null neu khong ton tai
- **Logic xu ly**:
  1. Query RoomTypeRepository.findById(typeId)
  2. Neu ton tai, goi loadRoomTypeDetails()
  3. Tra ve RoomType day du
- **Xu ly loi**: Return null neu khong tim thay

##### loadRoomTypeDetails(RoomType type)
- **Muc dich**: Phu cap dung hinh anh va amenities cho RoomType
- **Logic xu ly**:
  1. Lay images = roomImageRepository.findByTypeId(typeId)
  2. Lay amenities = amenityRepository.findByTypeId(typeId)
  3. Gan vao RoomType

##### getAvailableRoomCount(typeId)
- **Muc dich**: Dem so luong phong co san theo loai
- **Output**: int - so phong available
- **Logic xu ly**: Goi RoomRepository.countAvailableByTypeId(typeId)

##### getAvailableRooms(typeId, checkIn, checkOut)
- **Muc dich**: Lay danh sach phong co san cho khoang thoi gian
- **Input**:
  - typeId: Loai phong
  - checkIn: Thoi gian nhan phong (nullable)
  - checkOut: Thoi gian tra phong (nullable)
- **Output**: List<Room> phong khong xung dot voi cac booking khac
- **Logic xu ly**:
  1. Neu checkIn/checkOut null, tra ve findAvailableByTypeId()
  2. Neu co thoi gian, goi findAvailableForDates() de check xung dot booking
- **Lien ket**: RoomRepository

##### getFeaturedRoomTypes(limit)
- **Muc dich**: Lay danh sach loai phong featured (so luong gioi han)
- **Output**: List<RoomType> (toi da = limit)
- **Logic xu ly**:
  1. Lay toan bo loai phong + chi tiet
  2. Tra ve limit phan tu dau tien

#### StaffRoomService

##### getAllRoomsWithType()
- **Muc dich**: Lay toan bo phong voi chi tiet loai phong
- **Output**: List<Room> co RoomType day du
- **Lien ket**: RoomRepository

##### getRoomsGroupedByFloor()
- **Muc dich**: Nhomp phong theo tang (dung so dau cua so phong)
- **Output**: Map<String, List<Room>> - key la "Tang X"
- **Logic xu ly**:
  1. Lay toan bo phong voi type
  2. Stream/group theo ky tu dau cua roomNumber
  3. Neu roomNumber rong hoac khong hop le, dung khoa "Khac"
  4. Tra ve map

##### getRoomDetail(roomId)
- **Muc dich**: Lay chi tiet mot phong
- **Output**: Room voi RoomType va hinh anh
- **Logic xu ly**:
  1. Query findWithRoomType(roomId)
  2. Load hinh anh cho room + type
- **Lien ket**: RoomRepository, RoomImageRepository

##### countByStatus(status)
- **Muc dich**: Dem so phong theo trang thai
- **Output**: int
- **Lien ket**: RoomRepository

##### updateRoomStatus(roomId, status)
- **Muc dich**: Cap nhat trang thai phong
- **Output**: boolean - true neu thanh cong
- **Lien ket**: RoomRepository

##### markAsAvailable/markAsOccupied/markAsCleaning(roomId)
- **Muc dich**: Cap nhat trang thai phong vao cac trang thai cu the
- **Logic**: Goi updateRoomStatus() voi trang thai tuong ung

##### getRoomHistory(roomId)
- **Muc dich**: Lay lich su booking cua phong
- **Output**: List<Booking>
- **Lien ket**: BookingRepository

#### AdminRoomService

##### getAllRooms()
- **Muc dich**: Lay toan bo phong voi chi tiet loai phong va hinh anh
- **Output**: List<Room> day du thong tin
- **Logic xu ly**:
  1. Query findAllWithRoomType()
  2. Voi moi phong, load hinh anh cua type
- **Lien ket**: RoomRepository, RoomImageRepository

##### getRoomById(roomId)
- **Muc dich**: Lay chi tiet phong (admin view)
- **Output**: Room voi day du thong tin
- **Logic xu ly**:
  1. Query findWithRoomType(roomId)
  2. Load hinh anh cua room + type
- **Lien ket**: RoomRepository, RoomImageRepository

##### createRoom(Room room)
- **Muc dich**: Tao phong moi
- **Input**: Room object voi roomNumber, typeId, status
- **Output**: boolean - true neu thanh cong
- **Logic**: Goi RoomRepository.insert()
- **Validation**: Kiem tra roomNumber co trung khong?

##### updateRoom(Room room)
- **Muc dich**: Cap nhat thong tin phong
- **Output**: boolean
- **Lien ket**: RoomRepository

##### deleteRoom(roomId)
- **Muc dich**: Xoa phong
- **Output**: boolean
- **Lien ket**: RoomRepository

##### createRoomType/updateRoomType/deleteRoomType(RoomType)
- **Muc dich**: Quan ly loai phong
- **Lien ket**: RoomTypeRepository

##### getRoomHistory(roomId)
- **Muc dich**: Lay lich su dat phong cua phong
- **Output**: List<Booking>

##### getCurrentBookingForRoom(roomId)
- **Muc dich**: Lay booking hien tai (dang checked-in) cua phong
- **Output**: Booking hoac null
- **Lien ket**: BookingRepository

##### addRoomImage/deleteRoomImage(...)
- **Muc dich**: Quan ly hinh anh phong
- **Lien ket**: RoomImageRepository

### Repository Classes

#### RoomRepository

##### findById(roomId)
- **SQL**: SELECT * FROM Room WHERE room_id = ?
- **Output**: Room

##### findWithRoomType(roomId)
- **SQL**: JOIN Room voi RoomType
- **Output**: Room voi RoomType details (type_name, base_price, capacity, description)

##### findByTypeId(typeId)
- **SQL**: SELECT * FROM Room WHERE type_id = ? ORDER BY room_number
- **Output**: List<Room> theo loai

##### findAvailableByTypeId(typeId)
- **SQL**: SELECT * FROM Room WHERE type_id = ? AND status = 'Available'
- **Output**: List<Room> co san

##### findAvailableForDates(typeId, checkIn, checkOut, excludeBookingId)
- **Muc dich**: Tim phong khong xung dot voi cac booking trong khoang thoi gian
- **SQL**:
  ```sql
  SELECT r.* FROM Room r
  WHERE r.type_id = ?
    AND r.status = 'Available'
    AND r.room_id NOT IN (
      SELECT b.room_id FROM Booking b
      WHERE b.booking_id != ?
        AND b.status IN ('Pending', 'Confirmed', 'CheckedIn')
        AND NOT (b.check_out_expected <= ? OR b.check_in_expected >= ?)
    )
  ```
- **Logic**: Exclude phong da co booking trong khung thoi gian, tru booking dang xet
- **Output**: List<Room> available

##### countAvailableByTypeId(typeId)
- **SQL**: SELECT COUNT(*) FROM Room WHERE type_id = ? AND status = 'Available'
- **Output**: int

##### updateStatus(roomId, status)
- **SQL**: UPDATE Room SET status = ? WHERE room_id = ?
- **Output**: int - so hang cap nhat

##### findAll()
- **Output**: List<Room> theo room_number

##### findAllWithRoomType()
- **SQL**: JOIN Room voi RoomType
- **Output**: List<Room> voi RoomType details

##### findByStatus(status)
- **Output**: List<Room> voi status da cho

##### countByStatus(status)
- **Output**: int

##### findByRoomNumber(roomNumber)
- **Output**: Room hoac null

##### insert/update/delete
- CRUD operations

#### RoomTypeRepository

##### findAll()
- **SQL**: SELECT * FROM RoomType ORDER BY base_price
- **Output**: List<RoomType>

##### findById(typeId)
- **Output**: RoomType

##### findByFilters(minPrice, maxPrice, minCapacity, typeId)
- **Muc dich**: Tim kiem voi cac tieu chi loc
- **Logic xu ly**:
  1. Khoi tao "SELECT * FROM RoomType WHERE 1=1"
  2. Neu minPrice ko null, append "AND base_price >= minPrice"
  3. Neu maxPrice ko null, append "AND base_price <= maxPrice"
  4. Neu minCapacity ko null, append "AND capacity >= minCapacity"
  5. Neu typeId ko null, append "AND type_id = typeId"
  6. Append "ORDER BY base_price"
- **Output**: List<RoomType>

##### insert/update/delete
- CRUD

#### AmenityRepository

##### findByTypeId(typeId)
- **SQL**:
  ```sql
  SELECT a.* FROM Amenity a
  JOIN RoomType_Amenity rta ON a.amenity_id = rta.amenity_id
  WHERE rta.type_id = ?
  ORDER BY a.name
  ```
- **Output**: List<Amenity> cho loai phong

##### findAll()
- **SQL**: SELECT * FROM Amenity ORDER BY name
- **Output**: List<Amenity>

#### RoomImageRepository

##### findByTypeId(typeId)
- **SQL**: SELECT * FROM RoomImage WHERE type_id = ? ORDER BY image_id
- **Output**: List<RoomImage>

##### findFirstByTypeId(typeId)
- **SQL**: SELECT TOP 1 * FROM RoomImage WHERE type_id = ? ORDER BY image_id
- **Output**: RoomImage - hinh anh dau tien

##### findByRoomId(roomId)
- **SQL**: SELECT * FROM RoomImage WHERE room_id = ? ORDER BY image_id
- **Output**: List<RoomImage> cho phong cu the

##### insert(typeId, imageUrl)
- **SQL**: INSERT INTO RoomImage (type_id, image_url) VALUES (?, ?)

##### insertForRoom(roomId, imageUrl)
- **Muc dich**: Them hinh anh cho phong cu the, tu dong lay type_id
- **SQL**:
  ```sql
  INSERT INTO RoomImage (type_id, room_id, image_url)
  SELECT type_id, ?, ? FROM Room WHERE room_id = ?
  ```

##### deleteById(imageId)
- **SQL**: DELETE FROM RoomImage WHERE image_id = ?

### Controller Classes

#### RoomController (Customer/Public View)

##### @WebServlet("/rooms", "/rooms/detail")

##### handleList (GET /rooms)
- **Muc dich**: Hien thi danh sach loai phong voi tuy chon loc
- **Input params**: minPrice, maxPrice, capacity, typeId
- **Logic xu ly**:
  1. Parse cac tham so loc
  2. Neu co tham so loc, goi searchRoomTypes()
  3. Neu khong, goi getAllRoomTypes()
  4. Lay toan bo types cho dropdown loc
  5. Voi moi RoomType, load active promotion (neu co)
  6. Tinh toan gia giam gia (basePrice * (100 - discountPercent) / 100)
  7. Dat vao request: roomTypes, allTypes, promotionMap, discountedPriceMap
- **Template**: /WEB-INF/views/room/list.jsp
- **Lien ket**: RoomService, PromotionService

##### handleDetail (GET /rooms/detail)
- **Muc dich**: Hien thi chi tiet mot loai phong
- **Input params**: typeId
- **Logic xu ly**:
  1. Kiem tra typeId co hop le, neu khong redirect den /rooms
  2. Query getRoomTypeById(typeId), neu null -> HTTP 404
  3. Dem so phong available: getAvailableRoomCount(typeId)
  4. Lay danh sach phong available: getAvailableRooms(typeId, null, null)
  5. Load active promotion va tinh gia giam
  6. Dat vao request: roomType, availableCount, availableRooms, activePromo, discountedPrice
- **Template**: /WEB-INF/views/room/detail.jsp

##### parseIntParam(request, name)
- **Muc dich**: An toan parse tham so integer tu request
- **Logic**:
  1. Lay gia tri string tu request
  2. Neu rong hoac null, tra ve null
  3. Try parse to Integer
  4. Neu NumberFormatException, tra ve null

#### StaffRoomController

##### @WebServlet("/staff/rooms", "/staff/rooms/detail", "/staff/rooms/history")

##### handleRoomMap (GET /staff/rooms)
- **Muc dich**: Hien thi so do phong (nhomp theo tang)
- **Logic xu ly**:
  1. Lay toan bo phong: getAllRoomsWithType()
  2. Nhomp theo tang: getRoomsGroupedByFloor()
  3. Dat vao request: rooms, roomsByFloor
- **Template**: /WEB-INF/views/staff/rooms/map.jsp

##### handleRoomDetail (GET /staff/rooms/detail)
- **Muc dich**: Hien thi chi tiet phong
- **Input params**: id (roomId)
- **Logic xu ly**:
  1. Kiem tra id co hop le
  2. Query getRoomDetail(roomId)
  3. Neu null, return HTTP 404
  4. Dat vao request: room
- **Template**: /WEB-INF/views/staff/rooms/detail.jsp

##### handleRoomHistory (GET /staff/rooms/history)
- **Muc dich**: Hien thi lich su dat phong cua phong
- **Logic xu ly**:
  1. Query getRoomDetail(roomId)
  2. Lay lich su: getRoomHistory(roomId)
  3. Dat vao request: room, bookings
- **Template**: /WEB-INF/views/staff/rooms/history.jsp

#### AdminRoomController

##### @WebServlet(urlPatterns = {...multiple endpoints...})
##### @MultipartConfig
- **Max file size**: 5 MB
- **Max request size**: 25 MB

##### handleRoomMap (GET /admin/rooms/map)
- **Muc dich**: Hien thi so do phong (admin view)
- **Logic**: Nhomp phong theo tang, dat vao request

##### handleRoomList (GET /admin/rooms)
- **Muc dich**: Hien thi danh sach toan bo phong
- **Logic**:
  1. Query getAllRooms() + getAllRoomTypes()
  2. Dat vao request: rooms, roomTypes

##### showRoomForm (GET /admin/rooms/create)
- **Muc dich**: Hien thi form them phong moi
- **Logic**:
  1. Lay toan bo room types
  2. Lay list trang thai: AVAILABLE, OCCUPIED, CLEANING, MAINTENANCE
  3. Build map hinh anh cua tung type (de hien thi visual)
  4. Dat vao request

##### showRoomEditForm (GET /admin/rooms/edit)
- **Muc dich**: Hien thi form sua phong
- **Logic**:
  1. Parse roomId tu request param
  2. Query getRoomById()
  3. Lay toan bo room types
  4. Dat vao request

##### handleRoomCreate (POST /admin/rooms/create)
- **Muc dich**: Tao phong moi
- **Input**: roomNumber, typeId, status (form params)
- **Logic xu ly**:
  1. Parse cac tham so
  2. Kiem tra phong co trung hay khong: findRoomByNumber()
  3. Tao Room object va goi createRoom()
  4. Neu thanh cong, redirect den /admin/rooms
  5. Neu loi, hien thi form lai voi error message

##### handleRoomUpdate (POST /admin/rooms/edit)
- **Muc dich**: Cap nhat phong
- **Logic**: Parse + validate + goi updateRoom() + redirect

##### handleRoomDelete (POST /admin/rooms/delete)
- **Muc dich**: Xoa phong
- **Logic**: Parse roomId + goi deleteRoom()

##### handleRoomImageUpload (POST /admin/rooms/upload-image)
- **Muc dich**: Upload hinh anh cho phong
- **Logic xu ly**:
  1. Parse roomId tu form
  2. Lay Part (file upload)
  3. Validate file (size, type)
  4. Generate UUID cho ten file
  5. Luu file vao thu muc
  6. Tao record trong RoomImage table voi imageUrl
  7. Redirect + success message

##### handleRoomImageDelete (POST /admin/rooms/delete-image)
- **Muc dich**: Xoa hinh anh
- **Logic**: Parse imageId + goi deleteRoomImage()

##### Tuong tu cho room-types (create, edit, delete)
- Xu ly RoomType voi cac tham so gia va suc chua

## Luong du lieu (Data Flow)

### Use Case: Customer browse room va booking

1. Customer truy cap GET /rooms
2. RoomController.handleList()
   - RoomService.getAllRoomTypes() -> queryList [SELECT * FROM RoomType]
   - Voi moi RoomType:
     - loadRoomTypeDetails(type) -> RoomImageRepository.findByTypeId() + AmenityRepository.findByTypeId()
   - PromotionService.getActivePromotion() -> check co promotion hay khong
   - Tinh discountedPrice neu co promotion
3. JSP hien thi danh sach rooms voi gia goc va gia giam

4. Customer click xem chi tiet phong
5. GET /rooms/detail?typeId=X
6. RoomController.handleDetail()
   - RoomService.getRoomTypeById() -> queryOne + loadDetails
   - RoomService.getAvailableRoomCount() -> countAvailableByTypeId
   - RoomService.getAvailableRooms() -> findAvailableByTypeId
7. JSP hien thi chi tiet type, so phong available, khuyen mai

### Use Case: Admin quan ly phong

1. Admin GET /admin/rooms -> RoomController.handleRoomList()
   - AdminRoomService.getAllRooms() -> JOIN Room + RoomType + load images
2. Admin tao phong: GET /admin/rooms/create -> form
3. Admin submit: POST /admin/rooms/create
   - AdminRoomService.createRoom() -> RoomRepository.insert()
   - DB: INSERT INTO Room (room_number, type_id, status) VALUES (...)
4. Admin sua: GET /admin/rooms/edit?id=X
   - AdminRoomService.getRoomById() -> query + load details
5. Admin update: POST /admin/rooms/edit
   - AdminRoomService.updateRoom() -> RoomRepository.update()
6. Admin upload hinh: POST /admin/rooms/upload-image
   - File luu vao server
   - RoomImageRepository.insertForRoom() -> ghi vao DB

### Use Case: Staff xem so do phong

1. Staff GET /staff/rooms
2. StaffRoomController.handleRoomMap()
   - StaffRoomService.getAllRoomsWithType()
   - StaffRoomService.getRoomsGroupedByFloor() -> stream/group
3. JSP hien thi so do theo tang

## Bao mat & Phan quyen

### Authentication & Authorization

- RoomController (public): Ko can auth, bat ky ai cung truy cap duoc
- StaffRoomController: Yeu cau dang nhap + role = Staff (filter AuthFilter)
- AdminRoomController: Yeu cau dang nhap + role = Admin (filter AdminAuthFilter)

### SQL Injection Prevention

- Toan bo query su dung PreparedStatement voi placeholder (?)
- Params khong bao gio string concatenation vao SQL

### File Upload Security

- Check file extension (jpg, png, gif)
- Check file size (max 5MB)
- Generate UUID cho ten file (tranh ghi de file cu)
- Luu file ngoai web root hoac vao controlled folder
- Validate MIME type

### Data Validation

- RoomNumber: Khong duoc rong, duy nhat
- TypeId: Phai co ton tai trong DB
- Status: Phai la mot trong cac gia tri hop le (Available, Occupied, v.v.)
- BasePrice, PricePerHour, DepositPercent: Phai >= 0
- Capacity: Phai > 0
