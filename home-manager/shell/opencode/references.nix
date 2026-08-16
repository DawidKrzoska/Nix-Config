{ config, lib, pkgs, inputs, ... }: {
  references = {
    nixos = {
      path = "${config.wolfar.paths.nixConfig}/nixos";
      description = "NixOS system-level configuration modules";
    };
    hm = {
      path = "${config.wolfar.paths.nixConfig}/home-manager";
      description = "Home Manager user-level configuration modules";
    };
    nixvim = {
      path = "${config.wolfar.paths.nixConfig}/home-manager/nixvim";
      description = "NixVim configurations for Neovim";
    };
    desktop = {
      path = "${config.wolfar.paths.nixConfig}/home-manager/desktop";
      description = "Desktop environment (Hyprland, Waybar, wofi, theme, services)";
    };
    opencode = {
      path = "${config.wolfar.paths.nixConfig}/home-manager/shell";
      description = "OpenCode configuration source (opencode.nix + skills, plugins, commands)";
    };
    tuo-studio = {
      path = config.wolfar.paths.tuoStudio;
      description = "TUO Sports Club Booking Platform — React/TypeScript/Tailwind + Supabase";
    };
    tuo-docs = {
      path = "${config.wolfar.paths.tuoStudio}/docs";
      description = "PRD, database schema, RPC docs, deployment checklists for TuoStudio";
    };
  };
}
