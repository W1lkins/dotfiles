" use ,z to "focus" the current fold
nnoremap <leader>z zMzvzz

" toggle line numbers
nnoremap <leader>n :setlocal number!<cr>
" toggle relative numbers
nnoremap <leader>N :setlocal relativenumber!<cr>

" sort lines
nnoremap <leader>s vip:!sort -f<cr>
vnoremap <leader>s :!sort -f<cr>

" tabs
nnoremap <leader>( :tabprev<cr>
nnoremap <leader>) :tabnext<cr>

" wrap
nnoremap <leader>W :set wrap!<cr>

" Rebuild Ctags (mnemonic RC -> CR -> <cr>) [ install ctags ]
nnoremap <leader><cr> :silent !myctags >/dev/null 2>&1 &<cr>:redraw!<cr>

" clear trailing whitespace
nnoremap <leader>rw mz:%s/\s\+$//<cr>:let @/=''<cr>`z

" diffoff
nnoremap <leader>D :diffoff!<cr>

" easier linewise reselection of what you just pasted
nnoremap <leader>V V`]

" source current line
vnoremap <leader>S y:@"<cr>
nnoremap <leader>S ^vg_y:execute @@<cr>:echo 'Sourced line.'<cr>

" toggle [i]nvisible characters
nnoremap <leader>i :set list!<cr>

" ,y in normal mode copies a line - ,Y copies the whole file - ,y in visual mode copies whatever is highlighted
noremap <leader>p "*p
vnoremap <leader>y :<c-u>call g:CopyText<cr>
nnoremap <leader>y VV:<c-u>call g:CopyText<cr>
nnoremap <leader>Y :<c-u>call g:CopyAllText()<cr>

" quick editing
nnoremap <leader>ed :vsplit ~/.vim/custom-dictionary.utf-8.add<cr>
nnoremap <leader>eg :vsplit ~/.gitconfig<cr>
nnoremap <leader>ep :vsplit ~/.config<cr>
nnoremap <leader>et :vsplit ~/.tmux.conf<cr>
nnoremap <leader>ev :vsplit ~/.vimrc<cr>

" close currently open buffer
noremap <leader>bd :bd<cr>

" Switch CWD to the directory of the open buffer
noremap <leader>cd :cd %:p:h<cr>:pwd<cr>

" ,<space> to clear all highlighted search matches
noremap <silent> <leader><space> :noh<cr>:call clearmatches()<cr>

" ,v opens a vertical split
noremap <leader>v <c-w>v

" run make
nnoremap <leader>m :make

" edit a new file in cwd
nnoremap <leader>e :edit <c-r>=expand('%:p:h') . '/'<cr>

" jump back and forth between latest two buffers
nnoremap <leader>. <c-^>

