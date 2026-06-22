-- Comparing transparent dark themes. Both configured with transparency so the
-- terminal background shows through; flip between them live with <leader>uC.
--   rose-pine-moon            (muted, rosé)
--   catppuccin-macchiato      (current default) — also -mocha (darker) / -frappe
-- Switch the default by changing `colorscheme` below.
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "moon",
      styles = {
        italic = false,
        transparency = true,
      },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "macchiato",
      transparent_background = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
}
