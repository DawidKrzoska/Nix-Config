{ config, pkgs, ... }:
let

in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload =
        [ "~/wolfar-nix-config/home-manager/desktop/hyprland/wallpapers/Cry.jpg" ];

      wallpaper = [
        "DP-3, ~/wolfar-nix-config/home-manager/desktop/hyprland/wallpapers/Cry.jpg"
        "HDMI-A-1, ~/wolfar-nix-config/home-manager/desktop/hyprland/wallpapers/Cry.jpg"
      ];
    };
  };
}
