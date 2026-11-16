# Changelog

Mọi thay đổi đáng chú ý của plugin `feature-workflow` ghi ở đây. Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/), version theo [SemVer](https://semver.org/) giai đoạn 0 (`0.y.z`: MINOR khi phá vỡ, PATCH khi tương thích). Ngày ghi `YYYY-MM-DD` theo Keep a Changelog. Bản ghim trong `vendor/` có version riêng, xem `UPSTREAM.md`.

Chưa có bản nào gắn tag.

## [Unreleased]

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
