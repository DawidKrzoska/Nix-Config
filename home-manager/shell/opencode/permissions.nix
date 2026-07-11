{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  permission = {
    bash = {
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
      "rm -rf /" = "deny";
      "rm -rf /*" = "deny";
      "rm -rf ~" = "deny";
      "rm -rf ~/*" = "deny";
      "*" = "ask";
    };
    edit = "ask";
    read = {
      ".env" = "ask";
      ".env.*" = "ask";
      "*" = "allow";
    };
  };
}
