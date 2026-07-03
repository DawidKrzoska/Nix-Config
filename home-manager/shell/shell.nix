{ config, ... }: {
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs = {
    zsh = {
      enable = true;
      initContent = ''
        bindkey -M viins "^R" history-incremental-search-backward
      '';
    };
    starship.enable = true;
  };
}
