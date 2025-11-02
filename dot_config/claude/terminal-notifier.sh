#!/bin/sh

# プロジェクト名を取得
PROJECT_NAME=$(basename "$PWD")

# 詳細な通知を送信
terminal-notifier \
    -title "🤖 Claude Code" \
    -subtitle "プロジェクト: $PROJECT_NAME" \
    -message "処理が完了しました" \
    -sound "Blow" \
    -group "claude-code-completion"
