# feature-workflow: repo trung tâm của workspace

Repo này vừa là plugin marketplace của luồng làm tính năng, vừa là trung tâm của một workspace gồm nhiều repo đồng cấp nằm cùng thư mục cha.

- `workspace.json`: danh sách repo đồng cấp (`projects`, đường dẫn tương đối như `../my-api`) space Orrery lưu tài liệu tính năng (`orrery.space`, mặc định `personal`), và nơi lưu local dự phòng khi phiên không có Orrery (`featureDocs`: `auto`, `central` hoặc `project`).
- `rules/common.md`: luật duyệt chung cho mọi repo trong workspace. Mỗi repo có thể bổ sung trong `docs/flow-rules.md` của nó.
- Mọi tài liệu trừ luật duyệt nằm trong Orrery: tài liệu tính năng (biên lai, why, spec, ticket, soát spec, sổ quyết định) ở `<repo>/features/<slug>/`; `GLOSSARY.md` và ADR ở `<repo>/`. `features/<slug>/` trong repo này chỉ chứa bản local chưa đồng bộ.
- `.claude/settings.json`: khai báo các repo đồng cấp (`permissions.additionalDirectories`) và plugin cho team.
- `plugins/`: plugin của team. Ba bộ finolabs-vibecode, pstack, mattpocock-skills cài từ marketplace upstream bằng `scripts/setup-machine.sh`; xem `UPSTREAM.md`.

Khi phiên mở ở đây:

- Bắt đầu một tính năng bằng `/feature-workflow:feature-flow`.
- Thêm repo hoặc chỉnh workspace bằng `/feature-workflow:feature-setup`.
- Việc gắn với một repo (git, restore-point, MR, merge) làm trong repo đó. Lệnh chỉ người gõ được thì người làm `/cd ../<repo>` trước rồi mới gõ.
