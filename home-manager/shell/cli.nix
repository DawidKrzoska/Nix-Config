{ config, pkgs, ... }:
let

in {
  home.packages = with pkgs; [
    playerctl
    ripgrep
    fd
    gcc
    wget
    unzip
    tmux
    htop
    git
    gh
    killall
    rustup
    neofetch
  ];

}
