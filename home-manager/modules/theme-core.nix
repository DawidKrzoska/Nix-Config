{ config, lib, pkgs, ... }:
let
  cfg = config.wolfar.theme;
  palettes = {
    mocha = {
      rosewater = "#f5e0dc";
      flamingo = "#f2cdcd";
      pink = "#f5c2e7";
      mauve = "#cba6f7";
      red = "#f38ba8";
      maroon = "#eba0ac";
      peach = "#fab387";
      yellow = "#f9e2af";
      green = "#a6e3a1";
      teal = "#94e2d5";
      sky = "#89dceb";
      sapphire = "#74c7ec";
      blue = "#89b4fa";
      lavender = "#b4befe";
      text = "#cdd6f4";
      subtext1 = "#bac2de";
      subtext0 = "#a6adc8";
      overlay2 = "#9399b2";
      overlay1 = "#7f849c";
      overlay0 = "#6c7086";
      surface2 = "#585b70";
      surface1 = "#45475a";
      surface0 = "#313244";
      base = "#1e1e2e";
      mantle = "#181825";
      crust = "#11111b";
    };
  };
  palette = palettes.${cfg.flavor};
in
{
  options.wolfar.theme = {
    flavor = lib.mkOption {
      type = lib.types.enum (builtins.attrNames palettes);
      default = "mocha";
    };
    accent = lib.mkOption {
      type = lib.types.enum [
        "blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach"
        "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow"
      ];
      default = "mauve";
    };
    font.monospace = {
      family = lib.mkOption {
        type = lib.types.str;
        default = "FiraCode Nerd Font Mono";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nerd-fonts.fira-code;
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = 11;
      };
    };
    palette = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
    };
    semantic = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      readOnly = true;
    };
  };

  config = {
    wolfar.theme = {
      palette = palette;
      semantic = {
        accent = palette.${cfg.accent};
        highlight = palette.sapphire;
        border = palette.surface1;
        text = palette.text;
        mutedText = palette.subtext0;
        panelBackground = palette.base;
        overlayBackground = palette.mantle;
        hoverBackground = palette.surface0;
        danger = palette.red;
        success = palette.green;
        warning = palette.yellow;
        info = palette.sky;
        opacity = {
          panel = 0.82;
          overlay = 0.88;
          activeWindow = 0.97;
          inactiveWindow = 0.82;
        };
      };
    };

    home.packages = [
      cfg.font.monospace.package
      pkgs.nerd-fonts.symbols-only
    ];
  };
}
