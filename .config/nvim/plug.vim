" vim-plug start
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.nvim/plugged')

" syntax highlighting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'sheerun/vim-polyglot'

" files hierarchy tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" toggle NERDTree with ctrl-e, similar to vscode
nmap <C-E> :NERDTreeToggle<CR>
" exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" cool icons
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'ryanoasis/vim-devicons'

let g:webdevicons_enable_nerdtree = 1

" editorconfig support
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'editorconfig/editorconfig-vim'

" git integration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" lean & mean status/tabline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

let g:airline#extensions#tabline#enabled = 1

" emmet (like), essential toolkit for abbreviation expansion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'mattn/emmet-vim'

" trigger expansion with <Comma> <Comma> keys
let g:user_emmet_leader_key=','

let g:user_emmet_settings = {
\  'javascript' : {
\    'extends' : 'jsx',
\    'quote_char': "'",
\  },
\}

" awesome completion tool
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" use <Tab> key to trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

" insert or delete parenthesis in pair
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'vim-scripts/auto-pairs-gentle'

" toggle comments
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" use `gcc` to comment out a line (takes a count),
" `gc` in visual mode to comment out the selection, and much more...
Plug 'tpope/vim-commentary'

" search tool
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'mileszs/ack.vim'

" enable repeating supported plugin maps with `.`
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'tpope/vim-repeat'

" use CTRL-A/CTRL-X to increment dates, times, and more
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'tpope/vim-speeddating'

" vim-plug end, add plugins to &runtimepath
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#end()


