
augroup my_abbrev
  autocmd FileType sql iabbrev <buffer> select SELECT
  autocmd FileType sql iabbrev <buffer> from FROM
  autocmd FileType sql iabbrev <buffer> where WHERE
  autocmd FileType sql iabbrev <buffer> order ORDER
  autocmd FileType sql iabbrev <buffer> by BY

  autocmd FileType typescript,typescriptreact iabbrev <buffer> fn function
  autocmd FileType typescript,typescriptreact iabbrev <buffer> ex export
  autocmd FIleType typescript,typescriptreact iabbrev <buffer> im import
  autocmd FileType typescript,typescriptreact iabbrev <buffer> con console
augroup END

