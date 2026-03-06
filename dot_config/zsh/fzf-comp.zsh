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
  local ref escaped_ref
  ref=$(
    git for-each-ref --format='%(refname:short)' refs/heads/ refs/tags/ \
    | _fzf_run \
        --header 'ctrl-b: branches/tags  ctrl-l: commits' \
        --bind 'ctrl-l:reload(git log --format="%h  %s" --color=never)+change-header(commits  ctrl-b: branches/tags)' \
        --bind 'ctrl-b:reload(git for-each-ref --format="%(refname:short)" refs/heads/ refs/tags/)+change-header(branches/tags  ctrl-l: commits)' \
    | awk '{print $1}'
  )

  escaped_ref="${ref//\'/\'\\\'\'}"
  printf "'%s'\n" "$escaped_ref"
}

# package.json の workspaces 設定と pnpm-workspace.yaml から
# 各 workspace の package.json を列挙する。
_fzf_workspace_package_jsons() {
  emulate -L zsh
  setopt typeset_silent
  unsetopt xtrace

  local -a workspace_globs workspace_package_jsons

  local package_json="package.json"
  if [[ -f "$package_json" ]]; then
    workspace_globs+=("${(@f)$(jq -r '
      .workspaces as $w
      | if ($w | type) == "array" then
          $w[]
        elif ($w | type) == "object" and ($w.packages | type) == "array" then
          $w.packages[]
        else
          empty
        end
    ' "$package_json")}")
  fi

  local pnpm_workspace_yaml="pnpm-workspace.yaml"
  if [[ -f "$pnpm_workspace_yaml" ]]; then
    workspace_globs+=("${(@f)$(awk '
      /^packages:[[:space:]]*$/ {
        in_packages = 1
        next
      }
      in_packages == 1 && /^[^[:space:]-]/ {
        in_packages = 0
      }
      in_packages == 1 && /^[[:space:]]*-[[:space:]]*/ {
        line = $0
        sub(/^[[:space:]]*-[[:space:]]*/, "", line)
        sub(/^["\047]/, "", line)
        sub(/["\047]$/, "", line)
        print line
      }
    ' "$pnpm_workspace_yaml")}")
  fi

  local workspace_glob
  for workspace_glob in "${workspace_globs[@]}"; do
    workspace_package_jsons+=(${~workspace_glob}/package.json(N))
  done

  print -r -l ${(u)workspace_package_jsons}
}
_fzf_root_scripts() {
  emulate -L zsh
  setopt typeset_silent
  unsetopt xtrace

  local package_json="package.json"
  [[ ! -f "$package_json" ]] && return 0

  jq -r '
    (.scripts // {}) | to_entries[]?
    | .key + " = root / " + .key + " = " + .value
  ' "$package_json"
}

# run 系コマンド向けに、ルートと workspaces の scripts を候補化する。
# 選択結果は `* run ...` の引数としてそのまま追記できる形式で返す。
_fzf_workspace_run_target() {
  emulate -L zsh
  setopt typeset_silent
  unsetopt xtrace

  local root_prefix="$1"
  local workspace_prefix_format="$2"
  local include_root="$3"

  local candidates=""
  if [[ "$include_root" == "1" ]]; then
    local package_json="package.json"
    [[ ! -f "$package_json" ]] && return 0

    local root_candidates
    root_candidates=$(
      jq -r --arg root_prefix "$root_prefix" '
        (.scripts // {}) | to_entries[]?
        | ($root_prefix + .key) + " = root / " + .key + " = " + .value
      ' "$package_json"
    )
    candidates+="$root_candidates"$'\n'
  fi

  local -a workspace_package_jsons
  workspace_package_jsons=("${(@f)$(_fzf_workspace_package_jsons)}")

  local workspace_package
  for workspace_package in "${workspace_package_jsons[@]}"; do
    local workspace_name
    workspace_name=$(jq -r '.name // empty' "$workspace_package")
    [[ -z "$workspace_name" ]] && continue

    local workspace_prefix
    workspace_prefix=$(printf "$workspace_prefix_format" "$workspace_name")

    local workspace_candidates
    workspace_candidates=$(
      jq -r --arg workspace_name "$workspace_name" --arg workspace_prefix "$workspace_prefix" '
        (.scripts // {}) | to_entries[]?
        | ($workspace_prefix + .key) + " = " + $workspace_name + " / " + .key + " = " + .value
      ' "$workspace_package"
    )
    [[ -n "$workspace_candidates" ]] && candidates+="$workspace_candidates"$'\n'
  done

  printf '%s' "$candidates" \
    | awk 'NF' \
    | _fzf_run \
    | awk -F ' = ' '{print $1}'
}
_fzf_root_run_target() {
  emulate -L zsh
  setopt typeset_silent
  unsetopt xtrace

  local script_prefix="$1"
  _fzf_root_scripts \
    | _fzf_run \
    | awk -F ' = ' -v script_prefix="$script_prefix" '{print script_prefix $1}'
}

_fzf_npm_run_target() {
  _fzf_workspace_run_target '' '-w %s ' 1
}

_fzf_npm_workspace_target() {
  _fzf_workspace_run_target '' '%s run ' 0
}

_fzf_npm_root_target() {
  _fzf_root_run_target 'run '
}

_fzf_pnpm_run_target() {
  _fzf_workspace_run_target '' '--filter %s ' 1
}

_fzf_pnpm_filter_target() {
  _fzf_workspace_run_target '' '%s run ' 0
}

_fzf_pnpm_root_target() {
  _fzf_root_run_target ''
}

_fzf_bun_run_target() {
  _fzf_workspace_run_target '' '--filter %s ' 1
}

_fzf_bun_filter_target() {
  _fzf_workspace_run_target '' '%s run ' 0
}

_fzf_bun_root_target() {
  _fzf_root_run_target 'run '
}

_fzf_yarn_workspace_run_target() {
  _fzf_workspace_run_target '' '%s run ' 0
}

_fzf_yarn_root_target() {
  _fzf_root_run_target ''
}

# ---------------------------------------------------------------------------
# ウィジェット本体
# ---------------------------------------------------------------------------
_fzf_complete() {
  local lbuf="$LBUFFER"
  local match_lbuf="$lbuf"
  local i n="${#_FZF_COMP_PATTERNS[@]}"

  # ;, |, & などで連結された場合は、最後のコマンド断片だけを対象にする。
  match_lbuf="${match_lbuf##*[;&|]}"
  # 断片先頭の空白を除去する。
  match_lbuf="${match_lbuf#"${match_lbuf%%[![:space:]]*}"}"

  # 先頭に付与された環境変数代入（KEY=VALUE）を取り除いてマッチ判定する。
  # 例: COPYFILE_DISABLE=1 yarn  -> yarn
  while [[ "$match_lbuf" =~ ^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]+[[:space:]]+.+$ ]]; do
    match_lbuf="${match_lbuf#* }"
  done

  for (( i = 1; i <= n; i++ )); do
    local candidate="$match_lbuf"
    while true; do
      if [[ "$candidate" =~ ${_FZF_COMP_PATTERNS[$i]} ]]; then
        local result
        zle -I
        result=$(eval "${_FZF_COMP_COMMANDS[$i]}" 2>/dev/null)
        if [[ -n "$result" ]]; then
          if [[ "$LBUFFER" == *" " ]]; then
            LBUFFER+="${result} "
          else
            LBUFFER+=" ${result} "
          fi
          zle reset-prompt
        fi
        return
      fi

      [[ "$candidate" != *" "* ]] && break
      candidate="${candidate#* }"
    done
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
