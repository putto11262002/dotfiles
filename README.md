# Dotfiles

macOS configuration managed with [Nix](https://nixos.org/), [nix-darwin](https://github.com/LnL7/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager).

## What's Included

### System (nix-darwin)
- macOS system settings (dock, finder, keyboard, trackpad)
- Homebrew casks (GUI apps)
- Fonts (Nerd Fonts)
- Touch ID for sudo

### User (home-manager)
- **Shell**: Zsh with Oh My Zsh, syntax highlighting, autosuggestions
- **Editor**: Neovim with kickstart-based config
- **Terminal**: tmux with Nord theme
- **Git**: Delta for diffs, lazygit
- **Dev Tools**: Node.js, Go, Rust, Python, Bun, pnpm
- **CLI**: ripgrep, fzf, eza, bat, zoxide
- **Window Manager**: Aerospace

## Structure

```
dotfiles/
├── flake.nix              # Entry point
├── flake.lock             # Locked versions
├── config/                # App configs (symlinked by Nix)
│   ├── nvim/              # Neovim config
│   └── aerospace.toml     # Aerospace config
└── nix/
    ├── darwin/            # macOS system config
    │   └── default.nix
    └── home/              # User config (home-manager)
        ├── default.nix
        ├── packages.nix   # Dev tools & CLI
        ├── shell.nix      # Zsh config
        ├── git.nix        # Git config
        ├── tmux.nix       # tmux config
        └── neovim.nix     # Neovim setup
```

## Setup on a New Mac

### 1. Install Nix
```bash
curl -L https://nixos.org/nix/install | sh
```

### 2. Enable Flakes
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 3. Clone Dotfiles
```bash
git clone https://github.com/putto11262002/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 4. Build & Apply
```bash
# First time: bootstrap nix-darwin
nix run nix-darwin -- switch --flake .

# After that, use:
darwin-rebuild switch --flake .
```

## Day-to-Day Usage

### Apply Changes
```bash
# After editing any nix files:
darwin-rebuild switch --flake ~/dotfiles

# Or use the alias:
rebuild
```

### Update Packages
```bash
# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update ~/dotfiles

# Or use the alias:
update

# Then rebuild
rebuild
```

### Add a Package
Edit `nix/home/packages.nix`:
```nix
home.packages = with pkgs; [
  # ... existing packages
  newpackage    # Add your package
];
```
Then run `rebuild`.

### Add a Homebrew Cask (GUI App)
Edit `nix/darwin/default.nix`:
```nix
homebrew.casks = [
  # ... existing casks
  "new-app"    # Add your app
];
```
Then run `rebuild`.

### Clean Up Old Generations
```bash
# Remove old generations (saves disk space)
nix-collect-garbage -d

# Or use the alias:
cleanup
```

## Customization

### Machine-Specific Config
To support multiple machines, create host-specific configs in `nix/hosts/`:

```nix
# nix/hosts/work-macbook.nix
{ ... }: {
  # Override settings for work machine
  homebrew.casks = [
    "slack"
    "zoom"
  ];
}
```

Then update `flake.nix` to include a new darwinConfiguration.

### Per-Project Environments
Use `direnv` with `.envrc` files:

```bash
# In a project directory:
echo "use flake" > .envrc
direnv allow
```

Create a `flake.nix` in the project for project-specific dependencies.

## Aliases

| Alias | Command |
|-------|---------|
| `rebuild` | `darwin-rebuild switch --flake ~/dotfiles` |
| `update` | `nix flake update ~/dotfiles` |
| `cleanup` | `nix-collect-garbage -d` |
| `v` / `vim` | `nvim` |
| `ll` | `eza -la --icons --git` |
| `cat` | `bat` |
| `cd` | `z` (zoxide) |
| `g` | `git` |
| `k` | `kubectl` |
| `dc` | `docker-compose` |

## Troubleshooting

### "experimental-features" Error
Make sure flakes are enabled:
```bash
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Homebrew Not Found
Install Homebrew first (nix-darwin manages it but doesn't install it):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Symlink Conflicts
If you have existing configs that conflict:
```bash
# Back up and remove the conflicting file
mv ~/.config/nvim ~/.config/nvim.bak
rebuild
```
