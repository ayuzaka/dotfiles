# fzf-comp.zsh
# zeno.zsh の completion 相当機能を純粋な zsh + fzf で実装
#
# ルールは fzf-comp.yaml に記述する。
# 起動時に純粋な zsh で読み込むため、外部ツール不要・キャッシュ不要。

typeset -ga _FZF_COMP_PATTERNS=()
typeset -ga _FZF_COMP_COMMANDS=()

_fzf_comp_add() {
  # Usage: _fzf_comp_add <pattern> <command>
  _FZF_COMP_PATTERNS+=("$1")
  _FZF_COMP_COMMANDS+=("$2")
}

# fzf-comp.yaml の command 内で fzf の代わりに使うヘルパー。
# 一貫したオプションと LBUFFER ベースのプロンプトを提供する。
# $lbuf は _fzf_complete の local 変数で、動的スコープにより参照できる。
_fzf_run() {
  fzf --height 80% --border --prompt="${lbuf}> " "$@"
}

# ブランチ・タグ・コミットを切り替えながら選択するヘルパー。
# git rebase / git checkout など複数のルールから共有する。
_fzf_git_ref() {
  git for-each-ref --format='%(refname:short)' refs/heads/ refs/tags/ \
    | _fzf_run \
        --header 'ctrl-b: branches/tags  ctrl-l: commits' \
        --bind 'ctrl-l:reload(git log --format="%h  %s" --color=never)+change-header(commits  ctrl-b: branches/tags)' \
        --bind 'ctrl-b:reload(git for-each-ref --format="%(refname:short)" refs/heads/ refs/tags/)+change-header(branches/tags  ctrl-l: commits)' \
    | awk '{print $1}'
}

# ---------------------------------------------------------------------------
# ウィジェット本体
# ---------------------------------------------------------------------------
_fzf_complete() {
  local lbuf="$LBUFFER"
  local i n="${#_FZF_COMP_PATTERNS[@]}"

  for (( i = 1; i <= n; i++ )); do
    if [[ "$lbuf" =~ ${_FZF_COMP_PATTERNS[$i]} ]]; then
      local result
      result=$(eval "${_FZF_COMP_COMMANDS[$i]}" 2>/dev/null)
      if [[ -n "$result" ]]; then
        LBUFFER+="${result} "
        zle reset-prompt
      fi
      return
    fi
  done

  zle expand-or-complete
}

zle -N _fzf_complete
bindkey -M viins '^I' _fzf_complete
bindkey -M emacs  '^I' _fzf_complete

# ---------------------------------------------------------------------------
# fzf-comp.yaml をパースしてルールを登録（純粋な zsh、外部コマンド不要）
# ---------------------------------------------------------------------------
() {
  local yaml="${ZDOTDIR:-$HOME/.config/zsh}/fzf-comp.yaml"
  [[ ! -f "$yaml" ]] && return

  local line current_pattern
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      '- pattern: '*|'pattern: '*)
        current_pattern="${line#- pattern: }"
        current_pattern="${current_pattern#pattern: }"
        ;;
      '  command: '*|'command: '*)
        local current_command="${line#  command: }"
        current_command="${current_command#command: }"
        _fzf_comp_add "$current_pattern" "$current_command"
        ;;
    esac
  done < "$yaml"
}
