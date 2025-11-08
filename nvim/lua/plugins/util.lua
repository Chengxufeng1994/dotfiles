return {
  -- lua library for neovim
  { "nvim-lua/plenary.nvim", lazy = true },
  -- git
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gedit", "Gsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GRename", "GDelete", "GRemove", "GBrowse" },
  },
  {
    "tpope/vim-rhubarb",
    dependencies = "tpope/vim-fugitive",
    cmd = { "GBrowse" },
  },
}
