# MINI-PROJECT SHORT TECHNICAL REPORT
**Course:** Cross-Platform Mobile App Development (VKU)  
**Mini-Project Title:** ReceiptMate — On-Device OCR Receipt Scanner & Smart Expense Tracker  
**Team / Student Name:** Ngô Khắc Cường  
**Submission Date:** 10/10/2026  

---

## 1. GENERAL INFORMATION & DELIVERABLE LINKS
* **Team Members:**
  1. Ngô Khắc Cường — Student ID: [22ITxxx / 23ITxxx] — Role: Full-Stack Mobile Engineer (Architecture, Riverpod State, On-Device ML Kit OCR, CustomPainter Canvas, SQLite Persistence) — Contribution: [100%]
* **🔗 Live Demo / APK Release URL:** [https://github.com/cuongnk2005/ReceiptMate/releases](https://github.com/cuongnk2005/ReceiptMate) *(Pre-built binary: `build/app/outputs/flutter-apk/app-debug.apk`)*
* **💻 GitHub Repository:** [https://github.com/cuongnk2005/ReceiptMate](https://github.com/cuongnk2005/ReceiptMate)
* **🎥 Video Demo (Optional):** [https://youtu.be/xxx]

---

## 2. FEATURE IMPLEMENTATION CHECKLIST

| # | Required Feature | Status | Implementation Details & Acceptance Level |
|:---:|---|:---:|---|
| 1 | **On-Device Offline OCR & Heuristic Parsing** | ✅ Complete | Tích hợp Google ML Kit Text Recognition (`google_mlkit_text_recognition`) chạy 100% offline trên thiết bị. Trích xuất chính xác tên cửa hàng (Merchant), tổng tiền VND (Regex hỗ trợ `150.000`, `150,000`, `150k`, `đ`, `VND`) và ngày giờ giao dịch (`dd/MM/yyyy`). |
| 2 | **Review & Verification Screen** | ✅ Complete | Màn hình đối chiếu trực quan ảnh hóa đơn gốc (hỗ trợ InteractiveViewer pinch-to-zoom) với các trường dữ liệu bóc tách được; Form validation nghiêm ngặt (kiểm tra rỗng, số tiền dương) trước khi commit vào CSDL. |
| 3 | **Local SQLite Persistence & Image Storage** | ✅ Complete | Sử dụng `sqflite` với cấu trúc ACID transactions; Đánh chỉ mục B-Tree Index cho `transaction_date` và `category` nhằm tối ưu tốc độ lọc thống kê; Quản lý lưu trữ & xóa an toàn file ảnh companion trong bộ nhớ ứng dụng (`path_provider`). |
| 4 | **Zero-Dependency Canvas Charts (CustomPainter)** | ✅ Complete | Tự thiết kế và dựng hoạt ảnh cho Biểu đồ Donut (tỷ lệ danh mục) và Biểu đồ Cột tuần (7 ngày gần nhất) bằng Flutter Canvas `CustomPainter` + `AnimationController` mượt mà (60fps), không phụ thuộc bất kỳ thư viện chart bên thứ 3 nào. |
| 5 | **Reactive State Management (Riverpod 2)** | ✅ Complete | Áp dụng Clean State Architecture với `StateNotifierProvider` / `NotifierProvider`; Quản lý luồng dữ liệu 1 chiều (Unidirectional Data Flow), compile-safe, tự động invalidate và tính toán thống kê chi tiêu tức thời. |
| 6 | **Material 3 Design & Responsive Viewport** | ✅ Complete | Tuân thủ 100% chuẩn Material 3; Palette màu VKU Navy (`0xFF2C4570`); Hỗ trợ Dark Mode / Light Mode hoàn chỉnh; Xử lý triệt để các lỗi RenderFlex Overflow trên các tỉ lệ màn hình thực tế. |

---

## 3. TECHNICAL ARCHITECTURE & PROJECT STRUCTURE

### 3.1. Directory Structure (Clean Layered Architecture)
Ứng dụng được tổ chức theo mô hình phân tầng nghiêm ngặt nhằm đảm bảo tính phân tách trách nhiệm (Separation of Concerns) và dễ mở rộng:

```text
lib/
├── core/                              # Nền tảng dùng chung toàn ứng dụng
│   ├── constants/                     # Bảng màu hệ thống (app_colors), hằng số danh mục
│   ├── theme/                         # Cấu hình Material 3 ThemeData (Light & Dark)
│   └── utils/                         # Tiện ích định dạng tiền VND, ngày tháng, chuẩn hóa chuỗi
├── models/                            # Định nghĩa Data Entities & DTOs
│   ├── expense_item.dart              # Model thực thể chi tiêu (toMap, fromMap cho SQLite)
│   ├── parsed_receipt.dart            # DTO kết quả bóc tách từ OCR
│   └── category_expense.dart          # DTO tổng hợp số liệu cho biểu đồ Donut
├── services/                          # Lớp xử lý dịch vụ bên ngoài (Infrastructure)
│   ├── database_service.dart          # Quản lý kết nối SQLite, migrations, ACID CRUD
│   ├── ocr_service.dart               # Tương tác On-Device Google ML Kit
│   ├── receipt_parser.dart            # Thuật toán Regex Heuristics bóc tách hóa đơn VN
│   └── storage_service.dart           # Quản lý lưu/xóa file ảnh vào Application Documents
├── state/                             # Lớp quản lý trạng thái (State Management)
│   ├── expense_notifier.dart          # Riverpod AsyncNotifier thực hiện CRUD & sync
│   ├── expense_providers.dart         # Providers tổng hợp số liệu tuần/tháng, lọc danh mục
│   └── theme_provider.dart            # Provider chuyển đổi Light/Dark mode
├── widgets/                           # Reusable UI Widgets
│   ├── cards/                         # ExpenseSummaryCard, ExpenseItemTile
│   ├── charts/                        # AnimatedDonutChart, WeeklyBarChart & CustomPainters
│   └── common/                        # CustomTextField, EmptyStateView, ImageViewer
├── screens/                           # Màn hình chức năng chính
│   ├── dashboard/                     # DashboardScreen (Biểu đồ tổng quan & giao dịch gần đây)
│   ├── scan/                          # OcrScanScreen (Chụp/chọn ảnh, quét OCR)
│   ├── review/                        # ReviewScreen (Xác nhận & chỉnh sửa thông tin)
│   ├── expense/                       # ExpenseListScreen, ExpenseDetailScreen
│   └── main_navigation_screen.dart    # Khung điều hướng chính (Material 3 NavigationBar)
└── main.dart                          # Điểm khởi chạy ứng dụng & ProviderScope
```

### 3.2. State Management & Data Processing Pipeline
Hệ thống vận hành theo quy trình khép kín:
1. **Input:** Người dùng chụp ảnh hoặc chọn ảnh hóa đơn từ thư viện máy.
2. **On-Device OCR:** `OcrService` gọi `TextRecognizer` nhận diện văn bản hoàn toàn ngoại tuyến.
3. **Regex Heuristics:** `ReceiptParser` quét dòng tổng tiền thông qua bộ từ khóa đa ngữ cảnh (`Tổng cộng`, `Thanh toán`, `Total`, `Khách phải trả`), chuẩn hóa định dạng số (`150k` $\rightarrow 150000$, `150.000` $\rightarrow 150000$), nhận dạng ngày tháng và tên thương hiệu.
4. **Verification Step:** Dữ liệu được đưa vào `ReviewScreen`. Người dùng trực tiếp đối chiếu ảnh gốc (pinch-to-zoom) và bổ sung danh mục, chỉnh sửa nếu cần.
5. **Persistence & UI Reaction:** Khi bấm Lưu, `DatabaseService` ghi bản ghi vào SQLite (`receipt_mate.db`). `ExpenseListNotifier` kích hoạt cập nhật trạng thái, tự động refresh Dashboard và kích hoạt animation vẽ lại của biểu đồ Donut & Bar chart.

### 3.3. Exception Handling & Fail-Safe Strategy
- **OCR Fail-Safe:** Nếu hình ảnh mờ hoặc không nhận diện được số tiền, hệ thống không tự ý điền bừa mà trả về trường trống và gợi ý người dùng nhập tay trên màn hình Review.
- **SQLite ACID Transactions:** Mọi thao tác thêm/xóa đều bọc trong giao dịch (transaction); nếu lưu ảnh thất bại, bản ghi CSDL được rollback tự động.
- **Memory Safety:** Các controller nặng (`AnimationController`, `TextEditingController`, `FocusNode`) đều được gọi `dispose()` đúng chu kỳ vòng đời của widget để tránh rò rỉ bộ nhớ (memory leaks).

---

## 4. EMPIRICAL EVIDENCE & SCREENSHOTS

### 4.1. Màn hình Dashboard & Trực quan hóa Biểu đồ (CustomPainter)
*Biểu đồ Donut phân bố tỷ lệ chi tiêu theo danh mục được vẽ bằng Canvas CustomPainter cùng hiệu ứng xoay góc mượt mà. Danh sách các giao dịch gần đây hiển thị chuẩn xác, chống tràn màn hình (RenderFlex Overflow-safe).*

```text
[ Screenshot 1: Dashboard Overview với Donut Chart & Giao dịch gần đây trên thiết bị thật ]
```

### 4.2. Màn hình Quét OCR & Màn hình Review / Verification
*Giao diện quét hóa đơn chụp ảnh trực tiếp và màn hình xác nhận thông tin bóc tách: đối chiếu ảnh chụp phóng to, tự động điền tên cửa hàng, số tiền VND và ngày giao dịch.*

```text
[ Screenshot 2: Màn hình ReviewScreen hiển thị ảnh hóa đơn và form kiểm tra dữ liệu ]
```

### 4.3. Màn hình Lịch sử Giao dịch & Thao tác Xóa (Dismissible)
*Danh sách chi tiêu phân nhóm theo thời gian, hỗ trợ vuốt để xóa (Swipe-to-delete) có thông báo Snackbar hoàn tác (Undo).*

```text
[ Screenshot 3: Expense List Screen & Chi tiết giao dịch (ExpenseDetailScreen) ]
```

### 4.4. Hỗ trợ Giao diện Tối (Material 3 Dark Mode)
*Giao diện tự động thích ứng với Dark Theme của hệ điều hành, đảm bảo độ tương phản màu chuẩn WCAG và tiết kiệm pin trên màn hình AMOLED.*

```text
[ Screenshot 4: ReceiptMate hoạt động ở chế độ Dark Mode ]
```

---

## 5. TECHNICAL CHALLENGES & RESOLUTIONS

### 5.1. Thách thức 1: Chuẩn hóa bóc tách số tiền VND đa dạng trên hóa đơn in nhiệt
* **Vấn đề:** Hóa đơn tại Việt Nam có định dạng số tiền rất phong phú và dễ nhầm lẫn: dùng dấu chấm (`150.000 đ`), dấu phẩy (`150,000`), viết tắt (`150k`), hoặc bị OCR nhận diện nhầm số thứ tự món, số lượng, hoặc số bàn thành tổng tiền.
* **Giải pháp:** Xây dựng thuật toán phân tích 2 lớp (Two-Pass Heuristic):
  1. *Lớp 1 (Contextual Anchor):* Quét tìm dòng chứa các từ khóa tổng kết (`tổng cộng`, `thanh toán`, `khách phải trả`, `total`). Chỉ trích xuất số tiền nằm ngay sau hoặc cùng hàng với từ khóa.
  2. *Lớp 2 (Normalization & Sanity Filter):* Chuẩn hóa hậu tố `k` nhân 1.000, loại bỏ ký tự tiền tệ (`đ`, `VND`), loại trừ các số vô lý ($< 1.000$ VNĐ). Nếu không tìm thấy từ khóa xác đáng, hệ thống tìm giá trị lớn nhất trong các dòng có cấu trúc tiền tệ, hoặc trả về `null` để người dùng xác nhận thủ công (nguyên tắc Fail-Safe).

### 5.2. Thách thức 2: Lỗi tràn giao diện (RenderFlex Overflow) trên danh sách giao dịch điện thoại thật
* **Vấn đề:** Khi chạy app trên thiết bị thực tế (`2312DRA50G`), danh sách giao dịch xuất hiện lỗi sọc vàng đen `A RenderFlex overflowed by 91 pixels on the right` do phần hiển thị ghi chú (`Row(children: [Text(Date), Text(Note)])`) không giới hạn độ rộng khi ghi chú hóa đơn quá dài.
* **Giải pháp:** Tái cấu trúc [expense_item_tile.dart](file:///d:/code/danentang/ReceiptMate/lib/widgets/cards/expense_item_tile.dart) bằng cách bọc `Text(Note)` vào widget `Expanded` kết hợp thuộc tính `maxLines: 1` và `TextOverflow.ellipsis`. Nhờ đó chuỗi văn bản tự động co giãn theo phần không gian khả dụng còn lại của màn hình và thu gọn bằng dấu `...` một cách chuyên nghiệp.

### 5.3. Thách thức 3: Xung đột cấu hình Gradle & Kotlin Incremental Compiler trên môi trường Windows đa ổ đĩa
* **Vấn đề:** Khi biên dịch Android, Kotlin ném ngoại lệ `java.lang.IllegalArgumentException: this and base files have different roots` do mã nguồn nằm ở ổ `D:` còn bộ nhớ cache Pub nằm ở ổ `C:`. Đồng thời các gói thư viện AndroidX mới nhất yêu cầu `compileSdk >= 36` trong khi plugin con (`google_mlkit_commons`) mặc định chỉ khai báo `compileSdk 29`.
* **Giải pháp:** 
  1. Cấu hình `kotlin.incremental=false` trong [android/gradle.properties](file:///d:/code/danentang/ReceiptMate/android/gradle.properties) để tắt bộ nhớ đệm đa ổ đĩa của Kotlin.
  2. Thêm script can thiệp `subprojects` trong [android/build.gradle.kts](file:///d:/code/danentang/ReceiptMate/android/build.gradle.kts) tự động ép `compileSdk = 36` cho toàn bộ các plugin phụ thuộc trước khi evaluate dự án. Quá trình build APK hoàn tất chỉ trong 10.5 giây.
