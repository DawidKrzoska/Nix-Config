{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.wolfar.opencode;
in {
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

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."opencode/opencode.json" = {
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        default_agent = "build";
      };
    };
  };
}
