#!/usr/bin/env bash
# Install the shellcheck release used for the repository shell scripts.
set -euo pipefail

if [[ "$(uname -s)-$(uname -m)" != "Linux-x86_64" ]]; then
  echo "shellcheck install supports Linux x86_64" >&2
  exit 1
fi

sum=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198
dest=${1:-$HOME/.local/bin}
mkdir -p "$dest"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
archive="$tmpdir/shellcheck.tar.xz"
curl -fsSL -o "$archive" https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.linux.x86_64.tar.xz

actual=$(sha256sum "$archive" | awk '{print $1}')
if [[ "$actual" != "$sum" ]]; then
  echo "shellcheck checksum mismatch: $actual" >&2
  exit 1
fi

tar -xJf "$archive" -C "$tmpdir"
install -m 755 "$tmpdir/shellcheck-v0.11.0/shellcheck" "$dest/shellcheck"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$dest" >>"$GITHUB_PATH"
fi
