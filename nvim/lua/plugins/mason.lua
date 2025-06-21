return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    version = "^1.0.0",
    dependencies = {
      -- bridges mason with the lspconfig
      { "mason-org/mason-lspconfig.nvim", version = "^1.0.0", config = function() end },

      -- Install and upgrade third party tools automatically
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = function()
          require("mason-tool-installer").setup({
            ensure_installed = {
              "delve",
              -- golang
              "gopls",
              "golangci-lint",
              "gomodifytags",
              "gofumpt",
              "goimports",
              "golines",
              "impl",
              "lua_ls",
              "ts_ls",
              "stylua",
              "shellcheck",
              "bashls",
              -- vim
              "vimls",
              -- rust
              "rust_analyzer",
              "tflint",
              -- code spell
              "codespell",
              "misspell",
              "cspell",
              -- markdown
              "marksman",
            },
          })
        end,
      },
    },
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    config = function(_, opts)
      require("mason").setup({
        ui = {
          height = 0.85,
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
        max_concurrent_installers = 10,
      })
      require("mason-lspconfig").setup()
    end,
  },
}
