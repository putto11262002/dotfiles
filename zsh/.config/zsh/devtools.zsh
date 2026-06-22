# Development tool paths and shell integrations

path_prepend() {
  [ -d "$1" ] || return
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

path_prepend "/opt/homebrew/bin"
path_prepend "/usr/local/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

export BUN_INSTALL="$HOME/.bun"
path_prepend "$BUN_INSTALL/bin"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

export PNPM_HOME="$HOME/Library/pnpm"
path_prepend "$PNPM_HOME"

path_prepend "$HOME/.local/bin"

# CCM: define shell functions so provider switches affect this shell.
unalias ccm 2>/dev/null || true
unset -f ccm 2>/dev/null || true
ccm() {
  local script="$HOME/.local/share/ccm/ccm.sh"
  if [[ ! -f "$script" ]]; then
    echo "ccm error: script not found at $script" >&2
    return 1
  fi

  case "$1" in
    ""|"help"|"-h"|"--help"|"status"|"st"|"config"|"cfg"|"save-account"|"switch-account"|"list-accounts"|"delete-account"|"current-account"|"debug-keychain"|"project")
      "$script" "$@"
      ;;
    *)
      eval "$("$script" "$@")"
      ;;
  esac
}

unalias ccc 2>/dev/null || true
unset -f ccc 2>/dev/null || true
ccc() {
  command ccc "$@"
}
