# fzf-comp.zsh
# zeno.zsh の completion 相当機能を純粋な zsh + fzf で実装
#
# ルールは fzf-comp.yaml に記述する。
# 起動時は YAML → zsh スクリプトのコンパイル結果をキャッシュするため、
# ルール変更時のみ Python3 が走り、通常起動のコストは mtime 比較のみ。

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
  fzf --height 80% --border --prompt="${lbuf}> "
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
# YAML ルールのロード（変更時のみコンパイル、通常は生成済みキャッシュを使用）
# ---------------------------------------------------------------------------
() {
  local yaml="${ZDOTDIR:-$HOME/.config/zsh}/fzf-comp.yaml"
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf-comp.zsh"

  # YAML が存在しキャッシュより新しい場合のみ再コンパイル
  if [[ -f "$yaml" ]] && { [[ ! -f "$cache" ]] || [[ "$yaml" -nt "$cache" ]] }; then
    mkdir -p "${cache:h}"
    python3 - "$yaml" "$cache" <<'PYTHON'
import sys

try:
    import yaml
except ImportError:
    print("fzf-comp: PyYAML が見つかりません。pip3 install pyyaml でインストールしてください", file=sys.stderr)
    sys.exit(1)


def zsh_sq(s):
    """zsh のシングルクォート安全文字列に変換する"""
    return "'" + s.replace("'", "'\\''") + "'"


try:
    with open(sys.argv[1]) as f:
        rules = yaml.safe_load(f)

    with open(sys.argv[2], "w") as f:
        f.write("# auto-generated from fzf-comp.yaml — do not edit directly\n")
        for rule in rules:
            f.write(f"_fzf_comp_add {zsh_sq(rule['pattern'])} {zsh_sq(rule['command'])}\n")
except Exception as e:
    print(f"fzf-comp: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON
  fi

  [[ -f "$cache" ]] && source "$cache"
}
