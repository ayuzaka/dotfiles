function git_quicksave() {
  MESSAGE="quicksave $(date +"%Y-%m-%dT%H%M%S")"
  if [[ -n "$@" ]]; then
    MESSAGE="quicksave: $@"
  fi

  git commit -am "$MESSAGE"
  git reset HEAD~
}

function cd_ghq() {
  local ghq_root=$(ghq root)
  local project_dir=$(ghq list | fzf --preview "bat $ghq_root/{}/README.md")
  if [ "$project_dir" = "" ];then
    return 0
  fi

  cd "$ghq_root/$project_dir"
}
