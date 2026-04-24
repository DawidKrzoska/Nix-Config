{ outputs, config, lib, pkgs, inputs, desktopTheme, ... }:
let
  # Dependencies
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  hyprland = config.wayland.windowManager.hyprland.package;
  colors = desktopTheme.catppuccin;
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
        font-family: "${desktopTheme.font}";
        font-size: 13px;
        padding: 0;
        margin: 0;
        min-height: 0;
        border: none;
      }

      window#waybar {
        background: transparent;
        color: ${colors.text};
      }

      tooltip {
        background: ${colors.mantle};
        border: 1px solid ${colors.surface1};
        border-radius: 12px;
      }

      tooltip label {
        color: ${colors.text};
      }

      .modules-left,
      .modules-center,
      .modules-right {
        margin: 0 8px;
      }

      #workspaces,
      #custom-spotify,
      #cpu,
      #memory,
      #pulseaudio,
      #network,
      #clock {
        margin: 0 6px;
        padding: 9px 14px;
        border: 1px solid ${colors.surface1};
        border-radius: 14px;
        background: alpha(${colors.base}, 0.82);
        color: ${colors.text};
      }

      #workspaces {
        padding: 5px;
      }

      #workspaces button {
        margin: 0 4px;
        padding: 5px 10px;
        border-radius: 10px;
        color: ${colors.subtext0};
        background: transparent;
      }

      #workspaces button:hover {
        background: alpha(${colors.surface0}, 0.9);
        color: ${colors.text};
      }

      #workspaces button.active {
        background: ${colors.accent};
        color: ${colors.crust};
      }

      #workspaces button.urgent {
        background: ${colors.red};
        color: ${colors.crust};
      }

      #custom-spotify {
        color: ${colors.green};
      }

      #cpu {
        color: ${colors.yellow};
      }

      #memory {
        color: ${colors.peach};
      }

      #pulseaudio {
        color: ${colors.sky};
      }

      #network {
        color: ${colors.sapphire};
      }

      #clock {
        padding-left: 18px;
        padding-right: 18px;
        color: ${colors.lavender};
      }
    '';
  };
}
