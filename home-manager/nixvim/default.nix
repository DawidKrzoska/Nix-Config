{
  imports = [
    ./telescope.nix
    ./neo-tree.nix
    ./keymaps.nix
    ./bufferline.nix
    ./treesitter.nix
    ./none-ls.nix
    ./lsp.nix
    ./cmp.nix
    ./options.nix
    ./lualine.nix
  ];

  programs.nixvim = {
    enable = true;
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparentBackground = true;
        showBufferEnd = true;
        integrations = {
          neotree = true;
          indent_blankline.enabled = true;
        };
      };
    };
  };
}
