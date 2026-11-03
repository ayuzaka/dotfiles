# Status missing

Status missing lists every `[dotfiles]` entry that is not in the desired state and exits 1. After a successful apply it exits 0 and reports the entries up to date.

## Sub-features

- `status-before-apply` lists `~/.editorconfig` as `missing` and exits 1 without creating it.
- `status-after-apply` prints that the entries are up to date and exits 0.

## How to get to it (user POV)

- From the dotfiles checkout, run `mise bootstrap dotfiles status --missing`, as `README.md` shows after an update.

## Driving it with verify-dotfiles

Preconditions:

- `harness.sh doctor` prints `doctor: ok` and `mise_env=private`. Another environment loads different entries; do not call that this result.
- For `status-before-apply`, `$RUN_HOME/.editorconfig` does not exist.
- For `status-after-apply`, [Apply dotfiles](./apply-dotfiles.md) has completed in this same `RUN_HOME`, including trust.

- **Status before apply.** Run `.cursor/skills/verify-dotfiles/scripts/harness.sh exec -- bootstrap dotfiles status --missing > "$EVIDENCE/status-before.stdout.txt"` and record the exit code. Exit code `1`. Stdout contains a line with `~/.editorconfig` and `missing`, and a line with `~/.cursor` and `missing` from `mise.private.toml`. Then run `test ! -e "$RUN_HOME/.editorconfig"`.
- **Status after apply.** Run `.cursor/skills/verify-dotfiles/scripts/harness.sh exec -- bootstrap dotfiles status --missing > "$EVIDENCE/status-after.stdout.txt"`. Exit code `0`. Stdout contains `up to date`.
- **Proof.** Keep both stdout files and both exit codes. The before file is the action; the absent editorconfig path and the after file are the resulting states.

## Gotchas

- Exit code `1` before apply is the feature working. Do not retry without `--missing` to force a zero exit.
- Status renders templates in order to compare them. The observed before-apply run still left `~/.editorconfig` absent. If a destination appears, that is a failure of this check.
- The trailing "no checkpoint" and "history-watch" text is mise history status, not a missing dotfile. The dotfile result is the table and the exit code.
