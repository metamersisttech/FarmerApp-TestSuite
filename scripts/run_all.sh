#!/usr/bin/env bash
# =============================================================================
# FarmerApp — Full UI Test Runner
# Usage: ./scripts/run_all.sh [flow_folder]
#   flow_folder: optional — run only this folder (e.g. 04_transport)
#   No arg = run all flows
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."

# Load test credentials
if [ -f "$ROOT/.env.test" ]; then
  set -a; source "$ROOT/.env.test"; set +a
else
  echo "⚠️  .env.test not found — copy .env.test.example and fill in credentials"
  exit 1
fi

# Defaults
FARMERAPP_TEST_PHONE="${FARMERAPP_TEST_PHONE:-}"
FARMERAPP_TEST_OTP="${FARMERAPP_TEST_OTP:-}"
FARMERAPP_TEST_EMAIL="${FARMERAPP_TEST_EMAIL:-}"
FARMERAPP_TEST_PASSWORD="${FARMERAPP_TEST_PASSWORD:-}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="$ROOT/docs/testing/reports/$TIMESTAMP"
mkdir -p "$REPORT_DIR/screenshots"

FLOW_PATH="$ROOT/maestro/flows"
if [ -n "${1:-}" ]; then
  FLOW_PATH="$ROOT/maestro/flows/$1"
  echo "▶ Running flow: $1"
else
  echo "▶ Running all flows"
fi

echo "📁 Report dir: $REPORT_DIR"

# ── Logcat capture ──────────────────────────────────────────────────────────
DEVICE_ID=$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')
if [ -z "$DEVICE_ID" ]; then
  echo "❌ No Android device/emulator found. Run: adb devices"
  exit 1
fi
echo "📱 Device: $DEVICE_ID"

adb -s "$DEVICE_ID" logcat -c
adb -s "$DEVICE_ID" logcat -v threadtime > "$REPORT_DIR/logcat.txt" &
LOGCAT_PID=$!

# ── Screen recording ─────────────────────────────────────────────────────────
adb -s "$DEVICE_ID" shell screenrecord /sdcard/farmerapp_test.mp4 &
RECORD_PID=$!

echo ""
echo "═══════════════════════════════════════════"
echo "  RUNNING MAESTRO FLOWS"
echo "═══════════════════════════════════════════"

# ── Run Maestro ───────────────────────────────────────────────────────────────
maestro test "$FLOW_PATH" \
  --format junit \
  --output "$REPORT_DIR/results.xml" \
  --screenshots-dir "$REPORT_DIR/screenshots" \
  --env FARMERAPP_TEST_PHONE="$FARMERAPP_TEST_PHONE" \
  --env FARMERAPP_TEST_OTP="$FARMERAPP_TEST_OTP" \
  --env FARMERAPP_TEST_EMAIL="$FARMERAPP_TEST_EMAIL" \
  --env FARMERAPP_TEST_PASSWORD="$FARMERAPP_TEST_PASSWORD" \
  2>&1 | tee "$REPORT_DIR/maestro.log"

MAESTRO_EXIT=${PIPESTATUS[0]}

# ── Cleanup capture processes ─────────────────────────────────────────────────
kill "$LOGCAT_PID" 2>/dev/null || true
kill "$RECORD_PID" 2>/dev/null || true
sleep 2

# Pull screen recording
adb -s "$DEVICE_ID" pull /sdcard/farmerapp_test.mp4 \
  "$REPORT_DIR/screen_recording.mp4" 2>/dev/null || echo "⚠️  Screen recording unavailable"

# ── Crash extraction ──────────────────────────────────────────────────────────
grep -E \
  "FATAL EXCEPTION|AndroidRuntime|ANR in|Skipped [0-9]+ frames|FlutterError|DartError|RenderFlex overflow|Null check operator" \
  "$REPORT_DIR/logcat.txt" > "$REPORT_DIR/crashes.txt" 2>/dev/null || true

CRASH_COUNT=$(wc -l < "$REPORT_DIR/crashes.txt" | tr -d ' ')

# ── HTML Report ───────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════"
echo "  GENERATING REPORT"
echo "═══════════════════════════════════════════"

if command -v python3 &>/dev/null; then
  python3 "$SCRIPT_DIR/generate_report.py" "$REPORT_DIR" || true
else
  echo "⚠️  python3 not found — skipping HTML report"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════"
echo "  TEST RUN COMPLETE"
echo "═══════════════════════════════════════════"
echo "  Report    : $REPORT_DIR/report.html"
echo "  Video     : $REPORT_DIR/screen_recording.mp4"
echo "  Crashes   : $CRASH_COUNT lines in crashes.txt"
echo ""

exit "$MAESTRO_EXIT"
