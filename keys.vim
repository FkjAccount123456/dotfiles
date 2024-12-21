let g:mapleader = ';'
let g:maplocalleader = ';'

nnoremap <leader>oc :e D:\VimConfig\2\
nnoremap <leader>lc :source D:\VimConfig\2\init.vim<cr>

nnoremap <leader>ww <C-w><C-k>
nnoremap <leader>ws <C-w><C-j>
nnoremap <leader>wa <C-w><C-h>
nnoremap <leader>wd <C-w><C-l>

nnoremap <C-left> :vertical resize -1<cr>
nnoremap <C-right> :vertical resize +1<cr>
nnoremap <C-up> :resize +1<cr>
nnoremap <C-down> :resize -1<cr>

inoremap <C-b> <left>
inoremap <C-f> <right>
inoremap <M-p> <up>
inoremap <M-n> <down>
inoremap <C-a> <esc>I
inoremap <C-e> <end>
inoremap <M-b> <C-left>
inoremap <M-f> <C-right>

nnoremap <leader>e :Neotree<cr>

nnoremap <leader>t :Lspsaga term_toggle<cr>
