{ config, lib, pkgs, inputs, ... }: {
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
    fastfetch
    opencode
    inputs.codex-cli-nix.packages.x86_64-linux.default
    inputs.youtube-music-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.desktopEntries.youtube-music-cli = {
    name = "YouTube Music CLI";
    genericName = "YouTube Music Terminal UI";
    comment = "Launch youtube-music-cli in Alacritty";
    exec = "alacritty -e youtube-music-cli";
    terminal = false;
    categories = [ "AudioVideo" "Audio" "Player" "Music" ];
    icon = "multimedia-player";
  };
}
