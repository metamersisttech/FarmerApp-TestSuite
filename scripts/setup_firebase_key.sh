#!/usr/bin/env bash
# =============================================================================
#   Firebase Key Setup Helper
#   ==========================
#   Use this script to:
#     1. Encode google-services.json for GitHub Secrets (one-time setup)
#     2. Decode it back locally from base64
#
#   Usage:
#     # Encode (run AFTER getting new google-services.json from Firebase Console):
#     ./scripts/setup_firebase_key.sh encode android/app/google-services.json
#
#     # Decode locally (if you have the base64 value):
#     ./scripts/setup_firebase_key.sh decode <base64_string>
# =============================================================================

set -euo pipefail

ACTION="${1:-help}"
FILE_OR_B64="${2:-}"

case "$ACTION" in

  encode)
    # ── Encode google-services.json → base64 for GitHub Secret ──────────────
    if [ -z "$FILE_OR_B64" ]; then
      echo "Usage: $0 encode <path/to/google-services.json>"
      exit 1
    fi
    if [ ! -f "$FILE_OR_B64" ]; then
      echo "❌ File not found: $FILE_OR_B64"
      exit 1
    fi
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Copy this value into GitHub Secret: GOOGLE_SERVICES_JSON_B64"
    echo "  Settings → Secrets → Actions → New repository secret"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    base64 -w 0 "$FILE_OR_B64"
    echo ""
    echo ""
    echo "✅ Done. The original file stays local — never commit it."
    ;;

  decode)
    # ── Decode base64 → google-services.json locally ────────────────────────
    if [ -z "$FILE_OR_B64" ]; then
      echo "Usage: $0 decode <base64_string>"
      echo "   OR: $0 decode  (reads from GOOGLE_SERVICES_JSON_B64 env var)"
      FILE_OR_B64="${GOOGLE_SERVICES_JSON_B64:-}"
    fi

    B64_VALUE="${FILE_OR_B64:-${GOOGLE_SERVICES_JSON_B64:-}}"
    if [ -z "$B64_VALUE" ]; then
      echo "❌ No base64 value provided."
      echo "   Set GOOGLE_SERVICES_JSON_B64 env var or pass value as argument."
      exit 1
    fi

    echo "$B64_VALUE" | base64 -d > android/app/google-services.json
    echo "✅ android/app/google-services.json restored (local only, gitignored)"
    ;;

  help|*)
    echo ""
    echo "Firebase Key Setup Helper"
    echo ""
    echo "Commands:"
    echo "  encode <file>   — encode google-services.json to base64 for GitHub Secret"
    echo "  decode <b64>    — decode base64 back to google-services.json locally"
    echo ""
    echo "One-time setup workflow:"
    echo "  1. Download new google-services.json from Firebase Console"
    echo "     → Project Settings → Your Apps → google-services.json"
    echo "  2. ./scripts/setup_firebase_key.sh encode android/app/google-services.json"
    echo "  3. Copy the output → GitHub: Settings → Secrets → GOOGLE_SERVICES_JSON_B64"
    echo "  4. The file stays in android/app/ locally (gitignored) and is"
    echo "     auto-injected by CI from the secret."
    ;;
esac
