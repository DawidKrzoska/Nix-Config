{ config, pkgs, ... }:
let

in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload =
        [ "~/wolfar-nix-config/home-manager/desktop/hyprland/wallpapers/Cry.jpg" ];

      wallpaper = [
        "DP-2, ~/wolfar-nix-config/home-manager/desktop/hyprland/wallpapers/Cry.jpg"
        "HDMI-1, ~/wolfar-nix-config/home-manager/desktop/hyprland/wallpapers/Cry.jpg"
      ];
    };
  };
}
