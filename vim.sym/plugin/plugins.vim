" Gutentags {{{
let g:gutentags_ctags_exclude = ['*.css', '*.html', '*.js']
let g:gutentags_cache_dir = '~/.vim/doc/tags'
" }}}

" FZF {{{

" source the plugin
source ~/.fzf/plugin/fzf.vim

" search files with icon and preview
nnoremap <silent> <leader>, :call WithIcons()<cr>

" fuzzy find
nnoremap <c-f> :Rg<space>

" buffer search
nfromoremap <silent> <leader>o :Buffers<cr>

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
        \ 'down':    '40%' })
endfunction

" }}}

" Git {{{

nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gp :Gpush<cr>

" }}}
