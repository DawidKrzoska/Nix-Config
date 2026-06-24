{ config, pkgs, ... }:
let
  wallpaper = "${./wallpapers/Cry.jpg}";
in {
  services.hyprpaper.enable = true;

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${wallpaper}

    wallpaper {
        monitor = DP-1
        path = ${wallpaper}
    }

    wallpaper {
        monitor = HDMI-A-1
        path = ${wallpaper}
    }
  '';
}
