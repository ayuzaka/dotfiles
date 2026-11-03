#!/usr/bin/env bash
# Parse committed JSON that is not a Tera template.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
cd "$repo"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

count=0
while IFS= read -r -d '' file; do
  case "$file" in
  templates/*) continue ;;
  esac
  jq empty "$file"
  count=$((count + 1))
done < <(git ls-files -z '*.json')

if ((count == 0)); then
  echo "no JSON files found" >&2
  exit 1
fi

echo "parsed ${count} JSON files"
