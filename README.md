# Dotfiles

This repo stores my personal configuration files ("dotfiles") in one place and installs them into their expected locations using symlinks managed by **GNU Stow**. The goal is a repeatable setup across machines without manually copying files around.

This repo is intentionally app-agnostic. Any config (shell, editor, terminal, window manager, etc.) can live here as long as it follows the same layout rules.

## Quick Start

```bash
# New machine - run bootstrap
git clone <your-remote-repo> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh

# Check status
./status.sh

# Add a new config
./add.sh zsh ~/.zshrc

# Sync changes across machines
./sync.sh
```

## How it works

### Key idea
- The repo contains one or more **packages** (top-level folders).
- Each package mirrors the directory structure **relative to `$HOME`**.
- Running `stow -t "$HOME" <package>` creates symlinks in `$HOME` that point back into this repo.

Example mapping:
- Repo: `~/dotfiles/<package>/.config/example-app/config.toml`
- Link: `~/.config/example-app/config.toml -> ~/dotfiles/<package>/.config/example-app/config.toml`

### Why Stow
- Keeps the repo clean and organized by package.
- Creates symlinks safely (refuses to overwrite existing non-symlinks).
- Easy to add/remove groups of configs per machine.

## Repo structure

```text
dotfiles/
  nvim/                 # Package: neovim config
    .config/
      nvim/
        init.lua
        lua/
          ...
  <other-package>/      # More packages...
    ...
  bootstrap.sh          # Set up a new machine
  sync.sh               # Pull changes and restow
  add.sh                # Add a config to the repo
  status.sh             # Check package/symlink status
  .gitignore
  README.md
```

Inside each package, put files exactly where they should appear under `$HOME`. Common examples:

* `.<something>` files in home (e.g. `~/.zshrc` → `zsh/.zshrc`)
* `~/.config/<app>/...` configs (e.g. `~/.config/nvim/` → `nvim/.config/nvim/`)

## Scripts

### `bootstrap.sh` - New machine setup

Sets up dotfiles on a fresh machine. Installs prerequisites (git, stow) and stows all packages.

```bash
# If you already cloned the repo:
cd ~/dotfiles
./bootstrap.sh

# Or one-liner (set DOTFILES_REPO first):
DOTFILES_REPO=<url> curl -fsSL <raw-url>/bootstrap.sh | bash
```

What it does:
1. Detects OS (macOS/Linux)
2. Installs `git` and `stow` if missing
3. Clones the repo (if not already present)
4. Stows all packages

### `sync.sh` - Pull and restow

Syncs your dotfiles with the remote repo. Use this on any machine to get the latest changes.

```bash
./sync.sh           # Pull and restow all packages
./sync.sh --push    # Also push local commits after sync
```

What it does:
1. Stashes uncommitted changes (if any)
2. Pulls latest with rebase
3. Restores stash
4. Restows all packages (picks up new files/packages)

### `add.sh` - Add a config

Automates adding a new config file or directory to the repo.

```bash
./add.sh <package> <source-path>

# Examples:
./add.sh zsh ~/.zshrc              # Add .zshrc to 'zsh' package
./add.sh git ~/.gitconfig          # Add .gitconfig to 'git' package
./add.sh alacritty ~/.config/alacritty  # Add alacritty config
```

What it does:
1. Creates the package directory structure
2. Copies the config (excluding `.git/` if present)
3. Verifies the copy
4. Removes the original
5. Stows the package (creates symlink)
6. Shows files that might need `.gitignore` entries

### `status.sh` - Check status

Shows the status of all packages and their symlinks.

```bash
./status.sh           # Summary of all packages
./status.sh nvim      # Detailed status for one package
```

Shows:
- Which packages are stowed vs not stowed
- File counts per package
- Broken symlinks
- Conflicts (real files blocking stow)
- Git status (uncommitted changes, behind/ahead of remote)

## Manual Operations

### Update configs (day-to-day edits)

Edit the file through the *linked* path as usual (e.g. `~/.config/...`), or edit inside the repo. Because the target is a symlink, changes go into the repo either way.

```bash
cd ~/dotfiles
git status
# (update .gitignore if needed)
git add -A
git commit -m "feat: update nvim keymaps"
git push
```

### Remove/uninstall a package's symlinks

This removes symlinks created by Stow for that package (does not delete repo files):

```bash
cd ~/dotfiles
stow -D -t "$HOME" <package>
```

### Preview changes (dry run)

See what Stow would do without changing anything:

```bash
cd ~/dotfiles
stow -n -v -t "$HOME" <package>
```

### Handling conflicts (when Stow refuses)

If Stow reports a conflict, it usually means a real file/dir already exists at the target path.

Safe fix pattern:

1. Back it up:

```bash
mv ~/.config/example-app ~/.config/example-app.bak
```

2. Restow:

```bash
cd ~/dotfiles
stow -t "$HOME" <package>
```

3. Compare and merge changes from the backup if needed, then delete the backup.

## Machine-specific settings and secrets

Do not commit secrets (tokens, API keys, private keys). For machine-specific overrides:

* Prefer `*.local` files that are **ignored by git**.
* Or keep a `local/` package that is **gitignored** and only stowed on that machine.

## Prerequisites

* `git`
* `stow` (GNU Stow)

Install manually if needed:

* macOS (Homebrew): `brew install stow git`
* Debian/Ubuntu: `sudo apt install -y stow git`

(Or just run `./bootstrap.sh` which handles this automatically)

## Quick reference

```bash
# Scripts
./bootstrap.sh              # Set up new machine
./sync.sh                   # Pull and restow
./sync.sh --push            # Pull, restow, and push
./add.sh <pkg> <path>       # Add config to repo
./status.sh                 # Show all package status
./status.sh <pkg>           # Show detailed package status

# Manual stow commands
stow -t "$HOME" <package>           # Install (link) a package
stow -D -t "$HOME" <package>        # Remove (unlink) a package
stow -R -t "$HOME" <package>        # Restow (unlink + link)
stow -n -v -t "$HOME" <package>     # Dry run + verbose
```
