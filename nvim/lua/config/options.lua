-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LazyVim completion engine to use.
-- Can be one of: nvim-cmp, blink.cmp
-- Leave it to "auto" to automatically use the completion engine
-- enabled with `:LazyExtras`
vim.g.lazyvim_cmp = "nvim-cmp"

---- General
vim.opt.backup = false
vim.opt.writebackup = false -- Don't store backup
vim.opt.undofile = true -- Enable persistent undo
vim.opt.swapfile = false

---- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a" -- allow the mouse to be used in Nvim

-- Tab
vim.opt.tabstop = 2 -- number of visual spaces per TAB
vim.opt.softtabstop = 0 -- number of spacesin tab when editing
vim.opt.shiftwidth = 2 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of python
vim.opt.smarttab = true

-- UI config
vim.opt.breakindent = true -- Indent wrapped lines to match line start
vim.opt.number = true -- show absolute number
vim.opt.relativenumber = true -- add numbers to each line on the left side
vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.opt.cursorcolumn = false -- highlight cursor column  underneath the cursor horizontally
vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
vim.opt.conceallevel = 0
vim.opt.laststatus = 3 -- show statusline in last window
vim.opt.linebreak = true -- Wrap long lines at 'breakat' (if 'wrap' is set)
vim.opt.list = true -- show helpful character indicators
vim.opt.pumblend = 0 -- make builtin completion menus slightly transparent
vim.opt.pumheight = 10 -- make popup menu smaller
vim.opt.ruler = false -- don't show cursor position
-- vim.opt.shortmess = "aoOWFc" -- disable certain messages from |ins-completion-menu|
vim.opt.signcolumn = "yes" -- always show signcolumn or it would frequently shift
vim.opt.termguicolors = true -- enable gui colors
vim.opt.winblend = 0 -- make floating windows transparent
vim.opt.wrap = false -- display long lines as just one line
vim.opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint

vim.opt.smartindent = true
vim.opt.autoindent = true

-- Searching
vim.opt.incsearch = true -- search as characters are entered
vim.opt.hlsearch = true -- do not highlight matches
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered

vim.opt.scrolljump = 5
vim.opt.scrolloff = 3
vim.opt.foldenable = true
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
