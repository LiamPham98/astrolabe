---
name: spec-check
description: Soát spec của một tính năng trước khi thiết kế (trùng, mâu thuẫn, không đo được, số lệch, thiếu nghiệm thu, lỗ hổng, thuật ngữ lệch) và chấm checklist sẵn sàng. Chỉ đọc, không sửa spec. Dùng khi feature-flow tới cuối giai đoạn 2, hoặc khi gõ /feature-workflow:spec-check.
---

# spec-check: soát spec trước khi thiết kế

Đọc spec cùng các file đi kèm, tìm lỗi khiến thiết kế hoặc code phải làm lại, rồi chấm checklist sẵn sàng. Bước này **chỉ đọc**: không sửa spec, không sửa quyết định. Mọi phát hiện trả về cho feature-flow để đưa lại vào grill hoặc to-spec.

Cấu trúc tham khảo bước soát và checklist sẵn sàng của vibebiz (finolabs/vibebiz), viết lại cho team kỹ thuật.

## Đầu vào

- Spec (đường dẫn trong `docs/features/<slug>/flow.md`).
- `why.md`, `decisions.md` của tính năng, nếu có.
- `GLOSSARY.md`, `docs/flow-rules.md`.

## 1. Lập danh mục trước

Trước khi soát, liệt kê từ các file: user story, yêu cầu, tiêu chí thành công, mọi con số (giá trị, đơn vị, kỳ, nguồn, chỗ xuất hiện), thuật ngữ, câu hỏi còn mở, quyết định hiện hành (bỏ các quyết định đã bị `supersede`).

## 2. Các lượt soát

Chạy hết tám lượt. Chữ cái là tiền tố mã phát hiện.

- **D. Trùng**: hai story, yêu cầu, tiêu chí hay rủi ro nói cùng một ý; một con số mang hai tên.
- **X. Mâu thuẫn**: hai câu không thể cùng đúng; spec còn áp quyết định đã bị thay; phạm vi trong spec khác phương án đã chọn trong `why.md`; spec bỏ qua việc mà file luật bắt buộc người duyệt.
- **M. Không đo được**: kết quả thiếu mốc hoặc kế hoạch đo, mục tiêu, thời hạn, chỉ số không được xấu đi hay ngưỡng dừng; tiêu chí nêu việc làm thay vì kết quả; từ mơ hồ không có số ("nhanh", "tốt hơn", "dễ dùng").
- **F. Số lệch**: cùng một số mà khác giá trị, đơn vị hay kỳ ở hai chỗ; số không có nguồn, kỳ hoặc nhãn; số suy ra không khớp với số gốc; số giả định được trình bày như số đo thật.
- **A. Thiếu nghiệm thu**: story không có kịch bản Given/When/Then, hoặc kịch bản không kiểm được bằng cách quan sát; yêu cầu không story nào phủ; story ưu tiên cao nhất không tiêu chí nào đo; quyết định do AI đưa ra mà không có điểm người duyệt.
- **G. Lỗ hổng**: mục bắt buộc còn trống; câu hỏi còn mở loại chặn mà chưa có người phụ trách; giả định rủi ro nhất chưa có cách kiểm.
- **T. Thuật ngữ lệch**: hai từ cho một thứ giữa các file; thuật ngữ dùng khác nghĩa trong `GLOSSARY.md`.
- **P. Nguyên tắc**: khi có `why.md` mà phương án được chọn là xây mới, phải có dấu vết đã cân nhắc không làm và sửa quy trình; rủi ro từng nêu mà nay biến mất phải có trong `decisions.md`.

## 3. Mức nghiêm trọng

| Mức | Nghĩa | Ví dụ |
|---|---|---|
| Nghiêm trọng | Thiết kế sẽ dựa trên điều sai | số hai giá trị; mâu thuẫn với quyết định hiện hành; bỏ qua việc trong file luật mà không có quyết định |
| Cao | Không kiểm được điều spec hứa | kết quả không đo được; story thiếu nghiệm thu; câu hỏi chặn chưa có người phụ trách |
| Vừa | Dễ hiểu sai nhưng không đổi quyết định | thuật ngữ lệch; yêu cầu không story nào phủ |
| Thấp | Câu chữ, trình bày | trùng ý cùng nghĩa |

## 4. Checklist sẵn sàng

Đánh dấu một mục là đạt chỉ khi file thật sự thỏa. Mục không đạt thì ghi ngắn: file nào, thiếu gì.

1. Mục tiêu, phạm vi và cái nằm ngoài phạm vi đã rõ.
2. Mỗi story có ưu tiên và ít nhất một kịch bản Given/When/Then kiểm được.
3. Mỗi yêu cầu kiểm được và có mã riêng.
4. Tiêu chí thành công đo được và khớp với chỉ số trong `why.md` (nếu có).
5. Trường hợp ngoại lệ và lỗi đã liệt kê.
6. Dữ liệu dùng tới có nguồn và chủ sở hữu.
7. Hệ thống tích hợp được nêu tên.
8. Mọi thuật ngữ spec dùng đều có trong `GLOSSARY.md`.
9. Mọi câu hỏi còn mở đánh dấu chặn hay không chặn, có người phụ trách.
10. Không còn chỗ đánh dấu "cần làm rõ" ngoài các mục đã ghi là hoãn.
11. Việc trong file luật mà tính năng chạm tới đều có bước người duyệt.
12. Mọi con số có nguồn, kỳ và nhãn đo thật hoặc giả định.

## 5. Đầu ra

Ghi `docs/features/<slug>/feature-workflow:spec-check.md`:

- **Kết luận**: `qua` hoặc `quay-lại`. Có phát hiện nghiêm trọng hoặc cao, hoặc mục 1, 2, 3, 11 của checklist không đạt, thì là `quay-lại`.
- **Phát hiện**: mỗi phát hiện một dòng gồm mã (ví dụ `X-02`), mức, chỗ (file và mục), điều sai, và câu cần hỏi để sửa, viết sẵn để đưa vào grill hoặc to-spec.
- **Checklist**: 12 mục, đạt hay không, kèm ghi chú.

Trả kết quả cho feature-flow. Không tự sửa spec, kể cả lỗi câu chữ.
