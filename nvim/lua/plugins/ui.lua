return {
  -- fidget owns the LSP progress UI; keep noice from drawing it twice
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = { enabled = false },
      },
    },
  },

  -- color highlighter
  {
    "NvChad/nvim-colorizer.lua",
    event = "LazyFile",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          names = false,
          tailwind = "both",
          mode = "background",
        },
      })
    end,
  },

  -- Standalone UI for nvim-lsp progress
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function()
      require("fidget").setup({
        progress = {
          poll_rate = 200,
          ignore_done_already = true,
          display = {
            done_ttl = 0.5,
            -- done_icon = " ",
            -- Icon shown when LSP progress tasks are in progress
            progress_icon = { pattern = "meter", period = 1 },
            -- Highlight group for in-progress LSP tasks
            progress_style = "WarningMsg",
            group_style = "WarningMsg", -- Highlight group for group name (LSP server name)
            icon_style = "WarningMsg", -- Highlight group for group icons
            done_style = "Conditional", -- Highlight group for completed LSP tasks
          },
        },
        notification = {
          -- override_vim_notify = true,
          window = {
            winblend = 0,
          },
        },
      })
    end,
  },

  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
        [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
        [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
        ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "nvim-mini/mini.cursorword",
    event = "VeryLazy",
    version = "*",
    config = function()
      require("mini.cursorword").setup()
    end,
  },

  {
    "danilamihailov/beacon.nvim",
    event = "VeryLazy",
  },
}
