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

" search:
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

" Mappings {{{

" Move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

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
Plug 'shougo/denite.nvim'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'majutsushi/tagbar'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'pangloss/vim-javascript'

call plug#end()
" }}}

" ==============================
" NERDTreeToggle Config
" ==============================
noremap <C-n> :NERDTreeToggle<CR>

" ==============================
" Tagbar Config
" ==============================
nmap <F8> :TagbarToggle<CR>
