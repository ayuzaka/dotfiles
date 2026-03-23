#!/usr/bin/env bash
set -euo pipefail

current="$(git rev-parse HEAD)"
current_branch="$(git branch --show-current)"

best_branch=""
best_base=""

while IFS= read -r ref; do
  if [[ "$ref" == "$current_branch" ]]; then
    continue
  fi

  base="$(git merge-base "$current" "$ref")"

  if [[ -z "$best_base" ]]; then
    best_branch="$ref"
    best_base="$base"
    continue
  fi

  if git merge-base --is-ancestor "$best_base" "$base"; then
    best_branch="$ref"
    best_base="$base"
  fi
done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

echo "$best_branch"
