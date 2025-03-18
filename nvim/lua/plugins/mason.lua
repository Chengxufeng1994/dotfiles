return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      -- bridges mason with the lspconfig
      { "williamboman/mason-lspconfig.nvim" },

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
    config = function(_)
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
