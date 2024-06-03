-- Add your plugins here
-- Add your plugins here
-- Plugin configuration using `lazy.nvim`
return
-- Add your plugins here
{
  "plasticboy/vim-markdown",
  config = function()
    -- Optional: Additional configurations for vim-markdown
    vim.g.vim_markdown_folding_disabled = 1 -- Disable folding
    vim.g.vim_markdown_conceal = 0 -- Disable conceal
    vim.g.vim_markdown_frontmatter = 1 -- Enable front matter syntax
  end,
}
