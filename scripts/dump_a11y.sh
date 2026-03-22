#!/usr/bin/env bash
# dump_a11y.sh — Capture UIAutomator accessibility XML for all major screens
# Usage: ./scripts/dump_a11y.sh [output_dir]
#
# Navigates to each major screen via adb am start / Maestro tap, then
# dumps the view hierarchy XML. Output is passed to check_accessibility.py.

set -euo pipefail

DEVICE=$(adb devices | awk 'NR==2{print $1}')
if [ -z "$DEVICE" ]; then
  echo "ERROR: No ADB device found. Connect a device or start an emulator."
  exit 1
fi

OUTPUT_DIR="${1:-docs/testing/a11y-dumps}"
mkdir -p "$OUTPUT_DIR"

PACKAGE="com.example.flutter_app"

echo ">>> Device: $DEVICE"
echo ">>> Output: $OUTPUT_DIR"

dump_screen() {
  local screen_name="$1"
  echo "  Dumping: $screen_name"
  adb -s "$DEVICE" shell uiautomator dump /sdcard/ui_dump.xml 2>/dev/null || true
  adb -s "$DEVICE" pull /sdcard/ui_dump.xml "$OUTPUT_DIR/${screen_name}.xml" 2>/dev/null || true
  sleep 1
}

wait_stable() {
  sleep "${1:-3}"
}

# Launch app fresh
adb -s "$DEVICE" shell am force-stop "$PACKAGE"
sleep 1
adb -s "$DEVICE" shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
wait_stable 4
dump_screen "00_language_screen"

# Run Maestro login helper to get past login
if command -v maestro &>/dev/null; then
  maestro test maestro/helpers/login_helper.yaml \
    --env FARMERAPP_TEST_PHONE="${FARMERAPP_TEST_PHONE:-}" \
    --env FARMERAPP_TEST_OTP="${FARMERAPP_TEST_OTP:-}" \
    >/dev/null 2>&1 || true
fi
wait_stable 4
dump_screen "01_home_screen"

echo ""
echo ">>> Running accessibility checks..."
if [ -d ".venv" ]; then
  .venv/bin/python3 scripts/check_accessibility.py "$OUTPUT_DIR" \
    --output "$OUTPUT_DIR/a11y_report.txt" 2>/dev/null || \
  python3 scripts/check_accessibility.py "$OUTPUT_DIR" \
    --output "$OUTPUT_DIR/a11y_report.txt"
else
  python3 scripts/check_accessibility.py "$OUTPUT_DIR" \
    --output "$OUTPUT_DIR/a11y_report.txt"
fi

echo ""
echo ">>> A11y dump complete. Results in: $OUTPUT_DIR/a11y_report.txt"
