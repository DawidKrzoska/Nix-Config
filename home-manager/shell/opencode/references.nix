{ config, lib, pkgs, inputs, ... }: {
  references = {
    nixos = {
      path = "~/wolfar-nix-config/nixos";
      description = "NixOS system-level configuration modules";
    };
    hm = {
      path = "~/wolfar-nix-config/home-manager";
      description = "Home Manager user-level configuration modules";
    };
    nixvim = {
      path = "~/wolfar-nix-config/home-manager/nixvim";
      description = "NixVim configurations for Neovim";
    };
    desktop = {
      path = "~/wolfar-nix-config/home-manager/desktop";
      description = "Desktop environment (Hyprland, Waybar, wofi, theme, services)";
    };
    opencode = {
      path = "~/wolfar-nix-config/home-manager/shell";
      description = "OpenCode configuration source (opencode.nix + skills, plugins, commands)";
    };
    tuo-studio = {
      path = "/home/wolfar/TuoStudio";
      description = "TUO Sports Club Booking Platform — React/TypeScript/Tailwind + Supabase";
    };
    tuo-docs = {
      path = "/home/wolfar/TuoStudio/docs";
      description = "PRD, database schema, RPC docs, deployment checklists for TuoStudio";
    };
  };
}
