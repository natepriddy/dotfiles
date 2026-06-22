-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  pattern = ".env*",
  command = "set filetype=conf",
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  pattern = "*.har",
  command = "set filetype=json",
})

-- Markdown: hide diagnostics (markdownlint noise) by default.
-- Lint still runs silently; reveal it per buffer with <leader>um.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function(ev)
    vim.diagnostic.enable(false, { bufnr = ev.buf })
  end,
})
