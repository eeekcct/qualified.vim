" Run from the repository root: vim -Nu NONE -i NONE -n -es -S test/run.vim
set nocompatible
set nomore
set encoding=utf-8
set noswapfile

let s:root = fnamemodify(expand('<sfile>:p'), ':h:h')
execute 'set runtimepath^=' . fnameescape(s:root)
let s:iskeyword = &iskeyword
runtime plugin/qualified.vim
runtime plugin/qualified.vim

let g:qualified_test_events = []
augroup qualified_test
  autocmd!
  autocmd InsertEnter * call add(g:qualified_test_events, 'InsertEnter')
  autocmd TextYankPost * call add(g:qualified_test_events, 'TextYankPost')
augroup END

function! s:Reset(text, column) abort
  enew!
  call setline(1, a:text)
  call cursor(1, a:column)
  call setreg('0', 'saved yank')
  call setreg('a', 'named yank')
  call setreg('"', 'saved yank')
  let g:qualified_test_events = []
endfunction

function! s:Keys(keys) abort
  call feedkeys(a:keys . "\<Esc>", 'xt')
endfunction

function! s:Run() abort
  call assert_equal(s:iskeyword, &iskeyword, 'Preserve iskeyword')
  call assert_equal('', maparg('aq', 'x'))
  call assert_equal('', maparg('aq', 'o'))

  let valid = ['Foo::Bar', 'Foo::Bar::Baz', '::Foo', '::Foo::Bar',
        \ 'ActiveRecord::Base', 'std::collections::HashMap',
        \ 'crate::parser::Token', 'self::foo::Bar', 'super::parser::Token',
        \ 'Self::Error', '_foo1::_bar2']
  for selection in ['inclusive', 'exclusive', 'old']
    let &selection = selection
    for name in valid
      for column in range(1, strlen(name))
        for keys in ['yiq', 'viqy', 'diq', 'ciqreplacement']
          call s:Reset(name, column)
          call s:Keys(keys)
          let context = selection . ' ' . keys . ' ' . name . ':' . column
          call assert_equal(name, getreg('"'), context . ' register')
          let expected = keys ==# 'diq' ? '' : keys ==# 'ciqreplacement' ? 'replacement' : name
          call assert_equal(expected, getline(1), context . ' buffer')
          call assert_equal('v', getregtype('"'), context . ' characterwise')
        endfor
      endfor
    endfor
  endfor

  set selection=inclusive
  let invalid = ['Foo', 'HashMap', 'foo', 'path: &Path', 'foo:bar', 'key:value',
        \ 'Foo::', '::', 'Foo::::Bar', '::Foo::', 'Foo :: Bar',
        \ 'Foo::Bar::', 'Foo::::Bar::Baz', ':::Foo::Bar', '123Foo::Bar',
        \ 'Foo::123Bar', 'Foo::Bar:::Baz', 'Foo:Bar::Baz']
  for name in invalid
    for column in range(1, strlen(name))
      for keys in ['yiq', '"ayiq', 'diq', 'ciq']
        call s:Reset(name, column)
        let position = getpos('.')
        call s:Keys(keys)
        let context = keys . ' ' . name . ':' . column
        call assert_equal(name, getline(1), context . ' buffer')
        call assert_equal('saved yank', getreg('"'), context . ' unnamed register')
        call assert_equal('saved yank', getreg('0'), context . ' yank register')
        call assert_equal('named yank', getreg('a'), context . ' named register')
        call assert_equal([], g:qualified_test_events, context . ' no operator events')
        call assert_equal(position, getpos('.'), context . ' cursor')
      endfor
    endfor
  endfor

  " Locate only the candidate under the cursor, using byte columns in UTF-8.
  for selection in ['inclusive', 'exclusive']
    let &selection = selection
    let text = '日本語 (Foo::Bar), ::Baz 終'
    for name in ['Foo::Bar', '::Baz']
      let start = stridx(text, name)
      for offset in range(0, strlen(name) - 1)
        call s:Reset(text, start + offset + 1)
        call s:Keys('yiq')
        call assert_equal(name, getreg('"'), 'Multiple candidates with UTF-8 prefix')
      endfor
    endfor
    for column in [1, stridx(text, '(') + 1, stridx(text, ')') + 1, strlen(text) - 2]
      call s:Reset(text, column)
      call s:Keys('yiq')
      call assert_equal('saved yank', getreg('"'), 'Cursor outside candidate')
      call assert_equal([], g:qualified_test_events)
    endfor
  endfor

  set selection=inclusive
  call s:Reset(['std::', '  collections::', '  HashMap'], 1)
  for row in range(1, 3)
    call cursor(row, 3)
    call s:Keys('diq')
    call assert_equal(['std::', '  collections::', '  HashMap'], getline(1, '$'))
  endfor

  " A failed Visual selection preserves the existing selection and mode.
  call s:Reset('plain text', 1)
  call feedkeys('vlliq', 'xt')
  call assert_equal(1, col('v'))
  call assert_equal(3, col('.'))
  call s:Keys('y')
  call assert_equal('pla', getreg('"'))

  for keys in ['yiql', 'ciql', 'diql']
    call s:Reset('plain', 1)
    call s:Keys(keys)
    call assert_equal('plain', getline(1), 'Cancellation preserves following input')
    call assert_equal(2, col('.'))
    call assert_equal([], g:qualified_test_events)
  endfor

  call s:Reset('Foo::Bar Baz::Qux', 1)
  call s:Keys('diqw.')
  call assert_equal(' ', getline(1), 'Repeat delete')
  call s:Reset('Foo::Bar Baz::Qux', 1)
  call s:Keys("ciqX\<Esc>w.")
  call assert_equal('X X', getline(1), 'Repeat change')
  call s:Reset('Foo::Bar', 1)
  call s:Keys('"ayiq')
  call assert_equal('Foo::Bar', getreg('a'), 'Named register')

  " Ordinary word operations retain their normal boundaries.
  call s:Reset('Foo::Bar', 1)
  call s:Keys('yiw')
  call assert_equal('Foo', getreg('"'))
  call s:Keys('w')
  call assert_equal(4, col('.'))
  call s:Keys('b')
  call assert_equal(1, col('.'))
  call assert_equal(s:iskeyword, &iskeyword)
endfunction

try
  call s:Run()
catch
  call add(v:errors, v:exception . ' at ' . v:throwpoint)
endtry

if !empty(v:errors)
  call writefile(v:errors, s:root . '/test-errors.log')
  cquit
endif
call delete(s:root . '/test-errors.log')
qa!
