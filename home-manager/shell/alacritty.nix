{ config, ... }:
let
  theme = config.wolfar.theme;
  colors = theme.palette;
in {

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = theme.semantic.opacity.panel;
        padding = {
          x = 10;
          y = 12;
        };
      };
      font = {
        normal = {
          family = "FiraCode Nerd Font Mono";
          style = "Book";
        };
        bold = {
          family = "FiraCode Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font Mono";
          style = "Book";
        };
        bold_italic = {
          family = "FiraCode Nerd Font Mono";
          style = "Bold";
        };
        size = theme.font.monospace.size;
      };
      colors = {
        primary = {
          background = colors.base;
          foreground = colors.text;
          dim_foreground = colors.subtext0;
          bright_foreground = colors.rosewater;
        };
        cursor = {
          text = colors.base;
          cursor = colors.rosewater;
        };
        vi_mode_cursor = {
          text = colors.base;
          cursor = colors.lavender;
        };
        search.matches = {
          foreground = colors.base;
          background = colors.yellow;
        };
        search.focused_match = {
          foreground = colors.base;
          background = colors.green;
        };
        hints.start = {
          foreground = colors.base;
          background = colors.yellow;
        };
        hints.end = {
          foreground = colors.text;
          background = colors.surface0;
        };
        selection = {
          text = colors.text;
          background = colors.surface2;
        };
        normal = {
          black = colors.surface1;
          red = colors.red;
          green = colors.green;
          yellow = colors.yellow;
          blue = colors.blue;
          magenta = colors.pink;
          cyan = colors.sky;
          white = colors.subtext1;
        };
        bright = {
          black = colors.surface2;
          red = colors.red;
          green = colors.green;
          yellow = colors.yellow;
          blue = colors.blue;
          magenta = colors.pink;
          cyan = colors.sky;
          white = colors.text;
        };
        dim = {
          black = colors.surface0;
          red = colors.maroon;
          green = colors.teal;
          yellow = colors.peach;
          blue = colors.sapphire;
          magenta = colors.flamingo;
          cyan = colors.sky;
          white = colors.subtext0;
        };
      };
    };
  };
}
