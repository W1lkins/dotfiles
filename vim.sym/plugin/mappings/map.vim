" no help key
noremap  <F1> <Nop>

" no hash key
noremap # <Nop>

" next/previous buffer
noremap <c-n> :bnext<cr>
noremap <c-p> :bprev<cr>

" start and end of line bindings
noremap H ^
noremap L $

" ctrl+a, crtl+e move to start and end of line
cnoremap <c-a> <home>
cnoremap <c-e> <end>

" wrapped lines go down/up to next row, rather than next line in file
noremap j gj
noremap k gk
noremap gj j
noremap gk k

" easy split navigation
noremap <c-h> <c-w>h
noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l

