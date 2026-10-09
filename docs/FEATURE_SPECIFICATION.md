# Đặc tả Hành vi & Chức năng (Feature Specification)
> **Dự án:** ReceiptMate — Receipt OCR & Expense Tracker  
> **Nền tảng:** Android Mobile (Flutter & Dart 3)  
> **Tham chiếu:** [PRD.md](file:///d:/code/danentang/ReceiptMate/docs/PRD.md), [PROJECT_DESCRIPTION.md](file:///d:/code/danentang/ReceiptMate/docs/PROJECT_DESCRIPTION.md), [project_rules.md](file:///d:/code/danentang/ReceiptMate/.agents/rules/project_rules.md)  
> **Chủ quản tài liệu:** Lead Technical Product Manager & Senior Product Designer (UI/UX)  
> **Phiên bản:** 1.0.0 (Approved for UI/UX & Development)

Tài liệu này đặc tả chi tiết toàn bộ hành vi hệ thống và tương tác người dùng quan sát được (*Observable System & User Behaviors*) cho tất cả các tính năng cốt lõi của ứng dụng **ReceiptMate**. Tài liệu độc lập hoàn toàn với các quyết định kỹ thuật nội bộ (như Database schema, mã lệnh hay cấu trúc thư mục), đóng vai trò là "kim chỉ nam" trực tiếp cho quá trình thiết kế giao diện UI/UX và phát triển luồng tương tác người dùng.

---

## Danh mục Tính năng Đặc tả (Feature Matrix)

| Mã Tính năng | Tên Tính năng | Ánh xạ PRD |
| :--- | :--- | :--- |
| **Feature 1** | Chụp ảnh & Chọn ảnh Hóa đơn Ngoại tuyến | **FR-01** |
| **Feature 2** | Nhận diện Ký tự Quang học Ngoại tuyến (OCR) | **FR-02** |
| **Feature 3** | Bóc tách & Chuẩn hóa Dữ liệu Heuristics | **FR-03** |
| **Feature 4** | Màn hình Đối chiếu & Hiệu chỉnh Dữ liệu Hóa đơn | **FR-04** |
| **Feature 5** | Ghi nhận Chi tiêu Thủ công | **FR-05** |
| **Feature 6** | Quản lý Kho lưu trữ Chi tiêu Cục bộ & Xóa Tệp Mồ côi | **FR-06** |
| **Feature 7** | Xem Chi tiết & Đối soát Chứng từ Toàn màn hình | **FR-07** |
| **Feature 8** | Danh sách Lịch sử Giao dịch, Tìm kiếm & Bộ lọc | **FR-08** |
| **Feature 9** | Biểu đồ Tỷ lệ Chi tiêu Danh mục Canvas Donut | **FR-09** |
| **Feature 10** | Biểu đồ Chi tiêu 7 Ngày Gần nhất Canvas Bar Chart | **FR-10** |
| **Feature 11** | Chuyển đổi Chủ đề Sáng / Tối Material 3 | **FR-11** |

---

## Feature 1: Chụp ảnh & Chọn ảnh Hóa đơn Ngoại tuyến (FR-01)
*Cho phép người dùng thu nhận ảnh hóa đơn/biên lai mua hàng từ máy ảnh vật lý hoặc thư viện ảnh thiết bị Android trong môi trường hoàn toàn ngoại tuyến.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng bấm nút "Quét hóa đơn" (Biểu tượng Máy ảnh nổi bật tại thanh điều hướng trung tâm hoặc nút quét tại Dashboard).
  2. Hệ thống trượt lên một bảng tùy chọn (*Modal BottomSheet*) với 2 lựa chọn: **"Chụp ảnh mới"** (biểu tượng Camera) và **"Chọn từ thư viện"** (biểu tượng Thư viện ảnh).
  3. Người dùng chạm vào **"Chụp ảnh mới"** $\rightarrow$ Hệ thống khởi động máy ảnh hệ thống của Android.
  4. Người dùng căn chỉnh hóa đơn vào khung ngắm, bấm nút chụp $\rightarrow$ Xem trước ảnh và bấm dấu tích xác nhận (Done/OK).
  5. Hệ thống tiếp nhận ảnh, thực hiện nén ảnh ngầm ($1200 \times 1600$ pixel, chất lượng 85%) và lưu tạm vào thư mục đệm an toàn của ứng dụng.
  6. Hệ thống tự động chuyển tiếp ảnh vào quy trình nhận diện ký tự (Feature 2) và đưa người dùng đến màn hình Review (Feature 4).

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - **Kiểm tra quyền truy cập hệ thống (Runtime Permissions):**
    - Nếu là lần đầu sử dụng: Hiển thị hộp thoại xin cấp quyền hệ thống tiêu chuẩn (`Camera` và `Photos/Media`).
    - Nếu người dùng từ chối cấp quyền lần 1: Hệ thống hiển thị hộp thoại giải thích (*Rationale Dialog*): *"ReceiptMate cần quyền sử dụng máy ảnh để chụp và quét thông tin từ hóa đơn của bạn. Mọi dữ liệu đều được xử lý ngoại tuyến trên máy."* kèm nút "Cấp quyền".
    - Nếu người dùng chọn "Không hỏi lại" (Permanently Denied): Hệ thống hiển thị thông báo SnackBar nổi ở đáy màn hình có nút bấm hành động **"Mở Cài đặt"** (*Open Settings*) đưa thẳng người dùng đến trang cài đặt quyền của ứng dụng trong Android OS.
  - **Kiểm tra định dạng tệp:** Chỉ tiếp nhận tệp ảnh hợp lệ (`.jpg`, `.jpeg`, `.png`, `.webp`, `.heic`). Nếu chọn nhầm tệp dữ liệu không hỗ trợ, hiển thị thông báo lỗi màu đỏ: *"Định dạng tệp không được hỗ trợ. Vui lòng chọn tệp ảnh hợp lệ."*

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - **Người dùng hủy thao tác:** Nếu người dùng bấm nút "Hủy" hoặc phím Back của Android khi đang ở màn hình camera/gallery: Hệ thống hủy tiến trình nhẹ nhàng, không lưu tệp rác, không hiển thị lỗi gây bối rối, giữ nguyên vị trí màn hình trước đó.
  - **Thiết bị hết bộ nhớ lưu trữ:** Nếu hệ thống không thể lưu tệp ảnh tạm thời do bộ nhớ trong của máy bị đầy, hiển thị thông báo SnackBar cảnh báo: *"Bộ nhớ thiết bị đã đầy. Vui lòng giải phóng dung lượng để tiếp tục chụp ảnh."*

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Tệp ảnh sau khi nén được lưu tạm trong thư mục bộ nhớ đệm ứng dụng (`cache/receipts/`).
  - Tệp này chỉ được chuyển vào thư mục lưu trữ vĩnh viễn (`documents/receipts/`) khi người dùng hoàn thành bước xác nhận và bấm nút "Lưu chi tiêu" tại Feature 4.
  - Nếu người dùng hủy ở bước Review, tệp ảnh tạm thời sẽ được tự động xóa bỏ để tránh lãng phí dung lượng thiết bị.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Trong lúc nén và nạp tệp ảnh (thường diễn ra từ 50ms – 150ms): Hiển thị vòng xoay tiến trình tròn (`CircularProgressIndicator`) màu xanh VKU Navy giữa màn hình với nền mờ nhẹ.
  - Thao tác là non-blocking cho toàn hệ thống nhưng tạm thời khóa nút bấm trong 150ms để ngăn chặn người dùng bấm liên tiếp (Double tap).

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Tại bảng chọn phương thức (*BottomSheet*): Hiển thị rõ ràng biểu tượng vector lớn của Camera và Gallery kèm mô tả ngắn gọn: *"Chụp ảnh hóa đơn giấy hoặc chọn ảnh biên lai điện tử đã chụp sẵn"*.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Rung phản hồi (Haptic Feedback):** Thiết bị rung nhẹ khi người dùng chạm chọn giữa Camera và Gallery.
  - **Chuyển động BottomSheet:** Bảng chọn trượt lên từ cạnh đáy màn hình với đường cong gia tốc mượt mà và làm tối nền xung quanh (Barrier Color).
  - **Tự động hiệu chỉnh xoay ảnh:** Tự động phát hiện hướng xoay cảm biến EXIF để đảm bảo hóa đơn không bị lộn ngược khi đưa vào bộ quét OCR.

---

## Feature 2: Nhận diện Ký tự Quang học Ngoại tuyến (FR-02)
*Xử lý nhận diện ký tự quang học trực tiếp trên vi xử lý của điện thoại thông minh bằng Google ML Kit mà không cần mạng Internet.*

* **Success flow (Luồng thành công chính):**
  1. Nhận đường dẫn tệp ảnh hóa đơn hợp lệ từ Feature 1.
  2. Màn hình hiển thị trạng thái đang quét với hiệu ứng tia quét laser chuyển động trên ảnh hóa đơn.
  3. Động cơ Google ML Kit trên máy phân tích và bóc tách cấu trúc văn bản thô (Text Blocks, Text Lines, Bounding Boxes) trong thời gian $\le 1.500$ ms.
  4. Trả về kết quả văn bản thô đầy đủ theo thứ tự tọa độ từ trên xuống dưới của hóa đơn và tự động kích hoạt bộ phân tích Heuristic (Feature 3).

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - **Kiểm tra tính hợp lệ của ảnh:** Ảnh phải có độ phân giải đủ lớn và có thể giải mã thành dữ liệu hình ảnh.
  - **Trường hợp ảnh trắng/không chữ:** Nếu ảnh chụp mặt bàn, ngón tay hoặc bị lóa sáng 100% không phát hiện được chữ: Hệ thống không bị crash mà xác định danh sách kết quả rỗng và thông báo nhẹ: *"Không tìm thấy nội dung chữ trên hóa đơn. Bạn có thể tự nhập tay thông tin."*

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - **Thiếu tài nguyên phần cứng / Thất bại OCR:** Nếu tiến trình OCR gặp ngoại lệ hệ thống bất ngờ:
    - Hệ thống bắt lỗi an toàn (*Catch exception*), hiển thị hộp thoại thông báo: *"Không thể đọc ảnh hóa đơn này. Vui lòng chụp lại rõ nét hơn hoặc nhập thông tin thủ công."*
    - Cung cấp 2 nút lựa chọn: **"Chụp lại"** (quay lại Feature 1) và **"Nhập thủ công"** (chuyển sang Feature 5 giữ lại ảnh đính kèm).
  - **Bảo toàn ảnh gốc:** Tệp ảnh đã chụp không bị xóa, cho phép người dùng bấm thử quét lại (*Retry*).

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Chuỗi văn bản OCR được lưu tạm thời trong bộ nhớ RAM ứng dụng gắn liền với phiên quét hiện tại. Không lưu chuỗi văn bản thô này vào cơ sở dữ liệu để tránh làm phình tệp SQLite.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - **Hiệu ứng quét thị giác (Scanning Radar Beam):** Ảnh hóa đơn vừa chụp được hiển thị làm mờ nhẹ, phía trên có một thanh quét ngang màu xanh sáng VKU Navy chuyển động trượt lên xuống liên tục tạo cảm giác công nghệ thông minh.
  - Phía dưới thanh quét hiển thị văn bản động: *"Đang nhận diện ký tự ngoại tuyến..."* kèm biểu tượng huy hiệu ổ khóa / ngoại tuyến xanh lá (*100% On-Device & Private*).
  - Có nút **"Hủy"** ở góc trên bên phải để người dùng có thể ngắt tiến trình bất kỳ lúc nào nếu không muốn đợi.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Không áp dụng do đây là bước xử lý chuyển tiếp tự động trong vòng 1-1,5 giây.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - Khi hoàn tất nhận diện, thanh quét biến mất với hiệu ứng mờ dần (*Fade-out*) và màn hình Review (Feature 4) trượt vào từ cạnh phải màn hình.

---

## Feature 3: Bóc tách & Chuẩn hóa Dữ liệu Heuristics (FR-03)
*Tự động trích xuất Tên đơn vị bán hàng, Ngày giao dịch và Tổng tiền thanh toán VNĐ từ văn bản thô bằng các thuật toán Heuristics và biểu thức chính quy (Regex).*

* **Success flow (Luồng thành công chính):**
  1. Tiếp nhận danh sách các dòng chữ từ Feature 2.
  2. **Trích xuất Tên cửa hàng (Merchant):** Thuật toán rà soát 3–5 dòng đầu tiên, đối chiếu từ điển các chuỗi cửa hàng phổ biến tại Việt Nam (WinMart, Circle K, Highlands Coffee, Phúc Long, Co.opmart, GS25...) hoặc chọn dòng chữ in hoa có vị trí nổi bật nhất.
  3. **Trích xuất Ngày giao dịch:** Nhận diện mẫu ngày tháng Việt Nam (`dd/MM/yyyy`, `dd-MM-yyyy`, `yyyy-MM-dd`) và chuyển đổi thành kiểu ngày giờ chuẩn.
  4. **Trích xuất Tổng tiền VNĐ:** Tìm kiếm các từ khóa thanh toán ("Tổng cộng", "Thanh toán", "Total", "Khách phải trả"...), bóc tách số tiền lân cận, chuẩn hóa bỏ dấu chấm/phẩy phân cách hàng nghìn hoặc nhân $1.000$ đối với hậu tố `k`/`K` (ví dụ `45k` $\rightarrow 45.000$ đ).
  5. Điền tự động các giá trị đã trích xuất vào các ô nhập liệu tương ứng trên màn hình Review (Feature 4).

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - **Bộ lọc số tiền vô lý:** Bỏ qua các số nhỏ hơn $1.000$ VNĐ (tránh nhầm lẫn với số bàn "04", số lượng món "02", thứ tự in "01").
  - **Bộ lọc ngày tương lai:** Ngày giao dịch bóc tách không được vượt quá thời điểm hiện tại quá 24 giờ. Nếu vượt quá, hệ thống tự động gán ngày hiện tại (`DateTime.now()`).
  - **Cơ chế Fail-Safe (An toàn khi không chắc chắn):** Nếu không tìm thấy dòng tổng tiền có độ tin cậy cao, trường số tiền được để trống (`null`) để người dùng nhập tay, tuyệt đối không lấy bừa một con số ngẫu nhiên trên hóa đơn.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - Nếu hóa đơn bị mờ phần tên cửa hàng hoặc tổng tiền: Các trường tương ứng trên màn hình Review sẽ hiển thị rỗng kèm viền màu vàng/cam nhắc nhở: *"Chưa nhận diện được, vui lòng điền tay"*.
  - Người dùng chỉ cần chạm tay vào ô để nhập số tiền mà không cần quét lại từ đầu.

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Kết quả bóc tách được chuyển giao trực tiếp cho Form State của màn hình Review.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Thuật toán Regex Heuristic chạy trong bộ nhớ CPU trong thời gian cực ngắn ($< 15$ ms) ngay sau khi OCR hoàn tất, diễn ra tức thì nên không đòi hỏi màn hình chờ riêng biệt.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Không áp dụng.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Huy hiệu Auto-Suggested:** Trên màn hình Review, các trường dữ liệu được hệ thống tự động bóc tách thành công sẽ có một biểu tượng "Tia sét nhỏ" (*Sparkle Icon*) màu xanh lá ở góc phải ô input, biểu thị cho người dùng biết thông tin này đã được hỗ trợ điền tự động.

---

## Feature 4: Màn hình Đối chiếu & Hiệu chỉnh Dữ liệu Hóa đơn (FR-04)
*Cung cấp giao diện trực quan cho phép người dùng đối chiếu ảnh gốc hóa đơn và chỉnh sửa, bổ sung thông tin (Tên quán, Tiền, Ngày, Danh mục, Ghi chú) trước khi lưu vào sổ cái.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng nhìn thấy ảnh hóa đơn ở khung trên và biểu mẫu thông tin ở khung dưới.
  2. Người dùng kiểm tra đối chiếu: Nếu số tiền hoặc tên quán bị nhận diện sai/thiếu, chạm vào ô văn bản để sửa lại.
  3. Người dùng chạm chọn 1 trong 5 danh mục chi tiêu: **Ăn uống**, **Mua sắm**, **Di chuyển**, **Hóa đơn**, **Khác**.
  4. (Tùy chọn) Nhập ghi chú bổ sung hoặc đổi ngày giao dịch qua hộp thoại chọn ngày (*DatePicker*).
  5. Người dùng bấm nút **"Lưu chi tiêu"** (Nút Primary màu xanh VKU Navy toàn chiều rộng).
  6. Hệ thống kiểm tra hợp lệ dữ liệu $\rightarrow$ Hợp lệ $\rightarrow$ Ghi dữ liệu vào SQLite $\rightarrow$ Chuyển ảnh tạm thành ảnh lưu trữ vĩnh viễn $\rightarrow$ Hiển thị thông báo SnackBar thành công $\rightarrow$ Điều hướng về Dashboard.

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - **Tên cửa hàng (`merchant_name`):** Bắt buộc. Nếu để trống khi bấm Lưu $\rightarrow$ Ô nhập liệu đổi viền đỏ, hiển thị dòng chữ báo lỗi đỏ bên dưới: *"Vui lòng nhập tên cửa hàng / người bán"*.
  - **Tổng số tiền (`total_amount`):** Bắt buộc $> 0$.
    - Khi người dùng gõ số, hệ thống tự động định dạng phân cách hàng nghìn theo thời gian thực (gõ `150000` tự nhảy thành `150.000 đ`).
    - Nếu để trống hoặc nhập `0` $\rightarrow$ Viền đỏ, thông báo lỗi: *"Số tiền phải lớn hơn 0 đ"*.
  - **Ngày giao dịch (`transaction_date`):** Bắt buộc. Không cho phép chọn ngày trong tương lai ($> \text{Hôm nay}$).
  - **Danh mục (`category`):** Bắt buộc chọn 1 trong 5 danh mục. Danh mục được chọn có màu nền nổi bật và dấu tích (*Checkmark*).
  - **Phản hồi tức thì:** Dòng thông báo lỗi màu đỏ tự động biến mất ngay khi người dùng gõ ký tự hợp lệ đầu tiên. Nút "Lưu chi tiêu" luôn có thể bấm được để kích hoạt kiểm tra toàn diện.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - **Tự động cuộn đến vị trí lỗi (Auto-Scroll to Error):** Nếu có trường nhập liệu không hợp lệ, màn hình tự động cuộn đến trường bị lỗi đầu tiên và tự động mở bàn phím ảo tại trường đó.
  - **Chống vô tình thoát mất dữ liệu (Unsaved Changes Guard):** Nếu người dùng bấm phím Back hoặc nút mũi tên quay lại trên AppBar khi đã chỉnh sửa dữ liệu, hệ thống hiển thị hộp thoại xác nhận:
    - *Tiêu đề:* "Hủy bỏ chi tiêu này?"
    - *Nội dung:* "Thông tin bạn vừa nhập và ảnh hóa đơn sẽ không được lưu lại."
    - *Hai nút lựa chọn:* **"Tiếp tục sửa"** (Màu trung tính, đóng hộp thoại, giữ nguyên 100% dữ liệu) và **"Hủy bỏ"** (Màu đỏ, xóa ảnh tạm và quay về màn hình trước).

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Dữ liệu chỉ được lưu vào cơ sở dữ liệu SQLite khi người dùng chủ động bấm nút "Lưu chi tiêu" và vượt qua tất cả các bước kiểm tra hợp lệ.
  - Sau khi lưu, bản ghi mới lập tức xuất hiện ở đầu danh sách giao dịch và số liệu trên Dashboard được cập nhật ngay lập tức.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Khi người dùng bấm "Lưu chi tiêu": Nút bấm chuyển sang trạng thái chờ trong ~150ms: Chữ "Lưu chi tiêu" ẩn đi, thay thế bằng vòng xoay nhỏ màu trắng; nút bị vô hiệu hóa để ngăn chặn thao tác bấm đúp liên tiếp (*Double-tap prevention*).

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Nếu hóa đơn không nhận diện được tên cửa hàng hoặc tổng tiền: Các ô tương ứng hiển thị văn bản gợi ý mờ (*Placeholder/Hint*): *"Ví dụ: Highlands Coffee"*, *"0 đ"*.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Tương tác phóng to ảnh (Interactive Viewer):** Người dùng có thể dùng 2 ngón tay chụm mở (Pinch-to-zoom) trực tiếp trên khung ảnh hóa đơn nhỏ để phóng to đến 300%, giúp đọc rõ các con số mờ trước khi điền.
  - **Lựa chọn danh mục dạng ChoiceChip:** 5 danh mục hiển thị dạng hàng nút bo tròn có biểu tượng ngộ nghĩnh (🍔 Ăn uống, 🛍️ Mua sắm, 🚗 Di chuyển, 💡 Hóa đơn, 📦 Khác). Khi chạm chọn, nút nảy nhẹ (*Scale animation*) và đổi sang màu sắc đại diện của danh mục đó.
  - **Tự động mở bàn phím phù hợp:** Chạm vào ô Số tiền tự động mở bàn phím số (*Numeric Keyboard*); chạm vào ô Tên cửa hàng tự động mở bàn phím chữ với chế độ viết hoa chữ cái đầu.

---

## Feature 5: Ghi nhận Chi tiêu Thủ công (FR-05)
*Cho phép người dùng ghi nhanh các khoản chi tiêu không có hóa đơn giấy (ăn sáng tiền mặt, gửi xe, chuyển khoản bạn bè) với trải nghiệm nhập liệu tinh gọn.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng bấm nút Thêm mới (+) nổi (*Floating Action Button*) tại màn hình Dashboard hoặc tab Chi tiêu.
  2. Màn hình mở form "Thêm chi tiêu mới" với trường ngày được gán mặc định là ngày hôm nay.
  3. Người dùng nhập Tên khoản chi (ví dụ: *"Tiền gửi xe tháng"*), nhập Số tiền (ví dụ: *"120.000"*).
  4. Người dùng chọn danh mục **"Di chuyển"**.
  5. (Tùy chọn) Bấm vào khung "Đính kèm ảnh" nếu muốn chụp thêm ảnh biên lai viết tay.
  6. Người dùng bấm **"Lưu chi tiêu"** $\rightarrow$ Hệ thống lưu bản ghi mới với `receipt_image_path = null` $\rightarrow$ SnackBar thông báo thành công $\rightarrow$ Đóng màn hình.

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - Đồng nhất 100% với Feature 4: Tên không được rỗng, số tiền $> 0$, ngày hợp lệ, danh mục hợp lệ.
  - Cảnh báo viền đỏ và thông báo lỗi rõ ràng bên dưới ô nhập liệu khi bấm Lưu nếu vi phạm quy tắc.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - Nếu người dùng đã nhập số tiền hoặc tên nhưng bấm nút Back quay lại: Hiển thị hộp thoại cảnh báo rời màn hình để tránh vô tình mất nội dung đang gõ dở.

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Bản ghi được lưu trực tiếp vào cơ sở dữ liệu SQLite ngay khi bấm nút Lưu.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Thao tác lưu diễn ra dưới 50ms, nút Lưu hiển thị hiệu ứng xoay xử lý nhẹ.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Màn hình mở ra với tất cả các trường trống (ngoại trừ ô Ngày giờ đã điền sẵn ngày hiện tại). Khung đính kèm ảnh hiển thị icon máy ảnh nét đứt mờ kèm dòng chữ: *"Chạm để đính kèm ảnh (Tùy chọn)"*.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - Con trỏ chuột tự động focus vào ô "Số tiền" đầu tiên để người dùng có thể gõ ngay con số mà không cần mất thêm một thao tác chạm màn hình.

---

## Feature 6: Quản lý Kho lưu trữ Chi tiêu Cục bộ & Xóa Tệp Mồ côi (FR-06)
*Bảo đảm toàn vẹn dữ liệu chi tiêu trên thiết bị; tự động dọn dẹp các tệp ảnh liên kết khi xóa giao dịch để chống rác bộ nhớ.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng thực hiện thao tác xóa một giao dịch từ màn hình chi tiết hoặc vuốt thẻ chi tiêu.
  2. Hệ thống hiển thị hộp thoại cảnh báo xác nhận xóa.
  3. Người dùng xác nhận "Xóa" $\rightarrow$ Hệ thống xóa bản ghi khỏi SQLite trong một giao dịch ACID.
  4. Hệ thống kiểm tra tệp ảnh tương ứng trên bộ nhớ máy và thực hiện xóa tệp ảnh vĩnh viễn khỏi thư mục thiết bị.
  5. Bản ghi biến mất khỏi danh sách với hiệu ứng trượt thu nhỏ; Dashboard cập nhật lại số liệu tức thì.

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - Không cho phép thao tác xóa diễn ra âm thầm mà không có sự xác nhận của người dùng.
  - Kiểm tra đường dẫn tệp ảnh: Nếu tệp ảnh không còn tồn tại trên máy (do người dùng đã xóa bằng app Files ngoài), tiến trình xóa bản ghi database vẫn hoàn tất bình thường mà không bị crash.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - Nếu thao tác xóa database thất bại: Toàn bộ tiến trình bị hủy bỏ (*Rollback*), tệp ảnh được giữ nguyên, thông báo lỗi: *"Không thể xóa chi tiêu. Vui lòng thử lại."*
  - Nếu người dùng bấm "Hủy" trên hộp thoại xác nhận: Đóng hộp thoại, giữ nguyên dữ liệu 100%.

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Dữ liệu bị xóa vĩnh viễn khỏi thiết bị và không thể khôi phục (vì ứng dụng không dùng thùng rác trung gian để tiết kiệm dung lượng bộ nhớ).

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Xóa cục bộ hoàn tất trong $< 30$ ms, không làm giật khung hình.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Không áp dụng.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Hộp thoại xác nhận phá hủy (Destructive Confirmation Dialog):**
    - Biểu tượng thùng rác màu đỏ cảnh báo ở đầu hộp thoại.
    - *Tiêu đề:* "Xóa chi tiêu này?"
    - *Nội dung:* "Hành động này sẽ xóa vĩnh viễn thông tin chi tiêu và ảnh hóa đơn liên quan khỏi thiết bị của bạn."
    - Nút "Hủy" màu xám trung tính và nút "Xóa" màu đỏ nổi bật.
  - **Thông báo SnackBar hoàn tác nhanh:** Hiển thị SnackBar *"Đã xóa chi tiêu"* trong 3 giây ở chân màn hình.

---

## Feature 7: Xem Chi tiết & Đối soát Chứng từ Toàn màn hình (FR-07)
*Cho phép người dùng và thủ quỹ kiểm tra lại chứng từ hóa đơn gốc với khả năng phóng to toàn màn hình, phục vụ mục đích kiểm toán và đối soát tài chính.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng chạm vào một thẻ chi tiêu bất kỳ trên danh sách.
  2. Màn hình chi tiết mở ra mượt mà với hoạt ảnh chuyển đổi mở rộng (*Container Transform*).
  3. Hiển thị thông tin tổng quan: Tên cửa hàng cỡ lớn, số tiền in đậm nổi bật, ngày giờ giao dịch, nhãn danh mục có màu riêng biệt và khung ảnh hóa đơn gốc.
  4. Người dùng chạm vào khung ảnh hóa đơn $\rightarrow$ Màn hình xem ảnh toàn màn hình mở ra với nền đen sâu.
  5. Người dùng chụm mở 2 ngón tay để phóng to từng dòng chữ nhỏ trên hóa đơn đối soát với số tiền.
  6. Người dùng vuốt nhẹ ảnh xuống dưới để đóng trình xem ảnh và quay lại màn hình chi tiết.
  7. Người dùng có thể bấm nút "Sửa" (biểu tượng cây bút trên AppBar) để cập nhật lại thông tin hoặc nút "Xóa" (biểu tượng thùng rác) để xóa bản ghi.

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - Kiểm tra sự tồn tại của tệp ảnh: Nếu bản ghi có đường dẫn ảnh nhưng tệp vật lý bị mất, hiển thị thẻ thông báo màu xám nhạt: *"Ảnh biên lai không còn tồn tại trên máy"*.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - Khi xem ảnh toàn màn hình nếu ảnh bị lỗi hiển thị: Cung cấp nút "Đóng" màu trắng nổi bật ở góc trên màn hình để người dùng luôn có đường thoát ra ngoài.

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Đọc dữ liệu trực tiếp từ SQLite; nếu người dùng chuyển sang màn hình Sửa và lưu lại, màn hình chi tiết lập tức hiển thị thông tin mới nhất.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Ảnh hóa đơn lớn được nạp với hiệu ứng làm mờ dần (*FadeInImage*) để tránh cảm giác giật cục khi đọc ảnh độ phân giải cao từ bộ nhớ máy.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Đối với khoản chi tạo thủ công không có ảnh: Vùng ảnh được thay thế bằng thẻ thông tin nhẹ nhàng: *"Khoản chi tiêu này không có ảnh hóa đơn đính kèm"*.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Cử chỉ vuốt để đóng (Swipe-down to dismiss):** Người dùng có thể kéo vuốt ảnh xuống dưới để thoát chế độ xem toàn màn hình một cách tự nhiên.
  - Khả năng zoom ảnh lên đến 400% với bộ lọc mượt mà, thấy rõ từng dấu mộc đỏ hoặc nét mực in nhiệt mờ.

---

## Feature 8: Danh sách Lịch sử Giao dịch, Tìm kiếm & Bộ lọc (FR-08)
*Hiển thị danh sách toàn bộ các khoản chi tiêu có hỗ trợ tìm kiếm thời gian thực theo tên cửa hàng và lọc theo danh mục.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng chuyển sang tab "Lịch sử chi tiêu" trên thanh điều hướng đáy.
  2. Toàn bộ các giao dịch hiển thị theo thứ tự thời gian giảm dần (mới nhất nằm trên cùng), được gom nhóm trực quan theo từng ngày (ví dụ: *"Hôm nay"*, *"Hôm qua"*, *"15 tháng 8, 2026"*).
  3. Người dùng chạm vào thanh tìm kiếm ở đầu trang và gõ: *"Highlands"*.
  4. Danh sách lập tức lọc trong thời gian thực ($< 30$ ms), chỉ giữ lại các hóa đơn có tên cửa hàng chứa từ khóa "Highlands".
  5. Người dùng chạm vào nút chip lọc danh mục **"Ăn uống"** $\rightarrow$ Danh sách tiếp tục kết hợp lọc theo cả từ khóa và danh mục.
  6. Người dùng chạm vào dấu (X) trên thanh tìm kiếm để xóa từ khóa hoặc chạm lại vào chip lọc để bỏ lọc $\rightarrow$ Danh sách khôi phục đầy đủ.

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - **Tìm kiếm không phân biệt chữ hoa/thường và hỗ trợ tiếng Việt:** Gõ "highlands", "HIGHLANDS" hoặc gõ tiếng Việt không dấu "ca phe" vẫn tìm thấy kết quả "Cà phê Highland".
  - Ký tự đặc biệt trong ô tìm kiếm không gây crash ứng dụng.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - Nếu cơ sở dữ liệu có hàng ngàn bản ghi: Hệ thống sử dụng cơ chế ảo hóa danh sách (`ListView.builder`), bảo đảm bộ nhớ RAM chỉ cấp phát cho các thẻ đang hiển thị trên màn hình, ngăn chặn hiện tượng treo ứng dụng (ANR).

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Vị trí cuộn trang (*Scroll position*) được ghi nhớ trong suốt phiên làm việc. Khi người dùng bấm vào xem chi tiết một hóa đơn ở vị trí cuộn thứ 50 rồi quay lại, danh sách vẫn giữ nguyên vị trí cũ mà không bị nhảy lên đầu trang.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Khi ứng dụng vừa khởi động và đang nạp dữ liệu từ SQLite: Hiển thị hiệu ứng **Skeleton Loading** (4 thẻ xám chuyển động làn sóng mềm mại) trong khoảng 100ms.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - **Trường hợp 1 (Chưa có giao dịch nào trong ứng dụng):**
    - Hiển thị hình minh họa vector chiếc ví rỗng thanh lịch ở giữa màn hình.
    - Dòng chữ: *"Chưa có khoản chi tiêu nào được ghi nhận."*
    - Nút bấm Call-To-Action (CTA): **"Quét hóa đơn đầu tiên"** (bấm vào mở ngay Feature 1).
  - **Trường hợp 2 (Tìm kiếm hoặc lọc không có kết quả phù hợp):**
    - Hiển thị hình minh họa chiếc kính lúp.
    - Dòng chữ: *"Không tìm thấy chi tiêu nào khớp với '[từ khóa]'."*
    - Nút bấm CTA: **"Xóa bộ lọc"** để đưa danh sách về trạng thái ban đầu.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Vuốt để làm mới (Pull-to-refresh):** Kéo danh sách từ trên xuống dưới kích hoạt vòng quay làm mới dữ liệu.
  - **Cuộn siêu tốc mượt mà (60/120 FPS):** Thao tác lướt ngón tay diễn ra êm ái, các thẻ lướt qua mượt mà không có độ trễ giật lag.
  - Thẻ chi tiêu có huy hiệu icon tròn mang màu sắc đại diện cho từng danh mục, giúp người dùng nhận diện nhóm chi tiêu chỉ trong một cái nhìn lướt qua.

---

## Feature 9: Biểu đồ Tỷ lệ Chi tiêu Danh mục Canvas Donut (FR-09)
*Tự vẽ đồ thị tròn khuyết (Donut Chart) bằng Canvas CustomPainter trên Dashboard để trực quan hóa tỷ trọng các danh mục chi tiêu trong tháng với hiệu ứng chuyển động cao cấp.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng mở màn hình Dashboard.
  2. Biểu đồ Donut tự động bung mở các cung tròn màu sắc từ góc $0^\circ$ đến $360^\circ$ trong thời gian 1.000 ms với chuyển động chậm dần đều êm ái (*Curves.easeOutCubic*).
  3. Ở chính giữa tâm vòng tròn: Hiển thị tổng số tiền đã chi tiêu trong tháng được định dạng chuẩn tiền tệ tiếng Việt to rõ (ví dụ: *"3.450.000 đ"*).
  4. Ngay bên dưới biểu đồ: Hiển thị danh sách bảng chú giải (*Legend*) gồm: chấm màu danh mục, tên danh mục, tỷ lệ phần trăm (%) và số tiền đã chi.
  5. Người dùng chạm vào một cung tròn trên biểu đồ hoặc chạm vào dòng chú giải tương ứng $\rightarrow$ Cung tròn đó hơi nở rộng ra 4px và hiển thị bóng thông tin chi tiết của danh mục đó.

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - **Xử lý tổng chi tiêu bằng 0:** Nếu trong tháng người dùng chưa chi tiêu đồng nào ($S_{total} = 0$), hệ thống không thực hiện phép chia cho 0 mà tự động vẽ vòng tròn nền xám nhạt với độ mờ 20% và chữ ở tâm: *"0 đ"*.
  - Tỷ lệ phần trăm được làm tròn hợp lý sao cho tổng các phần tử luôn tiệm cận $100\%$.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - Vì biểu đồ được tự vẽ bằng mã nguồn toán học Canvas thuần của Flutter, không có rủi ro crash do thư viện bên ngoài không tương thích nền tảng.

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Biểu đồ tự động vẽ lại và cập nhật góc quét ngay lập tức mỗi khi người dùng thêm, sửa hoặc xóa bất kỳ khoản chi nào trong tháng.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Hoạt ảnh bung nở của `AnimationController` đóng vai trò chuyển tiếp thị giác mượt mà, người dùng không phải nhìn thấy màn hình chờ tĩnh khó chịu.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Khi chưa có dữ liệu trong tháng: Vẽ một vòng tròn viền nét mảnh màu xám nhạt, bên trong hiển thị dòng chữ: *"Chưa có chi tiêu trong tháng này"* kèm nút nhỏ *"Thêm chi tiêu"*.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Hoạt ảnh bung mở (Sweep Angle Expansion):** Cung tròn vẽ lần lượt theo chiều kim đồng hồ mang lại cảm giác sống động và hiện đại.
  - Màu sắc các cung tròn tương phản rõ rệt theo đúng bảng màu thiết kế: Cam (Ăn uống), Xanh dương (Mua sắm), Xanh lá (Di chuyển), Tím (Hóa đơn), Xám (Khác).

---

## Feature 10: Biểu đồ Chi tiêu 7 Ngày Gần nhất Canvas Bar Chart (FR-10)
*Tự vẽ biểu đồ cột (Bar Chart) bằng CustomPainter thể hiện mức độ chi tiêu của 7 ngày liên tiếp gần nhất, giúp người dùng nắm bắt nhịp độ tiêu tiền theo tuần.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng cuộn tới thẻ "Xu hướng 7 ngày" trên Dashboard.
  2. Biểu đồ hiển thị 7 cột chữ nhật bo góc tròn tương ứng với 7 ngày gần nhất (từ 6 ngày trước đến hôm nay).
  3. Các cột dâng dần độ cao từ chân trục tọa độ lên độ cao tỷ lệ tương ứng với số tiền trong thời gian 800 ms.
  4. Bên dưới mỗi cột hiển thị nhãn thứ trong tuần (T2, T3, T4, T5, T6, T7, CN).
  5. Cột của ngày hôm nay được tô màu nổi bật bằng màu chủ đạo VKU Navy (`0xFF2C4570`), các ngày khác mang màu xanh pastel thứ cấp.
  6. Người dùng chạm vào bất kỳ cột nào $\rightarrow$ Phía trên đỉnh cột xuất hiện bong bóng thông tin (*Tooltip Bubble*) hiển thị số tiền chính xác đã chi trong ngày đó (ví dụ: *"145.000 đ"*).

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - **Xử lý ngày có chi tiêu bằng 0:** Cột của ngày không có chi tiêu vẫn giữ độ cao tối thiểu 4px (dạng vạch bo tròn mờ) để người dùng phân biệt được vị trí của ngày đó trên trục thời gian.
  - **Tự động co giãn tỷ lệ trục Y:** Cột có chi tiêu lớn nhất trong 7 ngày sẽ chiếm $85\%$ chiều cao tối đa của khung Canvas, các cột còn lại tự động chia tỷ lệ tương đối theo cột lớn nhất, bảo đảm không bao giờ có cột bị vượt đỉnh khung vẽ.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - Tự động thích ứng khi qua ngày mới: Khi đồng hồ thiết bị bước sang ngày mới, biểu đồ tự động cập nhật lại nhãn 7 ngày mà không cần khởi động lại ứng dụng.

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Dữ liệu được tính toán nhanh từ các bản ghi có trường `transaction_date` trong khoảng 7 ngày gần nhất.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Hoạt ảnh dâng cột mượt mà 800ms với gia tốc `Curves.easeOutQuart` thay thế cho trạng thái chờ.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Nếu trong cả 7 ngày đều không có chi tiêu: 7 cột hiển thị ở độ cao vạch đáy mờ kèm dòng chữ nhỏ: *"Không có giao dịch nào trong 7 ngày qua"*.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Tương tác chạm cột (Tap to show Tooltip):** Khi chạm vào một cột, cột đó sáng lên nhẹ và bong bóng hiển thị số tiền xuất hiện ngay trên đỉnh cột trong 3 giây trước khi mờ dần.
  - Các cột được bo góc tròn mềm mại ở đỉnh (`Radius.circular(6)`).

---

## Feature 11: Chuyển đổi Chủ đề Sáng / Tối Material 3 (FR-11)
*Cho phép người dùng chuyển đổi linh hoạt giữa giao diện Sáng (Light Mode) và Tối (Dark Mode) hoặc đi theo hệ thống, bảo đảm tính thẩm mỹ và độ tương phản cao.*

* **Success flow (Luồng thành công chính):**
  1. Người dùng chạm vào nút chuyển đổi biểu tượng "Mặt trăng / Mặt trời" ở góc trên AppBar hoặc trong màn hình Cài đặt.
  2. Bảng chọn hiển thị 3 tùy chọn: **"Sáng"**, **"Tối"**, và **"Theo hệ thống"**.
  3. Người dùng chọn **"Tối"** (Dark Mode).
  4. Toàn bộ giao diện ứng dụng đổi sang bảng màu tối sang trọng: Nền đen sâu / xám than OLED (`0xFF121212`), bề mặt thẻ chuyển sang `SurfaceContainer` tương phản dịu mắt, chữ chuyển sang màu trắng ngà.
  5. Màu nền và nhãn chữ của biểu đồ Canvas (Donut chart và Bar chart) tự động đảo màu để giữ độ tương phản hoàn hảo.
  6. Tùy chọn được lưu lại vĩnh viễn trên thiết bị.

* **Validation behavior (Quy tắc kiểm tra & Phản hồi):**
  - **Đảm bảo độ tương phản chuẩn WCAG AA:** Toàn bộ văn bản trên nền trong cả hai chế độ Light và Dark bắt buộc đạt tỷ lệ tương phản tối thiểu **4.5:1**, loại trừ hoàn toàn tình trạng chữ xám tối chìm trên nền đen.

* **Failure & Recovery behavior (Xử lý sự cố & Phục hồi):**
  - Nếu tệp lưu trữ cài đặt bị lỗi: Ứng dụng tự động khôi phục chế độ mặc định "Theo hệ thống" mà không gây lỗi ứng dụng.

* **Persistence & Access behavior (Lưu trữ & Trạng thái dữ liệu):**
  - Lựa chọn theme được lưu tức thì vào bộ nhớ cài đặt cục bộ và được nạp ngay trước khi render giao diện lần đầu, ngăn chặn hiện tượng nháy sáng màn hình (*Flash of Light Theme*) khi mở app ban đêm.

* **Loading / Pending state (Trạng thái chờ xử lý):**
  - Quá trình chuyển đổi diễn ra tức thì trong $< 16$ ms (trong vòng 1 khung hình), mượt mà và không đòi hỏi trạng thái chờ.

* **Empty state (Trạng thái rỗng / Lần đầu sử dụng):**
  - Mặc định lần đầu cài đặt ứng dụng: Tự động kế thừa theo chế độ Sáng/Tối hiện tại của hệ điều hành Android.

* **User observable interactions (Tương tác chi tiết quan sát được):**
  - **Hoạt ảnh xoay biểu tượng (Animated Icon Switch):** Biểu tượng Mặt trời xoay nhẹ và biến hình thành Mặt trăng với hiệu ứng mượt mà khi đổi chế độ.
  - Bảng màu sinh từ Seed Color VKU Navy (`Color(0xFF2C4570)`), tạo cảm giác liền mạch, đồng bộ và đậm chất nhận diện thương hiệu.
