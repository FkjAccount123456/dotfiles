set number
set nocompatible
set guifont=Hack\ Nerd\ Font:h10
set nohls

if has('termguicolors')
  set termguicolors
endif

function LangSettings()
  if &filetype == 'c' || &filetype == 'cpp' || &filetype == 'vim' || &filetype == 'lua'
    set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  elseif &filetype == 'make'
    set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  else
    set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  endif
endfunction

au FileType * call LangSettings()

set signcolumn=yes:1
