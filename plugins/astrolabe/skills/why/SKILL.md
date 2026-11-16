---
name: why
description: Chốt "có nên làm không, làm để đạt gì, lấy gì để biết là đúng" cho một tính năng trước khi grill hoặc spec. Dùng khi astrolabe:flow bật công tắc why, hoặc khi gõ /astrolabe:why.
---

# astrolabe:why: có nên làm không

Bước này trả lời câu hỏi mà `/mattpocock-skills:grill-with-docs` mặc định coi như đã có: tính năng này có đáng làm không. Nó phỏng vấn người làm theo từng vòng ngắn, phản biện thẳng, và ghi kết quả vào `why.md` trong thư mục tính năng.

Cấu trúc bước này tham khảo phần phân tích của vibebiz (finolabs/vibebiz): cây phụ thuộc giữa các mục, xếp hạng câu hỏi, giao thức hỏi, phản biện và luật chống khen. Nội dung viết lại cho team kỹ thuật, không sao chép.

## Luật không bao giờ phá

1. **Không khen** ý tưởng, câu trả lời hay quyết định của người làm. Chỉ nói câu trả lời vừa ghi thay đổi gì.
2. **Mỗi vòng có câu phản biện phải nêu ít nhất một lý do cụ thể** khiến tính năng có thể thất bại: ai hoặc cái gì hỏng, hỏng thế nào, dựa trên cơ sở nào (dữ liệu có sẵn, code, hay thông lệ, ghi rõ là cái nào).
3. **Mọi con số có nguồn, kỳ đo và nhãn** "đo thật" hoặc "giả định". Chưa có mốc hiện tại thì ghi kế hoạch đo, không tự điền số.
4. **Rủi ro người làm chọn bỏ qua được ghi lại** vào `decisions.md` loại `dismissed-risk`, kèm lý do. Không xoá về sau.
5. **Một mục chỉ được tạm hoãn khi có lý do** ghi lại.
6. Đẩy lùi một rủi ro mà không có bằng chứng mới thì giữ nguyên rủi ro đó.

## Tra trước khi hỏi

Người làm quyết định; agent tìm dữ kiện. Trước mỗi câu hỏi, tìm câu trả lời theo thứ tự:

1. Mô tả tính năng, thư mục tính năng (đường dẫn trong `flow.md`), luật duyệt áp cho tính năng (`rules/common.md` của repo trung tâm nếu có workspace, cùng `docs/flow-rules.md` của từng repo).
2. Các tính năng khác, `GLOSSARY.md` và ADR, tìm theo `docsBackend` (mục "Nơi lưu tài liệu" trong skill `astrolabe:flow`): luôn đọc thư mục local, `GLOSSARY.md` và `docs/adr/` trong repo; với `orrery`, đọc thêm folder `<repo>/features/` (bằng `note_search`), `<repo>/GLOSSARY.md` và `<repo>/adr/` trong space.
3. Code liên quan: đọc trực tiếp để biết hệ thống đang làm gì. Cần hiểu sâu một subsystem thì đề nghị người làm gõ `/pstack:how`.

Tìm được thì ghi dữ kiện kèm nguồn, và chỉ hỏi phần quyết định còn lại. Không hỏi lại điều file hoặc code đã trả lời.

## Độ sâu

Xếp tính năng vào một trong bốn loại, dựa trên những gì đã có, không hỏi người làm:

| Loại | Dấu hiệu | Cách hỏi |
|---|---|---|
| Đã rõ | nguyên nhân và cách sửa đã biết, nhỏ, dễ quay lại | Chỉ hỏi mục còn thiếu, một câu mỗi mục |
| Cần phân tích | trả lời được bằng dữ liệu, chuyên gia hoặc so sánh phương án | Hỏi đủ các mục |
| Khó đoán trước | kết quả phụ thuộc phản ứng của người dùng, chỉ thấy sau khi thử | Hỏi đủ, bắt buộc có ngưỡng dừng, đề xuất thử nhỏ có nhóm đối chứng trước khi tung rộng |
| Đang khủng hoảng | sự cố đang gây hại ngay lúc này | Nói rằng sự cố cần xử lý trước, ghi lại ý tưởng, dừng |

Lưỡng lự giữa hai loại thì chọn loại sâu hơn. Nói loại đã chọn bằng một câu thường, không dùng tên loại.

## Các mục cần làm rõ

Chỉ hỏi một mục khi các mục nó phụ thuộc đã rõ hoặc đã hoãn có lý do.

| Mã | Mục | Cần có | Phụ thuộc |
|---|---|---|---|
| P | Vấn đề | lần gần nhất chuyện xảy ra, ai gặp, tần suất, chi phí hiện tại có nguồn, nguyên nhân gốc, vì sao làm bây giờ | — |
| S | Người liên quan | ai dùng, ai bị ảnh hưởng, ai duyệt, ai có thể phản đối | P |
| O | Kết quả | chỉ số, mốc hiện tại hoặc kế hoạch đo, mục tiêu, thời hạn | P |
| G | Giới hạn | ít nhất một chỉ số không được xấu đi, ít nhất một ngưỡng dừng có ngày | O |
| A | Phương án | không làm gì, sửa quy trình, mua hoặc cấu hình cái có sẵn, xây mới; mỗi phương án nêu ảnh hưởng tới O, chi phí thô, rủi ro chính | P, O |
| X | Phạm vi | luồng chính theo thứ tự ưu tiên, cái nằm ngoài phạm vi, bản đầu tiên tự đứng được | O, A |
| AI | Có cần AI không | quy tắc, tự động hoá hay AI; dữ liệu có sẵn; AI sai thì thiệt hại gì; điểm người phải duyệt | X (chỉ khi có AI) |
| R | Rủi ro | giả định rủi ro nhất, tuân thủ, dữ liệu nhạy cảm, việc trong file luật bị chạm | X |
| C | Thay đổi tổ chức | ai mất quyền hoặc thêm việc, cần đào tạo ai | S, X |
| Z | Quy mô | S, M hoặc L; có cần chia nhiều MR không | A, X |

Chỉ số ở O là chỉ số của **chính tính năng** (tính năng thay đổi điều gì), không phải dữ liệu mà hệ thống hiển thị cho người dùng.

## Chọn câu hỏi cho mỗi vòng

1. Lấy các mục đủ điều kiện hỏi (phụ thuộc đã rõ) mà còn thiếu hoặc mới rõ một phần.
2. Chấm mỗi mục **mức tác động × mức chưa rõ**, mỗi yếu tố từ 1 đến 3. Tác động là câu trả lời thay đổi phạm vi, chi phí hay quyết định làm nhiều đến đâu.
3. Hỏi mục điểm cao trước. Bằng điểm thì ưu tiên mục có nhiều mục khác phụ thuộc vào nó.

## Cách hỏi

- Mỗi vòng tối đa 4 câu, gửi trong một lần gọi công cụ hỏi trắc nghiệm.
- Mỗi câu tự đứng được: nêu tên tính năng, không viết "như trên", không dùng mã mục.
- 2 đến 4 phương án loại trừ nhau. Phương án đề xuất đứng đầu, gắn "(Đề xuất)", mô tả bắt đầu bằng lý do đề xuất. Không có bằng chứng nghiêng về bên nào thì đề xuất phương án dễ quay lại nhất.
- Không thêm phương án "Khác" hay "Không": người làm luôn có ô tự nhập và nút bỏ qua.
- Hỏi xong vòng nào, ghi ngay vào `why.md` và `decisions.md` vòng đó, trong thư mục tính năng (cách đọc ghi theo mục "Nơi lưu tài liệu" trong skill `astrolabe:flow`). Chưa có `decisions.md` thì tạo từ mẫu trong `templates/` của skill `astrolabe:flow`.
- Mặc định 3 vòng mỗi phiên. Hết 3 vòng mà chưa xong thì hỏi: hỏi tiếp, tạm dừng, hay ghi bản nháp với các mục chưa rõ đánh dấu "chưa làm rõ".

## Kỹ thuật

- **Từ thứ muốn có sang kết quả**: người làm hay nêu một thứ ("có màn hình X"). Viết lại thành "chỉ số Y đổi từ A sang B trước ngày D, cho ai". Đưa 2 đến 3 bản nháp để chọn.
- **Giả định đã thất bại**: giả sử 6 tháng sau tính năng bị gỡ. Viết 3 lý do dễ xảy ra nhất từ những gì file và code cho thấy, hỏi lý do nào dễ xảy ra nhất.
- **Giả định rủi ro nhất**: liệt kê những gì phải đúng thì tính năng mới có ích (người dùng muốn, đáng chi phí, làm được với dữ liệu và người hiện có, dùng được, công bằng và hợp luật). Giả định quan trọng nhất mà ít bằng chứng nhất là giả định rủi ro nhất.
- **Chi phí của việc không làm**: lấy chi phí hiện tại ở P nhân với thời hạn ở O. Vấn đề đang tự nhỏ đi thì nói ra, vì khi đó không làm là phương án thật.
- **Thử nhỏ**: khi giả định rủi ro nhất chưa được kiểm, hoặc tính năng thuộc loại khó đoán trước, thiết kế lần thử rẻ nhất: nhóm thử, nhóm đối chứng, thời gian đủ một chu kỳ dùng thật, chỉ số đọc, kết quả nào thì dừng.

## Khi câu trả lời mâu thuẫn với quyết định cũ

Không ghi câu trả lời mới ngay. Vòng sau hỏi đầu tiên: giữ quyết định cũ (nêu ngày) hay thay bằng câu mới; đề xuất bên có nhiều bằng chứng hơn. Thay thì ghi `supersede` vào `decisions.md` kèm lý do. Quyết định cũ vẫn giữ trong sổ.

## Xong khi

- P, O, G, A đã rõ. AI đã rõ nếu tính năng có AI. Z có ít nhất một quy mô.
- Các mục còn lại rõ, hoặc hoãn có lý do.

Khi xong, ghi `why.md` từ mẫu `templates/why.md` cạnh file SKILL.md này, gồm cả phần gợi ý công tắc cho astrolabe:flow, mỗi gợi ý một dòng lý do:

- `state` khi tính năng chạm vòng đời hoặc trạng thái;
- `contest` khi khó đảo ngược;
- `sec` khi chạm dữ liệu nhạy cảm, tiền, quyền;
- `multi` khi Z cần nhiều MR hoặc nhiều phiên.

Rồi trả lại cho astrolabe:flow để trình cửa "chốt có làm". Phương án được chọn là không làm gì hoặc sửa quy trình thì nói rõ là luồng nên dừng ở đây.
