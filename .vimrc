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

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=

set t_Co=256 " using 256 colors
set t_ti= t_te= " put terminal in 'termcap' mode
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

" 搜尋不分大小寫。
set ignorecase

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

" Plug menu {{{
call plug#begin('~/.vim/plugged')

" Basic
Plug 'godlygeek/tabular'
Plug 'luochen1990/rainbow'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'shougo/denite.nvim'
Plug 'tpope/vim-surround'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()
" }}}
noremap <C-n> :NERDTreeToggle<CR>
