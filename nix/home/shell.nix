{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History settings
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    # Oh My Zsh
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
        "kubectl"
      ];
    };

    # Shell aliases
    shellAliases = {
      # Navigation
      ll = "eza -la --icons --git";
      ls = "eza --icons";
      la = "eza -a --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      cd = "z";

      # Git
      g = "git";
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      gco = "git checkout";
      gcm = "git commit -m";
      gaa = "git add --all";
      glog = "git log --oneline --graph";

      # Editor
      vim = "nvim";
      v = "nvim";

      # Docker
      dc = "docker-compose";
      dps = "docker ps";

      # Kubernetes
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get svc";

      # System
      reload = "source ~/.zshrc";
      cleanup = "nix-collect-garbage -d";

      # Nix
      rebuild = "darwin-rebuild switch --flake ~/dotfiles";
      update = "nix flake update ~/dotfiles";

      # Apps
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };

    # Extra init (runs after oh-my-zsh)
    initExtra = ''
      # Vi mode
      bindkey -v
      bindkey ^R history-incremental-search-backward
      bindkey ^S history-incremental-search-forward

      # Better vi mode
      export KEYTIMEOUT=1

      # Initialize zoxide (smart cd)
      eval "$(zoxide init zsh)"

      # FZF configuration
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

      # Rustup (managed by Nix, but toolchains are user-local)
      [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

      # CCM: Claude Code Model switcher
      ccm() {
        local script="''${XDG_DATA_HOME:-$HOME/.local/share}/ccm/ccm.sh"
        if [[ ! -f "$script" ]]; then
          local default1="''${XDG_DATA_HOME:-$HOME/.local/share}/ccm/ccm.sh"
          local default2="$HOME/.ccm/ccm.sh"
          if [[ -f "$default1" ]]; then
            script="$default1"
          elif [[ -f "$default2" ]]; then
            script="$default2"
          fi
        fi
        if [[ ! -f "$script" ]]; then
          echo "ccm error: script not found at $script" >&2
          return 1
        fi

        case "$1" in
          ""|"help"|"-h"|"--help"|"status"|"st"|"config"|"cfg")
            "$script" "$@"
            ;;
          *)
            eval "$("$script" "$@")"
            ;;
        esac
      }

      # CCC: Claude Code Commander - switch model and launch Claude Code
      ccc() {
        if [[ $# -eq 0 ]]; then
          echo "Usage: ccc <model> [claude-options]"
          echo ""
          echo "Examples:"
          echo "  ccc deepseek                              # Launch with DeepSeek"
          echo "  ccc pp deepseek                           # Launch with PPINFRA DeepSeek"
          echo "  ccc glm --dangerously-skip-permissions    # Launch GLM with options"
          echo ""
          echo "Available models:"
          echo "  Official: deepseek, glm, kimi, qwen, claude, opus, longcat"
          echo "  PPINFRA:  pp deepseek, pp glm, pp kimi, pp qwen"
          return 1
        fi

        local use_pp=false
        local model=""
        local claude_args=()

        if [[ "$1" == "pp" ]]; then
          use_pp=true
          shift
          model="$1"
          shift
        else
          model="$1"
          shift
        fi

        claude_args=("$@")

        if $use_pp; then
          echo "Switching to PPINFRA $model..."
          ccm pp "$model" || return 1
        else
          echo "Switching to $model..."
          ccm "$model" || return 1
        fi

        echo ""
        echo "Launching Claude Code..."
        echo "   Model: $ANTHROPIC_MODEL"
        echo "   Base URL: ''${ANTHROPIC_BASE_URL:-Default (Anthropic)}"
        echo ""

        if [[ ''${#claude_args[@]} -eq 0 ]]; then
          exec claude
        else
          exec claude "''${claude_args[@]}"
        fi
      }
    '';

    # Environment variables (set early in zsh init)
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # Starship prompt (optional, can use instead of oh-my-zsh theme)
  # programs.starship = {
  #   enable = true;
  #   settings = { };
  # };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Direnv for per-project environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Zoxide (smart cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
      style = "numbers,changes,header";
    };
  };

  # Eza (better ls)
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };
}
