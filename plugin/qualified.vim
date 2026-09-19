vim9script noclear

if exists("g:loaded_qualified")
  finish
endif
g:loaded_qualified = 1

import autoload 'qualified.vim'

xnoremap <silent> iq <ScriptCmd>qualified.Select(true)<CR>
onoremap <silent> <expr> iq qualified#Operator()
