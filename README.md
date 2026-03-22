# 🌾 FarmerApp — Automated Test Suite

End-to-end automated testing for FarmerApp — a Flutter-based agricultural marketplace for Indian farmers.

---

## What's Inside

| Layer | Tool | Location |
|-------|------|----------|
| Unit & Widget Tests | Flutter `flutter_test` | `test/` |
| Integration Tests | Flutter `integration_test` | `integration_test/` |
| UI Flow Tests | Maestro YAML | `maestro/flows/` |
| Report Generator | Python | `scripts/generate_report.py` |
| Accessibility Checker | Python + uiautomator | `scripts/check_accessibility.py` |
| Visual Regression | Python + Pillow | `scripts/visual_diff.py` |
| AI Crash Triage | Claude API | `scripts/claude_triage.py` |
| CI/CD | GitHub Actions | `.github/workflows/` |

---

## Quick Start

### 1. One-Command Setup

**Linux / macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows (run as Administrator):**
```cmd
setup.bat
```

Installs: Java 17, ADB, Maestro, Python 3, Flutter, ffmpeg, and all Python packages.

### 2. Configure Test Credentials

```bash
cp .env.test.example .env.test
# Edit .env.test with your test phone number and OTP
```

### 3. Build & Install APK

```bash
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### 4. Run Tests

```bash
make check          # verify all tools installed
make smoke          # 5 smoke tests (< 5 min)
make flutter-test   # unit + widget tests
make test           # full Maestro UI suite
make report         # open HTML report in browser
```

---

## Maestro Flow Structure

```
maestro/flows/
├── 00_smoke/         5 flows  — app launch, language, login screen, crash check
├── 01_auth/          4 flows  — OTP login, invalid phone, email login, logout
├── 02_home/          2 flows  — bottom nav tabs, pull to refresh
├── 03_listings/      (Phase 2)
├── 04_transport/     2 flows  — book transport form, my bookings list
├── 05_messaging/     1 flow   — conversations list
├── 08_vet/           (Phase 2)
├── 09_profile/       1 flow   — view profile + settings
├── 10_search/        1 flow   — search animals
├── 11_language/      1 flow   — switch to Hindi and back
└── 99_regression/    (Phase 3 — full regression suite)
```

### Run a specific feature:
```bash
make feature f=04_transport
make feature f=00_smoke
```

---

## Available Make Commands

| Command | Description |
|---------|-------------|
| `make setup` | Run full environment setup |
| `make check` | Verify all tools are installed |
| `make smoke` | 5 smoke tests (< 5 min) |
| `make test` | Full UI test suite |
| `make feature f=<folder>` | Run one feature folder |
| `make flutter-test` | Unit + widget tests |
| `make integration` | Flutter integration tests on device |
| `make report` | Open latest HTML report |
| `make a11y` | Accessibility audit |
| `make visual-diff` | Visual regression check |
| `make approve-baseline` | Set current screenshots as baseline |
| `make triage` | Claude AI crash analysis |
| `make build-apk` | Build debug APK |
| `make install-apk` | Install APK on device |
| `make logcat` | Stream live device logs |
| `make clean-reports` | Delete old reports (keep last 5) |

---

## CI/CD

| Workflow | Trigger | What runs |
|----------|---------|-----------|
| `unit_tests.yml` | Every push / PR | All Flutter unit + widget tests |
| `ui_tests.yml` | PRs (smoke), nightly (full), manual | Maestro flows on Android emulator |

### GitHub Secrets Required

Add in: Settings → Secrets → Actions

| Secret | Description |
|--------|-------------|
| `FARMERAPP_TEST_PHONE` | Test account phone number |
| `FARMERAPP_TEST_OTP` | Fixed OTP for test account |
| `FARMERAPP_TEST_EMAIL` | Test email |
| `FARMERAPP_TEST_PASSWORD` | Test password |

---

## Report Structure

Each run creates a timestamped folder under `docs/testing/reports/`:

```
docs/testing/reports/20260322_143000/
├── results.xml          ← JUnit XML (CI consumption)
├── report.html          ← Bootstrap HTML with embedded screenshots
├── summary.json         ← Machine-readable pass/fail counts
├── maestro.log          ← Full Maestro output
├── logcat.txt           ← Android logcat
├── crashes.txt          ← Extracted FATAL/ANR/FlutterError lines
├── screen_recording.mp4 ← Full test run recording
├── screenshots/         ← Per-step screenshots
└── claude_triage.md     ← AI root-cause analysis (optional)
```

---

## Tech Stack

- **App**: Flutter 3 · Firebase · Django REST backend
- **Package**: `com.example.flutter_app`
- **Languages**: English, Hindi, Marathi, Punjabi
- **Features**: 26 features · 75 screens · 51 named routes
