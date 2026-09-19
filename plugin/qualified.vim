vim9script noclear

if exists("g:loaded_qualified")
  finish
endif

if !has('patch-9.1.0219')
  echoerr 'qualified.vim requires Vim 9.1.0219 or later'
  finish
endif

g:loaded_qualified = 1

import autoload 'qualified.vim'

xnoremap <silent> iq <ScriptCmd>qualified.Select(qualified.Mode.Visual)<CR>
onoremap <silent> <expr> iq qualified.Select(qualified.Mode.Operator)
