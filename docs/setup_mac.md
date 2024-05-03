# setup for Mac

## zsh

`/etc/zshenv` の変更

```env
ZDOTDIR=$HOME/.config/zsh
```

[A Users' Guid to the Z-Shell](https://zsh.sourceforge.io/Guide/zshguide02.html#l6)

## Homebrew

<https://brew.sh/>

```sh
# Brewfile があるパスに移動
brew bundle
```

## Homebrew 以外

- [vim-plug](https://github.com/junegunn/vim-plug)
- [Xcode](https://developer.apple.com/download/all/?q=Xcode)
- [Rust](https://www.rust-lang.org/learn/get-started)
- [Deno](https://docs.deno.com/runtime/manual/getting_started/installation)
- [Go](https://golang.google.cn/dl/)
- [bun](https://bun.sh/)
- [markdown-cli](https://github.com/igorshubovych/markdownlint-cli)
- [ollama](https://github.com/jmorganca/ollama)
- [Firebase CLI](https://firebase.google.com/docs/cli?hl=ja#install-cli-mac-linux)
- [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)

fetch and install the tmux plugin  
`Ctrl + s + I`

## Mac の設定

```sh
#!/bin/sh

# スクリーンショットの保存名
defaults write com.apple.screencapture name "screenShot"

# スクリーンショットの保存先
defaults write com.apple.screencapture location ~/Downloads

# すべての拡張子のファイルを表示する
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder のタイトルバーにフルパスを表示する
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

defaults write com.apple.dock mcx-expose-disabled -bool true
defaults write com.apple.dashboard mcx-disabled -bool true

# .DS_Store ファイルを 作らない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
```
