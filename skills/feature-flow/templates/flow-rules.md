# Luật duyệt của repo

Những việc dưới đây **luôn cần người duyệt**. Khi tính năng chạm một việc trong danh sách, `feature-flow` không được tắt cửa duyệt tương ứng, kể cả khi preset hay công tắc nói tắt.

Sửa file này bằng MR như mọi file khác. Mỗi việc ghi: việc gì, vì sao cần người duyệt, cửa nào bắt buộc, có bắt buộc security review không.

<!--
Cửa có thể chọn: "chốt có làm", "duyệt spec", "chốt thiết kế", "duyệt và merge".
"duyệt và merge" luôn có sẵn cho mọi MR; chỉ ghi các cửa thêm vào.
Ví dụ dưới chỉ để tham khảo; xoá những dòng không đúng với repo này.
-->

| Việc | Vì sao | Cửa bắt buộc | Security review |
|---|---|---|---|
| Sửa hoặc xoá dữ liệu đã chốt | Khó đảo ngược, ảnh hưởng tới người khác đã dùng dữ liệu đó | chốt thiết kế | không |
| Đổi công thức tính toán có ảnh hưởng tới tiền | Sai thì thiệt hại trực tiếp | duyệt spec, chốt thiết kế | không |
| Thay đổi phân quyền hoặc phạm vi xem dữ liệu | Lộ dữ liệu cho người không được xem | chốt thiết kế | có |
| AI đưa ra quyết định thay người | AI sai thì phải có người chịu trách nhiệm | chốt có làm, chốt thiết kế | không |
| Xuất hoặc chia sẻ dữ liệu cá nhân | Luật bảo vệ dữ liệu cá nhân | chốt thiết kế | có |
| Gửi thông báo hàng loạt | Gửi nhầm không thu hồi được | chốt thiết kế | không |
