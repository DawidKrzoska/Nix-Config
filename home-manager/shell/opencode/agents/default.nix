{ config, lib, pkgs, inputs, ... }:
let
  entries = builtins.readDir ./.;
  agentFiles = builtins.filter
    (name:
      entries.${name} == "regular"
      && name != "default.nix"
      && lib.hasSuffix ".nix" name)
    (builtins.attrNames entries);
  agentConfigs = map
    (name: import (./. + "/${name}") { inherit config lib pkgs inputs; })
    agentFiles;
in {
  agent = builtins.foldl' (acc: cfg: acc // cfg) { } agentConfigs;
}
