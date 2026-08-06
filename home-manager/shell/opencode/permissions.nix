{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  permission = {
    # opencode evaluates the LAST matching rule: broad rules first, narrow rules last.
    bash = {
      "*" = "ask";
      "nix develop *" = "allow";
      "tmux *" = "allow";
      "git *" = "allow";
      "jq *" = "allow";
      "python *" = "allow";
      "python3 *" = "allow";
      "rg *" = "allow";
      "grep *" = "allow";
      "find *" = "allow";
      "sed *" = "allow";
      "awk *" = "allow";
      "cat *" = "allow";
      "head *" = "allow";
      "tail *" = "allow";
      "ls *" = "allow";
      "pwd" = "allow";
      "which *" = "allow";
      "node *" = "allow";
      "pnpm *" = "allow";
      "gh *" = "allow";
      "home-manager switch *" = "allow";
      "nix build *" = "allow";
      "sudo *" = "deny";
      # Only the user-approved system rebuild command is askable; all other sudo stays denied.
      "sudo nixos-rebuild switch --flake .#nixos" = "ask";
      "rm -rf /" = "deny";
      "rm -rf /*" = "deny";
      "rm -rf ~" = "deny";
      "rm -rf ~/*" = "deny";
    };
    edit = "ask";
    read = {
      ".env" = "ask";
      ".env.*" = "ask";
      "*" = "allow";
    };
  };
}
