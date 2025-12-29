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

# Alacritty を新規起動して nvim を開く
tmp_dir="${TMPDIR:-/tmp}"
tmp_file="${tmp_dir%/}/raycast-note-$(date +%Y%m%d%H%M%S).md"

# 空ファイルを作成して初期ハッシュを固定（未編集や :q! はペーストをスキップするため）
: > "$tmp_file"
initial_hash="$(shasum -a 256 "$tmp_file" | awk '{print $1}')"

# 起動前に前面アプリを記録（nvim 終了後に戻してペーストするため）
front_app="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')"
tmp_script="${tmp_dir%/}/raycast-note-$(date +%Y%m%d%H%M%S).sh"

# Alacritty から実行する一時スクリプトを作成
cat > "$tmp_script" <<EOF
#!/bin/bash

# nvim を開いて編集
nvim "$tmp_file"

# 変更があり、かつ空でないときだけクリップボードへコピー&元アプリにペースト
final_hash="\$(shasum -a 256 "$tmp_file" | awk '{print \$1}')"
if [ "\$final_hash" != "$initial_hash" ] && [ -s "$tmp_file" ]; then
  cat "$tmp_file" | pbcopy
  osascript -e 'tell application "$front_app" to activate'
  osascript -e 'tell application "System Events" to keystroke "v" using command down'
fi
EOF

chmod +x "$tmp_script"

alacritty -e zsh -i -c "$tmp_script"
