# macOS CLI bootstrap

Target: Apple Silicon Mac (`aarch64-darwin`), local macOS user `dawid`.

This profile intentionally uses standalone Home Manager rather than nix-darwin. It does not manage macOS system defaults, Finder, the Dock, system services, gaming, or the Linux desktop configuration. Kitty is the only GUI application managed by the profile and is copied under `~/Applications/Nix Apps`.

## 1. Install Nix

Install Nix with flakes enabled using your preferred trusted Nix installer. Nix itself is machine-level infrastructure on macOS (`/nix` and the Nix daemon), while the Home Manager configuration below is scoped to user `dawid`.

Verify:

```sh
nix --version
nix flake --help >/dev/null
```

## 2. Clone the configuration

Before GitHub SSH is configured, clone over HTTPS:

```sh
cd ~
git clone https://github.com/DawidKrzoska/Nix-Config.git wolfar-nix-config
cd ~/wolfar-nix-config
git switch agent/add-darwin-cli-profile
```

## 3. Activate Home Manager

Bootstrap and activate the standalone Home Manager profile:

```sh
nix run github:nix-community/home-manager/release-26.05 -- \
  switch --flake ~/wolfar-nix-config#dawid@macbook
```

After the first activation, `home-manager` is installed in the user profile, so later updates are simply:

```sh
cd ~/wolfar-nix-config
home-manager switch --flake .#dawid@macbook
```

Log out and back in, or start a fresh Kitty session, before judging PATH or shell integration.

## 4. Generate a Mac-specific SSH key

Do not copy the Linux private key to this machine. Generate a separate Ed25519 key:

```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "dawid-macbook" -f ~/.ssh/id_ed25519_github
```

Add a host entry:

```sh
cat >> ~/.ssh/config <<'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
EOF
chmod 600 ~/.ssh/config
```

Load it into the macOS agent/keychain:

```sh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
```

Print the public key and add it to the GitHub account:

```sh
cat ~/.ssh/id_ed25519_github.pub
```

Then verify:

```sh
ssh -T git@github.com
```

Once SSH works, convert the Nix config remote:

```sh
cd ~/wolfar-nix-config
git remote set-url origin git@github.com:DawidKrzoska/Nix-Config.git
```

## 5. Authenticate GitHub CLI

```sh
gh auth login
```

Use the same GitHub account, but keep this Mac's SSH key separate from the Linux machine.

## 6. Clone and enter TuoStudio

```sh
cd ~
git clone git@github.com:DawidKrzoska/TuoStudio.git
cd ~/TuoStudio
nix develop
```

TuoStudio's own flake remains authoritative for project dependencies such as its exact Node version, pnpm, TypeScript tooling, Supabase CLI, Playwright tooling, jq, and OpenSSL. The Home Manager profile supplies the general workstation tools.

## 7. Expected workstation commands

Outside a project dev shell, the Mac profile provides at least:

```text
zsh
starship
kitty
tmux
nvim
git
gh
node / npm
pnpm
ripgrep (rg)
fd
wget
unzip
htop
python3
codex
opencode
```

## Isolation boundary

The `dawid` macOS account keeps Home Manager dotfiles, Git credentials, SSH keys, project checkouts and app links separate from the other user's home directory. Nix itself is not a per-user sandbox: `/nix` and its daemon are shared machine infrastructure.
