---
name: verify-dotfiles
description: Drive this dotfiles repo the way a user does, in an isolated HOME, with mise bootstrap dotfiles (dry-run, apply, status) and merge-codex-config. Use when a change to mise.toml, templates, dotfiles entries, or Codex config merge needs proof that the real commands still do what the user sees.
---

# Verify dotfiles

The user-facing surface is the mise CLI in this checkout. `mise bootstrap dotfiles` links, copies, and renders the `[dotfiles]` entries. `merge-codex-config` merges `extras/codex/config.toml` into the Codex config file. There is no long-running server. A desktop Mac also has `mise run macos-init`, which writes macOS defaults and is not an isolated surface.

Two launches can run side by side. Each has its own `RUN_HOME`. Never point a run at the real user home, and never symlink the source checkout into `RUN_HOME`: `mise.local.toml` and `git config` would write through the link.

## Launch

From the source checkout:

```sh
.cursor/skills/verify-dotfiles/scripts/harness.sh launch
```

`launch` is ready when it prints `RUN_ID`, `RUN_HOME`, `REPO`, `SOURCE_REPO`, `MISE_ENV`, and `EVIDENCE`, and `mise trust` has trusted the isolated copy (those trust lines go to stderr). The copy lives at `$RUN_HOME/workspace/github.com/ayuzaka/dotfiles` because `[settings] dotfiles.root` is `~/workspace/github.com/ayuzaka/dotfiles`.

If the source checkout has no `mise.local.toml`, launch writes verification scaffolding into the copy only:

```toml
[env]
MISE_ENV = "private"
```

It then exports that `MISE_ENV` into the mise process. Writing `MISE_ENV` inside `mise.local.toml` does not load `mise.<env>.toml` in the same process; an activated shell exports it first. Do not pass `mise -E` or override `MISE_ENV` on the command line.

Load the printed file before reading results:

```sh
. artifacts/verify-dotfiles/latest/run.env
```

There is no server to wait for. The next command can run immediately.

## Doctor

```sh
.cursor/skills/verify-dotfiles/scripts/harness.sh doctor
```

Run this first whenever a drive looks wrong. It is read-only. Ready output contains `doctor: ok`, `mise_env=`, `ghostty_running=yes|no`, and `repo=` equal to the isolated copy. It fails if `HOME` is the real user home, if `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`, or `CODEX_HOME` escape `RUN_HOME`, if `mise.<MISE_ENV>.toml` is not loaded, or if `MISE_ENV=work` and `private/git/work.gitconfig` is missing.

`ghostty_running=yes` means `Ghostty.app` is running. Dry-run and status can continue. Apply must stop: the post-dotfiles hook reloads that app through `osascript`.

## Drive

```sh
.cursor/skills/verify-dotfiles/scripts/harness.sh exec -- <mise args>
```

The script sets `HOME` and the `XDG_*` / `CODEX_HOME` variables, then runs `mise -C "$REPO"`. Quote a leading `~` if an argument must expand inside that `HOME`; the parent shell expands an unquoted `~` first. Prefer `$RUN_HOME` absolute paths after sourcing `run.env`.

Read `.cursor/skills/verify-dotfiles/features/README.md` and drive the feature that matches the change. Commands in the feature files are literal.

These commands are not isolated and must not be driven:

- `mise run macos-init` writes macOS defaults and runs `killall Dock`.
- `mise run git-signing-key-create` creates a key on the real Mac.
- `mise run macskk-download` writes `$HOME/Downloads` and calls the GitHub API.
- `mise run bootstrap` and `mise run sync-codex-config` install every tool in the loaded config before the task body. On a fresh home that install reaches the network. A run here failed with HTTP 403 for a cursor-agent Windows artifact and never reached the task body.

## Evidence

Write proof under `$EVIDENCE` (`artifacts/verify-dotfiles/<RUN_ID>/evidence/`). Capture the command's stdout and the resulting files, not only the exit code. For apply, keep the symlink target, the rendered purpose file, the Git credential helper, and the Ghostty theme the post-hook writes. For status, keep stdout and the exit code. For the Codex merge, keep stdout, the file mode, and a second read of the unmanaged keys.

Exercise the real mise and `merge-codex-config` commands. Do not call `merge_tables` from a test and call that a user-path proof. Compare rendered files and symlink targets on disk. A dry-run is proof of the preview only; confirm it did not create the destination. `status` renders templates in memory to compare them. After either command, a destination that was absent before must still be absent.

## Cleanup

```sh
.cursor/skills/verify-dotfiles/scripts/harness.sh cleanup
.cursor/skills/verify-dotfiles/scripts/harness.sh cleanup "$RUN_ID"
```

Cleanup deletes that run's `RUN_ROOT` and nothing else. It does not kill processes by name. Evidence under `artifacts/verify-dotfiles/<RUN_ID>/evidence/` stays. `latest` may still point at the removed run's metadata directory.

## Stand-in

The run that produced this skill was a Linux container, not the user's Mac. It installed mise `2026.10.25` into `~/.local/bin` and used `rustup` stable `1.99.1` for `merge-codex-config` because the image's default Rust `1.83` cannot parse `edition = "2024"`. The Mac is expected to already have mise and the repo's `rust = "latest"`. Those install steps are unverified on the Mac. `templates/.bashrc` emits `export MISE_ENV=...` only when `os() != "macos"`, so a Linux render of `~/.bashrc` is not proof of the Mac file. `Ghostty.app` was not running, so the `osascript` reload path was not executed. The hook still wrote `$RUN_HOME/.config/ghostty/theme`.
