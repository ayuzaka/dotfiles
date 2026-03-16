typeset -gA ZSH_ABBR_MAP

ZSH_ABBR_MAP=(
  ll 'lsd -lh'
  la 'lsd -lah'
  cl 'clear'
  dcon-exec 'devcontainer exec --workspace-folder . /bin/bash -i'
  golint 'golangci-lint'
  gu 'gitui'
  ol 'ollama'
  ls-img 'img2sixel'
  gcloud-switch 'gcloud config configurations activate'
  swh 'sips -g pixelWidth -g pixelHeight'
  sql 'lazysql'
  psp 'ps -fp "$(lsof -t -i :__CURSOR__)"'
  h 'cat $HISTFILE | fzf | pbcopy'
  cg 'cd_ghq'
  dc-exec 'docker container exec -it'
  gpf 'git push --force-with-lease'
  git-tree "git log --graph --pretty=format:'%x09%C(auto) %h %Cgreen %cd %Creset%x09%C(cyan ul)%an%Creset %x09%C(auto)%s %d' --date=format:'%Y-%m-%d (%a)'"
  gm 'git switch main'
  gs 'git switch'
  gc 'git checkout'
  gch 'git rev-parse HEAD'
  gsave 'git_quicksave'
  gh-pr-me 'gh pr list --author "@me" --state all'
  gh-pr-search "gh pr list --state all --json number,title --jq \".[] | [.number,.title] | @csv\" --search \"__CURSOR__\" | fzf | awk -F ',' '{print \$1}' | xargs gh browse"
  ghe 'gh copilot explain "__CURSOR__"'
  restore 'git checkout __CURSOR__ -- .'
)

function _zle_abbr_expand() {
  local key expansion prefix prefix_len cursor_marker before after

  key="${LBUFFER##* }"
  expansion="${ZSH_ABBR_MAP[$key]}"

  if [[ -z "$expansion" ]]; then
    return 1
  fi

  prefix_len=$(( ${#LBUFFER} - ${#key} ))
  if (( prefix_len > 0 )); then
    prefix="${LBUFFER[1,prefix_len]}"
  else
    prefix=""
  fi

  cursor_marker="__CURSOR__"
  if [[ "$expansion" == *"$cursor_marker"* ]]; then
    before="${expansion%%$cursor_marker*}"
    after="${expansion#*$cursor_marker}"
    LBUFFER="${prefix}${before}${after}"
    CURSOR=$(( ${#prefix} + ${#before} ))
    return 2
  fi

  LBUFFER="${prefix}${expansion}"
  return 0
}

function zle-abbr-expand-space() {
  _zle_abbr_expand
  local exit_code=$?

  if (( exit_code != 2 )); then
    zle .self-insert
  fi
}

function zle-abbr-expand-accept-line() {
  _zle_abbr_expand
  zle .accept-line
}

zle -N zle-abbr-expand-space
zle -N zle-abbr-expand-accept-line
bindkey -M emacs " " zle-abbr-expand-space
bindkey -M viins " " zle-abbr-expand-space
bindkey -M emacs "^M" zle-abbr-expand-accept-line
bindkey -M viins "^M" zle-abbr-expand-accept-line
