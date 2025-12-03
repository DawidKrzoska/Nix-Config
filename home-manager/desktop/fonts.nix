{ pkgs, ... }: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "Fira Code Nerd Font";
      package = pkgs.nerd-fonts.override { fonts = [ "Fira Code" ]; };
    };
  };
}
