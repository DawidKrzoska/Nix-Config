{
  programs.nixvim.plugins.none-ls = {
    enable = true;
    # We provide a custom on_attach (for diffview exclusion + format-on-save),
    # so disable the built-in lsp-format integration to avoid the warning.
    enableLspFormat = false;
    sources = {
      diagnostics = { ltrs.enable = false; };
      formatting = {
        nixfmt.enable = true;
        markdownlint.enable = true;
      };
    };
    settings.on_attach = ''
      function(client, bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        -- Don't attach to virtual buffers like diffview://
        if bufname:match("^diffview://") then
          vim.lsp.buf_detach_client(bufnr, client.id)
          return
        end
        -- Format on save using none-ls formatters
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
          end,
        })
      end
    '';
  };
}
