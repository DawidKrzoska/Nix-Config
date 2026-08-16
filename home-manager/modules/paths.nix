{
  config,
  lib,
  ...
}:
{
  options.wolfar = {
    paths = {
      nixConfig = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/wolfar-nix-config";
        description = "Local checkout path for the Nix configuration repository.";
      };

      tuoStudio = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/TuoStudio";
        description = "Local checkout path for the TuoStudio repository.";
      };
    };

    homeManagerProfile = lib.mkOption {
      type = lib.types.str;
      description = "Home Manager flake profile for this host.";
    };
  };
}
