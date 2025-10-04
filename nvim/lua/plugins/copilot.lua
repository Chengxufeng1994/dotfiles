return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = function()
      return {
        suggestion = {
          enabled = not vim.g.ai_cmp, -- 如果啟用 ai_cmp, Copilot suggestions 關閉
          auto_trigger = true, -- 輸入時自動出建議
          hide_during_completion = vim.g.ai_cmp, -- 補全選單出現時自動隱藏 Copilot
          keymap = {
            accept = false, -- 由 cmp or LazyVim 接手 accept 行為
            next = "<M-]>", -- 下個建議
            prev = "<M-[>", -- 上個建議
          },
        },
        panel = { enabled = false }, -- 關閉 Copilot side panel
        filetypes = {
          ["*"] = true,
        },
      }
    end,
    config = function(_, opts)
      require("copilot").setup(opts)
      LazyVim.cmp.actions.ai_accept = function()
        local suggestion = require("copilot.suggestion")
        if suggestion.is_visible() then
          LazyVim.create_undo()
          suggestion.accept()
          return true
        end
      end
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    opts = {},
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)
      LazyVim.lsp.on_attach(function()
        copilot_cmp._on_insert_enter({})
      end, "copilot")
    end,
    specs = {
      {
        "hrsh7th/nvim-cmp",
        optional = true,
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
          table.insert(opts.sources, 1, {
            name = "copilot",
            group_index = 1,
            priority = 100,
          })
        end,
      },
    },
  },
}
