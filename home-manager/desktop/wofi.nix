{
  config,
  ...
}: let
  theme = config.wolfar.theme;
  colors = theme.palette;
in {
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      prompt = "Launch";
      location = "center";
      lines = 8;
      width = 720;
      allow_markup = true;
      allow_images = true;
      image_size = 20;
      hide_scroll = true;
      no_actions = true;
      term = "alacritty";
    };

    style = ''
      * {
        font-family: "DejaVu Sans", "Symbols Nerd Font Mono";
        font-size: 15px;
      }

      window {
        margin: 0;
        padding: 18px;
        border: 1px solid ${theme.semantic.border};
        border-radius: ${toString theme.semantic.radius.menu}px;
        background-color: alpha(${theme.semantic.overlayBackground}, ${toString theme.semantic.opacity.overlay});
        color: ${theme.semantic.text};
      }

      #outer-box {
        margin: 0;
        padding: 0;
      }

      #input {
        margin: 0 0 14px 0;
        padding: 14px 16px;
        border: 1px solid ${colors.surface1};
        border-radius: 14px;
        background-color: alpha(${colors.surface0}, 0.96);
        color: ${theme.semantic.text};
      }

      #input:focus {
        border-color: ${theme.semantic.accent};
      }

      #inner-box {
        margin: 0;
        padding: 4px;
        border-radius: 16px;
        background-color: alpha(${theme.semantic.panelBackground}, 0.58);
      }

      #scroll {
        margin: 0;
        padding: 0;
      }

      #entry {
        margin: 6px;
        padding: 12px 14px;
        border: 1px solid transparent;
        border-radius: 14px;
        background-color: transparent;
      }

      #entry:selected {
        border-color: ${theme.semantic.accent};
        background-color: alpha(${colors.surface0}, 0.92);
      }

      #img {
        margin-right: 12px;
      }

      #text {
        color: ${colors.subtext1};
      }

      #entry:selected #text {
        color: ${theme.semantic.text};
      }
    '';
  };
}
