let g:netrw_winsize=30
let g:netrw_liststyle=3
let g:netrw_localrmdir='rm -r'

set background=dark

set autoindent                                   " copy indent from current line when starting a new
set autoread                                     " if file changes outside vim, read it back in
set backspace=indent,eol,start                   " make backspace work like most other apps

set textwidth=80                                 " marker on 80 chars
set colorcolumn=+1                               " highlight column after 'textwidth'
set encoding=UTF-8                               " set encoding
set hidden                                       " buffer becomes hidden when it is abandoned
set history=1000                                 " remember 1000 lines of history
set laststatus=2                                 " always show status line
set lazyredraw                                   " screen wont be redrawn while executing macros/registers
set linebreak                                    " vim will wrap long lines at char `breakat`
set listchars=tab:>\ ,eol:¬                      " change tab/eol chars etc.
set matchtime=3                                  " tenths of a second to show the matching brackets etc.
set modelines=0                                  " sets the number of lines (at the beginning and end of each file) vim checks for initialisations
set mouse=a                                      " lets use the mouse
set mousehide                                    " hide the mousecursor while typing
set number                                       " turn on line numbers by default
set pastetoggle=<F3>                             " binding to toggle paste mode
set relativenumber                               " show relative line numbers
set ruler                                        " shows the line and column number of the current cursor position
set shiftround                                   " round indent to multiple of `shiftwidth`
set showbreak=↳                                 " U+21B3
set showcmd                                      " show partial command in last line of screen, e.g. when selecting chars shows number of chars
set splitbelow                                   " splitting a window will put the new window below current
set splitright                                   " splitting a window will put the new window right of current
set synmaxcol=800                                " don't try to highlight lines longer than 800 characters.
set title                                        " title of the window will be set to value of `titlestring`
set ttyfast                                      " indicates a fast terminal connection
set undoreload=10000                             " number of lines to save for undo
set visualbell t_vb=                             " uses a visual bell instead of beeping noise

" better completion
set complete-=i
set completeopt=longest,menuone

" folding
set foldmethod=marker                            " fold with {{{ }}}
set foldlevelstart=0
set foldtext=MyFoldText()

set gdefault                                     " all matches in line substituted instead of one
set hlsearch                                     " highlight all matches
set ignorecase                                   " ignore case of normal letters
set incsearch                                    " match as you type
set showmatch                                    " jump to matching brackets briefly when closing tag inserted
set smartcase                                    " overrides ignorecase if search pattern contains upper case
set smarttab

if &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

set scrolloff=5                                  " number of lines to keep above cursor before moving screen
set sidescroll=1                                 " min number of columns to scroll horizontally
set sidescrolloff=10                             " number of lines to keep left and right of cursor if nowrap is set

set virtualedit+=block                           " allow virtual editing in visual block mode

" spelling
" two dictionaries used for spellchecking:
"   /usr/share/dict/words
"       basic stuff
"   ~/.vim/spell/custom-dictionary.utf-8.add
"       custom word list
" also remap zG to add to the local dict
set dictionary=/usr/share/dict/words
set spellfile=~/.vim/spell/custom-dictionary.utf-8.add

" required for cursorline on initial open
set cursorline

" wild{menu,mode,ignore} settings
set wildmenu                                     " e.g. :e <TAB>
set wildmode=list:longest
set wildignore+=*.o,*.rej

set expandtab                                    " insert mode, uses spaces to insert <Tab>
set formatoptions=qrn1j                          " how vim will auto format
set softtabstop=2                                " number of spaces a <Tab> counts for while editing
set tabstop=2                                    " number of spaces a <Tab> counts for
set shiftwidth=2
set wrap                                         " lines longer than the width of the window will wrap

" never consider numbers octal, e.g. <c-a> on 007 never becomes 010
set nrformats-=octal

" save when losing focus
au FocusLost * :silent! wall

" resize splits when the window is resized
au VimResized * :wincmd =

" only show cursorline in the current window and in normal mode.
augroup cline
    au!
    au WinLeave,InsertEnter * set nocursorline
    au WinEnter,InsertLeave * set cursorline
augroup END

" only shown trailing whitespace when not in insert mode
augroup trailing
    au!
    au InsertEnter * :set listchars-=trail:⌴
    au InsertLeave * :set listchars+=trail:⌴
augroup END

" make sure Vim returns to the same line when you reopen a file
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

