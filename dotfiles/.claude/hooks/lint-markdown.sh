#!/usr/bin/env bash
set -euo pipefail

file_path=$(jq -r '.tool_input.file_path // empty')

if ! textlint_output=$(textlint-ja "$file_path" 2>&1); then
  echo "[textlint-ja]" >&2
  echo "$textlint_output" >&2
  exit 2
fi
