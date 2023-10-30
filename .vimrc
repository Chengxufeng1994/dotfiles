" Name: VIM Configuration
" Author: Benny Cheng
" URL:
" License:

" Must be first line
set nocompatible
" Assume a dark background
set background=dark
if has('termguicolors')
  set termguicolors
endif

filetype plugin indent on
syntax on

if !isdirectory(expand("~/.vim/"))
    call mkdir($HOME . "/.vim")
endif

if has('clipboard')
    if has('unnamedplus')  " When possible use + register for copy-paste
        set clipboard=unnamed,unnamedplus
    else         " On mac and Windows, use * register for copy-paste
        set clipboard=unnamed
    endif
endif

set runtimepath+=$HOME/.vim

set title
set ttyfast

" Don't redraw while executing macros (good performance config)
set lazyredraw

" set term=xterm-256color
" set t_vb=
" set t_Co=256 " using 256 colors
" set t_ti=    " put terminal in 'termcap' mode
" set t_te=    " put terminal in 'termcap' mode
" set guicursor+=a:blinkon0 " no cursor blink

set number                      " Line numbers on
" set relativenumber            " Line relativenumber on
set hlsearch                    " Highlight search terms
set incsearch                   " Find as you type search
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set scrolljump=5                " Lines to scroll when cursor leaves screen
set scrolloff=3                 " Minimum lines to keep above and below cursor
set foldenable                  " Auto fold code
set foldmethod=indent
set foldlevel=99
" set list
" set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

" 文字編碼加入 utf8
set encoding=UTF-8
scriptencoding utf-8

set tabpagemax=15               " Only show 15 tabs
set showmode                    " Display the current mode

set cursorline                  " Highlight current line
set cursorcolumn                " Highlight current line

if has('cmdline_info')
    set ruler                   " Show the ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
    set showcmd                 " Show partial commands in status line and
                                " Selected characters/lines in visual mode
endif

set laststatus=2

" Lines of memoy to remember
set history=10000               " Store a ton of history (default is 20)
" set spell                     " Spell checking on
set hidden                      " Allow buffer switching without saving
set updatetime=100

" Setting up the directories
set backup                      " Backups are nice ...
if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undodir=$HOME/.vim/undo " Directory where the undo files will be stored
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

" set wrap                      " Wrap long lines
set nowrap                      " Do not wrap long lines
set autoindent                  " Indent at the same level of the previous line
set shiftwidth=2                " Use indents of 4 spaces
set expandtab                   " Tabs are spaces, not tabs
set tabstop=2                   " An indentation every four columns
set softtabstop=2               " Let backspace delete indent set
set backspace=indent,eol,start  " Allow backspacing over everything in insert mode

set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current

" No annoying sound on errors
" set noerrorbells
" set novisualbell

set vb                          " Disable the annoying beep sound

" Mappings {{{

" Reload .vimrc
nnoremap <F12> :so $MYVIMRC<CR>

" 定義快捷鍵的前綴，即<Leader>
let mapleader=","

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


" Leave the cursor at center of window
nmap n nzz
map <C-d> <C-d>zz
map <C-u> <C-u>zz
map <C-o> <C-o>zz

" The following two lines conflict with moving to top and
" bottom of the screen
map <S-H> gT
map <S-L> gt

map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext<cr>

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

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
Plug 'easymotion/vim-easymotion'
Plug 'godlygeek/tabular'
Plug 'frazrepo/vim-rainbow'
Plug 'luochen1990/rainbow'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'shougo/denite.nvim'
Plug 'tpope/vim-surround'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar'
Plug 'ryanoasis/vim-devicons'

" Autocomplete & Sinppets
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'


" Git Tools
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Go
Plug 'jstemmer/gotags'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'dgryski/vim-godef'

" Theme
Plug 'dracula/vim', { 'as': 'dracula' }

call plug#end()
" }}}

" ==============================
" Airline  Config
" ==============================
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" ==============================
" NERDTreeToggle Config
" ==============================
noremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>?
nnoremap <leader>n :NERDTreeFocus<CR>

let NERDTreeWinSize=50
" 顯示行號 
let NERDTreeShowLineNumbers=1
" 打開文件時是否顯示目錄 
let NERDTreeAutoCenter=1
" 是否顯示隱藏文件 
let NERDTreeShowHidden=1
" 打開 vim 文件及顯示書籤列表
let NERDTreeShowBookmarks=1
" 忽略顯示文件提示
" let NERDTreeIgnore=['\.pyc','\~$','\.swp']
let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']

let g:nerdtree_tabs_open_on_console_startup=1
let g:nerdtree_tabs_autoclose=0

" ==============================
" NERDTree Git Plugin Config
" ==============================
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

let g:NERDTreeGitStatusShowIgnoredStatus = 1

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

let g:syntastic_go_checkers = ['govet', 'errcheck', 'go']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

" ==============================
" Vim-Go Config
" ==============================
set autowrite

" Go syntax highlighting
let g:go_version_warning = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_function_parameters = 1
" let g:go_highlight_build_constraints = 1
" let g:go_highlight_variable_assignments = 1
" let g:go_highlight_format_strings = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_structs = 1
" let g:go_highlight_generate_tags = 1

" Specifes the `gopls` diagnostics level
let g:go_diagnostics_enabled = 1
let g:go_diagnostics_level = 2

" Enable auto formatting on saving
let g:go_fmt_autosave = 1

let g:go_list_type = "quickfix"

" Run `goimports` on your current file on every save
let g:go_fmt_command = "goimports"
" Use this option to define the command to be used for |:GoDef|. By default
" `guru` is being used as it covers all edge cases. But one might also use
" `godef` as it's faster. Current valid options are: `[guru, godef]` >
let g:go_def_mode = "gopls"

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

map <silent> <leader>gi :GoImports<cr>
map <silent> <leader>gd :GoDoc<cr>
map <silent> <leader>gr :GoRun<cr>
map <silent> <leader>gb :GoBuild<cr>
map <silent> <leader>gt :GoTest<cr>
map <silent> <leader>ge :GoErrCheck<cr>

" ==============================
" Dracula Theme
" ==============================
colorscheme dracula

" ==============================
" Vim Rainbow 
" ==============================
let g:rainbow_active = 1
