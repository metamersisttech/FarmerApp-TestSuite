#!/usr/bin/env bash
# run_regression.sh — Full regression suite for release validation
# Usage: ./scripts/run_regression.sh [--device <serial>] [--tag <release_tag>]
#
# Runs all 12 feature folders + 99_regression in sequence, captures video,
# generates a timestamped report, and exits non-zero if any flow fails.

set -euo pipefail

DEVICE=""
TAG="release-$(date +%Y%m%d-%H%M%S)"
REPORT_DIR="docs/testing/reports/$TAG"
JUNIT_FILE="$REPORT_DIR/results.xml"
LOG_FILE="$REPORT_DIR/maestro.log"
VIDEO_FILE="$REPORT_DIR/regression.mp4"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) DEVICE="$2"; shift 2 ;;
    --tag)    TAG="$2";    shift 2 ;;
    *)        echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Auto-detect device
if [ -z "$DEVICE" ]; then
  DEVICE=$(adb devices | awk 'NR==2{print $1}')
fi
if [ -z "$DEVICE" ]; then
  echo "ERROR: No ADB device found."
  exit 1
fi

mkdir -p "$REPORT_DIR"
echo ">>> Regression run: $TAG"
echo ">>> Device: $DEVICE"
echo ">>> Report: $REPORT_DIR"

# Load test credentials
if [ -f ".env.test" ]; then
  set -a; source .env.test; set +a
fi

# Start screen recording
adb -s "$DEVICE" shell screenrecord --time-limit 1800 /sdcard/regression.mp4 &
RECORD_PID=$!
trap "kill $RECORD_PID 2>/dev/null || true; adb -s \"$DEVICE\" pull /sdcard/regression.mp4 \"$VIDEO_FILE\" 2>/dev/null || true" EXIT

# Start logcat
adb -s "$DEVICE" logcat -c
adb -s "$DEVICE" logcat -v threadtime > "$REPORT_DIR/logcat.log" &
LOGCAT_PID=$!
trap "kill $LOGCAT_PID $RECORD_PID 2>/dev/null || true; adb -s \"$DEVICE\" pull /sdcard/regression.mp4 \"$VIDEO_FILE\" 2>/dev/null || true" EXIT

echo ""
echo ">>> Running full Maestro suite..."

FLOW_DIRS=(
  maestro/flows/00_smoke
  maestro/flows/01_auth
  maestro/flows/02_home
  maestro/flows/03_listings
  maestro/flows/04_transport
  maestro/flows/05_messaging
  maestro/flows/06_appointments
  maestro/flows/07_bidding
  maestro/flows/08_vet
  maestro/flows/09_profile
  maestro/flows/10_search
  maestro/flows/11_language
  maestro/flows/12_settings
  maestro/flows/99_regression
)

PASS=0; FAIL=0

for dir in "${FLOW_DIRS[@]}"; do
  folder_name=$(basename "$dir")
  echo "  Running: $folder_name"
  if maestro test "$dir" \
      --device "$DEVICE" \
      --format junit \
      --output "$REPORT_DIR/junit_${folder_name}.xml" \
      --env FARMERAPP_TEST_PHONE="${FARMERAPP_TEST_PHONE:-}" \
      --env FARMERAPP_TEST_OTP="${FARMERAPP_TEST_OTP:-}" \
      --screenshots-dir "$REPORT_DIR/screenshots" \
      >> "$LOG_FILE" 2>&1; then
    echo "    PASS"
    PASS=$((PASS + 1))
  else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
  fi
done

# Stop captures
kill $LOGCAT_PID $RECORD_PID 2>/dev/null || true
sleep 2
adb -s "$DEVICE" pull /sdcard/regression.mp4 "$VIDEO_FILE" 2>/dev/null || true

echo ""
echo ">>> Results: $PASS passed, $FAIL failed"

# Merge JUnit XMLs into one
python3 - <<'PYEOF'
import os, glob, xml.etree.ElementTree as ET

report_dir = os.environ.get("REPORT_DIR", "docs/testing/reports")
# find latest dir if env not set
if not os.path.isdir(report_dir):
    dirs = sorted(glob.glob("docs/testing/reports/release-*"))
    report_dir = dirs[-1] if dirs else "."

suite_root = ET.Element("testsuites")
for f in sorted(glob.glob(os.path.join(report_dir, "junit_*.xml"))):
    try:
        tree = ET.parse(f)
        suite_root.append(tree.getroot())
    except Exception:
        pass

ET.ElementTree(suite_root).write(
    os.path.join(report_dir, "results_all.xml"),
    encoding="unicode",
    xml_declaration=True,
)
print(f"Merged JUnit XML → {report_dir}/results_all.xml")
PYEOF

# Generate HTML report
REPORT_DIR="$REPORT_DIR" python3 scripts/generate_report.py \
  --junit "$REPORT_DIR/results_all.xml" \
  --screenshots "$REPORT_DIR/screenshots" \
  --output "$REPORT_DIR/regression_report.html" || true

echo ""
echo ">>> Report: $REPORT_DIR/regression_report.html"
echo ">>> Video:  $VIDEO_FILE"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
