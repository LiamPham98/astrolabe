# feature-workflow

Luồng làm tính năng của team, chạy trên Claude Code. Repo này là một **plugin marketplace** gom bốn plugin vào một chỗ:

| Plugin | Ở đâu | Nội dung |
|---|---|---|
| `feature-workflow` | `plugins/feature-workflow/` | Skill của team: `feature-setup`, `feature-flow`, `feature-why`, `spec-check`, kèm mẫu file |
| `finolabs-vibecode` | `vendor/finolabs-vibecode/` | Bản ghim của finolabs: điều phối, điểm khôi phục, kiểm, review, cửa merge |
| `pstack` | `vendor/pstack/` | Bản ghim của pstack: thiết kế, phản biện thiết kế, statechart, code, blast-radius |
| `mattpocock-skills` | `vendor/mattpocock-skills/` | Bản ghim skill của Matt Pocock: grill, spec, ticket |

Bản ghim, giấy phép và thay đổi so với upstream ghi trong [`UPSTREAM.md`](UPSTREAM.md). Luồng chốt ngày 13/11/2026.

## Luồng

```
0  Điều phối         /feature-flow          preset + công tắc, đọc file luật, ghi biên lai
1  Có nên làm không? feature-why             (tuỳ chọn)  ── Dừng: chốt có làm
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

Người làm vẫn chỉnh từng công tắc. Chi tiết trong [`plugins/feature-workflow/skills/feature-flow/SKILL.md`](plugins/feature-workflow/skills/feature-flow/SKILL.md).

## Cài đặt

**1. Gõ tay hai lệnh** trong Claude Code (một lần mỗi máy):

```text
/plugin marketplace add <github-user>/feature-workflow
/plugin install feature-workflow@feature-workflow
```

Chưa đẩy lên GitHub thì dùng đường dẫn thư mục: `/plugin marketplace add ~/feature-workflow`.

**2. Mở phiên mới trong repo dự án và gõ:**

```text
/feature-setup
```

`/feature-setup` kiểm tra rồi báo cáo trước, hỏi duyệt, sau đó mới làm:

- cài ba plugin còn lại, cảnh báo bản trùng cài từ nguồn khác;
- tạo `docs/features/` và `docs/flow-rules.md`;
- đọc code và hỏi vài câu để soạn file luật duyệt cho đúng repo;
- in sẵn `/setup` (finolabs) và `/setup-matt-pocock-skills` để anh gõ, vì hai skill này chỉ người gõ được;
- kiểm công cụ cho `/statechart`.

Chạy lại bao nhiêu lần cũng được: nó chỉ làm phần còn thiếu, không ghi đè file luật đã có.

**Cài tay (không dùng `/feature-setup`)**: cài thêm `finolabs-vibecode@feature-workflow`, `pstack@feature-workflow`, `mattpocock-skills@feature-workflow`. Sau đó chạy `scripts/init-project.sh <repo-dự-án>`, sửa `docs/flow-rules.md`, rồi gõ `/setup-matt-pocock-skills` và `/setup` trong repo dự án.

## Dùng

```
/feature-flow large mở lại kỳ đã khóa
```

Mỗi tính năng có một thư mục `docs/features/<slug>/` chứa:

- `flow.md`: biên lai quy trình;
- `why.md`: kết quả bước Why;
- `spec-check.md`: kết quả soát spec;
- `decisions.md`: sổ quyết định.

Xem [`docs/cheat-sheet.md`](docs/cheat-sheet.md).

## Cập nhật bản ghim

```bash
./scripts/update-vendor.sh pstack <commit>
```

Rồi làm theo các bước trong [`UPSTREAM.md`](UPSTREAM.md). Không sửa trực tiếp trong `vendor/`.

## Còn treo

- Giấy phép vibebiz: làm rõ trước khi lấy thêm bất kỳ phần nào trực tiếp từ code gốc.
- `post_review.py` và `merge_check.py` có chạy với MR trên GitLab không.
- `restore-point` có chụp thay đổi chưa commit không.
- Có gom `deslop` (plugin `cursor-team-kit`) hay không.
- pstack lấy từ `cursor/plugins`. Nếu team đang dùng bản mirror `backnotprop/pstack` (đã viết lại một số skill cho trung lập với harness), đổi nguồn trong `scripts/update-vendor.sh` và `UPSTREAM.md`.
