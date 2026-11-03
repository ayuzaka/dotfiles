# Preview apply

Preview apply prints the symlink, copy, and template actions `mise bootstrap dotfiles apply` would take, and does not create those destinations.

## Sub-features

- `preview-private` prints link and render lines for the private environment and leaves `~/.editorconfig` absent.
- `preview-work` is the same command when `MISE_ENV=work`. It cannot render the Git config template without `private/git/work.gitconfig`.

## How to get to it (user POV)

- From the dotfiles checkout, run `mise bootstrap dotfiles apply --force --dry-run`, as `README.md` shows before an apply.

## Driving it with verify-dotfiles

Preconditions:

- `harness.sh doctor` prints `doctor: ok`.
- `$RUN_HOME/.editorconfig` does not exist.
- For `preview-private`, `mise_env=private`. If it is not, stop and report that unmet precondition. Do not treat a work preview as this result.
- For `preview-work`, `mise_env=work` and `private/git/work.gitconfig` exists in the isolated copy. If the gitconfig is missing, doctor already fails.

- **Preview.** Run the dry-run and keep stdout. Run `.cursor/skills/verify-dotfiles/scripts/harness.sh exec -- bootstrap dotfiles apply --force --dry-run --yes > "$EVIDENCE/preview.stdout.txt"`. Exit code `0`. Stdout contains `ln -sf` and `.editorconfig`, and contains `render` and `purpose.toml`. A warning that `~/.config/mise/config.toml` is not trusted may appear before that symlink exists.
- **Confirm nothing was written.** Run `test ! -e "$RUN_HOME/.editorconfig"`. The destination is still absent.
- **Proof.** Keep `$EVIDENCE/preview.stdout.txt` and record that the editorconfig path was absent after the command.

## Gotchas

- `--yes` is required here because the harness has no confirmation prompt. The README's preview command is the same flags without `--yes`.
- An untrusted-config warning is not a failed preview when the exit code is `0`.
- Dry-run prints post-dotfiles hooks and does not run them, so it does not write the Ghostty theme and does not reload Ghostty.
- `mise run` is a different command. It installs tools. This preview does not.
