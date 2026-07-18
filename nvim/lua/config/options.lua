-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

--------------------------------------------------------------------------------
-- Leader
--------------------------------------------------------------------------------
vim.g.mapleader = " "

--------------------------------------------------------------------------------
-- Encoding
--------------------------------------------------------------------------------
vim.g.encoding = "UTF-8"
vim.opt.fileencoding = "UTF-8"

--------------------------------------------------------------------------------
-- Backup / Undo
--------------------------------------------------------------------------------
vim.opt.backup = false
vim.opt.writebackup = false -- don't store backup
vim.opt.swapfile = false
vim.opt.undofile = true -- enable persistent undo

--------------------------------------------------------------------------------
-- Performance
--------------------------------------------------------------------------------
vim.opt.updatetime = 300
vim.opt.timeout = true
vim.opt.timeoutlen = 300

--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------
---- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.mouse = "a" -- allow the mouse to be used in Nvim

-- 文件被修改的時候, 自動載入
vim.opt.autoread = true -- enable auto-reload on external file change
vim.opt.hidden = true -- enable hidden modified buffer
vim.opt.confirm = true -- 詢問是否儲存未保存檔案

----------------------------------------------------------------------------------
-- Indent
--------------------------------------------------------------------------------
vim.opt.tabstop = 2 -- number of visual spaces per TAB
vim.opt.softtabstop = 2 -- number of spacesin tab when editing
vim.opt.shiftwidth = 2 -- insert 4 spaces on a tab
vim.opt.shiftround = true
vim.opt.expandtab = true -- tabs are spaces, mainly because of python
vim.opt.autoindent = true
vim.opt.smartindent = true

--------------------------------------------------------------------------------
-- UI config
--------------------------------------------------------------------------------
-- Style
vim.opt.termguicolors = true -- enable gui colors
vim.opt.background = "dark"

vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.opt.cursorcolumn = true -- highlight cursor column  underneath the cursor horizontally

vim.opt.colorcolumn = "120"

vim.opt.signcolumn = "yes"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.laststatus = 3 -- show statusline in last window

vim.opt.cmdheight = 1
vim.opt.showcmd = true
vim.opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint

vim.opt.wrap = false -- display long lines as just one line
vim.opt.linebreak = true -- Wrap long lines at 'breakat' (if 'wrap' is set)
vim.opt.breakindent = true -- Indent wrapped lines to match line start

vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
vim.opt.splitkeep = "screen"

vim.opt.list = true -- show helpful character indicators
-- vim.o.listchars = "space:·,tab:>-"
vim.opt.listchars = {
  tab = ">-",
  space = "·",
  trail = "•",
  extends = "»",
  precedes = "«",
}

vim.opt.winblend = 0 -- make floating windows transparent
vim.opt.pumblend = 0 -- make builtin completion menus slightly transparent
vim.opt.pumheight = 10 -- make popup menu smaller
vim.opt.wildoptions = "pum"

vim.opt.ruler = false -- don't show cursor position
vim.opt.showtabline = 2 -- alway showt tabline

vim.opt.conceallevel = 0

--------------------------------------------------------------------------------
-- Title
--------------------------------------------------------------------------------
vim.opt.title = true
vim.opt.titlestring = "❐ %t"
vim.opt.titlelen = 70

----------------------------------------------------------------------------------
-- Searching
--------------------------------------------------------------------------------
vim.opt.incsearch = true -- search as characters are entered
vim.opt.hlsearch = false -- do not highlight matches
vim.opt.inccommand = "split" -- 在分割窗口中進行增量搜尋
-- 搜尋大小寫不敏感, 除非包含大寫
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered

vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
vim.opt.wildignore:append({ "*/node_modules/*" })

vim.opt.wildmenu = true

--------------------------------------------------------------------------------
-- Completion
--------------------------------------------------------------------------------
vim.opt.completeopt = {
  "menu",
  "menuone",
  "noselect",
}

-- Dont' pass messages to |ins-completin menu|
vim.o.shortmess = vim.o.shortmess .. "c"

--------------------------------------------------------------------------------
-- Scroll
--------------------------------------------------------------------------------
-- Scrolling
-- jk 移動時 Cursor 上下方保留行數
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10
vim.opt.scrolljump = 5

--------------------------------------------------------------------------------
-- Shell
--------------------------------------------------------------------------------
vim.opt.shell = "zsh"

--------------------------------------------------------------------------------
-- Folding
--------------------------------------------------------------------------------
-- Foldes
vim.opt.foldenable = true
vim.opt.foldlevel = 99

-- Treesitter (Neovim 0.11+)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

----------------------------------------------------------------------------------
-- Undercurl
----------------------------------------------------------------------------------
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

----------------------------------------------------------------------------------
-- Format
--------------------------------------------------------------------------------
-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })

----------------------------------------------------------------------------------
-- Filetype
--------------------------------------------------------------------------------
vim.filetype.add({
  extension = {
    mdx = "mdx",
  },
})

--------------------------------------------------------------------------------
-- LazyVim
--------------------------------------------------------------------------------
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
-- LSP Server to use for Rust.
-- Set to "bacon-ls" to use bacon-ls instead of rust-analyzer.
-- only for diagnostics. The rest of LSP support will still be
-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
-- Use the snacks picker (install_version 7 would otherwise default to fzf-lua)
vim.g.lazyvim_picker = "snacks"
-- Show AI suggestions (Copilot) in the completion menu instead of ghost text
vim.g.ai_cmp = true

--------------------------------------------------------------------------------
-- Formatter
--------------------------------------------------------------------------------
-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = true
-- Set to false to disable auto format
vim.g.lazyvim_eslint_auto_format = false
