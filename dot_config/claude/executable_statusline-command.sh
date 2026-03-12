#!/usr/bin/env bash

GRAY=$'\033[38;2;74;88;92m'
RESET=$'\033[0m'

CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360

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

get_usage_data() {
  local cached_data=""
  if [ -f "$CACHE_FILE" ]; then
    local mod_time current_time
    cached_data=$(cat "$CACHE_FILE" 2>/dev/null || true)
    mod_time=$(stat -f %m "$CACHE_FILE" 2>/dev/null)
    current_time=$(date +%s)
    [ $((current_time - mod_time)) -lt $CACHE_TTL ] && {
      [ -n "$cached_data" ] && printf '%s\n' "$cached_data"
      return
    }
  fi

  local credentials access_token response service_name
  local -a service_candidates=(
    "Claude Code-credentials"
    "Claude Code credentials"
  )

  for service_name in "${service_candidates[@]}"; do
    credentials=$(security find-generic-password -s "$service_name" -w 2>/dev/null) || continue
    access_token=$(echo "$credentials" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    [ -n "$access_token" ] && break
  done

  if [ -z "$access_token" ]; then
    while IFS= read -r service_name; do
      credentials=$(security find-generic-password -s "$service_name" -w 2>/dev/null) || continue
      access_token=$(echo "$credentials" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
      [ -n "$access_token" ] && break
    done < <(
      security dump-keychain 2>/dev/null \
        | grep -Eo '"[^"]+"' \
        | tr -d '"' \
        | grep -Ei 'claude.*credential|credential.*claude' \
        | sort -u
    )
  fi

  if [ -z "$access_token" ]; then
    [ -n "$cached_data" ] && { printf '%s\n' "$cached_data"; return; }
    return 1
  fi

  response=$(curl -sf --max-time 5 \
    -H "Authorization: Bearer ${access_token}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || return 1

  echo "$response" | jq -e '.five_hour.utilization, .seven_day.utilization' >/dev/null 2>&1 || {
    [ -n "$cached_data" ] && { printf '%s\n' "$cached_data"; return; }
    return 1
  }

  echo "$response" > "$CACHE_FILE"
  echo "$response"
}

format_reset_time() {
  local resets_at="$1"
  local today reset_date reset_time display_date normalized_at
  normalized_at="${resets_at%%.*}Z"
  local epoch
  epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%SZ" "$normalized_at" "+%s" 2>/dev/null) || return
  today=$(TZ=Asia/Tokyo date "+%m/%d")
  reset_date=$(TZ=Asia/Tokyo date -r "$epoch" "+%m/%d" 2>/dev/null) || return
  reset_time=$(TZ=Asia/Tokyo date -r "$epoch" "+%H:%M" 2>/dev/null)
  if [ "$today" = "$reset_date" ]; then
    echo "(🔄 ${reset_time})"
  else
    display_date="${reset_date#0}"
    echo "(🔄 ${display_date} ${reset_time})"
  fi
}

read -r input_json

model=$(echo "$input_json" | jq -r '.model.display_name // "Sonnet 4.6"')
context_usage=$(echo "$input_json" | jq -r '.context_window.used_percentage // 0' | xargs printf "%.0f")
added_lines=$(echo "$input_json" | jq -r '.cost.total_lines_added // 0')
removed_lines=$(echo "$input_json" | jq -r '.cost.total_lines_removed // 0')
branch=$(git -C "$PWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

context_color=$(get_color "$context_usage")
printf "%s🤖 %s%s %s│%s %s📊 %s%%%s %s│%s ✏️  +%s/-%s %s│%s 🌿 %s" \
  "$context_color" "$model" "$RESET" \
  "$GRAY" "$RESET" \
  "$context_color" "$context_usage" "$RESET" \
  "$GRAY" "$RESET" \
  "$added_lines" "$removed_lines" \
  "$GRAY" "$RESET" \
  "$branch"

usage_data=$(get_usage_data 2>/dev/null)
if [ -n "$usage_data" ]; then
  five_h=$(echo "$usage_data" | jq -r '.five_hour.utilization // 0' | xargs printf "%.0f")
  seven_d=$(echo "$usage_data" | jq -r '.seven_day.utilization // 0' | xargs printf "%.0f")
  five_h_resets=$(echo "$usage_data" | jq -r '.five_hour.resets_at // ""')
  seven_d_resets=$(echo "$usage_data" | jq -r '.seven_day.resets_at // ""')
  five_h_reset_str=$(format_reset_time "$five_h_resets")
  seven_d_reset_str=$(format_reset_time "$seven_d_resets")
  five_h_color=$(get_color "$five_h")
  seven_d_color=$(get_color "$seven_d")
  printf " %s│%s %sCurrent session: %s%%%s %s %s│%s %sCurrent week: %s%%%s %s" \
    "$GRAY" "$RESET" \
    "$five_h_color" "$five_h" "$RESET" "$five_h_reset_str" \
    "$GRAY" "$RESET" \
    "$seven_d_color" "$seven_d" "$RESET" "$seven_d_reset_str"
fi

printf "\n"
