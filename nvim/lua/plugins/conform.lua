return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = { "golines", "gofmt", "goimports" },
        lua = { "stylua" },
      },
    },
  },
}
