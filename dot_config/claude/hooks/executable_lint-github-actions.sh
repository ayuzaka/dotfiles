#!/usr/bin/env bash
set -euo pipefail

file_path=$(jq -r '.tool_input.file_path // empty')

case "$file_path" in
  */.github/workflows/*.yml | */.github/workflows/*.yaml) ;;
  *) exit 0 ;;
esac

errors=""

if ! actionlint_output=$(actionlint "$file_path" 2>&1); then
  errors+="[actionlint]"$'\n'"$actionlint_output"$'\n\n'
fi

if ! zizmor_output=$(zizmor "$file_path" 2>&1); then
  errors+="[zizmor]"$'\n'"$zizmor_output"$'\n'
fi

if [[ -n "$errors" ]]; then
  echo "$errors" >&2
  exit 2
fi
