#!/usr/bin/env bash

GRAY=$'\033[38;2;74;88;92m'
RESET=$'\033[0m'

get_color() {
  local usage=$1
  if [ "$usage" -lt 50 ]; then
    printf '%s' $'\033[38;2;151;201;195m'
  elif [ "$usage" -lt 80 ]; then
    printf '%s' $'\033[38;2;229;192;123m'
  else
    printf '%s' $'\033[38;2;224;108;117m'
  fi
}

read -r input_json

model=$(echo "$input_json" | jq -r '.model.display_name // "Sonnet 4.6"')
context_usage=$(echo "$input_json" | jq -r '.context_window.used_percentage // 0' | xargs printf "%.0f")
added_lines=$(echo "$input_json" | jq -r '.cost.total_lines_added // 0')
removed_lines=$(echo "$input_json" | jq -r '.cost.total_lines_removed // 0')
branch=$(git -C "$PWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

context_color=$(get_color "$context_usage")
printf "%s🤖 %s%s %s│%s %s📊 %s%%%s %s│%s ✏️  +%s/-%s %s│%s 🌿 %s\n" \
  "$context_color" "$model" "$RESET" \
  "$GRAY" "$RESET" \
  "$context_color" "$context_usage" "$RESET" \
  "$GRAY" "$RESET" \
  "$added_lines" "$removed_lines" \
  "$GRAY" "$RESET" \
  "$branch"
