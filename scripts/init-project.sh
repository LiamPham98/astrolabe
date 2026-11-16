#!/usr/bin/env bash
# Lối tắt cho bản clone: bản clone là repo trung tâm, chạy script thật trong plugin,
# plugins/astrolabe/scripts/init-project.sh.
#
#   ./scripts/init-project.sh <đường-dẫn-repo-dự-án> [--standalone]
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASTROLABE_HUB="$ROOT" exec "$ROOT/plugins/astrolabe/scripts/init-project.sh" "$@"
