" Gutentags {{{
let g:gutentags_ctags_exclude = ['*.css', '*.html', '*.js']
let g:gutentags_cache_dir = '~/.vim/doc/tags'

" jump to definition
nnoremap <leader>a <C-]>

" jump back
nnoremap <leader>t <C-t>

" select from tags
nnoremap <leader>A :tselect<CR>
" }}}

" FZF {{{
" source the plugin
" TODO(jwilkins): degrade gracefull with if statements
source ~/.fzf/plugin/fzf.vim

let g:fzf_layout = { 'up': '~40%' }
let g:fzf_buffers_jump = 1

" search files with icon and preview
nnoremap <silent> <leader>, :call WithIcons()<cr>

" fuzzy find
nnoremap <c-f> :Rg<space>

" search through files in git
nnoremap <c-g> :GFiles<cr>

" buffer search
nnoremap <silent> <leader>o :Buffers<cr>

" let FZF use ripgrep if it exists
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
endif

" WithIcons uses fzf to run rg, adding icons and file preview
function! WithIcons()
  let l:fzf_files_options = '--preview "bat --theme="OneHalfDark" --style=numbers,changes --color always {2..-1} | head -'.&lines.'"'

  function! s:files()
    let l:files = split(system($FZF_DEFAULT_COMMAND), '\n')
    return s:prepend_icon(l:files)
  endfunction

  function! s:prepend_icon(candidates)
    let l:result = []
    for l:candidate in a:candidates
      let l:filename = fnamemodify(l:candidate, ':p:t')
      let l:icon = WebDevIconsGetFileTypeSymbol(l:filename, isdirectory(l:filename))
      call add(l:result, printf('%s %s', l:icon, l:candidate))
    endfor

    return l:result
  endfunction

  function! s:edit_file(item)
    let l:pos = stridx(a:item, ' ')
    let l:file_path = a:item[pos+1:-1]
    execute 'silent e' l:file_path
  endfunction

  call fzf#run({
        \ 'source': <sid>files(),
        \ 'sink':   function('s:edit_file'),
        \ 'options': '-m ' . l:fzf_files_options,
        \ 'up':    '40%' })
endfunction
" }}}

" Git {{{
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gc :Gcommit --verbose<cr>
nnoremap <leader>gp :Gpush<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gb :Gblame<cr>
" }}}

" Lightline {{{
let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }
" }}}

" Goyo {{{
nnoremap <leader>f :Goyo<cr>
let g:goyo_width = 110
let g:goyo_height = 80
" }}}

" Vim-go {{{
let g:go_fmt_command = "goimports"
" }}}

