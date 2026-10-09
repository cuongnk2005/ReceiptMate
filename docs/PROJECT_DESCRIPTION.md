# TÀI LIỆU MÔ TẢ DỰ ÁN (PROJECT SPECIFICATION)
## RECEIPT OCR & EXPENSE TRACKER (RECEIPTMATE)

---

### 1. Tổng quan dự án

- **Tên dự án:** ReceiptMate — Receipt OCR & Expense Tracker
- **Nền tảng mục tiêu:** Android (Flutter & Dart)
- **Mục tiêu:** Xây dựng ứng dụng di động hỗ trợ người dùng (sinh viên, cá nhân, thủ quỹ câu lạc bộ) tự động hóa quy trình ghi nhận và theo dõi các khoản chi tiêu từ hóa đơn/biên lai mua hàng.
- **Điểm nổi bật:**
  - **On-Device Offline OCR:** Nhận diện ký tự trực tiếp trên thiết bị bằng Google ML Kit, bảo đảm quyền riêng tư và tốc độ xử lý tức thì, không phụ thuộc kết nối Internet.
  - **Bộ phân tích Regex Heuristics cho tiền tệ Việt Nam:** Chuẩn hóa các định dạng tiền phức tạp (dấu chấm, dấu phẩy, ký hiệu đ/VNĐ/k).
  - **Màn hình Review & Verification bắt buộc:** Không tự động ghi nhận mù quáng; cung cấp giao diện trực quan cho người dùng đối chiếu ảnh gốc và chỉnh sửa dữ liệu trước khi commit.
  - **Lưu trữ SQLite cục bộ:** Quản lý dữ liệu chi tiêu bền vững với đầy đủ tính năng CRUD.
  - **Trực quan hóa số liệu bằng CustomPainter:** Tự vẽ biểu đồ Donut phân loại chi tiêu và biểu đồ cột theo tuần có hoạt ảnh (AnimationController), tuân thủ 100% chuẩn Material 3.

---

### 2. Công nghệ và Thư viện cốt lõi

| Công nghệ / Gói thư viện | Phiên bản | Vai trò trong hệ thống |
| :--- | :--- | :--- |
| **Flutter & Dart 3** | Flutter 3.24+ / Dart 3 | Nền tảng phát triển ứng dụng di động đa nền tảng với Impeller engine và Sound Null Safety. |
| **google_mlkit_text_recognition** | `^0.11.0` | Nhận diện văn bản trên ảnh hóa đơn offline thông qua Google On-Device ML Kit. |
| **image_picker** | `^1.0.7` | Chụp ảnh hóa đơn từ camera hoặc chọn ảnh từ thư viện thiết bị. |
| **sqflite** & **path** | `^2.3.2` / `^1.9.0` | Hệ quản trị cơ sở dữ liệu quan hệ SQLite cục bộ trên thiết bị, thực thi CRUD. |
| **path_provider** | `^2.1.2` | Quản lý đường dẫn thư mục lưu trữ ảnh hóa đơn lâu dài trong bộ nhớ ứng dụng. |
| **flutter_riverpod** | `^2.5.1` | Quản lý trạng thái ứng dụng theo mô hình Compile-Safe, Reactive State với Notifier. |
| **intl** | `^0.19.0` | Định dạng tiền tệ tiếng Việt (`###.### đ`) và ngày giờ chuẩn bản địa (`dd/MM/yyyy`). |
| **Material 3 Design** | Built-in | Hệ thống giao diện hiện đại, bảng màu ColorScheme từ Seed Color VKU Navy (`0xFF2C4570`), hỗ trợ Light/Dark mode. |
| **CustomPainter + Animation** | Built-in | Tự vẽ đồ thị trực quan (Donut chart & Bar chart) không dùng thư viện biểu đồ bên thứ 3. |

---

### 3. Quy trình hoạt động của hệ thống (Pipeline)

Quy trình xử lý hóa đơn trải qua 6 bước khép kín và an toàn:

```
┌─────────────────┐       ┌────────────────────────┐       ┌─────────────────────────┐
│ 1. Chọn / Chụp  │ ────► │ 2. Nhận diện văn bản   │ ────► │ 3. Bóc tách Heuristics  │
│    ảnh hóa đơn  │       │    Google ML Kit (OCR) │       │    (ReceiptParser)      │
└─────────────────┘       └────────────────────────┘       └────────────┬────────────┘
                                                                        │
                                                                        ▼
┌─────────────────┐       ┌────────────────────────┐       ┌─────────────────────────┐
│ 6. Cập nhật     │ ◄──── │ 5. Lưu trữ cục bộ      │ ◄──── │ 4. Kiểm tra & Chỉnh sửa │
│    UI & Biểu đồ │       │    SQLite Database     │       │    Review & Verify      │
└─────────────────┘       └────────────────────────┘       └─────────────────────────┘
```

1. **Chọn ảnh:** Người dùng chụp ảnh trực tiếp từ camera hoặc chọn ảnh hóa đơn có sẵn từ máy. Ảnh được nén tối ưu (max width/height: 1200x1600, quality: 85%) và lưu trữ vào thư mục ứng dụng.
2. **Nhận diện văn bản:** Google ML Kit xử lý ảnh trên máy, trả về các khối văn bản (Text Blocks, Lines, Elements) cùng vị trí bounding box.
3. **Bóc tách Heuristics (ReceiptParser):**
   - Phân tích từng dòng chữ để tìm từ khóa tổng tiền (`Tổng cộng`, `Thanh toán`, `Total`, `Khách phải trả`).
   - Dùng biểu thức chính quy (Regex) trích xuất số tiền, loại bỏ dấu chấm/phẩy phân cách hàng nghìn và chuẩn hóa về số nguyên VND.
   - Tìm kiếm mẫu ngày tháng giao dịch (`dd/MM/yyyy`, `dd-MM-yyyy`, `yyyy-MM-dd`).
   - Dự đoán tên đơn vị bán lẻ (Merchant) từ các dòng đầu tiên của hóa đơn hoặc từ danh mục chuỗi cửa hàng phổ biến.
4. **Màn hình Review & Verification:**
   - Người dùng trực tiếp đối chiếu ảnh hóa đơn với các ô dữ liệu đã trích xuất.
   - Người dùng có thể sửa đổi bất kỳ thông tin nào bị nhận diện sai hoặc bổ sung thông tin thiếu.
   - Chọn danh mục chi tiêu (Ăn uống, Mua sắm, Di chuyển, Hóa đơn/Tiện ích, Khác) và nhập ghi chú.
   - Form Validator kiểm tra: Tên cửa hàng không được rỗng, số tiền phải là số dương hợp lệ.
5. **Ghi vào SQLite:** Dữ liệu sau khi xác nhận được commit vào database kèm đường dẫn ảnh.
6. **Đồng bộ trạng thái:** Riverpod kích hoạt cập nhật danh sách và màn hình Dashboard. Biểu đồ Donut và Bar Chart chạy hoạt ảnh cập nhật số liệu mới nhất.

---

### 4. Thiết kế Cơ sở Dữ liệu (SQLite Database Schema)

Tên cơ sở dữ liệu: `receipt_mate.db`  
Bảng chính: `expenses`

| Cột | Kiểu dữ liệu SQLite | Ràng buộc | Ý nghĩa |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | `PRIMARY KEY` | Mã định danh duy nhất (UUID/Timestamp string) |
| `merchant_name` | `TEXT` | `NOT NULL` | Tên cửa hàng / đơn vị cung cấp dịch vụ |
| `total_amount` | `REAL` | `NOT NULL` | Tổng số tiền thanh toán (lưu số chuẩn VND, ví dụ 150000.0) |
| `transaction_date` | `TEXT` | `NOT NULL` | Ngày giờ giao dịch (chuẩn ISO-8601: `YYYY-MM-DDTHH:MM:SS`) |
| `category` | `TEXT` | `NOT NULL` | Phân loại chi tiêu (Food, Shopping, Transport, Utilities, Other) |
| `note` | `TEXT` | `NULLABLE` | Ghi chú thêm của người dùng |
| `receipt_image_path` | `TEXT` | `NULLABLE` | Đường dẫn tuyệt đối đến file ảnh hóa đơn lưu trong thiết bị |
| `created_at` | `TEXT` | `NOT NULL` | Thời gian tạo bản ghi |
| `updated_at` | `TEXT` | `NOT NULL` | Thời gian cập nhật gần nhất |

**Chỉ mục (Index) tối ưu hóa truy vấn:**
- `CREATE INDEX idx_expenses_date ON expenses(transaction_date);` (Tối ưu việc lọc báo cáo theo tuần/tháng).
- `CREATE INDEX idx_expenses_category ON expenses(category);` (Tối ưu tính tổng số liệu theo danh mục).

---

### 5. Chiến lược Regex & Chuẩn hóa tiền tệ Việt Nam (ReceiptParser)

#### 5.1. Quy tắc tìm kiếm dòng tổng tiền
```dart
final keywordPattern = RegExp(
  r'(tổng cộng|tong cong|thanh toán|thanh toan|tong tien|tổng tiền|khách phải trả|amount due|grand total|total|phải thu)',
  caseSensitive: false,
);
```

#### 5.2. Biểu thức Regex trích xuất định dạng số tiền VNĐ
Hóa đơn Việt Nam thường viết: `150.000`, `150,000`, `150000`, `150.000 đ`, `150,000 VND`, `150k`.
```dart
final numberPattern = RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:\.\d{2})?|\d+[kK])');
```

#### 5.3. Chuẩn hóa về giá trị số thực (VND Normalization)
1. Trường hợp có đuôi `k` / `K` (ví dụ `65k`): lấy số nhân với `1.000` -> `65000`.
2. Trường hợp định dạng phân cách hàng nghìn (`150.000` hoặc `150,000`): loại bỏ tất cả dấu chấm `.` và dấu phẩy `,` -> `150000`.
3. Kiểm tra tính hợp lệ: Số tiền chi tiêu thực tế thường $\ge 1.000$ VNĐ. Bỏ qua các số nhỏ vô lý do OCR nhận diện nhầm số thứ tự món hàng hoặc số bàn.
4. **Nguyên tắc an toàn (Fail-Safe):** Nếu không chắc chắn, trả về `null` để màn hình Review yêu cầu người dùng nhập tay; không tự ý điền số sai.

---

### 6. Cấu trúc thư mục mã nguồn (`lib/`)

```
lib/
├── core/                              # Nền tảng cốt lõi của ứng dụng
│   ├── constants/
│   │   ├── app_colors.dart            # Định nghĩa bảng màu, màu từng danh mục
│   │   └── app_constants.dart         # Enums danh mục, text constants
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData Material 3 (Light & Dark mode)
│   └── utils/
│       ├── currency_formatter.dart    # Hàm format và parse số tiền VND
│       └── date_formatter.dart        # Hàm chuyển đổi hiển thị ngày giờ
│
├── models/                            # Lớp dữ liệu (Data Models)
│   ├── expense_item.dart              # Entity giao dịch chi tiêu, toMap / fromMap
│   ├── parsed_receipt.dart            # Kết quả trích xuất từ OCR
│   └── category_expense.dart          # DTO tổng hợp số liệu cho biểu đồ
│
├── services/                          # Lớp dịch vụ và xử lý logic bên ngoài
│   ├── database_service.dart          # Khởi tạo SQLite, thực thi CRUD
│   ├── ocr_service.dart               # Tương tác với Google ML Kit
│   ├── receipt_parser.dart            # Thuật toán Regex Heuristics
│   └── storage_service.dart           # Quản lý lưu file ảnh hóa đơn vào local storage
│
├── state/                             # Quản lý trạng thái (Riverpod 2)
│   ├── expense_notifier.dart          # Quản lý danh sách chi tiêu và hành động CRUD
│   ├── expense_providers.dart         # Providers cung cấp dữ liệu thống kê, filter
│   └── theme_provider.dart            # Provider điều khiển chế độ Light / Dark
│
├── widgets/                           # Các widget tái sử dụng
│   ├── cards/
│   │   └── expense_summary_card.dart  # Card hiển thị giao dịch chuẩn Material 3
│   ├── charts/
│   │   ├── animated_donut_chart.dart  # Donut chart với AnimationController
│   │   ├── category_donut_painter.dart# CustomPainter vẽ các cung tròn tỷ lệ
│   │   ├── weekly_bar_chart.dart      # Biểu đồ cột 7 ngày gần nhất
│   │   └── weekly_bar_painter.dart    # CustomPainter vẽ cột và trục tọa độ
│   └── common/
│       ├── custom_text_field.dart     # TextFormField chuẩn hóa với validator
│       └── empty_state_view.dart      # Giao diện khi danh sách rỗng
│
├── screens/                           # Các màn hình chính của ứng dụng
│   ├── dashboard/
│   │   └── dashboard_screen.dart      # Thống kê, biểu đồ Donut & Bar chart
│   ├── scan/
│   │   └── ocr_scan_screen.dart       # Chụp / chọn ảnh hóa đơn và quét OCR
│   ├── review/
│   │   └── review_screen.dart         # Xác nhận & chỉnh sửa dữ liệu trước khi lưu
│   ├── expense/
│   │   ├── expense_list_screen.dart   # Danh sách toàn bộ chi tiêu (ListView.builder)
│   │   └── expense_detail_screen.dart # Chi tiết hóa đơn, xem ảnh gốc, chỉnh sửa/xóa
│   └── main_navigation_screen.dart    # Scaffold chính chứa NavigationBar M3
│
└── main.dart                          # Khởi tạo App, ProviderScope, nạp database
```

---

### 7. Lộ trình triển khai (Implementation Plan)

- **Giai đoạn 1 — Khung ứng dụng (App Shell & M3 Theme):** Khởi tạo dự án Flutter, khai báo dependencies, cấu hình Android permissions, xây dựng theme Material 3 Light/Dark và khung điều hướng.
- **Giai đoạn 2 — Dữ liệu & SQLite CRUD:** Xây dựng `ExpenseItem` model, `DatabaseService` với SQLite, `ExpenseNotifier` bằng Riverpod, giao diện danh sách chi tiêu và nhập tay thủ công.
- **Giai đoạn 3 — OCR & Màn hình Review/Verification:** Tích hợp `image_picker`, ML Kit Text Recognition, hoàn thiện bộ bóc tách `ReceiptParser` và màn hình `ReviewScreen` có form validation nghiêm ngặt.
- **Giai đoạn 4 — Dashboard & Biểu đồ CustomPainter:** Xây dựng thuật toán tổng hợp số liệu, tự vẽ biểu đồ Donut và Weekly Bar Chart bằng `CustomPainter` kèm hiệu ứng mượt mà.
- **Giai đoạn 5 — Hoàn thiện & Đóng gói:** Tinh chỉnh Dark Mode, xử lý rò rỉ bộ nhớ (dispose), kiểm thử toàn diện trên thiết bị Android, build APK release đã ký và hoàn tất báo cáo kỹ thuật.

---

### 8. Tiêu chuẩn bàn giao & Thang điểm Rubric (10 Điểm)

1. **On-Device OCR & Heuristics (3.5 điểm):** Chụp ảnh/chọn ảnh mượt, ML Kit nhận diện văn bản offline, Regex trích xuất chính xác Tên cửa hàng, Ngày, Tổng tiền VND.
2. **Custom Canvas Visualization (2.5 điểm):** Biểu đồ Donut phân loại và biểu đồ Bar Chart tuần được tự vẽ bằng `CustomPainter` và hoạt ảnh mượt mà, không dùng thư viện ngoài.
3. **State Management & Database (2.0 điểm):** Kiến trúc Riverpod 2 rõ ràng, thao tác SQLite CRUD bền vững, lưu trữ ảnh hóa đơn cục bộ.
4. **UI/UX Polish (1.0 điểm):** Giao diện Material 3, Dark mode, bố cục thích ứng không lỗi tràn màn hình, màn hình Review & Verification kiểm tra dữ liệu tiện lợi.
5. **Deliverables & Report (1.0 điểm):** File APK release chạy được trên Android, video demo thực tế 2–3 phút, GitHub repository sạch sẽ, báo cáo kỹ thuật 2–4 trang.
