# Dotfiles

This repo stores my personal configuration files (“dotfiles”) in one place and installs them into their expected locations using symlinks managed by **GNU Stow**. The goal is a repeatable setup across machines without manually copying files around.

This repo is intentionally app-agnostic. Any config (shell, editor, terminal, window manager, etc.) can live here as long as it follows the same layout rules.

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

Top-level directories are Stow packages:

```text
dotfiles/
  <package-1>/
    (paths relative to $HOME)
  <package-2>/
    (paths relative to $HOME)
  bootstrap.sh        (optional helper)
  .gitignore
  README.md
````

Inside each package, put files exactly where they should appear under `$HOME`. Common examples:

* `.<something>` files in home (e.g. `~/.toolrc`)
* `~/.config/<app>/...` configs

## Prerequisites

* `git`
* `stow` (GNU Stow)

Install examples:

* macOS (Homebrew): `brew install stow git`
* Debian/Ubuntu: `sudo apt install -y stow git`

## Bootstrap on a new machine

1. Clone the repo

```bash
git clone <your-remote-repo> ~/dotfiles
cd ~/dotfiles
```

2. Install `stow` (see prerequisites)

3. Stow the packages you want

```bash
stow -t "$HOME" <package-1> <package-2>
```

4. Verify symlinks

```bash
ls -la ~/.config
# or inspect a specific file:
ls -la ~/.config/example-app/config.toml
```

## Common chores (How-to)

### Add a new config file or directory to the system

Rule: **copy into repo → update `.gitignore` → remove original → stow**.

Why update `.gitignore`:

* Many tools generate caches, lockfiles, backups, session files, or plugin downloads inside config directories.
* If you add a new config and suddenly see lots of generated files in `git status`, update `.gitignore` immediately so the repo only tracks what you intend.

1. Create/mirror directories under the right package:

```bash
mkdir -p ~/dotfiles/<package>/.config/example-app
```

2. Copy your existing config into the repo:

```bash
cp -a ~/.config/example-app ~/dotfiles/<package>/.config/
```

3. Update `.gitignore` to exclude generated files for this new config (as needed):

```bash
# edit ~/dotfiles/.gitignore
git status   # use this to spot junk you should ignore
```

4. Remove the original (only after confirming the copy is correct):

```bash
rm -rf ~/.config/example-app
```

5. Restow the package:

```bash
cd ~/dotfiles
stow -t "$HOME" <package>
```

6. Verify:

```bash
ls -la ~/.config/example-app
```

### Update configs (day-to-day edits)

Edit the file through the *linked* path as usual (e.g. `~/.config/...`), or edit inside the repo. Because the target is a symlink, changes go into the repo either way.

Important: if your edits introduce new generated files showing up in `git status`, update `.gitignore` so you do not accidentally commit caches/secrets/junk.

Typical workflow:

```bash
cd ~/dotfiles
git status
# (update .gitignore if needed)
git add -A
git commit -m "Update configs"
git push
```

### Add a brand new package

1. Create the package and put files under `$HOME`-relative paths:

```bash
mkdir -p ~/dotfiles/<new-package>/.config/example-app
```

2. Add config files:

```bash
cp -a ~/.config/example-app ~/dotfiles/<new-package>/.config/
```

3. Update `.gitignore` for generated files (as needed):

```bash
git status
# edit ~/dotfiles/.gitignore
```

4. Remove the original and stow it:

```bash
rm -rf ~/.config/example-app
cd ~/dotfiles
stow -t "$HOME" <new-package>
```

### Remove/uninstall a package’s symlinks

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

## Notes

* Stow creates symlinks relative to the package contents; keep paths clean and predictable.
* Keep generated files/caches out of the repo via `.gitignore`.
* Use small packages to make it easy to stow only what you want per machine.

## Quick reference

```bash
# Install (link) packages
stow -t "$HOME" <package...>

# Remove (unlink) packages
stow -D -t "$HOME" <package...>

# Dry run + verbose
stow -n -v -t "$HOME" <package>
```
