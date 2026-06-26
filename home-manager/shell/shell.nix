{ config, ... }: {
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs = {
    zsh = {
      enable = true;
    };
    starship.enable = true;
  };
}
