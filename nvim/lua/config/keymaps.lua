-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Snippet navigation keymaps (使用原生 vim.snippet)
vim.keymap.set({ "i", "s" }, "<C-l>", function()
  if vim.snippet.active({ direction = 1 }) then
    return vim.snippet.jump(1)
  end
end, { desc = "Jump to next snippet placeholder" })

vim.keymap.set({ "i", "s" }, "<C-h>", function()
  if vim.snippet.active({ direction = -1 }) then
    return vim.snippet.jump(-1)
  end
end, { desc = "Jump to previous snippet placeholder" })
