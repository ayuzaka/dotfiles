#!/usr/bin/env bash
# Isolated harness for `mise bootstrap dotfiles` and the repo tasks that write
# through $HOME. Each launch copies this checkout under a fresh HOME. Cleanup
# deletes that copy and nothing else.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SOURCE_REPO=$(cd "$SCRIPT_DIR/../../../.." && pwd)
STATE_DIR="$SOURCE_REPO/artifacts/verify-dotfiles"

usage() {
  cat <<'EOF'
Usage:
  harness.sh launch
  harness.sh doctor [RUN_ID]
  harness.sh exec [RUN_ID] -- <mise args>
  harness.sh cleanup [RUN_ID]

`launch` prints KEY=value lines and writes them to
artifacts/verify-dotfiles/<RUN_ID>/run.env. `latest` points at that run.
Evidence written under that run's evidence/ directory is kept across cleanup.
EOF
}

real_home() {
  getent passwd "$(id -un)" | cut -d: -f6
}

quote_env() {
  local name="$1"
  local value="$2"
  printf '%s=%q\n' "$name" "$value"
}

read_mise_env() {
  python3 - "$1" <<'PY'
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text()
match = re.search(r'(?m)^MISE_ENV\s*=\s*"([^"]+)"\s*$', text)
if not match:
    sys.exit("mise.local.toml has no MISE_ENV = \"...\" assignment")
print(match.group(1), end="")
PY
}

load_run() {
  local id="${1:-latest}"
  local env_file="$STATE_DIR/$id/run.env"
  if [[ ! -f "$env_file" ]]; then
    echo "harness: no run env at $env_file; launch first" >&2
    exit 1
  fi
  # shellcheck disable=SC1090
  source "$env_file"
}

apply_isolated_env() {
  export HOME="$RUN_HOME"
  export XDG_CONFIG_HOME="$RUN_HOME/.config"
  export XDG_DATA_HOME="$RUN_HOME/.local/share"
  export XDG_STATE_HOME="$RUN_HOME/.local/state"
  export XDG_CACHE_HOME="$RUN_HOME/.cache"
  export CODEX_HOME="$RUN_HOME/.config/codex"
  export MISE_ENV
}

cmd_launch() {
  local run_id run_root run_home repo evidence
  run_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
  run_root=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-verify-${run_id}.XXXXXX")
  run_home="$run_root/home"
  repo="$run_home/workspace/github.com/ayuzaka/dotfiles"
  evidence="$STATE_DIR/$run_id/evidence"
  mkdir -p "$(dirname "$repo")" "$evidence"
  cp -a "$SOURCE_REPO/." "$repo/"
  rm -rf "$repo/artifacts" "$repo/scripts/merge-codex-config/target"
  if [[ ! -f "$repo/mise.local.toml" ]]; then
    cat > "$repo/mise.local.toml" <<'EOF'
# verification scaffolding: this isolated copy had no mise.local.toml.
# Cleanup deletes the copy. This file is not written to the source checkout.
[env]
MISE_ENV = "private"
EOF
  fi
  local mise_env
  mise_env=$(read_mise_env "$repo/mise.local.toml")
  {
    quote_env RUN_ID "$run_id"
    quote_env RUN_ROOT "$run_root"
    quote_env RUN_HOME "$run_home"
    quote_env REPO "$repo"
    quote_env SOURCE_REPO "$SOURCE_REPO"
    quote_env MISE_ENV "$mise_env"
    quote_env EVIDENCE "$evidence"
  } > "$STATE_DIR/$run_id/run.env"
  ln -sfn "$STATE_DIR/$run_id" "$STATE_DIR/latest"
  load_run "$run_id"
  apply_isolated_env
  mise -C "$REPO" trust -a --yes >&2
  cat "$STATE_DIR/$run_id/run.env"
}

cmd_doctor() {
  load_run "${1:-latest}"
  apply_isolated_env
  local real
  real=$(real_home)
  if [[ "$HOME" == "$real" ]]; then
    echo "doctor: HOME is the real user home ($real); refusing" >&2
    exit 1
  fi
  if [[ "$HOME" != "$RUN_HOME" ]]; then
    echo "doctor: HOME ($HOME) is not RUN_HOME ($RUN_HOME)" >&2
    exit 1
  fi
  if [[ "$XDG_CONFIG_HOME" != "$RUN_HOME/.config" \
    || "$XDG_DATA_HOME" != "$RUN_HOME/.local/share" \
    || "$XDG_STATE_HOME" != "$RUN_HOME/.local/state" \
    || "$XDG_CACHE_HOME" != "$RUN_HOME/.cache" \
    || "$CODEX_HOME" != "$RUN_HOME/.config/codex" ]]; then
    echo "doctor: XDG or CODEX_HOME escapes RUN_HOME" >&2
    exit 1
  fi
  if [[ "$REPO" == "$SOURCE_REPO" || ! -d "$REPO" ]]; then
    echo "doctor: REPO must be an isolated copy" >&2
    exit 1
  fi
  if [[ ! -f "$REPO/mise.local.toml" ]]; then
    echo "doctor: isolated copy has no mise.local.toml" >&2
    exit 1
  fi
  local parsed
  parsed=$(read_mise_env "$REPO/mise.local.toml")
  if [[ "$parsed" != "$MISE_ENV" ]]; then
    echo "doctor: MISE_ENV ($MISE_ENV) does not match mise.local.toml ($parsed)" >&2
    exit 1
  fi
  if [[ "$MISE_ENV" == "work" && ! -f "$REPO/private/git/work.gitconfig" ]]; then
    echo "doctor: MISE_ENV=work but private/git/work.gitconfig is missing, so templates/.config/git/config cannot render" >&2
    exit 1
  fi
  command -v mise >/dev/null
  command -v python3 >/dev/null
  local config_list
  config_list=$(mise -C "$REPO" config ls)
  if ! grep -F "mise.${MISE_ENV}.toml" <<<"$config_list" >/dev/null; then
    echo "doctor: mise did not load mise.${MISE_ENV}.toml" >&2
    echo "$config_list" >&2
    exit 1
  fi
  local ghostty="no"
  if command -v pgrep >/dev/null && pgrep -qf 'Ghostty.app' >/dev/null 2>&1; then
    ghostty="yes"
  fi
  printf 'doctor: ok\n'
  printf 'home=%s\n' "$HOME"
  printf 'mise_env=%s\n' "$MISE_ENV"
  printf 'mise_version=%s\n' "$(mise --version)"
  printf 'ghostty_running=%s\n' "$ghostty"
  printf 'repo=%s\n' "$REPO"
}

cmd_exec() {
  local run_id="latest"
  if [[ $# -gt 0 && "$1" != "--" ]]; then
    run_id="$1"
    shift
  fi
  if [[ "${1:-}" != "--" ]]; then
    echo "harness: exec needs -- before mise arguments" >&2
    exit 1
  fi
  shift
  load_run "$run_id"
  apply_isolated_env
  mise -C "$REPO" "$@"
}

cmd_cleanup() {
  load_run "${1:-latest}"
  if [[ -z "${RUN_ROOT:-}" || "$RUN_ROOT" != "${TMPDIR:-/tmp}/dotfiles-verify-"* ]]; then
    echo "harness: refusing to delete unexpected RUN_ROOT (${RUN_ROOT:-})" >&2
    exit 1
  fi
  # Go module caches created by `mise run` are mode 0555 and survive plain rm.
  chmod -R u+w "$RUN_ROOT" 2>/dev/null || true
  rm -rf "$RUN_ROOT"
  echo "cleaned $RUN_ROOT"
  echo "evidence remains at $EVIDENCE"
}

main() {
  local command="${1:-}"
  if [[ -z "$command" ]]; then
    usage >&2
    exit 1
  fi
  shift
  case "$command" in
    launch) cmd_launch "$@" ;;
    doctor) cmd_doctor "$@" ;;
    exec) cmd_exec "$@" ;;
    cleanup) cmd_cleanup "$@" ;;
    -h|--help|help) usage ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
