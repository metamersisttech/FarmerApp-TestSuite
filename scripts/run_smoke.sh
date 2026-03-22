#!/usr/bin/env bash
# Quick smoke run — only 00_smoke folder (< 5 minutes)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/run_all.sh" "00_smoke" "$@"
