#!/usr/bin/env bash
# Cập nhật một bộ trong vendor/ lên một commit cụ thể của upstream.
#
#   ./scripts/update-vendor.sh <finolabs-vibecode|pstack|mattpocock-skills> <commit>
#
# Script thay toàn bộ vendor/<tên>/ bằng nội dung upstream ở commit đó.
# Với pstack, giữ lại .claude-plugin/plugin.json của repo này (upstream chỉ có
# manifest cho Cursor). Sau khi chạy: xem git diff, chạy thử luồng, sửa bản ghim
# trong UPSTREAM.md, rồi commit tất cả trong cùng một MR.

set -euo pipefail

[[ $# -eq 2 ]] || { echo "Cách dùng: $0 <finolabs-vibecode|pstack|mattpocock-skills> <commit>" >&2; exit 2; }
NAME="$1"; REF="$2"

case "$NAME" in
  finolabs-vibecode) URL="https://github.com/finolabs/finolabs-vibecode.git"; SUBDIR="." ;;
  pstack)            URL="https://github.com/cursor/plugins.git";              SUBDIR="pstack" ;;
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

KEEP=""
if [[ "$NAME" == "pstack" && -f "$DEST/.claude-plugin/plugin.json" ]]; then
  KEEP="$TMP/pstack-plugin.json"
  cp "$DEST/.claude-plugin/plugin.json" "$KEEP"
fi

rm -rf "$DEST"
mkdir -p "$DEST"
(cd "$TMP/src/$SUBDIR" && tar cf - --exclude=.git .) | (cd "$DEST" && tar xf -)

if [[ -n "$KEEP" ]]; then
  mkdir -p "$DEST/.claude-plugin"
  cp "$KEEP" "$DEST/.claude-plugin/plugin.json"
  echo "Giữ manifest Claude Code của pstack. Nhớ sửa version cho khớp upstream."
fi

echo "vendor/$NAME giờ ở commit $FULL"
echo "Sửa bản ghim trong UPSTREAM.md, chạy thử luồng, rồi commit."
