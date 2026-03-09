set number
set relativenumber
set shiftwidth=2

" Save your backups to a less annoying place than the current directory.
" If you have .vim-backup in the current directory, it'll use that.
" Otherwise it saves it to ~/.nvim/backup or . if all else fails.
if isdirectory($HOME . '/.nvim/backup') == 0
  :silent !mkdir -p ~/.nvim/backup >/dev/null 2>&1
endif
set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.nvim/backup/
set backupdir^=./.nvim-backup/
set backup

" Save your swp files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.nvim/swap, ~/tmp or .
if isdirectory($HOME . '/.nvim/swap') == 0
  :silent !mkdir -p ~/.nvim/swap >/dev/null 2>&1
endif
set directory=./.nvim-swap//
set directory+=~/.nvim/swap//
set directory+=~/tmp//
set directory+=.

" viminfo stores the the state of your previous editing session
set viminfo+=n~/.nvim/viminfo

if exists("+undofile")
  " undofile - This allows you to use undos after exiting and restarting
  " This, like swap and backups, uses .vim-undo first, then ~/.nvim/undo
  " :help undo-persistence
  " This is only present in 7.3+
  if isdirectory($HOME . '/.nvim/undo') == 0
    :silent !mkdir -p ~/.nvim/undo > /dev/null 2>&1
  endif
  set undodir=./.nvim-undo//
  set undodir+=~/.nvim/undo//
  set undofile
endif
