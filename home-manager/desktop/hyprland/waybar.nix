{ config, lib, pkgs, ... }:
let
  # Dependencies
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  theme = config.wolfar.theme;
  colors = theme.palette;
  playerctl = lib.getExe pkgs.playerctl;
  inherit (pkgs) jq curl procps;

  # OpenAI quota script: fetches usage from chatgpt.com API
  openaiQuotaScript = pkgs.writeShellScript "openai-quota" ''
    JQ=${jq}/bin/jq
    CURL=${curl}/bin/curl

    AUTH_FILE="$HOME/.local/share/opencode/auth.json"
    STATE_FILE="/tmp/waybar-openai-quota-view"
    CLIENT_ID="app_EMoamEEZ73f0CkXaXp7hramn"

    # Default values for error state
    TEXT="  ??"
    CLASS="ok"
    ALT="unknown"
    TOOLTIP=""

    error_exit() {
      $JQ -c -n --arg text "$TEXT" --arg alt "$ALT" --arg cls "$CLASS" --arg tooltip "$TOOLTIP" '{text: $text, alt: $alt, class: $cls, tooltip: $tooltip}'
      exit 0
    }

    [ -f "$AUTH_FILE" ] || error_exit

    ACCESS=$($JQ -r '.openai.access' "$AUTH_FILE")
    REFRESH=$($JQ -r '.openai.refresh' "$AUTH_FILE")
    EXPIRES=$($JQ -r '.openai.expires' "$AUTH_FILE")

    [ "$ACCESS" != "null" ] && [ -n "$ACCESS" ] || error_exit

    # Refresh token if expired (timestamps are in milliseconds)
    NOW_MS=$(date +%s%3N)
    if [ "$EXPIRES" != "null" ] && [ -n "$EXPIRES" ] && [ "$NOW_MS" -ge "$EXPIRES" ] 2>/dev/null; then
      RESP=$($CURL -s -X POST "https://auth.openai.com/oauth/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=refresh_token&refresh_token=$REFRESH&client_id=$CLIENT_ID")

      NEW_ACCESS=$(echo "$RESP" | $JQ -r '.access_token')
      NEW_REFRESH=$(echo "$RESP" | $JQ -r '.refresh_token')
      EXPIRES_IN=$(echo "$RESP" | $JQ -r '.expires_in')

      if [ -n "$NEW_ACCESS" ] && [ "$NEW_ACCESS" != "null" ]; then
        ACCESS="$NEW_ACCESS"
        NEW_EXPIRES_MS=$(( $(date +%s%3N) + EXPIRES_IN * 1000 ))

        $JQ --arg access "$NEW_ACCESS" \
            --arg refresh "$NEW_REFRESH" \
            --argjson expires "$NEW_EXPIRES_MS" \
            '.openai.access = $access | .openai.refresh = $refresh | .openai.expires = $expires' \
            "$AUTH_FILE" > "$AUTH_FILE.tmp" && mv "$AUTH_FILE.tmp" "$AUTH_FILE"
      else
        error_exit
      fi
    fi

    # Fetch quota from OpenAI
    RESP=$($CURL -s -H "Authorization: Bearer $ACCESS" "https://chatgpt.com/backend-api/wham/usage")

    USED_PRIMARY=$(echo "$RESP" | $JQ -r '.rate_limit.primary_window.used_percent')
    USED_SECONDARY=$(echo "$RESP" | $JQ -r '.rate_limit.secondary_window.used_percent')
    PLAN=$(echo "$RESP" | $JQ -r '.plan_type')
    LIMIT_REACHED=$(echo "$RESP" | $JQ -r '.rate_limit.limit_reached // false')
    RESET_SECONDS=$(echo "$RESP" | $JQ -r '.rate_limit.primary_window.reset_after_seconds // 0')
    RESET_SECONDS_7D=$(echo "$RESP" | $JQ -r '.rate_limit.secondary_window.reset_after_seconds // 0')
    RESET_CREDITS=$(echo "$RESP" | $JQ -r '.rate_limit_reset_credits.available_count // 0')

    [ "$USED_PRIMARY" != "null" ] && [ -n "$USED_PRIMARY" ] || error_exit

    # Format remaining time until 5h window resets
    if [ "$RESET_SECONDS" -gt 0 ] 2>/dev/null; then
      RESET_HOURS=$(( RESET_SECONDS / 3600 ))
      RESET_MINS=$(( (RESET_SECONDS % 3600) / 60 ))
      if [ "$RESET_HOURS" -gt 0 ]; then
        RESET_DISPLAY="''${RESET_HOURS}h''${RESET_MINS}m"
      else
        RESET_SECS=$(( RESET_SECONDS % 60 ))
        RESET_DISPLAY="''${RESET_MINS}m''${RESET_SECS}s"
      fi
    else
      RESET_DISPLAY=""
    fi

    # Format remaining time until 7d window resets
    if [ "$RESET_SECONDS_7D" -gt 0 ] 2>/dev/null; then
      RESET_DAYS_7D=$(( RESET_SECONDS_7D / 86400 ))
      RESET_HOURS_7D=$(( (RESET_SECONDS_7D % 86400) / 3600 ))
      RESET_DISPLAY_7D="''${RESET_DAYS_7D}d''${RESET_HOURS_7D}h"
    else
      RESET_DISPLAY_7D=""
    fi

    # Read view state (default to 5h if file missing)
    STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "5h")

    if [ "$STATE" = "7d" ]; then
      DISPLAY_PCT=$USED_SECONDARY
      LABEL="7d"
      ALT="weekly"
      REMAINING=$(( 100 - DISPLAY_PCT ))
      if [ "$REMAINING" -lt 0 ]; then REMAINING=0; fi
      TEXT="  7d $REMAINING%"
      TOOLTIP=$(printf 'OpenAI %s\n━━━ Windows ━━━\n7d: %s%% used (%s%% remaining, resets in %s)\n5h: %s%% used (resets in %s)' \
        "$PLAN" \
        "$USED_SECONDARY" "$REMAINING" "$RESET_DISPLAY_7D" \
        "$USED_PRIMARY" "$RESET_DISPLAY")
    else
      DISPLAY_PCT=$USED_PRIMARY
      LABEL="5h"
      ALT="5h"
      REMAINING=$(( 100 - DISPLAY_PCT ))
      if [ "$REMAINING" -lt 0 ]; then REMAINING=0; fi
      if [ "$LIMIT_REACHED" = "true" ] && [ "$REMAINING" -le 0 ] 2>/dev/null; then
        # At the cap — show countdown prominently
        TEXT="  5h ⏳$RESET_DISPLAY"
      elif [ "$REMAINING" -le 10 ] 2>/dev/null; then
        TEXT="  5h $REMAINING% ⏳$RESET_DISPLAY"
      else
        TEXT="  5h $REMAINING%"
      fi
      TOOLTIP=$(printf 'OpenAI %s\n━━━ Windows ━━━\n5h: %s%% used (%s%% remaining)\n    resets in %s\n7d: %s%% used (%s%% remaining, resets in %s)' \
        "$PLAN" \
        "$USED_PRIMARY" "$REMAINING" \
        "$RESET_DISPLAY" \
        "$USED_SECONDARY" "$((100 - USED_SECONDARY))" "$RESET_DISPLAY_7D")
    fi

    # Add reset credits info if available
    if [ "$RESET_CREDITS" -gt 0 ] 2>/dev/null; then
      TOOLTIP="$TOOLTIP"$'\n'"━━━ Reset ━━━"$'\n'"⚡ Credits: $RESET_CREDITS available"
    fi

    # Color thresholds based on used_percent
    if [ "$DISPLAY_PCT" -ge 81 ]; then
      CLASS="crit"
    elif [ "$DISPLAY_PCT" -ge 51 ]; then
      CLASS="warn"
    fi

    $JQ -c -n \
      --arg text "$TEXT" \
      --arg alt "$ALT" \
      --arg cls "$CLASS" \
      --arg tooltip "$TOOLTIP" \
      '{text: $text, alt: $alt, class: $cls, tooltip: $tooltip}'
  '';

  # Toggles the quota view between 5h and 7d, then refreshes only this module via SIGRTMIN+4
  toggleOpenaiQuotaView = pkgs.writeShellScript "toggle-openai-quota-view" ''
    STATE_FILE="/tmp/waybar-openai-quota-view"
    CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "5h")
    if [ "$CURRENT" = "5h" ]; then
      echo "7d" > "$STATE_FILE"
    else
      echo "5h" > "$STATE_FILE"
    fi
    ${procps}/bin/pkill -RTMIN+4 waybar 2>/dev/null || true
  '';
in {
  # Let it try to start a few more times
  systemd.user.services.waybar = { Unit.StartLimitBurst = 30; };
  services.playerctld.enable = true;

  # Create state file for OpenAI quota view toggle on every login
  systemd.user.tmpfiles.rules = [
    "f /tmp/waybar-openai-quota-view 0644 - - - 5h"
  ];
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

        modules-center = [ "cpu" "memory" "pulseaudio" "custom/gpu" ];

        modules-right = [ "bluetooth" "custom/openai-quota" "custom/weather" "network" "clock" ];

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
        "custom/gpu" = {
          interval = 2;
          exec = "${pkgs.writeShellScript "waybar-gpu" ''
            gpu_busy="$(cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null || echo 0)"
            vram_total="$(cat /sys/class/drm/card1/device/mem_info_vram_total 2>/dev/null || echo 0)"
            vram_used="$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null || echo 0)"

            vram_total_gib=$(( vram_total * 10 / 1073741824 ))
            vram_used_gib=$(( vram_used * 10 / 1073741824 ))

            printf '󰾲  %s%%    %d.%d/%d.%dGiB\n' \
              "$gpu_busy" \
              "$(( vram_used_gib / 10 ))" "$(( vram_used_gib % 10 ))" \
              "$(( vram_total_gib / 10 ))" "$(( vram_total_gib % 10 ))"
          ''}";
          format = "{}";
          tooltip = false;
        };

        "custom/openai-quota" = {
          interval = 120;
          exec = "${openaiQuotaScript}";
          return-type = "json";
          on-click = "${toggleOpenaiQuotaView}";
          signal = 4;
          tooltip = true;
        };

        "custom/weather" = {
          interval = 900;
          exec = "${pkgs.writeShellScript "waybar-weather" ''
            weather="$(${curl}/bin/curl -fsSL --max-time 10 'https://wttr.in/Bielsko-Biala?format=%c+%t' 2>/dev/null || true)"
            printf '%s\n' "''${weather:-󰖐  --°C}"
          ''}";
          format = "{}";
          tooltip = false;
        };

        "custom/media" = {
          interval = 2;
          exec = "${pkgs.writeShellScript "waybar-media" ''
            status="$(${playerctl} status 2>/dev/null)"
            if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
              exit 0
            fi

            track="$(${playerctl} metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)"
            if [ -z "$track" ] || [ "$track" = " - " ]; then
              track="$(${playerctl} metadata --format '{{ title }}' 2>/dev/null)"
            fi

            if [ -z "$track" ]; then
              exit 0
            fi

            printf '󰎆 %s\n' "$track"
          ''}";
          on-click = "${playerctl} play-pause";
          on-click-right = "${playerctl} next";
          on-click-middle = "${playerctl} previous";
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
       #custom-gpu,
       #custom-openai-quota,
       #custom-weather,
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

      #custom-gpu {
        color: ${colors.mauve};
      }

      #custom-openai-quota {
        color: ${theme.semantic.text};
      }

      #custom-openai-quota.warn {
        color: ${theme.semantic.warning};
      }

       #custom-openai-quota.crit {
         color: ${theme.semantic.danger};
       }

       #custom-weather {
         color: ${colors.sky};
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
