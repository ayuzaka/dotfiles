# dotfiles

Dotfiles managed with [`mise bootstrap`](https://mise.jdx.dev/dotfiles.html).

## First-time setup

Install [mise](https://mise.jdx.dev/getting-started.html), then clone this repository.

Change to the cloned repository.

```sh
cd "$HOME/workspace/github.com/ayuzaka/dotfiles"
```

Select the environment for the first bootstrap.
The generated shell configuration preserves this selection for new shells.

```sh
export MISE_ENV=private # or work
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
