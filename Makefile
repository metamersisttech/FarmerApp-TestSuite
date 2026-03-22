# =============================================================================
#   FarmerApp Test Suite — Makefile
#   =================================
#   Usage:
#     make setup         — run full environment setup
#     make smoke         — run 5 smoke tests (< 5 min)
#     make test          — run all Maestro UI flows
#     make feature f=04_transport — run a specific feature folder
#     make flutter-test  — run unit + widget tests
#     make integration   — run Flutter integration tests on device
#     make report        — open the latest HTML report
#     make a11y          — run accessibility checks
#     make visual-diff   — compare screenshots to baselines
#     make triage        — send latest report to Claude for analysis
#     make build-apk     — build debug APK
#     make install-apk   — install latest debug APK on device
#     make clean-reports — delete old reports (keep last 5)
# =============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help
.PHONY: help setup smoke test feature flutter-test integration report a11y visual-diff triage build-apk install-apk clean-reports

# ── Config ────────────────────────────────────────────────────────────────────
APK_PATH := build/app/outputs/flutter-apk/app-debug.apk
REPORTS_DIR := docs/testing/reports
SCRIPTS_DIR := scripts
VENV := .venv/bin/python3

# ── Latest report directory helper ───────────────────────────────────────────
LATEST_REPORT := $(shell ls -td $(REPORTS_DIR)/*/ 2>/dev/null | head -1)

# =============================================================================
help: ## Show this help
	@echo ""
	@echo "  🌾 FarmerApp Test Suite"
	@echo "  ─────────────────────────────────────────"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# =============================================================================
setup: ## Run one-command environment setup (Linux/macOS)
	@chmod +x setup.sh
	@./setup.sh

# =============================================================================
build-apk: ## Build debug APK for testing
	@echo "▶ Building debug APK..."
	@flutter build apk --debug
	@echo "✅ APK: $(APK_PATH)"

# =============================================================================
install-apk: ## Install latest debug APK on connected device
	@echo "▶ Installing APK..."
	@adb install -r $(APK_PATH)
	@echo "✅ APK installed"

# =============================================================================
smoke: ## Run 5 smoke tests (< 5 min) — quick sanity check
	@echo "▶ Running smoke tests..."
	@chmod +x $(SCRIPTS_DIR)/run_smoke.sh
	@$(SCRIPTS_DIR)/run_smoke.sh

# =============================================================================
test: ## Run all Maestro UI flows (full suite)
	@echo "▶ Running full test suite..."
	@chmod +x $(SCRIPTS_DIR)/run_all.sh
	@$(SCRIPTS_DIR)/run_all.sh

# =============================================================================
feature: ## Run a specific feature folder: make feature f=04_transport
	@if [ -z "$(f)" ]; then \
	  echo "Usage: make feature f=<folder_name>"; \
	  echo "Example: make feature f=04_transport"; \
	  exit 1; \
	fi
	@echo "▶ Running feature: $(f)"
	@chmod +x $(SCRIPTS_DIR)/run_feature.sh
	@$(SCRIPTS_DIR)/run_feature.sh "$(f)"

# =============================================================================
flutter-test: ## Run all Flutter unit + widget tests
	@echo "▶ Running Flutter unit/widget tests..."
	@flutter test --reporter compact

# =============================================================================
flutter-test-verbose: ## Run Flutter tests with verbose output
	@flutter test --reporter expanded

# =============================================================================
integration: ## Run Flutter integration tests on connected device
	@echo "▶ Running integration tests on device..."
	@DEVICE=$$(adb devices | awk 'NR>1 && $$2=="device" {print $$1; exit}'); \
	 if [ -z "$$DEVICE" ]; then \
	   echo "❌ No device found. Connect a device or start an emulator."; \
	   exit 1; \
	 fi; \
	 flutter test integration_test/app_test.dart \
	   --device-id="$$DEVICE" \
	   --reporter compact

# =============================================================================
report: ## Open the latest HTML test report
	@if [ -z "$(LATEST_REPORT)" ]; then \
	  echo "No reports found. Run: make smoke"; \
	  exit 1; \
	fi
	@echo "📂 Latest report: $(LATEST_REPORT)report.html"
	@if command -v xdg-open &>/dev/null; then \
	  xdg-open "$(LATEST_REPORT)report.html"; \
	elif command -v open &>/dev/null; then \
	  open "$(LATEST_REPORT)report.html"; \
	else \
	  echo "Open in browser: file://$(CURDIR)/$(LATEST_REPORT)report.html"; \
	fi

# =============================================================================
a11y: ## Run accessibility checks on latest UI dumps
	@echo "▶ Running accessibility checks..."
	@mkdir -p docs/testing/a11y
	@adb shell uiautomator dump /sdcard/ui_current.xml 2>/dev/null && \
	 adb pull /sdcard/ui_current.xml docs/testing/a11y/ 2>/dev/null || \
	 echo "⚠️  Could not dump UI — is app running?"
	@$(VENV) $(SCRIPTS_DIR)/check_accessibility.py docs/testing/a11y/

# =============================================================================
visual-diff: ## Compare latest screenshots to approved baselines
	@if [ -z "$(LATEST_REPORT)" ]; then \
	  echo "No reports found. Run: make smoke first"; \
	  exit 1; \
	fi
	@echo "▶ Running visual regression check..."
	@$(VENV) $(SCRIPTS_DIR)/visual_diff.py "$(LATEST_REPORT)screenshots"

# =============================================================================
approve-baseline: ## Approve current screenshots as new baseline
	@if [ -z "$(LATEST_REPORT)" ]; then \
	  echo "No reports found. Run: make smoke first"; \
	  exit 1; \
	fi
	@mkdir -p docs/testing/baseline-screenshots
	@cp $(LATEST_REPORT)screenshots/*.png docs/testing/baseline-screenshots/ 2>/dev/null && \
	 echo "✅ Baseline updated from $(LATEST_REPORT)" || \
	 echo "⚠️  No screenshots to copy"

# =============================================================================
triage: ## Send latest report to Claude AI for root-cause analysis
	@if [ -z "$(LATEST_REPORT)" ]; then \
	  echo "No reports found. Run: make smoke first"; \
	  exit 1; \
	fi
	@if [ -z "$$ANTHROPIC_API_KEY" ]; then \
	  echo "❌ Set ANTHROPIC_API_KEY environment variable first"; \
	  exit 1; \
	fi
	@echo "🤖 Sending report to Claude for triage..."
	@$(VENV) $(SCRIPTS_DIR)/claude_triage.py "$(LATEST_REPORT)"

# =============================================================================
clean-reports: ## Delete old reports, keep last 5
	@echo "▶ Cleaning old reports..."
	@ls -td $(REPORTS_DIR)/*/ 2>/dev/null | tail -n +6 | xargs rm -rf && \
	 echo "✅ Old reports cleaned" || echo "Nothing to clean"

# =============================================================================
devices: ## List connected Android devices
	@adb devices

# =============================================================================
logcat: ## Stream live logcat from connected device (Flutter filter)
	@adb logcat -v time flutter:V AndroidRuntime:E '*:S'

# =============================================================================
check: ## Verify all tools are installed and working
	@echo "Checking tools..."
	@echo -n "  java      : "; java -version 2>&1 | head -1 || echo "❌ MISSING"
	@echo -n "  adb       : "; adb version 2>&1 | head -1 || echo "❌ MISSING"
	@echo -n "  maestro   : "; maestro --version 2>&1 || echo "❌ MISSING"
	@echo -n "  flutter   : "; flutter --version 2>&1 | head -1 || echo "❌ MISSING"
	@echo -n "  python3   : "; python3 --version 2>&1 || echo "❌ MISSING"
	@echo -n "  ffmpeg    : "; ffmpeg -version 2>&1 | head -1 || echo "❌ MISSING"
	@echo ""
	@echo "Devices:"
	@adb devices
