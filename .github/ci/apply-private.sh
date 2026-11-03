#!/usr/bin/env bash
# Apply private dotfiles into a disposable HOME and check the rendered files.
# bootstrap dotfiles apply --dry-run does not render templates.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
cd "$repo"

if ! command -v mise >/dev/null 2>&1; then
  echo "mise is required" >&2
  exit 1
fi
mise_version=$(mise --version)
case "$mise_version" in
*2026.10.25*) ;;
*)
  echo "mise 2026.10.25 is required, found ${mise_version}" >&2
  exit 1
  ;;
esac

python_bin=""
for candidate in python3.13 python3.12 python3.11 python3; do
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import tomllib' >/dev/null 2>&1; then
    python_bin=$candidate
    break
  fi
done
if [[ -z "$python_bin" ]]; then
  echo "python 3.11 or newer is required to parse rendered TOML" >&2
  exit 1
fi

run_root=$(mktemp -d)
cleanup() {
  status=$?
  chmod -R u+w "$run_root" 2>/dev/null || true
  rm -rf "$run_root"
  exit "$status"
}
trap cleanup EXIT

export HOME="$run_root/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export CODEX_HOME="$HOME/.config/codex"
export MISE_ENV=private
mkdir -p "$HOME"

copy="$HOME/workspace/github.com/ayuzaka/dotfiles"
mkdir -p "$copy"
tar -C "$repo" \
  --exclude artifacts \
  --exclude scripts/merge-codex-config/target \
  --exclude .git \
  -cf - . | tar -C "$copy" -xf -
cat >"$copy/mise.local.toml" <<'EOF'
[env]
MISE_ENV = "private"
EOF

mise -C "$copy" trust -a --yes
mise -C "$copy" bootstrap dotfiles apply --force --yes

if [[ "$(uname -s)" == "Darwin" ]]; then
  if grep -q 'export MISE_ENV=' "$HOME/.bashrc"; then
    echo "macOS ~/.bashrc included the Linux bashrc body" >&2
    exit 1
  fi
  if ! grep -q 'orbstack/shell/init.zsh' "$HOME/.config/zsh/.zprofile"; then
    echo "macOS zprofile omitted the OrbStack line" >&2
    exit 1
  fi
  zsh -n "$HOME/.config/zsh/.zprofile"
  zsh -n "$HOME/.config/zsh/.zshrc"
else
  if ! grep -q 'export MISE_ENV="private"' "$HOME/.bashrc"; then
    echo "Linux bashrc did not export MISE_ENV=private" >&2
    exit 1
  fi
  bash -n "$HOME/.bashrc"
  if grep -q 'orbstack/shell/init.zsh' "$HOME/.config/zsh/.zprofile"; then
    echo "Linux zprofile included the macOS OrbStack block" >&2
    exit 1
  fi
fi

sh -n "$HOME/.config/op/plugins.sh"
if ! grep -q 'return "private"' "$HOME/.config/nvim/lua/config/purpose.lua"; then
  echo "purpose.lua did not render private" >&2
  exit 1
fi

selected=$("$python_bin" -c 'import json,sys; print(json.load(open(sys.argv[1]))["security"]["auth"]["selectedType"])' "$HOME/.gemini/settings.json")
if [[ "$selected" != "oauth-personal" ]]; then
  echo "gemini auth selectedType is ${selected}" >&2
  exit 1
fi

helpers=$(git config --file "$HOME/.config/git/config" --get-all credential.https://github.com.helper)
if ! grep -qx '!ghtkn git-credential' <<<"$helpers"; then
  echo "GitHub credential helper is not ghtkn" >&2
  echo "$helpers" >&2
  exit 1
fi
if grep -qx '!gh auth git-credential' <<<"$helpers"; then
  echo "private GitHub credential helper included the work helper" >&2
  exit 1
fi

"$python_bin" - "$HOME/.config/mise/conf.d/purpose.toml" <<'PY'
import pathlib, sys, tomllib

data = tomllib.loads(pathlib.Path(sys.argv[1]).read_text())
purpose = data.get("vars", {}).get("dotfiles_purpose")
if purpose != "private":
    sys.exit(f"purpose.toml dotfiles_purpose is {purpose!r}")
PY

theme_mode=$(tr -d '[:space:]' <"$repo/dotfiles/.config/theme")
case "$theme_mode" in
light) expected_theme="Everforest Light Med" ;;
*) expected_theme="Everforest Dark Hard" ;;
esac
theme="${XDG_CONFIG_HOME}/ghostty/theme"
if ! grep -q "theme = ${expected_theme}" "$theme"; then
  echo "ghostty theme did not follow dotfiles/.config/theme (${theme_mode})" >&2
  exit 1
fi

mise -C "$copy" bootstrap dotfiles status --missing
echo "private apply passed on $(uname -s)"
