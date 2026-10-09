# Product Requirements Document (PRD)
> **Dự án:** ReceiptMate — Receipt OCR & Expense Tracker  
> **Tài liệu tham chiếu:** [PROJECT_DESCRIPTION.md](file:///d:/code/danentang/ReceiptMate/docs/PROJECT_DESCRIPTION.md), [project_rules.md](file:///d:/code/danentang/ReceiptMate/.agents/rules/project_rules.md)  
> **Phiên bản:** 1.0.0 (Release Candidate)  
> **Chủ quản sản phẩm:** Principal Technical Product Manager (TPM) & Chief Product Officer (CPO)  
> **Trạng thái:** Approved for Engineering Implementation  

---

## 1. Mục tiêu Sản phẩm (Product Goals)

### 1.1 Bối cảnh & Vấn đề Người dùng (Problem Statement)
Trong kỷ nguyên tiêu dùng hiện đại, việc quản lý tài chính cá nhân thường gặp phải rào cản lớn nhất là **Sức ỳ nhập liệu thủ công (Manual Data Entry Friction)**. Người dùng (sinh viên, người trẻ đi làm, thủ quỹ câu lạc bộ) nhận hàng chục hóa đơn giấy và biên lai mỗi tuần từ siêu thị, quán cà phê, nhà sách, cây xăng. Việc mở ứng dụng tài chính để gõ từng con số, từng tên quán vào điện thoại tốn nhiều thời gian và dễ nhầm lẫn, dẫn đến tình trạng bỏ cuộc chỉ sau vài ngày ghi chép.

Mặt khác, các giải pháp quét hóa đơn hiện hành thường:
1. **Phụ thuộc kết nối đám mây (Cloud-dependent):** Yêu cầu kết nối Internet liên tục, độ trễ phản hồi cao (High Latency) từ 3–8 giây do phải gửi ảnh lên server.
2. **Chi phí vận hành cao:** Đòi hỏi chi phí API đắt đỏ khi quy mô người dùng tăng.
3. **Nguy cơ rò rỉ quyền riêng tư (Privacy Risks):** Biên lai chứa thông tin chi tiêu nhạy cảm, địa điểm sinh hoạt cá nhân, thời gian giao dịch bị tải lên các máy chủ bên thứ ba.
4. **Tỷ lệ nhận diện sai tiền tệ Việt Nam:** Các mô hình OCR quốc tế thường nhầm lẫn các dấu phân cách hàng nghìn (`.` và `,`), các định dạng viết tắt tiền tệ bản địa (`150k`, `150.000 đ`, `150,000 VND`).

### 1.2 Giải pháp & Tuyên ngôn Giá trị của ReceiptMate (Value Proposition)
**ReceiptMate** được định vị là ứng dụng di động quản lý chi tiêu thông minh thế hệ mới, vận hành theo triết lý **Ngoại tuyến trước tiên (Local-First)** và **Quyền riêng tư tuyệt đối (Privacy-First)**:
- **On-Device Offline OCR:** Tích hợp trực tiếp công nghệ nhận diện ký tự quang học Google ML Kit chạy hoàn toàn cục bộ trên vi xử lý của điện thoại, không cần Internet, phản hồi dưới 1,5 giây, bảo mật 100% dữ liệu trên thiết bị.
- **Bộ phân tích Heuristics bản địa hóa (Vietnamese Currency Normalizer):** Trích xuất thông minh tổng tiền thanh toán, ngày giao dịch và đơn vị bán hàng thông qua hệ thống biểu thức chính quy (Regex) tối ưu riêng cho thói quen in ấn hóa đơn tại Việt Nam.
- **Quy trình Kiểm soát Dữ liệu Hai lớp (Mandatory Review & Verification Pipeline):** Loại bỏ triệt để rủi ro "ghi nhận sai dữ liệu tự động" bằng màn hình đối chiếu thị giác trực quan, cho phép người dùng kiểm tra ảnh gốc và sửa lỗi trước khi ghi vào sổ cái.
- **Trực quan hóa Đồ họa Độc lập (Custom Canvas Graphics):** Tự xây dựng toàn bộ đồ thị Donut Chart và Weekly Bar Chart bằng Flutter `CustomPainter`, loại bỏ sự phụ thuộc vào các thư viện biểu đồ bên ngoài, tối ưu hiệu năng 60/120 FPS.

### 1.3 Chân dung Người dùng Mục tiêu (User Personas)
1. **Persona 1 — Sinh viên & Người mới đi làm (Young Independent Individuals):**
   - *Đặc điểm:* Thường xuyên ăn uống ngoài, mua sắm tiện ích, nhận biên lai giấy lẻ tẻ.
   - *Nhu cầu:* Muốn một công cụ quét hóa đơn siêu nhanh, mở app chụp một phát là xong, không cần tạo tài khoản hay đăng nhập phiền toái.
2. **Persona 2 — Thủ quỹ Câu lạc bộ & Nhóm dự án (Club & Team Treasurers):**
   - *Đặc điểm:* Quản lý quỹ chung của 20–50 thành viên, phải lưu trữ minh chứng hóa đơn giấy để báo cáo tài chính cuối tháng.
   - *Nhu cầu:* Lưu trữ ảnh hóa đơn kèm bản ghi chi tiêu, xem lại ảnh gốc mọi lúc để đối soát, thống kê chi tiêu theo từng hạng mục rõ ràng.
3. **Persona 3 — Người dùng đề cao Quyền riêng tư (Privacy-Conscious Users):**
   - *Đặc điểm:* Cảnh giác với việc dữ liệu mua sắm cá nhân bị thu thập để nhắm mục tiêu quảng cáo.
   - *Nhu cầu:* Ứng dụng chạy offline hoàn toàn, không gửi bất kỳ byte dữ liệu nào ra ngoài mạng Internet.

---

## 2. Phạm vi và Cốt lõi (Scope & Non-Goals)

### 2.1 Phạm vi cốt lõi (In-Scope)
Kiến trúc nghiệp vụ được phân tách chặt chẽ theo 5 tầng miền dữ liệu (*Domain Separation*):

```
┌────────────────────────────────────────────────────────────────────────┐
│                   RECEIPTMATE ARCHITECTURE DOMAINS                     │
├─────────────────────────┬──────────────────────────────────────────────┤
│ 1. Capture & Storage    │ Thu nhận ảnh (Camera/Gallery), nén ảnh,      │
│    Domain               │ quản lý tệp cục bộ (Local File System)       │
├─────────────────────────┼──────────────────────────────────────────────┤
│ 2. Offline OCR &        │ Trích xuất Text Blocks bằng ML Kit Offline,  │
│    Heuristic Parsing    │ Heuristics trích xuất Tiền/Ngày/Merchant     │
├─────────────────────────┼──────────────────────────────────────────────┤
│ 3. Review & Verify      │ Đối chiếu thị giác ảnh - dữ liệu, form       │
│    Domain               │ validation bắt buộc, phân loại danh mục      │
├─────────────────────────┼──────────────────────────────────────────────┤
│ 4. Persistence & Data   │ Lưu trữ SQLite (CRUD, ACID, Indexing),       │
│    Management Domain    │ dọn dẹp tệp ảnh mồ côi (Orphan Cleanup)     │
├─────────────────────────┼──────────────────────────────────────────────┤
│ 5. State & Analytics    │ Quản lý trạng thái Riverpod 2, biểu đồ tự    │
│    Visualization Domain │ vẽ CustomPainter (Donut & Weekly Bar Chart)  │
└─────────────────────────┴──────────────────────────────────────────────┘
```

**Các nhóm tính năng nằm trong kế hoạch triển khai (MVP V1):**
- Quét OCR hóa đơn qua Camera và Bộ sưu tập ảnh (Gallery) ngoại tuyến.
- Thuật toán Heuristic Parser bóc tách: Tên cửa hàng, Ngày giờ, Tổng tiền VND.
- Màn hình Review & Verification xác nhận và bổ sung ghi chú, danh mục.
- Chức năng nhập chi tiêu thủ công không cần hóa đơn.
- Quản lý sổ cái chi tiêu cục bộ bằng SQLite (Xem, Sửa, Xóa).
- Màn hình chi tiết chi tiêu phóng to xem lại ảnh gốc hóa đơn.
- Bảng tin thống kê Dashboard trực quan hóa bằng `CustomPainter` (Donut phân bổ danh mục & Bar chart 7 ngày có animation).
- Tùy chỉnh giao diện Material 3 hỗ trợ Light Mode và Dark Mode chuẩn ngữ cảnh màu sắc VKU Navy (`0xFF2C4570`).

### 2.2 Nằm ngoài phạm vi (Non-Goals / Future Features)
Để bảo đảm tính tập trung cao độ, sự tinh gọn của mã nguồn và hoàn thành đúng thời hạn, các tính năng sau đây **QUYẾT ĐỊNH KHÔNG TRIỂN KHAI** trong phiên bản này:
- **Non-Goal 1 — Đồng bộ Đám mây & Tài khoản (Cloud Sync & Authentication):** Không triển khai Firebase Auth, AWS Cognito, REST API backend hoặc lưu trữ đám mây. Ứng dụng 100% vận hành cục bộ.
- **Non-Goal 2 — Bóc tách Chi tiết từng Mặt hàng (Line Items Decomposition):** Không trích xuất danh sách chi tiết từng món đồ trong giỏ hàng (ví dụ: 1 chai nước 10.000đ, 1 gói snack 15.000đ). Trọng tâm của phiên bản này là **Tổng tiền thanh toán cuối cùng (`total_amount`)**, **Tên đơn vị (`merchant_name`)** và **Thời gian (`transaction_date`)**.
- **Non-Goal 3 — Tích hợp Trí tuệ Nhân tạo Đám mây (Cloud LLM / GenAI Parsing):** Không tích hợp OpenAI API, Gemini API hay Claude API. Toàn bộ logic bóc tách phải vận hành bằng thuật toán Heuristic/Regex chạy trực tiếp trên thiết bị để đảm bảo tính sẵn sàng ngoại tuyến và chi phí bằng 0.
- **Non-Goal 4 — Đa tiền tệ & Tỷ giá hối đoái (Multi-Currency & Forex):** Chỉ hỗ trợ đơn vị tiền tệ duy nhất là Việt Nam Đồng (VND). Không hỗ trợ USD, EUR, JPY hay chuyển đổi tỷ giá.
- **Non-Goal 5 — Chia tiền & Cổng thanh toán (Bill Splitting & Payment Gateway):** Không tích hợp VietQR, Momo, ZaloPay, không có tính năng chia tiền nhóm.
- **Non-Goal 6 — Hỗ trợ Nền tảng iOS & Web (iOS & Web Shell Support):** Giai đoạn hiện tại tập trung tối ưu hóa 100% cho nền tảng Android.

---

## 3. Ràng buộc Hệ thống (System Constraints)

### 3.1 Ràng buộc Công nghệ (Tech Stack Constraints)
| Thành phần | Công nghệ quy định | Phiên bản / Ràng buộc kỹ thuật |
| :--- | :--- | :--- |
| **Framework & Ngôn ngữ** | Flutter & Dart 3 | Flutter 3.24+, Dart 3.x với Sound Null Safety & Impeller Engine |
| **Quản lý Trạng thái** | `flutter_riverpod` | `^2.5.1` (Compile-Safe, Notifier/NotifierProvider) |
| **Nhận diện Ký tự (OCR)** | `google_mlkit_text_recognition` | `^0.11.0` (Chế độ Latin/Default On-Device Offline Engine) |
| **Xử lý Ảnh & Camera** | `image_picker` + `path_provider` | `^1.0.7` / `^2.1.2`, nén ảnh trước khi nạp bộ nhớ |
| **Cơ sở Dữ liệu Cục bộ** | `sqflite` + `path` | `^2.3.2` / `^1.9.0` (SQLite Native Engine trên Android) |
| **Định dạng & Bản địa hóa**| `intl` | `^0.19.0` (Locale `vi_VN`) |
| **Hệ thống Giao diện** | Material 3 Design System | Seed Color `Color(0xFF2C4570)` (VKU Navy), Full Light/Dark |
| **Đồ thị Trực quan hóa** | Flutter Canvas `CustomPainter` | Tự dựng 100%, **CẤM** sử dụng `fl_chart`, `syncfusion` |

### 3.2 Ràng buộc Vận hành & Nền tảng (Platform & Environmental Constraints)
- **Hệ điều hành mục tiêu:** Android OS API level 21 (`minSdkVersion = 21`) đến API level 35 (`targetSdkVersion = 34` hoặc `35`).
- **Quyền hạn hệ thống (`AndroidManifest.xml`):**
  - Chỉ yêu cầu: `android.permission.CAMERA`, `android.permission.READ_MEDIA_IMAGES` (API 33+), và `android.permission.READ_EXTERNAL_STORAGE` (`maxSdkVersion = 32`).
  - Không khai báo quyền mạng xâm lấn: Không yêu cầu kết nối Internet cho các luồng nghiệp vụ chính.
- **Ràng buộc Lưu trữ Tệp:**
  - Tuyệt đối **không lưu trữ dữ liệu ảnh dưới dạng nhị phân BLOB** trực tiếp vào bảng SQLite để tránh làm phình tệp cơ sở dữ liệu và suy giảm hiệu năng đọc ghi I/O.
  - Tệp ảnh hóa đơn phải được nén tối ưu (kích thước tối đa $1200 \times 1600$ pixel, tỷ lệ nén JPEG 85%) và lưu trong thư mục an toàn của ứng dụng (`getApplicationDocumentsDirectory()`). Bảng SQLite chỉ lưu chuỗi đường dẫn cục bộ (`receipt_image_path`).
- **Giải phóng Tài nguyên (Lifecycle & Resource Disposal):**
  - Toàn bộ `TextEditingController`, `FocusNode`, `AnimationController`, `TextRecognizer` bắt buộc phải được giải phóng bộ nhớ tại phương thức `dispose()` của widget hoặc service nhằm triệt tiêu nguy cơ rò rỉ bộ nhớ (Memory Leak).

---

## 4. Yêu cầu Chức năng (Functional Requirements - FR)

### FR-01: Chụp ảnh & Chọn ảnh Hóa đơn Ngoại tuyến (Receipt Image Acquisition)
- **Tên & Mô tả:** Cho phép người dùng chụp ảnh hóa đơn mới bằng máy ảnh của thiết bị hoặc chọn tệp ảnh hóa đơn sẵn có từ thư viện ảnh (Gallery).
- **Chi tiết dữ liệu & hành vi:**
  - Đầu vào: Hành động người dùng bấm chọn "Chụp ảnh" (Camera) hoặc "Chọn từ máy" (Gallery).
  - Quá trình xử lý:
    1. Ứng dụng kiểm tra và yêu cầu quyền truy cập Camera / Thư viện ảnh theo chuẩn Android Runtime Permissions.
    2. Gọi `image_picker` với tùy chọn nén: `maxWidth: 1200`, `maxHeight: 1600`, `imageQuality: 85`.
    3. Lưu bản sao của tệp ảnh vào thư mục ứng dụng (`/data/user/0/.../app_flutter/receipts/receipt_<timestamp>.jpg`).
  - Đầu ra: Đường dẫn tệp ảnh hợp lệ (`String imagePath`) được chuyển giao cho bộ xử lý OCR. Nếu người dùng hủy thao tác, trả về trạng thái nhàn rỗi (Idle) an toàn không phát sinh lỗi.
- **Acceptance Signals:**
  - [x] Khi bấm nút Camera trên thanh điều hướng hoặc màn hình Scan, giao diện chụp ảnh hệ thống Android mở ra tức thì.
  - [x] Chụp xong một hóa đơn thực tế, ứng dụng hiển thị chỉ báo đang xử lý (Loading indicator) và chuyển tiếp liền mạch sang màn hình Review mà không bị crash.
  - [x] Khi người dùng bấm nút Back để từ chối chụp/chọn ảnh, ứng dụng giữ nguyên trạng thái màn hình hiện tại mà không xuất hiện màn hình đen hay thông báo Exception.

---

### FR-02: Nhận diện Ký tự Quang học trên Thiết bị (On-Device Offline OCR Engine)
- **Tên & Mô tả:** Tiếp nhận tệp ảnh hóa đơn và thực hiện nhận diện văn bản hoàn toàn trên thiết bị (On-Device) bằng Google ML Kit Text Recognition mà không cần kết nối mạng.
- **Chi tiết dữ liệu & hành vi:**
  - Đầu vào: Đường dẫn tệp ảnh cục bộ (`imagePath`).
  - Quá trình xử lý:
    1. Khởi tạo `InputImage.fromFilePath(imagePath)`.
    2. Gọi `textRecognizer.processImage(inputImage)`.
    3. Thu nhận đối tượng `RecognizedText` bao gồm danh sách các `TextBlock`, `TextLine`, `TextElement` cùng tọa độ hình chữ nhật bao quanh (*Bounding Boxes*).
  - Cấu trúc dữ liệu nội bộ:
    ```dart
    class RawOcrResult {
      final String fullText;
      final List<String> lines;
      final List<Rect> boundingBoxes;
    }
    ```
  - Xử lý ngoại lệ: Nếu ảnh bị mờ hoặc không chứa chữ viết, trả về danh sách dòng rỗng mà không gây gián đoạn luồng ứng dụng.
- **Acceptance Signals:**
  - [x] Bật chế độ máy bay (Airplane Mode - ngắt toàn bộ Wi-Fi và Dữ liệu di động), đưa vào một hóa đơn thử nghiệm, quá trình OCR vẫn hoàn thành thành công trong thời gian dưới 1,5 giây.
  - [x] Toàn bộ chuỗi văn bản trên hóa đơn được tách thành danh sách các dòng văn bản theo đúng thứ tự không gian từ trên xuống dưới.

---

### FR-03: Bóc tách & Chuẩn hóa Dữ liệu Hóa đơn Việt Nam (Vietnamese Receipt Heuristic Parser)
- **Tên & Mô tả:** Phân tích cú pháp văn bản thô từ OCR bằng các thuật toán Heuristics và biểu thức chính quy (Regex) chuyên biệt để tự động phát hiện: Tên đơn vị bán lẻ (Merchant), Ngày giao dịch (Transaction Date), và Tổng tiền thanh toán (Total Amount).
- **Chi tiết dữ liệu & hành vi:**
  - **1. Trích xuất Tên đơn vị (Merchant Extraction):**
    - Quét 3–5 dòng văn bản đầu tiên trên hóa đơn (loại trừ các từ khóa vô nghĩa như "Hóa đơn", "Phiếu thanh toán", "Receipt", "Welcome").
    - Đối chiếu tập từ điển chuỗi bán lẻ phổ biến (WinMart, Circle K, Highlands, Phúc Long, GS25, 7-Eleven, Co.opmart).
    - Nếu không khớp từ điển, lấy dòng văn bản in hoa hoặc dòng đầu tiên có độ dài từ 3 đến 50 ký tự.
  - **2. Trích xuất Ngày giao dịch (Date Extraction):**
    - Áp dụng Regex phát hiện các mẫu ngày tháng: `\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})\b` hoặc `\b(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})\b`.
    - Chuẩn hóa về kiểu dữ liệu `DateTime`. Nếu không phát hiện ngày, mặc định gán ngày giờ hiện tại (`DateTime.now()`).
  - **3. Trích xuất & Chuẩn hóa Tổng tiền VNĐ (Amount Extraction & Normalization):**
    - Nhận diện dòng chứa từ khóa ưu tiên: `tổng cộng`, `tong cong`, `thanh toán`, `thanh toan`, `tổng tiền`, `khách phải trả`, `amount due`, `total`, `phải thu`.
    - Trích xuất mẫu số: `(\d{1,3}(?:[.,]\d{3})*(?:\.\d{2})?|\d+[kK])`.
    - Chuẩn hóa:
      - Nếu có hậu tố `k`/`K` (ví dụ `75k`): Nhân giá trị với 1.000 $\rightarrow 75.000$ VND.
      - Loại bỏ mọi ký tự phân cách hàng nghìn (`.` hoặc `,`): Chuỗi `150.000` hoặc `150,000` $\rightarrow 150000.0$.
      - Kiểm tra tính hợp lệ: Bỏ qua các số $< 1.000$ VND (tránh nhầm lẫn với số bàn, số thứ tự hóa đơn, định lượng món).
      - Trường hợp Fail-Safe: Nếu không tìm thấy số tiền tin cậy, trả về `null` (không tự ý bịa đặt số).
  - Cấu trúc đối tượng đầu ra (`ParsedReceipt`):
    ```dart
    class ParsedReceipt {
      final String? merchantName;
      final double? totalAmount;
      final DateTime? transactionDate;
      final String rawText;
      final String imagePath;
    }
    ```
- **Acceptance Signals:**
  - [x] Quét hóa đơn có dòng `Tổng cộng: 145.000 đ`, trường số tiền được bóc tách chính xác là `145000.0`.
  - [x] Quét hóa đơn quán nước viết tay/in nhiệt `Trà sữa 45k`, số tiền bóc tách chính xác là `45000.0`.
  - [x] Quét hóa đơn có ngày `15/08/2026`, trường ngày tháng được parse chính xác thành ngày 15 tháng 8 năm 2026.
  - [x] Hóa đơn bị rách phần tổng tiền: Trường số tiền hiển thị trống và đánh dấu yêu cầu nhập tay, không văng lỗi ứng dụng.

---

### FR-04: Màn hình Đối chiếu & Hiệu chỉnh Dữ liệu (Review & Verification Interface)
- **Tên & Mô tả:** Cung cấp giao diện trực quan cho phép người dùng đối chiếu ảnh chụp hóa đơn gốc với các trường thông tin do hệ thống tự động bóc tách; bắt buộc người dùng kiểm tra, chỉnh sửa và xác nhận trước khi lưu vào cơ sở dữ liệu.
- **Chi tiết dữ liệu & hành vi:**
  - Bố cục giao diện:
    1. Khung xem trước ảnh hóa đơn (Interactive Thumbnail / Image Preview): Cho phép phóng to, thu nhỏ để đọc rõ các dòng số mờ trên hóa đơn gốc.
    2. Trường nhập liệu Tên cửa hàng (`merchant_name`): Có giá trị gợi ý từ OCR, cho phép gõ lại.
    3. Trường nhập liệu Số tiền (`total_amount`): Tự động format theo chuẩn tiền tệ VND khi gõ (`150.000 đ`).
    4. Bộ chọn Ngày giao dịch (`transaction_date`): Hiển thị ngày đã bóc tách, bấm vào mở DatePicker Material 3 để đổi ngày.
    5. Bộ chọn Danh mục chi tiêu (`category`): Lựa chọn dạng SegmentedButton hoặc ChoiceChips gồm 5 danh mục:
       - 🍔 Ăn uống (`Food`)
       - 🛍️ Mua sắm (`Shopping`)
       - 🚗 Di chuyển (`Transport`)
       - 💡 Hóa đơn & Tiện ích (`Utilities`)
       - 📦 Khác (`Other`)
    6. Ô nhập Ghi chú (`note`): Tùy chọn (Nullable, tối đa 255 ký tự).
  - Quy tắc xác thực dữ liệu (Form Validation Rules):
    - `merchant_name`: Bắt buộc không được để trống (Trimmed string length $\ge 1$).
    - `total_amount`: Bắt buộc là số thực $> 0$.
    - `transaction_date`: Bắt buộc không được để trống và không được lớn hơn thời điểm hiện tại quá 1 ngày.
    - `category`: Bắt buộc thuộc một trong 5 danh mục hợp lệ.
  - Hành động: Bấm nút "Lưu chi tiêu" (Confirm & Save) $\rightarrow$ Validate Form $\rightarrow$ Gọi `ExpenseNotifier.addExpense()` $\rightarrow$ Điều hướng về Dashboard hoặc Danh sách chi tiêu kèm thông báo SnackBar thành công.
- **Acceptance Signals:**
  - [x] Sau khi quét OCR xong, người dùng luôn được đưa tới `ReviewScreen` với đầy đủ các ô nhập liệu đã điền sẵn dữ liệu trích xuất.
  - [x] Xóa trắng ô Tên cửa hàng và bấm "Lưu chi tiêu", ứng dụng chặn lại và hiển thị thông báo lỗi màu đỏ: *"Vui lòng nhập tên cửa hàng"*.
  - [x] Nhập số tiền `0` hoặc âm, ứng dụng báo lỗi: *"Số tiền phải lớn hơn 0"*.
  - [x] Người dùng đổi danh mục từ "Ăn uống" sang "Mua sắm", bấm lưu, bản ghi mới trong database phản ánh đúng danh mục "Mua sắm".

---

### FR-05: Nhập liệu Chi tiêu Thủ công (Manual Expense Entry)
- **Tên & Mô tả:** Cho phép người dùng ghi nhận các khoản chi tiêu không có biên lai giấy (chi tiền mặt chợ truyền thống, tiền gửi xe, chuyển khoản trực tiếp) thông qua biểu mẫu nhập tay độc lập.
- **Chi tiết dữ liệu & hành vi:**
  - Kích hoạt thông qua FloatingActionButton (+) tại màn hình chính hoặc nút "Nhập thủ công" trên màn hình Scan.
  - Tái sử dụng form xác thực của `ReviewScreen` nhưng trường `receipt_image_path` được gán giá trị `null`.
  - Các trường dữ liệu, quy tắc validator và danh mục hoàn toàn đồng nhất với FR-04.
- **Acceptance Signals:**
  - [x] Bấm nút (+) trên màn hình Dashboard, form nhập liệu mở ra với các trường trống (trừ ngày mặc định là hôm nay).
  - [x] Nhập tên: "Gửi xe tháng", Số tiền: "100.000", Danh mục: "Di chuyển", bấm Lưu $\rightarrow$ Giao dịch được lưu vào SQLite với `receipt_image_path = null`.

---

### FR-06: Quản lý Kho lưu trữ Chi tiêu Cục bộ (SQLite Local Persistence & CRUD)
- **Tên & Mô tả:** Khởi tạo cơ sở dữ liệu quan hệ SQLite trên máy, bảo đảm tính toàn vẹn dữ liệu chi tiêu qua các thao tác Thêm, Đọc, Cập nhật, Xóa (CRUD).
- **Chi tiết dữ liệu & lược đồ (Database Schema):**
  - Tên cơ sở dữ liệu: `receipt_mate.db`
  - Phiên bản: `1`
  - Bảng dữ liệu: `expenses`
  ```sql
  CREATE TABLE expenses (
    id TEXT PRIMARY KEY,
    merchant_name TEXT NOT NULL,
    total_amount REAL NOT NULL,
    transaction_date TEXT NOT NULL,
    category TEXT NOT NULL,
    note TEXT,
    receipt_image_path TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  );

  CREATE INDEX idx_expenses_date ON expenses(transaction_date);
  CREATE INDEX idx_expenses_category ON expenses(category);
  ```
  - Quản lý vòng đời dữ liệu khi XÓA (Delete Cascade / File Cleanup):
    - Khi một bản ghi bị xóa khỏi SQLite, ứng dụng kiểm tra xem `receipt_image_path` có tồn tại trên ổ đĩa hay không.
    - Nếu tệp tồn tại, thực thi `File(path).delete()` để giải phóng dung lượng bộ nhớ thiết bị, triệt tiêu tệp rác mồ côi (*Orphan File Prevention*).
- **Acceptance Signals:**
  - [x] Thêm mới 10 giao dịch chi tiêu, khởi động lại ứng dụng (Kill process và mở lại), toàn bộ 10 giao dịch vẫn hiển thị chính xác và đầy đủ.
  - [x] Thực hiện xóa một khoản chi tiêu có ảnh đính kèm, bản ghi biến mất khỏi danh sách và tệp ảnh trong thư mục ứng dụng bị xóa vĩnh viễn khỏi bộ nhớ máy.

---

### FR-07: Xem Chi tiết & Đối soát Chứng từ (Expense Detail & Receipt Inspector)
- **Tên & Mô tả:** Hiển thị toàn bộ thông tin chi tiết của một khoản chi tiêu đã lưu, hỗ trợ chế độ xem ảnh biên lai toàn màn hình để phục vụ mục đích đối soát tài chính của thủ quỹ.
- **Chi tiết dữ liệu & hành vi:**
  - Đầu vào: Chạm vào bất kỳ thẻ chi tiêu nào trong danh sách.
  - Hiển thị:
    - Huy hiệu danh mục (Icon + Tên danh mục + Màu tương ứng).
    - Tên cửa hàng cỡ chữ lớn, nổi bật.
    - Số tiền định dạng chuẩn VND màu sắc tương phản rõ ràng.
    - Ngày giờ giao dịch chi tiết (`dd/MM/yyyy HH:mm`).
    - Ghi chú đính kèm (nếu có).
    - Khung ảnh hóa đơn: Nếu có ảnh, cho phép bấm vào để mở modal xem ảnh toàn màn hình có hỗ trợ cử chỉ zoom 2 ngón tay (`InteractiveViewer`). Nếu không có ảnh (`null`), hiển thị thẻ ghi chú *"Giao dịch không có ảnh biên lai đính kèm"*.
  - Tác vụ: Cho phép bấm nút "Chỉnh sửa" (Edit) để sửa lại thông tin hoặc nút "Xóa" (Delete) có hộp thoại xác nhận (Confirmation Dialog).
- **Acceptance Signals:**
  - [x] Bấm vào một hóa đơn trong danh sách, màn hình chi tiết hiển thị đúng ảnh hóa đơn đã chụp trước đó.
  - [x] Dùng hai ngón tay zoom vào bức ảnh hóa đơn, ảnh phóng to mượt mà, thấy rõ từng con số in trên giấy.
  - [x] Bấm nút Xóa $\rightarrow$ Hộp thoại cảnh báo *"Bạn có chắc chắn muốn xóa chi tiêu này?"* xuất hiện. Bấm "Hủy" thì giữ nguyên; bấm "Xóa" thì xóa thành công và quay lại màn hình trước.

---

### FR-08: Danh sách Lịch sử Giao dịch & Bộ lọc (Transaction History & Filtering)
- **Tên & Mô tả:** Hiển thị danh sách toàn bộ các khoản chi tiêu đã ghi nhận theo thứ tự thời gian giảm dần (mới nhất lên đầu), hỗ trợ tìm kiếm theo tên cửa hàng và lọc theo danh mục.
- **Chi tiết dữ liệu & hành vi:**
  - Hiển thị bằng `ListView.builder` hiệu năng cao với `key: ValueKey(expense.id)`.
  - Thanh tìm kiếm (SearchBar): Lọc tức thì (Real-time filtering) theo chuỗi không dấu hoặc có dấu của `merchant_name`.
  - Hàng nút lọc danh mục (Category Filter Chips): Lọc nhanh theo Tất cả (`All`), Ăn uống, Mua sắm, Di chuyển, Hóa đơn, Khác.
  - Empty State: Khi không có dữ liệu nào khớp với bộ lọc, hiển thị widget `EmptyStateView` với hình ảnh minh họa vector và nút kêu gọi hành động (*"Không tìm thấy chi tiêu nào - Thêm ngay"*).
- **Acceptance Signals:**
  - [x] Khi có 500 bản ghi chi tiêu trong SQLite, thao tác cuộn danh sách (Fling scroll) diễn ra mượt mà không hề giật lag.
  - [x] Gõ chữ "Highlands" vào ô tìm kiếm, danh sách lọc ngay lập tức chỉ hiển thị các hóa đơn của Highlands Coffee trong vòng < 50ms.
  - [x] Chọn chip "Ăn uống", danh sách chỉ hiển thị các khoản thuộc nhóm Food.

---

### FR-09: Phân tích & Trực quan hóa Tỷ lệ Chi tiêu bằng Đồ họa Canvas (Category Donut Chart)
- **Tên & Mô tả:** Tự vẽ biểu đồ tròn khuyết (Donut Chart) bằng Flutter `CustomPainter` trên màn hình Dashboard để trực quan hóa tỷ trọng chi tiêu của từng danh mục trong tháng hiện tại.
- **Chi tiết dữ liệu & hành vi:**
  - Đầu vào: Danh sách chi tiêu thuộc tháng đang chọn.
  - Xử lý tổng hợp:
    1. Tính tổng số tiền chi tiêu toàn bộ danh mục ($S_{total}$).
    2. Gom nhóm theo từng `category` và tính tổng con ($S_{cat}$).
    3. Tính góc quét tương ứng trên đường tròn: $\theta_{cat} = (S_{cat} / S_{total}) \times 2\pi$.
  - Triển khai Canvas (`CategoryDonutPainter`):
    - Vẽ các cung tròn (`canvas.drawArc`) với độ dày đường vẽ kính cong `strokeWidth = 24.0`, kiểu nét viền tròn `StrokeCap.round`.
    - Màu sắc cung tròn tương ứng với hằng số màu danh mục định nghĩa trong `AppColors`.
    - Ở tâm của Donut chart: Vẽ tổng số tiền chi tiêu của cả tháng với kích thước chữ lớn, định dạng chuẩn tiền tệ tiếng Việt.
  - Hiệu ứng hoạt ảnh (Animation):
    - Sử dụng `AnimationController` thời lượng 1.000 ms với đường cong gia tốc `Curves.easeOutCubic`.
    - Biểu đồ nở dần góc quay từ $0^\circ$ đến $360^\circ$ khi người dùng mở màn hình Dashboard.
  - Empty State: Nếu tổng chi tiêu bằng 0, vẽ một vòng tròn xám nhạt (`Colors.grey.withOpacity(0.2)`) với chữ *"Chưa có dữ liệu"*.
- **Acceptance Signals:**
  - [x] Màn hình Dashboard nạp lên, biểu đồ Donut tự động bung nở mượt mà trong 1 giây mà không dùng bất kỳ thư viện biểu đồ bên ngoài nào.
  - [x] Khi thêm một khoản chi mới trị giá 500.000đ cho danh mục "Ăn uống", góc quét của màu cam/Food mở rộng tương ứng với tỷ lệ mới ngay lập tức.
  - [x] Kiểm tra mã nguồn không import `fl_chart`, `charts_flutter`, hoặc `syncfusion`.

---

### FR-10: Theo dõi Chi tiêu 7 Ngày Gần nhất (Weekly Spending Bar Chart with Canvas)
- **Tên & Mô tả:** Tự vẽ biểu đồ cột (Bar Chart) bằng `CustomPainter` thể hiện mức độ chi tiêu trong 7 ngày gần nhất, giúp người dùng nắm bắt nhịp độ tiêu tiền theo tuần.
- **Chi tiết dữ liệu & hành vi:**
  - Đầu vào: Dữ liệu chi tiêu của 7 ngày liên tiếp tính ngược từ ngày hiện tại ($D_{-6}$ đến $D_0$).
  - Thuật toán Canvas (`WeeklyBarPainter`):
    - Tìm ngày có chi tiêu cao nhất trong 7 ngày ($Amount_{max}$).
    - Tính chiều cao tương đối của từng cột: $Height_i = (Amount_i / Amount_{max}) \times MaxCanvasHeight$.
    - Vẽ 7 cột chữ nhật bo góc tròn (`RRect.fromRectAndRadius`) với khoảng cách đều nhau.
    - Vẽ nhãn thứ trong tuần (T2, T3, T4, T5, T6, T7, CN) bên dưới chân mỗi cột bằng `TextPainter`.
    - Cột của ngày hôm nay được tô màu nổi bật bằng Primary Color (VKU Navy), các ngày khác có màu thứ cấp.
  - Hiệu ứng chuyển động (Animation):
    - Các cột dâng dần từ độ cao 0 lên độ cao thực tế theo nhịp chuyển động mượt mà.
- **Acceptance Signals:**
  - [x] Biểu đồ hiển thị chính xác 7 cột tương ứng với 7 ngày gần nhất kèm nhãn ngày ở chân cột.
  - [x] Chiều cao của cột phản ánh chuẩn xác tỷ lệ số tiền chi tiêu của từng ngày.
  - [x] Hoạt ảnh dâng cột mượt mà ở tần số quét 60fps/120fps.

---

### FR-11: Chuyển đổi Chủ đề Sáng / Tối Hệ thống (Material 3 Dynamic Theme Switching)
- **Tên & Mô tả:** Cho phép người dùng chuyển đổi linh hoạt giữa giao diện Sáng (Light Mode), giao diện Tối (Dark Mode) hoặc đi theo cài đặt mặc định của hệ điều hành Android.
- **Chi tiết dữ liệu & hành vi:**
  - Bảng màu sinh từ Seed Color VKU Navy (`0xFF2C4570`) thông qua `ColorScheme.fromSeed`:
    - Light Theme: Nền sáng nhẹ nhàng, bề mặt thẻ tương phản rõ, văn bản màu than đậm.
    - Dark Theme: Nền đen OLED / xám đậm sâu (`0xFF121212`), bề mặt thẻ `SurfaceContainer` tương phản dịu mắt, không gây chói ban đêm.
  - Quản lý trạng thái: Lưu cấu hình theme vào `SharedPreferences` cục bộ để giữ nguyên trạng thái khi người dùng mở lại ứng dụng.
- **Acceptance Signals:**
  - [x] Chuyển từ Light sang Dark mode, toàn bộ văn bản, viền thẻ và màu nền đồ thị Canvas tự động thích ứng với độ tương phản chuẩn WCAG mà không bị chữ đen trên nền đen.
  - [x] Đóng ứng dụng ở Dark mode và mở lại, ứng dụng ghi nhớ và khởi động trực tiếp ở Dark mode.

---

## 5. Yêu cầu Phi Chức năng (Non-Functional Requirements - NFR)

### NFR-01: Hiệu năng & Tốc độ Phản hồi (Performance & Responsiveness)
1. **Thời gian xử lý OCR Cục bộ:** Quá trình trích xuất văn bản Google ML Kit và bộ bóc tách Heuristics phải hoàn thành trong thời gian **$\le 1.500$ ms** đối với ảnh hóa đơn tiêu chuẩn trên các thiết bị Android tầm trung (tương đương chip Snapdragon 680 hoặc Helio G99).
2. **Tốc độ Khởi động Ứng dụng (App Cold Start):** Thời gian từ khi người dùng bấm vào biểu tượng ứng dụng đến khi hiển thị đầy đủ màn hình Dashboard có dữ liệu phải **$< 1.200$ ms**.
3. **Mượt mà Giao diện & Đồ họa (Frame Budget):** Toàn bộ các thao tác cuộn danh sách (`ListView.builder`) và hoạt ảnh vẽ đồ thị Canvas (`CustomPainter`) phải đạt tốc độ khung hình ổn định **60 FPS** (ngân sách thời gian render $< 16,6$ ms/frame) và hỗ trợ **120 FPS** trên các màn hình có tần số quét cao; tỷ lệ rớt khung hình (Jank Rate) phải $< 1\%$.
4. **Độ trễ Truy vấn Cơ sở Dữ liệu:** Mọi thao tác đọc, lọc và thống kê tổng tiền trong SQLite phải hoàn tất trong vòng **$< 50$ ms** nhờ chỉ mục hóa (`Index`) trên các trường `transaction_date` và `category`.

### NFR-02: Bảo mật & Quyền riêng tư (Security & Privacy)
1. **Không Rò rỉ Dữ liệu Mạng (Zero Telemetry & Network Leak):** Toàn bộ dữ liệu chi tiêu, lịch sử giao dịch và hình ảnh hóa đơn chỉ được lưu trữ duy nhất trên thiết bị người dùng. Không có bất kỳ gói tin mạng nào chứa thông tin cá nhân được gửi đi qua giao thức HTTP/HTTPS.
2. **Khu vực Lưu trữ Tệp Biệt lập (Sandboxed Local Storage):** Ảnh hóa đơn và tệp cơ sở dữ liệu `receipt_mate.db` phải nằm hoàn toàn trong thư mục nội bộ an toàn của ứng dụng (`/data/user/0/<package_name>/app_flutter/`), ngăn chặn các ứng dụng khác trên cùng thiết bị truy cập trái phép.
3. **Giới hạn Quyền Hạn Tối thiểu (Principle of Least Privilege):** Ứng dụng chỉ xin quyền Camera và Truy cập Ảnh khi người dùng chủ động kích hoạt chức năng quét. Nếu người dùng từ chối quyền, ứng dụng vẫn cho phép sử dụng chức năng nhập tay bình thường mà không bị crash.

### NFR-03: Tính sẵn sàng & Toàn vẹn Dữ liệu (Reliability & Data Integrity)
1. **Khả năng Vận hành Ngoại tuyến Tuyệt đối (100% Offline-Ready):** Toàn bộ 11 yêu cầu chức năng (FR-01 đến FR-11) phải hoạt động hoàn hảo và không suy giảm tính năng khi thiết bị ở chế độ Máy bay (Airplane Mode).
2. **Tuân thủ Chuẩn Toàn vẹn Giao dịch (ACID Compliance):** Các giao dịch ghi vào SQLite phải đảm bảo tính nguyên tử (Atomicity). Nếu quá trình lưu bản ghi hoặc lưu tệp ảnh gặp sự cố bất ngờ (hết pin, tắt app đột ngột), dữ liệu phải tự động Rollback, không để lại bản ghi rác hoặc tệp ảnh mồ côi.
3. **Xử lý Ngoại lệ An toàn (Graceful Degradation):** Khi ảnh hóa đơn bị nhòe, tối hoặc nhàu nát khiến OCR không thể nhận diện được dòng tổng tiền, ứng dụng không được văng lỗi (Uncaught Exception) mà phải trả về trạng thái cảnh báo nhẹ nhàng và yêu cầu người dùng điền tay tại `ReviewScreen`.
4. **Kiểm soát Tràn Bộ nhớ Ảo (Out-Of-Memory Prevention):** Ứng dụng phải tự động nén kích thước ảnh (giới hạn tối đa $1200 \times 1600$ pixel, chất lượng 85%) trước khi đưa vào mô hình ML Kit, đảm bảo RAM sử dụng của ứng dụng không vượt quá **150 MB** trong suốt quá trình quét hóa đơn.

### NFR-04: Đa ngôn ngữ, Kiểu chữ & Mã hóa (Typography & Encoding)
1. **Mã hóa Ký tự UTF-8 Tuyệt đối:** Toàn bộ cơ sở dữ liệu SQLite, bộ bóc tách Regex và tầng giao diện người dùng phải sử dụng mã hóa ký tự UTF-8, hỗ trợ trọn vẹn 100% bảng ký tự tiếng Việt có dấu (kể cả Unicode tổ hợp và Unicode dựng sẵn).
2. **Quy chuẩn Định dạng Tiền tệ Bản địa:** Số tiền hiển thị trên giao diện bắt buộc tuân theo quy chuẩn Việt Nam: Phân cách hàng nghìn bằng dấu chấm (`.`), phân cách thập phân bằng dấu phẩy (`,`) và hậu tố tiền tệ `đ` (ví dụ: `150.000 đ`, `1.250.000 đ`). Tuyệt đối không hiển thị định dạng kiểu Mỹ (`$150,000.00`).
3. **Quy chuẩn Định dạng Ngày giờ:** Ngày giờ giao dịch hiển thị theo quy ước người Việt: `dd/MM/yyyy` (ví dụ: `28/02/2026`). Dưới tầng cơ sở dữ liệu SQLite, thời gian bắt buộc lưu theo định dạng chuẩn quốc tế ISO-8601 UTC (`YYYY-MM-DDTHH:MM:SS`) để phục vụ tính toán sắp xếp chính xác.

### NFR-05: Trải nghiệm Người dùng Nền tảng (Platform Usability & Accessibility)
1. **Thiết kế Thích ứng & Tránh Tràn Màn hình (Overflow Safety):** 100% các màn hình biểu mẫu phải được bao bọc trong `SafeArea` và `SingleChildScrollView` với cơ chế tự động ẩn bàn phím khi cuộn (`keyboardDismissBehavior: onDrag`). Tuyệt đối không để phát sinh lỗi vỡ layout (`RenderFlex overflowed by N pixels`) trên bất kỳ kích thước màn hình Android nào (từ màn hình 4.7 inch đến 6.7 inch).
2. **Độ tương phản Văn bản Chuẩn WCAG AA:** Toàn bộ màu chữ trên nền trong cả hai chế độ Light Mode và Dark Mode (đặc biệt là nhãn trên biểu đồ Donut và số tiền trên các thẻ chi tiêu) phải đạt tỷ lệ tương phản tối thiểu **4.5:1** theo tiêu chuẩn tiếp cận Web Content Accessibility Guidelines (WCAG) 2.1 AA.
3. **Phản hồi Tức thì (Optimistic UI & Visual Feedback):** Mọi hành động thêm, sửa, xóa chi tiêu phải cập nhật giao diện ngay lập tức trong vòng $< 16$ ms thông qua Riverpod Notifier, đi kèm thông báo phản hồi (SnackBar / Haptic feedback) để người dùng an tâm rằng dữ liệu đã được ghi nhận.

---

## 6. Lộ trình Triển khai Phân kỳ (Phase Implementation Roadmap)

Lộ trình phát triển được chia làm 5 giai đoạn kế tiếp nhau, bảo đảm từng viên gạch kiến trúc được kiểm thử vững chắc trước khi xây dựng tầng tiếp theo:

| Giai đoạn (Phase) | Tên Phân kỳ & Trọng tâm Triển khai | Yêu cầu Chức năng (FR) Liên quan | Tiêu chí Hoàn thành (Exit Criteria) |
| :---: | :--- | :--- | :--- |
| **Phase 1** | **Nền tảng Hạ tầng & Khung Giao diện**<br>- Khởi tạo dự án Flutter 3.24 Sound Null Safety.<br>- Cấu hình `pubspec.yaml`, Android permissions (`AndroidManifest.xml`).<br>- Xây dựng Theme Material 3 (VKU Navy) Light/Dark.<br>- Xây dựng Scaffold chính & M3 NavigationBar. | **FR-11** | Ứng dụng chạy mượt trên Android Emulator/Device, chuyển đổi Light/Dark mode tức thì, thanh điều hướng hoạt động hoàn hảo. |
| **Phase 2** | **Mô hình Dữ liệu & SQLite Persistence Cục bộ**<br>- Định nghĩa entity `ExpenseItem` với `toMap()`, `fromMap()`.<br>- Xây dựng `DatabaseService` (SQLite CRUD, Indexing, ACID).<br>- Tích hợp `flutter_riverpod` cho `ExpenseNotifier`.<br>- Màn hình Danh sách chi tiêu & Nhập liệu thủ công. | **FR-05**<br>**FR-06**<br>**FR-07**<br>**FR-08** | Thêm, sửa, xóa chi tiêu thủ công bền vững vào SQLite; lọc tìm kiếm theo danh mục và từ khóa cửa hàng mượt mà. |
| **Phase 3** | **Tích hợp OCR Ngoại tuyến & Màn hình Xác nhận**<br>- Tích hợp `image_picker` và nén ảnh lưu vào Storage.<br>- Tích hợp Google ML Kit Text Recognition Offline.<br>- Xây dựng thuật toán Regex Heuristics `ReceiptParser`.<br>- Hoàn thiện `ReviewScreen` với Form Validator nghiêm ngặt. | **FR-01**<br>**FR-02**<br>**FR-03**<br>**FR-04** | Chụp/chọn hóa đơn thực tế trong chế độ máy bay $\rightarrow$ OCR bóc tách Tên/Ngày/Tiền VND $\rightarrow$ Review Screen xác nhận và lưu vào SQLite thành công. |
| **Phase 4** | **Trực quan hóa Đồ họa Canvas (CustomPainter)**<br>- Xây dựng thuật toán tổng hợp số liệu theo danh mục và theo tuần.<br>- Tự vẽ Donut Chart với `CustomPainter` & `AnimationController`.<br>- Tự vẽ Weekly Bar Chart 7 ngày với trục tọa độ và nhãn thứ.<br>- Hoàn thiện giao diện Dashboard tổng quan. | **FR-09**<br>**FR-10** | Mở Dashboard: Donut chart và Bar chart dâng hoạt ảnh mượt mà 60fps/120fps; số liệu khớp 100% với database; không dùng thư viện biểu đồ bên ngoài. |
| **Phase 5** | **Kiểm thử Toàn diện, Tối ưu & Đóng gói Release**<br>- Kiểm tra rò rỉ bộ nhớ (Disposal of controllers/streams).<br>- Tinh chỉnh Responsive Layout, kiểm tra không lỗi tràn màn hình.<br>- Chạy `flutter analyze` đạt 0 lỗi, 0 cảnh báo.<br>- Đóng gói bản phát hành `flutter build apk --release`. | **Toàn bộ FRs**<br>**và NFRs** | File APK Release cài đặt độc lập và chạy hoàn hảo trên thiết bị Android vật lý; chuẩn bị video demo và báo cáo kỹ thuật. |

---

## 7. Lời kết Định hướng Tuân thủ cho Đội ngũ Kỹ sư (Engineering Mandate)

Tài liệu PRD này là cam kết chất lượng cao nhất giữa Quản lý Sản phẩm và Đội ngũ Kỹ sư. Trong quá trình viết mã nguồn, các kỹ sư cần ghi nhớ 3 nguyên tắc bất di bất dịch:
1. **"Never Trust OCR Blindly" (Không tin tưởng OCR tuyệt đối):** Không bao giờ được phép bỏ qua bước `ReviewScreen` để ghi dữ liệu trực tiếp vào cơ sở dữ liệu. Trải nghiệm người dùng phụ thuộc vào sự tự tin và quyền kiểm soát của chính họ đối với dữ liệu tài chính của mình.
2. **"True Local-First, Zero Data Leaks" (Ngoại tuyến chân chính, không rò rỉ dữ liệu):** Luôn kiểm thử ứng dụng trong trạng thái ngắt mạng hoàn toàn. Mọi tính năng cốt lõi phải chạy mượt mà ngay cả trên một đỉnh núi không có sóng di động.
3. **"Pixel-Perfect & Canvas Mastery" (Chăm chút từng điểm ảnh & làm chủ đồ họa):** Tự hào xây dựng biểu đồ bằng chính đôi tay và toán học trên Flutter Canvas thay vì lạm dụng các thư viện cồng kềnh. Từng khung hình chuyển động phải mang lại cảm giác mượt mà và đẳng cấp cho người dùng.
