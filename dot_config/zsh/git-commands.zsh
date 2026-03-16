function git_quicksave() {
  MESSAGE="quicksave $(date +"%Y-%m-%dT%H%M%S")"
  if [[ -n "$@" ]]; then
    MESSAGE="quicksave: $@"
  fi

  git commit -am "$MESSAGE"
  git reset HEAD~
}

function gh_pr_create() {
  if [[ -n "$BASE_BRANCH" ]]; then
    gh pr create --base "$BASE_BRANCH" "$@"
  else
    gh pr create "$@"
  fi
}

function cd_ghq() {
  local ghq_root=$(ghq root)
  local project_dir=$(ghq list | fzf --delimiter "/" --with-nth "2.." --preview "bat $ghq_root/{}/README.md")
  if [ "$project_dir" = "" ];then
    return 0
  fi

  cd "$ghq_root/$project_dir"
}
