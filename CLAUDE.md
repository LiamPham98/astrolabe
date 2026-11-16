# astrolabe: mã nguồn plugin

Repo này là marketplace và mã nguồn của plugin `astrolabe` (luồng làm tính năng cho Claude Code). Người dùng cài thẳng từ GitHub; repo này không phải nơi chứa cấu hình hay tài liệu của dự án nào.

- `plugins/astrolabe/`: plugin. `skills/` gồm `flow`, `why`, `spec-check`, `setup`, `help`; mẫu file nằm trong `templates/` của từng skill.
- `plugins/astrolabe/.claude-plugin/plugin.json`: manifest, có `userConfig` (`workspace_root`, `docs_backend`, `orrery_space`). Đổi gì trong plugin thì tăng `version`, để máy cài từ GitHub nhận bản mới.
- `.claude-plugin/marketplace.json`: marketplace trỏ tới `plugins/astrolabe`. Mô tả plugin ở đây phải giống `plugin.json`.
- `UPSTREAM.md`: ba bộ đồng hành tuỳ chọn (finolabs-vibecode, pstack, mattpocock-skills) và phần tham khảo từ vibebiz.
- Plugin không ghi file nào vào repo dự án. Tài liệu tính năng và luật duyệt nằm ở Orrery hoặc thư mục dữ liệu của plugin; xem mục "Nơi lưu tài liệu" trong `plugins/astrolabe/skills/flow/SKILL.md`.

Khi sửa plugin:

- Thử bằng `claude --plugin-dir plugins/astrolabe`, và `claude plugin validate plugins/astrolabe` trước khi commit.
- Ghi thay đổi vào mục `[Unreleased]` của `CHANGELOG.md`.
- Repo public: không đưa tên repo, URL hay dữ liệu nội bộ vào ví dụ.
