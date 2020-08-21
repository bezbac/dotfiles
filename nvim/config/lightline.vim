set showtabline=2

let s:palette = g:lightline#colorscheme#one#palette
let s:palette.tabline.tabsel = [ [ 'white', 'dark_red', 252, 66, 'bold' ] ]
unlet s:palette

let g:lightline#bufferline#show_number  = 1
let g:lightline#bufferline#shorten_path = 0
let g:lightline#bufferline#unnamed      = '[No Name]'

let g:lightline                  = {}
let g:lightline.colorscheme      = 'one'
let g:lightline.tabline          = {'left': [['buffers']], 'right': []}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
