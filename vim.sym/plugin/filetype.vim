" Git {{{
" set position to the first line when editing a git commit message
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
" }}}

" PHP {{{
let php_sql_query = 1
let php_htmlInStrings = 1
"}}}
