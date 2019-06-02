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
nnoremap <silent> <c-h> :call WinMove('h')<cr>
nnoremap <silent> <c-j> :call WinMove('j')<cr>
nnoremap <silent> <c-k> :call WinMove('k')<cr>
nnoremap <silent> <c-l> :call WinMove('l')<cr>

" WinMove creates a split if it doesn't exist and focuses it
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr())
    if (match(a:key,'[jk]'))
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction

