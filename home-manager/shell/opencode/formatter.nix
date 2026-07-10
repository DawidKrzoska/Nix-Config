{ config, lib, pkgs, inputs, ... }: {
  formatter = {
    prettier = {
      command = [
        "nix"
        "develop"
        "--command"
        "npx"
        "prettier"
        "--write"
        "$FILE"
      ];
      extensions = [
        ".js"
        ".jsx"
        ".ts"
        ".tsx"
        ".json"
        ".css"
        ".md"
      ];
    };
    nixfmt = {
      command = [
        "nixfmt"
        "$FILE"
      ];
      extensions = [ ".nix" ];
    };
  };
}
