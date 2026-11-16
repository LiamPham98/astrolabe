# astrolabe

Luồng làm tính năng của team, chạy trên Claude Code. Repo, plugin và marketplace cùng tên `astrolabe`; lệnh gõ `/astrolabe:<skill>`. Repo này làm hai việc:

1. **Plugin marketplace** của skill team, cộng script cài ba bộ skill upstream (bản mới nhất, tự cập nhật).
2. **Repo trung tâm của workspace**: các repo dự án nằm cùng thư mục cha dùng chung luồng, luật duyệt và tài liệu tính năng.

```
~/code/
├─ astrolabe/                  repo này (trung tâm)
│  ├─ workspace.json            repo đồng cấp + nơi lưu tài liệu
│  ├─ upstream.json             bộ skill upstream cần cài và skill luồng cần
│  ├─ rules/common.md           luật duyệt chung
│  ├─ features/<slug>/          tài liệu tính năng nhiều repo (docsBackend: local)
│  ├─ .claude/settings.json     khai báo repo đồng cấp, sinh theo máy (gitignore)
│  ├─ CLAUDE.md                 ngữ cảnh khi mở phiên ở đây
│  ├─ plugins/                  plugin của team
│  ├─ scripts/setup-machine.sh  cài cho máy, chạy một lần
│  └─ .claude-plugin/marketplace.json
├─ my-api/                     repo đồng cấp (tên ví dụ)
│  ├─ .claude/astrolabe.json  { "workspace": "../astrolabe" }
│  ├─ docs/flow-rules.md        luật riêng, bổ sung cho luật chung
│  └─ docs/features/<slug>/     tài liệu tính năng một repo (docsBackend: local)
└─ my-web/                     repo đồng cấp (tên ví dụ)
```

| Plugin | Cài từ | Nội dung |
|---|---|---|
| `astrolabe` | `plugins/astrolabe/` (repo này) | Skill của team: `setup`, `flow`, `why`, `spec-check`, `help`, kèm mẫu file |
| `finolabs-vibecode` | Marketplace `finolabs-vibecode` (GitHub, tự cập nhật) | Điều phối, điểm khôi phục, kiểm, review, cửa merge |
| `pstack` | Marketplace `cursor-plugins` (GitHub, tự cập nhật) | Bản dựng cho Claude Code: thiết kế, phản biện thiết kế, statechart, code, blast-radius |
| `mattpocock-skills` | Marketplace `mattpocock` (GitHub, tự cập nhật) | Skill của Matt Pocock: grill, spec, ticket |

Ba bộ upstream khai trong [`upstream.json`](upstream.json); nguồn, giấy phép và cách cập nhật ghi trong [`UPSTREAM.md`](UPSTREAM.md). Luồng chốt ngày 13/11/2026; chuyển sang bản upstream mới nhất ngày 16/11/2026.

## Luồng

```
0  Điều phối         /astrolabe:flow          preset + công tắc, đọc file luật, ghi biên lai
1  Có nên làm không? astrolabe:why             (tuỳ chọn)  ── Dừng: chốt có làm
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

Người làm vẫn chỉnh từng công tắc. Chi tiết trong [`plugins/astrolabe/skills/flow/SKILL.md`](plugins/astrolabe/skills/flow/SKILL.md).

## Cài đặt

**1. Đặt repo này cùng thư mục cha với các repo dự án**, ví dụ `~/code/astrolabe`.

**2. Chạy một lần mỗi máy** (Git Bash trên Windows):

```bash
./scripts/setup-machine.sh
```

Script đọc `upstream.json` và `.claude-plugin/marketplace.json`, ghi marketplace và plugin vào `~/.claude/settings.json` (sao lưu bản cũ), cài plugin của repo này cùng các bộ upstream, bật tự cập nhật cho bộ upstream, gỡ plugin cũ liệt kê trong `retired`, chuyển skill rời trùng tên trong `~/.claude/skills` sang `~/.claude/skills-backup-<ngày>/`, rồi kiểm các skill luồng cần. Chạy lại bao nhiêu lần cũng được.

Bộ skill của Matt cài qua `npx skills` cho Codex, Antigravity nằm ở `~/.agents/skills`; script không đụng tới. Khi `npx skills add` hay `update`, bỏ chọn Claude Code để không sinh lại symlink trùng.

**3. Mở phiên mới ở repo này và gõ:**

```text
/astrolabe:setup
```

Ở repo trung tâm, `/astrolabe:setup`:

- kiểm plugin theo `upstream.json` và bản trùng, chỉ lại `scripts/setup-machine.sh` khi thiếu;
- tìm các repo git cùng thư mục cha, hỏi đưa repo nào vào workspace;
- hỏi nơi lưu tài liệu (`docsBackend`): `local` (mặc định, file markdown trong git) hay `orrery`; với `orrery`, kiểm phiên có Orrery và thấy space `orrery.space` không;
- hỏi thư mục local (`featureDocs`):
  - `auto`: tính năng một repo lưu trong repo đó, nhiều repo lưu ở trung tâm;
  - `central`: lưu hết ở trung tâm;
  - `project`: lưu hết trong repo dự án;
- ghi `workspace.json`, khai báo repo đồng cấp trong `.claude/settings.json`;
- ghi `.claude/astrolabe.json` và `docs/flow-rules.md` vào từng repo;
- đọc code và hỏi để soạn luật chung (`rules/common.md`) và luật riêng từng repo;
- in sẵn lệnh setup của finolabs và Matt cho từng repo (kèm `/cd ../<repo>`).

Chạy lại bao nhiêu lần cũng được: nó chỉ làm phần còn thiếu. Thêm repo mới vào workspace thì chạy lại.

**Cho cả team**: mỗi đồng đội clone repo này và các repo dự án vào cùng thư mục cha, rồi chạy `./scripts/setup-machine.sh`. Plugin upstream cập nhật theo từng máy, nên hai máy có thể đang ở hai bản khác nhau trong một lúc.

**Cài tay**: với mỗi repo dự án chạy `scripts/init-project.sh <đường-dẫn-repo>` từ repo này (repo nên nằm cùng thư mục cha, nhưng ở đâu cũng được, miễn cùng ổ đĩa); rồi gõ `/mattpocock-skills:setup-matt-pocock-skills` và `/finolabs-vibecode:setup` trong từng repo.

**Một repo đơn lẻ, không workspace**: mở phiên trong repo đó và gõ `/astrolabe:setup`; nó nhận ra không có workspace và setup riêng repo đó.

## Dùng

Skill của plugin luôn gọi kèm tên plugin: `/<plugin>:<skill>`. Gõ `/astrolabe:` rồi Tab để Claude Code gợi ý tên.

- **Tính năng một repo**: mở phiên trong repo đó.
- **Tính năng nhiều repo**: mở phiên ở repo trung tâm. Phiên thấy được các repo đồng cấp khai báo trong `.claude/settings.json`. Việc gắn với một repo (restore-point, git, MR, merge) làm trong repo đó; lệnh chỉ người gõ được thì `/cd ../<repo>` trước.

```
/astrolabe:flow large mở lại kỳ đã khóa
```

Mỗi tính năng có một thư mục tính năng. Vị trí theo `docsBackend` trong `workspace.json` (hoặc `.claude/astrolabe.json` ở repo đơn lẻ):

- `local` (mặc định): file markdown trong git, ở `docs/features/<slug>/` của repo hoặc `features/<slug>/` của repo trung tâm, theo `featureDocs`. `GLOSSARY.md` và ADR (`docs/adr/`) nằm trong repo và đổi qua MR. Không cần dịch vụ ngoài.
- `orrery`: note trong [Orrery](#tuỳ-biến) ở `<space>:<repo>/features/<slug>/`; `GLOSSARY.md` và ADR ở `<repo>/`, đổi qua changeset. Phiên không có Orrery thì ghi local theo `featureDocs`, rồi đồng bộ lên ở phiên sau.

Luật duyệt luôn nằm trong git. Thư mục tính năng chứa:

- `flow.md`: biên lai quy trình;
- `why.md`: kết quả bước Why;
- `spec-check.md`: kết quả soát spec;
- `decisions.md`: sổ quyết định;
- `spec.md` và `issues/`: spec và ticket do `to-spec`, `to-tickets` ghi.

Xem [`docs/cheat-sheet.md`](docs/cheat-sheet.md). Không biết dùng skill nào thì gõ `/astrolabe:help <câu hỏi>`.

## Tuỳ biến

Mọi thứ riêng của một team nằm trong file cấu hình, không nằm trong skill hay script:

| Muốn đổi | Sửa ở |
|---|---|
| Thêm, bỏ hay thay bộ skill upstream; skill luồng cần kiểm | `upstream.json` (`upstream[]`: `marketplace`, `repo`, `plugin`, `skills`; `retired[]`, `retiredMarketplaces[]`: plugin và marketplace cũ cần gỡ) |
| Nơi lưu tài liệu tính năng | `docsBackend` (`local` hoặc `orrery`) và `featureDocs` (`auto`, `central`, `project`) trong `workspace.json` |
| Space Orrery (chỉ khi `docsBackend: orrery`) | `orrery.space` trong `workspace.json` |
| Repo trong workspace | `projects` trong `workspace.json`, hoặc chạy `scripts/init-project.sh` |
| Việc luôn cần người duyệt | `rules/common.md` (chung) và `docs/flow-rules.md` (từng repo) |

`.claude/settings.json` của repo trung tâm sinh theo từng máy nên nằm trong `.gitignore`. Team muốn commit danh sách repo đồng cấp thì bỏ dòng đó trong fork của mình.

Orrery là dịch vụ lưu note qua MCP; chỉ cần khi chọn `docsBackend: orrery`.

## Cập nhật

Các bộ upstream tự cập nhật khi upstream phát hành bản mới (tăng `version`). Sau một lần cập nhật, chạy lại `./scripts/setup-machine.sh` để kiểm skill luồng cần vẫn còn. Chi tiết trong [`UPSTREAM.md`](UPSTREAM.md).

## Còn treo

- Giấy phép vibebiz: làm rõ trước khi lấy thêm bất kỳ phần nào trực tiếp từ code gốc.
- Có gom `deslop` (plugin `cursor-team-kit`) hay không.
- Repo trên GitLab: `merge_check.py` và `post_review.py` của finolabs chỉ gọi `gh` (GitHub). Ở GitLab, cửa merge và việc đăng review lên MR không chạy được, cần thay thế hoặc bỏ.

## Đã kiểm

- `restore-point` chụp cả thay đổi chưa commit: nó lưu snapshot của working tree lên một ref local, không đụng index, nhánh hay HEAD.
- Mọi skill luồng này gọi tới đều có trong bản upstream: `scripts/setup-machine.sh` kiểm ở bước 5 mỗi lần chạy.

## Giấy phép

MIT, xem [`LICENSE`](LICENSE). Ba bộ upstream có giấy phép riêng, xem [`UPSTREAM.md`](UPSTREAM.md).
