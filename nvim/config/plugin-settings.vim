" Configure NERDTree
:nnoremap <silent> <A-b> :NERDTreeToggle<CR>
:nnoremap <silent> <A-S-e> :NERDTreeFocus<CR>

:let NERDTreeShowLineNumbers=0
:autocmd vimenter * NERDTreeToggle | wincmd l " Open NERDTree on startup and switch to file pane
:autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif " Autoclose if NERDTree is last window

" Ctrl-P
" :let g:ctrlp_map = '<A-p>'
" :let g:ctrlp_cmd = 'CtrlP'
" :let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

" Activate themes
if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    :let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
    :set termguicolors
endif

:syntax on
:colorscheme onedark
:let g:onedark_termcolors=16

" COC

" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

:verbose imap <tab>

:inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
:inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

:xmap <leader>f <Plug>(coc-format-selected)
:nmap <leader>f <Plug>(coc-format-selected)

" " FZF 
:map <silent> <A-p> :GFiles --cached --others --exclude-standard<CR>
:nmap <silent> <leader>p :GFiles --cached --others --exclude-standard<CR>

:nmap <silent> <leader>; :Buffers<CR>
