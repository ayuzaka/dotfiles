#!/usr/bin/env bash
# Install the Neovim release used to run dotfiles/.config/nvim/tests.
set -euo pipefail

if [[ "$(uname -s)-$(uname -m)" != "Linux-x86_64" ]]; then
  echo "Neovim install supports Linux x86_64" >&2
  exit 1
fi

sum=474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87
dest=${1:-$HOME/.local}
mkdir -p "$dest/bin"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
archive="$tmpdir/nvim.tar.gz"
curl -fsSL -o "$archive" https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-x86_64.tar.gz

actual=$(sha256sum "$archive" | awk '{print $1}')
if [[ "$actual" != "$sum" ]]; then
  echo "neovim checksum mismatch: $actual" >&2
  exit 1
fi

rm -rf "$dest/nvim-linux-x86_64"
tar -xzf "$archive" -C "$dest"
ln -sfn "$dest/nvim-linux-x86_64/bin/nvim" "$dest/bin/nvim"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$dest/bin" >>"$GITHUB_PATH"
fi
