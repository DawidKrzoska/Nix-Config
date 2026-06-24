{ config, lib, pkgs, ... }:
let
  cfg = config.wolfar.theme;

  palettes = {
    mocha = rec {
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

  capitalize = value:
    let
      head = builtins.substring 0 1 value;
      tail =
        builtins.substring 1 ((builtins.stringLength value) - 1) value;
    in lib.toUpper head + tail;

  cursorVariant = cfg.flavor + capitalize cfg.accent;
  cursorPackage = builtins.getAttr cursorVariant pkgs.catppuccin-cursors;
  gtkThemePackage = pkgs.catppuccin-gtk.override {
    accents = [ cfg.accent ];
    size = cfg.gtk.size;
    tweaks = cfg.gtk.tweaks;
    variant = cfg.flavor;
  };
  gtkTweaksSuffix = lib.optionalString (cfg.gtk.tweaks != [ ])
    "+${lib.concatStringsSep "+" cfg.gtk.tweaks}";
  gtkThemeName =
    "catppuccin-${cfg.flavor}-${cfg.accent}-${cfg.gtk.size}${gtkTweaksSuffix}";
  kvantumPackage = pkgs.catppuccin-kvantum.override {
    accent = cfg.accent;
    variant = cfg.flavor;
  };
  kvantumThemeName = "catppuccin-${cfg.flavor}-${cfg.accent}";
  palette = palettes.${cfg.flavor};
in {
  options.wolfar.theme = {
    flavor = lib.mkOption {
      type = lib.types.enum (builtins.attrNames palettes);
      default = "mocha";
      description = "Catppuccin flavor used across the desktop.";
    };

    accent = lib.mkOption {
      type = lib.types.enum [
        "blue"
        "flamingo"
        "green"
        "lavender"
        "maroon"
        "mauve"
        "peach"
        "pink"
        "red"
        "rosewater"
        "sapphire"
        "sky"
        "teal"
        "yellow"
      ];
      default = "mauve";
      description = "Primary accent color used by Catppuccin theme consumers.";
    };

    font = {
      monospace = {
        family = lib.mkOption {
          type = lib.types.str;
          default = "FiraCode Nerd Font Mono";
          description = "Primary monospace font family.";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.nerd-fonts.fira-code;
          description = "Package providing the configured monospace font.";
        };
        size = lib.mkOption {
          type = lib.types.int;
          default = 11;
          description = "Default monospace font size for terminal-facing applications.";
        };
      };

      sans = {
        family = lib.mkOption {
          type = lib.types.str;
          default = "DejaVu Sans";
          description = "Primary sans-serif font family for GTK applications.";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.dejavu_fonts;
          description = "Package providing the configured sans-serif font.";
        };
      };
    };

    gtk = {
      size = lib.mkOption {
        type = lib.types.enum [ "standard" "compact" ];
        default = "compact";
        description = "GTK theme density.";
      };
      tweaks = lib.mkOption {
        type = lib.types.listOf
          (lib.types.enum [ "black" "rimless" "normal" "float" ]);
        default = [ "rimless" ];
        description = "Extra GTK theme tweaks.";
      };
    };

    palette = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      description = "Resolved Catppuccin palette.";
    };

    semantic = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      readOnly = true;
      description = "Shared semantic design tokens for application modules.";
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
        radius = {
          panel = 14;
          menu = 18;
          workspace = 10;
          window = 10;
        };
        opacity = {
          panel = 0.82;
          overlay = 0.88;
          activeWindow = 0.97;
          inactiveWindow = 0.82;
        };
      };
    };

    fonts.fontconfig.enable = true;

    home.packages = [
      cfg.font.monospace.package
      cfg.font.sans.package
      pkgs.nerd-fonts.symbols-only
      kvantumPackage
    ];

    gtk = {
      enable = true;
      font = {
        name = cfg.font.sans.family;
        package = cfg.font.sans.package;
        size = cfg.font.monospace.size;
      };
      theme = {
        name = gtkThemeName;
        package = gtkThemePackage;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "catppuccin-${cfg.flavor}-${cfg.accent}-cursors";
        package = cursorPackage;
        size = 24;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.theme = {
        name = gtkThemeName;
        package = gtkThemePackage;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "catppuccin-${cfg.flavor}-${cfg.accent}-cursors";
      package = cursorPackage;
      size = 24;
    };

    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "kvantum";
      qt5ctSettings = {
        Appearance = {
          icon_theme = "Papirus-Dark";
          style = "kvantum";
          standard_dialogs = "xdgdesktopportal";
        };
        Fonts = {
          fixed =
            "\"${cfg.font.monospace.family},${toString cfg.font.monospace.size}\"";
          general =
            "\"${cfg.font.monospace.family},${toString cfg.font.monospace.size}\"";
        };
      };
      qt6ctSettings = {
        Appearance = {
          icon_theme = "Papirus-Dark";
          style = "kvantum";
          standard_dialogs = "xdgdesktopportal";
        };
        Fonts = {
          fixed =
            "\"${cfg.font.monospace.family},${toString cfg.font.monospace.size}\"";
          general =
            "\"${cfg.font.monospace.family},${toString cfg.font.monospace.size}\"";
        };
      };
    };

    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=${kvantumThemeName}
      '';
      "Kvantum/${kvantumThemeName}".source =
        "${kvantumPackage}/share/Kvantum/${kvantumThemeName}";
    };
  };
}
