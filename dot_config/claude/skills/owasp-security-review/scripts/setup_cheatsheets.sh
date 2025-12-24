#!/bin/bash
# Setup OWASP Cheat Sheet Series repository
# Usage: ./setup_cheatsheets.sh [target_directory]

set -euo pipefail

REPO="OWASP/CheatSheetSeries"
DEFAULT_DIR="${HOME}/.local/share/owasp-cheatsheets"
TARGET_DIR="${1:-$DEFAULT_DIR}"

if [ -d "$TARGET_DIR/.git" ]; then
    echo "Updating existing repository..."
    git -C "$TARGET_DIR" pull --ff-only
else
    echo "Cloning OWASP Cheat Sheet Series..."
    gh repo clone "$REPO" "$TARGET_DIR" -- --depth 1
fi

echo "Cheat sheets available at: $TARGET_DIR/cheatsheets"
echo "Done."
