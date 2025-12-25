#!/usr/bin/env bash
#
# bootstrap.sh - Set up dotfiles on a new machine
#
# Usage:
#   curl -fsSL <raw-url>/bootstrap.sh | bash
#   OR
#   git clone <repo> ~/dotfiles && cd ~/dotfiles && ./bootstrap.sh
#

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
REPO_URL="${DOTFILES_REPO:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

# Check if command exists
has_cmd() {
    command -v "$1" &>/dev/null
}

# Install prerequisites
install_prerequisites() {
    local os
    os=$(detect_os)

    info "Detected OS: $os"

    # Install git if missing
    if ! has_cmd git; then
        info "Installing git..."
        case "$os" in
            macos)
                xcode-select --install 2>/dev/null || true
                ;;
            linux)
                if has_cmd apt; then
                    sudo apt update && sudo apt install -y git
                elif has_cmd dnf; then
                    sudo dnf install -y git
                elif has_cmd pacman; then
                    sudo pacman -S --noconfirm git
                else
                    error "Could not install git. Please install manually."
                    exit 1
                fi
                ;;
            *)
                error "Unsupported OS. Please install git manually."
                exit 1
                ;;
        esac
        success "git installed"
    else
        success "git already installed"
    fi

    # Install stow if missing
    if ! has_cmd stow; then
        info "Installing stow..."
        case "$os" in
            macos)
                if has_cmd brew; then
                    brew install stow
                else
                    info "Installing Homebrew first..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    brew install stow
                fi
                ;;
            linux)
                if has_cmd apt; then
                    sudo apt update && sudo apt install -y stow
                elif has_cmd dnf; then
                    sudo dnf install -y stow
                elif has_cmd pacman; then
                    sudo pacman -S --noconfirm stow
                else
                    error "Could not install stow. Please install manually."
                    exit 1
                fi
                ;;
            *)
                error "Unsupported OS. Please install stow manually."
                exit 1
                ;;
        esac
        success "stow installed"
    else
        success "stow already installed"
    fi
}

# Clone repo if not already in dotfiles directory
clone_repo() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        success "Dotfiles repo already exists at $DOTFILES_DIR"
        return
    fi

    if [[ -z "$REPO_URL" ]]; then
        error "DOTFILES_REPO not set and repo not found at $DOTFILES_DIR"
        error "Either clone the repo first or set DOTFILES_REPO=<url>"
        exit 1
    fi

    info "Cloning dotfiles repo..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    success "Cloned to $DOTFILES_DIR"
}

# Get list of stow packages (top-level directories, excluding hidden and scripts)
get_packages() {
    find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
        ! -name ".*" \
        -exec basename {} \; | sort
}

# Stow all packages
stow_packages() {
    local packages
    packages=$(get_packages)

    if [[ -z "$packages" ]]; then
        warn "No packages found to stow"
        return
    fi

    info "Stowing packages..."
    cd "$DOTFILES_DIR"

    for pkg in $packages; do
        info "  Stowing $pkg..."
        if stow -t "$HOME" "$pkg" 2>&1; then
            success "  $pkg stowed"
        else
            error "  Failed to stow $pkg (conflicts may exist)"
        fi
    done
}

# Main
main() {
    echo ""
    echo "================================"
    echo "  Dotfiles Bootstrap"
    echo "================================"
    echo ""

    install_prerequisites
    clone_repo
    stow_packages

    echo ""
    success "Bootstrap complete!"
    info "Run './status.sh' to verify symlinks"
    echo ""
}

main "$@"
