#!/bin/bash
# Refresh brew plumbing list into Brewfile-friendly leaves dump (reference only).
# Source of truth for installs: mac/Brewfile
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
brew leaves > "${ROOT}/leaves"
# Casks are no longer used for daily apps; keep an empty/optional dump for awareness.
brew list --cask > "${ROOT}/casks" 2>/dev/null || true
echo "Updated ${ROOT}/leaves and ${ROOT}/casks"
echo "Edit mac/Brewfile to change what setup-mac.sh installs."
