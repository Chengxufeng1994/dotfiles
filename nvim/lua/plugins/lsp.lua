return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- managing tool
    { "mason.nvim" },

    -- bridges mason with the lspconfig
    { "williamboman/mason-lspconfig.nvim", config = function() end },

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
      eslint = {
        settings = {
          -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
          workingDirectories = { mode = "auto" },
          format = auto_format,
        },
      },
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
      pyright = {},
      basedpyright = {},
      helm_ls = {},
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
      ruff_lsp = {
        keys = {
          {
            "<leader>co",
            LazyVim.lsp.action["source.organizeImports"],
            desc = "Organize Imports",
          },
        },
      },
      terraformls = {},
      tsserver = {
        enabled = false,
      },
      ts_ls = {
        enabled = false,
      },
      vtsls = {
        -- explicitly add default filetypes, so that we can extend
        -- them in related extras
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
        keys = {
          {
            "gD",
            function()
              local params = vim.lsp.util.make_position_params()
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
          {
            "<leader>co",
            LazyVim.lsp.action["source.organizeImports"],
            desc = "Organize Imports",
          },
          {
            "<leader>cM",
            LazyVim.lsp.action["source.addMissingImports.ts"],
            desc = "Add missing imports",
          },
          {
            "<leader>cu",
            LazyVim.lsp.action["source.removeUnused.ts"],
            desc = "Remove unused imports",
          },
          {
            "<leader>cD",
            LazyVim.lsp.action["source.fixAll.ts"],
            desc = "Fix all diagnostics",
          },
          {
            "<leader>cV",
            function()
              LazyVim.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
            end,
            desc = "Select TS workspace version",
          },
        },
      },
    },
  },
  setup = {
    eslint = function()
      if not auto_format then
        return
      end

      local function get_client(buf)
        return LazyVim.lsp.get_clients({ name = "eslint", bufnr = buf })[1]
      end

      local formatter = LazyVim.lsp.formatter({
        name = "eslint: lsp",
        primary = false,
        priority = 200,
        filter = "eslint",
      })

      -- Use EslintFixAll on Neovim < 0.10.0
      if not pcall(require, "vim.lsp._dynamic") then
        formatter.name = "eslint: EslintFixAll"
        formatter.sources = function(buf)
          local client = get_client(buf)
          return client and { "eslint" } or {}
        end
        formatter.format = function(buf)
          local client = get_client(buf)
          if client then
            local diag = vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
            if #diag > 0 then
              vim.cmd("EslintFixAll")
            end
          end
        end
      end

      -- register the formatter with LazyVim
      LazyVim.format.register(formatter)
    end,
    ruff = function()
      LazyVim.lsp.on_attach(function(client, _)
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end, ruff)
    end,
    --- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
    --- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
    tsserver = function()
      -- disable tsserver
      return true
    end,
    ts_ls = function()
      -- disable tsserver
      return true
    end,
    vtsls = function(_, opts)
      LazyVim.lsp.on_attach(function(client, buffer)
        client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
          ---@type string, string, lsp.Range
          local action, uri, range = unpack(command.arguments)

          local function move(newf)
            client.request("workspace/executeCommand", {
              command = command.command,
              arguments = { action, uri, range, newf },
            })
          end

          local fname = vim.uri_to_fname(uri)
          client.request("workspace/executeCommand", {
            command = "typescript.tsserverRequest",
            arguments = {
              "getMoveToRefactoringFileSuggestions",
              {
                file = fname,
                startLine = range.start.line + 1,
                startOffset = range.start.character + 1,
                endLine = range["end"].line + 1,
                endOffset = range["end"].character + 1,
              },
            },
          }, function(_, result)
            ---@type string[]
            local files = result.body.files
            table.insert(files, 1, "Enter new path...")
            vim.ui.select(files, {
              prompt = "Select move destination:",
              format_item = function(f)
                return vim.fn.fnamemodify(f, ":~:.")
              end,
            }, function(f)
              if f and f:find("^Enter new path") then
                vim.ui.input({
                  prompt = "Enter move destination:",
                  default = vim.fn.fnamemodify(fname, ":h") .. "/",
                  completion = "file",
                }, function(newf)
                  return newf and move(newf)
                end)
              elseif f then
                move(f)
              end
            end)
          end)
        end
      end, "vtsls")
      -- copy typescript settings to javascript
      opts.settings.javascript =
        vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
    end,
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
