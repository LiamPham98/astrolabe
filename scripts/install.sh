#!/usr/bin/env bash
# Cài feature-workflow vào một repo dự án.
#
#   ./scripts/install.sh <đường-dẫn-repo-dự-án> [--force]
#
# - Chép skills/feature-flow, skills/why, skills/spec-check vào <repo>/.claude/skills/
# - Tạo <repo>/docs/flow-rules.md từ mẫu nếu chưa có (không bao giờ ghi đè)
# - Tạo <repo>/docs/features/ cho thư mục của từng tính năng
#
# Không có --force thì không ghi đè skill đã có.

set -euo pipefail

SKILLS=(feature-flow why spec-check)

usage() {
  echo "Cách dùng: $0 <đường-dẫn-repo-dự-án> [--force]" >&2
  exit 2
}

[[ $# -ge 1 ]] || usage
TARGET="$1"
FORCE="${2:-}"
[[ -z "$FORCE" || "$FORCE" == "--force" ]] || usage
[[ -d "$TARGET" ]] || { echo "Không thấy thư mục: $TARGET" >&2; exit 1; }

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_SKILLS="$TARGET/.claude/skills"
mkdir -p "$DEST_SKILLS"

for name in "${SKILLS[@]}"; do
  dest="$DEST_SKILLS/$name"
  if [[ -e "$dest" && "$FORCE" != "--force" ]]; then
    echo "Bỏ qua $name: đã có $dest (thêm --force để ghi đè)"
    continue
  fi
  rm -rf "$dest"
  cp -R "$SRC/skills/$name" "$dest"
  echo "Đã cài skill $name"
done

mkdir -p "$TARGET/docs/features"
[[ -e "$TARGET/docs/features/.gitkeep" ]] || touch "$TARGET/docs/features/.gitkeep"

RULES="$TARGET/docs/flow-rules.md"
if [[ -e "$RULES" ]]; then
  echo "Giữ nguyên $RULES"
else
  cp "$SRC/skills/feature-flow/templates/flow-rules.md" "$RULES"
  echo "Đã tạo $RULES từ mẫu. Sửa lại danh sách cho đúng repo này."
fi

COMMIT="$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo "không rõ")"
echo
echo "Xong. feature-workflow commit $COMMIT."
echo "Việc tiếp theo:"
echo "  1. Sửa docs/flow-rules.md cho đúng repo."
echo "  2. Kiểm tra pstack, skill của Matt và finolabs đã cài đúng bản trong UPSTREAM.md."
echo "  3. Gõ /feature-flow <small|medium|large> <mô tả> để bắt đầu một tính năng."
