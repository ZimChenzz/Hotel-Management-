# Quan ly Khuyen mai

## Tong quan nghiep vu

Tính năng quản lý khuyến mãi cho phép quản trị viên tạo, cập nhật và xóa các đợt khuyến mãi cho các loại phòng khác nhau. Mỗi khuyến mãi được xác định bằng mã code, loại phòng áp dụng, phần trăm chiết khấu, và khoảng thời gian có hiệu lực. Hệ thống sẽ tự động xác định trạng thái khuyến mãi (sắp tới, đang hoạt động, hoặc hết hạn) dựa trên ngày hiện tại.

Khuyến mãi được sử dụng khi hiển thị thông tin phòng cho khách hàng (hiển thị badge chiết khấu) và trong tính toán giá khi khách hàng đặt phòng.

## Kien truc & Code Flow

```
Request (GET/POST) -> AdminPromotionController
                   -> AdminPromotionService (validate & process)
                   -> PromotionRepository (data access)
                   -> PromotionService (shared lookup for promotions)
                   -> Database (Promotion table)
```

### Luong goi dich vu chinh:
1. Danh sach khuyến mãi: GET /admin/promotions -> Controller -> Service -> Repository -> JSP view
2. Tạo khuyến mãi: GET (form) + POST -> Controller -> validate -> Service -> Repository -> insert
3. Sửa khuyến mãi: GET (form) + POST -> Controller -> validate -> Service -> Repository -> update
4. Xóa khuyến mãi: POST -> Controller -> Service -> Repository -> delete
5. Lấy khuyến mãi hoạt động: Service -> Repository -> queryOne (dùng cho hiển thị & tính giá)

## Chi tiet tung ham

### AdminPromotionController

#### handleList(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Hiển thị danh sách toàn bộ khuyến mãi đã tạo
- **Input**: request, response
- **Output**: Danh sách Promotion được chuyển đến view list.jsp
- **Logic xu ly**:
  1. Gọi adminPromotionService.getAllPromotions() lấy tất cả khuyến mãi
  2. Kiểm tra parameter "success" để hiển thị thông báo (tạo/cập nhật/xóa thành công)
  3. Set attribute activePage="promotions" và pageTitle="Quản lý Khuyến mãi"
  4. Forward request đến /WEB-INF/views/admin/promotions/list.jsp
- **Xu ly loi**: Không có, chỉ forward view
- **Lien ket**: AdminPromotionService.getAllPromotions()

#### handleCreateForm(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Hiển thị form tạo khuyến mãi mới
- **Input**: request, response
- **Output**: Form view với danh sách loại phòng
- **Logic xu ly**:
  1. Gọi adminPromotionService.getAllRoomTypes() lấy danh sách loại phòng
  2. Set isEdit=false (để view biết đây là mode tạo)
  3. Set pageTitle="Thêm Khuyến mãi"
  4. Forward đến form.jsp
- **Xu ly loi**: Không có
- **Lien ket**: AdminPromotionService.getAllRoomTypes()

#### handleEditForm(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Hiển thị form sửa khuyến mãi hiện có
- **Input**: request (parameter "id" là ID khuyến mãi), response
- **Output**: Form view với dữ liệu khuyến mãi hiện tại
- **Logic xu ly**:
  1. Parse parameter "id" thành int
  2. Gọi adminPromotionService.getPromotionById(id) lấy dữ liệu khuyến mãi
  3. Nếu promotion null -> redirect đến /admin/promotions?error=notfound
  4. Set promotion object, roomTypes, isEdit=true vào attributes
  5. Set pageTitle="Sửa Khuyến mãi"
  6. Forward đến form.jsp
- **Xu ly loi**: Nếu promotion không tìm thấy, redirect với error message
- **Lien ket**: AdminPromotionService.getPromotionById(), getAllRoomTypes()

#### handleCreate(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Xử lý yêu cầu tạo khuyến mãi mới
- **Input**: request (parameters: typeId, promoCode, discountPercent, startDate, endDate), response
- **Output**: Redirect đến /admin/promotions?success=created hoặc quay lại form với error
- **Logic xu ly**:
  1. Parse typeId thành int
  2. Parse discountPercent thành BigDecimal
  3. Parse startDate, endDate thành LocalDate
  4. Gọi adminPromotionService.createPromotion() với các parameter
  5. Nếu result > 0 -> redirect with success=created
  6. Nếu result <= 0 -> set error message, forward lại form
- **Xu ly loi**: Try-catch bắt Exception (parse error, invalid data) -> set error message, forward form
- **Lien ket**: AdminPromotionService.createPromotion()

#### handleEdit(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Xử lý yêu cầu cập nhật khuyến mãi
- **Input**: request (parameters: id, typeId, promoCode, discountPercent, startDate, endDate), response
- **Output**: Redirect đến /admin/promotions?success=updated hoặc quay lại form với error
- **Logic xu ly**:
  1. Parse id, typeId thành int
  2. Parse discountPercent thành BigDecimal
  3. Parse startDate, endDate thành LocalDate
  4. Gọi adminPromotionService.updatePromotion()
  5. Nếu success=true -> redirect with success=updated
  6. Nếu success=false -> set error, forward lại form
- **Xu ly loi**: Try-catch bắt Exception -> set error message, forward form
- **Lien ket**: AdminPromotionService.updatePromotion()

#### handleDelete(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Xử lý yêu cầu xóa khuyến mãi
- **Input**: request (parameter "id"), response
- **Output**: Redirect đến /admin/promotions?success=deleted
- **Logic xu ly**:
  1. Parse parameter "id" thành int
  2. Gọi adminPromotionService.deletePromotion(id)
  3. Redirect đến /admin/promotions?success=deleted
- **Xu ly loi**: Không có (xóa luôn coi như thành công)
- **Lien ket**: AdminPromotionService.deletePromotion()

### AdminPromotionService

#### getAllPromotions()
- **Muc dich**: Lấy danh sách tất cả khuyến mãi (bao gồm tên loại phòng via JOIN)
- **Input**: Không có
- **Output**: List<Promotion> chứa tất cả khuyến mãi, sắp xếp theo ID giảm dần
- **Logic xu ly**:
  1. Gọi promotionRepository.findAll()
  2. Return danh sách kết quả
- **Xu ly loi**: Không có
- **Lien ket**: PromotionRepository.findAll()

#### getPromotionById(int promotionId)
- **Muc dich**: Lấy thông tin chi tiết một khuyến mãi theo ID
- **Input**: promotionId (ID khuyến mãi)
- **Output**: Promotion object hoặc null nếu không tìm thấy
- **Logic xu ly**:
  1. Gọi promotionRepository.findById(promotionId)
  2. Return kết quả
- **Xu ly loi**: Return null nếu không tìm thấy
- **Lien ket**: PromotionRepository.findById()

#### getAllRoomTypes()
- **Muc dich**: Lấy danh sách tất cả loại phòng (để hiển thị trong form)
- **Input**: Không có
- **Output**: List<RoomType>
- **Logic xu ly**:
  1. Gọi roomTypeRepository.findAll()
  2. Return kết quả
- **Xu ly loi**: Không có
- **Lien ket**: RoomTypeRepository.findAll()

#### createPromotion(int typeId, String promoCode, BigDecimal discountPercent, LocalDate startDate, LocalDate endDate)
- **Muc dich**: Tạo khuyến mãi mới sau khi validate
- **Input**:
  - typeId: ID loại phòng
  - promoCode: Mã khuyến mãi (sẽ được convert thành UPPERCASE)
  - discountPercent: Phần trăm chiết khấu (0-100)
  - startDate: Ngày bắt đầu
  - endDate: Ngày kết thúc
- **Output**: ID promotion mới được tạo (> 0) hoặc -1 nếu validation fail
- **Logic xu ly**:
  1. Gọi isValidInput() để validate toàn bộ input
  2. Nếu invalid -> return -1
  3. Tạo Promotion object mới
  4. Set typeId, promoCode (uppercase trim), discountPercent, startDate, endDate
  5. Gọi promotionRepository.insert(p) -> return promotion_id từ DB
- **Xu ly loi**: Validation fail return -1 (không throw exception)
- **Lien ket**: isValidInput(), PromotionRepository.insert()

#### updatePromotion(int promotionId, int typeId, String promoCode, BigDecimal discountPercent, LocalDate startDate, LocalDate endDate)
- **Muc dich**: Cập nhật khuyến mãi hiện có
- **Input**: promotionId + các field cần update (typeId, promoCode, discountPercent, startDate, endDate)
- **Output**: true nếu update thành công, false nếu fail
- **Logic xu ly**:
  1. Tìm promotion hiện có bằng findById(promotionId)
  2. Nếu promotion null -> return false
  3. Validate input bằng isValidInput()
  4. Nếu invalid -> return false
  5. Set các field mới vào promotion object (promoCode uppercase trim)
  6. Gọi promotionRepository.update(existing) -> return số rows affected
  7. Return (rows affected > 0)
- **Xu ly loi**: Return false nếu promotion không tìm thấy hoặc validation fail
- **Lien ket**: isValidInput(), PromotionRepository.update()

#### deletePromotion(int promotionId)
- **Muc dich**: Xóa khuyến mãi
- **Input**: promotionId
- **Output**: true nếu xóa thành công, false nếu fail
- **Logic xu ly**:
  1. Gọi promotionRepository.delete(promotionId)
  2. Return (rows deleted > 0)
- **Xu ly loi**: Không có exception handling, coi xóa luôn thành công
- **Lien ket**: PromotionRepository.delete()

#### isValidInput(int typeId, BigDecimal discountPercent, LocalDate startDate, LocalDate endDate)
- **Muc dich**: Validate tất cả input trước khi create/update
- **Input**: typeId, discountPercent, startDate, endDate
- **Output**: true nếu valid, false nếu invalid
- **Logic xu ly**:
  1. Kiểm tra discountPercent:
     - Không null
     - > 0
     - <= 100
     - Nếu không thỏa -> return false
  2. Kiểm tra dates:
     - startDate và endDate không null
     - endDate không được trước startDate
     - Nếu không thỏa -> return false
  3. Kiểm tra loại phòng:
     - roomTypeRepository.findById(typeId) != null
     - Nếu null (không tồn tại) -> return false
  4. Nếu tất cả hợp lệ -> return true
- **Xu ly loi**: Return false, không throw exception
- **Lien ket**: RoomTypeRepository.findById()

### PromotionService

#### getActivePromotion(int typeId)
- **Muc dich**: Lấy khuyến mãi đang hoạt động (active) cho một loại phòng
- **Input**: typeId (ID loại phòng)
- **Output**: Promotion object nếu có khuyến mãi đang hoạt động, null nếu không có
- **Logic xu ly**:
  1. Gọi promotionRepository.findActiveByTypeId(typeId)
  2. Return kết quả
- **Xu ly loi**: Return null nếu không có promotion hoạt động
- **Lien ket**: PromotionRepository.findActiveByTypeId()

### PromotionRepository

#### findAll()
- **Muc dich**: Lấy danh sách tất cả promotion kèm thông tin loại phòng (JOIN)
- **Input**: Không có
- **Output**: List<Promotion>
- **SQL**:
  ```sql
  SELECT p.*, rt.type_name
  FROM Promotion p
  JOIN RoomType rt ON p.type_id = rt.type_id
  ORDER BY p.promotion_id DESC
  ```
- **Lien ket**: queryList() từ BaseRepository

#### findById(int promotionId)
- **Muc dich**: Lấy promotion theo ID kèm type_name
- **Input**: promotionId
- **Output**: Promotion object hoặc null
- **SQL**:
  ```sql
  SELECT p.*, rt.type_name
  FROM Promotion p
  JOIN RoomType rt ON p.type_id = rt.type_id
  WHERE p.promotion_id = ?
  ```
- **Lien ket**: queryOne()

#### findActiveByTypeId(int typeId)
- **Muc dich**: Lấy promotion đang hoạt động (trong khoảng thời gian) cho loại phòng
- **Input**: typeId
- **Output**: Promotion object hoặc null
- **SQL**:
  ```sql
  SELECT TOP 1 p.*, rt.type_name
  FROM Promotion p
  JOIN RoomType rt ON p.type_id = rt.type_id
  WHERE p.type_id = ?
  AND CAST(GETDATE() AS DATE) BETWEEN p.start_date AND p.end_date
  ORDER BY p.promotion_id DESC
  ```
- **Logic**: Nếu có nhiều promotion overlap, lấy cái mới nhất (promotion_id cao nhất)
- **Lien ket**: queryOne()

#### insert(Promotion p)
- **Muc dich**: Tạo promotion mới trong DB
- **Input**: Promotion object chứa: typeId, promoCode, discountPercent, startDate, endDate
- **Output**: ID promotion mới được tạo
- **SQL**:
  ```sql
  INSERT INTO Promotion (type_id, promo_code, discount_percent, start_date, end_date)
  VALUES (?, ?, ?, ?, ?)
  ```
- **Lien ket**: executeInsert()

#### update(Promotion p)
- **Muc dich**: Cập nhật promotion hiện có
- **Input**: Promotion object (có promotionId) chứa các field cần update
- **Output**: Số rows affected (0 hoặc 1)
- **SQL**:
  ```sql
  UPDATE Promotion
  SET type_id=?, promo_code=?, discount_percent=?, start_date=?, end_date=?
  WHERE promotion_id=?
  ```
- **Lien ket**: executeUpdate()

#### delete(int promotionId)
- **Muc dich**: Xóa promotion
- **Input**: promotionId
- **Output**: Số rows deleted
- **SQL**:
  ```sql
  DELETE FROM Promotion WHERE promotion_id = ?
  ```
- **Lien ket**: executeUpdate()

### Promotion Entity

#### mapRow(ResultSet rs)
- **Muc dich**: Map một dòng ResultSet thành Promotion object
- **Input**: ResultSet từ query
- **Output**: Promotion object
- **Logic xu ly**:
  1. Extract promotion_id, type_id, promo_code, discount_percent
  2. Convert start_date, end_date từ java.sql.Date thành LocalDate
  3. Nếu có type_name (từ JOIN) -> set vào object, nếu không có ignore
  4. Return Promotion object
- **Xu ly loi**: Try-catch bắt SQLException khi lấy type_name (ignored nếu không có)

#### getStatus()
- **Muc dich**: Xác định trạng thái hiện tại của khuyến mãi (dựa trên ngày hiện tại)
- **Input**: Không có
- **Output**: String - "upcoming", "active", hoặc "expired"
- **Logic xu ly**:
  1. Lấy LocalDate.now() làm today
  2. Nếu today < startDate -> return "upcoming"
  3. Nếu today > endDate -> return "expired"
  4. Ngược lại -> return "active"
- **Xu ly loi**: Không có

#### isActive()
- **Muc dich**: Kiểm tra khuyến mãi có đang hoạt động không
- **Input**: Không có
- **Output**: boolean (true nếu đang active)
- **Logic xu ly**:
  1. Gọi getStatus() -> so sánh với "active"
  2. Return boolean

## Luong du lieu (Data Flow)

### Tạo khuyến mãi:
```
1. User truy cập /admin/promotions/create
2. Controller hiển thị form (GET) với danh sách loại phòng
3. User nhập dữ liệu: mã code, loại phòng, % chiết khấu, ngày bắt đầu, kết thúc
4. User submit form (POST)
5. Controller parse dữ liệu từ request
6. AdminPromotionService validate (% hợp lệ, date range hợp lệ, room type tồn tại)
7. Nếu valid: PromotionRepository.insert() -> insert vào DB
8. Return ID mới, redirect đến list page with success message
9. Nếu invalid: return error message, display form lại
```

### Xem danh sách & áp dụng khuyến mãi:
```
1. /admin/promotions (list)
   - Lấy ALL promotions + join với RoomType để hiển thị type_name
   - View hiển thị mã, loại phòng, %, ngày bắt đầu/kết thúc, trạng thái

2. /common/rooms (customer view)
   - RoomController gọi PromotionService.getActivePromotion(typeId)
   - Repository query: WHERE type_id = ? AND GETDATE() BETWEEN start_date AND end_date
   - Nếu có promotion -> hiển thị badge "Giảm X%"

3. /booking (tính giá)
   - BookingService gọi PromotionService.getActivePromotion(typeId)
   - Nếu có promotion -> tính discount = base_price * (discountPercent / 100)
   - final_price = base_price - discount
```

### Cập nhật khuyến mãi:
```
1. User truy cập /admin/promotions/edit?id=X
2. Controller lấy promotion hiện có, hiển thị form với dữ liệu cũ
3. User thay đổi thông tin
4. Controller validate -> AdminPromotionService.updatePromotion()
5. PromotionRepository.update() cập nhật DB
6. Redirect đến list with success message
```

### Xóa khuyến mãi:
```
1. User click delete button trên list
2. Controller nhận POST /admin/promotions/delete?id=X
3. AdminPromotionService.deletePromotion() -> Repository.delete()
4. Khuyến mãi bị xóa khỏi DB
5. Redirect đến list with success message
```

## Bao mat & Phan quyen

- Chỉ admin có thể tạo/cập nhật/xóa khuyến mãi (bảo vệ bằng AdminAuthFilter)
- Tất cả request đều đi qua filter kiểm tra session admin
- Không có xác thực API token, chỉ dựa vào HTTP session
- Khuyến mãi không yêu cầu authorization khác (một admin có quyền quản lý tất cả promotions)
- Không có encryption dữ liệu khuyến mãi (không sensitive)
- SQL queries sử dụng PreparedStatement (tránh SQL injection)

## Lien ket doi tuong & imports

- AdminPromotionService: sử dụng PromotionRepository, RoomTypeRepository
- PromotionService: sử dụng PromotionRepository (shared service cho customer-facing)
- BookingService: gọi PromotionService.getActivePromotion() để lấy khuyến mãi khi tính giá
- RoomController: gọi PromotionService để lấy khuyến mãi hiển thị badge

## Cac bien va constants

- discountPercent: BigDecimal, range [0.01 - 100.00]
- promoCode: String, uppercase, được trim
- status values: "upcoming" (trước startDate), "active" (trong khoảng), "expired" (sau endDate)
- Không có constant class riêng cho promotion

## Summary

Tính năng quản lý khuyến mãi là một công cụ quan trọng cho việc quảng cáo và khuyến khích khách hàng đặt phòng. Quá trình luôn tuân theo kiến trúc MVC: Controller -> Service -> Repository -> Database. Validation diễn ra ở tầng Service, đảm bảo tính toàn vẹn dữ liệu. Khuyến mãi được tích hợp vào hệ thống hiển thị phòng và tính giá booking một cách seamless.
