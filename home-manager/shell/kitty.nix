{ config, pkgs, ... }:
let
  theme = config.wolfar.theme;
  colors = theme.palette;
in
{
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    font = {
      name = theme.font.monospace.family;
      package = theme.font.monospace.package;
      size = theme.font.monospace.size;
    };
    settings = {
      background_opacity = theme.semantic.opacity.panel;
      window_padding_width = 10;
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      macos_option_as_alt = true;
      background = colors.base;
      foreground = colors.text;
      cursor = colors.rosewater;
      selection_background = colors.surface2;
      selection_foreground = colors.text;
      color0 = colors.surface1;
      color1 = colors.red;
      color2 = colors.green;
      color3 = colors.yellow;
      color4 = colors.blue;
      color5 = colors.pink;
      color6 = colors.sky;
      color7 = colors.subtext1;
      color8 = colors.surface2;
      color9 = colors.red;
      color10 = colors.green;
      color11 = colors.yellow;
      color12 = colors.blue;
      color13 = colors.pink;
      color14 = colors.sky;
      color15 = colors.text;
    };
  };
}
