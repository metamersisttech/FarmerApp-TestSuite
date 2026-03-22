#!/usr/bin/env bash
# Run a specific feature folder
# Usage: ./scripts/run_feature.sh 04_transport
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <feature_folder>"
  echo "Example: $0 04_transport"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/run_all.sh" "$1"
