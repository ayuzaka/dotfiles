# setup for Mac

## 1. Homebrew のインストール

公式サイトからインストール

<https://brew.sh/>

## chezmoi の導入

```sh
mkdir -p chezmoi_ignores/private/codex_projects.toml
mkdir -p chezmoi_ignores/private/ripgrep_ignore_local

chezmoi init https://github.com/ayuzaka/dotfiles.git --apply
```

## Homebrew で管理しているツールのインストール

```sh
# ~/.Brewfile からインストール
brew bundle --global
```

## fish をデフォルトシェルに設定

```sh
# fish を許可済みシェルに追加
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells

# デフォルトシェルを変更
chsh -s /opt/homebrew/bin/fish
```

ターミナルを再起動すると fish が起動する。

## 1Password

### SSH client compatibility

Configure `SSH_AUTH_SOCK` globally for every client

```sh
mkdir -p ~/Library/LaunchAgents
cat << EOF > ~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.1password.SSH_AUTH_SOCK</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string>
    <string>-c</string>
    <string>/bin/ln -sf $HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock \$SSH_AUTH_SOCK</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
launchctl load -w ~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist
```

参考：[SSH client compatibility](https://developer.1password.com/docs/ssh/agent/compatibility/)

## SKK 辞書の追加

```sh
mkdir -p "$HOME/.config/skk" && curl -fL "https://skk-dev.github.io/dict/SKK-JISYO.L.gz" | gzip -dc > "$HOME/.config/skk/SKK-JISYO.L"
```

参考：<https://skk-dev.github.io/dict/>

## Kensington のアプリをダウンロード

<https://www.kensington.com/ja-jp/software/kensingtonworks/>

## Git

`gpg` と `signingkey` は 1Password と連携させれば生成される
1Password の `GitHub SSH Key` のアイテムを参照すれば設定が表示される

```toml
[gpg "ssh"]
  program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
[user]
  email = 
  name =
  signingkey = ssh-xxxx
```

## Mac の設定

```sh
bash chezmoi_ignores/mac_init.sh
```
