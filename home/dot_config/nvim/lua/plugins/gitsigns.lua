-- Inline current-line git blame (the grey "You, 2 months ago - …" virtual text).
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 300,
      ignore_whitespace = false,
    },
    -- Mirrors the "<author>, <relative time> - <summary>" format in the demo.
    current_line_blame_formatter = "  <author>, <author_time:%R> - <summary>",
  },
}
