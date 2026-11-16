#!/usr/bin/env bash
# Cài luồng feature-workflow cho máy này. Chạy một lần mỗi máy; chạy lại vẫn an toàn.
#
#   ./scripts/setup-machine.sh
#
# Script làm:
# 1. Ghi vào ~/.claude/settings.json (giữ mọi key khác, sao lưu bản cũ):
#    - extraKnownMarketplaces: ba marketplace upstream với "autoUpdate": true,
#      và marketplace feature-workflow (thư mục repo này);
#    - enabledPlugins: bốn plugin của luồng.
# 2. Thêm marketplace còn thiếu, cài plugin còn thiếu.
# 3. Gỡ bản ghim cũ <bộ>@feature-workflow nếu còn.
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

# Đường dẫn repo này ở dạng của hệ điều hành (Windows cần C:\..., không phải /c/...).
HUB_NATIVE="$HUB"
command -v cygpath >/dev/null && HUB_NATIVE="$(cygpath -w "$HUB")"

echo "== 1. Ghi ~/.claude/settings.json"
"$PY" -I -X utf8 - "$HUB_NATIVE" <<'PY'
import json, os, shutil, sys, time
hub = sys.argv[1]
path = os.path.expanduser("~/.claude/settings.json")
st = json.load(open(path, encoding="utf-8")) if os.path.exists(path) else {}
before = json.dumps(st, sort_keys=True)

mk = st.setdefault("extraKnownMarketplaces", {})
upstream = {
    "finolabs-vibecode": "finolabs/finolabs-vibecode",
    "mattpocock": "mattpocock/skills",
    "cursor-plugins": "cursor/plugins",
}
for name, repo in upstream.items():
    mk[name] = {"source": {"source": "github", "repo": repo}, "autoUpdate": True}
mk["feature-workflow"] = {"source": {"source": "directory", "path": hub}}

ep = st.setdefault("enabledPlugins", {})
for old in ("finolabs-vibecode", "pstack", "mattpocock-skills"):
    ep.pop(f"{old}@feature-workflow", None)
for pid in ("feature-workflow@feature-workflow", "finolabs-vibecode@finolabs-vibecode",
            "mattpocock-skills@mattpocock", "pstack@cursor-plugins"):
    ep[pid] = True

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

echo "== 2. Marketplace và plugin"
known="$(claude plugin marketplace list 2>/dev/null || true)"
add_mk() {  # <tên> <nguồn>
  if grep -qw -- "$1" <<<"$known"; then echo "Đã có marketplace $1"; else claude plugin marketplace add "$2"; fi
}
add_mk finolabs-vibecode finolabs/finolabs-vibecode
add_mk mattpocock mattpocock/skills
add_mk cursor-plugins cursor/plugins
add_mk feature-workflow "$HUB_NATIVE"
claude plugin marketplace update finolabs-vibecode
claude plugin marketplace update mattpocock
claude plugin marketplace update cursor-plugins
claude plugin marketplace update feature-workflow

installed="$(claude plugin list --json)"
has_plugin() { grep -q "\"id\": \"$1\"" <<<"$installed"; }
for pid in feature-workflow@feature-workflow finolabs-vibecode@finolabs-vibecode \
           mattpocock-skills@mattpocock pstack@cursor-plugins; do
  if has_plugin "$pid"; then echo "Đã cài $pid"; else claude plugin install "$pid" --scope user; fi
done

echo "== 3. Gỡ bản ghim cũ"
for pid in finolabs-vibecode@feature-workflow pstack@feature-workflow mattpocock-skills@feature-workflow; do
  if has_plugin "$pid"; then claude plugin uninstall "$pid"; else echo "Không còn $pid"; fi
done

echo "== 4. Skill rời trùng tên"
"$PY" -I -X utf8 - "$(claude plugin list --json)" <<'PY'
import json, os, shutil, sys, time
plugins = json.loads(sys.argv[1])
wanted = {"finolabs-vibecode@finolabs-vibecode", "mattpocock-skills@mattpocock",
          "pstack@cursor-plugins", "feature-workflow@feature-workflow"}

def plugin_skills(root):
    """Tên skill một plugin nạp: danh sách "skills" trong plugin.json, hoặc skills/*/SKILL.md."""
    names = set()
    manifest = os.path.join(root, ".claude-plugin", "plugin.json")
    listed = None
    if os.path.exists(manifest):
        listed = json.load(open(manifest, encoding="utf-8")).get("skills")
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
"$PY" -I -X utf8 - "$(claude plugin list --json)" <<'PY'
import json, os, sys
need = {
    "finolabs-vibecode@finolabs-vibecode": ["coding-router", "restore-point", "checks", "review-gate",
                                             "security-review-gate", "setup"],
    "pstack@cursor-plugins": ["architect", "interrogate", "statechart", "poteto-mode", "blast-radius",
                              "how", "setup-pstack"],
    "mattpocock-skills@mattpocock": ["grill-with-docs", "grilling", "domain-modeling", "to-spec",
                                     "to-tickets", "setup-matt-pocock-skills"],
}
paths = {p["id"]: p["installPath"] for p in json.loads(sys.argv[1])}
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
  3. Ở repo trung tâm gõ /feature-workflow:feature-setup để setup workspace và từng repo.
EOF
