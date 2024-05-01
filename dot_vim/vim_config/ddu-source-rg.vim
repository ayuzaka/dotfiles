UsePlugin 'ddu-source-rg'

command! GrepIgnore call ddu#start(#{
      \  sources: [#{
      \    name: 'rg',
      \    params: #{
      \      input: input('Search word: '),
      \      args: ['--column', '--no-heading', '--color', 'never'],
      \    },
      \  }],
      \})


command! GrepIgnore call ddu#start(#{
      \  sources: [#{
      \    name: 'rg',
      \    params: #{
      \      input: input('Search word: '),
      \      args: ['-i', '--column', '--no-heading', '--color', 'never'],
      \    },
      \  }],
      \})

