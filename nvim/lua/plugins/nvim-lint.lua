return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- eslint/ruff diagnostics come from their LSP servers; don't lint twice
      linters_by_ft = {
        go = { "golangcilint" },
        lua = { "selene", "luacheck" },
        terraform = { "terraform_validate" },
        tf = { "terraform_validate" },
      },
      linters = {
        selene = {
          condition = function(ctx)
            local root = LazyVim.root.get({ normalize = true })
            if root ~= vim.uv.cwd() then
              return false
            end
            return vim.fs.find({ "selene.toml" }, { path = root, upward = true })[1]
          end,
        },
        luacheck = {
          condition = function(ctx)
            local root = LazyVim.root.get({ normalize = true })
            if root ~= vim.uv.cwd() then
              return false
            end
            return vim.fs.find({ ".luacheckrc" }, { path = root, upward = true })[1]
          end,
        },
      },
    },
  },
}
