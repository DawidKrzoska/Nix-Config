{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.wolfar.opencode;
  inherit (lib) mkIf;

  skillDir = ./skills;
  skillEntries = builtins.readDir skillDir;
  skillDirs = builtins.filter
    (name: skillEntries.${name} == "directory")
    (builtins.attrNames skillEntries);
  skillFiles = builtins.listToAttrs (map
    (name: {
      name = "opencode/skills/${name}/SKILL.md";
      value.source = skillDir + "/${name}/SKILL.md";
    })
    skillDirs);

  jsonSections = [
    (import ./base.nix { inherit config lib pkgs inputs; })
    (import ./permissions.nix { inherit config lib pkgs inputs; })
    (import ./formatter.nix { inherit config lib pkgs inputs; })
    (import ./references.nix { inherit config lib pkgs inputs; })
    (import ./commands.nix { inherit config lib pkgs inputs; })
    (import ./mcp.nix { inherit config lib pkgs inputs; })
    (import ./skills.nix { inherit config lib pkgs inputs; })
    (import ./agents.nix { inherit config lib pkgs inputs; })
  ];
  mergedJson = lib.foldl' (acc: section: acc // section) { } jsonSections;
in
{
  options.wolfar.opencode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable opencode.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.opencode.packages.x86_64-linux.default;
      defaultText = lib.literalExpression "inputs.opencode.packages.x86_64-linux.default";
      description = "opencode package to use";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = skillFiles // {
      "opencode/opencode.json".text = builtins.toJSON mergedJson;
    };
  };
}
