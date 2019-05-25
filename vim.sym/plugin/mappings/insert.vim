" no help key
inoremap <F1> <Nop>

" no hash key
inoremap # X<BS>#

" show digraph codes
inoremap <c-k><c-k> <esc>:help digraph-table<cr>

" <c-u> will uppercase a word in insert mode
inoremap <c-u> <esc>mzgUiw`za

" insert Mode Completion
inoremap <c-f> <c-x><c-f>
inoremap <c-]> <c-x><c-]>
inoremap <c-l> <c-x><c-l>

" ctrl+a, crtl+e move to start and end of line
inoremap <c-a> <esc>I
inoremap <c-e> <esc>A

