#!/bin/sh

# スクリーンショットの保存名
defaults write com.apple.screencapture name "screenShot"

# スクリーンショットの保存先
defaults write com.apple.screencapture location ~/Downloads

# すべての拡張子のファイルを表示する
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# .DS_Store ファイルを作らない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Dock からアプリを削除
defaults write com.apple.dock persistent-apps -array

# Dock の設定を反映
killall Dock
