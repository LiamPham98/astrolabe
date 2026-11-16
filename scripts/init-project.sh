#!/usr/bin/env bash
# Gắn một repo dự án vào workspace (cách làm tay, thay cho /feature-workflow:feature-setup).
#
#   ./scripts/init-project.sh <đường-dẫn-repo-dự-án> [--standalone]
#
# Mặc định (workspace), repo dự án phải nằm cùng thư mục cha với repo này:
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

if [[ "$(dirname "$TARGET")" != "$(dirname "$HUB")" ]]; then
  echo "Repo dự án phải nằm cùng thư mục cha với $HUB" >&2
  exit 1
fi

python3 -I - "$HUB" "$TARGET" <<'PY'
import json, os, subprocess, sys
hub, target = sys.argv[1], sys.argv[2]
name = os.path.basename(target)
rel_from_hub = "../" + name
rel_to_hub = "../" + os.path.basename(hub)

ws_path = os.path.join(hub, "workspace.json")
ws = json.load(open(ws_path, encoding="utf-8"))
ws.setdefault("featureDocs", "auto")
projects = ws.setdefault("projects", [])
if not any(p.get("name") == name for p in projects):
    try:
        remote = subprocess.run(["git", "-C", target, "remote", "get-url", "origin"],
                                capture_output=True, text=True).stdout.strip()
    except OSError:
        remote = ""
    projects.append({"name": name, "path": rel_from_hub, "remote": remote})
    print(f"Đã thêm {name} vào workspace.json")
json.dump(ws, open(ws_path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
open(ws_path, "a", encoding="utf-8").write("\n")

st_path = os.path.join(hub, ".claude", "settings.json")
os.makedirs(os.path.dirname(st_path), exist_ok=True)
st = json.load(open(st_path, encoding="utf-8")) if os.path.exists(st_path) else {}
perms = st.setdefault("permissions", {})
perms["additionalDirectories"] = [p["path"] for p in projects]
json.dump(st, open(st_path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
open(st_path, "a", encoding="utf-8").write("\n")
print("Đã đồng bộ permissions.additionalDirectories")

ptr = os.path.join(target, ".claude", "feature-workflow.json")
os.makedirs(os.path.dirname(ptr), exist_ok=True)
json.dump({"workspace": rel_to_hub}, open(ptr, "w", encoding="utf-8"), indent=2)
open(ptr, "a", encoding="utf-8").write("\n")
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
echo "  3. Commit file mới trong cả hai repo."
