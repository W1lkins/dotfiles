set noswapfile                    				" stop creating swapfiles

if exists('$SUDO_USER')
  set nobackup                        			" don't create files as root
  set nowritebackup                   			" don't create files as root
  set noundofile								" don't create files as root
else
  set backup                        			" enable backups
  set undofile									" enable undo files

  set backupdir=~/.vim/tmp/backup//				" dir to store backup files
  set directory=~/.vim/tmp/swap//   			" dir to store swap files
  set undodir=~/.vim/tmp/undo//     			" dir to store undo files

  " make above dirs automatically if they don't already exist
  if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
  endif

  if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
  endif

  if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
  endif
endif

