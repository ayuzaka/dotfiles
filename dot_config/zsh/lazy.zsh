# -----------------------------
# Completion
# -----------------------------
# 自動補完を有効にする
autoload -Uz compinit
compinit

compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

# 補完の選択を楽にする
zstyle ':completion:*' menu select

# 補完候補をできるだけ詰めて表示する
setopt list_packed

# 補完候補にファイルの種類も表示する
setopt list_types

# 色の設定
export LSCOLORS=Exfxcxdxbxegedabagacad

# 補完時の色設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true

# 補完候補に色つける
autoload -U colors
colors
zstyle ':completion:*' list-colors "${LS_COLORS}"
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 大文字・小文字を区別しない(大文字を入力した場合は区別する)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# manの補完をセクション番号別に表示させる
zstyle ':completion:*:manuals' separate-sections true

# --prefix=/usr などの = 以降でも補完
setopt magic_equal_subst

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# pnpm completion
# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# search ~/.chpwd-recent-dirs
alias cdd='fzf_cdr'
fzf_cdr() {
  target_dir=$(cdr -l | sed 's/^[^ ][^ ]*  *//' | fzf)
  target_dir="${target_dir/\~/$HOME}"
  if [ -n "$target_dir" ]; then
    cd "$target_dir" || return
  fi
}

function fzf-down() {
  fzf --height 50% "$@" --border
}

fghq() {
  projectDir=$(ghq list | fzf --preview "bat $(ghq root)/{}/README.md")
  if [ "$projectDir" = "" ]; then
    return 0
  fi

  cd ~/workspace/"$projectDir" || return
}

autoload -Uz is-at-least
if is-at-least 4.3.11; then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':chpwd:*' recent-dirs-max 500
  zstyle ':chpwd:*' recent-dirs-default yes
  zstyle ':completion:*' recent-dirs-insert both
fi

# zeno.zsh
export ZENO_HOME="$XDG_CONFIG_HOME/zeno"

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' ' zeno-auto-snippet

  # fallback if snippet not matched (default: self-insert)
  # export ZENO_AUTO_SNIPPET_FALLBACK=self-insert

  # if you use zsh's incremental search
  # bindkey -M isearch ' ' self-insert

  bindkey '^m' zeno-auto-snippet-and-accept-line

  bindkey '^i' zeno-completion

  # fallback if completion not matched
  # (default: fzf-completion if exists; otherwise expand-or-complete)
  # export ZENO_COMPLETION_FALLBACK=expand-or-complete
fi

# gibo
export GIBO_BOILERPLATES="$XDG_CONFIG_HOME"/gibo/gitignore-boilerplates

# Dart
export PUB_CACHE="$XDG_CONFIG_HOME"/dart/pub-cache
