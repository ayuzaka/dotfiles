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
if pgrep -x "alacritty" > /dev/null; then
  osascript -e 'tell application "Alacritty" to activate'
else
  alacritty -e zsh -i -c "nvim /tmp/raycast-note.md"
fi
