return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- managing tool
    { "mason.nvim" },

    -- bridges mason with the lspconfig
    { "mason-org/mason-lspconfig.nvim" },

    -- nvim-cmp source for neovim's built-in LSP
    { "hrsh7th/cmp-nvim-lsp" },
  },
  opts = {
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    -- LSP Server Settings
    ---@type lspconfig.options
    servers = {
      bashls = {},
      gopls = {
        settings = {
          gopls = {
            gofumpt = true, -- 使用 gofumpt 來格式化代碼
            usePlaceholders = true, -- 補全時使用佔位符
            completeUnimported = true, -- 自動補全未導入的 package
            semanticTokens = true, -- 啟用語義高亮
            staticcheck = true, -- 啟用 staticcheck 來檢查代碼
            analyses = {
              unusedparams = true, -- 檢查未使用的參數
              shadow = true, -- 偵測變數遮蔽問題
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      },
      helm_ls = {},
      marksman = {},
      ruff = {
        cmd_env = { RUFF_TRACE = "messages" },
        init_options = {
          settings = {
            logLevel = "error",
          },
        },
        keys = {
          {
            "<leader>co",
            LazyVim.lsp.action["source.organizeImports"],
            desc = "Organize Imports",
          },
        },
      },
      ruff_lsp = {},
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      },
      terraformls = {},
      -- settings + moveToFile refactoring come from the lang.typescript extra.
      -- Server keys REPLACE (not merge), so restate all keys here to keep the
      -- extra's gD/gR/cM/cD/cV plus our own <leader>co / <leader>cu.
      vtsls = {
        keys = {
          {
            "gD",
            function()
              local win = vim.api.nvim_get_current_win()
              local params = vim.lsp.util.make_position_params(win, "utf-16")
              LazyVim.lsp.execute({
                command = "typescript.goToSourceDefinition",
                arguments = { params.textDocument.uri, params.position },
                open = true,
              })
            end,
            desc = "Goto Source Definition",
          },
          {
            "gR",
            function()
              LazyVim.lsp.execute({
                command = "typescript.findAllFileReferences",
                arguments = { vim.uri_from_bufnr(0) },
                open = true,
              })
            end,
            desc = "File References",
          },
          { "<leader>co", LazyVim.lsp.action["source.organizeImports"], desc = "Organize Imports" },
          { "<leader>cM", LazyVim.lsp.action["source.addMissingImports.ts"], desc = "Add missing imports" },
          { "<leader>cu", LazyVim.lsp.action["source.removeUnused.ts"], desc = "Remove unused imports" },
          { "<leader>cD", LazyVim.lsp.action["source.fixAll.ts"], desc = "Fix all diagnostics" },
          {
            "<leader>cV",
            function()
              LazyVim.lsp.execute({
                title = "Select TypeScript Version",
                filter = "vtsls",
                command = "typescript.selectTypeScriptVersion",
              })
            end,
            desc = "Select TS workspace version",
          },
        },
      },
      yamlls = {
        -- Have to add this for yamlls to understand that we support line folding
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
        -- lazy-load schemastore when needed
        before_init = function(_, new_config)
          new_config.settings.yaml.schemas =
            vim.tbl_deep_extend("force", new_config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
        end,
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            keyOrdering = false,
            format = {
              enable = true,
            },
            validate = true,
            schemaStore = {
              -- Must disable built-in schemaStore support to use
              -- schemas from SchemaStore.nvim plugin
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = "",
            },
          },
        },
      },
    },
    setup = {
      ruff = function()
        Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
          -- Disable hover to avoid conflict with pyright
          client.server_capabilities.hoverProvider = false
        end)
      end,
      yamlls = function()
        Snacks.util.lsp.on({ name = "yamlls" }, function(buffer, _)
          if vim.bo[buffer].filetype == "helm" then
            vim.schedule(function()
              vim.cmd("LspStop ++force yamlls")
            end)
          end
        end)
      end,
    },
  },
}
