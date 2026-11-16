# astrolabe: plugin và repo trung tâm mẫu

Repo này vừa là plugin marketplace của luồng làm tính năng (plugin ở `plugins/astrolabe/`, cài được thẳng từ GitHub), vừa dùng được làm repo trung tâm của một workspace gồm nhiều repo đồng cấp nằm cùng thư mục cha.

- `workspace.json`: danh sách repo đồng cấp (`projects`, đường dẫn tương đối như `../my-api`), nơi lưu tài liệu tính năng (`docsBackend`: `local` mặc định hoặc `orrery`), thư mục local (`featureDocs`: `auto`, `central` hoặc `project`) và space Orrery (`orrery.space`, chỉ khi `docsBackend: orrery`).
- `rules/common.md`: luật duyệt chung cho mọi repo trong workspace. Mỗi repo có thể bổ sung trong `docs/flow-rules.md` của nó.
- Tài liệu tính năng (biên lai, why, spec, ticket, soát spec, sổ quyết định), `GLOSSARY.md` và ADR lưu theo `docsBackend`; cách đọc ghi ở mục "Nơi lưu tài liệu" của skill `astrolabe:flow`. Luật duyệt luôn nằm trong git.
- `.claude/settings.json`: khai báo các repo đồng cấp (`permissions.additionalDirectories`), sinh theo máy, nằm trong `.gitignore`.
- `plugins/astrolabe/`: plugin. `upstream.json` khai các bộ skill upstream (finolabs-vibecode, pstack, mattpocock-skills) mà `scripts/setup-machine.sh` cài, và skill luồng cần kiểm; xem `UPSTREAM.md`.
- `scripts/`: lối tắt tới `plugins/astrolabe/scripts/` cho bản clone.
- Đổi gì trong plugin thì tăng `version` trong `plugins/astrolabe/.claude-plugin/plugin.json`, để máy cài từ GitHub nhận bản mới.

Khi phiên mở ở đây:

- Bắt đầu một tính năng bằng `/astrolabe:flow`.
- Thêm repo hoặc chỉnh workspace bằng `/astrolabe:setup`.
- Việc gắn với một repo (git, restore-point, MR, merge) làm trong repo đó. Lệnh chỉ người gõ được thì người làm `/cd ../<repo>` trước rồi mới gõ.
