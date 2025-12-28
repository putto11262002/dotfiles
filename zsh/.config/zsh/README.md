# ZSH Configuration

Modular zsh configuration. The main `~/.zshrc` sources all `*.zsh` files from this directory.

## Structure

```
~/.config/zsh/
├── plugins.zsh      # Oh My Zsh, theme, plugins
├── path.zsh         # PATH additions (conditional)
├── aliases.zsh      # Shell aliases
├── keybindings.zsh  # Vi mode, search bindings
├── completions.zsh  # Tool completions (nvm, bun, etc)
├── local.zsh        # Machine-specific (gitignored)
└── install.sh       # Installs oh-my-zsh and plugins
```

## Setup on new machine

```bash
# 1. Run install script (installs oh-my-zsh and plugins)
~/.config/zsh/install.sh

# 2. (Optional) Create local config for machine-specific settings
cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh
```

## Adding new config

Create a new `.zsh` file in this directory. It will be automatically sourced.

```bash
# Example: add docker aliases
echo 'alias dps="docker ps"' > ~/.config/zsh/docker.zsh
```

## Load order

Files are sourced alphabetically, then `local.zsh` is sourced last.

To control order, prefix with numbers:
```
01-path.zsh
02-plugins.zsh
03-aliases.zsh
```

## Machine-specific settings

Use `local.zsh` for:
- Work vs personal machine differences
- API keys and secrets (never commit these)
- Paths that only exist on one machine

```bash
cp local.zsh.example local.zsh
# Edit local.zsh with your settings
```

## Adding a new plugin

1. Add to `plugins.zsh`:
   ```zsh
   plugins=(
     git
     zsh-autosuggestions
     your-new-plugin  # add here
   )
   ```

2. If it's a custom plugin, add install command to `install.sh`:
   ```bash
   git clone https://github.com/user/plugin "$ZSH_CUSTOM/plugins/plugin-name"
   ```

## Conditional loading

All PATH and tool configs use conditional checks so they don't break on machines where tools aren't installed:

```zsh
# Only add to PATH if directory exists
[ -d "$HOME/.bun/bin" ] && export PATH="$PATH:$HOME/.bun/bin"

# Only source if file exists
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
```
