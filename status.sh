#!/usr/bin/env bash
#
# status.sh - Show status of dotfiles packages and symlinks
#
# Usage:
#   ./status.sh           # Show all packages and their status
#   ./status.sh <package> # Show detailed status for one package
#

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Get list of stow packages
get_packages() {
    find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
        ! -name ".*" \
        -exec basename {} \; | sort
}

# Check if a package is stowed (has active symlinks)
is_stowed() {
    local package="$1"
    local pkg_dir="$DOTFILES_DIR/$package"

    # Find first file in package and check if corresponding symlink exists
    local first_file
    first_file=$(find "$pkg_dir" -type f | head -1)

    if [[ -z "$first_file" ]]; then
        return 1  # No files in package
    fi

    local relative_path="${first_file#$pkg_dir/}"
    local target_path="$HOME/$relative_path"

    # Check if target is a symlink OR if any parent directory is a symlink to dotfiles
    if [[ -L "$target_path" ]]; then
        return 0  # Is a symlink
    fi

    # Check if parent directories are symlinked (stow can symlink at directory level)
    local check_path="$HOME"
    for part in $(echo "$relative_path" | tr '/' ' '); do
        check_path="$check_path/$part"
        if [[ -L "$check_path" ]]; then
            # Verify it points to our dotfiles
            local link_target
            link_target=$(readlink "$check_path")
            if [[ "$link_target" == *"dotfiles/$package"* ]] || [[ "$link_target" == *"../"*"$package"* ]]; then
                return 0
            fi
        fi
    done

    return 1
}

# Count files in a package
count_files() {
    local package="$1"
    find "$DOTFILES_DIR/$package" -type f | wc -l | tr -d ' '
}

# Check for broken symlinks in HOME pointing to dotfiles
find_broken_links() {
    local package="$1"
    local pkg_dir="$DOTFILES_DIR/$package"
    local broken=()

    while IFS= read -r file; do
        local relative_path="${file#$pkg_dir/}"
        local target_path="$HOME/$relative_path"

        if [[ -L "$target_path" ]] && [[ ! -e "$target_path" ]]; then
            broken+=("$target_path")
        fi
    done < <(find "$pkg_dir" -type f)

    printf '%s\n' "${broken[@]}"
}

# Check for conflicts (non-symlink files that would conflict with stow)
find_conflicts() {
    local package="$1"
    local pkg_dir="$DOTFILES_DIR/$package"
    local conflicts=()

    while IFS= read -r file; do
        local relative_path="${file#$pkg_dir/}"
        local target_path="$HOME/$relative_path"

        if [[ -e "$target_path" ]] && [[ ! -L "$target_path" ]]; then
            conflicts+=("$target_path")
        fi
    done < <(find "$pkg_dir" -type f)

    printf '%s\n' "${conflicts[@]}"
}

# Show summary for all packages
show_summary() {
    echo ""
    echo "================================"
    echo "  Dotfiles Status"
    echo "================================"
    echo ""

    local packages
    packages=$(get_packages)

    if [[ -z "$packages" ]]; then
        warn "No packages found in $DOTFILES_DIR"
        return
    fi

    printf "%-20s %-10s %-10s\n" "PACKAGE" "STATUS" "FILES"
    printf "%-20s %-10s %-10s\n" "-------" "------" "-----"

    for pkg in $packages; do
        local status file_count
        file_count=$(count_files "$pkg")

        if is_stowed "$pkg"; then
            status="${GREEN}stowed${NC}"
        else
            status="${YELLOW}not stowed${NC}"
        fi

        printf "%-20s %-22b %-10s\n" "$pkg" "$status" "$file_count"
    done

    echo ""

    # Git status summary
    cd "$DOTFILES_DIR"
    local dirty_count
    dirty_count=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$dirty_count" -gt 0 ]]; then
        warn "Uncommitted changes: $dirty_count file(s)"
        echo "  Run 'git status' for details"
    else
        success "Working tree clean"
    fi

    # Check if behind/ahead of remote
    git fetch --quiet 2>/dev/null || true
    local behind ahead
    behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")

    if [[ "$behind" -gt 0 ]]; then
        warn "Behind remote by $behind commit(s). Run './sync.sh'"
    fi
    if [[ "$ahead" -gt 0 ]]; then
        info "Ahead of remote by $ahead commit(s). Run 'git push'"
    fi

    echo ""
}

# Show detailed status for one package
show_package_detail() {
    local package="$1"
    local pkg_dir="$DOTFILES_DIR/$package"

    if [[ ! -d "$pkg_dir" ]]; then
        error "Package not found: $package"
        exit 1
    fi

    echo ""
    echo "================================"
    echo "  Package: $package"
    echo "================================"
    echo ""

    # Basic info
    local file_count
    file_count=$(count_files "$package")
    info "Files: $file_count"

    if is_stowed "$package"; then
        success "Status: stowed"
    else
        warn "Status: not stowed"
    fi

    echo ""

    # List symlinks
    echo -e "${CYAN}Symlinks:${NC}"
    while IFS= read -r file; do
        local relative_path="${file#$pkg_dir/}"
        local target_path="$HOME/$relative_path"

        if [[ -L "$target_path" ]]; then
            echo -e "  ${GREEN}✓${NC} ~/$relative_path"
        elif [[ -e "$target_path" ]]; then
            # Check if accessible via a parent symlink (directory-level stow)
            local is_via_symlink=false
            local check_path="$HOME"
            for part in $(echo "$relative_path" | tr '/' ' '); do
                check_path="$check_path/$part"
                if [[ -L "$check_path" ]]; then
                    is_via_symlink=true
                    break
                fi
            done
            if [[ "$is_via_symlink" == "true" ]]; then
                echo -e "  ${GREEN}✓${NC} ~/$relative_path"
            else
                echo -e "  ${RED}✗${NC} ~/$relative_path (conflict: real file exists)"
            fi
        else
            echo -e "  ${YELLOW}○${NC} ~/$relative_path (not linked)"
        fi
    done < <(find "$pkg_dir" -type f | head -20)

    local total_files
    total_files=$(find "$pkg_dir" -type f | wc -l | tr -d ' ')
    if [[ "$total_files" -gt 20 ]]; then
        echo "  ... and $((total_files - 20)) more files"
    fi

    echo ""

    # Check for broken links
    local broken
    broken=$(find_broken_links "$package")
    if [[ -n "$broken" ]]; then
        echo -e "${RED}Broken symlinks:${NC}"
        echo "$broken" | while read -r link; do
            echo "  $link"
        done
        echo ""
    fi
}

# Main
main() {
    if [[ $# -gt 0 ]]; then
        case "$1" in
            --help|-h)
                echo "Usage: ./status.sh [package]"
                echo ""
                echo "Show status of dotfiles packages and symlinks."
                echo ""
                echo "Arguments:"
                echo "  package   Show detailed status for a specific package"
                echo ""
                echo "Examples:"
                echo "  ./status.sh        # Show summary of all packages"
                echo "  ./status.sh nvim   # Show detailed status for nvim"
                exit 0
                ;;
            *)
                show_package_detail "$1"
                ;;
        esac
    else
        show_summary
    fi
}

main "$@"
