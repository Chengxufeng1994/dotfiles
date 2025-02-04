return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "storm",
  },
  config = function()
    require("tokyonight").setup({
      transparent = true,
    })
  end,
}
