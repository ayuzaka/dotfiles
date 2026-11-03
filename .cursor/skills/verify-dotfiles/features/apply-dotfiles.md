# Apply dotfiles

Apply links static files, renders templates for the selected environment, and runs the post-dotfiles hook that writes the Ghostty theme under the isolated home.

## Sub-features

- `apply-private` renders purpose `private`, points `~/.editorconfig` at the isolated copy, and selects the ghtkn GitHub credential helper.
- `apply-trust` trusts the mise config symlink the apply just created.
- `apply-work` renders the gh credential helper and includes `private/git/work.gitconfig`. Without that file the Git config entry fails and the destination is not written.

## How to get to it (user POV)

- From the dotfiles checkout, run `mise bootstrap dotfiles apply --force --yes` on a first apply, then `mise trust "$HOME/.config/mise/config.toml" --yes`.
- Later updates use `mise bootstrap dotfiles apply --force`, which prompts before writing.

## Driving it with verify-dotfiles

Preconditions:

- `harness.sh doctor` prints `doctor: ok` and `ghostty_running=no`. If Ghostty is running, stop. Apply would reload the user's Ghostty.
- `mise_env=private` for `apply-private`. If `MISE_ENV` is `work`, do not record these private results as a pass. Drive `apply-work` only when `private/git/work.gitconfig` is present; otherwise report doctor's failure.
- `$RUN_HOME/.editorconfig` does not exist yet.
- Source `artifacts/verify-dotfiles/latest/run.env` so `$RUN_HOME`, `$REPO`, `$EVIDENCE`, and `$SOURCE_REPO` are set. Do not export those into a command that should keep the real `HOME` except through `harness.sh exec`.

- **Apply.** Run `.cursor/skills/verify-dotfiles/scripts/harness.sh exec -- bootstrap dotfiles apply --force --yes > "$EVIDENCE/apply.stdout.txt" 2> "$EVIDENCE/apply.stderr.txt"`. Exit code `0`. Stderr contains `created symlink ~/.editorconfig` and `rendered` together with `purpose.lua`. Stdout contains `wrote` and `.config/ghostty/theme`.
- **Confirm the symlink.** Run `readlink "$RUN_HOME/.editorconfig" > "$EVIDENCE/editorconfig-link.txt"`. The link target is `$REPO/dotfiles/.editorconfig`.
- **Confirm the private purpose.** Run `cp "$RUN_HOME/.config/nvim/lua/config/purpose.lua" "$EVIDENCE/purpose.lua"`. The file's trimmed text is `return "private"`.
- **Confirm the GitHub helper.** Run `grep -F 'helper = !ghtkn git-credential' "$RUN_HOME/.config/git/config" > "$EVIDENCE/git-credential.txt"`. The command exits `0`.
- **Confirm the hook stayed inside the home.** Run `cp "$RUN_HOME/.config/ghostty/theme" "$EVIDENCE/ghostty-theme.txt"`. When `$RUN_HOME/.config/theme` reads `light`, the theme file contains `theme = Everforest Light Med`. The path is under `$RUN_HOME`.
- **Trust the linked config.** Run `.cursor/skills/verify-dotfiles/scripts/harness.sh exec -- trust "$RUN_HOME/.config/mise/config.toml" --yes > "$EVIDENCE/trust.stdout.txt" 2> "$EVIDENCE/trust.stderr.txt"`. Stderr contains `mise trusted`.
- **Confirm the source checkout was not the destination.** Run `test ! -f "$SOURCE_REPO/mise.local.toml"` when the source had no such file before launch. `readlink` of `$RUN_HOME/.editorconfig` starts with `$RUN_HOME`, not `$SOURCE_REPO`.

## Gotchas

- The post-dotfiles hook is `dotfiles/.local/bin/ghostty-sync-theme`, declared in `dotfiles/.config/mise/conf.d/ghostty.toml`. It writes `$XDG_CONFIG_HOME/ghostty/theme` and, when `Ghostty.app` is running, reloads it with `osascript`. The harness sets `XDG_CONFIG_HOME` inside `RUN_HOME`. A real `XDG_CONFIG_HOME` inherited from the user would make the hook write outside the run.
- `templates/.bashrc` adds `export MISE_ENV=...` only when the OS is not macOS. Do not use the rendered bashrc as proof of a Mac apply.
- `apply-work` without `private/git/work.gitconfig` exits `1` with `Failed to read file` for `private/git/work.gitconfig` and does not create `~/.config/git/config`.
- `--yes` skips the confirmation prompt. A later apply on a real machine may prompt; that prompt is not part of this harness.
