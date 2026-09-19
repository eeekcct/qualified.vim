vim9script

def FindName(): list<number>
  var line_text = getline(".")
  var cursor_col = col(".") - 1

  # Find the whole candidate first, so malformed names cannot match in part.
  var candidate_pattern = '[A-Za-z0-9_:]\+'
  var pattern = '\v^(::)?[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)*$'
  var match = matchstrpos(line_text, candidate_pattern)
  while match[0] != '' && !(match[1] <= cursor_col && match[2] > cursor_col)
    match = matchstrpos(line_text, candidate_pattern, match[2])
  endwhile

  if stridx(match[0], '::') < 0 || match[0] !~# pattern
    return []
  endif
  return [match[1] + 1, match[2]]
enddef

export def Select(visual: bool, operation: bool): string
  var columns = FindName()

  # The operator mapping needs keys to execute after expression evaluation.
  if operation
    return empty(columns) ? "\<Esc>" : "\<Cmd>call qualified#Select(v:false, v:false)\<CR>"
  endif

  if empty(columns)
    return ''
  endif
  var line_number = line(".")

  if visual
    execute "normal! \<Esc>"
  endif

  call cursor(line_number, columns[0])
  normal! v
  call cursor(line_number, columns[1] + (&selection ==# 'exclusive' ? 1 : 0))
  return ''
enddef
