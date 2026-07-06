{
  programs.nixvim.plugins.none-ls = {
    enable = true;
    sources = {
      diagnostics = { ltrs.enable = false; };
      formatting = {
        nixfmt.enable = true;
        markdownlint.enable = true;
      };
    };
    # Prevent null-ls from attaching to virtual buffers like diffview://
    settings.on_attach = ''
      function(client, bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("^diffview://") then
          vim.lsp.buf_detach_client(bufnr, client.id)
        end
      end
    '';
  };
}
