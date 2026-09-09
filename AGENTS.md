# AGENTS.md

## Project Overview

This project manages dotfiles with `mise bootstrap dotfiles`.

## Important Rules

Edit files in this repository instead of editing their targets in the home directory.

- Place static files under `dotfiles/`.
- Place Tera templates under `templates/`.
- Keep machine-local template inputs under the Git-ignored `private/` directory.
- Keep Git-managed files that are not applied to the home directory under `extras/`.
- Place temporary documents in the working directory root, not under `/tmp/claude-501/` and not in `.gitignore`. This keeps them easy to open and avoids leaving stray files behind.

Preview dotfile changes before applying them.
Set `MISE_ENV` in the Git-ignored `mise.local.toml`; do not override it in the command.

```sh
mise \
  -C "$HOME/workspace/github.com/ayuzaka/dotfiles" \
  bootstrap dotfiles apply --force --dry-run
```

Run `mise run bootstrap` after changing the Codex merge or permission rules.
Do not replace `~/.config/codex/config.toml` as a whole.
It contains both managed and application-generated values.

Claude Code rewrites `dotfiles/.claude/settings.json` on its own, so a
`jsonsort` clean filter keeps its committed form key-sorted.
The filter lives in the per-clone Git config; run `mise run bootstrap` in a
fresh clone to register it.
There is no smudge filter, so `git checkout` writes the sorted form into the
live file through the symlink.

## Testing Guidelines

No comprehensive test suite is required.
Validate changed templates with a dry-run.
Confirm that each affected application can load its configuration.
