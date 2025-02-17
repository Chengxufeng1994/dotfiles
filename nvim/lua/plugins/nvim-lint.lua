return {
  "mfussenegger/nvim-lint",
  config = function()
    require("lint").linters_by_ft = {}
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "TextChanged", "BufEnter" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
