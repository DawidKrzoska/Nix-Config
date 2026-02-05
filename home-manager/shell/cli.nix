{ config, pkgs, inputs, ... }:
let

in {
  home.packages = with pkgs; [
    gnumake
    playerctl
    ripgrep
    fd
    gcc
    go
    golangci-lint
    wget
    unzip
    tmux
    htop
    git
    gh
    killall
    rustup
    nodejs
    neofetch
    inputs.codex-cli-nix.packages.x86_64-linux.default
  ];

}
