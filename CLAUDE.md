# feature-workflow: repo trung tâm của workspace

Repo này vừa là plugin marketplace của luồng làm tính năng, vừa là trung tâm của một workspace gồm nhiều repo đồng cấp nằm cùng thư mục cha.

- `workspace.json`: danh sách repo đồng cấp (`projects`, đường dẫn tương đối như `../my-api`) và nơi lưu tài liệu tính năng (`featureDocs`: `auto`, `central` hoặc `project`).
- `rules/common.md`: luật duyệt chung cho mọi repo trong workspace. Mỗi repo có thể bổ sung trong `docs/flow-rules.md` của nó.
- `features/<slug>/`: tài liệu của tính năng lưu ở trung tâm (biên lai, why, soát spec, sổ quyết định).
- `.claude/settings.json`: khai báo các repo đồng cấp (`permissions.additionalDirectories`) và plugin cho team.
- `plugins/`, `vendor/`: các plugin của marketplace. Không sửa `vendor/`; xem `UPSTREAM.md`.

Khi phiên mở ở đây:

- Bắt đầu một tính năng bằng `/feature-workflow:feature-flow`.
- Thêm repo hoặc chỉnh workspace bằng `/feature-workflow:feature-setup`.
- Việc gắn với một repo (git, restore-point, MR, merge) làm trong repo đó. Lệnh chỉ người gõ được thì người làm `/cd ../<repo>` trước rồi mới gõ.
