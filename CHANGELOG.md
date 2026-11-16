# Changelog

Mọi thay đổi đáng chú ý của plugin `astrolabe` ghi ở đây. Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/), version theo [SemVer](https://semver.org/) giai đoạn 0 (`0.y.z`: MINOR khi phá vỡ, PATCH khi tương thích). Ngày ghi `YYYY-MM-DD` theo Keep a Changelog. Ba bộ upstream có version riêng, xem `UPSTREAM.md`.

Bản gắn tag đầu tiên là `v0.5.0`; các bản trước chưa gắn tag.

## [Unreleased]

## [0.5.0] - 2026-11-16

### Thay đổi phá vỡ

- `upstream.json`, `setup-machine.sh` và `init-project.sh` chuyển vào `plugins/astrolabe/`; `scripts/` ở gốc repo giờ là lối tắt cho bản clone. Repo trung tâm nhận theo `workspace.json`, không cần `.claude-plugin/marketplace.json`. Việc cần làm: không có với bản clone; lệnh `./scripts/…` vẫn chạy.
- Đổi tên theo repo: plugin và marketplace `feature-workflow` thành `astrolabe`; skill `feature-setup`, `feature-flow`, `feature-why`, `feature-help` thành `setup`, `flow`, `why`, `help` (`spec-check` giữ tên). Lệnh giờ gõ `/astrolabe:flow`, `/astrolabe:setup`. File trỏ workspace trong repo dự án đổi từ `.claude/feature-workflow.json` thành `.claude/astrolabe.json`. Việc cần làm: chạy lại `./scripts/setup-machine.sh` (script gỡ `feature-workflow@feature-workflow` và marketplace cũ), rồi `/astrolabe:setup` trong từng repo để đổi tên file trỏ.
- Nơi lưu tài liệu chọn bằng `docsBackend` trong `workspace.json` (hoặc `.claude/astrolabe.json` ở repo đơn lẻ): `local` (mặc định) hoặc `orrery`. Thiếu khoá thì là `local`, nên workspace đang dùng Orrery sẽ chuyển sang ghi file local. Việc cần làm: muốn giữ Orrery thì thêm `"docsBackend": "orrery"` vào `workspace.json`.
- `.claude/settings.json` của repo trung tâm vào `.gitignore`. Việc cần làm: team muốn commit danh sách repo đồng cấp thì bỏ dòng đó trong fork của mình.

### Thêm

- Cài thẳng từ GitHub, không cần clone: `claude plugin marketplace add LiamPham98/astrolabe`, `claude plugin install astrolabe@astrolabe`, rồi `/astrolabe:setup`. `/astrolabe:setup` tự chạy `setup-machine.sh` trong thư mục plugin khi được duyệt, và biến được một repo bất kỳ của team thành repo trung tâm (tạo `workspace.json`, `rules/common.md` từ mẫu).
- `setup-machine.sh` nhận ra đang chạy từ plugin đã cài (marketplace nguồn GitHub, bật `autoUpdate`) hay từ bản clone (marketplace nguồn thư mục).
- `plugins/astrolabe/upstream.json`: khai các bộ skill upstream (marketplace, repo, plugin, skill luồng cần) và plugin cũ cần gỡ. `scripts/setup-machine.sh` và `astrolabe:setup` đọc file này thay cho danh sách viết cứng.
- `LICENSE` (MIT); `plugin.json` và `marketplace.json` có tác giả, `homepage`, `repository`, `license`.
- README có mục "Tuỳ biến".

### Sửa

- `setup-machine.sh` chạy `claude plugin update` cho plugin đã cài, để bước kiểm skill không đọc bản cũ còn sót trên máy.
- `setup-machine.sh` ghi `~/.claude/settings.json` sau khi thêm marketplace, vì `claude plugin marketplace add` làm mất `"autoUpdate": true`.
- Hai script đọc được file JSON có BOM UTF-8 (thường gặp khi file được ghi bằng PowerShell hay Notepad).
- `init-project.sh` nhận repo ở bất kỳ đâu cùng ổ đĩa, ghi đường dẫn tương đối tính bằng `relpath`, thay cho việc bắt buộc cùng thư mục cha.
- `init-project.sh` dò `python3` hoặc `python` như `setup-machine.sh`, và chuyển đường dẫn sang dạng Windows trước khi gọi Python, để chạy được trên Git Bash.
- Tên repo nội bộ trong ví dụ đổi thành `my-api`, `my-web`.

## [0.4.0] - 2026-11-16

### Thay đổi phá vỡ

- Bỏ bản ghim trong `vendor/` và `scripts/update-vendor.sh`. `finolabs-vibecode`, `pstack`, `mattpocock-skills` cài thẳng từ marketplace upstream (`finolabs-vibecode`, `cursor-plugins`, `mattpocock`) với `autoUpdate`. Việc cần làm: chạy `./scripts/setup-machine.sh` trên mỗi máy; script gỡ bản `<bộ>@feature-workflow` cũ.
- `feature-setup` không còn cài plugin hay ghi `enabledPlugins` cho team; nó chỉ lại `scripts/setup-machine.sh`.

### Thêm

- `scripts/setup-machine.sh`: cài cho máy một lần, chạy lại an toàn. Ghi `~/.claude/settings.json`, cài plugin, chuyển skill rời trùng tên trong `~/.claude/skills` sang thư mục sao lưu, kiểm skill luồng cần.
- `feature-setup` dò skill rời trong `~/.claude/skills` trùng tên với skill của plugin.

## [0.3.0] - 2026-11-16

### Thay đổi phá vỡ

- Tài liệu của luồng chuyển sang Orrery: tài liệu tính năng ở `<repo>/features/<slug>/`, `GLOSSARY.md` và ADR ở `<repo>/`. Việc cần làm: chạy lại `/feature-workflow:feature-setup` trong từng repo để ghi cấu hình Orrery và chép `GLOSSARY.md`, `docs/adr/` lên.
- `docs/features/` và `features/` giờ chỉ là nơi ghi local khi phiên không có Orrery. Việc cần làm: mở `/feature-workflow:feature-flow` trong phiên có Orrery để đồng bộ tài liệu cũ lên.
- Repo này thành repo trung tâm của workspace nhiều repo, với `workspace.json`, `rules/common.md` và `.claude/feature-workflow.json` trong từng repo đồng cấp. Việc cần làm: đặt các repo dự án cùng thư mục cha và chạy `/feature-workflow:feature-setup`.
- Mọi lệnh in ra dùng tiền tố plugin, ví dụ `/pstack:architect`. Việc cần làm: gõ lệnh có tiền tố.
- `vendor/pstack` đổi sang bản dựng cho Claude Code của upstream.

### Thêm

- Skill `feature-help`: trả lời nên dùng skill nào và gõ lệnh gì tiếp, theo luồng.
- Mẫu `issue-tracker-orrery.md` và `domain-orrery.md`: `to-spec`, `to-tickets` ghi spec và ticket thẳng vào Orrery; skill của Matt đọc `GLOSSARY.md` và ADR từ Orrery.
- Cửa "chốt thiết kế" ghi ADR vào `<repo>/adr/` qua changeset của Orrery.
- `workspace.json` có khóa `orrery.space`, mặc định `personal`.
- `.gitattributes` giữ LF cho mọi file.

### Sửa

- Luật duyệt bắt buộc một cửa thì bật công tắc của cửa đó, kể cả khi preset tắt.
- `spec-check` chỉ chạy khi có spec (`multi` bật).
- `init-project.sh` và `feature-setup` bỏ phần `user:token@` khỏi URL remote trước khi ghi vào `workspace.json`.
- `init-project.sh` không còn lỗi khi in tiếng Việt trên console Windows.
- Frontmatter của `feature-setup` parse được: trước đây `disable-model-invocation` bị bỏ qua.

## [0.2.0] - 2026-11-13

### Thêm

- Skill `feature-setup`: kiểm tra, cài plugin, tạo file luật, in lệnh setup của finolabs và Matt.

## [0.1.0] - 2026-11-13

### Thêm

- Marketplace gom `feature-workflow` cùng bản ghim của `finolabs-vibecode`, `pstack` và `mattpocock-skills`.
- Skill `feature-flow`, `feature-why`, `spec-check` và các mẫu `flow.md`, `decisions.md`, `why.md`, `flow-rules.md`.
