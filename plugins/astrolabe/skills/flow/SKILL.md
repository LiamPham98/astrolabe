---
name: flow
description: Dẫn một tính năng qua luồng đã chốt (điều phối, có nên làm, hiểu yêu cầu, thiết kế, lặp từng MR, sau ra mắt). Dùng khi gõ /astrolabe:flow hoặc khi bắt đầu làm một tính năng mới.
---

# flow

Dẫn một tính năng qua luồng làm tính năng. Luồng có một xương sống cố định và các giai đoạn tuỳ chọn bật theo đặc điểm tính năng. Phần làm và kiểm lặp lại cho từng MR.

Cách gọi: `/astrolabe:flow <small|medium|large> <mô tả tính năng>`. Thiếu quy mô thì hỏi.

## Cấu hình

Plugin không đọc hay ghi file cấu hình nào trong repo dự án. Mọi cấu hình là `userConfig` của plugin, người dùng đặt khi bật plugin hoặc trong `/config`:

| Khoá | Giá trị trong phiên này | Khi chưa đặt |
|---|---|---|
| `workspace_root` | `${user_config.workspace_root}` | thư mục cha của repo đang mở |
| `docs_backend` | `${user_config.docs_backend}` | `local` |
| `orrery_space` | `${user_config.orrery_space}` | `personal` |

Thư mục dữ liệu của plugin trên máy này: `${CLAUDE_PLUGIN_DATA}`.

Ô nào trống, hoặc còn nguyên dạng `${...}`, là chưa đặt: dùng cột "Khi chưa đặt". `docs_backend` khác `local` và `orrery` thì nói một câu và dùng `local`.

## Nguyên tắc

- **Bốn cửa dừng duyệt**: chốt có làm, duyệt spec, chốt thiết kế, duyệt và merge mỗi MR. Ở bốn cửa này, dừng và chờ người làm trả lời. Ngoài bốn cửa, trình kết quả rồi đi tiếp.
- **Không ghi gì vào repo dự án ngoài code của tính năng.** Tài liệu tính năng và luật duyệt nằm ở nơi lưu (mục "Nơi lưu tài liệu"), không nằm trong repo.
- **Bộ đồng hành là tuỳ chọn.** finolabs-vibecode, pstack và skill của Matt Pocock làm một số bước tốt hơn, nhưng luồng chạy đủ khi không có bộ nào. Một bộ có mặt khi danh sách skill của phiên có skill mang tiền tố của nó (`finolabs-vibecode:`, `pstack:`, `mattpocock-skills:`). Mỗi bước dùng bộ đồng hành nếu có, không thì làm theo cách mặc định trong mục "Bước và công cụ".
- **Ai chạy skill nào**:
  - Skill chỉ người gõ được (tắt model-invocation): mọi skill pstack luồng này dùng, `grill-with-docs`, `to-spec`, `to-tickets` của Matt, `restore-point` của finolabs. In đúng câu lệnh có tiền tố plugin để người làm gõ, kèm đường dẫn spec, thiết kế và nơi ghi kết quả. Không giả lập skill đó bằng cách tự làm thay; bộ không có mặt thì dùng cách mặc định.
  - Skill agent tự chạy được: `coding-router`, `checks`, `review-gate`, `security-review-gate` của finolabs; `code-review`, `security-review` có sẵn của Claude Code; `astrolabe:why` và `astrolabe:spec-check`.
- **Không merge thay người làm.** Không tắt cửa duyệt mà luật bắt buộc.
- **Mọi lệnh sau giai đoạn 2 đều kèm đường dẫn spec.**
- Không dùng `/mattpocock-skills:implement` hay `none.md implement` của finolabs.

## Workspace

Repo đang mở là gốc git của thư mục phiên (`git rev-parse --show-toplevel`). Workspace là thư mục `workspace_root`; mọi thư mục con trực tiếp có `.git` là một repo của workspace. Không có danh sách repo nào phải khai.

Tính năng có thể chạm nhiều repo. Ở giai đoạn 0, hỏi tính năng chạm repo nào trong số repo tìm thấy (chọn nhiều, đề xuất repo đang mở). Phiên mở ở chính thư mục workspace (không phải một repo) thì luôn hỏi.

Đọc, sửa repo khác repo đang mở bằng đường dẫn tuyệt đối. Công cụ bị chặn vì thư mục nằm ngoài phiên thì nhắc người làm gõ `/add-dir <đường dẫn repo>`.

## Nơi lưu tài liệu

`<slug>` là tên tính năng viết thường, không dấu, nối bằng gạch ngang. `<repo>` là tên thư mục của repo. Tính năng chạm nhiều repo lưu dưới `_workspace` thay cho `<repo>`.

Bố cục giống nhau ở mọi nơi lưu:

```
_workspace/
├─ rules.md                       luật duyệt chung
└─ features/<slug>/               tính năng nhiều repo
<repo>/
├─ rules.md                       luật duyệt riêng của repo
├─ GLOSSARY.md                    thuật ngữ (repo nhiều context: GLOSSARY-MAP.md + contexts/<context>/GLOSSARY.md)
├─ adr/0001-<slug>.md             ADR, đánh số tăng dần
└─ features/<slug>/               thư mục tính năng
   ├─ flow.md  why.md  spec.md  spec-check.md  decisions.md
   └─ issues/01-<slug>.md
```

| `docs_backend` | Bố cục trên nằm ở |
|---|---|
| `orrery` | note trong Orrery, space `orrery_space`, đọc ghi qua công cụ MCP của Orrery |
| `local` | thư mục `${CLAUDE_PLUGIN_DATA}` trên máy này |

| File | Ai ghi | Nội dung |
|---|---|---|
| `flow.md` | astrolabe:flow | Biên lai: cấu hình đã dùng, bộ đồng hành có mặt, preset, công tắc, lý do, các cửa đã qua |
| `why.md` | `astrolabe:why` | Kết quả bước Why |
| `spec.md`, `issues/` | `to-spec`, `to-tickets` của Matt; không có thì agent | Spec và ticket |
| `spec-check.md` | `astrolabe:spec-check` | Kết quả soát spec |
| `decisions.md` | mọi bước | Sổ quyết định, chỉ ghi thêm |
| `GLOSSARY.md`, `adr/` | bước hỏi làm rõ, cửa chốt thiết kế | Thuật ngữ và ADR của repo, dùng chung cho mọi tính năng |

Mỗi file có frontmatter `type` (`flow`, `why`, `spec`, `ticket`, `spec-check`, `decisions`, `adr`, `glossary`, `rules`), `repo`, `feature` (trừ `GLOSSARY.md`, ADR và luật) và `status` khi có. Ticket có dòng `Status:` gần đầu; nhãn triage: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`.

Mẫu `flow.md`, `decisions.md` và hai mẫu luật nằm trong `templates/` cạnh file SKILL.md này. Mẫu `why.md` nằm cạnh skill `astrolabe:why`.

### Luật duyệt

Luật áp cho tính năng là hợp của `_workspace/rules.md` và `<repo>/rules.md` của **mỗi repo tính năng chạm tới**. Luật riêng chỉ thêm việc hoặc siết cửa, không bỏ được việc của luật chung; hai nơi ghi khác nhau về cùng một việc thì lấy cửa chặt hơn.

Note hay file luật chưa có: dùng nội dung mẫu `templates/rules-common.md` (chung) và `templates/rules-repo.md` (riêng), nói một câu rằng đang dùng luật mẫu và gợi ý `/astrolabe:setup` để tạo luật thật. Không tự sửa luật; người làm yêu cầu sửa thì sửa và ghi `rules-change` vào `decisions.md`.

### Ghi vào Orrery

- Tạo note từ mẫu bằng `note_create`. Ghi thêm vào `decisions.md` bằng `note_edit` với `op: append`. Sửa note bằng `note_edit` hoặc `note_update`, luôn với `base_revision` vừa đọc; gặp `conflict` thì đọc lại, gộp, rồi ghi lại.
- Note trỏ nhau bằng wikilink, ví dụ mục `design` trong `decisions.md` trỏ `[[<repo>/adr/0003-<slug>]]`.
- `GLOSSARY.md`, ADR và luật là note dùng chung: đổi bằng `changeset_submit` (`op: note.create` hoặc `note.update`) để người khác tác giả duyệt. Agent không bao giờ tự duyệt changeset. Ghi id changeset vào `flow.md`; trước khi được duyệt, đọc nội dung từ `changeset_read`. Người làm nói space không có người duyệt thứ hai thì ghi thẳng và ghi `review-risk` vào `decisions.md`.
- Ghi vào `flow.md` revision của từng note lúc đọc làm bằng chứng cho cửa duyệt. Mô tả mỗi MR dán link note `spec.md` kèm revision.

**Khi phiên không kết nối Orrery** (không có công cụ `note_create`, hoặc `whoami` lỗi): nói một câu, ghi theo cùng bố cục vào `${CLAUDE_PLUGIN_DATA}`, và ghi `orrery: chưa đồng bộ` ở đầu `flow.md`. Lần sau phiên có Orrery:

1. Với mỗi file trong `${CLAUDE_PLUGIN_DATA}` có dòng đó ở `flow.md` của thư mục tính năng, đọc note cùng tên trong Orrery.
2. Note chưa có: tạo từ file. Note đã có và khác file: không ghi đè; trình hai bản và hỏi người làm giữ bản nào. Với `decisions.md`, chỉ append các mục `D-###` mà Orrery chưa có.
3. Xong thì xoá dòng `orrery: chưa đồng bộ` trong note `flow.md`, và hỏi người làm có xoá các file local không.

### Ghi local

- Ghi thêm vào `decisions.md` bằng cách nối vào cuối file; không sửa mục đã có.
- File nằm trên máy, reviewer của MR không đọc được: mô tả mỗi MR dán tóm tắt biên lai và phần spec liên quan.

### Từ repo về nơi lưu

`domain-modeling` của Matt (qua `grill-with-docs`) ghi `GLOSSARY.md` và `docs/adr/` vào repo. Sau mỗi lần chạy, so các file đó với `<repo>/GLOSSARY.md` và `<repo>/adr/` ở nơi lưu: file mới hoặc đã đổi thì đưa về nơi lưu (Orrery: qua changeset như trên), rồi hỏi người làm có xoá bản trong repo không.

## Bước và công cụ

| Bước | Mặc định (luôn có) | Có bộ đồng hành thì dùng |
|---|---|---|
| Chọn path và độ sâu | agent tự chọn theo preset | `coding-router` của finolabs (agent load) |
| Hỏi làm rõ (`unclear`) | agent phỏng vấn theo vòng bằng công cụ hỏi của phiên, mỗi câu có phương án đề xuất; chốt thuật ngữ vào `GLOSSARY.md` | `/mattpocock-skills:grill-with-docs` |
| Spec (`multi`) | agent viết `spec.md` (mục tiêu, phạm vi, ngoài phạm vi, luật nghiệp vụ, tiêu chí nghiệm thu đo được) và `issues/` nếu người làm muốn tách ticket | `/mattpocock-skills:to-spec`, `/mattpocock-skills:to-tickets` |
| Thiết kế (`cross`) | agent đọc code liên quan, viết thiết kế (module chạm tới, hợp đồng, dữ liệu, phương án đã loại) rồi dừng ở cửa; gợi ý người làm bật plan mode (Shift+Tab) nếu muốn duyệt kế hoạch trước khi agent đọc sâu | `/pstack:architect` |
| Phản biện (`contest`) | agent tự phản biện thiết kế: liệt kê cách nó hỏng, mỗi cách một cách kiểm chạy lại được | `/pstack:interrogate` |
| Máy trạng thái (`state`) | agent lập bảng trạng thái × sự kiện, liệt kê chuyển trạng thái thiếu và đường lỗi | `/pstack:statechart` (cần `mise`) |
| Điểm khôi phục | working tree sạch và một nhánh riêng cho tính năng trong mỗi repo chạm tới | `/finolabs-vibecode:restore-point create` |
| Code | agent code từng đơn vị kiểm được, mỗi đơn vị một MR | `/pstack:poteto-mode` |
| Phạm vi ảnh hưởng | agent tìm mọi nơi gọi tới code đã đổi và ghi rủi ro | `/pstack:blast-radius` |
| Kiểm | chạy test, lint, type check của repo; đọc output thật, gán PASS, FAIL hoặc PENDING có biên lai | `checks` của finolabs (agent load) |
| Review | skill `code-review` có sẵn của Claude Code; không gọi được thì in `/code-review` cho người làm | `review-gate` của finolabs (agent load) |
| Security (`sec`) | skill `security-review` có sẵn của Claude Code; không gọi được thì in `/security-review` | `security-review-gate` của finolabs |
| Cửa merge | người làm tự đối chiếu gói kiểm và review rồi merge | `merge_check.py` của `review-gate` (chỉ pull request GitHub, vì gọi `gh`) |

Lệnh của bộ đồng hành chạy trên repo đang mở của phiên. Với repo khác, in `/cd <đường dẫn repo>` trước lệnh, và nhắc `/cd` về lại sau.

Khi in lệnh `to-spec`, `to-tickets` hay `grill-with-docs`, ghi kèm nơi lưu để skill của Matt không cần cấu hình riêng trong repo, ví dụ: `/mattpocock-skills:to-spec Ghi spec vào <nơi lưu>:<repo>/features/<slug>/spec.md, ticket vào issues/NN-<slug>.md cùng thư mục.`

## Giai đoạn 0: Điều phối

1. **Cấu hình và bộ đồng hành**: đọc bảng "Cấu hình"; ghi bộ đồng hành nào có mặt. Với `orrery`, gọi `whoami` để biết phiên có Orrery không.
2. **Chọn path**: có finolabs và chưa có biên lai của `coding-router` cho tính năng này thì load `coding-router`. Path luôn là luồng này.
3. **Repo chạm tới**: theo mục "Workspace". Chạm hơn một repo thì bật `repo`.
4. **Luật**: đọc theo mục "Luật duyệt".
5. **Preset và công tắc**: bắt đầu từ preset, rồi chỉnh từng công tắc theo tính năng thật.

   | Công tắc | Bật khi | Bật bước | S | M | L |
   |---|---|---|---|---|---|
   | `why` | tính năng mới tốn công, cần sếp hoặc nghiệp vụ duyệt, có AI, chạm dữ liệu nhạy cảm | giai đoạn 1 và 5 | | | ✓ |
   | `unclear` | yêu cầu còn mơ hồ, luật nghiệp vụ hoặc thuật ngữ mới | hỏi làm rõ | | ✓ | ✓ |
   | `multi` | làm qua nhiều phiên, nhiều người hoặc nhiều MR | spec, `spec-check` | | | ✓ |
   | `cross` | code vượt biên hàm, chạm nhiều module hoặc hợp đồng | thiết kế | | ✓ | ✓ |
   | `contest` | thiết kế có tranh cãi hoặc khó đảo ngược (schema, migration) | phản biện | | | ✓ |
   | `state` | có máy trạng thái | máy trạng thái | | | ✓ |
   | `sec` | đụng tiền, quyền, dữ liệu cá nhân | security | | | |
   | `repo` | chạm nhiều repo | điểm khôi phục mỗi repo, thứ tự merge | | | ✓ |

   Hỏi những công tắc chưa rõ từ mô tả, tối đa 4 câu trong một lần hỏi. Đọc code liên quan nếu cần để trả lời thay vì hỏi.
6. **Khóa theo luật**: tính năng chạm một việc trong luật thì cửa duyệt việc đó yêu cầu không được tắt, và bật `sec` nếu việc đó cần security review. Cửa chỉ chạy khi giai đoạn chứa nó chạy, nên bật công tắc của cửa đó, kể cả khi preset tắt:

   | Cửa bắt buộc | Bật công tắc |
   |---|---|
   | chốt có làm | `why` |
   | duyệt spec | `multi` |
   | chốt thiết kế | `cross` |

   Ghi rõ việc nào bị chạm, đến từ luật chung hay luật riêng của repo nào, và công tắc nào bị khóa bật.
7. **Thư mục tính năng và biên lai**: ghi `flow.md` từ mẫu vào `<repo>/features/<slug>/` (hoặc `_workspace/features/<slug>/`) ở nơi lưu.
8. **Kế hoạch**: trình chuỗi bước sẽ chạy theo công tắc đã bật, ghi rõ bước nào dùng bộ đồng hành, bước nào dùng mặc định. Chờ người làm đồng ý (xác nhận nhanh, không phải cửa).

Preset small bỏ giai đoạn 1, 2, 3: đi thẳng tới điểm khôi phục rồi giai đoạn 4.

## Giai đoạn 1: Có nên làm không (khi bật `why`)

1. Load skill `astrolabe:why`. Nó phỏng vấn, phản biện và ghi `why.md`.
2. **Cửa: chốt có làm.** Trình tóm tắt `why.md` và hỏi làm hay không.
3. Chọn không làm, hoặc phương án được chọn là sửa quy trình hay không làm gì: ghi quyết định vào `decisions.md`, cập nhật `flow.md`, dừng luồng.
4. Áp các gợi ý công tắc trong `why.md` vào `flow.md` nếu người làm đồng ý.

## Giai đoạn 2: Hiểu yêu cầu (khi bật `unclear` hoặc `multi`)

1. Khi bật `unclear`: chạy bước hỏi làm rõ. Có `why.md` thì chỉ hỏi phần `why.md` chưa chốt.
2. Khi bật `multi`: chạy bước spec. Ghi đường dẫn spec vào `flow.md`.
3. Khi bật `unclear` mà không bật `multi`: ghi các quyết định đã chốt vào `decisions.md` thay cho spec.
4. Khi đã có spec: load `astrolabe:spec-check`. Có phát hiện mức nghiêm trọng hoặc cao thì quay lại hỏi làm rõ hoặc spec với đúng các câu hỏi `spec-check` nêu.
5. **Cửa: duyệt spec.** Có spec thì trình spec cùng kết quả `spec-check`. Không có spec thì trình các quyết định vừa ghi.

## Giai đoạn 3: Thiết kế (khi bật `cross`, `contest` hoặc `state`)

1. Khi bật `cross` hoặc `contest`: chạy bước thiết kế. Với pstack, in `/pstack:architect with checkpoint. stop and show me before implementing. Spec: <đường dẫn spec>`. Mở đầu checkpoint bằng một đoạn nhắc lại mục tiêu tính năng bằng lời của agent, để người làm sửa nếu hiểu sai.
2. Khi bật `contest`: chạy bước phản biện trên thiết kế vừa ra. Chỉ giữ finding kiểm lại được.
3. Khi bật `state`: chạy bước máy trạng thái **trước khi viết code**. Đường lỗi tìm ra thì sửa thiết kế ngay ở giai đoạn này.
4. **Cửa: chốt thiết kế.** Gộp thiết kế, phản biện và kết quả máy trạng thái thành một lần duyệt. Ghi quyết định thiết kế vào `decisions.md`.
5. **ADR**: với mỗi quyết định khó đảo ngược, sẽ gây thắc mắc nếu không ghi lý do, và là lựa chọn thật giữa các phương án, ghi một ADR vào `<repo>/adr/` ở nơi lưu (bối cảnh, quyết định, phương án đã loại, hệ quả; có Matt thì theo `ADR-FORMAT.md` của `domain-modeling`). Lấy số tiếp theo sau số lớn nhất đã có. Tính năng nhiều repo ghi ADR vào repo cung cấp hợp đồng. Mục `design` trong `decisions.md` trỏ tới ADR.

## Trước khi code

Chạy bước điểm khôi phục cho repo đang mở, hoặc cho từng repo khi bật `repo`.

## Giai đoạn 4: Lặp cho từng MR

Chia việc thành các đơn vị kiểm được; mỗi đơn vị một MR. Với mỗi đơn vị, đi hết các bước dưới rồi mới sang đơn vị tiếp theo.

1. **Code**. Với pstack: đã qua giai đoạn 3 thì `/pstack:poteto-mode <mục tiêu>. Cách kiểm: <…>. Một MR mỗi đơn vị kiểm được. Dùng thiết kế đã chốt, bắt đầu từ throughput checkpoint. Spec: <đường dẫn>`; không qua giai đoạn 3 thì bỏ hai câu cuối.
2. **Phạm vi ảnh hưởng** trên MR. Khi bật `state`: phát lại đường lỗi của bước máy trạng thái trên code thật.
3. **Kiểm**.
4. **Review**; khi bật `sec` thêm **security**. Tối đa 2 vòng sửa. Hết 2 vòng mà vẫn còn lỗi chặn: dừng và hỏi người làm chọn quay lại giai đoạn 3, hoặc chấp nhận rủi ro. Chấp nhận thì ghi `review-risk` vào `decisions.md` kèm lý do.
5. **Cửa merge**: với finolabs, `merge_check.py` chỉ chạy với pull request trên GitHub. Repo trên GitLab hay forge khác thì nói rõ MR này không có cửa cứng.
6. **Cửa: duyệt và merge.** Trình gói: kết quả kiểm, review, phạm vi ảnh hưởng và rủi ro đã chấp nhận. Người làm tự merge. Khi bật `repo`, merge repo cung cấp hợp đồng trước, repo dùng hợp đồng sau.
7. Cập nhật `flow.md` (MR nào đã merge), sang đơn vị tiếp theo.

Trong mô tả mỗi MR, dán tóm tắt biên lai: preset, công tắc đã bật, nơi lưu `flow.md`.

## Giai đoạn 5: Sau ra mắt (khi bật `why`)

1. Lấy ngày đọc chỉ số từ `why.md` (thời hạn của mục tiêu, hoặc mốc kiểm của ngưỡng dừng). Nhắc người làm đặt lịch nhắc nếu cần.
2. Đến hạn: đọc chỉ số, so với mục tiêu, chỉ số không được xấu đi và ngưỡng dừng.
3. Ghi `launch-review` vào `decisions.md`: giữ, chỉnh hay gỡ tính năng, kèm số liệu và nguồn.

## Hoàn thành khi

- Mọi MR của tính năng đã merge hoặc được ghi lý do bỏ.
- `flow.md` ghi đủ các cửa đã qua.
- Khi bật `why`: đã có ngày đọc chỉ số sau ra mắt.
