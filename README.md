# dotfiles

Dotfiles managed with [`mise bootstrap`](https://mise.jdx.dev/dotfiles.html).

## First-time setup

Install [mise](https://mise.jdx.dev/getting-started.html), then clone this repository.

Change to the cloned repository.

```sh
cd "$HOME/workspace/github.com/ayuzaka/dotfiles"
```

Select the environment in the Git-ignored `mise.local.toml`.

```toml
[env]
MISE_ENV = "private" # or "work"
```

On a work machine, create the Git-ignored Git include file.
`templates/.config/git/config` reads it when the environment is `work`,
and the dotfiles apply fails while it is missing.
Put the `includeIf` entries for work repositories in it.

```sh
mkdir -p private/git
"$EDITOR" private/git/work.gitconfig
```

On a work machine, also create the Git-ignored ghtkn config.
`templates/.config/ghtkn/ghtkn.yaml` reads it when the environment is `work`.
Put that environment's GitHub App in it. This repository's private environment uses its own app.

```sh
mkdir -p private/ghtkn
"$EDITOR" private/ghtkn/ghtkn.yaml
```

```yaml
apps:
  - name: work
    client_id: Iv1...
```

Trust the cloned repository after reviewing its mise configuration.

```sh
mise trust -a --yes
```

Preview and apply the dotfiles.

```sh
mise bootstrap dotfiles apply --force --dry-run
mise bootstrap dotfiles apply --force --yes
```

Trust the mise configuration symlink created by the dotfile apply.

```sh
mise trust "$HOME/.config/mise/config.toml" --yes
```

Apply the one-time macOS settings on a new Mac.

```sh
mise run macos-init
```

Preview and run the remaining bootstrap steps.
System packages and Homebrew are excluded from this workflow.

```sh
mise bootstrap --skip packages,dotfiles --dry-run
mise bootstrap --skip packages,dotfiles --yes
```

Check for missing or out-of-sync dotfiles.

```sh
mise bootstrap dotfiles status --missing
```

Check for configured tool versions that are not installed.

```sh
mise ls --missing
```

## Apply updates

After editing this repository or pulling changes, preview and apply the dotfiles.

```sh
mise bootstrap dotfiles apply --force --dry-run
mise bootstrap dotfiles apply --force
```

If the mise tools or bootstrap task changed, preview and run the remaining
bootstrap steps too.

```sh
mise bootstrap --skip packages,dotfiles --dry-run
mise bootstrap --skip packages,dotfiles
```

Check for missing or out-of-sync dotfiles.

```sh
mise bootstrap dotfiles status --missing
```

Check for configured tool versions that are not installed.

```sh
mise ls --missing
```
