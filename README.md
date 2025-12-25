# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## How it works

- The repo contains **packages** (top-level directories like `nvim/`, `zsh/`)
- Each package mirrors the directory structure relative to `$HOME`
- Stow creates symlinks from `$HOME` pointing into this repo

Example:
```
dotfiles/nvim/.config/nvim/init.lua
       ↓ stow
~/.config/nvim/init.lua -> ~/dotfiles/nvim/.config/nvim/init.lua
```

## Prerequisites

Install these manually before using:

- `git`
- `stow` (GNU Stow)

```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow
```

## Structure

```
dotfiles/
  nvim/                 # package
    .config/
      nvim/
        init.lua
        lua/
          ...
  zsh/                  # package
    .zshrc
  bootstrap.sh
  sync.sh
  add.sh
  status.sh
  .gitignore
```

Each top-level directory is a "package". Files inside mirror their location relative to `$HOME`.

## Scripts

Simple helper scripts. They fail fast with a message if something is wrong.

| Script | What it does |
|--------|--------------|
| `./bootstrap.sh` | Stow all packages (requires stow installed) |
| `./sync.sh` | Pull and restow (requires clean working tree) |
| `./add.sh <pkg> <path>` | Add a config to a package |
| `./status.sh` | List packages and their stow status |

## Setup on a new machine

1. Install prerequisites (git, stow)
2. Clone and bootstrap:

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

If stow reports conflicts, see [Handling conflicts](#handling-conflicts).

## Adding a new config

Use the helper script:

```bash
./add.sh zsh ~/.zshrc
./add.sh alacritty ~/.config/alacritty
```

Or manually:

1. Create package structure:
   ```bash
   mkdir -p ~/dotfiles/zsh
   ```

2. Copy config into package (preserving path relative to $HOME):
   ```bash
   cp ~/.zshrc ~/dotfiles/zsh/.zshrc
   ```

3. Remove original:
   ```bash
   rm ~/.zshrc
   ```

4. Stow:
   ```bash
   cd ~/dotfiles
   stow -t "$HOME" zsh
   ```

5. Update `.gitignore` if the config generates cache/temp files:
   ```bash
   git status  # check for junk files
   # edit .gitignore as needed
   ```

6. Commit:
   ```bash
   git add -A
   git commit -m "feat: add zsh config"
   ```

## Syncing changes

On another machine (or after pushing changes from elsewhere):

```bash
cd ~/dotfiles
./sync.sh
```

This requires a clean working tree. If you have uncommitted changes:

```bash
git stash
./sync.sh
git stash pop
```

## Day-to-day edits

Edit configs through the symlinked path (e.g. `~/.config/nvim/init.lua`) or directly in the repo. Changes go to the repo either way.

```bash
cd ~/dotfiles
git add -A
git commit -m "feat: update nvim keymaps"
git push
```

## Handling conflicts

If stow refuses with "conflict", a real file exists at the target path.

```bash
# Back up the existing file
mv ~/.zshrc ~/.zshrc.bak

# Stow
cd ~/dotfiles
stow -t "$HOME" zsh

# Compare and merge if needed, then remove backup
diff ~/.zshrc.bak ~/.zshrc
rm ~/.zshrc.bak
```

## Removing a package

Unstow removes symlinks (does not delete repo files):

```bash
cd ~/dotfiles
stow -D -t "$HOME" nvim
```

## Manual stow commands

```bash
stow -t "$HOME" <package>       # link (install)
stow -D -t "$HOME" <package>    # unlink (uninstall)
stow -R -t "$HOME" <package>    # restow (unlink + link)
stow -n -v -t "$HOME" <package> # dry run (preview)
```

## Machine-specific configs and secrets

**Never commit secrets** (API keys, tokens, private keys).

Options:
- Use `*.local` files that are gitignored (e.g. `.zshrc` sources `.zshrc.local`)
- Keep a `local/` package that is gitignored and only exists on that machine

## Updating .gitignore

Many tools generate cache/temp files inside config directories. When adding a new config:

1. Run `git status` to spot generated files
2. Add patterns to `.gitignore`:
   ```gitignore
   # Neovim
   nvim/.config/nvim/spell/
   nvim/.config/nvim/.luarc.json
   nvim/.config/nvim/plugin/
   ```
3. Only track files you intentionally configured
