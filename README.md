# dotfiles

設定はこのリポジトリを編集してから、下のコマンドで反映する。ホームディレクトリ側は直接編集しない。

このリポジトリで実行する。環境は Git 管理外の `mise.local.toml` にある `MISE_ENV`（`private` または `work`）で選ぶ。コマンドでは上書きしない。適用の前に `--dry-run` で対象を確認する。

| 種類                               | 編集する場所                                 |
|------------------------------------|----------------------------------------------|
| 静的ファイル                       | `dotfiles/`                                  |
| テンプレート                       | `templates/`。入力は Git 管理外の `private/` |
| 環境ごとの配置・ツール・パッケージ | `mise.private.toml` / `mise.work.toml`       |
| 共通のツール・パッケージ・macOS    | `dotfiles/.config/mise/conf.d/`              |
| 配置ルール                         | `mise.toml` と環境別 toml の `[dotfiles]`    |
| ホームへ自動で置かないもの         | `extras/`                                    |

## 静的ファイル

`symlink` と `symlink-each`。`~/.config` 以下の大半はここ。編集したファイルがそのまま実体になる。

- 追加: 対応するディレクトリにファイルを置く。新しい配置先なら `[dotfiles]` にエントリを足す。

```sh
mise bootstrap dotfiles apply --force --dry-run
mise bootstrap dotfiles apply --force
```

- 更新: 保存すれば反映される。
- 削除: ファイルを消してから、残った symlink を外す。

```sh
mise bootstrap dotfiles apply --prune --dry-run
mise bootstrap dotfiles apply --prune
```

`dotfiles/.config/theme` を変えたあとは、Ghostty のテーマファイル `~/.config/ghostty/theme` を更新する。`mise bootstrap dotfiles apply` のあとにも、このコマンドが実行される。

```sh
~/.local/bin/ghostty-sync-theme
```

## テンプレートと copy

`templates/` と、macSKK の `kana-rule.conf`（`mode = "copy"`）。出力は apply のときに作られる。

- 追加: ファイルを置き、`[dotfiles]` にエントリを書く。テンプレートは `mode = "template"`。
- 更新: 上の apply。
- 削除: ファイルと `[dotfiles]` のエントリを消してから、`--prune` 付きの apply。

`private/` を変えたときも、それを読むテンプレートを apply する。仕事用マシンでは `private/git/work.gitconfig` が無いと Git 設定の apply が失敗する。

## Neovim のプラグイン

定義は `dotfiles/.config/nvim/lua/config/plugins.lua`。定義の保存は symlink なので即反映され、プラグイン本体は次のコマンドで入れる。

- 追加・バージョンを上げる: `lazy-lock.json` も更新される。

```sh
nvim --headless '+Lazy! sync' +qa
```

- ロックファイルのコミットに合わせる。

```sh
nvim --headless '+Lazy! restore' +qa
```

- 削除: 定義を消してから、使われなくなったプラグインを外す。

```sh
nvim --headless '+Lazy! clean' +qa
```

## Vim のプラグイン

定義は `dotfiles/.config/vim/plugins.vim`。

- 追加: `vim +PlugInstall +qa`
- 更新: `vim +PlugUpdate +qa`
- 削除: 定義を消してから `vim +PlugClean +qa`

## zsh のプラグイン

定義は `dotfiles/.config/zsh/sheldon/plugins.toml`。次のシェル起動で読み込まれる。今すぐキャッシュを作り直すときだけ実行する。

```sh
sheldon source
```

## Codex

管理する値は `extras/codex/config.toml`。`mise run sync-codex-config` が `~/.config/codex/config.toml` へマージする。ファイルごと置き換えない。

- 追加・更新: `mise run sync-codex-config`
- 削除: 同じコマンドは消したキーを取り除かない。`extras/codex/config.toml` と `~/.config/codex/config.toml` の両方からそのキーを消す。

## mise のツール

`[tools]`。共通は `dotfiles/.config/mise/conf.d/base.toml`、環境ごとが `mise.private.toml` と `mise.work.toml`。

- 追加・バージョンの変更:

```sh
mise install
```

- `latest` を今の最新へ上げる:

```sh
mise upgrade
```

- 削除: エントリを消してから、どの設定からも参照されなくなったバージョンを消す。

```sh
mise prune --dry-run
mise prune
```

未インストールの確認は `mise ls --missing`。

## Homebrew と Mac App Store

`[bootstrap.packages]`。共通は `base.toml`、環境ごとが `mise.private.toml` と `mise.work.toml`。

- 追加:

```sh
mise bootstrap packages apply --dry-run
mise bootstrap packages apply
```

- 更新:

```sh
mise bootstrap packages upgrade
```

- 削除: エントリを消してから prune する。formula は宣言に無いものも対象になるので、先に dry-run で一覧を確認する。

```sh
mise bootstrap packages prune --dry-run
mise bootstrap packages prune
mise bootstrap packages prune --manager brew-cask --dry-run
mise bootstrap packages prune --manager brew-cask
```

Mac App Store のアプリ（`mas:`）は prune の対象外なので、App Store から削除する。

## macOS のシステム設定

`[bootstrap.macos]` の Dock、Finder、キーボード、トラックパッド。`base.toml` にある。

- 追加・更新:

```sh
mise bootstrap macos defaults apply --dry-run
mise bootstrap macos defaults apply
```

- 削除: エントリを消しても、すでに書いた値は残る。戻したい値を書いて、もう一度 apply する。

スクリーンショットの保存先など、一度だけの設定は `mise run macos-init`。

## LaunchAgent

`[bootstrap.macos.launchd.agents]`。共通は `dotfiles/.config/mise/conf.d/launchd.toml`、プライベート用は `mise.private.toml`。

- 追加・更新:

```sh
mise bootstrap macos launchd-agents apply --dry-run
mise bootstrap macos launchd-agents apply
```

- 削除: 宣言を消してから、エージェント名で外す。宣言が残っていると、次の bootstrap で戻る。

```sh
mise bootstrap services remove <name>
```

## 自動では入らないもの

- GitHub CLI 拡張: `extras/gh_extensions.txt` に URL を書き、`gh extension install <url>`。外すときは行を消して `gh extension remove <name>`。
- Raycast: `extras/raycast/` を Raycast から読み込む。

## 初回だけ

```sh
mise trust -a --yes
mise bootstrap dotfiles apply --force --dry-run
mise bootstrap dotfiles apply --force --yes
mise trust "$HOME/.config/mise/config.toml" --yes
mise run bootstrap
mise run macos-init
mise bootstrap --skip packages,dotfiles --dry-run
mise bootstrap --skip packages,dotfiles --yes
```

`mise run bootstrap` は、この clone に JSON をキー順で保存する Git フィルタを登録する。
