return {
  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for neovim's built-in LSP
      "hrsh7th/cmp-buffer", -- nvim-cmp source for buffer words
      "hrsh7th/cmp-path", -- nvim-cmp source for path words
      "hrsh7th/cmp-cmdline", -- nvim-cmp source for vim's cmdline
      "onsails/lspkind-nvim", -- lspkind (VS pictograms)
      "petertriho/cmp-git",
      { "saadparwaiz1/cmp_luasnip", enabled = true },
      -- Snippet engine
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" }, -- Set of preconfigured snippets for different languages
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local luasnip = require("luasnip")
      local types = require("luasnip.util.types")

      -- Display virtual text to indicate snippet has more nodes
      luasnip.config.setup({
        ext_opts = {
          [types.choiceNode] = {
            active = { virt_text = { { "⇥", "GruvboxRed" } } },
          },
          [types.insertNode] = {
            active = { virt_text = { { "⇥", "GruvboxBlue" } } },
          },
        },
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
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
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "git" },
        }, {
          { name = "buffer" }, -- show buffer's completion only if type more then keyword_length
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 70,
            show_labelDetails = false,
          }),
        },
      })
    end,
  },
  { "petertriho/cmp-git", opts = {} },
}
