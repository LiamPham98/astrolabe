# Upstream

feature-workflow chạy trên ba bộ skill cài riêng, và tham khảo cấu trúc phân tích của vibebiz. Bảng dưới ghim bản đang dùng. **Chỉ cập nhật bản ghim có chủ đích**: đọc thay đổi của upstream, chạy thử luồng, rồi sửa bảng này trong cùng một MR.

## Ba bộ skill luồng này gọi tới

| Bộ | Nguồn | Bản ghim | Skill luồng này dùng |
|---|---|---|---|
| Matt Pocock skills | https://github.com/mattpocock/skills | `5863806` (HEAD ngày 13/11/2026, cần xác nhận là bản team đang cài) | `grill-with-docs` (gọi `grilling`, `domain-modeling`), `to-spec`, `to-tickets`, `setup-matt-pocock-skills` |
| pstack | `<điền nguồn team đang dùng>` | `<điền commit>` | `architect`, `interrogate`, `poteto-mode`, `blast-radius`, `how`, `statechart` (cần xác nhận nguồn) |
| finolabs | `<điền repo>` | `<điền commit>` | `coding-router`, `restore-point`, `checks`, `review-gate`, `security-review-gate`, `merge_check.py` |

Không dùng: `/implement` của Matt, `none.md implement` của finolabs, `deslop` (chưa quyết định có cài bản port hay không).

## Phần tham khảo từ vibebiz

Nguồn: https://github.com/finolabs/vibebiz, commit `08b1649` (bản 0.1.1). Giấy phép PolyForm Noncommercial 1.0.0, bản quyền Fioenix.

feature-workflow **không sao chép** văn bản hay code của vibebiz. Các skill dưới đây viết lại bằng lời riêng theo cấu trúc tham khảo:

| Ở đây | Cấu trúc tham khảo từ vibebiz |
|---|---|
| `skills/why`: cây phụ thuộc, xếp hạng tác động × mức chưa rõ, độ sâu theo loại việc | router |
| `skills/why`: cách hỏi theo vòng, phương án đề xuất đứng đầu | ask protocol |
| `skills/why`: luật không khen, lý do thất bại cụ thể, rủi ro bỏ qua phải ghi | anti-sycophancy, challenge lens |
| `skills/why`: từ thứ muốn có sang kết quả, chỉ số không được xấu đi, ngưỡng dừng | outcome lens |
| `skills/spec-check`: các lượt soát và mức nghiêm trọng | analyze |
| `skills/spec-check`: checklist sẵn sàng | checklist |
| `skills/feature-flow/templates/flow-rules.md`: việc luôn cần người duyệt | constitution (`mandatory_approvals`) |
| `skills/feature-flow/templates/decisions.md`: sổ chỉ ghi thêm, loại `dismissed-risk`, `supersede` | decisions |
| File này | `UPSTREAM.md` của vibebiz |

**Còn treo**: làm rõ giấy phép với chủ repo vibebiz trước khi lấy thêm bất kỳ phần nào trực tiếp từ code gốc.
