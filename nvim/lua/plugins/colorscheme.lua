return {
  "folke/tokyonight.nvim",
  lazy = true,
  priority = 1000,
  opts = {},
  config = function()
    require("tokyonight").setup({
      -- use the night style
      style = "storm",

      styles = {
        -- sidebars = "transparent",
        -- floats = "transparent",
      },

      transparent = true,
    })
  end,
}
