#!/usr/bin/env bash
# Gắn một repo dự án vào workspace (cách làm tay, thay cho /feature-workflow:feature-setup).
#
#   ./scripts/init-project.sh <đường-dẫn-repo-dự-án> [--standalone]
#
# Mặc định (workspace). Repo dự án nên nằm cùng thư mục cha với repo này, nhưng ở đâu cũng được,
# miễn cùng ổ đĩa: mọi đường dẫn ghi vào file đều là đường dẫn tương đối.
# - Thêm repo vào workspace.json (projects) nếu chưa có
# - Đồng bộ permissions.additionalDirectories trong .claude/settings.json của repo này
# - Ghi <repo>/.claude/feature-workflow.json trỏ về repo này
# - Tạo <repo>/docs/flow-rules.md từ mẫu nếu chưa có (không bao giờ ghi đè)
# - Tạo <repo>/docs/features/ khi featureDocs là auto hoặc project
#
# --standalone: chỉ tạo docs/flow-rules.md và docs/features/, không đụng workspace.

set -euo pipefail

usage() { echo "Cách dùng: $0 <đường-dẫn-repo-dự-án> [--standalone]" >&2; exit 2; }
[[ $# -ge 1 && $# -le 2 ]] || usage
MODE="${2:-workspace}"
[[ "$MODE" == "workspace" || "$MODE" == "--standalone" ]] || usage

HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$(cd "$1" 2>/dev/null && pwd)" || { echo "Không thấy thư mục: $1" >&2; exit 1; }
[[ "$TARGET" != "$HUB" ]] || { echo "Không gắn repo trung tâm vào chính nó." >&2; exit 1; }
TEMPLATE="$HUB/plugins/feature-workflow/skills/feature-flow/templates/flow-rules.md"

RULES="$TARGET/docs/flow-rules.md"
mkdir -p "$TARGET/docs"
if [[ -e "$RULES" ]]; then
  echo "Giữ nguyên $RULES"
else
  cp "$TEMPLATE" "$RULES"
  echo "Đã tạo $RULES từ mẫu."
fi

if [[ "$MODE" == "--standalone" ]]; then
  mkdir -p "$TARGET/docs/features" && touch "$TARGET/docs/features/.gitkeep"
  echo "Xong (đơn lẻ). Sửa docs/flow-rules.md cho đúng repo."
  exit 0
fi

PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null && "$c" -c "import sys" >/dev/null 2>&1; then PY="$c"; break; fi
done
[[ -n "$PY" ]] || { echo "Cần Python 3." >&2; exit 1; }

# Python trên Windows cần đường dẫn dạng C:\..., không phải /c/... của Git Bash.
HUB_NATIVE="$HUB"; TARGET_NATIVE="$TARGET"
if command -v cygpath >/dev/null; then
  HUB_NATIVE="$(cygpath -w "$HUB")"; TARGET_NATIVE="$(cygpath -w "$TARGET")"
fi

"$PY" -I -X utf8 - "$HUB_NATIVE" "$TARGET_NATIVE" <<'PY'
import json, os, subprocess, sys
from urllib.parse import urlsplit, urlunsplit
hub, target = sys.argv[1], sys.argv[2]

def strip_userinfo(url):
    # https://user:token@host/x -> https://host/x, để token không vào file commit chung
    parts = urlsplit(url)
    if parts.scheme and "@" in parts.netloc:
        return urlunsplit(parts._replace(netloc=parts.netloc.rsplit("@", 1)[1]))
    return url

def rel(path, start):
    try:
        return os.path.relpath(path, start).replace(os.sep, "/")
    except ValueError:  # Windows: khác ổ đĩa thì không có đường dẫn tương đối
        sys.exit(f"{path} và {start} phải cùng ổ đĩa.")

def write_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

name = os.path.basename(target)
rel_from_hub = rel(target, hub)
rel_to_hub = rel(hub, target)

ws_path = os.path.join(hub, "workspace.json")
ws = json.load(open(ws_path, encoding="utf-8")) if os.path.exists(ws_path) else {"version": 1}
ws.setdefault("docsBackend", "local")
ws.setdefault("featureDocs", "auto")
projects = ws.setdefault("projects", [])
if any(p.get("path") == rel_from_hub for p in projects):
    print(f"{rel_from_hub} đã có trong workspace.json")
elif any(p.get("name") == name for p in projects):
    sys.exit(f"workspace.json đã có repo khác tên {name}; đổi tên thư mục hoặc sửa tay.")
else:
    try:
        remote = subprocess.run(["git", "-C", target, "remote", "get-url", "origin"],
                                capture_output=True, text=True).stdout.strip()
    except OSError:
        remote = ""
    projects.append({"name": name, "path": rel_from_hub, "remote": strip_userinfo(remote)})
    print(f"Đã thêm {name} ({rel_from_hub}) vào workspace.json")
write_json(ws_path, ws)

st_path = os.path.join(hub, ".claude", "settings.json")
st = json.load(open(st_path, encoding="utf-8")) if os.path.exists(st_path) else {}
st.setdefault("permissions", {})["additionalDirectories"] = [p["path"] for p in projects]
write_json(st_path, st)
print("Đã đồng bộ permissions.additionalDirectories")

ptr = os.path.join(target, ".claude", "feature-workflow.json")
cfg = json.load(open(ptr, encoding="utf-8")) if os.path.exists(ptr) else {}
cfg["workspace"] = rel_to_hub
write_json(ptr, cfg)
print(f"Đã ghi {ptr}")

if ws["featureDocs"] in ("auto", "project"):
    d = os.path.join(target, "docs", "features")
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, ".gitkeep"), "a").close()
PY

echo
echo "Việc tiếp theo:"
echo "  1. Sửa docs/flow-rules.md của repo (chỉ thêm việc riêng; luật chung ở rules/common.md)."
echo "  2. Mở phiên trong repo đó, gõ /mattpocock-skills:setup-matt-pocock-skills và /finolabs-vibecode:setup."
echo "  3. Commit file mới trong repo dự án và workspace.json của repo trung tâm."
