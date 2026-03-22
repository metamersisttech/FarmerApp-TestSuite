#!/usr/bin/env bash
# update_baseline.sh — Promote latest screenshots to visual regression baselines
# Usage: ./scripts/update_baseline.sh [--report-dir <path>] [--screen <name>]
#
# Without --screen: promotes ALL screenshots from the latest report.
# With    --screen: promotes only the named screenshot (without .png).

set -euo pipefail

REPORT_DIR=""
SCREEN_FILTER=""
BASELINE_DIR="docs/testing/baseline-screenshots"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --report-dir) REPORT_DIR="$2"; shift 2 ;;
    --screen)     SCREEN_FILTER="$2"; shift 2 ;;
    *)            echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Auto-detect latest report
if [ -z "$REPORT_DIR" ]; then
  REPORT_DIR=$(ls -dt docs/testing/reports/*/ 2>/dev/null | head -1)
fi
if [ -z "$REPORT_DIR" ] || [ ! -d "$REPORT_DIR" ]; then
  echo "ERROR: No report directory found. Run tests first or pass --report-dir."
  exit 1
fi

SCREENSHOTS_DIR="$REPORT_DIR/screenshots"
if [ ! -d "$SCREENSHOTS_DIR" ]; then
  echo "ERROR: No screenshots directory in $REPORT_DIR"
  exit 1
fi

mkdir -p "$BASELINE_DIR"

echo ">>> Updating baselines from: $SCREENSHOTS_DIR"
echo ">>> Baseline dir: $BASELINE_DIR"

UPDATED=0
SKIPPED=0

for png in "$SCREENSHOTS_DIR"/*.png; do
  [ -f "$png" ] || continue
  filename=$(basename "$png")
  screen_name="${filename%.png}"

  if [ -n "$SCREEN_FILTER" ] && [ "$screen_name" != "$SCREEN_FILTER" ]; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  dest="$BASELINE_DIR/$filename"
  if [ -f "$dest" ]; then
    # Show diff summary before overwriting
    echo "  Updating: $filename"
  else
    echo "  Adding:   $filename (new baseline)"
  fi

  cp "$png" "$dest"
  UPDATED=$((UPDATED + 1))
done

echo ""
echo ">>> Updated: $UPDATED  Skipped: $SKIPPED"
echo ""
echo ">>> Next steps:"
echo "    1. Review the changes: git diff --stat docs/testing/baseline-screenshots/"
echo "    2. Stage and commit: git add docs/testing/baseline-screenshots/ && git commit -m 'chore: update visual regression baselines'"
