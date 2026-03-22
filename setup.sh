#!/usr/bin/env bash
# =============================================================================
#   FarmerApp Test Suite — One-Command Environment Setup
#   =====================================================
#   Works on: Ubuntu 20.04+, macOS 12+, Debian/Raspberry Pi
#
#   Usage:
#     chmod +x setup.sh
#     ./setup.sh
#
#   What this installs:
#     1. Java 17          — required by Maestro
#     2. Android ADB      — device communication
#     3. Maestro          — mobile UI test runner (pinned version)
#     4. Python 3 + venv  — report generation
#     5. ffmpeg           — video processing
#     6. Flutter SDK      — running unit/widget/integration tests
#     7. Python packages  — lxml, jinja2, pillow, anthropic, requests
#
#   After setup run:
#     make smoke          — 5 smoke tests
#     make test           — full test suite
#     make report         — generate HTML report
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; exit 1; }
section() { echo -e "\n${BOLD}═══ $* ═══${RESET}\n"; }

# ── Constants ─────────────────────────────────────────────────────────────────
MAESTRO_VERSION="1.40.0"
FLUTTER_VERSION="3.32.0"
JAVA_MIN_VERSION=17
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"

# ── Detect OS ─────────────────────────────────────────────────────────────────
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &>/dev/null; then
      OS="ubuntu"
    elif command -v yum &>/dev/null; then
      OS="centos"
    else
      OS="linux"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  else
    error "Unsupported OS: $OSTYPE. Use setup.bat on Windows."
  fi
  info "Detected OS: $OS"
}

# ── Check if command exists ───────────────────────────────────────────────────
has() { command -v "$1" &>/dev/null; }

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   🌾 FarmerApp Test Suite Setup            ║${RESET}"
echo -e "${BOLD}╚════════════════════════════════════════════╝${RESET}"
echo ""

detect_os

# =============================================================================
# STEP 1 — Java 17
# =============================================================================
section "STEP 1: Java 17"

install_java_ubuntu() {
  info "Installing OpenJDK 17..."
  sudo apt-get update -qq
  sudo apt-get install -y openjdk-17-jdk
  # Set as default if multiple versions
  sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 2>/dev/null || true
}

install_java_macos() {
  if ! has brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install --cask temurin@17 2>/dev/null || brew install --cask temurin 2>/dev/null || true
}

if has java; then
  JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
  if [ "${JAVA_VER:-0}" -ge "$JAVA_MIN_VERSION" ] 2>/dev/null; then
    success "Java $JAVA_VER already installed"
  else
    warn "Java $JAVA_VER found but need $JAVA_MIN_VERSION+. Upgrading..."
    [ "$OS" = "ubuntu" ] && install_java_ubuntu
    [ "$OS" = "macos" ]  && install_java_macos
  fi
else
  [ "$OS" = "ubuntu" ] && install_java_ubuntu
  [ "$OS" = "macos" ]  && install_java_macos
fi

# Export JAVA_HOME
JAVA_HOME_CANDIDATE=$(java -XshowSettings:properties -version 2>&1 | \
  grep "java.home" | awk '{print $3}' | head -1)
if [ -n "${JAVA_HOME_CANDIDATE:-}" ]; then
  export JAVA_HOME="$JAVA_HOME_CANDIDATE"
  info "JAVA_HOME: $JAVA_HOME"
fi

java -version 2>&1 | head -1
success "Java OK"

# =============================================================================
# STEP 2 — Android ADB
# =============================================================================
section "STEP 2: Android Debug Bridge (ADB)"

install_adb_ubuntu() {
  sudo apt-get install -y android-tools-adb
}

install_adb_macos() {
  brew install android-platform-tools
}

if has adb; then
  success "ADB already installed: $(adb version | head -1)"
else
  info "Installing ADB..."
  [ "$OS" = "ubuntu" ] && install_adb_ubuntu
  [ "$OS" = "macos" ]  && install_adb_macos
  success "ADB installed: $(adb version | head -1)"
fi

# =============================================================================
# STEP 3 — Maestro
# =============================================================================
section "STEP 3: Maestro $MAESTRO_VERSION"

MAESTRO_BIN="$HOME/.maestro/bin/maestro"

install_maestro() {
  info "Downloading and installing Maestro $MAESTRO_VERSION..."
  export MAESTRO_VERSION
  curl -Ls "https://get.maestro.mobile.dev" | bash
  export PATH="$HOME/.maestro/bin:$PATH"
}

if [ -f "$MAESTRO_BIN" ]; then
  CURRENT_MAESTRO=$("$MAESTRO_BIN" --version 2>/dev/null || echo "unknown")
  success "Maestro already installed: $CURRENT_MAESTRO"
else
  install_maestro
fi

# Persist PATH for maestro
MAESTRO_PATH_LINE='export PATH="$HOME/.maestro/bin:$PATH"'
SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "\.maestro/bin" "$SHELL_RC" 2>/dev/null; then
  echo "$MAESTRO_PATH_LINE" >> "$SHELL_RC"
  info "Added Maestro to $SHELL_RC"
fi

export PATH="$HOME/.maestro/bin:$PATH"
maestro --version && success "Maestro OK" || warn "Maestro not found in PATH — restart shell after setup"

# =============================================================================
# STEP 4 — Python 3 + Virtual Environment
# =============================================================================
section "STEP 4: Python 3 + Virtual Environment"

install_python_ubuntu() {
  sudo apt-get install -y python3 python3-pip python3-venv
}

install_python_macos() {
  brew install python3
}

if has python3; then
  success "Python3 found: $(python3 --version)"
else
  info "Installing Python 3..."
  [ "$OS" = "ubuntu" ] && install_python_ubuntu
  [ "$OS" = "macos" ]  && install_python_macos
fi

# Create virtual environment
if [ ! -d "$VENV_DIR" ]; then
  info "Creating Python virtual environment at $VENV_DIR..."
  python3 -m venv "$VENV_DIR"
fi

# Activate and install packages
source "$VENV_DIR/bin/activate"
info "Installing Python packages..."
pip install --quiet --upgrade pip
pip install --quiet \
  lxml \
  jinja2 \
  pillow \
  anthropic \
  requests \
  pytest-html

success "Python packages installed"
deactivate

# =============================================================================
# STEP 5 — ffmpeg
# =============================================================================
section "STEP 5: ffmpeg (video processing)"

install_ffmpeg_ubuntu() { sudo apt-get install -y ffmpeg; }
install_ffmpeg_macos()  { brew install ffmpeg; }

if has ffmpeg; then
  success "ffmpeg already installed: $(ffmpeg -version 2>&1 | head -1)"
else
  info "Installing ffmpeg..."
  [ "$OS" = "ubuntu" ] && install_ffmpeg_ubuntu
  [ "$OS" = "macos" ]  && install_ffmpeg_macos
  success "ffmpeg installed"
fi

# =============================================================================
# STEP 6 — Flutter SDK
# =============================================================================
section "STEP 6: Flutter SDK"

FLUTTER_DIR="$HOME/flutter"

install_flutter() {
  info "Downloading Flutter $FLUTTER_VERSION..."
  if [ "$OS" = "macos" ]; then
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${FLUTTER_VERSION}-stable.zip"
  else
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  fi

  TMPFILE=$(mktemp)
  curl -L -o "$TMPFILE" "$FLUTTER_URL"

  mkdir -p "$HOME"
  if [[ "$FLUTTER_URL" == *.zip ]]; then
    unzip -q "$TMPFILE" -d "$HOME"
  else
    tar xf "$TMPFILE" -C "$HOME"
  fi
  rm "$TMPFILE"

  export PATH="$FLUTTER_DIR/bin:$PATH"
}

if has flutter; then
  success "Flutter found: $(flutter --version | head -1)"
else
  if [ -f "$FLUTTER_DIR/bin/flutter" ]; then
    export PATH="$FLUTTER_DIR/bin:$PATH"
    success "Flutter found at $FLUTTER_DIR"
  else
    install_flutter
  fi
fi

# Persist Flutter PATH
FLUTTER_PATH_LINE='export PATH="$HOME/flutter/bin:$PATH"'
if ! grep -q "flutter/bin" "$SHELL_RC" 2>/dev/null; then
  echo "$FLUTTER_PATH_LINE" >> "$SHELL_RC"
  info "Added Flutter to $SHELL_RC"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Accept Android licenses non-interactively
info "Accepting Android SDK licenses..."
yes | flutter doctor --android-licenses 2>/dev/null | tail -3 || true

flutter pub get --directory "$SCRIPT_DIR" 2>&1 | tail -3 || warn "flutter pub get had warnings"
success "Flutter OK"

# =============================================================================
# STEP 7 — .env.test setup
# =============================================================================
section "STEP 7: Test Credentials"

ENV_FILE="$SCRIPT_DIR/.env.test"
ENV_EXAMPLE="$SCRIPT_DIR/.env.test.example"

if [ ! -f "$ENV_FILE" ]; then
  if [ -f "$ENV_EXAMPLE" ]; then
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    warn ".env.test created from template."
    warn "Edit $ENV_FILE and fill in:"
    warn "  FARMERAPP_TEST_PHONE — test account phone number"
    warn "  FARMERAPP_TEST_OTP   — fixed OTP (configure backend to accept)"
  fi
else
  success ".env.test already exists"
fi

# =============================================================================
# STEP 8 — Make scripts executable
# =============================================================================
section "STEP 8: Permissions"

chmod +x "$SCRIPT_DIR/scripts/"*.sh 2>/dev/null || true
chmod +x "$SCRIPT_DIR/setup.sh"
success "Scripts are executable"

# =============================================================================
# STEP 9 — Verify device connection
# =============================================================================
section "STEP 9: Android Device Check"

adb start-server 2>/dev/null || true
DEVICE_COUNT=$(adb devices | grep -c "device$" || true)
if [ "$DEVICE_COUNT" -gt 0 ]; then
  success "$DEVICE_COUNT device(s) connected:"
  adb devices | grep "device$"
else
  warn "No Android device/emulator detected."
  warn "Connect a device with USB debugging enabled, OR start an emulator:"
  warn "  emulator -avd <avd_name> &"
fi

# =============================================================================
# DONE
# =============================================================================
echo ""
echo -e "${BOLD}╔════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   ✅  Setup Complete!                       ║${RESET}"
echo -e "${BOLD}╚════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${YELLOW}Edit .env.test${RESET} — fill in test phone + OTP"
echo -e "  2. ${YELLOW}Connect device${RESET} (USB debugging) or start emulator"
echo -e "  3. ${YELLOW}Build APK${RESET}:"
echo -e "     flutter build apk --debug"
echo -e "     adb install build/app/outputs/flutter-apk/app-debug.apk"
echo -e ""
echo -e "  4. ${GREEN}make smoke${RESET}          — run 5 smoke tests"
echo -e "     ${GREEN}make test${RESET}           — run full suite"
echo -e "     ${GREEN}make flutter-test${RESET}   — run unit/widget tests"
echo -e "     ${GREEN}make report${RESET}         — open latest HTML report"
echo ""
echo -e "  Restart your shell or run:  source $SHELL_RC"
echo ""
