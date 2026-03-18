#!/usr/bin/env bash
set -euo pipefail

file_path=$(jq -r '.tool_input.file_path // empty')

case "$file_path" in
  *.sh) ;;
  *) exit 0 ;;
esac

if ! shellcheck_output=$(shellcheck "$file_path" 2>&1); then
  echo "[shellcheck]" >&2
  echo "$shellcheck_output" >&2
  exit 2
fi
