---
name: setup
description: "Kiểm tra và cài đặt luồng astrolabe: workspace trung tâm với các repo đồng cấp, kiểm plugin của máy, luật duyệt chung và riêng, nơi lưu tài liệu tính năng, setup của finolabs và Matt. Chạy lại được, chỉ làm phần còn thiếu. Dùng khi gõ /astrolabe:setup."
disable-model-invocation: true
---

# setup

Đưa máy, workspace và các repo về trạng thái dùng được `/astrolabe:flow`. Kiểm tra trước, báo cáo, hỏi duyệt, rồi mới làm. Chạy lại bao nhiêu lần cũng được: chỉ làm phần còn thiếu, không ghi đè thứ đã có.

Nói với người dùng bằng ngôn ngữ họ đang dùng. Giữ nguyên tên lệnh, tên plugin, đường dẫn.

## Nguyên tắc

- **Không cài, gỡ hay ghi file khi chưa được duyệt.** Một câu "cài hết đi" chỉ duyệt đúng danh sách vừa trình.
- **Không gỡ plugin khi chưa hỏi riêng từng plugin.**
- **Skill chỉ người gõ được** (`/finolabs-vibecode:setup`, `/mattpocock-skills:setup-matt-pocock-skills`, `/pstack:setup-pstack`): in đúng câu lệnh cho người dùng gõ, không làm thay. Hai lệnh đầu chạy trên repo đang mở của phiên, nên với repo đồng cấp, người dùng `/cd ../<repo>` trước.
- Plugin mới cài chỉ có hiệu lực ở **phiên Claude Code mới**.
- Đường dẫn trong file commit chung luôn là **tương đối** (`../my-api`), không bao giờ là đường dẫn tuyệt đối của một máy.
- **Thư mục plugin**: hai cấp trên thư mục chứa file SKILL.md này (`<plugin>/skills/setup/` thì là `<plugin>/`). `upstream.json` và `scripts/` nằm ở đó, dù plugin cài từ GitHub hay chạy từ bản clone.

## 0. Xác định chế độ

Tìm gốc repo đang mở: `git rev-parse --show-toplevel`.

| Dấu hiệu | Chế độ |
|---|---|
| Gốc repo có `workspace.json` | **Trung tâm**: setup workspace và các repo đồng cấp |
| Gốc repo có `.claude/astrolabe.json`, hoặc thư mục cha có một repo trung tâm như trên | **Repo đồng cấp**: gắn repo này vào workspace |
| Không có gì ở trên | **Đơn lẻ**: setup riêng repo này, không workspace |

Ở chế độ repo đồng cấp mà chưa có `.claude/astrolabe.json`: hỏi có gắn repo này vào workspace ở `../<tên repo trung tâm>` không. Không gắn thì chuyển sang đơn lẻ.

Ở chế độ đơn lẻ mà thư mục cha có repo git khác: hỏi thêm có biến repo đang mở thành **repo trung tâm** không. Repo trung tâm là repo bất kỳ có `workspace.json` (ví dụ repo tài liệu hay repo chính của team), không cần là bản clone của astrolabe. Đồng ý thì làm tiếp như chế độ trung tâm, với `workspace.json` và `rules/common.md` tạo ở bước 4.

## 1. Kiểm tra (chỉ đọc)

**Máy** (mọi chế độ):

```bash
claude plugin marketplace list
claude plugin list --json
```

- Plugin cần có: plugin này (tên trong `.claude-plugin/plugin.json` của thư mục plugin; marketplace xem trong `claude plugin list --json`, thường là `astrolabe@astrolabe`) và mỗi mục trong `upstream` của `upstream.json` trong thư mục plugin (dạng `<plugin>@<marketplace>`). Đọc các file đó, không dùng danh sách nhớ sẵn. Ghi phạm vi cài (user hay project).
- `~/.claude/settings.json`: mỗi marketplace upstream, và marketplace của plugin này khi nguồn là GitHub, có `"autoUpdate": true` trong `extraKnownMarketplaces` không.
- **Bản trùng**:
  - cùng bộ skill cài từ marketplace khác, kể cả plugin cũ trong `retired` và marketplace cũ trong `retiredMarketplaces` của `upstream.json`;
  - skill rời trong `~/.claude/skills` trùng tên với skill của các plugin trên (skill rời không có tiền tố nên bị gọi lẫn).
- Thiếu plugin, thiếu `autoUpdate` hoặc có bản trùng: việc cần làm là chạy `scripts/setup-machine.sh` trong thư mục plugin (agent chạy, sau khi được duyệt). Script gỡ plugin cũ, thêm marketplace, cài và cập nhật plugin, ghi settings, chuyển skill rời trùng tên sang `~/.claude/skills-backup-<ngày>/` và kiểm skill luồng cần.
- Công cụ cho statechart: `command -v mise`.
- **Orrery** (chỉ khi `docsBackend` là `orrery`): phiên có công cụ MCP của Orrery không (`whoami`); `space_list` có thấy space trong `orrery.space` (mặc định `personal`) không, và vai trò có từ `editor` trở lên không. Không có Orrery thì ghi `thiếu`: luồng vẫn chạy nhưng ghi local và đồng bộ sau.

**Workspace** (chế độ trung tâm):

- `workspace.json`: `docsBackend` và `featureDocs` đã chọn chưa, `projects` gồm những repo nào, đường dẫn còn đúng không.
- Các repo git nằm cùng thư mục cha (`ls ..`, mỗi thư mục có `.git`) mà chưa có trong `projects`.
- `.claude/settings.json` của repo trung tâm: `permissions.additionalDirectories` có khớp `projects` không; không có `enabledPlugins` hay `extraKnownMarketplaces` (hai khoá này thuộc `~/.claude/settings.json` của từng máy).
- `rules/common.md` có chưa; còn là bản mẫu nguyên hay đã sửa.
- Remote của repo trung tâm: `git remote get-url origin`.

**Từng repo** (repo đang mở ở chế độ đồng cấp và đơn lẻ; mọi repo trong `projects` ở chế độ trung tâm):

- `.claude/astrolabe.json` có trỏ đúng repo trung tâm không (không áp dụng với đơn lẻ). Còn `.claude/feature-workflow.json` (tên cũ) thì ghi `thiếu`: việc cần làm là đổi tên file thành `.claude/astrolabe.json`, giữ nguyên nội dung. Ở chế độ đơn lẻ, file này giữ `docsBackend` của repo.
- `docs/flow-rules.md` có chưa; đã sửa hay còn mẫu.
- `docs/features/` có chưa (cần khi `featureDocs` là `auto` hoặc `project`, hoặc ở chế độ đơn lẻ).
- Cấu hình của Matt: đọc SKILL.md của `setup-matt-pocock-skills` trong plugin `mattpocock-skills` để biết nó ghi file gì, rồi kiểm file đó có chưa.
  - `docsBackend: local`: bản "Local markdown" của Matt là đúng.
  - `docsBackend: orrery`: `docs/agents/issue-tracker.md` và `docs/agents/domain.md` phải trỏ về Orrery (nội dung như mẫu `templates/issue-tracker-orrery.md` và `templates/domain-orrery.md` cạnh file SKILL.md này); còn là bản của Matt thì ghi `thiếu`.
- Chỉ khi `docsBackend: orrery`: `GLOSSARY.md`, `GLOSSARY-MAP.md` và `docs/adr/` trong repo có thì ghi `thiếu` cho mục "chép lên Orrery".
- Cửa của finolabs: ghi "cần chạy `/finolabs-vibecode:setup check` trong repo này".
- Remote: không phải GitHub thì ghi rõ `merge_check.py` và `post_review.py` của finolabs gọi `gh`, nên cửa merge và việc đăng review không chạy được ở repo này.

## 2. Báo cáo

Một bảng cho máy và workspace, một bảng cho mỗi repo:

| Mục | Trạng thái | Việc cần làm |
|---|---|---|

Trạng thái chỉ dùng: `đã có`, `thiếu`, `trùng`, `chưa rõ`. Việc cần làm ghi rõ ai làm: agent (sau khi được duyệt) hay người dùng (gõ lệnh, kèm repo phải `/cd` tới).

Mọi mục đều `đã có` thì nói là đã sẵn sàng, gợi ý `/astrolabe:flow`, và dừng.

## 3. Hỏi duyệt và chọn

Gửi trong một lần hỏi, chỉ những câu đang cần:

- **Nơi lưu tài liệu** (`docsBackend`; mọi chế độ, khi chưa chọn hoặc người dùng muốn đổi):
  - `local` (Đề xuất): tài liệu tính năng là file markdown trong git, không cần dịch vụ ngoài.
  - `orrery`: tài liệu nằm trong Orrery, cần phiên có công cụ MCP của Orrery; hỏi thêm tên space (mặc định `personal`).
- **Thư mục local** (`featureDocs`; chế độ trung tâm, khi chưa chọn hoặc người dùng muốn đổi; với `orrery` đây là nơi dự phòng khi phiên không có Orrery):
  - `auto` (Đề xuất): tính năng một repo lưu ở `docs/features/` của repo đó; tính năng nhiều repo lưu ở `features/` của trung tâm.
  - `central`: mọi tính năng lưu ở `features/` của trung tâm.
  - `project`: mọi tính năng lưu trong repo dự án; tính năng nhiều repo lưu ở repo chính của tính năng.
- **Repo đồng cấp đưa vào workspace** (chế độ trung tâm, chọn nhiều): các repo git tìm thấy cùng thư mục cha mà chưa có trong `projects`.
- **Việc agent sẽ làm** (chọn nhiều): liệt kê đúng những việc ở bước 4 đang cần.

Cài máy là một mục trong "Việc agent sẽ làm" khi bước 1 thấy thiếu. Mục đó nói rõ script sẽ chuyển những skill rời nào sang thư mục sao lưu.

## 4. Làm phần đã duyệt

Lệnh nào lỗi thì dừng mục đó, ghi lỗi nguyên văn, làm tiếp các mục khác.

**Máy**: chạy `bash "<thư mục plugin>/scripts/setup-machine.sh"` (thời gian chờ tới 10 phút; script clone marketplace từ GitHub). Đọc output thật: báo `THIẾU` ở bước cuối thì báo nguyên văn cho người dùng. Không gỡ plugin nào ngoài danh sách `retired` của `upstream.json`. Xong thì nhắc mở phiên mới hoặc gõ `/reload-plugins`.

**Workspace** (chế độ trung tâm):

1. Ghi `workspace.json` (tạo với `"version": 1` nếu chưa có): `docsBackend` và `featureDocs` đã chọn; `"orrery": { "space": "<space>" }` chỉ khi `docsBackend` là `orrery`; thêm mỗi repo đã chọn vào `projects` với `name` (tên thư mục), `path` (đường dẫn tương đối từ repo trung tâm, thường là `../<tên>`), `remote` (kết quả `git -C ../<tên> remote get-url origin`, rỗng nếu không có). URL có phần `user:token@` thì bỏ phần đó trước khi ghi, ví dụ `https://user:token@gitlab.com/x.git` thành `https://gitlab.com/x.git`; không in token ra. Giữ nguyên repo đã có.
2. Ghi `.claude/settings.json` của repo trung tâm, **giữ mọi key khác đang có**:
   - `permissions.additionalDirectories`: đúng danh sách `path` trong `projects`.
   - Không ghi `enabledPlugins` hay `extraKnownMarketplaces` vào file này: plugin cài theo máy bằng `scripts/setup-machine.sh`, và nguồn `directory` là đường dẫn tuyệt đối của một máy.
   - File này nằm trong `.gitignore` của bản public. Repo có dòng đó thì nói rằng file không được commit; team muốn chia sẻ danh sách repo thì bỏ dòng đó.
3. Tạo `features/.gitkeep` nếu chưa có.
4. Tạo `rules/common.md` từ `templates/common-rules.md` cạnh file SKILL.md này nếu chưa có. Có rồi thì không ghi đè.

**Từng repo** (repo đang mở, hoặc mọi repo trong `projects` ở chế độ trung tâm):

1. Chế độ trung tâm hoặc đồng cấp: ghi `.claude/astrolabe.json`:

   ```json
   { "workspace": "../<tên repo trung tâm>" }
   ```

   `workspace` là đường dẫn tương đối từ repo này tới repo trung tâm.

   Chế độ đơn lẻ: ghi `.claude/astrolabe.json` với `{ "docsBackend": "<đã chọn>" }`, thêm `"orrery": { "space": "<space>" }` khi chọn `orrery`. Giữ các khoá đã có.

2. Tạo `docs/flow-rules.md` từ `../flow/templates/flow-rules.md` cạnh file SKILL.md này, nếu chưa có. Có rồi thì không ghi đè.
3. Tạo `docs/features/.gitkeep` nếu `featureDocs` là `auto` hoặc `project`, hoặc ở chế độ đơn lẻ.
4. Chỉ khi `docsBackend: orrery`, sau khi người dùng chạy `/mattpocock-skills:setup-matt-pocock-skills`: ghi đè `docs/agents/issue-tracker.md` và `docs/agents/domain.md` bằng hai mẫu `templates/issue-tracker-orrery.md` và `templates/domain-orrery.md`, thay `{{space}}` bằng `orrery.space` và `{{repo}}` bằng tên repo. Trình nội dung cũ trước khi ghi đè.
5. Chỉ khi `docsBackend: orrery`, chép lên Orrery (cần phiên có Orrery): `GLOSSARY.md`, `GLOSSARY-MAP.md` và các file trong `docs/adr/` của repo lên `<repo>/` trong space, theo mục "Orrery" trong "Nơi lưu tài liệu" của skill `astrolabe:flow`, bằng `changeset_submit`. Note đã có và khác file thì không ghi đè; trình hai bản và hỏi. Chép xong thì hỏi có xoá bản trong repo không.

Nhắc người dùng commit các file vừa tạo trong từng repo; file luật và `.claude/astrolabe.json` là file chung của team.

## 5. Soạn luật duyệt (khi được duyệt)

Chế độ trung tâm soạn `rules/common.md` trước, rồi phần riêng của từng repo. Chế độ đồng cấp và đơn lẻ chỉ soạn `docs/flow-rules.md` của repo đang mở.

1. Đọc code để tìm chỗ thuộc các loại việc trong mẫu: sửa hoặc xoá dữ liệu đã chốt, công thức ảnh hưởng tiền, phân quyền, AI ra quyết định, xuất dữ liệu cá nhân, gửi thông báo hàng loạt. Ghi chỗ tìm được (repo, file, module).
2. Hỏi một vòng, tối đa 4 câu:
   - **Luật chung**: loại việc nào áp cho mọi repo (đề xuất những loại tìm thấy ở nhiều repo).
   - **Luật riêng**: với từng repo, việc nào chỉ repo đó có (đề xuất theo code tìm được).
   - Việc nhạy cảm khác không có trong mẫu.
   - Cửa bắt buộc và security review cho các việc đã chọn (đề xuất theo cột tương ứng trong mẫu).
3. Ghi bảng vào `rules/common.md` và `docs/flow-rules.md` của từng repo. Bỏ dòng không áp dụng, thêm dòng mới, giữ phần chú thích đầu file. Luật riêng không lặp lại việc đã có trong luật chung.
4. Trình nội dung đã ghi. Nhắc rằng các file này sửa qua MR như code.

## 6. In lệnh cho người dùng gõ

Với mỗi repo còn thiếu, in theo thứ tự (ghi rõ repo nào):

1. `/cd ../<repo>` nếu phiên đang ở repo khác.
2. `/mattpocock-skills:setup-matt-pocock-skills`: ở câu hỏi issue tracker chọn "Local markdown". Khi `docsBackend` là `orrery`: bước 4 của mục "Từng repo" sẽ thay bằng cấu hình Orrery, nên xong thì quay lại `/astrolabe:setup`.
3. `/finolabs-vibecode:setup`: chọn phạm vi **project** để bật cửa kiểm và cửa merge cho repo này. Xong thì `/finolabs-vibecode:setup check`.

Một lần cho máy:

- `/pstack:setup-pstack`: chọn model cho từng vai của pstack. Mặc định pstack dùng cả model không phải Claude (Grok); trong Claude Code các vai đó chạy bằng model của phiên. Lệnh này ghi `~/.claude/rules/pstack-models.md`. Bỏ qua được nếu dùng mặc định.
- Thiếu `mise`: cài theo hướng dẫn của mise trước khi dùng `/pstack:statechart`. Không tự cài gói hệ thống.

Nếu vừa cài plugin ở bước 4: nhắc mở phiên Claude Code mới trước khi gõ các lệnh trên.

## 7. Báo cáo cuối

Các bảng như bước 2, cập nhật trạng thái, thêm cột "đã làm gì". Kết thúc bằng một dòng việc tiếp theo:

- chế độ trung tâm, đã sẵn sàng: mở phiên ở repo trung tâm cho tính năng nhiều repo, hoặc ở repo dự án cho tính năng một repo, rồi gõ `/astrolabe:flow <small|medium|large> <mô tả>`;
- còn thiếu: lệnh nào, gõ ở repo nào.
