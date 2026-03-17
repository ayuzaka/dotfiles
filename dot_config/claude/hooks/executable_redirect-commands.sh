#!/bin/bash
# grep → rg に変換（フラグはほぼ互換）
# find → ブロック（fd はフラグ体系が異なるため手動で書き直す）
# rm   → ブロック（trash はフラグ体系が異なるため手動で書き直す）

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

[ -z "$cmd" ] && exit 0

# find はブロック
if echo "$cmd" | grep -qE '\bfind\b'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"find は使用禁止です。fd を使って書き直してください。例: fd -e sh . (find . -name \"*.sh\" -type f の代わり)"}}'
  exit 0
fi

# rm はブロック
if echo "$cmd" | grep -qE '\brm\b'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"rm は使用禁止です。trash を使って書き直してください。例: trash file.txt (rm file.txt の代わり)"}}'
  exit 0
fi

# grep → rg に変換
new_cmd=$(echo "$cmd" | sed 's/\bgrep\b/rg/g')

if [ "$cmd" != "$new_cmd" ]; then
  jq -n --arg cmd "$new_cmd" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":$cmd}}}'
fi
