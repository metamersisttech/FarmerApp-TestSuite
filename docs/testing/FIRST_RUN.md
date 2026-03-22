# First Run Guide — FarmerApp Test Suite

Step-by-step instructions to get from zero to running UI tests on a real device or emulator.

---

## Prerequisites

| Tool | Minimum Version | Check Command |
|------|----------------|---------------|
| Java JDK | 17 | `java -version` |
| Android SDK / ADB | API 33+ | `adb --version` |
| Node.js | 18+ (optional, for some scripts) | `node --version` |
| Python | 3.9+ | `python3 --version` |
| Flutter SDK | 3.32.0 | `flutter --version` |

---

## Step 1 — Clone the test repo

```bash
git clone https://github.com/metamersisttech/FarmerApp-TestSuite.git
cd FarmerApp-TestSuite
```

---

## Step 2 — Run the one-command setup

**Linux / macOS:**
```bash
chmod +x setup.sh
./setup.sh
source ~/.bashrc   # or source ~/.zshrc on macOS
```

**Windows (PowerShell as Administrator):**
```bat
setup.bat
```

This installs: Java 17, ADB, Maestro 1.40.0, Python venv, ffmpeg, Flutter 3.32.0.

---

## Step 3 — Create your test credentials file

```bash
cp .env.test.example .env.test
```

Edit `.env.test`:

```env
FARMERAPP_TEST_PHONE=91XXXXXXXXXX    # 10-digit mobile, prefixed with 91
FARMERAPP_TEST_OTP=123456            # fixed OTP (see BACKEND_TEST_MODE.md)
ANTHROPIC_API_KEY=sk-ant-...         # optional, for AI triage
```

> **Important:** `.env.test` is git-ignored and never committed.

---

## Step 4 — Connect a device

**Option A — Physical Android device:**
1. Enable **Developer Options** → **USB Debugging** on your phone
2. Connect via USB
3. Accept the "Allow USB Debugging" prompt on the phone
4. Verify: `adb devices` should show your device serial

**Option B — Android Emulator:**
```bash
# List available AVDs
emulator -list-avds

# Start an emulator (replace Pixel_6_API_33 with your AVD name)
emulator -avd Pixel_6_API_33 &

# Wait ~30s then verify
adb devices
```

Recommended emulator spec: **Pixel 6, API 33, x86_64**, 4GB RAM, 8GB storage.

---

## Step 5 — Install the FarmerApp APK

You need a debug APK of FarmerApp. Options:

**Option A — Build from source:**
```bash
# In the FarmerApp source repo:
flutter build apk --debug
# Then install:
adb install build/app/outputs/flutter-apk/app-debug.apk
```

**Option B — Install a pre-built APK:**
```bash
make install-apk APK=path/to/farmerapp-debug.apk
```

Verify the app is installed:
```bash
adb shell pm list packages | grep com.example.flutter_app
```

---

## Step 6 — Configure Firebase (CI only, skip for local runs)

For local testing the app uses the Firebase config already embedded in the APK.

For CI builds that compile from source, add the base64 secret:
```bash
# Encode your google-services.json for GitHub Secrets:
./scripts/setup_firebase_key.sh encode android/app/google-services.json
# Paste the output into GitHub → Settings → Secrets → GOOGLE_SERVICES_JSON_B64
```

---

## Step 7 — Run smoke tests

```bash
make smoke
```

This runs the 5 smoke flows in `maestro/flows/00_smoke/`. If all pass, your device and Maestro are configured correctly.

---

## Step 8 — Run the full suite

```bash
make test
```

Or a specific feature:
```bash
make feature f=06_appointments
```

---

## Step 9 — View the report

After a test run:
```bash
make report
```

Opens `docs/testing/reports/<latest>/report.html` in your default browser.

---

## Step 10 — Set up baselines for visual regression

After your first successful full run, promote the screenshots as baselines:
```bash
./scripts/update_baseline.sh
git add docs/testing/baseline-screenshots/
git commit -m "chore: add initial visual regression baselines"
```

Future runs will compare against these baselines with `make visual-diff`.

---

## Troubleshooting

### `adb devices` shows "unauthorized"
- Unlock the phone and tap **Allow** on the USB debugging dialog.

### Maestro can't find the app
- Make sure the APK is installed: `adb shell pm list packages | grep flutter_app`
- Check the `appId` in `maestro/config.yaml` matches your build: `com.example.flutter_app`

### OTP login fails
- Configure your Django backend to accept a fixed test OTP.
  See [BACKEND_TEST_MODE.md](BACKEND_TEST_MODE.md).

### Emulator is too slow
- Enable hardware acceleration (HAXM on Intel, WHPX on Windows, Hypervisor on macOS).
- Use an x86_64 image, not ARM.
- Allocate at least 4GB RAM to the AVD.

### Maestro version mismatch
```bash
maestro --version        # should be 1.40.0
curl -fsSL "https://get.maestro.mobile.dev" | bash  # reinstall
```
