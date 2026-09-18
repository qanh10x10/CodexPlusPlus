#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

MANAGER="target/release/codex-plus-plus-manager"
if [[ ! -x "$MANAGER" && ! -f "$MANAGER" ]]; then
  echo "Chua build. Chay ./setup.sh truoc."
  exit 1
fi

chmod +x "$MANAGER" 2>/dev/null || true
exec "$MANAGER"
