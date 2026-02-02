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
target_app_file="${tmp_dir%/}/quick-note-target-app"

# 前面アプリを記録
front_app="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')"
echo "$front_app" > "$target_app_file"

window_title="Quick Note → ${front_app}"

# 一時ファイルを作成
tmp_file="${tmp_dir%/}/raycast-note-$(date +%Y%m%d%H%M%S).md"
: > "$tmp_file"
initial_hash="$(shasum -a 256 "$tmp_file" | awk '{print $1}')"

# Ghostty を起動して nvim を開く（タイトルにターゲットアプリ名を表示）
/Applications/Ghostty.app/Contents/MacOS/ghostty --title="$window_title" -e zsh -i -c "
nvim '$tmp_file'
final_hash=\"\$(shasum -a 256 '$tmp_file' | awk '{print \$1}')\"
if [ \"\$final_hash\" != '$initial_hash' ] && [ -s '$tmp_file' ]; then
  cat '$tmp_file' | pbcopy
  osascript -e 'tell application \"$front_app\" to activate'
  osascript -e 'tell application \"System Events\" to keystroke \"v\" using command down'
fi
"
