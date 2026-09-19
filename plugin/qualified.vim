vim9script noclear

if exists("g:loaded_qualified")
  finish
endif
g:loaded_qualified = 1

import autoload 'qualified.vim'

xnoremap <silent> iq <ScriptCmd>qualified.Select(true)<CR>
# Return Esc before entering Cmd; otherwise an empty operator can run.
onoremap <silent> <expr> iq qualified#Available() ? "\<Cmd>call qualified#Select(v:false)\<CR>" : "\<Esc>"
