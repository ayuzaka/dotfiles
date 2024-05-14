UsePlugin 'ddu-source-help'

call ddu#custom#patch_local('help', #{
    \   sources: [#{name: 'help'}],
    \   sourceOptions: #{
    \     help: #{
    \       defaultAction: 'open',
    \     },
    \   },
    \})

command! Help call ddu#start({"name": "help"})
