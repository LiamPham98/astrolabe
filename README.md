# feature-workflow

Luồng làm tính năng của team, chạy trên Claude Code. Ghép ba bộ skill có sẵn (finolabs, Matt Pocock, pstack) thành một luồng có xương sống cố định và các giai đoạn tuỳ chọn, cộng thêm hai skill phân tích viết theo cấu trúc của vibebiz.

Luồng chốt ngày 13/11/2026.

## Luồng

```
0  Điều phối         /feature-flow          preset + công tắc, đọc file luật, ghi biên lai
1  Có nên làm không? why                     (tuỳ chọn)  ── Dừng: chốt có làm
2  Hiểu yêu cầu      /grill-with-docs → /to-spec → spec-check
                                             (tuỳ chọn)  ── Dừng: duyệt spec
3  Thiết kế          /architect (+ /interrogate, /statechart)
                                             (tuỳ chọn)  ── Dừng: chốt thiết kế
   Trước code        /restore-point create
4  Mỗi MR            /poteto-mode → /blast-radius → /checks → /review-gate → merge_check.py
                                                         ── Dừng: duyệt và merge
5  Sau ra mắt        đọc chỉ số so với mục tiêu và ngưỡng dừng   (khi đã chạy bước 1)
```

**Bốn cửa dừng duyệt**: chốt có làm, duyệt spec, chốt thiết kế, duyệt và merge mỗi MR. Ngoài bốn cửa, agent trình kết quả rồi đi tiếp. Việc ghi trong `docs/flow-rules.md` thì không được tắt cửa duyệt.

**Preset**:

- small: bỏ giai đoạn 1 đến 3;
- medium: bật `unclear`, `cross`;
- large: bật `why`, `unclear`, `multi`, `cross`, `contest`, `state`, `repo`.

Người làm vẫn chỉnh từng công tắc. Chi tiết trong [`skills/feature-flow/SKILL.md`](skills/feature-flow/SKILL.md).

## Có gì trong repo

```
skills/
  feature-flow/     dẫn luồng; templates/ có flow.md, decisions.md, flow-rules.md
  why/              bước "có nên làm không"; templates/why.md
  spec-check/       soát spec + checklist sẵn sàng, chỉ đọc
scripts/install.sh  cài vào repo dự án
docs/cheat-sheet.md một trang cho team
UPSTREAM.md         bản ghim của ba bộ skill, phần tham khảo từ vibebiz
```

## Cài đặt

Điều kiện: repo dự án đã cài pstack, skill của Matt và bộ finolabs, đúng bản ghim trong [`UPSTREAM.md`](UPSTREAM.md).

```bash
git clone <repo này> ~/feature-workflow
~/feature-workflow/scripts/install.sh /đường/dẫn/repo-dự-án
```

Script chép ba skill vào `.claude/skills/`, tạo `docs/flow-rules.md` từ mẫu (nếu chưa có) và thư mục `docs/features/`. Thêm `--force` để ghi đè skill đã cài.

Sau khi cài, làm một lần cho mỗi repo:

1. Sửa `docs/flow-rules.md` cho đúng repo.
2. Chạy `/setup-matt-pocock-skills`, chọn lưu spec dạng markdown local.
3. Adopt cửa `merge_check.py` của finolabs. Chưa adopt thì MR không có cửa cứng.
4. Cài Java và TLC nếu dùng `/statechart`.

## Dùng

```
/feature-flow large mở lại kỳ đã khóa
```

Mỗi tính năng có một thư mục `docs/features/<slug>/` chứa biên lai (`flow.md`), kết quả bước Why (`why.md`), kết quả soát spec (`spec-check.md`) và sổ quyết định (`decisions.md`). Xem [`docs/cheat-sheet.md`](docs/cheat-sheet.md).

## Còn treo

- Giấy phép vibebiz: làm rõ trước khi lấy thêm bất kỳ phần nào trực tiếp từ code gốc.
- `post_review.py` và `merge_check.py` có chạy với MR trên GitLab không.
- `restore-point` có chụp thay đổi chưa commit không.
- Nguồn của skill `statechart`; có cài `deslop` hay không.
- Điền bản ghim của pstack và finolabs trong `UPSTREAM.md`.
