#!/usr/bin/env bash
# Run the plenary specs. They load tests/minimal_init.lua, not the full config.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
cd "$repo"

if ! command -v nvim >/dev/null 2>&1; then
  echo "nvim is required" >&2
  exit 1
fi
if ! command -v timeout >/dev/null 2>&1; then
  echo "timeout is required" >&2
  exit 1
fi

commit=74b06c6c75e4eeb3108ec01852001636d85a932b
data=$(mktemp -d)
trap 'rm -rf "$data"' EXIT
export XDG_DATA_HOME="$data"
dest="$data/nvim/lazy/plenary.nvim"
mkdir -p "$(dirname "$dest")"
git init -q "$dest"
git -C "$dest" remote add origin https://github.com/nvim-lua/plenary.nvim.git
git -C "$dest" fetch -q --depth 1 origin "$commit"
git -C "$dest" checkout -q --detach FETCH_HEAD

timeout 120 nvim --headless \
  -u dotfiles/.config/nvim/tests/minimal_init.lua \
  -c "PlenaryBustedDirectory dotfiles/.config/nvim/tests { minimal_init = 'dotfiles/.config/nvim/tests/minimal_init.lua', sequential = true }"
