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

alacritty -e zsh -i -c "nvim /tmp/raycast-note.md"
