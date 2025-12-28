# PATH additions - only adds if directory exists
# Machine-specific paths go in local.zsh

# Homebrew
[ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:$PATH"

# Go
if [ -d "$HOME/go" ]; then
  export GOPATH="$HOME/go"
  export PATH="$PATH:$GOPATH/bin"
fi
[ -d "$GOROOT/bin" ] && export PATH="$PATH:$GOROOT/bin"
