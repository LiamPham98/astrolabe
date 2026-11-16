---
name: flow
description: Dẫn một tính năng qua luồng đã chốt (điều phối, có nên làm, hiểu yêu cầu, thiết kế, lặp từng MR, sau ra mắt). Dùng khi gõ /astrolabe:flow hoặc khi bắt đầu làm một tính năng mới.
---

# flow

Dẫn một tính năng qua luồng làm tính năng của team. Luồng có một xương sống cố định và các giai đoạn tuỳ chọn bật theo đặc điểm tính năng. Phần làm và kiểm lặp lại cho từng MR.

Cách gọi: `/astrolabe:flow <small|medium|large> <mô tả tính năng>`. Thiếu quy mô thì hỏi.

## Nguyên tắc

- **Bốn cửa dừng duyệt**: chốt có làm, duyệt spec, chốt thiết kế, duyệt và merge mỗi MR. Ở bốn cửa này, dừng và chờ người làm trả lời. Ngoài bốn cửa, trình kết quả rồi đi tiếp.
- **Tên lệnh có tiền tố plugin**: skill của plugin được gọi bằng `/<plugin>:<skill>`, ví dụ `/pstack:architect`. Mọi lệnh in ra cho người làm đều phải có tiền tố.
- **Ai chạy skill nào**:
  - Skill chỉ người gõ được (tắt model-invocation): mọi skill pstack luồng này dùng, `grill-with-docs`, `to-spec`, `to-tickets`, `setup-matt-pocock-skills` của Matt, `restore-point` và `setup` của finolabs. Với các skill này, in đúng câu lệnh để người làm gõ, kèm đường dẫn spec hoặc thiết kế cần dùng. Không giả lập skill đó bằng cách tự làm thay.
  - Skill agent tự chạy được: `coding-router`, `checks`, `review-gate`, `security-review-gate` của finolabs, cùng `astrolabe:why` và `spec-check` của plugin này. Agent tự load và chạy, không bắt người làm gõ.
- **Không merge thay người làm.** Không tắt cửa duyệt mà file luật bắt buộc.
- **Mọi lệnh sau giai đoạn 2 đều kèm đường dẫn spec** (file hoặc link issue).
- Không dùng `/mattpocock-skills:implement` của Matt hay `none.md implement`. "Không adopt path Matt" chỉ có nghĩa là không dùng chuỗi implement của Matt; vẫn dùng `/mattpocock-skills:grill-with-docs` và `/mattpocock-skills:to-spec`.

## Workspace

Luồng chạy được theo hai kiểu:

- **Đơn lẻ**: một repo, không có workspace.
- **Workspace**: một repo trung tâm (có `workspace.json` ở gốc; là bản clone astrolabe hoặc repo bất kỳ của team) cùng các repo đồng cấp nằm chung thư mục cha.

Tìm workspace khi bắt đầu:

1. Gốc repo đang mở có `workspace.json`: phiên đang ở **repo trung tâm**. Các repo đồng cấp là danh sách `projects`, đường dẫn tính từ repo trung tâm.
2. Gốc repo đang mở có `.claude/astrolabe.json`: phiên đang ở **repo đồng cấp**. Repo trung tâm là `workspace` trong file đó, tính từ repo đang mở. Repo chỉ có `.claude/feature-workflow.json` (tên cũ trước bản đổi tên) thì đọc file đó và đề nghị chạy `/astrolabe:setup` để đổi tên.
3. Không có cả hai: đơn lẻ.

Ở kiểu workspace, đọc `workspace.json` để biết `docsBackend`, `featureDocs` và danh sách repo.

## Nơi lưu tài liệu

`<slug>` là tên tính năng viết thường, không dấu, nối bằng gạch ngang. Luật duyệt (`rules/common.md`, `docs/flow-rules.md`) luôn nằm trong git để sửa qua MR. Các tài liệu còn lại lưu theo `docsBackend`, đọc trong `workspace.json` (kiểu workspace) hoặc `.claude/astrolabe.json` (kiểu đơn lẻ):

| `docsBackend` | Tài liệu tính năng | `GLOSSARY.md`, ADR |
|---|---|---|
| `local` (mặc định, cả khi thiếu khoá) | file trong git, ở thư mục theo mục "Thư mục local" | `GLOSSARY.md` và `docs/adr/` trong repo, đổi qua MR |
| `orrery` | note trong Orrery, theo mục "Orrery" | note trong Orrery, đổi qua changeset |

Giá trị khác hai giá trị trên thì nói một câu và dùng `local`.

Thư mục tính năng chứa cùng các file ở mọi backend:

| File | Ai ghi | Nội dung |
|---|---|---|
| `flow.md` | astrolabe:flow | Biên lai: preset, công tắc, lý do, các cửa đã qua |
| `why.md` | skill `astrolabe:why` | Kết quả bước Why |
| `spec.md`, `issues/` | `/mattpocock-skills:to-spec`, `/mattpocock-skills:to-tickets` | Spec và ticket, ghi theo `docs/agents/issue-tracker.md` của repo |
| `spec-check.md` | skill `spec-check` | Kết quả soát spec |
| `decisions.md` | mọi bước | Sổ quyết định, chỉ ghi thêm |

Mỗi file có frontmatter `type` (`flow`, `why`, `spec`, `ticket`, `spec-check`, `decisions`, `adr`, `glossary`), `repo`, `feature` (trừ `GLOSSARY.md` và ADR) và `status` khi có. `GLOSSARY.md` và ADR dùng chung cho mọi tính năng của repo; `/mattpocock-skills:grill-with-docs` và cửa chốt thiết kế ghi chúng.

Mẫu của `flow.md` và `decisions.md` nằm trong thư mục `templates/` cạnh file SKILL.md này. Mẫu `why.md` nằm cạnh skill `astrolabe:why`.

### Thư mục local

Dùng khi `docsBackend` là `local`, và làm nơi dự phòng khi `docsBackend` là `orrery` mà phiên không kết nối Orrery.

| Kiểu | `featureDocs` | Tính năng một repo | Tính năng nhiều repo (`repo` bật) |
|---|---|---|---|
| Đơn lẻ | — | `docs/features/<slug>/` | — |
| Workspace | `auto` (mặc định) | `docs/features/<slug>/` của repo đó | `features/<slug>/` của repo trung tâm |
| Workspace | `central` | `features/<slug>/` của repo trung tâm | `features/<slug>/` của repo trung tâm |
| Workspace | `project` | `docs/features/<slug>/` của repo đó | `docs/features/<slug>/` của repo chính của tính năng (hỏi repo nào) |

Với `docsBackend: local`:

- Ghi thêm vào `decisions.md` bằng cách nối vào cuối file; không sửa mục đã có.
- Spec và ticket nằm ở nơi `docs/agents/issue-tracker.md` của repo quy định (cấu hình "Local markdown" của `/mattpocock-skills:setup-matt-pocock-skills`). Ghi đường dẫn của chúng vào `flow.md`.
- File tính năng là file trong git: commit cùng MR đầu tiên của tính năng, rồi cập nhật trong các MR sau. Mô tả mỗi MR dán đường dẫn `flow.md` và `spec.md`.
- ADR ghi vào `docs/adr/` của repo, đánh số tăng dần; `GLOSSARY.md` nằm ở gốc repo.

### Orrery

Chỉ áp khi `docsBackend` là `orrery`. Tài liệu đọc, ghi qua công cụ MCP của Orrery.

**Space**: `orrery.space` cùng file với `docsBackend`. Thiếu thì dùng `personal`.

**Bố cục**: folder theo repo trước, theo tính năng sau. `<repo>` là tên repo của tính năng một repo, hoặc tên repo trung tâm của tính năng nhiều repo.

```
<repo>/
├─ GLOSSARY.md                     thuật ngữ của repo (repo nhiều context: GLOSSARY-MAP.md + contexts/<context>/GLOSSARY.md)
├─ adr/0001-<slug>.md              ADR, đánh số tăng dần
└─ features/<slug>/                thư mục tính năng
   ├─ flow.md  why.md  spec.md  spec-check.md  decisions.md
   └─ issues/01-<slug>.md
```

**Cách ghi**:

- Server tự gán `id` cho note.
- Tạo note từ mẫu bằng `note_create`. Ghi thêm vào `decisions.md` bằng `note_edit` với `op: append`. Sửa note bằng `note_edit` hoặc `note_update`, luôn với `base_revision` vừa đọc; gặp `conflict` thì đọc lại, gộp, rồi ghi lại.
- Note trỏ nhau bằng wikilink, ví dụ mục `design` trong `decisions.md` trỏ `[[<repo>/adr/0003-<slug>]]`.
- `GLOSSARY.md` và ADR là note dùng chung cho cả repo: đổi chúng bằng `changeset_submit` (`op: note.create` hoặc `note.update`), để một người khác tác giả duyệt trong client của họ. Agent không bao giờ tự duyệt changeset. Ghi id changeset vào `flow.md`; trước khi changeset được duyệt, note chưa có trong Orrery, nên bước sau đọc nội dung từ changeset (`changeset_read`). Người làm nói space không có người duyệt thứ hai thì ghi thẳng và ghi `review-risk` vào `decisions.md`.
- Ghi vào `flow.md` revision của từng note lúc đọc để làm bằng chứng cho cửa duyệt. Mô tả mỗi MR dán link note `spec.md` kèm revision, vì reviewer trong CI không đọc được Orrery.

**Chép từ repo lên Orrery**: skill của Matt (`domain-modeling`, qua `grill-with-docs`) luôn ghi `GLOSSARY.md` và `docs/adr/` vào repo. Sau mỗi lần chạy grill, so các file đó với note trong `<repo>/`: file mới hoặc đã đổi thì đưa lên Orrery như trên, rồi hỏi người làm có xoá bản trong repo không.

**Khi phiên không kết nối Orrery** (không có công cụ `note_create`, hoặc `whoami` lỗi): nói một câu, rồi ghi vào thư mục local ở mục trên, và ghi `orrery: chưa đồng bộ` ở đầu `flow.md`. Spec và ticket khi đó ghi cạnh `flow.md`. Lần sau phiên có Orrery:

1. Với mỗi file local, đọc note cùng tên trong Orrery.
2. Note chưa có: tạo từ file local. Note đã có và khác file local: không ghi đè; trình hai bản và hỏi người làm giữ bản nào. Với `decisions.md`, chỉ append các mục `D-###` mà Orrery chưa có.
3. Xong thì xoá dòng `orrery: chưa đồng bộ` trong note `flow.md`, và hỏi người làm có xoá các file local không.

## Giai đoạn 0: Điều phối

1. **coding-router**: nếu chưa có biên lai của coding-router cho tính năng này, load `coding-router` để inspect, chọn path và độ sâu. Path luôn là luồng này.
2. **File luật**: luật áp cho tính năng là hợp của:
   - ở kiểu workspace: `rules/common.md` của repo trung tâm;
   - `docs/flow-rules.md` của **mỗi repo tính năng chạm tới**.

   Luật riêng chỉ thêm việc hoặc siết cửa, không bỏ được việc của luật chung; hai file ghi khác nhau về cùng một việc thì lấy cửa chặt hơn. Thiếu file nào thì nói một câu và đề nghị chạy `/astrolabe:setup`; tiếp tục với phần đang có.
3. **Preset và công tắc**: bắt đầu từ preset, rồi chỉnh từng công tắc theo tính năng thật.

   | Công tắc | Bật khi | Bật giai đoạn hoặc bước | S | M | L |
   |---|---|---|---|---|---|
   | `why` | tính năng mới tốn công, cần sếp hoặc nghiệp vụ duyệt, có AI, chạm dữ liệu nhạy cảm | giai đoạn 1 và 5 | | | ✓ |
   | `unclear` | yêu cầu còn mơ hồ, luật nghiệp vụ hoặc thuật ngữ mới | `/mattpocock-skills:grill-with-docs` | | ✓ | ✓ |
   | `multi` | làm qua nhiều phiên, nhiều người hoặc nhiều MR | `/mattpocock-skills:to-spec`, `spec-check` | | | ✓ |
   | `cross` | code vượt biên hàm, chạm nhiều module hoặc hợp đồng | `/pstack:architect` | | ✓ | ✓ |
   | `contest` | thiết kế có tranh cãi hoặc khó đảo ngược (schema, migration) | `/pstack:interrogate` | | | ✓ |
   | `state` | có máy trạng thái | `/pstack:statechart` | | | ✓ |
   | `sec` | đụng tiền, quyền, dữ liệu cá nhân | `/finolabs-vibecode:security-review-gate` | | | |
   | `repo` | chạm nhiều repo | restore-point mỗi repo, thứ tự merge | | | ✓ |

   Hỏi những công tắc chưa rõ từ mô tả, tối đa 4 câu trong một lần hỏi. Đọc code liên quan nếu cần để trả lời thay vì hỏi.
4. **Khóa theo file luật**: nếu tính năng chạm một việc trong file luật, cửa duyệt mà việc đó yêu cầu không được tắt, và bật `sec` nếu việc đó đánh dấu cần security review. Cửa chỉ chạy khi giai đoạn chứa nó chạy, nên bật công tắc của cửa đó, kể cả khi preset tắt:

   | Cửa bắt buộc | Bật công tắc |
   |---|---|
   | chốt có làm | `why` |
   | duyệt spec | `multi` |
   | chốt thiết kế | `cross` |

   Ghi rõ việc nào trong file luật bị chạm và công tắc nào bị khóa bật.
5. **Thư mục tính năng và biên lai**: chọn thư mục tính năng theo bảng ở trên, rồi ghi `flow.md` từ mẫu: preset, từng công tắc bật hay tắt kèm một dòng lý do, các repo liên quan, việc bị khóa theo file luật (ghi rõ việc đó đến từ luật chung hay luật riêng của repo nào), đường dẫn thư mục tính năng.
6. **Kế hoạch**: trình chuỗi lệnh sẽ gõ theo các công tắc đã bật. Chờ người làm đồng ý (xác nhận nhanh, không phải cửa).

Preset small bỏ giai đoạn 1, 2, 3: đi thẳng tới restore-point rồi giai đoạn 4, để `poteto-mode` chạy playbook đầy đủ. Playbook tự gọi `how` và `architect` khi code vượt biên hàm.

## Giai đoạn 1: Có nên làm không (khi bật `why`)

1. Load skill `astrolabe:why`. Nó phỏng vấn, phản biện và ghi `why.md`.
2. **Cửa: chốt có làm.** Trình tóm tắt `why.md` và hỏi làm hay không.
3. Chọn không làm, hoặc phương án được chọn là sửa quy trình hay không làm gì: ghi quyết định vào `decisions.md`, cập nhật `flow.md`, dừng luồng.
4. Áp các gợi ý công tắc trong `why.md` vào `flow.md` nếu người làm đồng ý.

## Giai đoạn 2: Hiểu yêu cầu (khi bật `unclear` hoặc `multi`)

1. Khi bật `unclear`: in lệnh `/mattpocock-skills:grill-with-docs` cho người làm gõ. Nếu có `why.md`, nhắc rằng grill chỉ hỏi phần `why.md` chưa chốt và đưa đường dẫn `why.md`.
2. Khi bật `multi`: in lệnh `/mattpocock-skills:to-spec`. Ghi đường dẫn spec vào `flow.md`. Thêm `/mattpocock-skills:to-tickets` nếu người làm muốn tách ticket.
3. Khi bật `unclear` mà không bật `multi`: sau grill, ghi các quyết định đã chốt vào `decisions.md` thay cho spec.
4. Khi bật `multi` (đã có spec): load skill `spec-check` trên spec vừa ghi. Kết quả có phát hiện mức nghiêm trọng hoặc cao thì quay lại grill hoặc to-spec với đúng các câu hỏi `spec-check` nêu.
5. **Cửa: duyệt spec.** Có spec thì trình spec cùng kết quả `spec-check`. Không có spec (chỉ bật `unclear`) thì trình các quyết định vừa ghi vào `decisions.md`.

## Giai đoạn 3: Thiết kế (khi bật `cross`, `contest` hoặc `state`)

Không chạy `/pstack:how` riêng: Phase A (Ground) của `architect` đã chạy `how`.

1. Khi bật `cross` hoặc `contest`, in lệnh:
   `/pstack:architect with checkpoint. stop and show me before implementing. Spec: <đường dẫn spec>`
   Mở đầu checkpoint bằng một đoạn nhắc lại mục tiêu tính năng bằng lời của agent, để người làm sửa nếu hiểu sai.
2. Khi bật `contest`: in lệnh `/pstack:interrogate` trên thiết kế vừa ra. Chỉ giữ finding chạy lại được.
3. Khi bật `state`: in lệnh `/pstack:statechart` trên thiết kế, **trước khi viết code**. Đường lỗi TLC tìm ra thì sửa thiết kế ngay ở giai đoạn này.
4. **Cửa: chốt thiết kế.** Gộp checkpoint của architect, finding của interrogate và kết quả statechart thành một lần duyệt. Ghi quyết định thiết kế vào `decisions.md`.
5. **ADR**: với mỗi quyết định thiết kế khó đảo ngược, sẽ gây thắc mắc nếu không có lý do ghi lại, và là kết quả của một lựa chọn thật giữa các phương án, ghi một ADR theo `ADR-FORMAT.md` của skill `domain-modeling` (plugin `mattpocock-skills`), ở nơi lưu ADR theo `docsBackend` (mục "Nơi lưu tài liệu"): `docs/adr/` của repo với `local`, `<repo>/adr/` trong Orrery bằng `changeset_submit` với `orrery`. Lấy số tiếp theo sau số lớn nhất đã có. Tính năng nhiều repo ghi ADR vào repo cung cấp hợp đồng. Mục `design` trong `decisions.md` trỏ tới ADR (đường dẫn file với `local`, wikilink với `orrery`).

## Trước khi code

In lệnh `/finolabs-vibecode:restore-point create` cho người làm gõ. Lệnh chạy trên repo đang mở của phiên. Khi bật `repo`, hoặc khi phiên đang ở repo trung tâm mà code nằm ở repo đồng cấp, in theo từng repo:

```
/cd ../<repo>
/finolabs-vibecode:restore-point create
```

Xong thì nhắc `/cd` về lại repo trung tâm nếu luồng đang chạy từ đó.

## Giai đoạn 4: Lặp cho từng MR

Chia việc thành các đơn vị kiểm được; mỗi đơn vị một MR. Với mỗi đơn vị, đi hết các bước dưới rồi mới sang đơn vị tiếp theo.

1. In lệnh poteto-mode:
   - đã qua giai đoạn 3: `/pstack:poteto-mode <mục tiêu>. Cách kiểm: <…>. Một MR mỗi đơn vị kiểm được. Dùng thiết kế đã chốt, bắt đầu từ throughput checkpoint. Spec: <đường dẫn>`
   - không qua giai đoạn 3: `/pstack:poteto-mode <mục tiêu>. Cách kiểm: <…>. Một MR mỗi đơn vị kiểm được.`
2. `/pstack:blast-radius` trên MR. Khi bật `state`: phát lại đường lỗi của statechart trên code thật.
3. Agent tự chạy skill `checks` của finolabs: đọc output thật, gán PASS, FAIL hoặc PENDING có biên lai.
4. Agent tự chạy skill `review-gate` của finolabs. Khi bật `sec`: chạy thêm `security-review-gate`.
   - Tối đa 2 vòng sửa. Hết 2 vòng mà vẫn REWORK: dừng và hỏi người làm chọn quay lại giai đoạn 3, hoặc chấp nhận rủi ro. Chấp nhận thì ghi `review-risk` vào `decisions.md` kèm lý do.
5. `merge_check.py` do `review-gate` chạy, theo cửa của repo. Script này gọi `gh`, nên **chỉ chạy với pull request trên GitHub**. Repo trên GitLab, hoặc repo chưa adopt cửa, thì nói rõ là MR này không có cửa cứng.
6. **Cửa: duyệt và merge.** Trình gói: kết quả checks, review-gate, blast-radius và rủi ro đã chấp nhận. Người làm tự merge. Khi bật `repo`, merge repo cung cấp hợp đồng trước, repo dùng hợp đồng sau.
7. Cập nhật `flow.md` (MR nào đã merge), sang đơn vị tiếp theo.

Trong mô tả mỗi MR, dán tóm tắt biên lai: preset, công tắc đã bật, đường dẫn `flow.md`.

## Giai đoạn 5: Sau ra mắt (khi bật `why`)

1. Lấy ngày đọc chỉ số từ `why.md` (thời hạn của mục tiêu, hoặc mốc kiểm của ngưỡng dừng). Nhắc người làm đặt lịch nhắc nếu cần.
2. Đến hạn: đọc chỉ số, so với mục tiêu, chỉ số không được xấu đi và ngưỡng dừng.
3. Ghi `launch-review` vào `decisions.md`: giữ, chỉnh hay gỡ tính năng, kèm số liệu và nguồn.

## Hoàn thành khi

- Mọi MR của tính năng đã merge hoặc được ghi lý do bỏ.
- `flow.md` ghi đủ các cửa đã qua.
- Khi bật `why`: đã có ngày đọc chỉ số sau ra mắt.
