UsePlugin 'ddu-source-rg'

function! s:grep() abort
  let word = input('Search word: ')
  call ddu#start(#{sources: [#{name: 'rg', params: #{input: word}}]})
endfunction

command! Grep call s:grep()

command! GrepIgnore call ddu#start(#{
      \  sources: [#{
      \    name: 'rg',
      \    params: #{
      \      input: input('Search word: '),
      \      args: ['-i', '--column', '--no-heading', '--color', 'never'],
      \    },
      \  }],
      \})

