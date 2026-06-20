#!/bin/bash
# Shared PreToolUse hook for Claude Code / Codex / OpenCode-compatible agents
# grep → rg (flags are mostly compatible)
# find → block (fd has a different flag system, rewrite manually)
# rm   → block (trash has a different flag system, rewrite manually)

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

# block find
if echo "$cmd" | grep -qE '\bfind\b'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"find is not allowed. Use fd instead. Example: fd -e sh . (instead of find . -name \"*.sh\" -type f)"}}'
  exit 0
fi

# block rm
if echo "$cmd" | grep -qE '\brm\b'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"rm is not allowed. Use trash instead. Example: trash file.txt (instead of rm file.txt)"}}'
  exit 0
fi

# block git push
if echo "$cmd" | grep -qE '\bgit push\b'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git push is not allowed."}}'
  exit 0
fi

# block git reset --hard
if echo "$cmd" | grep -qE '\bgit reset --hard\b'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git reset --hard is not allowed."}}'
  exit 0
fi

# block git clean
if echo "$cmd" | grep -qE '\bgit clean -f\b'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git clean is not allowed."}}'
  exit 0
fi

# block git branch -D
if echo "$cmd" | grep -qE '\bgit branch -D\b'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git branch -D is not allowed."}}'
  exit 0
fi

# block git checkout .
if echo "$cmd" | grep -qE '\bgit checkout \.'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git checkout . is not allowed."}}'
  exit 0
fi

# block git restore .
if echo "$cmd" | grep -qE '\bgit restore \.'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git restore . is not allowed."}}'
  exit 0
fi

# convert grep → rg
# shellcheck disable=SC2001
new_cmd=$(echo "$cmd" | sed 's/\bgrep\b/rg/g')

if [ "$cmd" != "$new_cmd" ]; then
  jq -n --arg cmd "$new_cmd" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","updatedInput":{"command":$cmd}}}'
  exit 0
fi
