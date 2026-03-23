#!/usr/bin/env bash
# PreToolUse hook for WebSearch: intercept and use Tavily API instead
set -euo pipefail

INPUT=$(cat)
QUERY=$(echo "$INPUT" | jq -r '.tool_input.query // ""')

if [ -z "$QUERY" ]; then
  exit 0
fi

if [ -z "${TAVILY_API_KEY:-}" ]; then
  # APIキーがなければ素通しして通常のWebSearchを使用
  exit 0
fi

RESPONSE=$(curl -sf -X POST "https://api.tavily.com/search" \
  -H "Content-Type: application/json" \
  -d "{\"api_key\": \"$TAVILY_API_KEY\", \"query\": \"$QUERY\", \"search_depth\": \"basic\", \"max_results\": 5}" \
  2>/dev/null) || exit 0

RESULTS=$(echo "$RESPONSE" | jq -r '
  .results[]? | "### \(.title)\nURL: \(.url)\n\(.content // .snippet // "")\n"
' 2>/dev/null)

if [ -z "$RESULTS" ]; then
  exit 0
fi

CONTEXT="Tavily検索結果（クエリ: ${QUERY}）:

${RESULTS}"

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Tavily APIで検索を実行しました",
    "additionalContext": $ctx
  }
}'
