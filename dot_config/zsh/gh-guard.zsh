gh() {
  if [[ "$1" == "auth" && "$2" == "token" ]]; then
    print -u2 "blocked: gh auth token is disabled"
    return 1
  fi

  if [[ "$1" == "auth" && "$2" == "status" ]]; then
    local arg
    for arg in "$@"; do
      if [[ "$arg" == "--show-token" || "$arg" == "-t" ]]; then
        print -u2 "blocked: gh auth status --show-token is disabled"
        return 1
      fi
    done
  fi

  command gh "$@"
}
