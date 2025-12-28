# PATH additions - only adds if directory exists

# Homebrew
[ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:$PATH"

# Go
if [ -d "$HOME/go" ]; then
  export GOPATH="$HOME/go"
  export PATH="$PATH:$GOPATH/bin"
fi
[ -d "$GOROOT/bin" ] && export PATH="$PATH:$GOROOT/bin"

# LM Studio CLI
[ -d "$HOME/.lmstudio/bin" ] && export PATH="$PATH:$HOME/.lmstudio/bin"

# Bun
[ -d "$HOME/.bun/bin" ] && export PATH="$PATH:$HOME/.bun/bin"
