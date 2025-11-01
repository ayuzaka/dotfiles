function git_quicksave() {
  MESSAGE="quicksave $(date +"%Y-%m-%dT%H%M%S")"
  if [[ -n "$@" ]]; then
    MESSAGE="quicksave: $@"
  fi

  git commit -am "$MESSAGE"
  git reset HEAD~
}

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
