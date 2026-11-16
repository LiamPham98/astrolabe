---
name: setup
description: "Kiểm cấu hình của plugin astrolabe, kết nối Orrery, luật duyệt và các bộ đồng hành tuỳ chọn; tạo luật duyệt từ mẫu khi chưa có. Không ghi file nào vào repo dự án. Chạy lại được, chỉ làm phần còn thiếu. Dùng khi gõ /astrolabe:setup."
disable-model-invocation: true
---

# setup

Đưa máy về trạng thái dùng được `/astrolabe:flow`. Kiểm tra trước, báo cáo, hỏi duyệt, rồi mới làm. Chạy lại bao nhiêu lần cũng được.

Nói với người dùng bằng ngôn ngữ họ đang dùng. Giữ nguyên tên lệnh, tên plugin, đường dẫn.

## Nguyên tắc

- **Không ghi file nào vào repo dự án.** Cấu hình nằm trong `userConfig` của plugin; luật duyệt và tài liệu nằm ở nơi lưu (Orrery hoặc thư mục dữ liệu của plugin).
- **Không ghi gì khi chưa được duyệt.** Một câu "làm hết đi" chỉ duyệt đúng danh sách vừa trình.
- **Không cài hay gỡ plugin.** Bộ đồng hành là tuỳ chọn; chỉ in lệnh cài cho người dùng tự chạy.
- Cấu hình, bố cục nơi lưu và luật duyệt theo mục "Cấu hình", "Nơi lưu tài liệu" và "Luật duyệt" của skill `astrolabe:flow` (file `../flow/SKILL.md` cạnh file này).

## 1. Kiểm tra (chỉ đọc)

**Cấu hình** (giá trị trong phiên này; trống hoặc còn dạng `${...}` là chưa đặt):

| Khoá | Giá trị |
|---|---|
| `workspace_root` | `${user_config.workspace_root}` |
| `docs_backend` | `${user_config.docs_backend}` |
| `orrery_space` | `${user_config.orrery_space}` |

- `workspace_root`: thư mục có tồn tại không; liệt kê các repo git là thư mục con trực tiếp. Chưa đặt thì dùng thư mục cha của repo đang mở và nói rõ.
- `docs_backend`: `local` hay `orrery`.

**Nơi lưu**:

- `orrery`: phiên có công cụ MCP của Orrery không (`whoami`); `space_list` có thấy space `orrery_space` không, vai trò có từ `editor` trở lên không.
- `local`: thư mục `${CLAUDE_PLUGIN_DATA}` có tồn tại không (được tạo khi ghi lần đầu).
- Có tài liệu nào đang chờ đồng bộ lên Orrery không: các `flow.md` trong `${CLAUDE_PLUGIN_DATA}` có dòng `orrery: chưa đồng bộ`.

**Luật duyệt** ở nơi lưu: `_workspace/rules.md` có chưa; với mỗi repo trong workspace, `<repo>/rules.md` có chưa. Còn đúng nội dung mẫu thì ghi "còn mẫu".

**Bộ đồng hành** (tuỳ chọn): danh sách skill của phiên có skill mang tiền tố `finolabs-vibecode:`, `pstack:`, `mattpocock-skills:` không. Với pstack: `command -v mise` (cần cho `/pstack:statechart`).

**Dấu vết bản cũ** (trước 0.6.0): repo đang mở hay các repo trong workspace còn `.claude/astrolabe.json`, `.claude/feature-workflow.json`, `docs/flow-rules.md`, `workspace.json` không. Bản này không đọc các file đó nữa.

## 2. Báo cáo

Một bảng:

| Mục | Trạng thái | Việc cần làm |
|---|---|---|

Trạng thái chỉ dùng: `đã có`, `thiếu`, `chưa rõ`, `tuỳ chọn`. Việc cần làm ghi rõ ai làm: agent (sau khi được duyệt) hay người dùng.

Mọi mục bắt buộc đều `đã có` thì nói là đã sẵn sàng, gợi ý `/astrolabe:flow`, và dừng.

## 3. Hỏi duyệt

Gửi trong một lần hỏi, chỉ những câu đang cần:

- **Luật duyệt cần tạo** (chọn nhiều): `_workspace/rules.md` từ mẫu `../flow/templates/rules-common.md`; `<repo>/rules.md` từ mẫu `../flow/templates/rules-repo.md` cho từng repo còn thiếu.
- **Soạn luật từ code** (có hoặc để sau): đọc code các repo để đề xuất luật chung và luật riêng.
- **Đồng bộ lên Orrery** khi có tài liệu chờ đồng bộ và phiên có Orrery.
- **Dọn dấu vết bản cũ** khi bước 1 thấy file cũ: liệt kê từng file, trạng thái git của nó (chưa commit hay đã commit), và đề xuất xoá. File đã commit thì chỉ xoá trong working tree để người dùng tự commit.

Cấu hình sai hoặc thiếu: không hỏi ở đây; hướng dẫn người dùng mở `/config` và sửa mục của plugin `astrolabe`.

## 4. Làm phần đã duyệt

Lệnh nào lỗi thì dừng mục đó, ghi lỗi nguyên văn, làm tiếp các mục khác.

1. **Tạo luật**: theo "Tạo lần đầu" trong mục "Tạo và sửa luật" của `astrolabe:flow`. Đã có thì không ghi đè.
2. **Soạn luật từ code** (khi được duyệt):
   1. Đọc code để tìm chỗ thuộc các loại việc trong mẫu: sửa hoặc xoá dữ liệu đã chốt, công thức ảnh hưởng tiền, phân quyền, AI ra quyết định, xuất dữ liệu cá nhân, gửi thông báo hàng loạt. Ghi chỗ tìm được (repo, file, module).
   2. Hỏi một vòng, tối đa 4 câu: loại việc nào áp cho mọi repo; việc nào chỉ một repo có; việc nhạy cảm khác không có trong mẫu; cửa bắt buộc và security review cho các việc đã chọn. Mỗi câu có phương án đề xuất theo code tìm được.
   3. Ghi bảng vào `_workspace/rules.md` và `<repo>/rules.md`. Bỏ dòng không áp dụng, thêm dòng mới, giữ phần chú thích đầu. Luật riêng không lặp lại việc đã có trong luật chung. Note hay file chưa có thì tạo như mục 1; đã có thì sửa theo "Sửa luật đã có" trong mục "Tạo và sửa luật" của `astrolabe:flow` (Orrery: qua changeset).
3. **Đồng bộ lên Orrery**: theo mục "Khi phiên không kết nối Orrery" của `astrolabe:flow`.
4. **Dọn dấu vết bản cũ**: xoá đúng các file đã duyệt; thư mục rỗng sau khi xoá thì xoá luôn. Luật trong `docs/flow-rules.md` đã sửa khác mẫu thì chép nội dung sang `<repo>/rules.md` ở nơi lưu trước khi xoá.

## 5. Bộ đồng hành (tuỳ chọn)

Không có bộ nào luồng vẫn chạy đủ. Muốn dùng thì người dùng tự cài, ví dụ:

```bash
claude plugin marketplace add finolabs/finolabs-vibecode
claude plugin install finolabs-vibecode@finolabs-vibecode
claude plugin marketplace add cursor/plugins
claude plugin install pstack@cursor-plugins
claude plugin marketplace add mattpocock/skills
claude plugin install mattpocock-skills@mattpocock
```

Sau khi cài: `/pstack:setup-pstack` để chọn model cho các vai của pstack (bỏ qua được). Thiếu `mise` thì cài theo hướng dẫn của mise trước khi dùng `/pstack:statechart`. Không tự cài gói hệ thống. Plugin mới cài có hiệu lực ở phiên Claude Code mới hoặc sau `/reload-plugins`.

## 6. Báo cáo cuối

Bảng như bước 2, cập nhật trạng thái, thêm cột "đã làm gì". Kết thúc bằng một dòng việc tiếp theo: gõ `/astrolabe:flow <small|medium|large> <mô tả>` trong repo của tính năng, hoặc việc còn thiếu và ai làm.
