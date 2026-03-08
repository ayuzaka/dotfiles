#!/bin/sh
set -e

# tide 設定（Lean スタイル）
# このファイルの内容が変わるたびに chezmoi apply で再実行される
fish << 'FISH'
# プロンプトレイアウト
set -U tide_left_prompt_items pwd git newline character
set -U tide_right_prompt_items status cmd_duration context jobs direnv

# プロンプトスタイル
set -U tide_prompt_add_newline_before false
set -U tide_prompt_pad_items false
set -U tide_prompt_min_cols 34
set -U tide_prompt_color_frame_and_connection 6C6C6C
set -U tide_prompt_color_separator_same_color 949494
set -U tide_prompt_icon_connection " "
set -U tide_prompt_transient_enabled false

# character（プロンプト記号）
set -U tide_character_icon ❯
set -U tide_character_color 5FD700
set -U tide_character_color_failure FF0000
set -U tide_character_vi_icon_default ❮
set -U tide_character_vi_icon_replace ▶
set -U tide_character_vi_icon_visual V

# pwd（ディレクトリ表示）
set -U tide_pwd_color_anchors 00AFFF
set -U tide_pwd_color_dirs 0087AF
set -U tide_pwd_color_truncated_dirs 8787AF
set -U tide_pwd_icon ""
set -U tide_pwd_icon_home ""
set -U tide_pwd_icon_unwritable ""
set -U tide_pwd_truncation_length 48
set -U tide_pwd_markers .git .node-version .python-version .ruby-version .shorten_folder_marker .terraform .vagrant

# git
set -U tide_git_icon ""
set -U tide_git_color_branch 5FD700
set -U tide_git_color_operation FF0000
set -U tide_git_color_conflicted FF0000
set -U tide_git_color_staged FFA500
set -U tide_git_color_dirty E4E400
set -U tide_git_color_untracked 00AFFF
set -U tide_git_color_upstream 5FD700
set -U tide_git_color_stash B48EAD
set -U tide_git_truncation_length 24
set -U tide_git_truncation_strategy ""

# status（前コマンドの終了ステータス）
set -U tide_status_color 5FD700
set -U tide_status_color_failure FF0000
set -U tide_status_icon ✔
set -U tide_status_icon_failure ✘

# cmd_duration（コマンド実行時間）
set -U tide_cmd_duration_color FFA500
set -U tide_cmd_duration_decimals 0
set -U tide_cmd_duration_icon ""
set -U tide_cmd_duration_threshold 3000

# context（user@host、SSH 接続時のみ表示）
set -U tide_context_always_display false
set -U tide_context_color_default 87AF87
set -U tide_context_color_root FF0000
set -U tide_context_color_ssh FFA500
set -U tide_context_hostname_parts 1

# jobs（バックグラウンドジョブ）
set -U tide_jobs_icon ✶
set -U tide_jobs_number_threshold 1000

# direnv
set -U tide_direnv_color FFA500
set -U tide_direnv_color_denied FF0000
set -U tide_direnv_icon ▼
FISH
