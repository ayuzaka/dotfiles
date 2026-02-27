# fzf-comp.zsh
# zeno.zsh の completion 相当機能を純粋な zsh + fzf で実装
#
# 使い方:
#   _fzf_comp_add <pattern> <source> <prompt> [callback]
#
#   pattern  : LBUFFER にマッチさせる ERE 正規表現
#   source   : fzf に渡す候補を生成するシェルコマンド（eval される）
#   prompt   : fzf のプロンプト文字列（$lbuf を含めると LBUFFER の内容が展開される）
#   callback : fzf の出力を加工するコマンド（省略時はそのまま）
#
# 新しいルールを追加したい場合は _fzf_comp_add を呼ぶだけでよい。
# ウィジェット本体のコードを変更する必要はない。

typeset -ga _FZF_COMP_PATTERNS=()
typeset -ga _FZF_COMP_SOURCES=()
typeset -ga _FZF_COMP_CALLBACKS=()
typeset -ga _FZF_COMP_PROMPTS=()

_fzf_comp_add() {
  # Usage: _fzf_comp_add <pattern> <source> <prompt> [callback]
  _FZF_COMP_PATTERNS+=("$1")
  _FZF_COMP_SOURCES+=("$2")
  _FZF_COMP_PROMPTS+=("$3")
  _FZF_COMP_CALLBACKS+=("${4:-cat}")
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
      result=$(
        eval "${_FZF_COMP_SOURCES[$i]}" 2>/dev/null \
          | fzf --height 80% --border --prompt="${(e)_FZF_COMP_PROMPTS[$i]}" \
          | eval "${_FZF_COMP_CALLBACKS[$i]}"
      )
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
  'tmux ls' \
  'tmux attach > ' \
  "awk -F ':' '{print \$1}'"

_fzf_comp_add \
  '^tmux kill-session -t( .*)? $' \
  'tmux ls' \
  'tmux kill-session > ' \
  "awk -F ':' '{print \$1}'"

_fzf_comp_add \
  '^tmux send-keys -t( .*)? $' \
  "tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{session_name}:#{window_name} [#{pane_current_command}]'" \
  'tmux send-keys -t > ' \
  "awk '{print \$1}'"

# --- npm / yarn / pnpm / bun / ni scripts ---
_fzf_comp_add \
  '^(npm|yarn|pnpm|bun|ni) run( .*)? $' \
  "jq -r '.scripts | to_entries | .[] | .key + \" = \" + .value' package.json" \
  'run > ' \
  "awk -F ' = ' '{print \$1}'"

# --- deno tasks ---
_fzf_comp_add \
  '^deno task( .*)? $' \
  "jq -r '.tasks | to_entries | .[] | .key + \" = \" + .value' deno.jsonc" \
  'deno task > ' \
  "awk -F ' = ' '{print \$1}'"

# --- act (GitHub Actions local runner) ---
_fzf_comp_add \
  '^act --job( .*)?$' \
  "act --list 2>/dev/null | grep -v Stage | awk '{print \$2}'" \
  'act --job > '

# --- ssh / scp ---
_fzf_comp_add \
  '^ssh( .*)? $' \
  "cat \$HOME/.ssh/*.conf 2>/dev/null | grep '^Host' | awk '{print \$2}'" \
  'ssh > '

_fzf_comp_add \
  '^scp( .*)? $' \
  "cat \$HOME/.ssh/*.conf 2>/dev/null | grep '^Host' | awk '{print \$2}'" \
  'scp > '

# --- gcloud ---
_fzf_comp_add \
  '^gcloud config configurations activate( .*)?$' \
  "gcloud config configurations list --format 'value(name)'" \
  'gcloud config > '

# --- git switch ---
_fzf_comp_add \
  '^git switch( .*)? $' \
  "git for-each-ref --format='%(refname:short) - %(contents:subject)' refs/heads/" \
  'git switch > ' \
  "awk '{print \$1}'"

# --- git worktree switch ---
_fzf_comp_add \
  '^git wt?( )$' \
  "git wt 2>/dev/null | grep -v -F -e '*' -e 'BRANCH' | awk '{print \$2}'" \
  'git-wt switch > '

# --- git worktree delete ---
_fzf_comp_add \
  '^git wt -(d|D)( .*)? $' \
  "git wt 2>/dev/null | grep -v -F -e '*' -e 'BRANCH' | awk '{print \$2}'" \
  'git worktree remove > '

# --- git branch delete ---
_fzf_comp_add \
  '^git branch -d( .*)? $' \
  "git for-each-ref --format='%(refname:short)' refs/heads --merged" \
  'git branch -d > ' \
  "grep -v -x -F -e develop -e main -e master -e \"\$(git symbolic-ref --short HEAD 2>/dev/null)\" | awk '{print \$1}'"

# --- gh issue edit ---
_fzf_comp_add \
  '^gh issue edit( .*)? $' \
  'gh issue list --assignee @me --state open --limit 1000' \
  'gh issue edit > ' \
  "awk '{print \$1}'"

# --- gh pr checkout ---
_fzf_comp_add \
  '^gh pr checkout( .*)? $' \
  "gh pr list --json number,title,author --jq '.[] | [(.number | tostring), .title, .author.login] | join(\",\")'" \
  'gh pr checkout > ' \
  "awk -F ',' '{print \$1}'"

# --- docker container exec / stop ---
_fzf_comp_add \
  '^docker (container exec( -it)?|exec|container stop)( .*)? $' \
  "docker container ls --format '{{.Names}}'" \
  'docker container > '

# --- docker container rm ---
_fzf_comp_add \
  '^docker container rm( .*)? $' \
  "docker container ls -a --format '{{.Names}}'" \
  'docker container rm > '

# --- docker image rm ---
_fzf_comp_add \
  '^docker image rm( .*)? $' \
  "docker image ls --format '{{.Repository}}:{{.Tag}}:{{.ID}}'" \
  'docker image rm > ' \
  "awk -F ':' '{print \$3}'"
