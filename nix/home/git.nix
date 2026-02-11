{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Put Suthisrisinlpa";
    userEmail = "putto11262002@gmail.com";  # Update if needed

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };

    # Delta for better diffs
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "Nord";
        side-by-side = false;
      };
    };

    # Aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      lg = "log --oneline --graph --decorate";
      amend = "commit --amend --no-edit";
      undo = "reset --soft HEAD~1";
    };

    # Ignore patterns
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "node_modules/"
      ".env.local"
      ".env*.local"
      "__pycache__/"
      "*.pyc"
      ".direnv/"
    ];
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # Lazygit
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
        theme = {
          lightTheme = false;
        };
      };
    };
  };
}
