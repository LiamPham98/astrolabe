---
name: feature-help
description: "Trả lời câu hỏi về luồng feature-workflow: đang ở giai đoạn nào, gõ lệnh gì tiếp, skill nào hợp, lệnh nào không dùng, tài liệu nằm đâu (file local hoặc Orrery). Khi câu hỏi chỉ thuộc một bộ (finolabs, pstack, Matt), trỏ sang skill trợ giúp của bộ đó. Chỉ đọc. Dùng khi gõ /feature-workflow:feature-help hoặc khi người làm hỏi nên dùng skill nào."
---

# feature-help: hỏi về luồng

Trả lời câu hỏi của người làm về luồng làm tính năng, bằng lời thường, và kết thúc bằng đúng lệnh cần gõ tiếp. Skill này **chỉ đọc**: không ghi file, không ghi note, không chạy skill khác thay người làm.

Nói với người làm bằng ngôn ngữ họ đang dùng. Giữ nguyên tên lệnh, tên plugin, đường dẫn.

## Nguồn sự thật

Trả lời từ các file này, không từ trí nhớ. Hai nguồn nói khác nhau thì nói ra cả hai.

1. `skills/feature-flow/SKILL.md` của plugin này: giai đoạn, cửa, preset, công tắc, nơi lưu tài liệu.
2. `README.md` và `docs/cheat-sheet.md` của repo trung tâm, nếu phiên thấy được.
3. Luật duyệt áp cho repo đang mở: `rules/common.md` của repo trung tâm và `docs/flow-rules.md` của repo.

## 1. Xác định người làm đang ở đâu

Chỉ làm khi câu hỏi gắn với một tính năng cụ thể ("tôi làm tiếp gì", "tính năng X tới đâu rồi").

- Tìm `flow.md` của tính năng theo `docsBackend` (mục "Nơi lưu tài liệu" của `feature-flow`): `local` thì tìm trong thư mục local; `orrery` thì `note_search` trong folder `<repo>/features/` của space, và tìm cả thư mục local khi phiên không có Orrery.
- Đọc preset, công tắc đã bật, các cửa đã qua, MR đã merge, và id changeset còn chờ duyệt.
- Suy ra giai đoạn hiện tại và bước tiếp theo. Ghi revision của `flow.md` đã đọc trong câu trả lời.

Không tìm thấy `flow.md` thì nói tính năng chưa bắt đầu và đưa lệnh `/feature-workflow:feature-flow <small|medium|large> <mô tả>`.

## 2. Chọn câu trả lời

| Người làm muốn | Trả lời bằng lệnh |
|---|---|
| Bắt đầu một tính năng | `/feature-workflow:feature-flow <small\|medium\|large> <mô tả>` |
| Cài máy, thêm repo, sửa workspace, chọn nơi lưu tài liệu | `/feature-workflow:feature-setup` |
| Biết tính năng có đáng làm không | `/feature-workflow:feature-why`, hoặc bật `why` trong `feature-flow` |
| Soát một spec đã có | `/feature-workflow:spec-check` |
| Chọn preset | bảng "Chọn quy mô" trong `docs/cheat-sheet.md` |
| Làm tiếp tính năng đang dở | lệnh của bước tiếp theo theo mục 1 |

Câu hỏi về một bước cụ thể trong luồng thì trả lời theo `feature-flow` trước, kể cả khi bước đó dùng skill của bộ khác. Ví dụ: "khi nào chạy `/pstack:statechart`" trả lời theo công tắc `state`.

## 3. Trỏ sang trợ giúp của từng bộ

Chỉ trỏ khi câu hỏi nằm trong một bộ và không đổi luồng (cách skill đó chạy, tham số, lỗi của nó):

| Câu hỏi về | Lệnh |
|---|---|
| Kiểm, review, cửa merge, restore-point, setup (finolabs) | `/finolabs-vibecode:help <câu hỏi>` |
| Thiết kế, code, poteto-mode, statechart (pstack) | `/pstack:poteto-help <câu hỏi>` |
| Grill, spec, ticket, ADR, thuật ngữ (Matt) | `/mattpocock-skills:ask-matt <câu hỏi>` |

Khi trỏ, nhắc một câu: trợ giúp của bộ đó không biết luồng này; gợi ý nào trái với "Không dùng" ở dưới thì bỏ qua và quay lại `/feature-workflow:feature-help`.

## Không dùng

Luồng này không dùng các lệnh dưới. Người làm hỏi tới thì nói lý do và đưa lệnh thay thế.

- `/mattpocock-skills:implement` và `none.md implement` của finolabs: phần code đi qua `/pstack:poteto-mode` ở giai đoạn 4.
- `/pstack:how` chạy riêng trước `architect`: Phase A của `/pstack:architect` đã chạy `how`.
- Agent merge thay người làm, hoặc agent tự duyệt changeset của Orrery: người làm tự merge, người khác tác giả duyệt changeset.
- Tắt cửa duyệt mà luật duyệt bắt buộc.

## Đầu ra

- Một đến ba câu trả lời đúng câu hỏi, có nguồn (file hoặc note kèm revision).
- Một khối lệnh để gõ tiếp, đủ tiền tố plugin. Lệnh chạy ở repo khác thì thêm `/cd ../<repo>` trước.
- Câu hỏi có nhiều cách hiểu thì hỏi lại một câu, phương án đề xuất đứng đầu, thay vì đoán.
