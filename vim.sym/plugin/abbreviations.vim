" EatChar stops abbreviations inserting an extra space
function! EatChar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunction
function! MakeSpacelessIabbrev(from, to)
    execute "iabbrev <silent> ".a:from." ".a:to."<c-R>=EatChar('\\s')<cr>"
endfunction
function! MakeSpacelessBufferIabbrev(from, to)
    execute "iabbrev <silent> <buffer> ".a:from." ".a:to."<c-R>=EatChar('\\s')<cr>"
endfunction

call MakeSpacelessIabbrev('mywebsite', 'https://wilkins.tech/')
call MakeSpacelessIabbrev('myemail', 'jonathan@wilkins.tech')
call MakeSpacelessIabbrev('edn', '// eslint-disable-next-line')

" date abbreviation
iab xdate <c-r>=strftime("%FT%H:%M:%S")<cr>

