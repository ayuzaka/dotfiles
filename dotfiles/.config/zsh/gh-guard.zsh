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

  # work 環境は organization 向けに GitHub CLI の認証を使う
  if [[ ${MISE_ENV:-} == work ]]; then
    command gh "$@"
    return
  fi

  if [[ -n ${GH_TOKEN:-} || -n ${GITHUB_TOKEN:-} ]]; then
    command gh "$@"
    return
  fi

  # work では ghtkn を入れない。private でも未インストールなら素の gh に落とす
  if ! command -v ghtkn >/dev/null 2>&1; then
    command gh "$@"
    return
  fi

  # ghtkn は PATH 上の gh を実行するので、この関数は再入しない
  ghtkn exec -e GH_TOKEN -- gh "$@"
}
