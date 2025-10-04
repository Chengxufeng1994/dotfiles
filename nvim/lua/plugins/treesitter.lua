-- Syntax highlightings
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = "LazyFile",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects" }, -- Syntax aware text-objects
    },
    opts = {
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
        -- 部分語言禁用，因為可能有問題
        disable = { "yaml", "python" },
      },
      -- 核心語言解析器（其他通過 auto_install 自動安裝）
      ensure_installed = {
        "bash",
        "html",
        "css",
        "csv",
        "regex",
        "dockerfile",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "git_config",
        "gitcommit",
        "git_rebase",
        "gitignore",
        "gitattributes",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "lua",
        "rust",
        "markdown",
        "markdown_inline",
        "python",
        "toml",
        "yaml",
        "sql",
        "query",
        "vim",
        "vimdoc",
        "terraform",
        "hcl",
        "helm",
      },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
      ignore_install = { "" }, -- List off parsers to ignore installing,
      auto_pairs = {
        enable = true,
      },
      autotag = {
        enable = true,
      },
      -- 增量選擇
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<tab>",
          node_decremental = "<bs>",
        },
      },
      -- Text objects 完整配置
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup()

      local ts_ctx = require("treesitter-context")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown" },
        callback = function(ev)
          -- treesitter-context is buggy with Markdown files
          ts_ctx.disable()
        end,
      })

      -- 確保 ensure_installed 無重複
      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = LazyVim.dedup(opts.ensure_installed)
      end
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    enabled = true,
    opts = {
      enable = true,
      mode = "topline", -- 'cursor' | 'topline'
      max_lines = 3,
      min_window_height = 20,
      line_numbers = true,
      multiline_threshold = 1,
      trim_scope = "outer",
      separator = nil,
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true })
      vim.api.nvim_set_keymap("n", "<leader>tc", ":TSContextToggle<CR>", { noremap = true, silent = true })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
  },
}
