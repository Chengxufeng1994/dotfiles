return {
  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for neovim's built-in LSP
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer", -- nvim-cmp source for buffer words
      "hrsh7th/cmp-path", -- nvim-cmp source for path words
      -- "hrsh7th/cmp-cmdline", -- nvim-cmp source for command line
      "onsails/lspkind-nvim", -- lspkind (VS pictograms)
      "zbirenbaum/copilot-cmp",
      -- Snippet engine - 使用 LazyVim 2025 預設的 nvim-snippets
      {
        "garymjr/nvim-snippets",
        opts = {
          friendly_snippets = true,
        },
        dependencies = { "rafamadriz/friendly-snippets" },
      },
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body) -- 使用原生 vim.snippet
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "snippets", priority = 1000 }, -- 最高優先級：Snippets
          { name = "nvim_lsp", priority = 900 }, -- LSP 建議
          { name = "nvim_lsp_signature_help", priority = 850 }, -- 函數簽名
          { name = "path", priority = 800 }, -- 路徑補全
          { name = "copilot", priority = 600 }, -- AI 建議
        }, {
          { name = "buffer", keyword_length = 2, priority = 400 }, -- Buffer 文字
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local kind = lspkind.cmp_format({
              mode = "symbol_text",
              maxwidth = 70,
              show_labelDetails = false,
              symbol_map = { Copilot = "" },
            })(entry, vim_item)

            -- 來源名稱映射
            local menu_icon = {
              snippets = "⋗",
              nvim_lsp = "λ",
              buffer = "Ω",
            }

            vim_item.menu = menu_icon[entry.source.name] or "[" .. entry.source.name .. "]"

            return vim_item
          end,
        },
      })
    end,
  },
}
