#!/usr/bin/env bash
# Cập nhật một bộ trong vendor/ lên một commit cụ thể của upstream.
#
#   ./scripts/update-vendor.sh <finolabs-vibecode|pstack|mattpocock-skills> <commit>
#
# Script thay toàn bộ vendor/<tên>/ bằng nội dung upstream ở commit đó.
# pstack lấy bản dựng cho Claude Code (harness/pstack/claude-code), không lấy thư
# mục pstack/ gốc (bản cho Cursor). Sau khi chạy: xem git diff, chạy thử luồng,
# sửa bản ghim trong UPSTREAM.md, rồi commit tất cả trong cùng một MR.

set -euo pipefail

[[ $# -eq 2 ]] || { echo "Cách dùng: $0 <finolabs-vibecode|pstack|mattpocock-skills> <commit>" >&2; exit 2; }
NAME="$1"; REF="$2"

case "$NAME" in
  finolabs-vibecode) URL="https://github.com/finolabs/finolabs-vibecode.git"; SUBDIR="." ;;
  pstack)            URL="https://github.com/cursor/plugins.git";              SUBDIR="harness/pstack/claude-code" ;;
  mattpocock-skills) URL="https://github.com/mattpocock/skills.git";           SUBDIR="." ;;
  *) echo "Không biết bộ: $NAME" >&2; exit 2 ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/vendor/$NAME"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone -q "$URL" "$TMP/src"
git -C "$TMP/src" checkout -q "$REF"
FULL="$(git -C "$TMP/src" rev-parse HEAD)"

rm -rf "$DEST"
mkdir -p "$DEST"
(cd "$TMP/src/$SUBDIR" && tar cf - --exclude=.git .) | (cd "$DEST" && tar xf -)

echo "vendor/$NAME giờ ở commit $FULL"
echo "Sửa bản ghim trong UPSTREAM.md, chạy thử luồng, rồi commit."
