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

# .DS_Store ファイルを作らない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Dock を右側に配置
defaults write com.apple.dock orientation -string right

# Dock のサイズを小さくする
defaults write com.apple.dock tilesize -int 16

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Dock からアプリを削除
defaults write com.apple.dock persistent-apps -array

# Dock の設定を反映
killall Dock
