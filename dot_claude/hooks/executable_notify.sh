#!/usr/bin/env bash
set -euo pipefail

message=$(jq -r '.message // "Claude Code"')

terminal-notifier \
  -title "Claude Code" \
  -message "$message"
