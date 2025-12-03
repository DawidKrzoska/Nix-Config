{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      nixGrammars = true;
    };
    treesitter-context.enable = true;
  };
}
