#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Quick Note
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Quick Note

# Documentation:
# @raycast.author ayuzaka
# @raycast.authorURL https://raycast.com/ayuzaka

# Alacritty が既に起動していればフォーカス、なければ新規起動
tmp_dir="${TMPDIR:-/tmp}"
tmp_file="${tmp_dir%/}/raycast-note-$(date +%Y%m%d%H%M%S).md"

if pgrep -x "alacritty" > /dev/null; then
  osascript -e 'tell application "Alacritty" to activate'
else
  alacritty -e zsh -i -c "nvim \"$tmp_file\""
fi
