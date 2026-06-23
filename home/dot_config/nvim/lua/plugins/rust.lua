return {
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    opts = function(_, opts)
      opts.server = opts.server or {}
      opts.server.default_settings = opts.server.default_settings or {}
      opts.server.default_settings["rust-analyzer"] =
        opts.server.default_settings["rust-analyzer"] or {}
      opts.server.default_settings["rust-analyzer"].inlayHints = { enable = true }

      local orig_on_attach = opts.server.on_attach
      opts.server.on_attach = function(client, bufnr)
        if orig_on_attach then
          orig_on_attach(client, bufnr)
        end
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
  },
}
