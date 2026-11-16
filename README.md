# feature-workflow

Luồng làm tính năng của team, chạy trên Claude Code. Repo này làm hai việc:

1. **Plugin marketplace** gom bốn plugin vào một chỗ.
2. **Repo trung tâm của workspace**: các repo dự án nằm cùng thư mục cha dùng chung luồng, luật duyệt và tài liệu tính năng.

```
~/code/
├─ feature-workflow/          repo này (trung tâm)
│  ├─ workspace.json           repo đồng cấp + nơi lưu tài liệu tính năng
│  ├─ rules/common.md          luật duyệt chung
│  ├─ features/<slug>/         tài liệu tính năng lưu ở trung tâm
│  ├─ .claude/settings.json    khai báo repo đồng cấp, plugin cho team
│  ├─ CLAUDE.md                ngữ cảnh khi mở phiên ở đây
│  ├─ plugins/ vendor/         plugin của marketplace
│  └─ .claude-plugin/marketplace.json
├─ my-api/             repo đồng cấp
│  ├─ .claude/feature-workflow.json   { "workspace": "../feature-workflow" }
│  ├─ docs/flow-rules.md       luật riêng, bổ sung cho luật chung
│  └─ docs/features/<slug>/    tài liệu tính năng lưu trong repo
└─ my-web/                 repo đồng cấp
```

| Plugin | Ở đâu | Nội dung |
|---|---|---|
| `feature-workflow` | `plugins/feature-workflow/` | Skill của team: `feature-setup`, `feature-flow`, `feature-why`, `spec-check`, kèm mẫu file |
| `finolabs-vibecode` | `vendor/finolabs-vibecode/` | Bản ghim của finolabs: điều phối, điểm khôi phục, kiểm, review, cửa merge |
| `pstack` | `vendor/pstack/` | Bản ghim của pstack (bản dựng cho Claude Code): thiết kế, phản biện thiết kế, statechart, code, blast-radius |
| `mattpocock-skills` | `vendor/mattpocock-skills/` | Bản ghim skill của Matt Pocock: grill, spec, ticket |

Bản ghim, giấy phép và thay đổi so với upstream ghi trong [`UPSTREAM.md`](UPSTREAM.md). Luồng chốt ngày 13/11/2026.

## Luồng

```
0  Điều phối         /feature-workflow:feature-flow          preset + công tắc, đọc file luật, ghi biên lai
1  Có nên làm không? feature-why             (tuỳ chọn)  ── Dừng: chốt có làm
2  Hiểu yêu cầu      /mattpocock-skills:grill-with-docs → /mattpocock-skills:to-spec → spec-check
                                             (tuỳ chọn)  ── Dừng: duyệt spec
3  Thiết kế          /pstack:architect (+ /pstack:interrogate, /pstack:statechart)
                                             (tuỳ chọn)  ── Dừng: chốt thiết kế
   Trước code        /finolabs-vibecode:restore-point create
4  Mỗi MR            /pstack:poteto-mode → /pstack:blast-radius → /finolabs-vibecode:checks → /finolabs-vibecode:review-gate → merge_check.py
                                                         ── Dừng: duyệt và merge
5  Sau ra mắt        đọc chỉ số so với mục tiêu và ngưỡng dừng   (khi đã chạy bước 1)
```

**Bốn cửa dừng duyệt**: chốt có làm, duyệt spec, chốt thiết kế, duyệt và merge mỗi MR. Ngoài bốn cửa, agent trình kết quả rồi đi tiếp. Việc ghi trong luật duyệt (`rules/common.md` chung và `docs/flow-rules.md` của từng repo) thì không được tắt cửa duyệt.

**Preset**:

- small: bỏ giai đoạn 1 đến 3;
- medium: bật `unclear`, `cross`;
- large: bật `why`, `unclear`, `multi`, `cross`, `contest`, `state`, `repo`.

Người làm vẫn chỉnh từng công tắc. Chi tiết trong [`plugins/feature-workflow/skills/feature-flow/SKILL.md`](plugins/feature-workflow/skills/feature-flow/SKILL.md).

## Cài đặt

**1. Đặt repo này cùng thư mục cha với các repo dự án**, ví dụ `~/code/feature-workflow`.

**2. Gõ tay hai lệnh** trong Claude Code (một lần mỗi máy):

```text
/plugin marketplace add ~/code/feature-workflow
/plugin install feature-workflow@feature-workflow
```

Khi repo đã lên GitHub, dòng đầu có thể là `/plugin marketplace add <github-user>/feature-workflow`.

**3. Mở phiên mới ở repo này và gõ:**

```text
/feature-workflow:feature-setup
```

Ở repo trung tâm, `/feature-workflow:feature-setup`:

- cài ba plugin còn lại, cảnh báo bản trùng;
- tìm các repo git cùng thư mục cha, hỏi đưa repo nào vào workspace;
- hỏi nơi lưu tài liệu tính năng (`featureDocs`):
  - `auto`: tính năng một repo lưu trong repo đó, nhiều repo lưu ở trung tâm;
  - `central`: lưu hết ở trung tâm;
  - `project`: lưu hết trong repo dự án;
- ghi `workspace.json`, khai báo repo đồng cấp trong `.claude/settings.json`;
- ghi `.claude/feature-workflow.json` và `docs/flow-rules.md` vào từng repo;
- đọc code và hỏi để soạn luật chung (`rules/common.md`) và luật riêng từng repo;
- in sẵn lệnh setup của finolabs và Matt cho từng repo (kèm `/cd ../<repo>`).

Chạy lại bao nhiêu lần cũng được: nó chỉ làm phần còn thiếu. Thêm repo mới vào workspace thì chạy lại.

**Cho cả team**: khi được hỏi phạm vi cài, chọn `team`. `feature-setup` ghi `enabledPlugins` (và `extraKnownMarketplaces` nếu repo này có remote GitHub) vào `.claude/settings.json`. Commit file đó; đồng đội clone về, tin cậy thư mục, sẽ được nhắc cài plugin. Đồng đội cũng cần clone các repo dự án vào cùng thư mục cha.

**Cài tay**: cài thêm `finolabs-vibecode@feature-workflow`, `pstack@feature-workflow`, `mattpocock-skills@feature-workflow`; với mỗi repo dự án chạy `scripts/init-project.sh ../<repo>` từ repo này; rồi gõ `/mattpocock-skills:setup-matt-pocock-skills` và `/finolabs-vibecode:setup` trong từng repo.

**Một repo đơn lẻ, không workspace**: mở phiên trong repo đó và gõ `/feature-workflow:feature-setup`; nó nhận ra không có workspace và setup riêng repo đó.

## Dùng

Skill của plugin luôn gọi kèm tên plugin: `/<plugin>:<skill>`. Gõ `/feature-workflow:` rồi Tab để Claude Code gợi ý tên.

- **Tính năng một repo**: mở phiên trong repo đó.
- **Tính năng nhiều repo**: mở phiên ở repo trung tâm. Phiên thấy được các repo đồng cấp khai báo trong `.claude/settings.json`. Việc gắn với một repo (restore-point, git, MR, merge) làm trong repo đó; lệnh chỉ người gõ được thì `/cd ../<repo>` trước.

```
/feature-workflow:feature-flow large mở lại kỳ đã khóa
```

Mỗi tính năng có một thư mục tính năng (vị trí theo `featureDocs`) chứa:

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
- Có gom `deslop` (plugin `cursor-team-kit`) hay không.
- Repo trên GitLab: `merge_check.py` và `post_review.py` của finolabs chỉ gọi `gh` (GitHub). Ở GitLab, cửa merge và việc đăng review lên MR không chạy được, cần thay thế hoặc bỏ.

## Đã kiểm

- `restore-point` chụp cả thay đổi chưa commit: nó lưu snapshot của working tree lên một ref local, không đụng index, nhánh hay HEAD.
- Mọi skill luồng này gọi tới đều có trong bản ghim, và cả bốn plugin cài được từ marketplace này (`claude plugin validate`, cài thử trên máy trống).
