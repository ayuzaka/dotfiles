function cd_ghq
    set ghq_root (ghq root)
    set project_dir (ghq list | fzf --preview "bat $ghq_root/{}/README.md --color=always" --height 50% --border)
    test -n "$project_dir"; and cd "$ghq_root/$project_dir"
end
