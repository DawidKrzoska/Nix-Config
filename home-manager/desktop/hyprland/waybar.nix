{ outputs, config, lib, pkgs, inputs, ... }:
let
  # Dependencies
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  hyprland = config.wayland.windowManager.hyprland.package;
in {
  # Let it try to start a few more times
  systemd.user.services.waybar = { Unit.StartLimitBurst = 30; };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      primary = {
        height = 32;
        "margin-bottom" = -11;
        "margin-top" = 5;
        spacing = 0;
        position = "top";
        layer = "top";
        modules-left = [ "hyprland/workspaces" "custom/spotify" ];

        modules-center = [ "cpu" "memory" "pulseaudio" ];

        modules-right = [ "network" "clock" ];

        clock = {
          interval = 1;
          format = "{:%d/%m %H:%M:%S}";
          format-alt = "{:%Y-%m-%d %H:%M:%S %z}";
          on-click-left = "mode";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };

        cpu = { format = "  {usage}%"; };
        memory = { format = "  {percentage}%"; };

        "custom/spotify" = {
          exec =
            "/usr/bin/python3 /full/path/to/mediaplayer.py --player spotify";
          format = "{}  ";
          return-type = "json";
        };
        mpd = {
          format =
            "{stateIcon} {artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
        };

        pulseaudio = {
          format = "{icon}   {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋎";
            portable = "";
            default = [ "" "" "" ];
          };
          on-click = pavucontrol;
        };
        "sway/window" = { max-length = 20; };
        network = {
          interval = 3;
          format-wifi = "   {essid}";
          format-ethernet = "󰈁 Connected";
          format-disconnected = "";
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          on-click = "";
        };
      };
    };
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = ''
      * {
        font-family: FiraCode;
        font-size: 12pt;
        padding: 0;
        margin: 0 0.4em;
      }

      window#waybar {
        padding: 0;
        border-radius: 0.5em;
      }

      .modules-left {
        margin-left: -0.65em;
      }

      .modules-right {
        margin-right: -0.65em;
      }

      #workspaces button {
        padding-left: 0.4em;
        padding-right: 0.4em;
        margin-top: 0.15em;
        margin-bottom: 0.15em;
      }

      #clock {
        padding-right: 1em;
        padding-left: 1em;
        border-radius: 0.5em;
      }
    '';
  };
}
