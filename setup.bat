@echo off
REM =============================================================================
REM   FarmerApp Test Suite — Windows Setup Script
REM   =============================================
REM   Tested on: Windows 10/11 with Git Bash or PowerShell
REM
REM   Usage (run as Administrator):
REM     setup.bat
REM
REM   Installs:
REM     1. Chocolatey      — package manager
REM     2. Java 17         — required by Maestro
REM     3. ADB             — Android device bridge
REM     4. Maestro         — UI test runner
REM     5. Python 3        — report generation
REM     6. Flutter SDK     — unit/widget tests
REM     7. ffmpeg          — video processing
REM =============================================================================

setlocal EnableDelayedExpansion

echo.
echo ============================================
echo   FarmerApp Test Suite - Windows Setup
echo ============================================
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [ERROR] Please run this script as Administrator.
    echo Right-click setup.bat and choose "Run as administrator"
    pause
    exit /b 1
)

REM ── Step 1: Install Chocolatey ────────────────────────────────────────────
echo [STEP 1] Installing Chocolatey package manager...
where choco >nul 2>&1
if %errorLevel% EQU 0 (
    echo [OK]    Chocolatey already installed
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Set-ExecutionPolicy Bypass -Scope Process -Force; ^
       [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; ^
       iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    echo [OK]    Chocolatey installed
)

REM ── Step 2: Java 17 ───────────────────────────────────────────────────────
echo.
echo [STEP 2] Installing Java 17...
java -version >nul 2>&1
if %errorLevel% EQU 0 (
    echo [OK]    Java already installed
) else (
    choco install -y temurin17
    echo [OK]    Java 17 installed
)

REM ── Step 3: Android Platform Tools (ADB) ─────────────────────────────────
echo.
echo [STEP 3] Installing Android Platform Tools (ADB)...
where adb >nul 2>&1
if %errorLevel% EQU 0 (
    echo [OK]    ADB already installed
) else (
    choco install -y android-sdk
    echo [OK]    ADB installed
    echo [WARN]  You may need to restart your shell for PATH to update
)

REM ── Step 4: Maestro ───────────────────────────────────────────────────────
echo.
echo [STEP 4] Installing Maestro...
where maestro >nul 2>&1
if %errorLevel% EQU 0 (
    echo [OK]    Maestro already installed
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; ^
       iex ((New-Object System.Net.WebClient).DownloadString('https://get.maestro.mobile.dev'))"
    echo [OK]    Maestro installed
)

REM ── Step 5: Python 3 ──────────────────────────────────────────────────────
echo.
echo [STEP 5] Installing Python 3...
where python >nul 2>&1
if %errorLevel% EQU 0 (
    echo [OK]    Python already installed
) else (
    choco install -y python3
    refreshenv
    echo [OK]    Python 3 installed
)

REM Install Python packages
echo [INFO]  Installing Python packages...
python -m pip install --quiet --upgrade pip
python -m pip install --quiet lxml jinja2 pillow anthropic requests
echo [OK]    Python packages installed

REM ── Step 6: Flutter SDK ───────────────────────────────────────────────────
echo.
echo [STEP 6] Installing Flutter SDK...
where flutter >nul 2>&1
if %errorLevel% EQU 0 (
    echo [OK]    Flutter already installed
) else (
    choco install -y flutter
    refreshenv
    echo [OK]    Flutter installed
)

REM ── Step 7: ffmpeg ────────────────────────────────────────────────────────
echo.
echo [STEP 7] Installing ffmpeg...
where ffmpeg >nul 2>&1
if %errorLevel% EQU 0 (
    echo [OK]    ffmpeg already installed
) else (
    choco install -y ffmpeg
    echo [OK]    ffmpeg installed
)

REM ── Step 8: .env.test ─────────────────────────────────────────────────────
echo.
echo [STEP 8] Setting up test credentials...
if not exist ".env.test" (
    if exist ".env.test.example" (
        copy ".env.test.example" ".env.test" >nul
        echo [WARN]  .env.test created from template.
        echo [WARN]  Edit .env.test and fill in your test credentials!
    )
) else (
    echo [OK]    .env.test already exists
)

REM ── Step 9: Flutter pub get ───────────────────────────────────────────────
echo.
echo [STEP 9] Installing Flutter dependencies...
call flutter pub get
echo [OK]    Flutter dependencies installed

REM ── Step 10: Device check ─────────────────────────────────────────────────
echo.
echo [STEP 10] Checking for Android devices...
adb start-server >nul 2>&1
adb devices

echo.
echo ============================================
echo   Setup Complete!
echo ============================================
echo.
echo Next Steps:
echo   1. Edit .env.test with your test phone + OTP
echo   2. Connect Android device with USB debugging
echo      OR start an emulator
echo.
echo   3. Build APK:
echo      flutter build apk --debug
echo      adb install build\app\outputs\flutter-apk\app-debug.apk
echo.
echo   4. Run tests (in Git Bash):
echo      make smoke        -- 5 smoke tests
echo      make test         -- full test suite
echo      make flutter-test -- unit/widget tests
echo      make report       -- open latest HTML report
echo.
pause
