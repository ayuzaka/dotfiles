# prompt.zsh - カレントパスと git ステータスを表示するシンプルなプロンプト
#
# 【非同期の仕組み】
#   1. コマンド実行後 (precmd) にバックグラウンドプロセスで git コマンドを起動
#   2. 結果はパイプ経由でファイルディスクリプタ (fd) に流れる
#   3. zle -F で fd が読み取り可能になったタイミングを監視
#   4. 完了したら _PROMPT_GIT を更新し zle reset-prompt でプロンプトを再描画
#
# 【表示内容】
#   %~                カレントディレクトリ (ホームは ~ に省略)
#    ブランチ名      git ブランチ (detached HEAD 時はコミットハッシュ)
#   ~N                コンフリクト数
#   ✚N                staged (インデックスに追加済みの変更) 数
#   !N                unstaged (作業ツリーの変更) 数
#   ?N                untracked (未追跡) ファイル数
#   $N                stash 数
#   ⇡N / ⇣N           リモートより N コミット ahead / behind
#   ❯                 成功時は緑、直前のコマンドが失敗した場合は赤

# バックグラウンドプロセスとの通信に使う fd。-1 = 未使用
typeset -g _git_prompt_fd=-1

# バックグラウンドで実行: git ステータス文字列を stdout に出力して終了する
_git_prompt_compute() {
  # ブランチ名を取得。detached HEAD の場合は短縮コミットハッシュを使う
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(git rev-parse --short HEAD 2>/dev/null) \
    || { print -r -- ""; return }

  # `git status --porcelain` の各行を解析してカウントする
  # 行の 1 文字目 (x) = インデックス状態、2 文字目 (y) = 作業ツリー状態
  local staged=0 unstaged=0 untracked=0 conflicts=0 line x y
  while IFS= read -r line; do
    x="${line[1]}" y="${line[2]}"
    if   [[ $x == '?' && $y == '?' ]]; then ((untracked++))
    elif [[ $x == 'U' || $y == 'U' || ($x == 'A' && $y == 'A') || ($x == 'D' && $y == 'D') ]]; then ((conflicts++))
    else
      [[ $x != ' ' ]] && ((staged++))
      [[ $y != ' ' ]] && ((unstaged++))
    fi
  done < <(git --no-optional-locks status --porcelain 2>/dev/null)
  # --no-optional-locks: FETCH_HEAD 等の任意ロック取得を省略して高速化

  local stash=0
  stash=$(git stash list 2>/dev/null | wc -l)

  # upstream が設定されている場合のみ ahead/behind を計算
  local ahead=0 behind=0 tracking
  tracking=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  if [[ -n $tracking ]]; then
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
  fi

  # PROMPT_SUBST で展開される %F{color}...%f 形式の文字列を組み立てる
  local out=" %F{cyan} ${branch}%f"
  ((conflicts > 0)) && out+=" %F{red}~${conflicts}%f"
  ((staged > 0))    && out+=" %F{yellow}✚${staged}%f"
  ((unstaged > 0))  && out+=" %F{red}!${unstaged}%f"
  ((untracked > 0)) && out+=" %F{red}?${untracked}%f"
  ((stash > 0))     && out+=" %F{cyan}\$${stash}%f"
  ((ahead > 0))     && out+=" %F{green}⇡${ahead}%f"
  ((behind > 0))    && out+=" %F{red}⇣${behind}%f"

  print -r -- "$out"
}

# zle が fd の読み取り可能を検知したときに呼ばれるコールバック
_git_prompt_callback() {
  local fd=$1
  zle -F $fd  # このコールバックの登録を解除

  local result
  IFS= read -r result <&$fd  # バックグラウンドプロセスの出力を受け取る
  exec {fd}<&-                # fd を閉じる
  _git_prompt_fd=-1

  _PROMPT_GIT=$result
  zle && zle reset-prompt  # プロンプトを再描画
}

# precmd フック: コマンド実行後、次のプロンプト表示前に毎回呼ばれる
_git_prompt_precmd() {
  # 前回の非同期ジョブが完了前なら破棄して再起動
  if (( _git_prompt_fd != -1 )); then
    zle -F $_git_prompt_fd 2>/dev/null
    exec {_git_prompt_fd}<&- 2>/dev/null
    _git_prompt_fd=-1
  fi

  # git リポジトリ外なら即座にクリアして終了
  if ! git rev-parse --git-dir &>/dev/null; then
    _PROMPT_GIT=""
    return
  fi

  # バックグラウンドプロセスを起動し fd を登録
  exec {_git_prompt_fd}< <(_git_prompt_compute)
  zle -F $_git_prompt_fd _git_prompt_callback
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _git_prompt_precmd

# PROMPT_SUBST: プロンプト文字列内の ${...} や %(...) を毎回展開する
setopt PROMPT_SUBST
# 1行目: %~ = カレントディレクトリ, ${_PROMPT_GIT} = git ステータス (非同期で更新)
# 2行目: %(?.ok.fail) = 直前コマンドの終了コードで色を切り替えた ❯
PROMPT='%F{31}%~%f${_PROMPT_GIT}
%(?.%F{76}❯%f.%F{196}❯%f) '
