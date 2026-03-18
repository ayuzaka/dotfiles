#!/bin/bash
# grep → rg (flags are mostly compatible)
# find → block (fd has a different flag system, rewrite manually)
# rm   → block (trash has a different flag system, rewrite manually)

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

[ -z "$cmd" ] && exit 0

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

# convert grep → rg
new_cmd=$(echo "$cmd" | sed 's/\bgrep\b/rg/g')

if [ "$cmd" != "$new_cmd" ]; then
  jq -n --arg cmd "$new_cmd" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":$cmd}}}'
fi
