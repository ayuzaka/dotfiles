# Dotfiles verification map

This directory is the maintained source for verifying the user-facing behavior of this dotfiles checkout. Read the index before driving, then use the matching feature file as the recipe.

## Baseline preconditions

- Launch with `.cursor/skills/verify-dotfiles/scripts/harness.sh launch` so destinations land in a disposable `RUN_HOME`.
- Source `artifacts/verify-dotfiles/latest/run.env` before reading `$RUN_HOME`, `$REPO`, `$EVIDENCE`, or `$MISE_ENV`.
- Run `.cursor/skills/verify-dotfiles/scripts/harness.sh doctor` and require `doctor: ok`.
- Never drive an instance whose `home=` line is the real user home.
- The isolated copy selects its environment from its own `mise.local.toml`. A missing source file becomes `MISE_ENV=private` scaffolding inside the copy only.

## Driving conventions

- Start every recipe from the baseline state unless its preconditions say otherwise.
- Treat every command as literal. Keep quoted paths and flags unchanged.
- Run mise through `harness.sh exec`. The parent shell must not be the process whose `HOME` is the real home during `exec`; the script sets `HOME` itself.
- Restore nothing in the source checkout. Do not remove proof artifacts during cleanup.

## Proof and skip reporting

- Capture the user action and the resulting state, not only the final screen.
- CLI proof includes the command, stdout, stderr when it explains a failure, and the exit code.
- Mutation proof includes a second read of the file or symlink the command claimed to write.
- Record the feature ID and entry point used with every artifact.
- Report an unreachable path with the attempted command and the unmet precondition.
- Do not report a skipped entry point as verified through a different path.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with verify-dotfiles` starts with `Preconditions:` and uses labeled bullets that pair each user action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

## Features

- [Preview apply](./preview-apply.md) prints the link, copy, and render actions and leaves the home unchanged.
- [Apply dotfiles](./apply-dotfiles.md) links and renders into the isolated home, including the private purpose and the Ghostty theme hook.
- [Status missing](./status-missing.md) lists destinations that are not applied and exits 1, then reports up to date after apply.
- [Sync Codex config](./sync-codex-config.md) merges the managed Codex file into an isolated target, keeps unmanaged state, and refuses a symlink.
