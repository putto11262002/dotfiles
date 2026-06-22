# ZSH Configuration
# Modular configs are in ~/.config/zsh/

ZSH_CONFIG="$HOME/.config/zsh"

# Source all tracked config modules. local.zsh is machine-specific and sourced once below.
for file in "$ZSH_CONFIG"/*.zsh; do
  [ "$(basename "$file")" = "local.zsh" ] && continue
  [ -r "$file" ] && source "$file"
done

# Source local config (machine-specific, gitignored)
[ -r "$ZSH_CONFIG/local.zsh" ] && source "$ZSH_CONFIG/local.zsh"
