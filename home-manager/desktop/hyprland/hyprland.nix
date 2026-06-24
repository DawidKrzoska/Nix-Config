{ lib, config, pkgs, ... }:
let
  theme = config.wolfar.theme;
  stripHash = color: lib.removePrefix "#" color;
in {
  imports = [ ./binds.nix ./waybar.nix ./hyprpaper.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    settings = {
      general = {
        gaps_in = 15;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" =
          "rgb(${stripHash theme.semantic.accent}) rgb(${stripHash theme.semantic.highlight}) 45deg";
        "col.inactive_border" = "rgb(${stripHash theme.semantic.border})";
      };

      group = { groupbar.font_size = 11; };

      binds = {
        movefocus_cycles_fullscreen = false;

      };

      input = { kb_layout = "pl,us"; };

      dwindle = {
        split_width_multiplier = 1.35;
        preserve_split = "yes";
      };

      debug = { vfr = true; };

      misc = {
        close_special_on_empty = true;
        focus_on_activate = true;
      };

      decoration = {
        active_opacity = theme.semantic.opacity.activeWindow;
        inactive_opacity = theme.semantic.opacity.inactiveWindow;
        fullscreen_opacity = 1.0;
        rounding = theme.semantic.radius.window;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };
      };
      animations = { enabled = true; };
    };

    extraConfig = ''
      monitor=DP-1,2560x1440,0x0,1
      monitor=HDMI-A-1,1920x1080,-1920x0,1
    '';
    #monitor=Unknown-1,disable,1 '';
  };
}
