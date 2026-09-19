vim9script noclear

if exists("g:loaded_qualified")
  finish
endif
g:loaded_qualified = 1

import autoload 'qualified.vim'

xnoremap <silent> iq <ScriptCmd>qualified.Select(qualified.Mode.Visual)<CR>
onoremap <silent> <expr> iq qualified.Select(qualified.Mode.Operator)
