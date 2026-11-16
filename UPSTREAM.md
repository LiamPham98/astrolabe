# Upstream

Repo này chỉ chứa bộ skill của team (`plugins/feature-workflow/`). Ba bộ còn lại cài thẳng từ marketplace của upstream, bật `autoUpdate`. Repo không chép code của upstream.

Quyết định ngày 16/11/2026: bỏ bản ghim trong `vendor/` (đến bản 0.3.0), lấy bản mới nhất của upstream. Đổi lại, luồng có thể hỏng khi upstream đổi tên, bỏ hoặc đổi hành vi một skill mà luồng gọi tới.

## Nguồn

| Plugin | Marketplace | Repo | Giấy phép |
|---|---|---|---|
| `finolabs-vibecode@finolabs-vibecode` | `finolabs-vibecode` | https://github.com/finolabs/finolabs-vibecode | MIT, Fioenix |
| `pstack@cursor-plugins` | `cursor-plugins` | https://github.com/cursor/plugins (bản dựng cho Claude Code, thư mục `harness/pstack/claude-code/`) | MIT, Lauren Tan |
| `mattpocock-skills@mattpocock` | `mattpocock` | https://github.com/mattpocock/skills | MIT, Matt Pocock |

Danh sách này khai trong `upstream.json` ở gốc repo: mỗi mục có `marketplace`, `repo` (GitHub), `plugin` và `skills` (skill luồng gọi tới, để kiểm còn tồn tại); `retired` liệt kê plugin cũ cần gỡ. `scripts/setup-machine.sh` đọc file đó, ghi các marketplace vào `extraKnownMarketplaces` của `~/.claude/settings.json` với `"autoUpdate": true`, rồi cài plugin. Thêm hay thay một bộ: sửa `upstream.json` và bảng dưới, không cần sửa script.

## Cập nhật chạy thế nào

- Mỗi phiên Claude Code, sau tin nhắn đầu, Claude Code làm mới marketplace và cập nhật plugin. Bản mới có hiệu lực ở phiên sau, hoặc sau `/reload-plugins`.
- Bản "mới hơn" tính theo `version` trong `plugin.json` của upstream, không theo commit. Upstream đẩy commit mà không tăng `version` thì máy không nhận.
- Cập nhật tay: `claude plugin marketplace update <marketplace>`, rồi `claude plugin update <plugin>@<marketplace>`.
- `DISABLE_AUTOUPDATER=1` hoặc `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` tắt lượt cập nhật plugin; `FORCE_AUTOUPDATE_PLUGINS=1` bật lại.
- Chạy lại `scripts/setup-machine.sh` sau một lần cập nhật để kiểm các skill trong `upstream.json` vẫn còn. Script báo `THIẾU` khi upstream đổi tên hoặc bỏ skill. Script không phát hiện skill đổi hành vi.

pstack dùng bản dựng cho Claude Code mà chính upstream phát hành, không dùng thư mục `pstack/` gốc. Bản dựng này bảo agent đọc `docs/harness/claude-code.md`, file ánh xạ công cụ, subagent và model của Cursor sang Claude Code. Muốn sửa một skill của upstream: viết skill riêng trong `plugins/feature-workflow/`, hoặc gửi thay đổi lên upstream.

## Skill luồng này dùng

| Bộ | Skill |
|---|---|
| finolabs-vibecode | `coding-router`, `restore-point`, `checks`, `review-gate`, `security-review-gate`; script `merge_check.py`, `post_review.py` |
| pstack | `architect`, `interrogate`, `statechart`, `poteto-mode`, `blast-radius`, `how` |
| mattpocock-skills | `grill-with-docs` (gọi `grilling`, `domain-modeling`), `to-spec`, `to-tickets`, `setup-matt-pocock-skills` |

Không dùng: `/mattpocock-skills:implement` của Matt, `none.md implement` của finolabs. `deslop` không có trong ba bộ này; nó nằm trong plugin `cursor-team-kit` của Cursor, chưa gom vào.

Trùng tên skill giữa các bộ: pstack và Matt đều có `tdd`, `teach`; Matt và finolabs đều có `handoff`. Mọi skill của plugin đều gọi bằng `/<plugin>:<skill>` (ví dụ `/pstack:tdd`, `/mattpocock-skills:tdd`), nên trùng tên không đè nhau. Skill rời trong `~/.claude/skills` thì không có tiền tố, nên trùng tên với skill của plugin là gọi lẫn; `scripts/setup-machine.sh` chuyển các skill rời đó sang `~/.claude/skills-backup-<ngày>/`. Skill "có nên làm không" của team đặt tên `feature-why` để không trùng với `why` của pstack.

## Phần tham khảo từ vibebiz

Nguồn: https://github.com/finolabs/vibebiz, commit `08b1649` (bản 0.1.1). Giấy phép PolyForm Noncommercial 1.0.0, bản quyền Fioenix. **Không gom vào repo này.**

Hai skill dưới đây viết lại bằng lời riêng theo cấu trúc tham khảo, không sao chép văn bản hay code của vibebiz:

| Ở đây | Cấu trúc tham khảo từ vibebiz |
|---|---|
| `feature-why`: cây phụ thuộc, xếp hạng tác động × mức chưa rõ, độ sâu theo loại việc | router |
| `feature-why`: cách hỏi theo vòng, phương án đề xuất đứng đầu | ask protocol |
| `feature-why`: luật không khen, lý do thất bại cụ thể, rủi ro bỏ qua phải ghi | anti-sycophancy, challenge lens |
| `feature-why`: từ thứ muốn có sang kết quả, chỉ số không được xấu đi, ngưỡng dừng | outcome lens |
| `spec-check`: các lượt soát và mức nghiêm trọng | analyze |
| `spec-check`: checklist sẵn sàng | checklist |
| `feature-flow/templates/flow-rules.md`: việc luôn cần người duyệt | constitution (`mandatory_approvals`) |
| `feature-flow/templates/decisions.md`: sổ chỉ ghi thêm, loại `dismissed-risk`, `supersede` | decisions |
| File này | `UPSTREAM.md` của vibebiz |

**Còn treo**: làm rõ giấy phép với chủ repo vibebiz trước khi lấy thêm bất kỳ phần nào trực tiếp từ code gốc.
