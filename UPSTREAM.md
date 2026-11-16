# Bộ đồng hành và nguồn tham khảo

Repo này chỉ chứa plugin `astrolabe` (`plugins/astrolabe/`). Ba bộ dưới đây là **đồng hành tuỳ chọn**: luồng chạy đủ khi không có bộ nào, và dùng bộ nào đã cài cho bước mà bộ đó làm tốt hơn (bảng "Bước và công cụ" trong `plugins/astrolabe/skills/flow/SKILL.md`). Repo không chép code của bộ nào.

Quyết định ngày 16/11/2026 (bản 0.6.0): bỏ việc bắt buộc cài ba bộ này và bỏ script cài máy. Lý do: plugin phải cài xong là dùng được. Đổi lại, khi chưa cài bộ nào, các bước dùng cách mặc định dựa trên những gì Claude Code có sẵn.

## Ba bộ đồng hành

| Plugin | Marketplace | Repo | Giấy phép |
|---|---|---|---|
| `finolabs-vibecode@finolabs-vibecode` | `finolabs-vibecode` | https://github.com/finolabs/finolabs-vibecode | MIT, Fioenix |
| `pstack@cursor-plugins` | `cursor-plugins` | https://github.com/cursor/plugins (bản dựng cho Claude Code, thư mục `harness/pstack/claude-code/`) | MIT, Lauren Tan |
| `mattpocock-skills@mattpocock` | `mattpocock` | https://github.com/mattpocock/skills | MIT, Matt Pocock |

Lệnh cài nằm ở mục "Bộ đồng hành" của README và của skill `astrolabe:setup`.

| Bộ | Skill luồng dùng khi có mặt |
|---|---|
| finolabs-vibecode | `coding-router`, `restore-point`, `checks`, `review-gate`, `security-review-gate`; script `merge_check.py` |
| pstack | `architect`, `interrogate`, `statechart`, `poteto-mode`, `blast-radius`, `how` |
| mattpocock-skills | `grill-with-docs` (gọi `grilling`, `domain-modeling`), `to-spec`, `to-tickets` |

Không dùng: `/mattpocock-skills:implement` của Matt, `none.md implement` của finolabs.

Bộ đồng hành tự cập nhật theo `version` trong `plugin.json` của chúng. Một bộ đổi tên hay bỏ một skill thì `astrolabe:flow` không thấy skill đó trong phiên và quay về cách mặc định của bước đó.

Mọi skill của plugin đều gọi kèm tiền tố (`/pstack:tdd`, `/mattpocock-skills:tdd`, `/astrolabe:why`), nên trùng tên giữa các bộ không đè nhau. Skill rời trong `~/.claude/skills` thì không có tiền tố, nên trùng tên với skill của plugin là gọi lẫn.

## Phần tham khảo từ vibebiz

Nguồn: https://github.com/finolabs/vibebiz, commit `08b1649` (bản 0.1.1). Giấy phép PolyForm Noncommercial 1.0.0, bản quyền Fioenix. **Không gom vào repo này.**

Các phần dưới đây viết lại bằng lời riêng theo cấu trúc tham khảo, không sao chép văn bản hay code của vibebiz:

| Ở đây | Cấu trúc tham khảo từ vibebiz |
|---|---|
| `astrolabe:why`: cây phụ thuộc, xếp hạng tác động × mức chưa rõ, độ sâu theo loại việc | router |
| `astrolabe:why`: cách hỏi theo vòng, phương án đề xuất đứng đầu | ask protocol |
| `astrolabe:why`: luật không khen, lý do thất bại cụ thể, rủi ro bỏ qua phải ghi | anti-sycophancy, challenge lens |
| `astrolabe:why`: từ thứ muốn có sang kết quả, chỉ số không được xấu đi, ngưỡng dừng | outcome lens |
| `spec-check`: các lượt soát và mức nghiêm trọng | analyze |
| `spec-check`: checklist sẵn sàng | checklist |
| `flow/templates/rules-common.md`, `rules-repo.md`: việc luôn cần người duyệt | constitution (`mandatory_approvals`) |
| `flow/templates/decisions.md`: sổ chỉ ghi thêm, loại `dismissed-risk`, `supersede` | decisions |
| File này | `UPSTREAM.md` của vibebiz |

**Còn treo**: làm rõ giấy phép với chủ repo vibebiz trước khi lấy thêm bất kỳ phần nào trực tiếp từ code gốc.
