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

tmp_dir="${TMPDIR:-/tmp}"
tmp_file="${tmp_dir%/}/raycast-note-$(date +%Y%m%d%H%M%S).md"
target_app_file="${tmp_dir%/}/quick-note-target-app"

# 空ファイルを作成して初期ハッシュを固定
: > "$tmp_file"
initial_hash="$(shasum -a 256 "$tmp_file" | awk '{print $1}')"

# 前面アプリを記録
front_app="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')"
echo "$front_app" > "$target_app_file"

# Ghostty を起動して nvim を開く
/Applications/Ghostty.app/Contents/MacOS/ghostty -e zsh -i -c "
nvim '$tmp_file'
final_hash=\"\$(shasum -a 256 '$tmp_file' | awk '{print \$1}')\"
if [ \"\$final_hash\" != '$initial_hash' ] && [ -s '$tmp_file' ]; then
  cat '$tmp_file' | pbcopy
  osascript -e 'tell application \"$front_app\" to activate'
  osascript -e 'tell application \"System Events\" to keystroke \"v\" using command down'
fi
"
