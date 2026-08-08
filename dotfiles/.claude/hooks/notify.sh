#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
message=$(echo "$input" | jq -r '.message // "Claude Code"')
cwd=$(echo "$input" | jq -r '.cwd // ""')

project=""
if [[ -n "$cwd" ]]; then
  ghq_root=$(ghq root 2>/dev/null || true)
  toplevel=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

  # worktree の場合 toplevel が .git-wt/ 以下になるため、本来のリポジトリルートに戻す
  [[ "$toplevel" == *"/.git-wt/"* ]] && toplevel="${toplevel%%/.git-wt/*}"

  if [[ -n "$ghq_root" && -n "$toplevel" && "$toplevel" == "$ghq_root"/* ]]; then
    ghq_rel="${toplevel#"$ghq_root"/}"
    org_repo="${ghq_rel#*/}"  # host 部分を除去して org/repo 形式に
    project="$org_repo"
  elif [[ -n "$toplevel" ]]; then
    project=$(basename "$toplevel")
  else
    project=$(basename "$cwd")
  fi

  [[ -n "$branch" && "$branch" != "HEAD" ]] && project="$project - $branch"
fi

args=(-title "Claude Code" -message "$message")
[[ -n "$project" ]] && args+=(-subtitle "$project")

terminal-notifier "${args[@]}"
