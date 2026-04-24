{ pkgs, ... }: {
  wolfar.theme = {
    flavor = "mocha";
    accent = "mauve";
    font.monospace = {
      family = "FiraCode Nerd Font Mono";
      package = pkgs.nerd-fonts.fira-code;
      size = 11;
    };
    gtk = {
      size = "compact";
      tweaks = [ "rimless" ];
    };
  };
}
