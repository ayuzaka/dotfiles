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

# 同じターゲットアプリの Ghostty ウィンドウが既にあればフォーカスする
existing_window="$(osascript -e "
tell application \"System Events\"
  if exists (application process \"Ghostty\") then
    tell application process \"Ghostty\"
      repeat with w in windows
        if name of w starts with \"Quick Note → ${front_app}\" then
          return \"found\"
        end if
      end repeat
    end tell
  end if
  return \"\"
end tell
" 2>/dev/null)"

if [ "$existing_window" = "found" ]; then
  # 既存ウィンドウにフォーカス
  osascript -e "
  tell application \"System Events\"
    tell application process \"Ghostty\"
      repeat with w in windows
        if name of w starts with \"Quick Note → ${front_app}\" then
          perform action \"AXRaise\" of w
        end if
      end repeat
      set frontmost to true
    end tell
  end tell
  "
  exit 0
fi

# 新規: 一時ファイルを作成
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
