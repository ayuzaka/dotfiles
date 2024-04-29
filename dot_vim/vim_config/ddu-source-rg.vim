UsePlugin 'ddu-source-rg'

command! Grep call ddu_rg#find()

command! GrepIgnore call ddu#start(#{
      \  sources: [#{
      \    name: 'rg',
      \    params: #{
      \      input: input('Search word: '),
      \      args: ['-i', '--column', '--no-heading', '--color', 'never'],
      \    },
      \  }],
      \})

