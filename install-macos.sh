#!/usr/bin/env bash
#
# install-macos.sh - Install this dotfiles repo on macOS.
#
# Usage:
#   ./install-macos.sh
#

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: this installer is only for macOS"
  exit 1
fi

if ! command -v brew &>/dev/null; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  elif [[ -x /usr/local/bin/brew ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi
fi

if ! command -v brew &>/dev/null; then
  echo "Error: Homebrew is not installed"
  echo "Install it from https://brew.sh, then rerun this script"
  exit 1
fi

echo "Installing Homebrew dependencies..."
brew bundle install --no-upgrade --file "$DOTFILES_DIR/Brewfile"

backup_if_conflict() {
  local rel="$1"
  local target="$HOME/$rel"

  if [[ ! -e "$target" && ! -L "$target" ]]; then
    return
  fi

  if [[ -L "$target" ]]; then
    local link
    link="$(readlink "$target")"
    case "$link" in
      *dotfiles*) return ;;
    esac
  fi

  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  echo "Backing up $target -> $BACKUP_DIR/$rel"
  mv "$target" "$BACKUP_DIR/$rel"
}

backup_if_conflict ".aerospace.toml"
backup_if_conflict ".config/kitty"
backup_if_conflict ".config/nvim"
backup_if_conflict ".config/zsh"
backup_if_conflict ".tmux.conf"
backup_if_conflict ".zshrc"

echo "Stowing dotfiles..."
"$DOTFILES_DIR/bootstrap.sh"

if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
  echo "Installing tmux plugins..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

if command -v nvim &>/dev/null; then
  echo "Syncing Neovim plugins..."
  nvim --headless '+Lazy! sync' +qa || echo "Warning: Neovim plugin sync failed; open nvim and run :Lazy sync"
fi

echo "Done"
if [[ -d "$BACKUP_DIR" ]]; then
  echo "Backups were written to $BACKUP_DIR"
fi
