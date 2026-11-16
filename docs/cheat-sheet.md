# Cheat-sheet: làm một tính năng

Mọi lệnh có tiền tố tên plugin (`/astrolabe:…`, và `/pstack:…`, `/mattpocock-skills:…`, `/finolabs-vibecode:…` khi đã cài bộ đồng hành). Skill của plugin chạy dưới dạng `/<plugin>:<skill>`, nên luôn gõ đủ tiền tố.

## 0. Lần đầu

```
/astrolabe:setup
```

Kiểm cấu hình, kết nối Orrery, luật duyệt và bộ đồng hành; tạo luật từ mẫu khi được duyệt. Không ghi gì vào repo. Chạy lại được.

Cấu hình (`/config`, mục plugin `astrolabe`):

- `workspace_root`: thư mục chứa các repo, ví dụ `~/code`. Mọi repo git trong đó là một workspace.
- `docs_backend`: `orrery` (note trong Orrery) hoặc `local` (thư mục dữ liệu của plugin trên máy).
- `orrery_space`: mặc định `personal`.

## 1. Bắt đầu

Mở phiên trong repo của tính năng. Tính năng chạm nhiều repo thì mở ở một trong các repo đó, hoặc ở thư mục workspace; flow hỏi chạm repo nào.

```
/astrolabe:flow <small|medium|large> <mô tả>
```

Agent đọc luật, chọn công tắc, ghi biên lai, rồi trình chuỗi bước. Đồng ý thì đi tiếp.

Tài liệu nằm ở nơi lưu, không nằm trong repo:

- `<repo>/features/<slug>/`: biên lai `flow.md`, `why.md`, `spec.md`, `issues/`, `spec-check.md`, sổ `decisions.md`; tính năng nhiều repo ở `_workspace/features/<slug>/`.
- `_workspace/rules.md`, `<repo>/rules.md`: luật duyệt chung và riêng.
- `<repo>/GLOSSARY.md`, `<repo>/adr/`: thuật ngữ và ADR.

Phiên không có Orrery thì ghi vào thư mục dữ liệu của plugin, phiên sau đồng bộ lên.

## 2. Chọn quy mô

| Tính năng | Preset |
|---|---|
| Sửa nhỏ, một chỗ, dễ quay lại | small |
| Vài module, yêu cầu chưa thật rõ | medium |
| Mới, tốn công, cần duyệt, có trạng thái hoặc nhiều repo | large |

## 3. Công tắc

| Bật khi | Công tắc | Thêm bước (mặc định / có bộ đồng hành) |
|---|---|---|
| Cần chứng minh giá trị | `why` | `astrolabe:why`, đọc chỉ số sau ra mắt |
| Yêu cầu mơ hồ | `unclear` | agent hỏi theo vòng / `/mattpocock-skills:grill-with-docs` |
| Nhiều phiên, người, MR | `multi` | agent viết spec / `/mattpocock-skills:to-spec`; rồi `spec-check` |
| Vượt biên hàm | `cross` | agent viết thiết kế / `/pstack:architect` |
| Khó đảo ngược | `contest` | agent tự phản biện / `/pstack:interrogate` |
| Có máy trạng thái | `state` | bảng trạng thái × sự kiện / `/pstack:statechart`, trước khi code |
| Tiền, quyền, dữ liệu cá nhân | `sec` | `security-review` / `security-review-gate` của finolabs |
| Nhiều repo | `repo` | điểm khôi phục mỗi repo, merge bên cung cấp trước |

**Bỏ bước Why khi**: sửa bug, refactor, việc nhỏ đã rõ, việc kỹ thuật thuần.

## 4. Bốn lần dừng

1. **Chốt có làm**: đọc `why.md`. Chọn không làm thì dừng.
2. **Duyệt spec**: đọc spec và `spec-check.md`.
3. **Chốt thiết kế**: thiết kế, phản biện, kết quả máy trạng thái.
4. **Duyệt và merge** mỗi MR: kiểm, review, phạm vi ảnh hưởng, rủi ro đã chấp nhận. Người làm tự merge.

## 5. Mỗi MR

Code → phạm vi ảnh hưởng → kiểm → review (+ security khi bật `sec`) → duyệt và merge.

Khi đã cài bộ đồng hành:

```
/finolabs-vibecode:restore-point create
/pstack:poteto-mode <mục tiêu>. Cách kiểm: <…>. Một MR mỗi đơn vị kiểm được. Dùng thiết kế đã chốt, bắt đầu từ throughput checkpoint. Spec: <đường dẫn>
/pstack:blast-radius
```

## 6. Khi kẹt

- **Không biết dùng gì**: `/astrolabe:help <câu hỏi>`.
- **Review hết 2 vòng mà vẫn còn lỗi chặn**: quay lại thiết kế, hoặc chấp nhận rủi ro và ghi `review-risk` vào `decisions.md`.
- **Muốn đổi quyết định cũ**: thêm mục `supersede` vào `decisions.md`, không sửa mục cũ.
- **Tính năng chạm việc trong luật**: cửa duyệt đó không tắt được. Muốn đổi luật thì sửa `_workspace/rules.md` hoặc `<repo>/rules.md` có người duyệt.

## 7. Không làm

- Không dùng `/mattpocock-skills:implement` của Matt.
- Không để agent merge.
