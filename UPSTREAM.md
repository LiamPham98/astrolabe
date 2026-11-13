# Upstream

Repo này gom bản chép nguyên của ba bộ skill vào `vendor/`, cộng bộ skill của team trong `plugins/feature-workflow/`. Ba bộ đều theo giấy phép MIT; file LICENSE gốc của từng bộ giữ nguyên trong thư mục của bộ đó.

**Chỉ cập nhật bản ghim có chủ đích**:

1. Chạy `scripts/update-vendor.sh <bộ> <commit>`.
2. Đọc `git diff`.
3. Chạy thử luồng trên một tính năng thật.
4. Sửa bảng dưới.
5. Commit tất cả trong cùng một MR.

## Bản ghim

| Thư mục | Nguồn | Commit | Phiên bản | Giấy phép |
|---|---|---|---|---|
| `vendor/finolabs-vibecode` | https://github.com/finolabs/finolabs-vibecode | `9b7c83c18a14182db35afb8bbea05349b1a3ab8d` | 0.2.6-dev | MIT, Fioenix |
| `vendor/pstack` | https://github.com/cursor/plugins (thư mục `pstack/`) | `6e359ce0aba9e927914d8a940510aa2ef66a8f23` | 0.15.36 | MIT, Lauren Tan |
| `vendor/mattpocock-skills` | https://github.com/mattpocock/skills | `5863806dd4e15c63174bee4e7515a4256792ecfa` | 1.3.2 | MIT, Matt Pocock |

Lấy ngày 13/11/2026.

## Thay đổi so với upstream

| Thư mục | Thay đổi | Lý do |
|---|---|---|
| `vendor/pstack/.claude-plugin/plugin.json` | Thêm mới | Upstream chỉ có manifest cho Cursor (`.cursor-plugin/`). File này để Claude Code cài được pstack như một plugin. Nội dung lấy từ manifest gốc |

Ngoài file trên, `vendor/` giữ nguyên từng byte so với upstream. Muốn sửa một skill của upstream thì không sửa trong `vendor/`: viết skill riêng trong `plugins/feature-workflow/`, hoặc gửi thay đổi lên upstream.

## Skill luồng này dùng

| Bộ | Skill |
|---|---|
| finolabs-vibecode | `coding-router`, `restore-point`, `checks`, `review-gate`, `security-review-gate`; script `merge_check.py`, `post_review.py` |
| pstack | `architect`, `interrogate`, `statechart`, `poteto-mode`, `blast-radius`, `how` |
| mattpocock-skills | `grill-with-docs` (gọi `grilling`, `domain-modeling`), `to-spec`, `to-tickets`, `setup-matt-pocock-skills` |

Không dùng: `/implement` của Matt, `none.md implement` của finolabs. `deslop` không có trong ba bộ này; nó nằm trong plugin `cursor-team-kit` của Cursor, chưa gom vào.

Trùng tên skill giữa các bộ: pstack và Matt đều có `tdd`, `teach`; Matt và finolabs đều có `handoff`. Skill của plugin được phân biệt theo tên plugin, nên gõ kèm tên plugin khi cần (ví dụ `/pstack:tdd`). Skill "có nên làm không" của team đặt tên `feature-why` để không trùng với `why` của pstack.

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
