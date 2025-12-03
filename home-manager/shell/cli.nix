{ config, pkgs, inputs, ... }:
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
    inputs.codex-cli-nix.packages.x86_64-linux.default
  ];

}
