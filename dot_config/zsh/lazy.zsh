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

# With 1Password
opr() {
  who=$(op whoami)
  if [[ $? != 0 ]]; then
    eval $(op signin)
  fi

  if [[ -f "$PWD/.env" ]]; then
    op run --env-file="$PWD"/.env -- "$@"
  elif [[ -f "$PWD/.env.local" ]]; then
    op run --env-file="$PWD"/.env.local -- "$@"
  else
    op run --env-file="$XDG_CONFIG_HOME"/op/.env.1password -- "$@"
  fi
}

export PATH="$PATH:/opt/homebrew/Cellar/icu4c/74.2/bin"

source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

source "$RYE_HOME/env"

# Added by OrbStack: command-line tools and integration
source $HOME/.orbstack/shell/init.zsh 2>/dev/null || :

export WASMTIME_HOME="$XDG_DATA_HOME/wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"

eval "$(zoxide init zsh)"

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^o" edit-command-line

alias claude=$XDG_CONFIG_HOME/claude/local/claude

GIT_WORKTREE_DIR_BASE=~/workspace/my_worktrees
GIT_WORKTREE_COPYFILES=".copy_files.txt"

wt() {
  local cmd=$1
  local here=${PWD##*/}
  shift

  case "$cmd" in
    init)
      nvim $GIT_WORKTREE_COPYFILES
      ;;

    add)
      local create_worktree_dir=$1
      local branch=$2
      local git_worktree_dir="$GIT_WORKTREE_DIR_BASE/$here/$create_worktree_dir"

      if [[ -z "$create_worktree_dir" || -z "$branch" ]]; then
        echo "usage wt add <dir_name> <branch_name>" >&2
        return 1
      fi

      git worktree add "$git_worktree_dir" -b "$branch"

      if [[ -f "$GIT_WORKTREE_COPYFILES" ]]; then
        while IFS= read -r file; do
          # Skip comments and empty lines
          [[ "$file" =~ ^#.*$ || -z "$file" ]] && continue
          if [[ -d "$file" ]]; then
            mkdir -p "$git_worktree_dir/$(basename "$file")"
            cp -r "$file" "$git_worktree_dir/"
          else
            cp "$file" "$git_worktree_dir/"
          fi
        done < "$GIT_WORKTREE_COPYFILES"
      fi
      ;;

    switch)
      local dir
      dir=$(git worktree list --porcelain | awk '/worktree /{print $2}' | fzf)
      if [[ -n "$dir" ]]; then
        cd "$dir"
      fi
      ;;

    *)
      echo "usage: wt {add|switch|init}" >&2
      return 1
      ;;
  esac
}
