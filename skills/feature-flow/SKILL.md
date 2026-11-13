---
name: feature-flow
description: Dẫn một tính năng qua luồng đã chốt (điều phối, có nên làm, hiểu yêu cầu, thiết kế, lặp từng MR, sau ra mắt). Dùng khi gõ /feature-flow hoặc khi bắt đầu làm một tính năng mới.
---

# feature-flow

Dẫn một tính năng qua luồng làm tính năng của team. Luồng có một xương sống cố định và các giai đoạn tuỳ chọn bật theo đặc điểm tính năng. Phần làm và kiểm lặp lại cho từng MR.

Cách gọi: `/feature-flow <small|medium|large> <mô tả tính năng>`. Thiếu quy mô thì hỏi.

## Nguyên tắc

- **Bốn cửa dừng duyệt**: chốt có làm, duyệt spec, chốt thiết kế, duyệt và merge mỗi MR. Ở bốn cửa này, dừng và chờ người làm trả lời. Ngoài bốn cửa, trình kết quả rồi đi tiếp.
- **Lệnh chỉ người gõ được**: phần lớn skill của pstack và Matt tắt model-invocation. Với các skill đó, in đúng câu lệnh để người làm gõ, kèm đường dẫn spec hoặc thiết kế cần dùng. Không giả lập skill đó bằng cách tự làm thay.
- **Không merge thay người làm.** Không tắt cửa duyệt mà file luật bắt buộc.
- **Mọi lệnh sau giai đoạn 2 đều kèm đường dẫn spec** (file hoặc link issue).
- Không dùng `/implement` của Matt hay `none.md implement`. "Không adopt path Matt" chỉ có nghĩa là không dùng chuỗi implement của Matt; vẫn dùng `/grill-with-docs` và `/to-spec`.

## Thư mục của một tính năng

Mọi file do luồng này tạo nằm ở `docs/features/<slug>/`, với `<slug>` là tên tính năng viết thường, không dấu, nối bằng gạch ngang:

| File | Ai ghi | Nội dung |
|---|---|---|
| `flow.md` | feature-flow | Biên lai: preset, công tắc, lý do, các cửa đã qua |
| `why.md` | skill `why` | Kết quả bước Why |
| `spec-check.md` | skill `spec-check` | Kết quả soát spec |
| `decisions.md` | mọi bước | Sổ quyết định, chỉ ghi thêm |

Spec nằm ở nơi `/to-spec` lưu (mặc định markdown local theo cấu hình `setup-matt-pocock-skills`). Ghi đường dẫn spec vào `flow.md`.

Mẫu của `flow.md` và `decisions.md` nằm trong thư mục `templates/` cạnh file SKILL.md này. Mẫu `why.md` nằm cạnh skill `why`.

## Giai đoạn 0: Điều phối

1. **coding-router**: nếu chưa có biên lai của coding-router cho tính năng này, load `coding-router` để inspect, chọn path và độ sâu. Path luôn là luồng này.
2. **File luật**: đọc `docs/flow-rules.md`. Nếu chưa có, nói một câu rằng repo chưa có file luật và đề nghị tạo từ `templates/flow-rules.md` cạnh file SKILL.md này; tiếp tục với danh sách rỗng.
3. **Preset và công tắc**: bắt đầu từ preset, rồi chỉnh từng công tắc theo tính năng thật.

   | Công tắc | Bật khi | Bật giai đoạn hoặc bước | S | M | L |
   |---|---|---|---|---|---|
   | `why` | tính năng mới tốn công, cần sếp hoặc nghiệp vụ duyệt, có AI, chạm dữ liệu nhạy cảm | giai đoạn 1 và 5 | | | ✓ |
   | `unclear` | yêu cầu còn mơ hồ, luật nghiệp vụ hoặc thuật ngữ mới | `/grill-with-docs` | | ✓ | ✓ |
   | `multi` | làm qua nhiều phiên, nhiều người hoặc nhiều MR | `/to-spec`, `spec-check` | | | ✓ |
   | `cross` | code vượt biên hàm, chạm nhiều module hoặc hợp đồng | `/architect` | | ✓ | ✓ |
   | `contest` | thiết kế có tranh cãi hoặc khó đảo ngược (schema, migration) | `/interrogate` | | | ✓ |
   | `state` | có máy trạng thái | `/statechart` | | | ✓ |
   | `sec` | đụng tiền, quyền, dữ liệu cá nhân | `/security-review-gate` | | | |
   | `repo` | chạm nhiều repo | restore-point mỗi repo, thứ tự merge | | | ✓ |

   Hỏi những công tắc chưa rõ từ mô tả, tối đa 4 câu trong một lần hỏi. Đọc code liên quan nếu cần để trả lời thay vì hỏi.
4. **Khóa theo file luật**: nếu tính năng chạm một việc trong file luật, cửa duyệt mà việc đó yêu cầu không được tắt, và bật `sec` nếu việc đó đánh dấu cần security review. Ghi rõ việc nào trong file luật bị chạm.
5. **Biên lai**: ghi `flow.md` từ mẫu: preset, từng công tắc bật hay tắt kèm một dòng lý do, các repo liên quan, việc bị khóa theo file luật.
6. **Kế hoạch**: trình chuỗi lệnh sẽ gõ theo các công tắc đã bật. Chờ người làm đồng ý (xác nhận nhanh, không phải cửa).

Preset small bỏ giai đoạn 1, 2, 3: đi thẳng tới restore-point rồi giai đoạn 4, để `poteto-mode` chạy playbook đầy đủ. Playbook tự gọi `how` và `architect` khi code vượt biên hàm.

## Giai đoạn 1: Có nên làm không (khi bật `why`)

1. Load skill `why`. Nó phỏng vấn, phản biện và ghi `why.md`.
2. **Cửa: chốt có làm.** Trình tóm tắt `why.md` và hỏi làm hay không.
3. Chọn không làm, hoặc phương án được chọn là sửa quy trình hay không làm gì: ghi quyết định vào `decisions.md`, cập nhật `flow.md`, dừng luồng.
4. Áp các gợi ý công tắc trong `why.md` vào `flow.md` nếu người làm đồng ý.

## Giai đoạn 2: Hiểu yêu cầu (khi bật `unclear` hoặc `multi`)

1. Khi bật `unclear`: in lệnh `/grill-with-docs` cho người làm gõ. Nếu có `why.md`, nhắc rằng grill chỉ hỏi phần `why.md` chưa chốt và đưa đường dẫn `why.md`.
2. Khi bật `multi`: in lệnh `/to-spec`. Ghi đường dẫn spec vào `flow.md`. Thêm `/to-tickets` nếu người làm muốn tách ticket.
3. Khi bật `unclear` mà không bật `multi`: sau grill, ghi các quyết định đã chốt vào `decisions.md` thay cho spec.
4. Khi bật `why` hoặc `multi`: load skill `spec-check` trên spec vừa ghi. Kết quả có phát hiện mức nghiêm trọng hoặc cao thì quay lại grill hoặc to-spec với đúng các câu hỏi `spec-check` nêu.
5. **Cửa: duyệt spec.** Trình spec cùng kết quả `spec-check`.

## Giai đoạn 3: Thiết kế (khi bật `cross`, `contest` hoặc `state`)

Không chạy `/how` riêng: Phase A (Ground) của `architect` đã chạy `how`.

1. Khi bật `cross` hoặc `contest`, in lệnh:
   `/architect with checkpoint. stop and show me before implementing. Spec: <đường dẫn spec>`
   Mở đầu checkpoint bằng một đoạn nhắc lại mục tiêu tính năng bằng lời của agent, để người làm sửa nếu hiểu sai.
2. Khi bật `contest`: in lệnh `/interrogate` trên thiết kế vừa ra. Chỉ giữ finding chạy lại được.
3. Khi bật `state`: in lệnh `/statechart` trên thiết kế, **trước khi viết code**. Đường lỗi TLC tìm ra thì sửa thiết kế ngay ở giai đoạn này.
4. **Cửa: chốt thiết kế.** Gộp checkpoint của architect, finding của interrogate và kết quả statechart thành một lần duyệt. Ghi quyết định thiết kế vào `decisions.md`.

## Trước khi code

In lệnh `/restore-point create` cho người làm gõ. Khi bật `repo`, gõ ở từng repo.

## Giai đoạn 4: Lặp cho từng MR

Chia việc thành các đơn vị kiểm được; mỗi đơn vị một MR. Với mỗi đơn vị, đi hết các bước dưới rồi mới sang đơn vị tiếp theo.

1. In lệnh poteto-mode:
   - đã qua giai đoạn 3: `/poteto-mode <mục tiêu>. Cách kiểm: <…>. Một MR mỗi đơn vị kiểm được. Dùng thiết kế đã chốt, bắt đầu từ throughput checkpoint. Spec: <đường dẫn>`
   - không qua giai đoạn 3: `/poteto-mode <mục tiêu>. Cách kiểm: <…>. Một MR mỗi đơn vị kiểm được.`
2. `/blast-radius` trên MR. Khi bật `state`: phát lại đường lỗi của statechart trên code thật.
3. `/checks`: đọc output thật, gán PASS, FAIL hoặc PENDING có biên lai.
4. `/review-gate`. Khi bật `sec`: thêm `/security-review-gate`.
   - Tối đa 2 vòng sửa. Hết 2 vòng mà vẫn REWORK: dừng và hỏi người làm chọn quay lại giai đoạn 3, hoặc chấp nhận rủi ro. Chấp nhận thì ghi `review-risk` vào `decisions.md` kèm lý do.
5. `merge_check.py` chạy theo cửa của repo. Repo chưa adopt cửa thì nói rõ là MR này không có cửa cứng.
6. **Cửa: duyệt và merge.** Trình gói: kết quả checks, review-gate, blast-radius và rủi ro đã chấp nhận. Người làm tự merge. Khi bật `repo`, merge repo cung cấp hợp đồng trước, repo dùng hợp đồng sau.
7. Cập nhật `flow.md` (MR nào đã merge), sang đơn vị tiếp theo.

Trong mô tả mỗi MR, dán tóm tắt biên lai: preset, công tắc đã bật, đường dẫn `flow.md`.

## Giai đoạn 5: Sau ra mắt (khi bật `why`)

1. Lấy ngày đọc chỉ số từ `why.md` (thời hạn của mục tiêu, hoặc mốc kiểm của ngưỡng dừng). Nhắc người làm đặt lịch nhắc nếu cần.
2. Đến hạn: đọc chỉ số, so với mục tiêu, chỉ số không được xấu đi và ngưỡng dừng.
3. Ghi `launch-review` vào `decisions.md`: giữ, chỉnh hay gỡ tính năng, kèm số liệu và nguồn.

## Hoàn thành khi

- Mọi MR của tính năng đã merge hoặc được ghi lý do bỏ.
- `flow.md` ghi đủ các cửa đã qua.
- Khi bật `why`: đã có ngày đọc chỉ số sau ra mắt.
