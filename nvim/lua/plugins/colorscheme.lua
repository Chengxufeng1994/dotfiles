return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      transparent = false,
      on_highlights = function(hl, c)
        -- 自訂 mini.cursorword 高亮，讓效果更明顯
        hl.MiniCursorword = { bg = c.bg_highlight, underline = true }
        hl.MiniCursorwordCurrent = { bg = c.bg_highlight, underline = true }
      end,
    },
  },
}
