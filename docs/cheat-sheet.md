# Cheat-sheet: làm một tính năng

## 1. Bắt đầu

```
/feature-flow <small|medium|large> <mô tả>
```

Agent chọn công tắc, đọc `docs/flow-rules.md`, ghi biên lai, rồi trình chuỗi lệnh. Đồng ý thì đi tiếp.

## 2. Chọn quy mô

| Tính năng | Preset |
|---|---|
| Sửa nhỏ, một chỗ, dễ quay lại | small |
| Vài module, yêu cầu chưa thật rõ | medium |
| Mới, tốn công, cần duyệt, có trạng thái hoặc nhiều repo | large |

## 3. Công tắc

| Bật khi | Công tắc | Thêm bước |
|---|---|---|
| Cần chứng minh giá trị | `why` | `feature-why`, đọc chỉ số sau ra mắt |
| Yêu cầu mơ hồ | `unclear` | `/grill-with-docs` |
| Nhiều phiên, người, MR | `multi` | `/to-spec`, `spec-check` |
| Vượt biên hàm | `cross` | `/architect` |
| Khó đảo ngược | `contest` | `/interrogate` |
| Có máy trạng thái | `state` | `/statechart` trước khi code |
| Tiền, quyền, dữ liệu cá nhân | `sec` | `/security-review-gate` |
| Nhiều repo | `repo` | restore-point mỗi repo, merge bên cung cấp trước |

**Bỏ bước Why khi**: sửa bug, refactor, việc nhỏ đã rõ, việc kỹ thuật thuần.

## 4. Bốn lần dừng

1. **Chốt có làm**: đọc `why.md` (do `feature-why` ghi). Chọn không làm thì dừng.
2. **Duyệt spec**: đọc spec và `spec-check.md`.
3. **Chốt thiết kế**: checkpoint của architect, finding interrogate, kết quả statechart.
4. **Duyệt và merge** mỗi MR: checks, review-gate, blast-radius, rủi ro đã chấp nhận. Người làm tự merge.

## 5. Lệnh hay gõ

```
/architect with checkpoint. stop and show me before implementing. Spec: <đường dẫn>
/restore-point create
/poteto-mode <mục tiêu>. Cách kiểm: <…>. Một MR mỗi đơn vị kiểm được. Dùng thiết kế đã chốt, bắt đầu từ throughput checkpoint. Spec: <đường dẫn>
/blast-radius
/checks
/review-gate
```

## 6. Khi kẹt

- **review-gate hết 2 vòng mà vẫn REWORK**: quay lại thiết kế, hoặc chấp nhận rủi ro và ghi `review-risk` vào `decisions.md`.
- **Muốn đổi quyết định cũ**: thêm mục `supersede` vào `decisions.md`, không sửa mục cũ.
- **Tính năng chạm việc trong file luật**: cửa duyệt đó không tắt được. Muốn đổi luật thì sửa `docs/flow-rules.md` bằng MR.

## 7. Không làm

- Không chạy `/how` riêng trước architect (Phase A đã chạy).
- Không dùng `/implement` của Matt.
- Không để agent merge.
