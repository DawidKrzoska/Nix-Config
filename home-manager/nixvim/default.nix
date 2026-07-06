{ config, ... }: let
  theme = config.wolfar.theme;
in {
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
    ./gitsigns.nix
    ./diffview.nix
  ];

  programs.nixvim = {
    enable = true;
    plugins.web-devicons.enable = true;
    plugins.mini = {
      mockDevIcons = true;
      modules.icons.enable = true;
    };
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = theme.flavor;
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
