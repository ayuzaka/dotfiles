# fzf 初期化（fzf 0.48.0+ で Ctrl+R, Ctrl+T, Alt+C が設定される）
if command -v fzf &>/dev/null
    fzf --fish | source
end

# ──────────────────────────────
# ヘルパー関数
# ──────────────────────────────

function _fzf_run
    fzf --height 50% --border
end

function _fzf_git_ref
    git for-each-ref --format='%(refname:short)' refs/heads/ refs/remotes/ refs/tags/ | _fzf_run
end

# --- npm / pnpm / bun / yarn（共通: package.json のスクリプト一覧）---

function _fzf_pkg_scripts
    jq -r '.scripts | to_entries[] | .key + " = " + .value' package.json 2>/dev/null | _fzf_run | awk -F ' = ' '{print $1}'
end

function _fzf_pkg_workspaces_npm
    jq -r '.workspaces[]?' package.json 2>/dev/null | _fzf_run
end

function _fzf_pkg_workspaces_pnpm
    pnpm ls --json 2>/dev/null | jq -r '.[].name' | _fzf_run
end

function _fzf_pkg_workspaces_yarn
    yarn workspaces info 2>/dev/null | jq -r 'keys[]' | _fzf_run
end

# ──────────────────────────────
# Tab キー fzf 補完ディスパッチャー
# ──────────────────────────────

function _fzf_tab_complete
    set line (commandline)
    set result ""

    switch $line
        # --- tmux ---
        case "tmux a *" "tmux attach *"
            set result (tmux ls | _fzf_run | awk -F ':' '{print $1}')
        case "tmux kill-session *"
            set result (tmux ls | _fzf_run | awk -F ':' '{print $1}')
        case "tmux send-keys *"
            set result (tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}' | _fzf_run)

        # --- git ---
        case "git switch *"
            set result (git for-each-ref --format='%(refname:short)' refs/heads/ | _fzf_run)
        case "git rebase *" "git checkout *" "git reset *"
            set result (_fzf_git_ref)
        case "git wt *"
            set result (git wt 2>/dev/null | grep -v -F -e '*' -e 'BRANCH' | awk '{print $2}' | _fzf_run)
        case "git branch -d *"
            set result (git for-each-ref --format='%(refname:short)' refs/heads --merged | grep -v -x -F -e develop -e main -e master | _fzf_run)

        # --- npm ---
        case "npm run *"
            set result (_fzf_pkg_scripts)
        case "npm workspace *"
            set result (_fzf_pkg_workspaces_npm)
        case "npm *"
            set result (_fzf_pkg_scripts)

        # --- pnpm ---
        case "pnpm run *"
            set result (_fzf_pkg_scripts)
        case "pnpm --filter *"
            set result (_fzf_pkg_workspaces_pnpm)
        case "pnpm *"
            set result (_fzf_pkg_scripts)

        # --- bun ---
        case "bun run *"
            set result (_fzf_pkg_scripts)
        case "bun --filter *"
            set result (_fzf_pkg_workspaces_npm)
        case "bun *"
            set result (_fzf_pkg_scripts)

        # --- yarn ---
        case "yarn run *"
            set result (_fzf_pkg_scripts)
        case "yarn workspace *"
            set result (_fzf_pkg_workspaces_yarn)
        case "yarn *"
            set result (_fzf_pkg_scripts)

        # --- make ---
        case "make *"
            set result (awk '/^\.PHONY:/ {for (i=2;i<=NF;i++) print $i}' Makefile 2>/dev/null | sort -u | _fzf_run)

        # --- deno ---
        case "deno task *"
            set result (jq -r '.tasks | to_entries[] | .key + " = " + .value' deno.jsonc 2>/dev/null | _fzf_run | awk -F ' = ' '{print $1}')

        # --- act ---
        case "act --job *"
            set result (act --list 2>/dev/null | grep -v Stage | awk '{print $2}' | _fzf_run)

        # --- ssh / scp ---
        case "ssh *" "scp *"
            set result (cat $HOME/.ssh/*.conf 2>/dev/null | grep '^Host' | awk '{print $2}' | _fzf_run)

        # --- gcloud ---
        case "gcloud config configurations activate *"
            set result (gcloud config configurations list --format 'value(name)' | _fzf_run)

        # --- GitHub CLI ---
        case "gh issue edit *"
            set result (gh issue list --assignee @me --state open --limit 1000 | _fzf_run | awk '{print $1}')
        case "gh pr checkout *"
            set result (gh pr list --json number,title,author --jq '.[] | [(.number | tostring), .title, .author.login] | join(",")' | _fzf_run | awk -F ',' '{print $1}')

        # --- docker ---
        case "docker exec *" "docker container exec *" "docker container stop *"
            set result (docker container ls --format '{{.Names}}' | _fzf_run)
        case "docker container rm *"
            set result (docker container ls -a --format '{{.Names}}' | _fzf_run)
        case "docker image rm *"
            set result (docker image ls --format '{{.Repository}}:{{.Tag}}:{{.ID}}' | _fzf_run | awk -F ':' '{print $3}')

        # マッチしない場合は通常の Tab 補完にフォールバック
        case "*"
            commandline -f complete
            return
    end

    if test -n "$result"
        commandline -a " $result"
        commandline -f repaint
    end
end

# キーバインド設定
function fish_user_key_bindings
    bind \t _fzf_tab_complete
end
