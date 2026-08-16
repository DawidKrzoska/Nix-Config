{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./modules/theme-core.nix
    ./shell/cli.nix
    ./shell/opencode
    ./shell/shell.nix
    ./shell/tmux.nix
    ./shell/kitty.nix
    ./nixvim/default.nix
    inputs.nixvim.homeModules.nixvim
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  home = {
    username = "dawid";
    homeDirectory = "/Users/dawid";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Home Manager 25.11+ copies Darwin app bundles to a user-owned directory.
  # Kitty is the only GUI application in this profile; no system Applications,
  # Dock, Finder, defaults, services, or nix-darwin settings are managed.
  targets.darwin.copyApps = {
    enable = true;
    directory = "Applications/Nix Apps";
  };
}
