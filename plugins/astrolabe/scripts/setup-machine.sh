#!/usr/bin/env bash
# Cài luồng astrolabe cho máy này. Chạy một lần mỗi máy; chạy lại vẫn an toàn.
#
# File này nằm trong plugin (plugins/astrolabe/scripts/) nên chạy được từ hai chỗ:
# - plugin cài từ GitHub: /astrolabe:setup chạy file này trong thư mục plugin đã cài.
#   Marketplace của plugin là nguồn GitHub, bật autoUpdate.
# - bản clone hay fork của repo: ./scripts/setup-machine.sh ở gốc repo gọi tới file này.
#   Marketplace của plugin là thư mục của bản clone; muốn bản mới thì git pull.
#
# Bộ skill upstream (marketplace, repo GitHub, plugin, skill luồng cần) khai trong upstream.json
# ở thư mục plugin. Thêm, bỏ hay đổi một bộ thì sửa upstream.json, không sửa script này.
#
# Script làm:
#
# Chạy từ bản clone mà marketplace cùng tên đã có với nguồn khác (ví dụ đã cài từ GitHub), script giữ
# nguồn đó và báo cách chuyển sang bản clone, không ghi đè.
#
# 1. Gỡ plugin cũ ("retired") và marketplace cũ ("retiredMarketplaces") khai trong upstream.json,
#    ví dụ bản feature-workflow trước khi đổi tên thành astrolabe.
# 2. Thêm marketplace còn thiếu, cài plugin còn thiếu, cập nhật plugin đã cài lên bản mới nhất.
# 3. Ghi vào ~/.claude/settings.json (giữ mọi key khác, sao lưu bản cũ):
#    - extraKnownMarketplaces: marketplace upstream và marketplace của plugin này, bật "autoUpdate"
#      (trừ nguồn thư mục của bản clone);
#    - enabledPlugins: plugin này và plugin upstream.
#    Bước này chạy sau bước 2 vì "claude plugin marketplace add" ghi lại mục marketplace
#    và làm mất "autoUpdate".
# 4. Chuyển skill rời trong ~/.claude/skills trùng tên với skill của plugin sang
#    ~/.claude/skills-backup-<ngày>/ (không xoá; ~/.agents/skills giữ nguyên cho Codex, Antigravity).
# 5. Kiểm các skill mà luồng gọi tới vẫn còn trong plugin upstream.
#
# Plugin tự lên bản mới khi nguồn tăng "version" trong plugin.json.
# Bản mới có hiệu lực ở phiên Claude Code sau, hoặc sau /reload-plugins.

set -euo pipefail

PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="$(cd "$PLUGIN/../.." && pwd)"
command -v claude >/dev/null || { echo "Không thấy lệnh claude trong PATH." >&2; exit 1; }
PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null && "$c" -c "import sys" >/dev/null 2>&1; then PY="$c"; break; fi
done
[[ -n "$PY" ]] || { echo "Cần Python 3." >&2; exit 1; }
[[ -f "$PLUGIN/upstream.json" ]] || { echo "Không thấy $PLUGIN/upstream.json." >&2; exit 1; }

# Đường dẫn ở dạng của hệ điều hành (Python trên Windows cần C:\..., không phải /c/...).
native() { if command -v cygpath >/dev/null; then cygpath -w "$1"; else printf '%s\n' "$1"; fi; }
PLUGIN_NATIVE="$(native "$PLUGIN")"
REPO_NATIVE="$(native "$REPO")"

# Cách chạy, in một dòng:
#   clone <marketplace>                   từ bản clone có .claude-plugin/marketplace.json trỏ tới plugin này,
#                                         marketplace chưa có hoặc đang trỏ vào chính bản clone
#   keep <marketplace>                    từ bản clone, nhưng marketplace cùng tên đang dùng nguồn khác
#                                         (ví dụ GitHub): giữ nguồn đó, không ghi đè
#   installed <marketplace> <owner/repo>  từ plugin đã cài; marketplace lấy từ claude plugin list
detect_mode() {
  "$PY" -I -X utf8 - "$PLUGIN_NATIVE" "$REPO_NATIVE" "$(claude plugin list --json)" \
    "$(claude plugin marketplace list --json 2>/dev/null || echo '[]')" <<'PY' | tr -d '\r'
import json, os, re, sys
plugin, repo, listing, markets = sys.argv[1:5]
load = lambda p: json.load(open(p, encoding="utf-8-sig"))
same = lambda a, b: os.path.normcase(os.path.realpath(a)) == os.path.normcase(os.path.realpath(b))
def parse(text):
    try:
        return json.loads(text or "[]")
    except ValueError:
        return []
mkp = os.path.join(repo, ".claude-plugin", "marketplace.json")
if os.path.exists(mkp):
    mk = load(mkp)
    for p in mk.get("plugins", []):
        if isinstance(p.get("source"), str) and same(os.path.join(repo, p["source"]), plugin):
            cur = next((m for m in parse(markets) if m.get("name") == mk["name"]), None)
            path = cur and (cur.get("path") or cur.get("installLocation"))
            if cur and not (cur.get("source") == "directory" and path and same(path, repo)):
                where = cur.get("repo") or path or cur.get("source")
                print(f"Marketplace {mk['name']} đang dùng nguồn {cur.get('source')} ({where}), không phải bản clone này; "
                      f"giữ nguyên nguồn đó. Muốn dùng bản clone: claude plugin marketplace remove {mk['name']}, "
                      "rồi chạy lại script.", file=sys.stderr)
                print("keep", mk["name"], "-")
            else:
                print("clone", mk["name"], "-")
            sys.exit()
for p in json.loads(listing or "[]"):
    if same(p.get("installPath", ""), plugin):
        meta = load(os.path.join(plugin, ".claude-plugin", "plugin.json"))
        m = re.search(r"github\.com[/:]([^/]+/[^/.]+)", meta.get("repository", ""))
        print("installed", p["id"].split("@", 1)[1], m.group(1) if m else "-")
        sys.exit()
sys.exit("Không biết plugin này cài từ marketplace nào. Cài plugin qua marketplace trước, hoặc chạy từ bản clone.")
PY
}
MODE_LINE="$(detect_mode)"
read -r MODE SELF_MK SELF_REPO <<<"$MODE_LINE"
[[ -n "$MODE" ]] || exit 1
SELF_SRC="$SELF_REPO"
[[ "$MODE" == clone ]] && SELF_SRC="$REPO_NATIVE"
echo "Chạy từ: $MODE (marketplace $SELF_MK)"

# In một danh sách từ upstream.json, mỗi dòng một mục:
#   marketplaces  "<marketplace> <repo GitHub>" của từng bộ upstream
#   wanted        mọi plugin cần bật, dạng <plugin>@<marketplace>, kể cả plugin này
#   retired       plugin cũ cần gỡ
#   retired-mk    marketplace cũ cần gỡ
manifest() {
  "$PY" -I -X utf8 - "$PLUGIN_NATIVE" "$SELF_MK" "$1" <<'PY' | tr -d '\r'
import json, os, sys
plugin, self_mk, key = sys.argv[1], sys.argv[2], sys.argv[3]
load = lambda p: json.load(open(p, encoding="utf-8-sig"))
up = load(os.path.join(plugin, "upstream.json"))
me = load(os.path.join(plugin, ".claude-plugin", "plugin.json"))["name"]
if key == "marketplaces":
    rows = [f'{u["marketplace"]} {u["repo"]}' for u in up["upstream"]]
elif key == "wanted":
    rows = [f"{me}@{self_mk}"] + [f'{u["plugin"]}@{u["marketplace"]}' for u in up["upstream"]]
elif key == "retired":
    rows = up.get("retired", [])
elif key == "retired-mk":
    rows = [m for m in up.get("retiredMarketplaces", []) if m != self_mk]
else:
    sys.exit(f"khoá lạ: {key}")
print("\n".join(rows))
PY
}

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
add_mk "$SELF_MK" "$SELF_SRC"
while read -r name _ <&3; do
  claude plugin marketplace update "$name"
done 3< <(manifest marketplaces)
claude plugin marketplace update "$SELF_MK"

installed="$(claude plugin list --json)"
for pid in $WANTED; do
  # Đã cài thì cập nhật lên bản mới nhất của marketplace; autoUpdate chỉ chạy khi mở phiên.
  if has_plugin "$pid"; then claude plugin update "$pid"; else claude plugin install "$pid" --scope user; fi
done

echo "== 3. Ghi ~/.claude/settings.json"
"$PY" -I -X utf8 - "$PLUGIN_NATIVE" "$MODE" "$SELF_MK" "$SELF_SRC" <<'PY'
import json, os, shutil, sys, time
plugin, mode, self_mk, self_src = sys.argv[1:5]
load = lambda p: json.load(open(p, encoding="utf-8-sig"))
up = load(os.path.join(plugin, "upstream.json"))
me = load(os.path.join(plugin, ".claude-plugin", "plugin.json"))["name"]
path = os.path.expanduser("~/.claude/settings.json")
st = load(path) if os.path.exists(path) else {}
before = json.dumps(st, sort_keys=True)

mk = st.setdefault("extraKnownMarketplaces", {})
for name in up.get("retiredMarketplaces", []):
    if name != self_mk:
        mk.pop(name, None)
for u in up["upstream"]:
    mk[u["marketplace"]] = {"source": {"source": "github", "repo": u["repo"]}, "autoUpdate": True}
if mode == "clone":
    mk[self_mk] = {"source": {"source": "directory", "path": self_src}}
else:
    # Giữ nguồn người dùng đã thêm; chỉ điền nguồn GitHub khi chưa có mục nào.
    entry = mk.setdefault(self_mk, {})
    if "source" not in entry and self_src != "-":
        entry["source"] = {"source": "github", "repo": self_src}
    entry["autoUpdate"] = True

ep = st.setdefault("enabledPlugins", {})
for pid in up.get("retired", []):
    ep.pop(pid, None)
ep[f"{me}@{self_mk}"] = True
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
"$PY" -I -X utf8 - "$PLUGIN_NATIVE" "$(claude plugin list --json)" <<'PY'
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
