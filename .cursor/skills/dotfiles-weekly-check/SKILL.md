---
name: dotfiles-weekly-check
description: 週次点検で見つかった dotfiles の設定の修正を、動作確認つきのPRにする。起動時のプロンプトで渡された修正対象だけを直す。
---

# dotfiles 週次点検の修正

週次点検で「対応が必要」と分かった変更を、このリポジトリで直して PR にする。対象は、ツールのメジャーアップデート、破壊的変更、非推奨になった設定である。何を直すかは起動時のプロンプトで渡される。調べる作業そのものは、このスキルの対象外。

ファイルの置き場所、適用前の dry-run、`MISE_ENV`、Codex の設定、変更に合わせた確認の選び方は、リポジトリルートの `AGENTS.md` に従う。

1. 起動時のプロンプトで渡された修正対象だけを直す。差分は最小にする。ついでの整理や、渡されていないツールの更新はしない。`mise.work.toml`（仕事用プロファイルの mise 設定：`[tools]` と `[bootstrap.packages]`）も、他の設定ファイルと同じく、渡された修正対象なら直す。
2. 非推奨の設定は、新しい設定へ移す。警告を消すだけの回避はしない。直し方が複数あって判断に迷う場合は、PR を作らず、候補と推奨を最終報告に書いて止まる。
3. 動作確認は必須である。必要なツール（Neovim nightly、deno、mise など）は自分の環境に入れる。環境にないことを理由に確認を省かない。実際に起動して動くところまで確かめる。設定を適用して確認する場合は、先に `AGENTS.md` の dry-run を行う。手順は次のコマンドを基本にする。
   1. 作業ブランチを checkout する。
   2. `mise bootstrap --skip packages,dotfiles`（ツールのインストールに `mise install npm:typescript` は使わない）
   3. `nvim --headless '+Lazy! restore' +qa`（`dotfiles/.config/nvim/lazy-lock.json` のコミットに合わせる）
   4. そのうえで、修正した設定が実際に読み込まれて動くことを確認する。
   5. `mise.work.toml` が修正対象に含まれるときは、`[tools]` のツール（awscli、gcloud、stripe、yarn、lazydocker、`npm:@vtsls/language-server`、`npm:@vue/language-server`、`npm:aws-cdk`、`npm:ntn`、`pipx:awscli-local`、`github:docker/sbx-releases`）を、自分の環境で `mise` により入れて、バージョンと起動を確かめる。`MISE_ENV` はコマンドで上書きしない（`AGENTS.md`）。work 側の設定を読むための環境変数の扱い：未確認。`AGENTS.md` は `MISE_ENV` を Git 管理外の `mise.local.toml` に書くとだけ定めており、`mise.toml` には、どの値で `mise.work.toml` の `[tools]` を読むかが書いていない。値を推測してコマンドに書かない。
   6. `[bootstrap.packages]` の `brew-cask:*`（figma、slack、claude、docker-desktop）は macOS 専用で、クラウド環境では確認できない。この分は PR 説明の「手動確認が必要なこと」に書く。
   7. 仕事用の認証情報や会社のリポジトリ・データは扱わない。確認はツールのバージョンと起動までにする。
4. `line-notes.nvim`、`ddu-source-line-notes`、`ddu-source-git_blame`、`reader-mode.nvim` はユーザーの非公開リポジトリで取得できない。この分は「手動確認が必要なこと」に書く。
5. PR はマージしない。draft にはしない。タイトルと説明は日本語にする。説明には次の見出しを必ず入れる。
   - 「動作確認」：何をどう検証したか。そのままコピーして実行できるコマンドで書く。実行して確認できたことと、できなかったことを分ける。
   - 「手動確認が必要なこと」：ユーザーが自分の環境で確かめる必要があること。
   確認できなかったことを「できた」と書かない。
6. 最終報告では、作った PR のリンク、動作確認の結果、手動確認が必要な点を、日本語で短くまとめる。
