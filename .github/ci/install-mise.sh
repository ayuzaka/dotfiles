#!/usr/bin/env bash
# Install the mise release this repository's apply check was written against.
set -euo pipefail

version=2026.10.25
dest=${1:-$HOME/.local/bin}
mkdir -p "$dest"

case "$(uname -s)-$(uname -m)" in
Linux-x86_64)
  asset="mise-v${version}-linux-x64.tar.gz"
  sum=199966edaad1b208eb4c72955f1722dafb8fa799f575db720dea05aaa8216546
  ;;
Darwin-arm64)
  asset="mise-v${version}-macos-arm64.tar.gz"
  sum=774236e3247e48d78078c0bce79e5327d4e4479f1a94c8487827f178197ee39b
  ;;
Darwin-x86_64)
  asset="mise-v${version}-macos-x64.tar.gz"
  sum=2b31afc1ef77c46bf9cb0837dba9366ad744f452343a0f8b00d3df1eef892f84
  ;;
*)
  echo "unsupported platform: $(uname -s)-$(uname -m)" >&2
  exit 1
  ;;
esac

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
archive="$tmpdir/mise.tar.gz"
curl -fsSL -o "$archive" "https://github.com/jdx/mise/releases/download/v${version}/${asset}"

actual=$(sha256sum "$archive" 2>/dev/null | awk '{print $1}' || true)
if [[ -z "$actual" ]]; then
  actual=$(shasum -a 256 "$archive" | awk '{print $1}')
fi
if [[ "$actual" != "$sum" ]]; then
  echo "mise checksum mismatch: $actual" >&2
  exit 1
fi

tar -xzf "$archive" -C "$tmpdir"
install -m 755 "$tmpdir/mise/bin/mise" "$dest/mise"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$dest" >>"$GITHUB_PATH"
fi
