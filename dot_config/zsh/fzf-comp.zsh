# fzf-comp.zsh
# zeno.zsh の completion 相当機能を純粋な zsh + fzf で実装
#
# 使い方:
#   _fzf_comp_add <pattern> <command>
#
#   pattern : LBUFFER にマッチさせる ERE 正規表現
#   command : 候補生成・fzf 呼び出し・出力加工を含む完全なパイプライン（eval される）
#             _fzf_run を fzf の代わりに使うと一貫したオプションとプロンプトが適用される
#             プロンプトには $lbuf（LBUFFER の内容）が使える
#
# 新しいルールを追加したい場合は _fzf_comp_add を呼ぶだけでよい。
# ウィジェット本体のコードを変更する必要はない。

typeset -ga _FZF_COMP_PATTERNS=()
typeset -ga _FZF_COMP_COMMANDS=()

_fzf_comp_add() {
  # Usage: _fzf_comp_add <pattern> <command>
  _FZF_COMP_PATTERNS+=("$1")
  _FZF_COMP_COMMANDS+=("$2")
}

# _fzf_comp_add の command 内で fzf の代わりに使うヘルパー。
# 一貫したオプションと LBUFFER ベースのプロンプトを提供する。
_fzf_run() {
  fzf --height 80% --border --prompt="${lbuf}> "
}

# ---------------------------------------------------------------------------
# ウィジェット本体
# LBUFFER を登録済みパターンと順番に照合し、最初にマッチしたルールで fzf を起動。
# どのパターンにも一致しない場合は通常の zsh 補完 (expand-or-complete) にフォールスルー。
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
# ルール定義
# ---------------------------------------------------------------------------

# --- tmux ---
_fzf_comp_add \
  '^tmux (a|attach) -t( .*)? $' \
  "tmux ls | _fzf_run | awk -F ':' '{print \$1}'"

_fzf_comp_add \
  '^tmux kill-session -t( .*)? $' \
  "tmux ls | _fzf_run | awk -F ':' '{print \$1}'"

_fzf_comp_add \
  '^tmux send-keys -t( .*)? $' \
  "tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{session_name}:#{window_name} [#{pane_current_command}]' | _fzf_run | awk '{print \$1}'"

# --- npm / yarn / pnpm / bun / ni scripts ---
_fzf_comp_add \
  '^(npm|yarn|pnpm|bun|ni) run( .*)? $' \
  "jq -r '.scripts | to_entries | .[] | .key + \" = \" + .value' package.json | _fzf_run | awk -F ' = ' '{print \$1}'"

# --- deno tasks ---
_fzf_comp_add \
  '^deno task( .*)? $' \
  "jq -r '.tasks | to_entries | .[] | .key + \" = \" + .value' deno.jsonc | _fzf_run | awk -F ' = ' '{print \$1}'"

# --- act (GitHub Actions local runner) ---
_fzf_comp_add \
  '^act --job( .*)?$' \
  "act --list 2>/dev/null | grep -v Stage | awk '{print \$2}' | _fzf_run"

# --- ssh / scp ---
_fzf_comp_add \
  '^ssh( .*)? $' \
  "cat \$HOME/.ssh/*.conf 2>/dev/null | grep '^Host' | awk '{print \$2}' | _fzf_run"

_fzf_comp_add \
  '^scp( .*)? $' \
  "cat \$HOME/.ssh/*.conf 2>/dev/null | grep '^Host' | awk '{print \$2}' | _fzf_run"

# --- gcloud ---
_fzf_comp_add \
  '^gcloud config configurations activate( .*)?$' \
  "gcloud config configurations list --format 'value(name)' | _fzf_run"

# --- git switch ---
_fzf_comp_add \
  '^git switch( .*)? $' \
  "git for-each-ref --format='%(refname:short) - %(contents:subject)' refs/heads/ | _fzf_run | awk '{print \$1}'"

# --- git worktree switch ---
_fzf_comp_add \
  '^git wt?( )$' \
  "git wt 2>/dev/null | grep -v -F -e '*' -e 'BRANCH' | awk '{print \$2}' | _fzf_run"

# --- git worktree delete ---
_fzf_comp_add \
  '^git wt -(d|D)( .*)? $' \
  "git wt 2>/dev/null | grep -v -F -e '*' -e 'BRANCH' | awk '{print \$2}' | _fzf_run"

# --- git branch delete ---
_fzf_comp_add \
  '^git branch -d( .*)? $' \
  "git for-each-ref --format='%(refname:short)' refs/heads --merged \
    | grep -v -x -F -e develop -e main -e master -e \"\$(git symbolic-ref --short HEAD 2>/dev/null)\" \
    | _fzf_run"

# --- gh issue edit ---
_fzf_comp_add \
  '^gh issue edit( .*)? $' \
  "gh issue list --assignee @me --state open --limit 1000 | _fzf_run | awk '{print \$1}'"

# --- gh pr checkout ---
_fzf_comp_add \
  '^gh pr checkout( .*)? $' \
  "gh pr list --json number,title,author --jq '.[] | [(.number | tostring), .title, .author.login] | join(\",\")' | _fzf_run | awk -F ',' '{print \$1}'"

# --- docker container exec / stop ---
_fzf_comp_add \
  '^docker (container exec( -it)?|exec|container stop)( .*)? $' \
  "docker container ls --format '{{.Names}}' | _fzf_run"

# --- docker container rm ---
_fzf_comp_add \
  '^docker container rm( .*)? $' \
  "docker container ls -a --format '{{.Names}}' | _fzf_run"

# --- docker image rm ---
_fzf_comp_add \
  '^docker image rm( .*)? $' \
  "docker image ls --format '{{.Repository}}:{{.Tag}}:{{.ID}}' | _fzf_run | awk -F ':' '{print \$3}'"
