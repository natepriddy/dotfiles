-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Open k9s in a terminal buffer using Snacks
vim.keymap.set("n", "<leader>k8", function()
  Snacks.terminal("k9s")
end, { desc = "Open k9s" })

-- Keep cursor centered when half-page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })

-- Keep cursor centered when searching
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- Move selected lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Paste over selection without losing register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Toggle diagnostics in the current buffer (markdown is off by default; this reveals markdownlint).
-- <leader>um is taken by LazyVim (toggle render-markdown), so use <leader>uM.
vim.keymap.set("n", "<leader>uM", function()
  local on = vim.diagnostic.is_enabled({ bufnr = 0 })
  vim.diagnostic.enable(not on, { bufnr = 0 })
  vim.notify("Buffer diagnostics " .. (on and "disabled" or "enabled"), vim.log.levels.INFO)
end, { desc = "Toggle buffer diagnostics" })
