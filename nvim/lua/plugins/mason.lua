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
              "gopls",
              "golangci-lint",
              "gofumpt",
              "goimports",
              "golines",
              "lua_ls",
              "ts_ls",
              "stylua",
              "shellcheck",
              "bashls",
              "vimls",
              "rust_analyzer",
              "tflint",
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
