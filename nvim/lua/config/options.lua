-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LazyVim completion engine to use.
-- Can be one of: nvim-cmp, blink.cmp
-- Leave it to "auto" to automatically use the completion engine
-- enabled with `:LazyExtras`
vim.g.lazyvim_cmp = "nvim-cmp"

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"

-- utf8
vim.g.encoding = "UTF-8"
vim.o.fileencoding = "UTF-8"

vim.g.completeopt = "menu,menuone,noselect,noinsert"

---- Backup
vim.opt.backup = false
vim.opt.writebackup = false -- don't store backup
vim.opt.swapfile = false
vim.opt.undofile = true -- enable persistent undo

-- Timings
vim.opt.updatetime = 300
vim.opt.timeout = true
vim.opt.timeoutlen = 100

---- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a" -- allow the mouse to be used in Nvim

-- 文件被修改的時候, 自動載入
vim.opt.autoread = true -- enable auto-reload on external file change
vim.bo.autoread = true
vim.opt.hidden = true -- enable hidden modified buffer

-- Tab
-- 縮進 2 個空格等於一個 Tab
vim.opt.tabstop = 2 -- number of visual spaces per TAB
vim.bo.tabstop = 2
vim.opt.softtabstop = 2 -- number of spacesin tab when editing
vim.opt.shiftround = true
-- >> << 移動長度
vim.opt.shiftwidth = 2 -- insert 4 spaces on a tab
vim.bo.shiftwidth = 2
-- 新行數對其當前行數, 空格替代 Tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of python
vim.bo.expandtab = true
vim.opt.autoindent = true
vim.bo.autoindent = true
vim.opt.smartindent = true

-- UI config
vim.opt.breakindent = true -- Indent wrapped lines to match line start
vim.wo.number = true -- show absolute number
vim.wo.relativenumber = true -- add numbers to each line on the left side
vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.wo.cursorcolumn = true -- highlight cursor column  underneath the cursor horizontally
vim.wo.signcolumn = "yes" -- always show signcolumn or it would frequently shift
vim.wo.colorcolumn = "120"
vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
vim.opt.conceallevel = 0
vim.opt.laststatus = 3 -- show statusline in last window
vim.opt.linebreak = true -- Wrap long lines at 'breakat' (if 'wrap' is set)
vim.opt.list = true -- show helpful character indicators
vim.o.listchars = "space:·,tab:>-"
vim.opt.pumblend = 0 -- make builtin completion menus slightly transparent
vim.opt.pumheight = 10 -- make popup menu smaller
vim.opt.ruler = false -- don't show cursor position
-- vim.opt.shortmess = "aoOWFc" -- disable certain messages from |ins-completion-menu|
vim.opt.winblend = 0 -- make floating windows transparent
vim.opt.wrap = false -- display long lines as just one line
vim.wo.wrap = false
vim.opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint
vim.opt.cmdheight = 2 --
vim.opt.showtabline = 2 -- alway showt tabline

-- Title
vim.opt.titlestring = "❐ %t"
vim.opt.title = true
vim.opt.titlelen = 70

-- Style
vim.opt.background = "dark"
vim.opt.termguicolors = true -- enable gui colors

-- Searching
vim.opt.incsearch = true -- search as characters are entered
vim.opt.hlsearch = false -- do not highlight matches
-- 搜尋大小寫不敏感, 除非包含大寫
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered
vim.opt.wildmenu = true
-- Dont' pass messages to |ins-completin menu|
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.pumheight = 10

-- Scrolling
-- jk 移動時 Cursor 上下方保留行數
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.scrolljump = 5

-- Foldes
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr" -- or 'syntax'
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
