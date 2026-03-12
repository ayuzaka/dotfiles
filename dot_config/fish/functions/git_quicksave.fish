function git_quicksave
    set message "quicksave $(date +"%Y-%m-%dT%H%M%S")"
    if test -n "$argv"
        set message "quicksave: $argv"
    end
    git commit -am $message
    git reset HEAD~
end
