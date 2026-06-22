-- Disabled: redundant with treesitter + render-markdown.nvim, and its
-- `vim_markdown_conceal = 0` forced conceallevel=0, which suppressed
-- render-markdown's heading icons and inline concealment.
-- Re-enable only if you specifically want :Toc / ]] [[ heading motions / :TableFormat.
return {
  "plasticboy/vim-markdown",
  enabled = false,
}
