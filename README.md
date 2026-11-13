# feature-workflow

Luồng làm tính năng của team, chạy trên Claude Code. Repo này là một **plugin marketplace** gom bốn plugin vào một chỗ:

| Plugin | Ở đâu | Nội dung |
|---|---|---|
| `feature-workflow` | `plugins/feature-workflow/` | Skill của team: `feature-flow`, `feature-why`, `spec-check`, kèm mẫu file |
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

**1. Cài plugin** (một lần mỗi máy), gõ trong Claude Code:

```text
/plugin marketplace add <github-user>/feature-workflow
/plugin install feature-workflow@feature-workflow
/plugin install finolabs-vibecode@feature-workflow
/plugin install pstack@feature-workflow
/plugin install mattpocock-skills@feature-workflow
```

Đã cài finolabs-vibecode, pstack hoặc skill của Matt từ nguồn khác thì gỡ bản đó trước, để không có hai bản cùng chạy.

**2. Chuẩn bị repo dự án** (một lần mỗi repo):

```bash
git clone <repo này> ~/feature-workflow
~/feature-workflow/scripts/init-project.sh /đường/dẫn/repo-dự-án
```

Script tạo `docs/flow-rules.md` từ mẫu (nếu chưa có) và thư mục `docs/features/`. Sau đó, trong repo dự án:

1. Sửa `docs/flow-rules.md` cho đúng repo.
2. Chạy `/setup-matt-pocock-skills`, chọn lưu spec dạng markdown local.
3. Adopt cửa `merge_check.py` của finolabs-vibecode. Chưa adopt thì MR không có cửa cứng.
4. Cài Java và TLC nếu dùng `/statechart`.

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
