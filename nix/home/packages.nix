{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # === Languages & Runtimes ===
    # Node.js (replaces nvm)
    nodejs_22
    nodePackages.npm
    nodePackages.pnpm
    bun

    # Go
    go

    # Rust (rustup manages toolchains)
    rustup

    # Python
    python312
    python312Packages.pip

    # Java
    temurin-bin-21

    # Elixir (optional, add if you use it)
    # elixir

    # === CLI Tools ===
    # Core utilities
    coreutils
    findutils
    gnused
    gawk

    # Search & Navigation
    ripgrep
    fd
    fzf
    eza        # Modern ls
    bat        # Better cat
    zoxide     # Smart cd

    # Git & GitHub
    gh
    lazygit
    delta      # Better git diff

    # File & Text Processing
    jq
    yq-go
    tree
    httpie

    # Development Tools
    gnumake
    cmake
    pkg-config

    # Container & Cloud
    # docker is installed via Homebrew cask
    docker-compose
    kubectl
    kubectx
    terraform
    awscli2

    # Database Tools
    postgresql_16
    # mysql-client  # Uncomment if needed

    # Network Tools
    curl
    wget
    htop
    btop

    # === LSP & Formatters (for Neovim) ===
    # TypeScript/JavaScript
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint

    # Lua
    lua-language-server
    stylua

    # Go
    gopls
    golangci-lint
    gotools

    # Python
    pyright
    black
    ruff

    # Rust
    rust-analyzer

    # Nix
    nil
    nixfmt-rfc-style

    # General
    nodePackages.yaml-language-server
    nodePackages.vscode-json-languageserver

    # === Other Tools ===
    ollama
    ffmpeg
    imagemagick
  ];
}
