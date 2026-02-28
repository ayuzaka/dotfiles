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
  local branch='' oid='' has_upstream=0
  local staged=0 unstaged=0 untracked=0 conflicts=0
  local ahead=0 behind=0
  local line

  # `--porcelain=v2 --branch` の 1 回の呼び出しでブランチ・upstream・ahead/behind・
  # 作業ツリー状態を全て取得 (旧実装の git 7 呼び出しを 1 回に集約)
  # --no-optional-locks: FETCH_HEAD 等の任意ロック取得を省略して高速化
  while IFS= read -r line; do
    case $line in
      '# branch.oid '*)
        # コミットハッシュ (detached HEAD 時にブランチ名として使用)
        oid="${line#\# branch.oid }"
        ;;
      '# branch.head '*)
        # ブランチ名。detached HEAD 時は "(detached)" という文字列になる
        branch="${line#\# branch.head }"
        [[ $branch == '(detached)' ]] && branch=''
        ;;
      '# branch.upstream '*)
        has_upstream=1
        ;;
      '# branch.ab '*)
        # "+N -M" 形式: ahead/behind のコミット数
        local ab="${line#\# branch.ab }"
        ahead="${${ab%% *}#+}"  # "+3 -2" → "3"
        behind="${ab##* -}"     # "+3 -2" → "2"
        ;;
      '1 '* | '2 '*)
        # 通常変更・リネーム/コピー行: 3文字目 = index 状態、4文字目 = worktree 状態
        # porcelain v2 では変更なしを '.' で表す (v1 はスペース)
        [[ ${line[3]} != '.' ]] && ((staged++))
        [[ ${line[4]} != '.' ]] && ((unstaged++))
        ;;
      'u '*)
        # unmerged (コンフリクト)
        ((conflicts++))
        ;;
      '? '*)
        ((untracked++))
        ;;
    esac
  done < <(git --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)

  # ブランチ名が空 = detached HEAD → oid 先頭 7 文字を使用
  if [[ -z $branch ]]; then
    [[ -z $oid || $oid == '(initial)' ]] && { print -r -- ""; return }
    branch="${oid[1,7]}"
  fi

  # upstream なしなら ahead/behind を非表示
  (( has_upstream == 0 )) && ahead=0 && behind=0

  # stash 数: wc -l を使わず純粋 zsh でカウント
  # (git worktree 対応のため logs/refs/stash 直読みではなく git stash list を維持)
  local _stash_out stash=0
  _stash_out=$(git stash list 2>/dev/null)
  [[ -n $_stash_out ]] && stash=${#${(f)_stash_out}}

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
# %~ = カレントディレクトリ, ${_PROMPT_GIT} = git ステータス (非同期で更新)
# %(?.ok.fail) = 直前コマンドの終了コードで色を切り替えた ❯
PROMPT='%F{31}%~%f${_PROMPT_GIT} %(?.%F{76}❯%f.%F{196}❯%f) '
