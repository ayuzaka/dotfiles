# prompt.zsh - Simple prompt showing current path and git status
# Replaces powerlevel10k

autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%b'
zstyle ':vcs_info:git:*' actionformats '%b (%a)'

_update_prompt() {
  vcs_info

  if [[ -n "${vcs_info_msg_0_}" ]]; then
    local staged=0 unstaged=0 untracked=0 ahead=0 behind=0 stash=0 conflicts=0
    local line x y

    while IFS= read -r line; do
      x="${line[1]}" y="${line[2]}"
      if [[ "$x" == '?' && "$y" == '?' ]]; then
        ((untracked++))
      elif [[ "$x" == 'U' || "$y" == 'U' || ( "$x" == 'A' && "$y" == 'A' ) || ( "$x" == 'D' && "$y" == 'D' ) ]]; then
        ((conflicts++))
      else
        [[ "$x" != ' ' ]] && ((staged++))
        [[ "$y" != ' ' ]] && ((unstaged++))
      fi
    done < <(git status --porcelain 2>/dev/null)

    stash=$(git stash list 2>/dev/null | wc -l)

    local tracking
    tracking=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [[ -n "$tracking" ]]; then
      ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
      behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
    fi

    _PROMPT_GIT=" %F{cyan} ${vcs_info_msg_0_}%f"
    ((conflicts > 0)) && _PROMPT_GIT+=" %F{red}~${conflicts}%f"
    ((staged > 0))    && _PROMPT_GIT+=" %F{yellow}✚${staged}%f"
    ((unstaged > 0))  && _PROMPT_GIT+=" %F{red}!${unstaged}%f"
    ((untracked > 0)) && _PROMPT_GIT+=" %F{red}?${untracked}%f"
    ((stash > 0))     && _PROMPT_GIT+=" %F{cyan}\$${stash}%f"
    ((ahead > 0))     && _PROMPT_GIT+=" %F{green}⇡${ahead}%f"
    ((behind > 0))    && _PROMPT_GIT+=" %F{red}⇣${behind}%f"
  else
    _PROMPT_GIT=""
  fi
}

add-zsh-hook precmd _update_prompt

setopt PROMPT_SUBST
PROMPT='%F{31}%~%f${_PROMPT_GIT}
%(?.%F{76}❯%f.%F{196}❯%f) '
