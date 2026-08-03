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
      "git status" = "allow";
      "git diff" = "allow";
      "git diff *" = "allow";
      "git log" = "allow";
      "git log *" = "allow";
      "git add *" = "allow";
      "git commit *" = "allow";
      "git push" = "allow";
      "git push *" = "allow";
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
