# Sync Codex config

Sync Codex config merges `extras/codex/config.toml` into the Codex config file, updates managed values, keeps project trust and Codex-owned marketplace state, and refuses to replace a symlink.

## Sub-features

- `sync-check` exits 1 when the target differs and exits 0 after a merge.
- `sync-merge` writes the managed model, leaves unmanaged keys in place, and sets mode `0600`.
- `sync-symlink` exits 2 and leaves the symlink in place.
- `sync-mise-run` is `mise run sync-codex-config` after dotfiles are applied. On a fresh home it installs tools before the task and is not proved by the cargo command.

## How to get to it (user POV)

- After dotfiles are applied, run `mise run sync-codex-config`. The task body is `cargo run --quiet --manifest-path "$HOME/workspace/github.com/ayuzaka/dotfiles/scripts/merge-codex-config/Cargo.toml" --`, which writes the default Codex path for that `HOME`.
- The binary also accepts `--check` and `--target PATH`.

## Driving it with verify-dotfiles

Preconditions:

- `harness.sh doctor` prints `doctor: ok`.
- `cargo metadata --manifest-path "$REPO/scripts/merge-codex-config/Cargo.toml" --no-deps --format-version 1` exits 0. Rust must accept `edition = "2024"`. The image default Rust `1.83` fails this; the repo's `rust = "latest"` satisfies it.
- For `sync-mise-run`, dotfiles are already applied and trusted in this `RUN_HOME`, and the tool install is expected to be able to finish. A fresh home does not meet that. Report the install failure instead of substituting the cargo command.

- **Plant a target.** Write `$RUN_HOME/.config/codex/config.toml` with `model = "old-model"`, `[projects."/private/project"] trust_level = "trusted"`, `[marketplaces.example]` `last_updated`, `last_revision`, and `source`, and `[tui] model_availability_nux = "seen"`. Point `$RUN_HOME/.config/codex/config-link.toml` at that file with `ln -s`.
- **Check.** Run `cargo run --quiet --manifest-path "$REPO/scripts/merge-codex-config/Cargo.toml" -- --check --target "$RUN_HOME/.config/codex/config.toml" > "$EVIDENCE/sync-check-before.stdout.txt"`. Exit code `1`. Stdout contains `Codex config needs update`.
- **Refuse a symlink.** Run `cargo run --quiet --manifest-path "$REPO/scripts/merge-codex-config/Cargo.toml" -- --target "$RUN_HOME/.config/codex/config-link.toml" > "$EVIDENCE/sync-symlink.stdout.txt"`. Exit code `2`. Stderr contains `refusing to replace symlink`. `readlink` of `config-link.toml` is unchanged.
- **Merge.** Run `cargo run --quiet --manifest-path "$REPO/scripts/merge-codex-config/Cargo.toml" -- --target "$RUN_HOME/.config/codex/config.toml" > "$EVIDENCE/sync-merge.stdout.txt"`. Exit code `0`. Stdout contains `Merged Codex config`. The file mode is `0600`. `model` equals the `model` value in `$REPO/extras/codex/config.toml`. `trust_level = "trusted"`, the planted `last_updated`, `last_revision`, `source`, and `model_availability_nux = "seen"` are still in the file. Copy the merged file to `$EVIDENCE/config.toml`.
- **Check again.** Run the same `--check` command and write `$EVIDENCE/sync-check-after.stdout.txt`. Exit code `0`. Stdout contains `Codex config is up to date`.
- **Mise task entry.** Run `.cursor/skills/verify-dotfiles/scripts/harness.sh exec -- run sync-codex-config > "$EVIDENCE/sync-mise-run.stdout.txt"` only when the tool-install precondition holds. On a fresh isolated home the observed result was a non-zero mise install error, `HTTP status client error (403 Forbidden)` for a cursor-agent Windows artifact, and no merge. Keep that stdout and report the entry unmet. Do not mark it passed because the cargo command passed.

## Gotchas

- `sync-codex-config` is declared in `dotfiles/.config/mise/conf.d/base.toml`. That file is on the mise path only after dotfiles apply. Before apply, `mise run sync-codex-config` says the task does not exist.
- `mise run` installs every tool in the loaded config before the task body. The cargo commands above are the task body with an explicit `--target` under `RUN_HOME`. They do not prove the install step.
- The desired file is always `extras/codex/config.toml` inside the binary's repository root. There is no flag to point it elsewhere. A marketplace table that the desired file does not mention stays as planted, which is why `source` remains `https://example.com/original.git` in this fixture.
- `--check` still reads the target. It does not write. A symlink check is a separate invocation and exits `2`.
