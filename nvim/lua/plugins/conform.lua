return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  opts = {
    default_format_opts = {
      timeout_ms = 3000,
      async = false, -- not recommended to change
      quiet = false, -- not recommended to change
      lsp_format = "fallback", -- not recommended to change
    },
    formatters_by_ft = {
      sh = { "shfmt" },
      zsh = { "shfmt" },
      python = { "ruff_fix", "ruff_format" },
      go = { "gofmt", "goimports", "golines" },
      lua = { "stylua" },
      hcl = { "packer_fmt" },
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },
      ["markdown"] = { "prettier" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
    },
    -- The options you set here will be merged with the builtin formatters.
    -- You can also define any custom formatters here.
    ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    formatters = {
      injected = { options = { ignore_errors = true } },
      -- # Example of using dprint only when a dprint.json file is present
      -- dprint = {
      --   condition = function(ctx)
      --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
      --   end,
      -- },
      --
      -- # Example of using shfmt with extra args
      -- shfmt = {
      --   prepend_args = { "-i", "2", "-ci" },
      -- },
    },
  },
}
