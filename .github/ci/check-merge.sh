#!/usr/bin/env bash
# Run merge-codex-config. The unit test calls merge_tables and does not execute run.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
cd "$repo"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "merge-codex-config file mode check expects Linux stat" >&2
  exit 1
fi

cargo build --locked --manifest-path scripts/merge-codex-config/Cargo.toml
bin="$repo/scripts/merge-codex-config/target/debug/merge-codex-config"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
target="$tmp/config.toml"
cat >"$target" <<'EOF'
model = "old-model"

[projects."/private/project"]
trust_level = "trusted"

[marketplaces.example]
last_updated = "2020-01-01T00:00:00Z"
last_revision = "kept-revision"
source = "https://example.com/original.git"

[tui]
model_availability_nux = "seen"
EOF
chmod 644 "$target"

set +e
"$bin" --check --target "$target" >"$tmp/check.out" 2>"$tmp/check.err"
check_status=$?
set -e
if [[ "$check_status" -ne 1 ]]; then
  echo "expected --check to exit 1 before the merge, got ${check_status}" >&2
  cat "$tmp/check.err" >&2
  exit 1
fi

ln -s "$target" "$tmp/link.toml"
set +e
"$bin" --target "$tmp/link.toml" >"$tmp/link.out" 2>"$tmp/link.err"
link_status=$?
set -e
if [[ "$link_status" -ne 2 ]]; then
  echo "expected a symlink target to exit 2, got ${link_status}" >&2
  cat "$tmp/link.err" >&2
  exit 1
fi
if ! grep -q 'refusing to replace symlink' "$tmp/link.err"; then
  echo "symlink refusal did not explain itself" >&2
  cat "$tmp/link.err" >&2
  exit 1
fi

"$bin" --target "$target"
mode=$(stat -c '%a' "$target")
if [[ "$mode" != "600" ]]; then
  echo "merged config mode is ${mode}, expected 600" >&2
  exit 1
fi

python3 - "$target" "$repo/extras/codex/config.toml" <<'PY'
import pathlib, sys, tomllib

merged = tomllib.loads(pathlib.Path(sys.argv[1]).read_text())
desired = tomllib.loads(pathlib.Path(sys.argv[2]).read_text())
if merged["model"] != desired["model"]:
    sys.exit(f"model is {merged['model']!r}, desired {desired['model']!r}")
project = merged["projects"]["/private/project"]
if project["trust_level"] != "trusted":
    sys.exit("unmanaged project trust was dropped")
marketplace = merged["marketplaces"]["example"]
if marketplace["last_updated"] != "2020-01-01T00:00:00Z":
    sys.exit("marketplace last_updated was overwritten")
if marketplace["last_revision"] != "kept-revision":
    sys.exit("marketplace last_revision was overwritten")
if merged["tui"]["model_availability_nux"] != "seen":
    sys.exit("Codex tui state was overwritten")
PY

"$bin" --check --target "$target"
echo "merge-codex-config run passed"
