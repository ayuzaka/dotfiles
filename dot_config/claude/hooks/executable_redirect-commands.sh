#!/bin/bash
# Redirect grep→rg, find→fd, rm→trash

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

[ -z "$cmd" ] && exit 0

new_cmd=$(echo "$cmd" | sed 's/\bgrep\b/rg/g; s/\bfind\b/fd/g; s/\brm\b/trash/g')

if [ "$cmd" != "$new_cmd" ]; then
  jq -n --arg cmd "$new_cmd" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":$cmd}}}'
fi
