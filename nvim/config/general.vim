let mapleader = "\<Space>"

" General Settings
:set shell=/bin/bash
:set hidden
:set history=100 
:set encoding=utf-8
:set autoindent
:set nowrap
:set noswapfile
:set nojoinspaces

:set number rnu 

" Enable mouse
:set mouse=a

" Use system clipboard
:set clipboard=unnamedplus

" Expand tab to spaces
:set expandtab
:set tabstop=2

" Hide tilde sign on blank lines
set fcs=eob:\

" Vim colors & syntax
:filetype on

" Display vim filename in iterm tab
:set t_ts=^[]1;
:set t_fs=^

" Navigate panes easy with Alt+[h,j,k,l]
nnoremap <silent> <M-h> :wincmd h<CR>
nnoremap <silent> <M-j> :wincmd j<CR>
nnoremap <silent> <M-k> :wincmd k<CR>
nnoremap <silent> <M-l> :wincmd l<CR>
tnoremap <M-h> <C-w>h
tnoremap <M-j> <C-w>j
tnoremap <M-k> <C-w>k
tnoremap <M-l> <C-w>l

" easily switch to normal mode for terminal buffer
if has("nvim")
  au TermOpen * tnoremap <Esc> <c-\><c-n>
  au FileType fzf tunmap <Esc>
endif

" Jump to start and end of line using the home row keys
map H ^
map L $

" <leader><leader> toggles between buffers
:nnoremap <silent> <leader><leader> <c-^>

:nnoremap <silent> <leader><Right> :bnext<CR>
:nnoremap <silent> <leader>l :bnext<CR>

:nnoremap <silent> <leader><Left> :bnext<CR>
:nnoremap <silent> <leader>h :bprevious<CR>

" Quick save
:nmap <silent> <leader>w :w<CR>

" Quick close buffers
:nmap <silent> <leader>c :bp<cr>:bd #<cr>

" Ripgrep search
if executable('rg')
	set grepprg=rg\ --no-heading\ --vimgrep
	set grepformat=%f:%l:%c:%m
endif