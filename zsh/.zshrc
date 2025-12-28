# ZSH Configuration
# Modular configs are in ~/.config/zsh/

ZSH_CONFIG="$HOME/.config/zsh"

# Source all config modules
for file in "$ZSH_CONFIG"/*.zsh; do
  [ -r "$file" ] && source "$file"
done

# Source local config (machine-specific, gitignored)
[ -r "$ZSH_CONFIG/local.zsh" ] && source "$ZSH_CONFIG/local.zsh"
