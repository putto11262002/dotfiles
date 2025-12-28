# Oh My Zsh configuration

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="af-magic"

plugins=(
  git
  zsh-autosuggestions
)

# Only source oh-my-zsh if installed
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
