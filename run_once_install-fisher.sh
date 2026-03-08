#!/bin/sh
set -e

# fisher インストール
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'

# tide インストール
fish -c 'fisher install IlanCosman/tide@v6'
