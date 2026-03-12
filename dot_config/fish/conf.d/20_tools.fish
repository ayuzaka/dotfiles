# LS_COLORS
set -gx LSCOLORS Exfxcxdxbxegedabagacad
set -gx LS_COLORS 'di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# mise
if command -v mise &>/dev/null
    mise activate fish | source
end

# direnv
if command -v direnv &>/dev/null
    direnv hook fish | source
end

# git-wt
if git wt --init fish &>/dev/null 2>&1
    git wt --init fish | source
end

# zoxide
if command -v zoxide &>/dev/null
    zoxide init fish | source
end

# Google Cloud SDK（fish 用スクリプト）
if test -f /opt/homebrew/share/google-cloud-sdk/path.fish.inc
    source /opt/homebrew/share/google-cloud-sdk/path.fish.inc
end

# tenv
if command -v tenv &>/dev/null
    tenv completion fish | source
end

# ngrok
if command -v ngrok &>/dev/null
    ngrok completion fish | source
end

# bun completions
if command -v bun &>/dev/null
    bun completions fish 2>/dev/null | source
end

# pnpm completions
if command -v pnpm &>/dev/null
    pnpm completion fish 2>/dev/null | source
end

# 1Password shell plugins（fish 公式サポート済み）
# fish 環境で op plugin init を再実行して生成したファイルを source
if command -v op &>/dev/null; and test -f $XDG_CONFIG_HOME/op/plugins.sh
    source $XDG_CONFIG_HOME/op/plugins.sh
end
