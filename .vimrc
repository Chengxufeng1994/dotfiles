" Name: VIM Configuration
" Author: Benny Cheng
" URL:
" License:

" Must be first line
set nocompatible

syntax on
filetype on
filetype plugin on
filetype plugin indent on

if !isdirectory(expand("~/.vim/"))
    call mkdir($HOME . "/.vim")
endif

set runtimepath+=$HOME/.vim

set title
set ttyfast

" Don't redraw while executing macros (good performance config)
set lazyredraw

set term=xterm-256color
set t_vb=
set t_Co=256 " using 256 colors
set t_ti=    " put terminal in 'termcap' mode
set t_te=    " put terminal in 'termcap' mode
set guicursor+=a:blinkon0 " no cursor blink

set incsearch                   " Find as you type search
set hlsearch                    " Highlight search terms
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present

" 啟用行游標提示。
set cursorline

" 文字編碼加入 utf8。
set enc=utf8

" 顯示行號。
set number

" 顯示相對行號。
" set relativenumber

" 使用空白取到 Tab。
set expandtab

" 自訂縮排 (Tab) 位元數。
set tabstop=2
set shiftwidth=2

" 字數過長時換行。
set wrap

" 高亮當前行 (水平)。
set cursorline

" 高亮當前列 (垂直)。
set cursorcolumn

" 顯示輸入的命令
set showcmd

set laststatus=2

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" No annoying sound on errors
set noerrorbells
set novisualbell

" Lines of memoy to remember
set history=10000

" Mappings {{{

" Reload .vimrc
nnoremap <F12> :so $MYVIMRC<CR>

" 定義快捷鍵的前綴，即<Leader>
" let mapleader=";"

" ==== 系统剪切板复制粘贴 ====
" visual mode 複製內容到系統剪貼簿
vmap <Leader>c "+yy
" normal mode 複製內容到系統剪貼簿
nmap <Leader>c "+yy
" normal mode 黏貼系統剪貼簿到內容
nmap <Leader>v "+p

" Move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext<cr>

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/

" Type jj to exit insert mode quickly.
inoremap jj <Esc>

" }}}

" Plug menu {{{
call plug#begin('~/.vim/plugged')

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Basic
Plug 'ctrlpvim/ctrlp.vim'
Plug 'godlygeek/tabular'
Plug 'luochen1990/rainbow'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'shougo/denite.nvim'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar'
Plug 'easymotion/vim-easymotion'

" Autocomplete

" Git Tools
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'pangloss/vim-javascript'

" Go
Plug 'jstemmer/gotags'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()
" }}}

" ==============================
" NERDTreeToggle Config
" ==============================
noremap <C-n> :NERDTreeToggle<CR>
" 顯示行號 
let NERDTreeShowLineNumbers=1
" 打開文件時是否顯示目錄 
let NERDTreeAutoCenter=1
" 是否顯示隱藏文件 
let NERDTreeShowHidden=1
" 打開 vim 文件及顯示書籤列表
let NERDTreeShowBookmarks=2

" ==============================
" Tagbar Config
" ==============================
nmap <F8> :TagbarToggle<CR>
let g:tagbar_type_go = {
\ 'ctagstype' : 'go',
\ 'kinds'     : [
\ 'p:package',
\ 'i:imports:1',
\ 'c:constants',
\ 'v:variables',
\ 't:types',
\ 'n:interfaces',
\ 'w:fields',
\ 'e:embedded',
\ 'm:methods',
\ 'r:constructor',
\ 'f:functions'
\ ],
\ 'sro' : '.',
\ 'kind2scope' : {
\ 't' : 'ctype',
\ 'n' : 'ntype'
\ },
\ 'scope2kind' : {
\ 'ctype' : 't',
\ 'ntype' : 'n'
\ },
\ 'ctagsbin'  : 'gotags',
\ 'ctagsargs' : '-sort -silent'
\ }

" ==============================
" Suntastic Config
" ==============================
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 2
let g:syntastic_check_on_wq = 1

" ==============================
" Vim-Go Config
" ==============================
set autowrite

" Go syntax highlighting
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

" Enable auto formatting on saving
let g:go_fmt_autosave = 1

" Run `goimports` on your current file on every save
let g:go_fmt_command = "goimports"

" Status line types/signatures
let g:go_auto_type_info = 1

" Linter
let g:go_metalinter_command = "golangci-lint"
let g:go_metalinter_enabled = ['vet', 'errcheck', 'staticcheck', 'gosimple']

" Run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction
