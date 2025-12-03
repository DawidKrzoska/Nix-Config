{
  programs.nixvim.plugins.none-ls = {
    enable = true;
    sources = {
      diagnostics = { ltrs.enable = true; };
      formatting = {
        nixfmt.enable = true;
        markdownlint.enable = true;
      };
    };
  };
}
