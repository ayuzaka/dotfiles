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

function fzf-down() {
  fzf --height 50% "$@" --border
}

autoload -Uz is-at-least
if is-at-least 4.3.11; then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':chpwd:*' recent-dirs-max 500
  zstyle ':chpwd:*' recent-dirs-default yes
  zstyle ':completion:*' recent-dirs-insert both
fi

# ni.zsh
export NI_USE_SOCKET_FIREWALL=1

# gibo
export GIBO_BOILERPLATES="$XDG_CONFIG_HOME"/gibo/gitignore-boilerplates

# Dart
export PUB_CACHE="$XDG_CONFIG_HOME"/dart/pub-cache

# With 1Password
opr() {
  who=$(op whoami)
  if [[ $? != 0 ]]; then
    if [[ -n "$OP_ACCOUNT" ]]; then
      eval $(op signin --account "$OP_ACCOUNT")
    else
      eval $(op signin)
    fi
  fi

  if [[ -f "$PWD/.env" ]]; then
    op run --env-file="$PWD"/.env -- "$@"
  elif [[ -f "$PWD/.env.local" ]]; then
    op run --env-file="$PWD"/.env.local -- "$@"
  elif [[ -f "$XDG_CONFIG_HOME/op/.env" ]]; then
    op run --env-file="$XDG_CONFIG_HOME"/op/.env -- "$@"
  else
    "$@"
  fi
}

export PATH="$PATH:/opt/homebrew/Cellar/icu4c/74.2/bin"

source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc

source $HOME/.tenv/tenv.completion.zsh

export WASMTIME_HOME="$XDG_DATA_HOME/wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"

_zoxide_cache="$XDG_CACHE_HOME/zsh/zoxide.zsh"
_lazy_zsh="$XDG_CONFIG_HOME/zsh/lazy.zsh"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
if [[ ! -r "$_zoxide_cache" || "$_lazy_zsh" -nt "$_zoxide_cache" ]]; then
  zoxide init zsh >| "$_zoxide_cache"
fi
source "$_zoxide_cache"
unset _zoxide_cache _lazy_zsh

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^o" edit-command-line

export CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$XDG_CONFIG_HOME/claude}"
export CODEX_HOME="${CODEX_HOME:-$XDG_CONFIG_HOME/codex}"

if command -v ngrok &>/dev/null; then
  _ngrok_cache="$XDG_CACHE_HOME/zsh/ngrok.zsh"
  _lazy_zsh="$XDG_CONFIG_HOME/zsh/lazy.zsh"
  if [[ ! -r "$_ngrok_cache" || "$_lazy_zsh" -nt "$_ngrok_cache" ]]; then
    ngrok completion >| "$_ngrok_cache"
  fi
  source "$_ngrok_cache"
  unset _ngrok_cache _lazy_zsh
fi

# 1Password
if command -v op >/dev/null 2>&1; then
  source "$XDG_CONFIG_HOME"/op/plugins.sh
fi
