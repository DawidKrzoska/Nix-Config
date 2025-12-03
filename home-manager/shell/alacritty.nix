{ config, pkgs, ... }:
let

in {

  programs.alacritty = {
    enable = true;
    settings = {
      window.padding = {
        x = 2;
        y = 10;
      };
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
      };
    };
  };
}
