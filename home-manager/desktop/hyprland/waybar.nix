{ config, lib, pkgs, inputs, ... }:
let
  # Dependencies
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  theme = config.wolfar.theme;
  colors = theme.palette;
  playerctl = lib.getExe pkgs.playerctl;
  jq = lib.getExe pkgs.jq;
  youtubeMusicCli =
    lib.getExe inputs.youtube-music-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  # Let it try to start a few more times
  systemd.user.services.waybar = { Unit.StartLimitBurst = 30; };
  services.playerctld.enable = true;
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
        modules-left = [ "hyprland/workspaces" "custom/media" ];

        modules-center = [ "cpu" "memory" "pulseaudio" ];

        modules-right = [ "bluetooth" "network" "clock" ];

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

        "custom/media" = {
          interval = 2;
          exec = "${pkgs.writeShellScript "waybar-media" ''
            state_file="$HOME/.youtube-music-cli/player-state.json"

            if [ ! -f "$state_file" ]; then
              exit 0
            fi

            track="$(${jq} -r '
              if .currentTrack == null then
                empty
              else
                ((.currentTrack.artists // []) | map(.name) | join(", ")) as $artists
                | if $artists == "" then .currentTrack.title else "\($artists) - \(.currentTrack.title)" end
              end
            ' "$state_file" 2>/dev/null)"

            if [ -z "$track" ] || [ "$track" = "null" ]; then
              exit 0
            fi

            printf '󰎆 %s\n' "$track"
          ''}";
          on-click = "${youtubeMusicCli} pause || ${youtubeMusicCli} resume";
          on-click-right = "${youtubeMusicCli} skip";
          on-click-middle = "${youtubeMusicCli} back";
          max-length = 48;
          format = "{}";
          tooltip = false;
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
        bluetooth = {
          format = "";
          format-disabled = "󰂲";
          format-off = "󰂲";
          format-on = "";
          format-connected = " {device_alias}";
          format-connected-battery =
            " {device_alias} {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\n{num_connections} connected";
          tooltip-format-enumerate-connected = "{device_alias}";
          tooltip-format-enumerate-connected-battery =
            "{device_alias}\t{device_battery_percentage}%";
          on-click = "blueman-manager";
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
        font-family: "DejaVu Sans", "Symbols Nerd Font Mono";
        font-size: 13px;
        padding: 0;
        margin: 0;
        min-height: 0;
        border: none;
      }

      window#waybar {
        background: transparent;
        color: ${theme.semantic.text};
      }

      tooltip {
        background: ${theme.semantic.overlayBackground};
        border: 1px solid ${theme.semantic.border};
        border-radius: 12px;
      }

      tooltip label {
        color: ${theme.semantic.text};
      }

      .modules-left,
      .modules-center,
      .modules-right {
        margin: 0 8px;
      }

      #workspaces,
      #custom-media,
      #cpu,
      #memory,
      #pulseaudio,
      #bluetooth,
      #network,
      #clock {
        margin: 0 6px;
        padding: 9px 14px;
        border: 1px solid ${theme.semantic.border};
        border-radius: ${toString theme.semantic.radius.panel}px;
        background: alpha(${theme.semantic.panelBackground}, ${toString theme.semantic.opacity.panel});
        color: ${theme.semantic.text};
      }

      #workspaces {
        padding: 5px;
      }

      #workspaces button {
        margin: 0 4px;
        padding: 5px 10px;
        border-radius: ${toString theme.semantic.radius.workspace}px;
        color: ${theme.semantic.mutedText};
        background: transparent;
      }

      #workspaces button:hover {
        background: alpha(${theme.semantic.hoverBackground}, 0.9);
        color: ${theme.semantic.text};
      }

      #workspaces button.active {
        background: ${theme.semantic.accent};
        color: ${colors.crust};
      }

      #workspaces button.urgent {
        background: ${theme.semantic.danger};
        color: ${colors.crust};
      }

      #custom-media {
        color: ${theme.semantic.success};
      }

      #cpu {
        color: ${theme.semantic.warning};
      }

      #memory {
        color: ${colors.peach};
      }

      #pulseaudio {
        color: ${theme.semantic.info};
      }

      #bluetooth {
        color: ${colors.blue};
      }

      #network {
        color: ${theme.semantic.highlight};
      }

      #clock {
        padding-left: 18px;
        padding-right: 18px;
        color: ${colors.lavender};
      }
    '';
  };
}
