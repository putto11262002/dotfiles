{ pkgs, ... }:

{
  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    # Optimize storage (new option name)
    optimise.automatic = true;
    # Garbage collection
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Primary user (required for user-specific settings)
  system.primaryUser = "putsuthisrisinlpa";

  # System packages (available to all users)
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # Homebrew - for GUI apps that Nix can't handle well
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Remove unlisted casks/formulae
      upgrade = true;
    };

    # CLI tools that work better via Homebrew
    brews = [
      # Add any brew-specific tools here if needed
    ];

    # GUI Applications
    casks = [
      # Browsers
      "arc"
      "vivaldi"

      # Development
      "visual-studio-code"
      "docker"
      "postman"
      "tableplus"

      # Terminal
      "iterm2"
      "warp"

      # Productivity
      "raycast"
      "notion"
      "obsidian"

      # Window Management
      "aerospace"

      # Communication
      "slack"
      "discord"
      "zoom"

      # Utilities
      "tailscale"
      "1password"
      "appcleaner"

      # Media
      "spotify"
    ];

    # Mac App Store apps (requires `mas` CLI)
    masApps = {
      # "App Name" = app_id;
      # Example: "Xcode" = 497799835;
    };
  };

  # macOS system settings
  system = {
    defaults = {
      # Dock
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.4;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
        # Don't rearrange spaces based on recent use
        mru-spaces = false;
      };

      # Finder
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXDefaultSearchScope = "SCcf"; # Search current folder
        FXPreferredViewStyle = "Nlsv"; # List view
      };

      # Global
      NSGlobalDomain = {
        # Keyboard
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        ApplePressAndHoldEnabled = false;

        # Mouse/Trackpad
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.enableSecondaryClick" = true;

        # UI
        AppleShowScrollBars = "WhenScrolling";
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      # Trackpad
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      # Screenshots
      screencapture = {
        location = "~/Desktop";
        type = "png";
      };
    };

    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # Used for backwards compatibility
    stateVersion = 5;
  };

  # Enable Touch ID for sudo (new option name)
  security.pam.services.sudo_local.touchIdAuth = true;

  # Fonts (nerd-fonts are now separate packages in nixpkgs)
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
  ];

  # Add shells
  environment.shells = with pkgs; [ zsh bash ];
  programs.zsh.enable = true;

  # Set primary user
  users.users.putsuthisrisinlpa = {
    name = "putsuthisrisinlpa";
    home = "/Users/putsuthisrisinlpa";
  };
}
