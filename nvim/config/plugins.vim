call plug#begin('~/.local/share/nvim/plugged')

" Visuals & GUI
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'

Plug 'scrooloose/nerdtree'
" Plug 'ryanoasis/vim-devicons'

" Theming
Plug 'joshdick/onedark.vim'
Plug 'ayu-theme/ayu-vim' 

" Productivity
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

Plug 'editorconfig/editorconfig-vim'

Plug 'airblade/vim-rooter'

" Languages & Syntax
Plug 'sheerun/vim-polyglot'

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Linting
Plug 'dense-analysis/ale'

call plug#end()
