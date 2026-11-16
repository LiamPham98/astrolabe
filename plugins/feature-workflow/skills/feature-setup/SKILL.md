---
name: feature-setup
description: Kiểm tra và cài đặt luồng feature-workflow cho máy và repo đang mở (plugin, file luật duyệt, thư mục tính năng, setup của finolabs và Matt, công cụ cho statechart). Chạy lại được, chỉ làm phần còn thiếu. Dùng khi gõ /feature-workflow:feature-setup.
disable-model-invocation: true
---

# feature-setup

Đưa máy và repo đang mở về trạng thái dùng được `/feature-workflow:feature-flow`. Kiểm tra trước, báo cáo, hỏi duyệt, rồi mới làm. Chạy lại bao nhiêu lần cũng được: chỉ làm phần còn thiếu, không ghi đè thứ đã có.

Nói với người dùng bằng ngôn ngữ họ đang dùng. Giữ nguyên tên lệnh, tên plugin, đường dẫn.

## Nguyên tắc

- **Không cài, gỡ hay ghi file khi chưa được duyệt.** Một câu "cài hết đi" chỉ duyệt đúng danh sách vừa trình, không duyệt việc phát sinh sau đó.
- **Không bao giờ gỡ plugin khi chưa hỏi riêng từng plugin.**
- **Skill chỉ người gõ được** (`/finolabs-vibecode:setup` của finolabs, `/mattpocock-skills:setup-matt-pocock-skills`): in đúng câu lệnh cho người dùng gõ, không làm thay.
- Plugin mới cài chỉ có hiệu lực ở **phiên Claude Code mới**. Nói rõ điều này khi có cài thêm.

## 1. Kiểm tra (chỉ đọc)

Chạy các lệnh dưới và ghi kết quả. Không sửa gì ở bước này.

**Máy:**

```bash
claude plugin marketplace list
claude plugin list --json
```

- Marketplace `feature-workflow` đã có chưa, nguồn ở đâu (đường dẫn hay GitHub).
- Bốn plugin cần có, đều từ marketplace `feature-workflow`: `feature-workflow`, `finolabs-vibecode`, `pstack`, `mattpocock-skills`.
- **Bản trùng**: cùng tên plugin (hoặc cùng bộ skill) nhưng cài từ marketplace khác, ví dụ `finolabs-vibecode@finolabs`, `mattpocock-skills@mattpocock`, hay một bản pstack từ nguồn khác. Hai bản cùng chạy thì skill bị gọi lẫn.

**Repo đang mở** (tìm gốc repo bằng `git rev-parse --show-toplevel`; không phải repo git thì nói rõ và chỉ làm phần máy):

- `docs/flow-rules.md` có chưa; có rồi thì còn là bản mẫu nguyên hay đã sửa (so với `../feature-flow/templates/flow-rules.md` cạnh file SKILL.md này).
- `docs/features/` có chưa.
- Cấu hình của `setup-matt-pocock-skills`: đọc SKILL.md của skill đó trong plugin `mattpocock-skills` để biết nó ghi file gì, rồi kiểm file đó có trong repo chưa.
- Cửa của finolabs-vibecode: không tự kiểm được đầy đủ. Ghi là "cần chạy `/finolabs-vibecode:setup check`".
- Nơi đặt remote: `git remote get-url origin`. Không phải GitHub (ví dụ GitLab) thì ghi rõ: `merge_check.py` và `post_review.py` của finolabs gọi `gh`, nên cửa merge và việc đăng review lên MR không chạy được ở repo này.

**Công cụ cho statechart**: lần đầu chạy, statechart cài TLC và Java qua `mise` và cần mạng. Kiểm `command -v mise` và `java -version`. Thiếu `mise` thì ghi là cần cài trước khi dùng `/pstack:statechart`.

## 2. Báo cáo

Trình một bảng, mỗi dòng một mục:

| Mục | Trạng thái | Việc cần làm |
|---|---|---|

Trạng thái chỉ dùng: `đã có`, `thiếu`, `trùng`, `chưa rõ`. Việc cần làm ghi rõ ai làm: agent (sau khi được duyệt) hay người dùng (gõ lệnh).

Mọi mục đều `đã có` thì nói là đã sẵn sàng, gợi ý `/feature-workflow:feature-flow`, và dừng.

## 3. Hỏi duyệt

Một câu hỏi chọn nhiều, chỉ gồm những việc agent sẽ làm và đang cần làm:

- Cài plugin còn thiếu (liệt kê tên).
- Tạo `docs/features/`.
- Tạo `docs/flow-rules.md` từ mẫu.
- Soạn lại `docs/flow-rules.md` cho đúng repo (bước 5).

Mỗi bản trùng hỏi riêng một câu: gỡ bản nào, giữ bản nào. Đề xuất giữ bản từ `feature-workflow`, vì đó là bản ghim trong `UPSTREAM.md`.

## 4. Làm phần đã duyệt

**Cài plugin còn thiếu:**

```bash
claude plugin install <tên>@feature-workflow --scope user
```

Marketplace `feature-workflow` chưa có thì không cài được gì: in hướng dẫn thêm marketplace (`/plugin marketplace add <đường dẫn hoặc user/feature-workflow>`) và bỏ qua phần cài.

**Gỡ bản trùng** (chỉ bản đã được duyệt riêng):

```bash
claude plugin uninstall <tên>@<marketplace khác>
```

**Thư mục và file luật:**

- Tạo `docs/features/.gitkeep` nếu chưa có `docs/features/`.
- Chưa có `docs/flow-rules.md`: chép từ `../feature-flow/templates/flow-rules.md` cạnh file SKILL.md này. **Có rồi thì không ghi đè.**

Lệnh nào lỗi thì dừng mục đó, ghi lỗi nguyên văn vào báo cáo cuối, làm tiếp các mục khác.

## 5. Soạn file luật (khi được duyệt)

Mục đích: danh sách "việc luôn cần người duyệt" khớp với repo thật, không để nguyên mẫu.

1. Đọc code để tìm những chỗ thuộc các loại việc trong mẫu: sửa hoặc xoá dữ liệu đã chốt, công thức ảnh hưởng tiền, phân quyền, AI ra quyết định, xuất dữ liệu cá nhân, gửi thông báo hàng loạt. Ghi chỗ tìm được (file, module).
2. Hỏi một vòng, tối đa 4 câu:
   - Loại việc nào áp dụng cho repo này (chọn nhiều; đề xuất những loại tìm thấy trong code, kèm chỗ tìm thấy).
   - Có việc nhạy cảm nào khác không có trong mẫu.
   - Với các việc đã chọn, cửa bắt buộc nào (chốt có làm, duyệt spec, chốt thiết kế) và có cần security review không. Đề xuất theo cột tương ứng trong mẫu.
3. Ghi lại bảng trong `docs/flow-rules.md`: bỏ dòng không áp dụng, thêm dòng mới. Giữ phần chú thích đầu file.
4. Trình nội dung đã ghi. Nhắc rằng file này nên được commit và sửa qua MR như code.

## 6. In lệnh cho người dùng gõ

Những mục còn `thiếu` hoặc `chưa rõ` thuộc phần người dùng, in theo thứ tự:

1. `/mattpocock-skills:setup-matt-pocock-skills`: chọn lưu spec dạng markdown local (tracker là tuỳ chọn).
2. `/finolabs-vibecode:setup`: chọn phạm vi **project** để bật cửa kiểm và cửa merge của finolabs cho repo này. Xong thì chạy `/finolabs-vibecode:setup check` để xác nhận.
3. `/pstack:setup-pstack`: chọn model cho từng vai của pstack. Mặc định pstack dùng cả model không phải Claude (Grok); trong Claude Code các vai đó chạy bằng model của phiên. Lệnh này ghi `~/.claude/rules/pstack-models.md`. Có thể bỏ qua nếu dùng mặc định.
4. Thiếu `mise`: cài theo hướng dẫn của mise trước khi dùng `/pstack:statechart`. Không tự cài gói hệ thống.

Nếu vừa cài plugin ở bước 4: nhắc mở phiên Claude Code mới trước khi gõ các lệnh trên.

## 7. Báo cáo cuối

Bảng như bước 2, cập nhật trạng thái sau khi làm, thêm cột "đã làm gì". Kết thúc bằng một dòng: việc tiếp theo là gì (gõ lệnh nào, hoặc `/feature-workflow:feature-flow <small|medium|large> <mô tả>` nếu đã sẵn sàng).
