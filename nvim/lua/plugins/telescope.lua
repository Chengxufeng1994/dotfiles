return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          -- layout_config = { prompt_position = "top" },
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<c-j>"] = actions.move_selection_next,
              ["<c-k>"] = actions.move_selection_previous,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case", the default case_mode is "smart_case"
          },
          -- file_browser = {
          --   path = "%:p:h", -- open from within the folder of your current buffer
          --   display_stat = false, -- don't show file stat
          --   grouped = true, -- group initial sorting by directories and then files
          --   hidden = true, -- show hidden files
          --   hide_parent_dir = true, -- hide `../` in the file browser
          --   hijack_netrw = true, -- use telescope file browser when opening directory paths
          --   prompt_path = true, -- show the current relative path from cwd as the prompt prefix
          --   use_fd = true, -- use `fd` instead of plenary, make sure to install `fd`
          -- },
          undo = {
            mappings = {
              i = {
                -- ["<cr>"] = require("telescope-undo.actions").yank_additions,
                -- ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
                -- ["<C-cr>"] = require("telescope-undo.actions").restore,
                ["<cr>"] = require("telescope-undo.actions").restore,
              },
            },
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("undo")

      local builtin = require("telescope.builtin")

      -- key maps

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "-", ":Telescope file_browser<CR>")

      map("n", "<leader>ff", builtin.find_files, opts) -- Lists files in your current working directory, respects .gitignore
      map("n", "<leader>fx", builtin.treesitter, opts) -- Lists tree-sitter symbols
      map("n", "<leader>fs", builtin.spell_suggest, opts) -- Lists spell options
    end,
  },
  -- native telescope sorter to significantly improve sorting performance
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    lazy = true,
    build = "make",
  },

  -- enable passing arguments to the live_grep of telescope
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    lazy = true,
  },

  -- A telescope extension to view and search your undo tree
  {
    "debugloop/telescope-undo.nvim",
    lazy = true,
  },
}
