# prompt.zsh - Simple prompt showing current path and git status
# Uses zle -F async to avoid blocking the prompt on git commands

typeset -g _git_prompt_fd=-1

# Runs in a background process; prints the git status string to stdout
_git_prompt_compute() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(git rev-parse --short HEAD 2>/dev/null) \
    || { print -r -- ""; return }

  local staged=0 unstaged=0 untracked=0 conflicts=0 line x y
  while IFS= read -r line; do
    x="${line[1]}" y="${line[2]}"
    if   [[ $x == '?' && $y == '?' ]]; then ((untracked++))
    elif [[ $x == 'U' || $y == 'U' || ($x == 'A' && $y == 'A') || ($x == 'D' && $y == 'D') ]]; then ((conflicts++))
    else
      [[ $x != ' ' ]] && ((staged++))
      [[ $y != ' ' ]] && ((unstaged++))
    fi
  done < <(git --no-optional-locks status --porcelain 2>/dev/null)

  local stash=0
  stash=$(git stash list 2>/dev/null | wc -l)

  local ahead=0 behind=0 tracking
  tracking=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  if [[ -n $tracking ]]; then
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
  fi

  local out=" %F{cyan} ${branch}%f"
  ((conflicts > 0)) && out+=" %F{red}~${conflicts}%f"
  ((staged > 0))    && out+=" %F{yellow}✚${staged}%f"
  ((unstaged > 0))  && out+=" %F{red}!${unstaged}%f"
  ((untracked > 0)) && out+=" %F{red}?${untracked}%f"
  ((stash > 0))     && out+=" %F{cyan}\$${stash}%f"
  ((ahead > 0))     && out+=" %F{green}⇡${ahead}%f"
  ((behind > 0))    && out+=" %F{red}⇣${behind}%f"

  print -r -- "$out"
}

# Called by zle when the background fd becomes readable
_git_prompt_callback() {
  local fd=$1
  zle -F $fd  # unregister handler

  local result
  IFS= read -r result <&$fd
  exec {fd}<&-
  _git_prompt_fd=-1

  _PROMPT_GIT=$result
  zle && zle reset-prompt
}

_git_prompt_precmd() {
  # Cancel previous async job if still running
  if (( _git_prompt_fd != -1 )); then
    zle -F $_git_prompt_fd 2>/dev/null
    exec {_git_prompt_fd}<&- 2>/dev/null
    _git_prompt_fd=-1
  fi

  # Outside a git repo: clear git info immediately
  if ! git rev-parse --git-dir &>/dev/null; then
    _PROMPT_GIT=""
    return
  fi

  # Spawn background process and register fd callback
  exec {_git_prompt_fd}< <(_git_prompt_compute)
  zle -F $_git_prompt_fd _git_prompt_callback
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _git_prompt_precmd

setopt PROMPT_SUBST
PROMPT='%F{31}%~%f${_PROMPT_GIT}
%(?.%F{76}❯%f.%F{196}❯%f) '
