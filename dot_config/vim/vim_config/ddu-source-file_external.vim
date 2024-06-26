UsePlugin 'ddu-source-file_external'

call ddu#custom#patch_local('fd', #{
   \  sources: [#{name: 'file_external', params: {}}],
   \  sourceParams: #{
   \    file_external: #{
   \      cmd: ['fd', '.', '-H', '-t', 'f', '--exclude', '*.{png,jpg,jpeg,webp,avif,gif}']
   \    },
   \  },
   \})

nnoremap <C-p> :call ddu#start({"name": "fd"})<CR>
