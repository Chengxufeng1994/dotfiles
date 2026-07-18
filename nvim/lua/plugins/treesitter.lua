-- Syntax highlightings
-- Playground 已內建於 Neovim：:InspectTree（語法樹）、:Inspect（游標處 highlight group）、:EditQuery（query 編輯器 + linter）
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- 核心語言解析器（LazyVim 預設清單以外的；LazyVim 透過 opts_extend 合併）
      ensure_installed = {
        "bash",
        "css",
        "csv",
        "dockerfile",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "graphql",
        "python",
        "make",
        "markdown",
        "ninja",
        "rst",
        "git_config",
        "gitcommit",
        "git_rebase",
        "gitignore",
        "gitattributes",
        "json5",
        "sql",
        "yaml",
        "toml",
        "rust",
        "lua",
        "terraform",
        "hcl",
        "helm",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = {
      mode = "topline", -- 'cursor' | 'topline'
      max_lines = 3,
      min_window_height = 20,
      line_numbers = true,
      multiline_threshold = 1,
      trim_scope = "outer",
      separator = nil,
      -- treesitter-context is buggy with Markdown files
      on_attach = function(buf)
        return vim.bo[buf].filetype ~= "markdown"
      end,
    },
    keys = {
      { "<leader>tc", "<cmd>TSContextToggle<cr>", desc = "Toggle Treesitter Context" },
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
      per_filetype = {
        html = { enable_close = false },
      },
    },
  },
}
