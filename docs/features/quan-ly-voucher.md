# Quan ly Voucher

## Tong quan nghiep vu

Tính năng quản lý voucher cho phép quản trị viên tạo và quản lý các mã giảm giá (voucher code) mà khách hàng có thể sử dụng khi đặt phòng hoặc thanh toán. Mỗi voucher có mã code duy nhất, số tiền giảm cố định (discount amount), giá trị đơn hàng tối thiểu để áp dụng (min order value), và trạng thái kích hoạt (active/inactive).

Khác với khuyến mãi (promotion) theo phần trăm và loại phòng, voucher là một công cụ marketing linh hoạt hơn với giảm giá cố định, áp dụng cho tất cả loại phòng (nếu điều kiện tối thiểu được đáp ứng).

## Kien truc & Code Flow

```
Request (GET/POST) -> AdminVoucherController
                   -> AdminVoucherService (validate & process)
                   -> VoucherRepository (data access)
                   -> Database (Voucher table)
```

### Luong goi dich vu chinh:
1. Danh sach voucher: GET /admin/vouchers -> Controller -> Service -> Repository -> JSP view
2. Tạo voucher: GET (form) + POST -> Controller -> Service -> Repository -> insert
3. Sửa voucher: GET (form) + POST -> Controller -> Service -> Repository -> update
4. Xóa voucher: POST -> Controller -> Service -> Repository -> delete
5. Kiểm tra voucher khi thanh toán: Payment/Booking service -> Repository.findByCode() -> apply discount

## Chi tiet tung ham

### AdminVoucherController

#### handleList(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Hiển thị danh sách tất cả voucher đã tạo
- **Input**: request, response
- **Output**: Danh sách Voucher được chuyển đến view list.jsp
- **Logic xu ly**:
  1. Gọi adminVoucherService.getAllVouchers() lấy tất cả voucher từ DB
  2. Kiểm tra parameter "success" để hiển thị thông báo (created/updated/deleted)
  3. Set attributes: activePage="vouchers", pageTitle="Quản lý Voucher"
  4. Forward request đến /WEB-INF/views/admin/vouchers/list.jsp
- **Xu ly loi**: Không có
- **Lien ket**: AdminVoucherService.getAllVouchers()

#### handleCreateForm(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Hiển thị form để tạo voucher mới
- **Input**: request, response
- **Output**: Form view (form.jsp) trong mode tạo
- **Logic xu ly**:
  1. Set attributes: isEdit=false, pageTitle="Thêm Voucher"
  2. Set activePage="vouchers"
  3. Forward đến form.jsp
- **Xu ly loi**: Không có
- **Lien ket**: Không gọi service nào

#### handleEditForm(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Hiển thị form sửa voucher hiện có
- **Input**: request (parameter "id" là ID voucher), response
- **Output**: Form view với dữ liệu voucher hiện tại
- **Logic xu ly**:
  1. Parse parameter "id" thành int
  2. Gọi adminVoucherService.getVoucherById(id) lấy voucher
  3. Nếu voucher == null -> redirect đến /admin/vouchers?error=notfound
  4. Set voucher object, isEdit=true vào attributes
  5. Set pageTitle="Sửa Voucher"
  6. Forward đến form.jsp
- **Xu ly loi**: Nếu voucher không tìm thấy, redirect với error
- **Lien ket**: AdminVoucherService.getVoucherById()

#### handleCreate(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Xử lý yêu cầu tạo voucher mới
- **Input**: request (parameters: code, discountAmount, minOrderValue, isActive), response
- **Output**: Redirect đến /admin/vouchers?success=created hoặc forward form với error
- **Logic xu ly**:
  1. Parse parameter "code" thành String
  2. Parse "discountAmount" thành BigDecimal
  3. Parse "minOrderValue" thành BigDecimal
  4. Parse "isActive" - nếu checkbox được check -> isActive=true, ngược lại false
  5. Gọi adminVoucherService.createVoucher(code, discountAmount, minOrderValue, isActive)
  6. Nếu result > 0 -> redirect với success=created
  7. Nếu result <= 0 -> set error message, forward lại form
- **Xu ly loi**: Không có explicit error handling, nhưng service trả về 0 nếu fail
- **Lien ket**: AdminVoucherService.createVoucher()

#### handleEdit(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Xử lý yêu cầu cập nhật voucher
- **Input**: request (parameters: id, code, discountAmount, minOrderValue, isActive), response
- **Output**: Redirect đến /admin/vouchers?success=updated hoặc forward form với error
- **Logic xu ly**:
  1. Parse id thành int
  2. Parse code, discountAmount, minOrderValue như createForm
  3. Parse isActive từ checkbox
  4. Gọi adminVoucherService.updateVoucher(id, code, discountAmount, minOrderValue, isActive)
  5. Nếu success=true -> redirect with success=updated
  6. Nếu success=false -> set error, call handleEditForm() để display form lại
- **Xu ly loi**: Nếu update fail, forward form lại với error message
- **Lien ket**: AdminVoucherService.updateVoucher(), handleEditForm()

#### handleDelete(HttpServletRequest, HttpServletResponse)
- **Muc dich**: Xử lý yêu cầu xóa voucher
- **Input**: request (parameter "id"), response
- **Output**: Redirect đến /admin/vouchers?success=deleted
- **Logic xu ly**:
  1. Parse parameter "id" thành int
  2. Gọi adminVoucherService.deleteVoucher(id)
  3. Redirect đến /admin/vouchers?success=deleted (luôn thành công)
- **Xu ly loi**: Không có
- **Lien ket**: AdminVoucherService.deleteVoucher()

### AdminVoucherService

#### getAllVouchers()
- **Muc dich**: Lấy danh sách tất cả voucher từ DB
- **Input**: Không có
- **Output**: List<Voucher> sắp xếp theo ID giảm dần
- **Logic xu ly**:
  1. Gọi voucherRepository.findAll()
  2. Return danh sách
- **Xu ly loi**: Không có
- **Lien ket**: VoucherRepository.findAll()

#### getVoucherById(int voucherId)
- **Muc dich**: Lấy một voucher theo ID
- **Input**: voucherId
- **Output**: Voucher object hoặc null nếu không tìm thấy
- **Logic xu ly**:
  1. Gọi voucherRepository.findById(voucherId)
  2. Return kết quả
- **Xu ly loi**: Return null
- **Lien ket**: VoucherRepository.findById()

#### createVoucher(String code, BigDecimal discountAmount, BigDecimal minOrderValue, boolean isActive)
- **Muc dich**: Tạo voucher mới
- **Input**:
  - code: Mã voucher (sẽ convert thành UPPERCASE)
  - discountAmount: Số tiền giảm (ví dụ: 50000 = 50K VND)
  - minOrderValue: Giá trị đơn hàng tối thiểu để áp dụng voucher
  - isActive: Trạng thái kích hoạt
- **Output**: ID voucher mới (> 0) hoặc 0 nếu fail
- **Logic xu ly**:
  1. Tạo Voucher object mới
  2. Set code (uppercase)
  3. Set discountAmount, minOrderValue, isActive
  4. Gọi voucherRepository.insert(voucher)
  5. Return ID mới từ DB
- **Xu ly loi**: Không có validation, trả về giá trị từ insert
- **Lien ket**: VoucherRepository.insert()

#### updateVoucher(int voucherId, String code, BigDecimal discountAmount, BigDecimal minOrderValue, boolean isActive)
- **Muc dich**: Cập nhật voucher hiện có
- **Input**: voucherId + các field cần update
- **Output**: true nếu update thành công, false nếu fail
- **Logic xu ly**:
  1. Gọi voucherRepository.findById(voucherId) lấy voucher hiện có
  2. Nếu voucher == null -> return false
  3. Set các field mới: code (uppercase), discountAmount, minOrderValue, isActive
  4. Gọi voucherRepository.update(voucher)
  5. Return (rows affected > 0)
- **Xu ly loi**: Return false nếu voucher không tìm thấy
- **Lien ket**: VoucherRepository.findById(), update()

#### deleteVoucher(int voucherId)
- **Muc dich**: Xóa voucher
- **Input**: voucherId
- **Output**: true nếu xóa thành công, false nếu fail
- **Logic xu ly**:
  1. Gọi voucherRepository.delete(voucherId)
  2. Return (rows deleted > 0)
- **Xu ly loi**: Không có
- **Lien ket**: VoucherRepository.delete()

### VoucherRepository

#### findByCode(String code)
- **Muc dich**: Tìm voucher theo code (được sử dụng khi khách áp dụng voucher)
- **Input**: code (mã voucher)
- **Output**: Voucher object hoặc null
- **SQL**:
  ```sql
  SELECT * FROM Voucher
  WHERE code = ? AND is_active = 1
  ```
- **Logic**: Chỉ tìm voucher đang active, không tìm voucher đã disable
- **Lien ket**: queryOne()

#### findById(int voucherId)
- **Muc dich**: Tìm voucher theo ID
- **Input**: voucherId
- **Output**: Voucher object hoặc null
- **SQL**:
  ```sql
  SELECT * FROM Voucher WHERE voucher_id = ?
  ```
- **Lien ket**: queryOne()

#### findAll()
- **Muc dich**: Lấy tất cả voucher, sắp xếp mới nhất trước
- **Input**: Không có
- **Output**: List<Voucher>
- **SQL**:
  ```sql
  SELECT * FROM Voucher ORDER BY voucher_id DESC
  ```
- **Lien ket**: queryList()

#### insert(Voucher voucher)
- **Muc dich**: Tạo voucher mới
- **Input**: Voucher object
- **Output**: ID voucher mới
- **SQL**:
  ```sql
  INSERT INTO Voucher (code, discount_amount, min_order_value, is_active)
  VALUES (?, ?, ?, ?)
  ```
- **Logic**: is_active được convert từ boolean (true=1, false=0)
- **Lien ket**: executeInsert()

#### update(Voucher voucher)
- **Muc dich**: Cập nhật voucher
- **Input**: Voucher object (có voucherId)
- **Output**: Số rows affected
- **SQL**:
  ```sql
  UPDATE Voucher
  SET code = ?, discount_amount = ?, min_order_value = ?, is_active = ?
  WHERE voucher_id = ?
  ```
- **Lien ket**: executeUpdate()

#### delete(int voucherId)
- **Muc dich**: Xóa voucher
- **Input**: voucherId
- **Output**: Số rows deleted
- **SQL**:
  ```sql
  DELETE FROM Voucher WHERE voucher_id = ?
  ```
- **Lien ket**: executeUpdate()

### Voucher Entity

Các getter/setter cho các field:
- voucherId: int
- code: String (uppercase)
- discountAmount: BigDecimal (số tiền giảm cố định)
- minOrderValue: BigDecimal (tổng tiền tối thiểu để dùng voucher)
- isActive: boolean (true = active, false = inactive/disabled)

#### mapRow(ResultSet rs)
- **Muc dich**: Convert một dòng ResultSet thành Voucher object
- **Input**: ResultSet
- **Output**: Voucher object
- **Logic xu ly**:
  1. Extract voucher_id, code, discount_amount, min_order_value
  2. Extract is_active (từ DB integer 0/1 convert thành boolean)
  3. Return Voucher object

## Luong du lieu (Data Flow)

### Tạo voucher:
```
1. Admin truy cập /admin/vouchers/create
2. Controller forward đến form.jsp (isEdit=false)
3. Admin nhập: mã code, số tiền giảm, min order value, active checkbox
4. Submit form (POST)
5. Controller parse dữ liệu
6. AdminVoucherService.createVoucher():
   - Tạo Voucher object
   - Convert code thành UPPERCASE
   - Repository.insert() -> lưu vào DB
7. Return ID mới (> 0)
8. Controller redirect đến /admin/vouchers?success=created
9. handleList() hiển thị danh sách update với voucher mới + success message
```

### Sử dụng voucher (khách hàng apply):
```
1. Khách hàng nhập mã voucher khi đặt phòng/thanh toán
2. BookingService hoặc PaymentService gọi:
   VoucherRepository.findByCode(code)
3. Repository query:
   SELECT * FROM Voucher
   WHERE code = ? AND is_active = 1
4. Nếu tìm thấy:
   - Kiểm tra total price >= minOrderValue
   - Nếu yes: áp dụng discount = discountAmount
   - final_price = total_price - discountAmount
   - Nếu no: return error "Giá trị đơn hàng không đủ"
5. Nếu không tìm thấy:
   - Return error "Voucher không hợp lệ hoặc đã hết hạn"
6. Cập nhật giá vào Payment/Invoice
```

### Cập nhật voucher:
```
1. Admin truy cập /admin/vouchers/edit?id=X
2. Controller gọi getVoucherById(X) -> hiển thị form với dữ liệu cũ
3. Admin thay đổi thông tin (code, discount, min value, active status)
4. POST request
5. Controller parse, gọi updateVoucher()
6. Repository.update() cập nhật DB
7. Redirect với success message
```

### Xóa voucher:
```
1. Admin click delete trên list
2. POST /admin/vouchers/delete?id=X
3. Controller gọi deleteVoucher(X)
4. Repository.delete() xóa khỏi DB
5. Redirect với success message
6. Voucher không còn khả dụng
```

### Vô hiệu hóa voucher (không xóa):
```
- Thay vì xóa, admin có thể set isActive=false
- Voucher vẫn tồn tại trong DB (giữ lại lịch sử)
- Khi khách apply: findByCode() WHERE is_active = 1
- Sẽ không tìm thấy -> return error
```

## Bao mat & Phan quyen

- Chỉ admin có quyền tạo/cập nhật/xóa voucher (AdminAuthFilter)
- Khách hàng chỉ có quyền áp dụng voucher (không tạo/edit/delete)
- Code voucher được convert uppercase để tránh case-sensitivity issues
- Discount amount phải > 0 (không validate trong code hiện tại, nên DB constraints nên enforce)
- Min order value >= 0 (có thể là 0 = không có giới hạn)
- SQL queries sử dụng PreparedStatement (tránh SQL injection)
- Voucher không yêu cầu authentication khác ngoài admin role

## Lien ket doi tuong

- AdminVoucherService: sử dụng VoucherRepository
- BookingService / PaymentService: gọi VoucherRepository.findByCode() để verify & apply discount
- Voucher có thể được liên kết với Payment/Invoice table (tùy thiết kế DB)

## Cac bien va constants

- code: String, uppercase, unique (tùy DB constraints)
- discountAmount: BigDecimal, range >= 0
- minOrderValue: BigDecimal, range >= 0 (0 = không có điều kiện)
- isActive: boolean (true = có thể dùng, false = disabled)

## Summary

Tính năng quản lý voucher cung cấp một công cụ marketing mạnh mẽ với giảm giá cố định. Khác với promotion (phần trăm, theo loại phòng), voucher linh hoạt hơn, áp dụng toàn bộ và có điều kiện tối thiểu. Kiến trúc MVC đảm bảo tính tách biệt: Controller -> Service -> Repository -> Database. Voucher được sử dụng ở tầng thanh toán (booking/payment) để tính giá cuối cùng sau chiết khấu.
