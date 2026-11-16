# astrolabe

Luồng làm tính năng cho Claude Code, đóng gói thành một plugin. Cài xong là dùng được: không cần repo trung tâm, không ghi file cấu hình nào vào repo dự án, không bắt buộc cài thêm plugin nào. Lệnh gõ `/astrolabe:<skill>`.

| Skill | Dùng khi |
|---|---|
| `/astrolabe:flow` | Bắt đầu hoặc làm tiếp một tính năng: điều phối, có nên làm, hiểu yêu cầu, thiết kế, lặp từng MR, sau ra mắt |
| `/astrolabe:why` | Chốt tính năng có đáng làm không, làm để đạt gì, lấy gì để biết là đúng |
| `/astrolabe:spec-check` | Soát spec trước khi thiết kế, chấm checklist sẵn sàng |
| `/astrolabe:setup` | Kiểm cấu hình, Orrery, luật duyệt và bộ đồng hành; tạo luật từ mẫu |
| `/astrolabe:help` | Hỏi đang ở bước nào, gõ gì tiếp, dùng skill nào |

## Cài đặt

```bash
claude plugin marketplace add LiamPham98/astrolabe
```

```bash
claude plugin install astrolabe@astrolabe
```

Khi bật plugin, Claude Code hỏi ba giá trị cấu hình (sửa lại được trong `/config`, mục plugin `astrolabe`):

| Khoá | Ý nghĩa | Mặc định |
|---|---|---|
| `workspace_root` | Thư mục chứa các repo làm việc chung, ví dụ `~/code`. Mọi repo git trong đó là một workspace | thư mục cha của repo đang mở |
| `docs_backend` | `orrery`: tài liệu và luật duyệt là note trong Orrery. `local`: file trong thư mục dữ liệu của plugin trên máy | `local` |
| `orrery_space` | Space Orrery dùng khi `docs_backend` là `orrery` | `personal` |

Rồi mở phiên Claude Code mới trong một repo và gõ `/astrolabe:setup` để kiểm và tạo luật duyệt từ mẫu. Plugin tự cập nhật khi repo này tăng `version`.

## Luồng

```
0  Điều phối         /astrolabe:flow     cấu hình, repo chạm tới, luật, preset + công tắc, biên lai
1  Có nên làm không? astrolabe:why       (tuỳ chọn)  ── Dừng: chốt có làm
2  Hiểu yêu cầu      hỏi làm rõ → spec → astrolabe:spec-check
                                         (tuỳ chọn)  ── Dừng: duyệt spec
3  Thiết kế          thiết kế (+ phản biện, máy trạng thái)
                                         (tuỳ chọn)  ── Dừng: chốt thiết kế
   Trước code        điểm khôi phục
4  Mỗi MR            code → phạm vi ảnh hưởng → kiểm → review (+ security)
                                                     ── Dừng: duyệt và merge
5  Sau ra mắt        đọc chỉ số so với mục tiêu và ngưỡng dừng   (khi đã chạy bước 1)
```

**Bốn cửa dừng duyệt**: chốt có làm, duyệt spec, chốt thiết kế, duyệt và merge mỗi MR. Ngoài bốn cửa, agent trình kết quả rồi đi tiếp. Việc ghi trong luật duyệt thì không được tắt cửa duyệt.

**Preset**:

- small: bỏ giai đoạn 1 đến 3;
- medium: bật `unclear`, `cross`;
- large: bật `why`, `unclear`, `multi`, `cross`, `contest`, `state`, `repo`.

Người làm vẫn chỉnh từng công tắc. Chi tiết trong [`plugins/astrolabe/skills/flow/SKILL.md`](plugins/astrolabe/skills/flow/SKILL.md); bảng tóm tắt ở [`docs/cheat-sheet.md`](docs/cheat-sheet.md).

```
/astrolabe:flow large mở lại kỳ đã khóa
```

**Tính năng nhiều repo**: mở phiên ở một repo, hoặc ở thư mục `workspace_root`; flow hỏi tính năng chạm repo nào. Repo nằm ngoài thư mục phiên thì thêm bằng `/add-dir <đường dẫn>`.

## Nơi lưu tài liệu

Tài liệu tính năng và luật duyệt không nằm trong repo dự án. Bố cục giống nhau ở cả hai nơi lưu:

```
_workspace/
├─ rules.md                 luật duyệt chung
└─ features/<slug>/         tính năng nhiều repo
<repo>/
├─ rules.md                 luật duyệt riêng của repo
├─ GLOSSARY.md, adr/        thuật ngữ, ADR
└─ features/<slug>/         flow.md, why.md, spec.md, issues/, spec-check.md, decisions.md
```

- `orrery`: note trong Orrery (dịch vụ lưu note qua MCP), space `orrery_space`. Luật, thuật ngữ và ADR đổi qua changeset. Phiên không có Orrery thì ghi tạm vào thư mục dữ liệu của plugin, phiên sau đồng bộ lên.
- `local`: file trong thư mục dữ liệu của plugin (`~/.claude/plugins/data/astrolabe-…/`). Chỉ có trên máy này; gỡ plugin là mất, trừ khi gỡ với `--keep-data`.

Chưa có luật nào thì flow dùng mẫu 6 việc luôn cần người duyệt: sửa hoặc xoá dữ liệu đã chốt, công thức ảnh hưởng tới tiền, phân quyền, AI ra quyết định thay người, xuất dữ liệu cá nhân, gửi thông báo hàng loạt.

## Bộ đồng hành (tuỳ chọn)

Không cài bộ nào luồng vẫn chạy đủ: mỗi bước có cách làm mặc định dựa trên những gì Claude Code có sẵn (agent tự phỏng vấn và viết spec, `code-review`, `security-review`, chạy test của repo). Cài bộ nào thì flow dùng bộ đó cho bước nó làm tốt hơn:

| Bộ | Bước | Cài |
|---|---|---|
| `finolabs-vibecode` | chọn path, điểm khôi phục, kiểm, review, security, cửa merge | `claude plugin marketplace add finolabs/finolabs-vibecode` rồi `claude plugin install finolabs-vibecode@finolabs-vibecode` |
| `pstack` | thiết kế, phản biện, máy trạng thái, code, phạm vi ảnh hưởng | `claude plugin marketplace add cursor/plugins` rồi `claude plugin install pstack@cursor-plugins` |
| `mattpocock-skills` | hỏi làm rõ, spec, ticket, thuật ngữ | `claude plugin marketplace add mattpocock/skills` rồi `claude plugin install mattpocock-skills@mattpocock` |

Nguồn, giấy phép và skill luồng dùng của từng bộ ghi trong [`UPSTREAM.md`](UPSTREAM.md).

## Sửa plugin

Fork repo này, sửa trong `plugins/astrolabe/`, rồi thử bằng `claude --plugin-dir plugins/astrolabe`. Sửa xong thì tăng `version` trong `plugins/astrolabe/.claude-plugin/plugin.json`, để máy cài từ GitHub nhận bản mới.

## Còn treo

- Giấy phép vibebiz: làm rõ trước khi lấy thêm bất kỳ phần nào trực tiếp từ code gốc.
- Repo trên GitLab: `merge_check.py` của finolabs chỉ gọi `gh` (GitHub), nên cửa merge cứng không chạy ở GitLab.

## Giấy phép

MIT, xem [`LICENSE`](LICENSE). Bộ đồng hành có giấy phép riêng, xem [`UPSTREAM.md`](UPSTREAM.md).
