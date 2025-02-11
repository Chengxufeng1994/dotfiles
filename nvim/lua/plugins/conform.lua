return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        zsh = { "shfmt" },

        go = { "golines", "gofmt", "goimports" },
        lua = { "stylua" },

        hcl = { "packer_fmt" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },

        ["markdown"] = { "prettier" },
      },
    },
  },
}
