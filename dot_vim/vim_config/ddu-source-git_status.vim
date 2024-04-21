UsePlugin 'ddu-source-git_status'

call ddu#custom#patch_local('git_status', #{
    \  sources: [#{name: 'git_status'}],
    \  kindOptions: #{
    \    git_status: #{
    \      defaultAction: 'open',
    \      actions: #{}
    \    },
    \  },
    \})

command! Gs call ddu#start({"name": "git_status"})
