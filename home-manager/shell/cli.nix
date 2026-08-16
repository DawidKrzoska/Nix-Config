{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  home.packages =
    (with pkgs; [
      gnumake
      ripgrep
      fd
      wget
      unzip
      tmux
      htop
      git
      gh
      nodejs
      pnpm
      python3
      fastfetch
      inputs.codex-cli-nix.packages.${pkgs.system}.default
    ])
    ++ lib.optionals isLinux (with pkgs; [
      playerctl
      gcc
      go
      golangci-lint
      killall
      rustup
      bun
      wl-clipboard
      cliphist
      polkit_gnome
    ]);
}
