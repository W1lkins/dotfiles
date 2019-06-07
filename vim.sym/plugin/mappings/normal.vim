" add to custom word list
nnoremap zG zg

" make zO recursively open whatever fold we're in, even if it's partially open
nnoremap zO zczO

" space to toggle folds.
nnoremap <Space> za

" kill window
nnoremap K :q!<cr>

" save
nnoremap s :w<cr>

" man file for word under cursor
nnoremap M K

" inserting blank line by pressing enter
nnoremap <cr> o<esc>

" Yank to end of line
nnoremap Y y$

" Reselect last-pasted text
nnoremap gv `[v`]

" select entire buffer
nnoremap vaa ggvGg_
nnoremap Vaa ggVG

" fix for spellcheck `zz` brings up buffer to edit word under cursor
nnoremap zz z=
nnoremap z= :echo "remapped to zz"<cr>

" panic button (reverse all text on screen)
nnoremap <f9> mzggg?G`z

" `zh` is "zoom to head level" e.g. put text under cursor at top of screen
nnoremap zh mzzt5<c-u>`z

" reformat line
nnoremap ql gqq

" indent/dedent/autoindent what you just pasted
nnoremap <lt>> V`]<
nnoremap ><lt> V`]>
nnoremap =- V`]=

" keep the cursor in place while joining lines
nnoremap J mzJ`z

" split line
" the normal use of S is covered by cc, so don't worry about shadowing it.
nnoremap S i<cr><esc>^mwgk:silent! s/\v +$//<cr>:noh<cr>`w

" start regex with Ctrl-s
nnoremap <c-s> :%s/

" select (charwise) the contents of the current line, excluding indentation.
nnoremap vv ^vg_

" unfuck the screen
nnoremap U :syntax sync fromstart<cr>:redraw!<cr>

" shift-t to open a new tab
nnoremap T :tabnew<cr>

" tl to tab-next and th to tab-prev
nnoremap tl :tabN<cr>
nnoremap th :tabp<cr>

" use sane regex
nnoremap / /\v

" D deletes to the end of a line
nnoremap D d$

" don't move on * (search word under cursor)
nnoremap <silent> * :let stay_star_view = winsaveview()<cr>*:call winrestview(stay_star_view)<cr>

" keep search matches in the middle of the window
nnoremap n nzzzv
nnoremap N Nzzzv

" same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap <c-o> <c-o>zz

" gi already moves to "last place you exited insert mode", so we'll map gI to move to last change
nnoremap gI `.

" fix linewise visual selection of various text objects
nnoremap VV V
nnoremap Vit vitVkoj
nnoremap Vat vatV
nnoremap Vab vabV
nnoremap VaB vaBV

" navigation
nnoremap <left>  :cprev<cr>zvzz
nnoremap <right> :cnext<cr>zvzz
nnoremap <up>    :lprev<cr>zvzz
nnoremap <down>  :lnext<cr>zvzz

" file browser
nnoremap <F2> :Lexplore<cr>

