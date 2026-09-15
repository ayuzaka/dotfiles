#!/usr/bin/env bash
set -u

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

# --body/-b lets prose skip the .md write step, so lint-markdown.sh, the
# PostToolUse hook on Write for Markdown files, never sees it. Force
# --body-file so textlint-ja still runs.
if echo "$cmd" | grep -qE -- '(^|[[:space:]])(-b|--body)([[:space:]=]|$)'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"本文は -b/--body で直接渡さず、Writeツールで .md ファイルに書いて textlint を通してから --body-file/-F で渡すこと"}}'
  exit 0
fi
