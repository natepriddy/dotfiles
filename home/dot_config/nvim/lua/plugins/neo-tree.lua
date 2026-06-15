return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        -- Show dotfiles and gitignored files instead of hiding them.
        -- Toggle visibility at runtime with `H` in the neo-tree window.
        visible = true,          -- render filtered items dimmed rather than invisible
        hide_dotfiles = false,   -- dotfiles (e.g. .env, .gitignore) always shown
        hide_gitignored = false, -- gitignored files always shown
      },
    },
  },
}
