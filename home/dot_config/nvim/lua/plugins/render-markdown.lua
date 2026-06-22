-- Render Markdown styling to match the Kun-style AGENTS.md look:
-- numbered heading icons, full-width heading bars, filled bullets.
-- Requires conceallevel >= 2 (LazyVim default once vim-markdown is disabled).
return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    heading = {
      -- Full window-width colored bar behind each heading.
      width = "full",
      -- Conceal the '#'s and inline the icon on the left.
      position = "inline",
      -- Nerd Font numeric-N-box glyphs (mdi), cycled by heading level.
      -- Swap to outline boxes 󰎦 󰎩 󰎬 󰎮 󰎰 󰎵 if you prefer.
      icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      right_pad = 1,
    },
    bullet = {
      -- Filled dot for list items, cycled by nesting depth.
      icons = { "● ", "○ ", "◆ ", "◇ " },
    },
    code = {
      -- Block-style fenced code with a left sign and minimum width.
      width = "block",
      min_width = 60,
      left_pad = 1,
      right_pad = 1,
    },
  },
}
