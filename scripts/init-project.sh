#!/usr/bin/env bash
# Chuẩn bị một repo dự án cho luồng feature-workflow.
#
#   ./scripts/init-project.sh <đường-dẫn-repo-dự-án>
#
# - Tạo <repo>/docs/flow-rules.md từ mẫu nếu chưa có (không bao giờ ghi đè)
# - Tạo <repo>/docs/features/ cho thư mục của từng tính năng
#
# Skill được cài qua plugin marketplace (xem README), không qua script này.

set -euo pipefail

[[ $# -eq 1 ]] || { echo "Cách dùng: $0 <đường-dẫn-repo-dự-án>" >&2; exit 2; }
TARGET="$1"
[[ -d "$TARGET" ]] || { echo "Không thấy thư mục: $TARGET" >&2; exit 1; }

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$SRC/plugins/feature-workflow/skills/feature-flow/templates/flow-rules.md"

mkdir -p "$TARGET/docs/features"
[[ -e "$TARGET/docs/features/.gitkeep" ]] || touch "$TARGET/docs/features/.gitkeep"

RULES="$TARGET/docs/flow-rules.md"
if [[ -e "$RULES" ]]; then
  echo "Giữ nguyên $RULES"
else
  cp "$TEMPLATE" "$RULES"
  echo "Đã tạo $RULES từ mẫu. Sửa lại danh sách cho đúng repo này."
fi

echo
echo "Việc tiếp theo trong repo dự án:"
echo "  1. Sửa docs/flow-rules.md cho đúng repo."
echo "  2. Chạy /mattpocock-skills:setup-matt-pocock-skills, chọn lưu spec dạng markdown local."
echo "  3. Adopt cửa merge_check.py của finolabs-vibecode."
echo "  4. Cài Java và TLC nếu dùng /pstack:statechart."
