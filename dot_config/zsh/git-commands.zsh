function git_quicksave() {
  MESSAGE="quicksave $(date +"%Y-%m-%dT%H%M%S")"
  if [[ -n "$@" ]]; then
    MESSAGE="quicksave: $@"
  fi

  git commit -am "$MESSAGE"
  git reset HEAD~
}
