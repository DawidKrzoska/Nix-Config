# Agent Rules — wolfar-nix-config

This is a **declarative NixOS + Home Manager flake**. All system and user configuration lives only in this repository — nothing should be installed or configured outside of it.

## Golden rules

1. **All config is here** — never install packages imperatively (`nix profile install`, `nix-env -i`, `pip install`, `cargo install`, `npm install -g`, `go install`, etc.). Every package, service, and dotfile must be added via `.nix` files in this repo.

2. **No manual `.config` edits** — Home Manager manages dotfiles declaratively. Do not edit `~/.config/`, `~/.local/`, `~/.themes/`, or any other user config directory by hand. All such configuration belongs in `home-manager/` modules.

3. **System changes** → edit files under `nixos/`. **Always ask me before running `sudo nixos-rebuild switch --flake .#nixos`**.

4. **User/home changes** → edit files under `home-manager/`. You may run `home-manager switch --flake .#wolfar@nixos` directly without asking.

5. **Theme tokens** are in `home-manager/modules/theme.nix` — import and reference them rather than duplicating values.

6. **Updating inputs** → use `nix flake update` to bump flake inputs.

7. **Validate before system apply** — run `nix build .#nixosConfigurations.nixos.config.system.build.toplevel` or a dry-run first to check for errors before asking me for system rebuild approval.

## Applying changes

| Scope | Command | Ask first? |
|-------|---------|------------|
| System | `sudo nixos-rebuild switch --flake .#nixos` | **Yes** — always notify me |
| User | `home-manager switch --flake .#wolfar@nixos` | No — safe to run directly |
