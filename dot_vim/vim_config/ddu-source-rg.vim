UsePlugin 'ddu-source-rg'

command! Grep call ddu#start(#{
      \  sources: [#{
      \    name: 'rg',
      \    params: #{
      \      input: input('Search word: '),
      \      args: ['-i', '--column', '--no-heading', '--color', 'never'],
      \    },
      \  }],
      \})

