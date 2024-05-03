# setup for Windows

## PowerShell

インストール

```powershell
winget install --id Microsoft.Powershell --source winget
```

## WSL

インストール

```powershell
wsl --install
```

<https://learn.microsoft.com/ja-jp/windows/wsl/install>

### Vim

```sh
# 既存の Vim を削除
sudo apt remove vim
```

```sh
# ビルドに必要なライブラリをインストール
sudo apt install -y meke libncurses-dev
```

```sh
# ソースコードからビルド
git clone https://github.com/vim/vim.git
cd vim/src
make
sudo make install
```

<https://www.vim.org/download.php>

### zsh

```sh
sudo apt install zsh

# デフォルトシェルの変更
chsh -s /bin/zsh
```

[sheldon](https://github.com/rossmacarthur/sheldon)

```sh
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

# `~.local/bin` になぜかパスが通らないので場所を変更
mv ~/.local/bin/sheldon /usr/local/bin
```

`cargo install sheldon` だとエラーになる

[GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)
[Rust](https://www.rust-lang.org/learn/get-started)
[fnm](https://github.com/Schniz/fnm)
[Deno](https://docs.deno.com/runtime/manual/getting_started/installation)
[Go](https://golang.google.cn/dl/)
[bun](https://bun.sh/)
[lsd](https://github.com/lsd-rs/lsd)

[chezmoi](https://www.chezmoi.io/install/#one-line-package-install)

```sh
# One-line binary install
sh -c "$(curl -fsLS get.chezmoi.io)"
```

tig

```sh
sudo apt install tig
```

### Scoop

パッケージマネージャ
`winget` にないものをインストール用

```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
> irm get.scoop.sh | iex
```

<https://scoop.sh/>

### Git

```sh
scoop install git
```

> [!TIP]
> scoop が Git を要求するため、scoop で入れる

### Fira Code

```powershell
scoop install sudo

scoop bucket add nerd-fonts
sudo scoop install -g firacode
```
