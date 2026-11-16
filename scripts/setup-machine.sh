#!/usr/bin/env bash
# Cài luồng astrolabe cho máy này. Chạy một lần mỗi máy; chạy lại vẫn an toàn.
#
#   ./scripts/setup-machine.sh
#
# Bộ skill upstream (marketplace, repo GitHub, plugin, skill luồng cần) khai trong upstream.json
# ở gốc repo; marketplace và plugin của chính repo này đọc từ .claude-plugin/marketplace.json.
# Thêm, bỏ hay đổi một bộ thì sửa upstream.json, không sửa script này.
#
# Script làm:
# 1. Gỡ plugin cũ ("retired") và marketplace cũ ("retiredMarketplaces") khai trong upstream.json,
#    ví dụ bản feature-workflow trước khi đổi tên thành astrolabe.
# 2. Thêm marketplace còn thiếu, cài plugin còn thiếu, cập nhật plugin đã cài lên bản mới nhất.
# 3. Ghi vào ~/.claude/settings.json (giữ mọi key khác, sao lưu bản cũ):
#    - extraKnownMarketplaces: các marketplace upstream với "autoUpdate": true,
#      và marketplace của repo này (nguồn directory);
#    - enabledPlugins: plugin của repo này và plugin upstream.
#    Bước này chạy sau bước 2 vì "claude plugin marketplace add" ghi lại mục marketplace
#    và làm mất "autoUpdate".
# 4. Chuyển skill rời trong ~/.claude/skills trùng tên với skill của plugin sang
#    ~/.claude/skills-backup-<ngày>/ (không xoá; ~/.agents/skills giữ nguyên cho Codex, Antigravity).
# 5. Kiểm các skill mà luồng gọi tới vẫn còn trong plugin upstream.
#
# Plugin upstream tự lên bản mới khi upstream tăng "version" trong plugin.json.
# Bản mới có hiệu lực ở phiên Claude Code sau, hoặc sau /reload-plugins.

set -euo pipefail

HUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v claude >/dev/null || { echo "Không thấy lệnh claude trong PATH." >&2; exit 1; }
PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null && "$c" -c "import sys" >/dev/null 2>&1; then PY="$c"; break; fi
done
[[ -n "$PY" ]] || { echo "Cần Python 3." >&2; exit 1; }
[[ -f "$HUB/upstream.json" ]] || { echo "Không thấy $HUB/upstream.json." >&2; exit 1; }

# Đường dẫn repo này ở dạng của hệ điều hành (Windows cần C:\..., không phải /c/...).
HUB_NATIVE="$HUB"
command -v cygpath >/dev/null && HUB_NATIVE="$(cygpath -w "$HUB")"

# In một danh sách từ upstream.json và marketplace.json, mỗi dòng một mục:
#   hub-marketplace  tên marketplace của repo này
#   marketplaces     "<marketplace> <repo GitHub>" của từng bộ upstream
#   wanted           mọi plugin cần bật, dạng <plugin>@<marketplace>
#   retired          plugin cũ cần gỡ
#   retired-mk       marketplace cũ cần gỡ
manifest() {
  "$PY" -I -X utf8 - "$HUB_NATIVE" "$1" <<'PY' | tr -d '\r'
import json, os, sys
hub, key = sys.argv[1], sys.argv[2]
up = json.load(open(os.path.join(hub, "upstream.json"), encoding="utf-8-sig"))
mk = json.load(open(os.path.join(hub, ".claude-plugin", "marketplace.json"), encoding="utf-8-sig"))
if key == "hub-marketplace":
    rows = [mk["name"]]
elif key == "marketplaces":
    rows = [f'{u["marketplace"]} {u["repo"]}' for u in up["upstream"]]
elif key == "wanted":
    rows = [f'{p["name"]}@{mk["name"]}' for p in mk.get("plugins", [])]
    rows += [f'{u["plugin"]}@{u["marketplace"]}' for u in up["upstream"]]
elif key == "retired":
    rows = up.get("retired", [])
elif key == "retired-mk":
    rows = up.get("retiredMarketplaces", [])
else:
    sys.exit(f"khoá lạ: {key}")
print("\n".join(rows))
PY
}

HUB_MK="$(manifest hub-marketplace)"
WANTED="$(manifest wanted)"

echo "== 1. Gỡ plugin và marketplace cũ"
installed="$(claude plugin list --json)"
has_plugin() { grep -q "\"id\": \"$1\"" <<<"$installed"; }
for pid in $(manifest retired); do
  if has_plugin "$pid"; then claude plugin uninstall "$pid"; else echo "Không còn $pid"; fi
done
known="$(claude plugin marketplace list 2>/dev/null || true)"
for name in $(manifest retired-mk); do
  if grep -qw -- "$name" <<<"$known"; then claude plugin marketplace remove "$name"; else echo "Không còn marketplace $name"; fi
done

echo "== 2. Marketplace và plugin"
known="$(claude plugin marketplace list 2>/dev/null || true)"
add_mk() {  # <tên> <nguồn>
  if grep -qw -- "$1" <<<"$known"; then echo "Đã có marketplace $1"; else claude plugin marketplace add "$2"; fi
}
# Đọc qua fd 3 để lệnh claude trong vòng lặp không ăn mất stdin của vòng lặp.
while read -r name repo <&3; do
  add_mk "$name" "$repo"
done 3< <(manifest marketplaces)
add_mk "$HUB_MK" "$HUB_NATIVE"
while read -r name _ <&3; do
  claude plugin marketplace update "$name"
done 3< <(manifest marketplaces)
claude plugin marketplace update "$HUB_MK"

installed="$(claude plugin list --json)"
for pid in $WANTED; do
  # Đã cài thì cập nhật lên bản mới nhất của marketplace; autoUpdate chỉ chạy khi mở phiên.
  if has_plugin "$pid"; then claude plugin update "$pid"; else claude plugin install "$pid" --scope user; fi
done

echo "== 3. Ghi ~/.claude/settings.json"
"$PY" -I -X utf8 - "$HUB_NATIVE" <<'PY'
import json, os, shutil, sys, time
hub = sys.argv[1]
up = json.load(open(os.path.join(hub, "upstream.json"), encoding="utf-8-sig"))
hub_mk = json.load(open(os.path.join(hub, ".claude-plugin", "marketplace.json"), encoding="utf-8-sig"))
path = os.path.expanduser("~/.claude/settings.json")
st = json.load(open(path, encoding="utf-8-sig")) if os.path.exists(path) else {}
before = json.dumps(st, sort_keys=True)

mk = st.setdefault("extraKnownMarketplaces", {})
for name in up.get("retiredMarketplaces", []):
    if name != hub_mk["name"]:
        mk.pop(name, None)
for u in up["upstream"]:
    mk[u["marketplace"]] = {"source": {"source": "github", "repo": u["repo"]}, "autoUpdate": True}
mk[hub_mk["name"]] = {"source": {"source": "directory", "path": hub}}

ep = st.setdefault("enabledPlugins", {})
for pid in up.get("retired", []):
    ep.pop(pid, None)
for p in hub_mk.get("plugins", []):
    ep[f'{p["name"]}@{hub_mk["name"]}'] = True
for u in up["upstream"]:
    ep[f'{u["plugin"]}@{u["marketplace"]}'] = True

if json.dumps(st, sort_keys=True) == before:
    print("Không đổi.")
else:
    if os.path.exists(path):
        bak = f"{path}.bak-{time.strftime('%Y%m%d-%H%M%S')}"
        shutil.copy2(path, bak)
        print(f"Đã sao lưu {bak}")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(st, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print("Đã ghi.")
PY

echo "== 4. Skill rời trùng tên"
"$PY" -I -X utf8 - "$WANTED" "$(claude plugin list --json)" <<'PY'
import json, os, shutil, sys, time
wanted = set(sys.argv[1].split())
plugins = json.loads(sys.argv[2])

def plugin_skills(root):
    """Tên skill một plugin nạp: danh sách "skills" trong plugin.json, hoặc skills/*/SKILL.md."""
    names = set()
    manifest = os.path.join(root, ".claude-plugin", "plugin.json")
    listed = None
    if os.path.exists(manifest):
        listed = json.load(open(manifest, encoding="utf-8-sig")).get("skills")
    if isinstance(listed, list):
        for p in listed:
            names.add(os.path.basename(os.path.normpath(p)))
    else:
        d = os.path.join(root, "skills")
        if os.path.isdir(d):
            for n in os.listdir(d):
                if os.path.exists(os.path.join(d, n, "SKILL.md")):
                    names.add(n)
    return names

names = set()
for p in plugins:
    if p["id"] in wanted:
        names |= plugin_skills(p["installPath"])
missing = wanted - {p["id"] for p in plugins}
if missing:
    print("Chưa cài:", ", ".join(sorted(missing)), "- bỏ qua bước dọn skill.")
    sys.exit(0)

skills = os.path.expanduser("~/.claude/skills")
dupes = sorted(n for n in (os.listdir(skills) if os.path.isdir(skills) else []) if n in names)
if not dupes:
    print("Không có skill rời trùng tên.")
    sys.exit(0)
backup = os.path.expanduser(f"~/.claude/skills-backup-{time.strftime('%Y%m%d')}")
os.makedirs(backup, exist_ok=True)
for n in dupes:
    dst = os.path.join(backup, n)
    if os.path.lexists(dst):
        dst = f"{dst}-{time.strftime('%H%M%S')}"
    shutil.move(os.path.join(skills, n), dst)
print(f"Đã chuyển {len(dupes)} skill sang {backup}:")
print("  " + " ".join(dupes))
PY

echo "== 5. Skill luồng cần"
"$PY" -I -X utf8 - "$HUB_NATIVE" "$(claude plugin list --json)" <<'PY'
import json, os, sys
up = json.load(open(os.path.join(sys.argv[1], "upstream.json"), encoding="utf-8-sig"))
need = {f'{u["plugin"]}@{u["marketplace"]}': u.get("skills", []) for u in up["upstream"]}
paths = {p["id"]: p["installPath"] for p in json.loads(sys.argv[2])}
bad = []
for pid, skills in need.items():
    root = paths.get(pid)
    for s in skills:
        found = root and any(
            os.path.exists(os.path.join(dp, "SKILL.md")) and os.path.basename(dp) == s
            for dp, _, _ in os.walk(root))
        if not found:
            bad.append(f"{pid}: {s}")
if bad:
    print("THIẾU (upstream có thể đã đổi tên hoặc bỏ):")
    print("\n".join("  " + b for b in bad))
    sys.exit(1)
print("Đủ.")
PY

cat <<'EOF'

Xong. Việc tiếp theo:
  1. Mở phiên Claude Code mới (hoặc gõ /reload-plugins) để nạp plugin mới.
  2. Chưa có ~/.claude/rules/pstack-models.md thì gõ /pstack:setup-pstack.
  3. Ở repo trung tâm gõ /astrolabe:setup để setup workspace và từng repo.
EOF
