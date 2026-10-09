# QUY TẮC PHÁT TRIỂN DỰ ÁN (PROJECT RULES & GUIDELINES)
## RECEIPT OCR & EXPENSE TRACKER (RECEIPTMATE)

Tài liệu này định nghĩa các quy chuẩn kiến trúc, lập trình, xử lý dữ liệu và thiết kế giao diện bắt buộc phải tuân thủ trong suốt quá trình phát triển dự án ReceiptMate.

---

### 1. Kiến trúc & Cấu trúc thư mục (Architecture Rules)

1. **Tuân thủ Clean Layered Architecture:**
   - **`lib/core/`**: Chứa hằng số (`constants`), theme Material 3 (`theme`), tiện ích định dạng (`utils`). Tuyệt đối không import các tầng bên trên (`screens`, `state`).
   - **`lib/models/`**: Chứa các thực thể dữ liệu (`ExpenseItem`, `ParsedReceipt`). Phải có đầy đủ `toMap()`, `fromMap()`, `copyWith()` và bất biến (`@immutable` / `final`).
   - **`lib/services/`**: Chứa logic gọi hệ thống, native, database và I/O (`DatabaseService`, `OcrService`, `ReceiptParser`, `StorageService`). Không chứa mã giao diện (UI) hay `BuildContext`.
   - **`lib/state/`**: Quản lý trạng thái bằng Riverpod 2 (`Notifier`, `NotifierProvider`, `FutureProvider`). Tách biệt hoàn toàn logic thay đổi dữ liệu khỏi UI widget.
   - **`lib/widgets/`**: Các widget độc lập, tái sử dụng (`ExpenseSummaryCard`, `CustomPainter` charts, form inputs).
   - **`lib/screens/`**: Các màn hình hoàn chỉnh (`DashboardScreen`, `OcrScanScreen`, `ReviewScreen`, `ExpenseListScreen`, `ExpenseDetailScreen`).
   - **`lib/main.dart`**: Điểm khởi động ứng dụng gọn gàng, bọc `ProviderScope`.

2. **Nguyên tắc phụ thuộc (Dependency Rule):**
   - Tầng UI (`screens`, `widgets`) chỉ giao tiếp với dữ liệu thông qua Riverpod State Providers hoặc gọi Controller.
   - Database và OCR Services không phụ thuộc vào `BuildContext`.

---

### 2. Tiêu chuẩn lập trình Dart 3 & Tối ưu hiệu năng Flutter

1. **Sound Null Safety & Khai báo biến:**
   - 100% mã nguồn tuân thủ Sound Null Safety. Hạn chế tối đa toán tử ép kiểu null (`!`), ưu tiên dùng toán tử dự phòng (`??`, `?.`) hoặc gán giá trị mặc định.
   - Sử dụng tính năng hiện đại của Dart 3: `switch expressions`, `records` (anonymous tuples), `pattern matching` khi phân tích cú pháp hoặc ánh xạ danh mục.

2. **Tối ưu hóa cây Widget & Tái sử dụng bộ nhớ:**
   - **Bắt buộc dùng `const` constructor** cho mọi widget và padding có cấu hình tĩnh để tránh cấp phát lại bộ nhớ trong chu kỳ Render của Flutter.
   - **Tuyệt đối không thực hiện tính toán nặng (regex, file I/O, db queries) bên trong hàm `build()`** của Widget. Toàn bộ tính toán phải nằm trong Notifier, Service hoặc thực thi bất đồng bộ.
   - Sử dụng `ListView.builder` cho danh sách chi tiêu; **cấm dùng** `SingleChildScrollView(child: Column(...))` cho dữ liệu động dài để tránh tràn RAM và rớt khung hình (Jank).
   - Các phần tử trong danh sách bắt buộc gán `key: ValueKey(expense.id)` để Element Tree đồng bộ chính xác khi thêm/sửa/xóa.

3. **Quản lý Vòng đời & Ngăn ngừa Rò rỉ Bộ nhớ (Lifecycle & Memory Leak Safety):**
   - Trong mọi `StatefulWidget`, tất cả `TextEditingController`, `FocusNode`, `AnimationController`, `StreamSubscription` **bắt buộc phải được giải phóng tại phương thức `dispose()`**.

---

### 3. Quy chuẩn Xử lý Dữ liệu & SQLite Persistence

1. **Chuẩn hóa tiền tệ Việt Nam (VND):**
   - **Quy tắc vàng:** Số tiền trong SQLite luôn luôn lưu dưới dạng số thực/số nguyên chuẩn VND (ví dụ `150000.0` hoặc `150000`), **tuyệt đối không bao giờ lưu `150.0`**.
   - Dấu chấm (`.`) và dấu phẩy (`,`) trên hóa đơn tiếng Việt là ký tự phân cách hàng nghìn, phải loại bỏ sạch trước khi parse.
   - Hiển thị ra màn hình luôn dùng tiện ích định dạng bản địa chuẩn: `150.000 đ` (sử dụng thư viện `intl` hoặc formatter tùy chỉnh).

2. **Ràng buộc toàn vẹn dữ liệu (Data Integrity):**
   - Mọi bản ghi `ExpenseItem` bắt buộc có: `id` (duy nhất), `merchantName` (không được để trống), `totalAmount` (phải $> 0$), `transactionDate` (hợp lệ), `category` (thuộc enum hợp lệ).
   - Thời gian `transactionDate`, `createdAt`, `updatedAt` lưu trữ theo chuẩn chuỗi ISO-8601 (`toIso8601String()`).

3. **Lưu trữ ảnh hóa đơn:**
   - Không lưu ảnh trực tiếp dưới dạng BLOB vào SQLite (tránh phình DB). Chỉ lưu đường dẫn file ảnh cục bộ (`receiptImagePath`) trong thư mục ứng dụng (`getApplicationDocumentsDirectory()`).
   - Khi xóa bản ghi chi tiêu, kiểm tra và dọn dẹp file ảnh tương ứng để tránh rác bộ nhớ thiết bị.

---

### 4. Quy chuẩn OCR & Màn hình Xác nhận (Review & Verification)

1. **Nguyên tắc "Không tin tưởng OCR tuyệt đối" (Never Trust OCR Blindly):**
   - Kết quả từ Google ML Kit và `ReceiptParser` chỉ mang tính chất **gợi ý (Auto-Suggestion)**.
   - **Bắt buộc** phải chuyển qua màn hình `Review & Verification Screen` để người dùng xác nhận. Cấm ghi trực tiếp kết quả OCR vào SQLite mà chưa qua bước xác nhận này.

2. **Cơ chế Fallback an toàn:**
   - Nếu OCR không nhận diện được tổng tiền hoặc tên cửa hàng: để trống trường nhập liệu và hiển thị cảnh báo đỏ yêu cầu người dùng điền tay.
   - Luôn hỗ trợ luồng nhập thủ công không cần chụp ảnh cho các hóa đơn điện tử hoặc chi tiêu không có biên lai.

3. **Form Validation nghiêm ngặt:**
   - Màn hình Review sử dụng `GlobalKey<FormState>` và `AutovalidateMode.onUserInteraction`.
   - Nút "Lưu chi tiêu" chỉ kích hoạt hoặc lưu thành công khi vượt qua tất cả các hàm `validator`.

---

### 5. Tiêu chuẩn Vẽ biểu đồ Đồ họa (CustomPainter Visualization)

1. **Không sử dụng thư viện đồ thị thứ 3:**
   - Để đạt điểm tối đa rubric (2.5 điểm Canvas), toàn bộ biểu đồ Donut phân loại và biểu đồ Bar Chart tuần phải được vẽ bằng `CustomPainter`.

2. **Hiệu năng Canvas & Animation:**
   - Triển khai hàm `shouldRepaint(covariant CustomPainter oldDelegate)` thông minh, chỉ trả về `true` khi dữ liệu số liệu hoặc giá trị `progress` của animation thay đổi.
   - Kết hợp `AnimationController` (thời lượng 800ms - 1200ms, `Curves.easeOutCubic`) và `AnimatedBuilder` để chuyển động vẽ góc quét (sweep angles) và chiều cao cột diễn ra mượt mà ở tần số quét 60Hz/120Hz.

---

### 6. Tiêu chuẩn Giao diện Material 3 & Trải nghiệm Người dùng (UI/UX)

1. **Hệ thống Theming:**
   - Bật `useMaterial3: true`.
   - Seed Color chủ đạo: VKU Navy (`Color(0xFF2C4570)`).
   - Hỗ trợ đầy đủ Light Mode và Dark Mode, bảo đảm độ tương phản văn bản chuẩn WCAG (đặc biệt là nhãn trên biểu đồ và card chi tiêu).

2. **Bố cục Thích ứng (Responsive Layout) & Tránh Lỗi Tràn (Overflow):**
   - Luôn sử dụng `SafeArea` để tránh tai thỏ (Notch), Dynamic Island và thanh điều hướng hệ thống Android.
   - Bọc các biểu mẫu trong `SingleChildScrollView` với thuộc tính `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` để tránh lỗi tràn màn hình khi bàn phím ảo xuất hiện (`RenderFlex overflowed by N pixels`).
   - Dùng `Expanded` hoặc `Flexible` đúng ngữ cảnh trong `Row` / `Column` có kèm `TextOverflow.ellipsis`.

---

### 7. Quy chuẩn Build Release Android

1. **Cấu hình SDK:**
   - `minSdkVersion`: 21 (đảm bảo tương thích Google ML Kit).
   - `targetSdkVersion`: 34 hoặc 35.
2. **Quyền hạn Android (`AndroidManifest.xml`):**
   - Khai báo đầy đủ:
     ```xml
     <uses-permission android:name="android.permission.CAMERA" />
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
     <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
     ```
3. **Đóng gói APK:**
   - Kiểm tra mã nguồn không còn warning nghiêm trọng bằng `flutter analyze`.
   - Build bản release hoàn chỉnh: `flutter build apk --release`.
