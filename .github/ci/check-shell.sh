#!/usr/bin/env bash
# Check tracked shell scripts, including those without a .sh suffix.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
cd "$repo"

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck is required" >&2
  exit 1
fi

files=()
while IFS= read -r -d '' file; do
  case "$file" in
  templates/*) continue ;;
  esac
  [[ -f "$file" ]] || continue
  shebang=$(head -n 1 "$file" || true)
  case "$shebang" in
  '#!'*'/bash' | '#!'*' bash' | '#!'*'/sh' | '#!'*' sh')
    files+=("$file")
    ;;
  esac
done < <(git ls-files -z)

if ((${#files[@]} == 0)); then
  echo "no shell scripts found" >&2
  exit 1
fi

shellcheck "${files[@]}"
echo "checked ${#files[@]} shell scripts"
