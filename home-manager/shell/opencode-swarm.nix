{ config, lib, pkgs, ... }:

let
  pname = "opencode-swarm-plugin";
  version = "0.63.2";

  swarmPlugin = pkgs.buildNpmPackage {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
      hash = "sha256-ZWop4tjcBZrzpq0WPO+JXixv0gzlttB2nhQk9+Ap3T8=";
    };

    postPatch = ''
      cp ${./opencode-swarm-package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-SN3RiyVVHufIIp/FguQuFp55hrw32r4BetyVAadxFk0=";

    dontNpmBuild = true;

    meta = {
      description = "Multi-agent swarm coordination for OpenCode with learning capabilities";
      homepage = "https://swarmtools.ai";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };
in {
  home.packages = [ swarmPlugin ];

  home.sessionVariables = {
    NODE_PATH = "${swarmPlugin}/lib/node_modules";
  };
}
