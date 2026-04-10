# Thong tin Khach san

## Tong quan nghiep vu

Mô-đun Thông tin Khách sạn cho phép quản trị viên cập nhật và quản lý các thông tin công khai của khách sạn, bao gồm:

1. **Thông tin cơ bản**: Tên khách sạn, slogan, mô tả ngắn, mô tả đầy đủ
2. **Thông tin liên hệ**: Địa chỉ, thành phố, điện thoại, email, website
3. **Chính sách hoạt động**: Giờ check-in, giờ check-out, chính sách hủy phòng, chính sách khác
4. **Tiện nghi**: Danh sách các tiện nghi mà khách sạn cung cấp (lưu dưới dạng chuỗi comma-separated)
5. **Logo**: URL của logo khách sạn
6. **Mạng xã hội**: Liên kết Facebook, Instagram, Twitter

Dữ liệu được lưu trong bảng HotelInfo (singleton pattern - chỉ một dòng duy nhất).

## Kien truc & Code Flow

```
HTTP Request (GET/POST)
    |
    v
AdminHotelInfoController
    |
    +---> GET: Lấy HotelInfo
    +---> POST: Lưu HotelInfo
    |
    v
HotelInfoService
    |
    v
HotelInfoRepository
    |
    v
Database (HotelInfo table)
```

Cơ chế hoạt động:
1. GET request: Controller lấy HotelInfo từ Service, set vào JSP form cho admin chỉnh sửa
2. POST request: Controller lấy dữ liệu từ form, gọi Service để cập nhật database
3. Service là lớp trung gian xử lý logic (kiểm tra dữ liệu tồn tại, tạo default nếu cần)
4. Repository thực hiện các thao tác CRUD với database

## Chi tiet tung ham

### AdminHotelInfoController

#### init()

- **Muc dich**: Khởi tạo controller, tạo instance của HotelInfoService
- **Input**: Không có
- **Output**: Void
- **Logic xu ly**:
  1. Tạo new HotelInfoService()
  2. Gán vào hotelInfoService
- **Xu ly loi**: Không có
- **Lien ket**: HotelInfoService

---

#### doGet(HttpServletRequest request, HttpServletResponse response)

- **Muc dich**: Hiển thị form chỉnh sửa thông tin khách sạn
- **Input**: request, response
- **Output**: Void - forward đến /WEB-INF/views/admin/content/hotel-info.jsp
- **Logic xu ly**:
  1. Gọi hotelInfoService.getHotelInfo() lấy thông tin khách sạn
  2. Set attribute "hotelInfo" vào request (dùng để bind vào form)
  3. Set activePage = "hotel-info"
  4. Set pageTitle = "Thông tin khách sạn"
  5. Forward sang view hotel-info.jsp
- **Xu ly loi**: Nếu service throw exception, servlet sẽ báo lỗi
- **Lien ket**: HotelInfoService.getHotelInfo()

---

#### doPost(HttpServletRequest request, HttpServletResponse response)

- **Muc dich**: Nhận dữ liệu từ form và lưu thông tin khách sạn vào database
- **Input**: request (chứa các parameter form), response
- **Output**: Void - redirect hoặc forward
- **Logic xu ly**:
  1. Set character encoding UTF-8 cho request (để hỗ trợ tiếng Việt)
  2. Tạo object HotelInfo mới
  3. Lấy các parameter từ request và set vào object:
     - hotelName -> info.name
     - slogan -> info.slogan
     - shortDescription -> info.shortDescription
     - fullDescription -> info.fullDescription
     - address -> info.address
     - city -> info.city
     - phone -> info.phone
     - email -> info.email
     - website -> info.website
     - checkInTime -> info.checkInTime
     - checkOutTime -> info.checkOutTime
     - cancellationPolicy -> info.cancellationPolicy
     - policies -> info.policies
     - facebook -> info.facebook
     - instagram -> info.instagram
     - twitter -> info.twitter
  4. Xử lý amenities (tiện nghi):
     - Lấy request.getParameterValues("amenities") -> mảng amenities[]
     - Nếu array không null: String.join(",", amenitiesArr) -> convert thành chuỗi comma-separated
     - Set vào info.amenities
  5. Lấy thông tin khách sạn hiện có (để giữ lại logo nếu không upload mới)
  6. Set logoUrl từ existing info vào info mới
  7. Gọi hotelInfoService.updateHotelInfo(info)
  8. Nếu update thành công (return true):
     - Redirect về /admin/content/hotel-info?success=saved
  9. Nếu update thất bại (return false):
     - Set error message: "Không thể lưu thông tin. Vui lòng thử lại."
     - Set hotelInfo vào request
     - Forward lại sang view hotel-info.jsp để hiển thị lỗi
  10. Nếu throw exception:
      - Catch exception
      - Set error message với exception message
      - Gọi doGet() để hiển thị form lại
- **Xu ly loi**:
  - Try-catch bao quanh toàn bộ logic
  - Nếu exception: set error attribute và doGet()
- **Lien ket**: HotelInfoService.updateHotelInfo()

---

### HotelInfoService

#### getHotelInfo(): HotelInfo

- **Muc dich**: Lấy thông tin khách sạn, tạo default row nếu chưa tồn tại
- **Input**: Không có
- **Output**: HotelInfo object
- **Logic xu ly**:
  1. Gọi hotelInfoRepository.findFirst() lấy thông tin khách sạn từ database
  2. Nếu info null (chưa tồn tại):
     - Gọi hotelInfoRepository.insertDefault() tạo row default
     - Gọi lại hotelInfoRepository.findFirst() để lấy info vừa tạo
  3. Return info
- **Xu ly loi**: Nếu repository throw exception, propagate lên
- **Lien ket**: HotelInfoRepository

---

#### updateHotelInfo(HotelInfo info): boolean

- **Muc dich**: Cập nhật thông tin khách sạn vào database
- **Input**: HotelInfo object chứa dữ liệu cần cập nhật
- **Output**: boolean - true nếu cập nhật thành công, false nếu thất bại
- **Logic xu ly**:
  1. Trong try-catch:
     - Gọi hotelInfoRepository.findFirst() lấy thông tin khách sạn hiện có
     - Nếu existing null (chưa có data):
       - Gọi hotelInfoRepository.insertDefault() tạo row default
       - Gọi lại findFirst() để lấy info ID
     - Set info ID từ existing info vào info mới (info.setInfoId(existing.getInfoId()))
     - Gọi hotelInfoRepository.update(info) lưu vào database
     - Return (rowsAffected > 0) - true nếu có dòng bị ảnh hưởng
  2. Nếu exception:
     - Throw RuntimeException với message "Failed to update hotel info"
- **Xu ly loi**: Throw RuntimeException nếu có lỗi
- **Lien ket**: HotelInfoRepository

---

### HotelInfoRepository

#### mapRow(ResultSet rs): HotelInfo

- **Muc dich**: Ánh xạ dữ liệu từ ResultSet thành object HotelInfo
- **Input**: ResultSet từ database query
- **Output**: HotelInfo object
- **Logic xu ly**:
  1. Tạo HotelInfo object mới
  2. Map từng cột database sang property của object:
     - info_id -> infoId
     - hotel_name -> name
     - slogan -> slogan
     - short_description -> shortDescription
     - full_description -> fullDescription
     - address -> address
     - city -> city
     - phone -> phone
     - email -> email
     - website -> website
     - check_in_time -> checkInTime
     - check_out_time -> checkOutTime
     - cancellation_policy -> cancellationPolicy
     - policies -> policies
     - logo_url -> logoUrl
     - facebook -> facebook
     - instagram -> instagram
     - twitter -> twitter
     - amenities -> amenities
     - updated_at -> updatedAt (nếu không null, convert Timestamp sang LocalDateTime)
  3. Return object
- **Xu ly loi**: Nếu SQLException: propagate lên
- **Lien ket**: Không

---

#### findFirst(): HotelInfo

- **Muc dich**: Lấy dòng thông tin khách sạn duy nhất (singleton pattern)
- **Input**: Không có
- **Output**: HotelInfo object hoặc null nếu không tìm thấy
- **Logic xu ly**:
  1. Tạo SQL query: "SELECT TOP 1 * FROM HotelInfo"
  2. Gọi queryOne(sql) để thực hiện query
  3. queryOne sẽ:
     - Lấy connection từ DbContext
     - Prepare statement
     - Execute query
     - Nếu có result: gọi mapRow(rs) để convert thành HotelInfo
     - Close resource
  4. Return HotelInfo hoặc null
- **Xu ly loi**: Nếu SQLException: throw RuntimeException
- **Lien ket**: queryOne() từ BaseRepository

---

#### update(HotelInfo info): int

- **Muc dich**: Cập nhật dòng thông tin khách sạn
- **Input**: HotelInfo object chứa dữ liệu mới
- **Output**: int - số dòng bị ảnh hưởng (thường là 1)
- **Logic xu ly**:
  1. Tạo SQL UPDATE statement với 18 cột:
     ```sql
     UPDATE HotelInfo SET
       hotel_name = ?, slogan = ?, short_description = ?, full_description = ?,
       address = ?, city = ?, phone = ?, email = ?, website = ?,
       check_in_time = ?, check_out_time = ?,
       cancellation_policy = ?, policies = ?,
       logo_url = ?, facebook = ?, instagram = ?, twitter = ?,
       amenities = ?, updated_at = GETDATE()
     WHERE info_id = ?
     ```
  2. Gọi executeUpdate(sql, param1, param2, ..., info.getInfoId())
  3. executeUpdate sẽ:
     - Lấy connection
     - Prepare statement
     - Set parameters (18 parameter values)
     - Execute update
     - Close resource
  4. Return số dòng affected
- **Xu ly loi**: Nếu SQLException: throw RuntimeException
- **Lien ket**: executeUpdate() từ BaseRepository

---

#### insertDefault(): int

- **Muc dich**: Tạo dòng default khách sạn nếu bảng trống
- **Input**: Không có
- **Output**: int - ID của dòng vừa insert
- **Logic xu ly**:
  1. Tạo SQL INSERT statement:
     ```sql
     INSERT INTO HotelInfo (hotel_name, check_in_time, check_out_time)
     VALUES (N'Luxury Hotel', '14:00', '12:00')
     ```
  2. Gọi executeInsert(sql)
  3. executeInsert sẽ:
     - Lấy connection
     - Prepare statement với RETURN_GENERATED_KEYS
     - Execute insert
     - Lấy generated key (ID vừa insert)
     - Close resource
  4. Return ID của dòng vừa insert
- **Xu ly loi**: Nếu SQLException: throw RuntimeException
- **Lien ket**: executeInsert() từ BaseRepository

---

### HotelInfo (Entity)

#### Các properties (fields):

- **infoId**: int - khóa chính, ID của dòng HotelInfo
- **name**: String - tên khách sạn
- **slogan**: String - slogan khách sạn
- **shortDescription**: String - mô tả ngắn
- **fullDescription**: String - mô tả đầy đủ
- **address**: String - địa chỉ
- **city**: String - thành phố
- **phone**: String - số điện thoại
- **email**: String - email liên hệ
- **website**: String - URL website
- **checkInTime**: String - giờ check-in (ví dụ "14:00")
- **checkOutTime**: String - giờ check-out (ví dụ "12:00")
- **cancellationPolicy**: String - chính sách hủy phòng
- **policies**: String - chính sách khác
- **logoUrl**: String - URL của logo
- **facebook**: String - URL Facebook page
- **instagram**: String - URL Instagram profile
- **twitter**: String - URL Twitter account
- **amenities**: String - danh sách tiện nghi, định dạng comma-separated (ví dụ "Wifi,Pool,Gym")
- **updatedAt**: LocalDateTime - thời gian cập nhật lần cuối

#### Getter/Setter:

Tất cả properties đều có getter và setter tương ứng.

---

## Summary

**Singleton Pattern**: HotelInfo sử dụng pattern Singleton vì khách sạn chỉ có một bộ thông tin duy nhất.

**Flow GET:**
1. Admin truy cập /admin/content/hotel-info
2. AdminHotelInfoController.doGet() gọi HotelInfoService.getHotelInfo()
3. Service lấy từ Repository, tạo default nếu cần
4. Data set vào JSP form

**Flow POST:**
1. Admin submit form chỉnh sửa
2. AdminHotelInfoController.doPost() lấy parameter từ request
3. Xử lý amenities array thành comma-separated string
4. Gọi HotelInfoService.updateHotelInfo()
5. Service đảm bảo row tồn tại, gọi Repository update
6. Redirect về trang với success message

**Character encoding**: Sử dụng UTF-8 để hỗ trợ tiếng Việt.

**Error handling**: Post request có try-catch, nếu lỗi sẽ hiển thị error message trên form.
