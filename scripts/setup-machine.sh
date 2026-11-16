#!/usr/bin/env bash
# Lối tắt cho bản clone: chạy script thật trong plugin, plugins/astrolabe/scripts/setup-machine.sh.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/plugins/astrolabe/scripts/setup-machine.sh" "$@"
