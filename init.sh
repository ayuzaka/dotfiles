#!/bin/sh

# npm のディレクトリパスを変更
# ref: https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview#recommended-create-a-new-user-writable-npm-prefix
npm config set prefix "$XDG_DATA_HOME"/npm/bin

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

# .DS_Store ファイルを作らない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
