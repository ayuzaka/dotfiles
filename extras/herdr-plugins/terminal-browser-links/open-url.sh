#!/usr/bin/env bash
# Open a Ctrl-clicked herdr URL in terminal-browser (right split).
set -euo pipefail

url="${HERDR_PLUGIN_CLICKED_URL:-}"
if [[ -z "$url" ]]; then
  echo "missing HERDR_PLUGIN_CLICKED_URL" >&2
  exit 1
fi

if ! command -v terminal-browser >/dev/null 2>&1; then
  echo "terminal-browser is not installed — see https://github.com/zenbu-labs/terminal-browser" >&2
  exit 1
fi

exec terminal-browser open --split right "$url"
