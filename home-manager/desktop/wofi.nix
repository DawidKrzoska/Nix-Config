{
  desktopTheme,
  ...
}: let
  colors = desktopTheme.catppuccin;
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
        font-family: "${desktopTheme.font}";
        font-size: 15px;
      }

      window {
        margin: 0;
        padding: 18px;
        border: 1px solid ${colors.border};
        border-radius: 18px;
        background-color: rgba(24, 24, 37, 0.88);
        color: ${colors.text};
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
        background-color: rgba(49, 50, 68, 0.96);
        color: ${colors.text};
      }

      #input:focus {
        border-color: ${colors.accent};
      }

      #inner-box {
        margin: 0;
        padding: 4px;
        border-radius: 16px;
        background-color: rgba(30, 30, 46, 0.58);
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
        border-color: ${colors.accent};
        background-color: rgba(49, 50, 68, 0.92);
      }

      #img {
        margin-right: 12px;
      }

      #text {
        color: ${colors.subtext1};
      }

      #entry:selected #text {
        color: ${colors.text};
      }
    '';
  };
}
