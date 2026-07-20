return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    -- version = "^1.0.0",
    dependencies = {
      -- bridges mason with the lspconfig
      {
        "mason-org/mason-lspconfig.nvim",
        -- version = "^1.0.0",
      },

      -- Install and upgrade third party tools automatically
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = function()
          require("mason-tool-installer").setup({
            auto_update = false,
            ensure_installed = {
              -- shell
              "bashls",
              "shfmt",
              "shellcheck",
              -- golang
              "delve",
              "gopls",
              "golangci-lint",
              "gomodifytags",
              "gofumpt",
              "goimports",
              "golines",
              "impl",
              -- lua
              "lua_ls",
              "stylua",
              -- python
              "ruff",
              "pyright",
              "debugpy",
              -- vim
              "vimls",
              -- rust
              "rust_analyzer",
              "codelldb", -- debugger (used by rustaceanvim); extras' ensure is dropped by our custom config
              -- "docker",
              "dockerls",
              "hadolint",
              -- terraform
              "tflint",
              -- typescript
              "vtsls",
              "js-debug-adapter", -- debugger for JS/TS (from lang.typescript ensure, not auto-installed here)
              -- code spell
              "codespell",
              "misspell",
              "cspell",
              -- markdown
              "marksman",
              "markdownlint-cli2",
              "markdown-toc",
              "prettier",
              --- yaml
              "yamlls",
              "yamlfmt",
            },
          })
        end,
      },
    },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      max_concurrent_installers = 10,
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
    end,
  },
}
