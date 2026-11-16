# Cheat-sheet: làm một tính năng

Mọi lệnh dưới đây có tiền tố tên plugin (`/pstack:…`, `/mattpocock-skills:…`, `/finolabs-vibecode:…`, `/feature-workflow:…`). Theo tài liệu Claude Code, skill của plugin chạy dưới dạng `/<plugin>:<skill>`, nên luôn gõ đủ tiền tố.

## 0. Lần đầu trong repo

```
/feature-workflow:feature-setup
```

Kiểm tra, hỏi duyệt, rồi cài phần còn thiếu. Chạy lại được.

Workspace: chạy ở repo trung tâm (repo này) để setup mọi repo đồng cấp một lần. Thêm repo mới thì chạy lại.

## 1. Bắt đầu

Mở phiên ở đâu:

- tính năng một repo: trong repo đó;
- tính năng nhiều repo: ở repo trung tâm.

```
/feature-workflow:feature-flow <small|medium|large> <mô tả>
```

Agent chọn công tắc, đọc `docs/flow-rules.md`, ghi biên lai, rồi trình chuỗi lệnh. Đồng ý thì đi tiếp.

Biên lai, `why.md`, spec, ticket, `spec-check.md` và sổ quyết định nằm ở thư mục tính năng, theo `docsBackend` trong `workspace.json`:

- `local` (mặc định): file markdown trong git, ở `docs/features/<slug>/` của repo hoặc `features/<slug>/` của repo trung tâm (theo `featureDocs`). `GLOSSARY.md` và ADR (`docs/adr/`) cũng trong repo.
- `orrery`: note trong Orrery ở `<repo>/features/<slug>/` (space theo `orrery.space`). `GLOSSARY.md` và ADR ở `<repo>/`. Phiên không có Orrery thì ghi local, phiên sau đồng bộ lên.

Luật duyệt luôn nằm trong git.

## 2. Chọn quy mô

| Tính năng | Preset |
|---|---|
| Sửa nhỏ, một chỗ, dễ quay lại | small |
| Vài module, yêu cầu chưa thật rõ | medium |
| Mới, tốn công, cần duyệt, có trạng thái hoặc nhiều repo | large |

## 3. Công tắc

| Bật khi | Công tắc | Thêm bước |
|---|---|---|
| Cần chứng minh giá trị | `why` | `feature-why`, đọc chỉ số sau ra mắt |
| Yêu cầu mơ hồ | `unclear` | `/mattpocock-skills:grill-with-docs` |
| Nhiều phiên, người, MR | `multi` | `/mattpocock-skills:to-spec`, `spec-check` |
| Vượt biên hàm | `cross` | `/pstack:architect` |
| Khó đảo ngược | `contest` | `/pstack:interrogate` |
| Có máy trạng thái | `state` | `/pstack:statechart` trước khi code |
| Tiền, quyền, dữ liệu cá nhân | `sec` | `/finolabs-vibecode:security-review-gate` |
| Nhiều repo | `repo` | restore-point mỗi repo, merge bên cung cấp trước |

**Bỏ bước Why khi**: sửa bug, refactor, việc nhỏ đã rõ, việc kỹ thuật thuần.

## 4. Bốn lần dừng

1. **Chốt có làm**: đọc `why.md` (do `feature-why` ghi). Chọn không làm thì dừng.
2. **Duyệt spec**: đọc spec và `spec-check.md`.
3. **Chốt thiết kế**: checkpoint của architect, finding interrogate, kết quả statechart.
4. **Duyệt và merge** mỗi MR: checks, review-gate, blast-radius, rủi ro đã chấp nhận. Người làm tự merge.

## 5. Lệnh hay gõ

```
/pstack:architect with checkpoint. stop and show me before implementing. Spec: <đường dẫn>
/finolabs-vibecode:restore-point create
/pstack:poteto-mode <mục tiêu>. Cách kiểm: <…>. Một MR mỗi đơn vị kiểm được. Dùng thiết kế đã chốt, bắt đầu từ throughput checkpoint. Spec: <đường dẫn>
/pstack:blast-radius
/finolabs-vibecode:checks
/finolabs-vibecode:review-gate
```

## 6. Khi kẹt

- **Không biết dùng skill nào**: `/feature-workflow:feature-help <câu hỏi>`. Nó trả lời theo luồng này và trỏ sang trợ giúp của từng bộ khi cần.

- **review-gate hết 2 vòng mà vẫn REWORK**: quay lại thiết kế, hoặc chấp nhận rủi ro và ghi `review-risk` vào `decisions.md`.
- **Muốn đổi quyết định cũ**: thêm mục `supersede` vào `decisions.md`, không sửa mục cũ.
- **Tính năng chạm việc trong file luật**: cửa duyệt đó không tắt được. Muốn đổi luật thì sửa `docs/flow-rules.md` bằng MR.

## 7. Không làm

- Không chạy `/pstack:how` riêng trước architect (Phase A đã chạy).
- Không dùng `/mattpocock-skills:implement` của Matt.
- Không để agent merge.
