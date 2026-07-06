#!/usr/bin/env bash
# PreToolUse (Edit|Write) ガード:
# cwd が .git-wt worktree 内のとき、対象パスが親リポジトリ側（worktree 外）なら deny する。
# サブエージェントが返す本体チェックアウトの絶対パスをそのまま Edit して main を汚染する事故の防止。
set -u

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"

# worktree 外で作業中なら何もしない
case "$cwd" in
  */.git-wt/*) ;;
  *) exit 0 ;;
esac

file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file" ] && exit 0

parent="${cwd%%/.git-wt/*}"

case "$file" in
  "$parent"/.git-wt/*) exit 0 ;;
  "$parent"/*)
    jq -n --arg reason "worktree（${cwd}）の外＝本体チェックアウト側への書き込みです: ${file}。worktree 配下のパスに読み替えてください。" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
    exit 0 ;;
  *) exit 0 ;;
esac
