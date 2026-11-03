#!/usr/bin/env bash
# Install Rust 1.99.1. The merge tool uses edition 2024, which needs Rust 1.85 or newer.
set -euo pipefail

if [[ "$(uname -s)-$(uname -m)" != "Linux-x86_64" ]]; then
  echo "Rust install supports Linux x86_64" >&2
  exit 1
fi

sum=5be191e8c70a5007074254cb74d78dbfdd25cd5a61c27de7b8e5410122ec24f4
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
installer="$tmpdir/rustup-init"
curl -fsSL -o "$installer" https://static.rust-lang.org/rustup/archive/1.29.2/x86_64-unknown-linux-gnu/rustup-init

actual=$(sha256sum "$installer" | awk '{print $1}')
if [[ "$actual" != "$sum" ]]; then
  echo "rustup-init checksum mismatch: $actual" >&2
  exit 1
fi

chmod 755 "$installer"
# Keep this toolchain off the runner's own rustup, which can be older than edition 2024.
export CARGO_HOME="$HOME/.ci-cargo"
export RUSTUP_HOME="$HOME/.ci-rustup"
"$installer" -y --default-toolchain 1.99.1 --profile minimal --no-modify-path

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "CARGO_HOME=$CARGO_HOME" >>"$GITHUB_ENV"
  echo "RUSTUP_HOME=$RUSTUP_HOME" >>"$GITHUB_ENV"
fi
if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$CARGO_HOME/bin" >>"$GITHUB_PATH"
fi
