return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- managing tool
    { "williamboman/mason.nvim" },

    -- bridges mason with the lspconfig
    { "williamboman/mason-lspconfig.nvim" },

    -- nvim-cmp source for neovim's built-in LSP
    { "hrsh7th/cmp-nvim-lsp" },
  },
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            gofumpt = true, -- 使用 gofumpt 來格式化代碼
            staticcheck = true, -- 啟用 staticcheck 來檢查代碼
            analyses = {
              unusedparams = true, -- 檢查未使用的參數
              fieldalignment = true, -- 建議最佳的 struct field 排列
              shadow = true, -- 偵測變數遮蔽問題
            },
            usePlaceholders = true, -- 補全時使用佔位符
            completeUnimported = true, -- 自動補全未導入的 package
            semanticTokens = true, -- 啟用語義高亮
          },
        },
      },
      helm_ls = {},
      terraformls = {},
      tsserver = {
        enabled = false,
      },
      ts_ls = {
        enabled = false,
      },
    },
  },
  setup = {
    yamlls = function()
      LazyVim.lsp.on_attach(function(client, buffer)
        if vim.bo[buffer].filetype == "helm" then
          vim.schedule(function()
            vim.cmd("LspStop ++force yamlls")
          end)
        end
      end, "yamlls")
    end,
  },
}
