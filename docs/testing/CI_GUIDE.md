# CI/CD Guide — FarmerApp Test Suite

This document covers the CI/CD setup for FarmerApp across two repositories:

- **`metamersisttech/FarmerApp-TestSuite`** — Flutter unit/widget tests + Maestro UI tests
- **`metamersisttech/FarmerApp-Backend`** — Django backend API tests

---

## Workflows Overview

| Workflow | File | Trigger | Runner |
|----------|------|---------|--------|
| Unit & Widget Tests | `unit_tests.yml` | push/PR to `main`/`develop` | ubuntu-latest |
| Maestro UI Tests | `ui_tests.yml` | nightly 01:00 UTC + PR smoke + manual | macos-latest |
| Nightly Full Suite | `nightly_full_suite.yml` | nightly 02:00 UTC + manual | ubuntu + macos |
| Backend Tests | `backend_tests.yml` (FarmerApp-Backend) | push/PR to `main`/`develop`/`auth`/`features` | ubuntu-latest |

---

## Required Secrets

### FarmerApp-TestSuite repo secrets

| Secret | Description |
|--------|-------------|
| `GOOGLE_SERVICES_JSON_B64` | Base64-encoded `google-services.json` for Firebase |
| `FARMERAPP_TEST_PHONE` | Test user phone (e.g. `+919876543210`) |
| `FARMERAPP_TEST_OTP` | Fixed OTP enabled via `TEST_MODE_FIXED_OTP=123456` |
| `FARMERAPP_TEST_EMAIL` | Test user email |
| `FARMERAPP_TEST_PASSWORD` | Test user password |
| `GH_PAT` | GitHub PAT with `repo` scope (used by nightly suite to checkout backend) |

### FarmerApp-Backend repo secrets

| Secret | Description |
|--------|-------------|
| `SECRET_KEY` | Django secret key (set automatically by CI env block) |

> **Setting secrets:** Go to GitHub repo → Settings → Secrets and variables → Actions → New repository secret.

---

## How to Add `GOOGLE_SERVICES_JSON_B64`

```bash
# On your local machine:
base64 -w 0 android/app/google-services.json
# Copy the output → paste as the secret value
```

On macOS:
```bash
base64 -i android/app/google-services.json | pbcopy
```

---

## Running Tests Locally

### Flutter unit/widget tests

```bash
# All unit tests
flutter test test/unit/ --reporter compact

# All widget tests
flutter test test/widget/ --reporter compact

# Everything with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Maestro UI tests

```bash
# Smoke only (fast, ~5 min)
maestro test maestro/flows/00_smoke \
  --env FARMERAPP_TEST_PHONE=+919876543210 \
  --env FARMERAPP_TEST_OTP=123456

# Full suite
maestro test maestro/flows \
  --format junit --output results.xml \
  --screenshots-dir screenshots
```

### Django backend tests

```bash
cd FarmerApp-Backend

# Individual app
python manage.py test core.tests --verbosity=2
python manage.py test auth_app.tests --verbosity=2
python manage.py test listings.tests --verbosity=2
python manage.py test appointments.tests --verbosity=2

# All with coverage
pip install coverage
coverage run --source='.' manage.py test core auth_app listings appointments
coverage report --omit='*/migrations/*,*/tests.py,farmerApp/*'
coverage html -d htmlcov
```

---

## Unified Report

The nightly workflow generates `unified_report.html` — a Bootstrap dashboard aggregating all three test sources.

To generate locally:

```bash
# From FarmerApp-TestSuite root
python3 scripts/generate_unified_report.py \
  --maestro   results.xml \
  --flutter   flutter-results.xml \
  --backend   backend-results.xml \
  --coverage  coverage.xml \
  --output    unified_report.html \
  --summary   unified_summary.json
```

Output:
- `unified_report.html` — full HTML dashboard with per-suite tables, screenshots, coverage
- `unified_summary.json` — machine-readable totals for further automation

---

## Nightly Schedule

The `nightly_full_suite.yml` runs at **02:00 UTC** every day:

1. **Job: flutter-tests** (ubuntu-latest) — unit + widget tests with lcov coverage
2. **Job: backend-tests** (ubuntu-latest) — checks out FarmerApp-Backend, runs Django tests with coverage
3. **Job: ui-tests** (macos-latest) — full Maestro suite on Android emulator
4. **Job: unified-report** (ubuntu-latest) — downloads all artifacts, runs `generate_unified_report.py`, posts to GitHub Job Summary

### Manual trigger

```
GitHub → FarmerApp-TestSuite → Actions → Nightly Full Test Suite → Run workflow
```

Optional inputs:
- `skip_ui` — skip Maestro (faster, ~8 min vs ~60 min)
- `skip_flutter` — skip Flutter tests

---

## PR Comment Behavior

Every PR to `main` automatically receives a comment from CI:

**Backend PR (FarmerApp-Backend):**
```
✅ Backend Tests — PASS
| Tests Run | 71 |
| ✅ Passed | 71 |
| ❌ Failed | 0  |
| 📊 Line Coverage | 74% |
```

**Flutter PR (FarmerApp-TestSuite):**
```
✅ Flutter Unit & Widget Tests — PASS
| Total Tests | 92 |
| ✅ Passed   | 92 |
| ❌ Failed   | 0  |
| 📊 Coverage | 68.4% |
```

**UI Tests PR (smoke only):**
```
✅ UI Test Results — smoke
| Total Tests | 12 |
| ✅ Passed   | 12 |
| ❌ Failed   | 0  |
```

---

## Coverage Badges

README badges auto-update from CI workflow status:

**FarmerApp-TestSuite:**
```markdown
[![Unit & Widget Tests](https://github.com/metamersisttech/FarmerApp-TestSuite/actions/workflows/unit_tests.yml/badge.svg)](...)
[![Maestro UI Tests](https://github.com/metamersisttech/FarmerApp-TestSuite/actions/workflows/ui_tests.yml/badge.svg)](...)
[![Nightly Full Suite](https://github.com/metamersisttech/FarmerApp-TestSuite/actions/workflows/nightly_full_suite.yml/badge.svg)](...)
```

**FarmerApp-Backend:**
```markdown
[![Backend Tests](https://github.com/metamersisttech/FarmerApp-Backend/actions/workflows/backend_tests.yml/badge.svg)](...)
```

---

## Artifact Retention

| Artifact | Retention |
|----------|-----------|
| `backend-test-results-*` | Default (90 days) |
| `unit-test-results-*` | Default (90 days) |
| `ui-test-results-*` | Default (90 days) |
| `unified-test-report-*` | Default (90 days) |

Download artifacts from: GitHub → Actions → specific run → Artifacts section.

---

## Troubleshooting

### `google-services.json` decode error
Ensure the secret is pure base64 with no newlines:
```bash
base64 -w 0 android/app/google-services.json | wc -c   # should be > 0
```

### Django tests fail with `No module named 'farmerApp'`
Tests must be run from the repo root (where `manage.py` lives):
```bash
cd FarmerApp-Backend
python manage.py test core.tests
```

### Maestro: `ADB not found`
Maestro UI tests require `macos-latest` runner with Android emulator via `reactivecircus/android-emulator-runner@v2`. They cannot run on `ubuntu-latest` without KVM acceleration.

### Coverage XML not generated
Ensure `coverage` is installed and run from the project root:
```bash
pip install coverage
coverage run --source='.' manage.py test ...
coverage xml -o coverage.xml
```
