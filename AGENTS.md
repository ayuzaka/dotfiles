# AGENTS.md

## Project Overview

This project manages dotfiles with `mise bootstrap dotfiles`.

## Important Rules

Edit files in this repository instead of editing their targets in the home directory.

- Place static files under `dotfiles/`.
- Place Tera templates under `templates/`.
- Keep machine-local template inputs under the Git-ignored `private/` directory.
- Keep Git-managed files that are not applied to the home directory under `extras/`.

Preview dotfile changes before applying them.

```sh
MISE_ENV=private mise \
  -C "$HOME/workspace/github.com/ayuzaka/dotfiles" \
  bootstrap dotfiles apply --force --dry-run
```

Run `mise run bootstrap` after changing the Codex merge or permission rules.
Do not replace `~/.config/codex/config.toml` as a whole.
It contains both managed and application-generated values.

The legacy chezmoi checkout and configuration are retained only for rollback.
Do not use chezmoi for normal dotfile updates.

## Testing Guidelines

No comprehensive test suite is required.
Validate changed templates with a dry-run.
Confirm that each affected application can load its configuration.
