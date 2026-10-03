function git_quicksave() {
  MESSAGE="quicksave $(date +"%Y-%m-%dT%H%M%S")"
  if [[ -n "$@" ]]; then
    MESSAGE="quicksave: $@"
  fi

  git commit -am "$MESSAGE"
  git reset HEAD~
}

# fzf 共通: Esc / Ctrl-C / Ctrl-G で中断（ctrl-[ は fzf 未対応で bind 全体が壊れる）
function _fzf_select() {
  fzf --bind 'esc:abort,ctrl-c:abort,ctrl-g:abort' "$@"
}

# ghq repo を fuzzy 選択。キャンセル時は空文字。
function _select_ghq() {
  local ghq_root
  ghq_root="$(ghq root)"
  ghq list | _fzf_select --delimiter "/" --with-nth "2.." \
    --preview "bat $ghq_root/{}/README.md"
}

# 現 repo の worktree を fuzzy 選択し、絶対パスを返す。キャンセル時は空文字。
function _select_worktree() {
  local repo_root line wt_path label selected
  local -a candidates=()
  local -A wt_paths=()

  repo_root="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || {
    echo "not a git repository" >&2
    return 1
  }
  repo_root="$(dirname "$repo_root")"

  while IFS= read -r line; do
    [[ "$line" == worktree\ * ]] || continue
    wt_path="${line#worktree }"
    wt_path="${wt_path%/}"
    [[ -d "$wt_path" ]] || continue

    if [[ "$wt_path" == "$repo_root"/.git-wt/* ]]; then
      label="${wt_path#"$repo_root"/.git-wt/}"
    elif [[ "$wt_path" == "$repo_root"/.worktrees/* ]]; then
      label="${wt_path#"$repo_root"/.worktrees/}"
    else
      label="$(git -C "$wt_path" branch --show-current 2>/dev/null || basename "$wt_path")"
    fi

    # ghq list と同じ "/" 区切り。表示は with-nth 2..（w/chore/hoge → chore/hoge）
    candidates+=("w/$label")
    wt_paths["w/$label"]="$wt_path"
  done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null)

  if (( ${#candidates[@]} == 0 )); then
    echo "no worktrees found" >&2
    return 1
  fi

  selected="$(
    printf '%s\n' "${candidates[@]}" \
      | _fzf_select --ansi --delimiter "/" --with-nth "2.." \
        --preview "p=\$(echo {} | sed 's|^w/||'); d=\"$repo_root\"; if [ -d \"$repo_root/.git-wt/\$p\" ]; then d=\"$repo_root/.git-wt/\$p\"; elif [ -d \"$repo_root/.worktrees/\$p\" ]; then d=\"$repo_root/.worktrees/\$p\"; fi; git -C \"\$d\" log --oneline --decorate -n 20 --color=always"
  )" || return 0
  if [[ -z "$selected" ]]; then
    return 0
  fi

  print -r -- "${wt_paths["$selected"]}"
}

# checkout の herdr space を open / focus する（cd はしない）
# - server 上で space を focus
# - 今のシェルが herdr 外なら TUI を attach（open だけでは画面は切り替わらない）
function _herdr_open_checkout() {
  local checkout=$1
  local repo_root common_dir out

  [[ -d "$checkout" ]] || {
    echo "not a directory: $checkout" >&2
    return 1
  }

  common_dir="$(git -C "$checkout" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || {
    echo "not a git repository: $checkout" >&2
    return 1
  }
  repo_root="$(dirname "$common_dir")"

  out="$(herdr worktree open --cwd "$repo_root" --path "$checkout" --focus 2>&1)" || {
    echo "$out" >&2
    return 1
  }
  case "$out" in
    *\"error\"*)
      echo "$out" >&2
      return 1
      ;;
  esac

  # herdr 管理下の pane 内なら focus 済み。外から呼んだときだけ TUI を前面に出す。
  if [[ "${HERDR_ENV:-}" != 1 ]]; then
    herdr
  fi
}

function cd_ghq() {
  local ghq_root project_dir
  ghq_root="$(ghq root)"
  project_dir="$(_select_ghq)" || return 0
  if [[ -z "$project_dir" ]]; then
    return 0
  fi

  cd "$ghq_root/$project_dir"
}

# Current repo の worktree を fuzzy で選んで移動する（UI は cd_ghq と同じ fzf）
function cd_worktree() {
  local target
  target="$(_select_worktree)" || return $?
  if [[ -z "$target" ]]; then
    return 0
  fi

  cd "$target"
}

# cd_ghq と同じ選択 UI → 選んだ checkout の herdr space を open/focus（現シェルは cd しない）
function herdr_ghq() {
  local ghq_root project_dir
  ghq_root="$(ghq root)"
  project_dir="$(_select_ghq)" || return 0
  if [[ -z "$project_dir" ]]; then
    return 0
  fi

  _herdr_open_checkout "$ghq_root/$project_dir"
}

# cd_worktree と同じ選択 UI → 選んだ worktree の herdr space を open/focus（現シェルは cd しない）
function herdr_worktree() {
  local target
  target="$(_select_worktree)" || return $?
  if [[ -z "$target" ]]; then
    return 0
  fi

  _herdr_open_checkout "$target"
}

function cd_root() {
  local dir=$(roots | fzf --delimiter "/" --with-nth "2.." --preview "glow {}/README.md")
  if [ "$dir" = "" ];then
    return 0
  fi

  cd "$dir"
}
