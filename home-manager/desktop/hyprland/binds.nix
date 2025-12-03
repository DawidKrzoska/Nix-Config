{ lib, pkgs, config, ... }: {
  wayland.windowManager.hyprland.settings = {
    bind = let
      workspaces = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" ];
      # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
      directions = rec {
        left = "l";
        right = "r";
        up = "u";
        down = "d";
        h = left;
        l = right;
        k = up;
        j = down;
      };
      pactl = lib.getExe' pkgs.pulseaudio "pactl";
      playerctl = lib.getExe' config.services.playerctld.package "playerctl";
    in [
      "SUPER,q,killactive"
      "SUPER,m,exit"
      "SUPER,f,fullscreen,1"
      "SUPER,t,exec,alacritty"
      "SUPER,o,exec,wofi --show drun"
      ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
      ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
      ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
      "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
      ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
      ",XF86AudioNext,exec,${playerctl} next"
      ",XF86AudioPrev,exec,${playerctl} previous"
      ",XF86AudioPlay,exec,${playerctl} play-pause"

    ] ++
    # Change workspace
    (map (n: "SUPER,${n},workspace,name:${n}") workspaces) ++
    # Move window to workspace
    (map (n: "SUPERSHIFT,${n},movetoworkspacesilent,name:${n}") workspaces) ++
    # Move focus
    (lib.mapAttrsToList (key: direction: "SUPER,${key},movefocus,${direction}")
      directions) ++
    # Swap windows
    (lib.mapAttrsToList
      (key: direction: "SUPERSHIFT,${key},swapwindow,${direction}") directions)
    ++
    # Move windows
    (lib.mapAttrsToList
      (key: direction: "SUPERCONTROL,${key},movewindoworgroup,${direction}")
      directions) ++
    # Move monitor focus
    (lib.mapAttrsToList
      (key: direction: "SUPERALT,${key},focusmonitor,${direction}") directions)
    ++
    # Move workspace to other monitor
    (lib.mapAttrsToList (key: direction:
      "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}")
      directions);
  };
}
