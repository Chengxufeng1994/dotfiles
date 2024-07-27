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

" Required
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

" 定義快捷鍵的前綴，即<Leader>
let mapleader=","

set title
set titleold="Terminal"
set titlestring=%F

" Don't redraw while executing macros (good performance config)
set lazyredraw

" set term=xterm-256color
" set t_vb=
set t_Co=256 " using 256 colors
" set t_ti=    " put terminal in 'termcap' mode
" set t_te=    " put terminal in 'termcap' mode
set guioptions=egmrti
set gfn=Monospace\ 10
if &term =~ '256color'
  set t_ut=
endif
set gcr=a:blinkon0              " no cursor blink

set number                           " Line numbers on
set relativenumber                   " Line relativenumber on
set hlsearch                         " Highlight search terms
set incsearch                        " Find as you type search
set ignorecase                       " Case insensitive search
set smartcase                        " Case sensitive when uc present
set wildmenu                         " Show list instead of just completing
set wildmode=list:longest,list:full  " Command <Tab> completion, list matches, then longest common part, then all.
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

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set ttyfast
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

set laststatus=2                " Show status line

" Lines of memoy to remember
set history=10000               " Store a ton of history (default is 20)
set updatetime=100
"set spell spelllang=en_us      " Spell checking on

" Setting up the directories
set nobackup                    " No backup files
set nowritebackup               " Only in case you don't want a backup file while editing
set noswapfile                  " No swap files

if has('persistent_undo')
    set undofile                " So is persistent undo ...
    set undodir=$HOME/.vim/undo " Directory where the undo files will be stored
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

" set wrap                      " Wrap long lines
set nowrap                      " Do not wrap long lines
set autoindent                  " Indent at the same level of the previous line

" Fix backspace indent
set backspace=indent,eol,start  " Allow backspacing over everything in insert mode

" Tabs. May be overriden by autocmd rules
set tabstop=4                   " An indentation every four columns
set softtabstop=0               " Let backspace delete indent set
set shiftwidth=4                " Use indents of 4 spaces
set expandtab                   " Tabs are spaces, not tabs

" Enable hidden buffers
set hidden                      " Allow buffer switching without saving

set fileformats=unix,dos,mac

set autoread                    " If file change, will notifaction

set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current

" Disable visualbell, No annoying sound on errors
set noerrorbells visualbell t_vb= " Disable the annoying beep sound

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
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar'
Plug 'ryanoasis/vim-devicons'
Plug 'Yggdroot/indentLine'

" Vim-Session

" Autocomplete & Sinppets
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'


" Git Tools
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

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
let g:airline#extensions#branch#enabled = 1
" let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1

" =============================
" BufExplorer
" =============================
map <C-b> :BufExplorer<CR>

" ==============================
" NERDTreeToggle Config
" ==============================
nnoremap <silent> <F2> :NERDTreeFind<CR>
nnoremap <silent> <F3> :NERDTreeToggle<CR>
nnoremap <leader>n :NERDTreeFocus<CR>

let g:NERDTreeWinSize=50
" 顯示行號
let g:NERDTreeShowLineNumbers=1
" 打開文件時是否顯示目錄
let g:NERDTreeAutoCenter=1
" 是否顯示隱藏文件
let g:NERDTreeShowHidden=1
" 打開 vim 文件及顯示書籤列表
let g:NERDTreeShowBookmarks=1
" 忽略顯示文件提示
" let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
let g:NERDTreeIgnore=['node_modules','\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeChDirMode=2
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
" let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:nerdtree_tabs_focus_on_files=1
let g:nerdtree_tabs_open_on_console_startup=0
let g:nerdtree_tabs_autoclose=0
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite,*node_modules/
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

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
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1
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
if exists("*fugitive#statusline")
    set statusline+=%{fugitive#statusline()}
endif
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

let g:go_list_type = "quickfix"
" Run `goimports` on your current file on every save
let g:go_fmt_command = "goimports"
" Use this option to define the command to be used for |:GoDef|. By default
" `guru` is being used as it covers all edge cases. But one might also use
" `godef` as it's faster. Current valid options are: `[guru, godef]` >
let g:go_def_mode = "gopls"
let g:go_fmt_fail_silently = 1

" Go syntax highlighting
let g:go_version_warning = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_structs = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_space_tab_error = 0
let g:go_highlight_array_whitespace_error = 0
let g:go_highlight_trailing_whitespace_error = 0
let g:go_highlight_function_calls = 1
let ggo_highlight_function_parameters = 1
" let g:go_highlight_variable_assignments = 1
" let g:go_highlight_format_strings = 1
let g:go_highlight_extra_types = 1

" Specifes the `gopls` diagnostics level
let g:go_diagnostics_enabled = 1
let g:go_diagnostics_level = 2

" Enable auto formatting on saving
let g:go_fmt_autosave = 1

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
" Indent Line 
" ==============================
if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set guifont=Menlo:h12
    set transparency=7
  endif
else
  " let g:CSApprox_loaded = 1

  " IndentLine
  let g:indentLine_enabled = 1
  let g:indentLine_concealcursor = ''
  let g:indentLine_char = '┆'
  let g:indentLine_faster = 1

  
  if $COLORTERM == 'gnome-terminal'
    set term=gnome-256color
  else
    if $TERM == 'xterm'
      set term=xterm-256color
    endif
  endif
  
endif

" ==============================
" Vim Rainbow
" ==============================
let g:rainbow_active = 1

" ==============================
" Terminal emulation
" ==============================
nnoremap <silent> <leader>sh :terminal<CR>

"*****************************************************************************
" Commands
"*****************************************************************************
" remove trailing whitespaces
command! FixWhitespace :%s/\s\+$//e


"*****************************************************************************
" Mappings
"*****************************************************************************

" Reload .vimrc
nnoremap <F12> :so $MYVIMRC<CR>

" ==== 系统剪切板复制粘贴 ====
" visual mode 複製內容到系統剪貼簿
vmap YY "+yy
" normal mode 複製內容到系統剪貼簿
nmap YY "+yy
" normal mode 黏貼系統剪貼簿到內容
nmap <Leader>p "+p
nmap <Leader>P "+gP

" Move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Leave the cursor at center of window
nnoremap n nzxzv
nnoremap N Nzzzv
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap <C-o> <C-o>zz

" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Tabs
" The following two lines conflict with moving to top and
" bottom of the screen
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <S-H> gT
nnoremap <S-L> gt
nnoremap <silent> <S-t> :tabnew<CR>
map <leader>tn :tabnew<CR>
map <leader>to :tabonly<CR>
map <leader>tc :tabclose<CR>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext<CR>

"" Buffer nav
noremap <leader>z :bp<CR>
noremap <leader>q :bp<CR>
noremap <leader>x :bn<CR>
noremap <leader>w :bn<CR>

"" Close buffer
noremap <leader>c :bd<CR>

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/

" Visual shifting (does not exit Visual mode), Vmap for maintain Visual Mode after shifting > and <
vnoremap < <gv
vnoremap > >gv

"" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>

" Type jj to exit insert mode quickly.
inoremap jj <Esc>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

"" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" ==============================
" fzf.vim
" ==============================
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
let $FZF_DEFAULT_COMMAND =  "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"

" The Silver Searcher
if executable('ag')
  let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
  set grepprg=ag\ --nogroup\ --nocolor
endif

" ripgrep
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>e :FZF -m<CR>
"Recovery commands from history through FZF
nmap <leader>y :History:<CR>


" ==============================
"Git 
" ==============================
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Git commit --verbose<CR>
noremap <Leader>gsh :Git push<CR>
noremap <Leader>gll :Git pull<CR>
noremap <Leader>gs :Git<CR>
norema <Leader>gb :Git blame<CR>
noremap <Leader>gd :Gvdiffsplit<CR>
noremap <Leader>gr :GRemove<CR>

