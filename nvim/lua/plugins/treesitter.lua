-- Syntax highlightings
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufEnter",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects" }, -- Syntax aware text-objects
      {
        "nvim-treesitter/nvim-treesitter-context", -- Show code context
        opts = { enable = true, mode = "topline", line_numbers = true },
      },
    },
    config = function()
      local treesitter = require("nvim-treesitter.configs")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown" },
        callback = function(ev)
          -- treesitter-context is buggy with Markdown files
          require("treesitter-context").disable()
        end,
      })

      treesitter.setup({
        ensure_installed = {
          "bash",
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
          "sql",
          "markdown",
          "markdown_inline",
          "html",
          "toml",
          "yaml",
          "sql",
          "query",
          "vim",
          "vimdoc",
          "terraform",
          "hcl",
          "helm",
          "ninja",
          "rst",
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        highlight = {
          enable = true,
          disable = { "csv" },
        },
        indent = {
          enable = true,
          disable = { "python" },
        },
        auto_install = true,
        ignore_install = { "" }, -- List off parsers to ignore installing,
        sync_install = false,
        auto_pairs = {
          enable = true,
        },
        autotag = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
          },
        },
        modules = {},
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufEnter",
    config = function()
      require("treesitter-context").setup({
        enable = false, -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true })
      vim.api.nvim_set_keymap("n", "<leader>tc", ":TSContextToggle<CR>", { noremap = true, silent = true })
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
    config = function(_, opts)
      LazyVim.mini.pairs(opts)
    end,
  },

  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = LazyVim.mini.ai_buffer, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      LazyVim.on_load("which-key.nvim", function()
        vim.schedule(function()
          LazyVim.mini.ai_whichkey(opts)
        end)
      end)
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    ft = { "html" },
    lazy = true,
    config = true,
  },

  {
    "towolf/vim-helm",
    ft = "helm",
  },
}
